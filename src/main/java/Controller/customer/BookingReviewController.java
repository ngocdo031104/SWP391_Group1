package Controller.customer;

// Người làm: Dương
// Thời gian tạo: 04/06/2026
// Chức năng: Controller màn Customer xác nhận chi tiết booking.
// Ý nghĩa: Hiển thị BookingDraft cho khách kiểm tra, sau đó tạo Booking thật trong database khi khách chuyển sang thanh toán.

import Controller.customer.BookingFlowSupport.BookingDraft;
import Entities.Booking;
import Entities.Tour;
import Entities.User;
import Model.BookingDAO;
import Model.CouponDAO;
import Model.TourDAO;
import Model.TourScheduleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "CustomerBookingReviewController", urlPatterns = {"/customer/booking/review"})
public class BookingReviewController extends HttpServlet {

    // doGet hiển thị màn review từ BookingDraft trong session.
    // Nếu không có draft nghĩa là khách vào thẳng URL review, khi đó quay về trang khám phá tour.
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!BookingFlowSupport.requireLogin(request, response)) {
            return;
        }

        BookingDraft draft = getDraft(request);
        if (draft == null) {
            response.sendRedirect(request.getContextPath() + "/tourdiscovery");
            return;
        }

        String successMessage = (String) request.getSession().getAttribute("successMessage");
        if (successMessage != null) {
            request.setAttribute("successMessage", successMessage);
            request.getSession().removeAttribute("successMessage");
        }
        
        String errorMessage = (String) request.getSession().getAttribute("errorMessage");
        if (errorMessage != null) {
            request.setAttribute("errorMessage", errorMessage);
            request.getSession().removeAttribute("errorMessage");
        }

        TourDAO tourDAO = null;

        TourScheduleDAO tourScheduleDAO = null;

        try {
            tourDAO = new TourDAO();
            tourScheduleDAO = new TourScheduleDAO();
            Tour tour = tourDAO.getTourById(draft.tourId);
            // tour dùng để render card tour ở màn xác nhận.
            request.setAttribute("tour", tour);
            // Dương làm đoạn này: lấy lịch đã chọn trực tiếp từ TourScheduleDAO bằng ScheduleID + TourID.
            // Mục đích là màn xác nhận luôn có DepartureDate đúng từ bảng TourSchedule, kể cả khi TourDAO không nạp lịch đó.
            request.setAttribute("selectedSchedule", tourScheduleDAO.getScheduleByIdForTour(draft.scheduleId, draft.tourId));
            // draft chứa participant và tổng tiền đã tính ở bước create.
            request.setAttribute("draft", draft);
            request.getRequestDispatcher("/customer/booking-review.jsp").forward(request, response);
        } finally {
            if (tourScheduleDAO != null) {
                tourScheduleDAO.close();
            }
            if (tourDAO != null) {
                tourDAO.close();
            }
        }
    }

    // doPost được gọi khi khách bấm chuyển sang thanh toán.
    // Lúc này mới tạo Booking thật trong DB và trừ số chỗ trống bằng BookingDAO transaction.
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!BookingFlowSupport.requireLogin(request, response)) {
            return;
        }

        HttpSession session = request.getSession(false);
        BookingDraft draft = getDraft(request);
        User user = session != null ? (User) session.getAttribute("sessionUser") : null;
        if (draft == null || user == null) {
            response.sendRedirect(request.getContextPath() + "/tourdiscovery");
            return;
        }

        String action = request.getParameter("action");

        // Dương làm đoạn này: Xử lý áp dụng mã khuyến mãi ngay tại màn hình review trước khi tạo booking
        if ("applyCoupon".equals(action)) {
            CouponDAO couponDAO = null;
            String couponCode = BookingFlowSupport.safeTrim(request.getParameter("couponCode")).toUpperCase();
            
            if (!couponCode.isEmpty()) {
                try {
                    couponDAO = new CouponDAO();
                    Entities.Coupon coupon = couponDAO.getCouponByCode(couponCode);
                    if (coupon == null) {
                        session.setAttribute("errorMessage", "Mã giảm giá không hợp lệ hoặc đã hết hiệu lực.");
                        response.sendRedirect(request.getContextPath() + "/customer/booking/review");
                        return;
                    }
                    if (draft.baseAmount < coupon.getMinOrderAmount()) {
                        session.setAttribute("errorMessage", "Đơn hàng chưa đạt giá trị tối thiểu của mã giảm giá.");
                        response.sendRedirect(request.getContextPath() + "/customer/booking/review");
                        return;
                    }
                    
                    draft.couponId = coupon.getCouponId();
                    draft.couponCode = coupon.getCouponCode();
                    draft.discountAmount = BookingFlowSupport.calculateDiscount(draft.baseAmount, coupon);
                    
                    double taxableAmount = Math.max(0, draft.baseAmount - draft.discountAmount);
                    draft.vatAmount = BookingFlowSupport.calculateVatAmount(taxableAmount, draft.vatRatePercent);
                    draft.totalAmount = taxableAmount + draft.vatAmount;
                    
                    session.setAttribute("bookingDraft", draft);
                    session.setAttribute("successMessage", "Đã áp dụng mã giảm giá thành công.");
                } finally {
                    if (couponDAO != null) {
                        couponDAO.close();
                    }
                }
            } else {
                // Nếu khách hàng xóa mã giảm giá
                draft.couponId = null;
                draft.couponCode = "";
                draft.discountAmount = 0.0;
                double taxableAmount = draft.baseAmount;
                draft.vatAmount = BookingFlowSupport.calculateVatAmount(taxableAmount, draft.vatRatePercent);
                draft.totalAmount = taxableAmount + draft.vatAmount;
                session.setAttribute("bookingDraft", draft);
            }
            response.sendRedirect(request.getContextPath() + "/customer/booking/review");
            return;
        }

        // Dương làm đoạn này: bookingNote lấy từ ghi chú khách nhập ở màn create booking.
        // Nếu khách không nhập ghi chú, hệ thống dùng note mặc định để nhân viên vẫn biết nguồn tạo đơn.
        String bookingNote = BookingFlowSupport.safeTrim(draft.customerNote);
        if (bookingNote.isEmpty()) {
            bookingNote = "Đơn đặt tour được tạo từ màn hình đăng ký tham gia.";
        }

        // booking là entity thật để insert vào bảng Booking.
        Booking booking = new Booking();
        booking.setBookingCode(BookingFlowSupport.generateBookingCode());
        booking.setScheduleId(draft.scheduleId);
        booking.setCustomerId(user.getUserId());
        booking.setNumParticipants(draft.participantCount);
        booking.setBaseAmount(draft.baseAmount);
        booking.setDiscountAmount(draft.discountAmount);
        booking.setVatAmount(draft.vatAmount);
        booking.setTotalAmount(draft.totalAmount);
        booking.setStatus("PendingPayment");
        booking.setNotes(bookingNote);
        booking.setCouponId(draft.couponId);
        booking.setParticipants(draft.participants);

        BookingDAO bookingDAO = null;
        try {
            bookingDAO = new BookingDAO();
            // Dương làm đoạn này: dọn các booking PendingPayment đã quá 10 phút trước khi giữ slot mới.
            bookingDAO.releaseExpiredPendingPaymentBookings(BookingFlowSupport.PAYMENT_HOLD_MINUTES);
            boolean created = bookingDAO.createBooking(booking);
            if (!created) {
                request.setAttribute("errorMessage", "Không thể tạo booking. Vui lòng kiểm tra lại số chỗ còn trống.");
                doGet(request, response);
                return;
            }

            // Sau khi DB tạo booking thành công, lưu bookingId/bookingCode vào draft để màn payment sử dụng.
            draft.bookingId = booking.getBookingId();
            draft.bookingCode = booking.getBookingCode();
            // Dương làm đoạn này: lưu mốc giữ slot 10 phút để màn payment có bộ đếm ngược thống nhất với server.
            draft.paymentHoldStartedAtMillis = System.currentTimeMillis();
            draft.paymentExpiresAtMillis = draft.paymentHoldStartedAtMillis + BookingFlowSupport.PAYMENT_HOLD_MINUTES * 60L * 1000L;
            session.setAttribute("bookingDraft", draft);
            response.sendRedirect(request.getContextPath() + "/customer/booking/payment");
        } finally {
            if (bookingDAO != null) {
                bookingDAO.close();
            }
        }
    }

    // Lấy BookingDraft từ session, tách thành hàm riêng để doGet/doPost dùng chung.
    private BookingDraft getDraft(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null ? (BookingDraft) session.getAttribute("bookingDraft") : null;
    }
}
