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
        booking.setNotes("Đơn đặt tour được tạo từ màn hình đăng ký tham gia.");
        booking.setCouponId(draft.couponId);
        booking.setParticipants(draft.participants);

        BookingDAO bookingDAO = null;
        try {
            bookingDAO = new BookingDAO();
            boolean created = bookingDAO.createBooking(booking);
            if (!created) {
                request.setAttribute("errorMessage", "Không thể tạo booking. Vui lòng kiểm tra lại số chỗ còn trống.");
                doGet(request, response);
                return;
            }

            // Sau khi DB tạo booking thành công, lưu bookingId/bookingCode vào draft để màn payment sử dụng.
            draft.bookingId = booking.getBookingId();
            draft.bookingCode = booking.getBookingCode();
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