package Controller.customer;

// Người làm: Dương
// Thời gian tạo: 04/06/2026
// Chức năng: Controller màn Customer thanh toán booking.
// Ý nghĩa: Nạp màn thanh toán, xử lý coupon ở bước payment, hiển thị VietQR và chờ webhook SePay xác nhận chuyển khoản.

import Controller.customer.BookingFlowSupport.BookingDraft;
import Entities.Booking;
import Entities.Coupon;
import Entities.Tour;
import Model.BookingDAO;
import Model.CouponDAO;
import Model.InvoiceDAO;
import Model.TourDAO;
import Model.TourScheduleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "CustomerBookingPaymentController", urlPatterns = {"/customer/booking/payment"})
public class BookingPaymentController extends HttpServlet {

    // doGet hiển thị màn thanh toán sau khi booking thật đã được tạo ở bước review.
    // Điều kiện draft.bookingId > 0 đảm bảo khách không vào màn payment khi chưa có booking trong DB.
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!BookingFlowSupport.requireLogin(request, response)) {
            return;
        }

        BookingDraft draft = getDraft(request);
        if (draft == null || draft.bookingId <= 0) {
            response.sendRedirect(request.getContextPath() + "/tourdiscovery");
            return;
        }

BookingDAO bookingDAO = null;
        try {
            bookingDAO = new BookingDAO();
            // Dương làm đoạn này: nếu booking PendingPayment quá 10 phút thì nhả slot trước khi hiển thị QR.
            bookingDAO.releaseExpiredPendingPaymentBookings(BookingFlowSupport.PAYMENT_HOLD_MINUTES);
            Booking booking = bookingDAO.getBookingByCode(draft.bookingCode);
            if (booking == null || "Cancelled".equalsIgnoreCase(booking.getStatus())) {
                request.getSession().removeAttribute("bookingDraft");
                request.getSession().setAttribute("bookingExpiredMessage", "Đơn giữ chỗ đã quá 10 phút chưa thanh toán nên hệ thống đã nhả slot. Vui lòng tạo lại booking.");
                response.sendRedirect(request.getContextPath() + "/customer/booking/create?tourId=" + draft.tourId);
                return;
            }
        } finally {
            if (bookingDAO != null) {
                bookingDAO.close();
            }
        }

        forwardPayment(request, response, draft, null);
    }

    // doPost xử lý cập nhật coupon/số tiền trước khi khách quét VietQR.
    // Logic gồm: kiểm tra coupon nếu có, cập nhật tài chính Booking và quay lại màn chờ SePay webhook.
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!BookingFlowSupport.requireLogin(request, response)) {
            return;
        }

        HttpSession session = request.getSession(false);
        BookingDraft draft = getDraft(request);
        if (draft == null || draft.bookingId <= 0) {
            response.sendRedirect(request.getContextPath() + "/tourdiscovery");
            return;
        }

        BookingDAO holdBookingDAO = null;
        try {
            holdBookingDAO = new BookingDAO();
            holdBookingDAO.releaseExpiredPendingPaymentBookings(BookingFlowSupport.PAYMENT_HOLD_MINUTES);
            Booking booking = holdBookingDAO.getBookingByCode(draft.bookingCode);
            if (booking == null || "Cancelled".equalsIgnoreCase(booking.getStatus())) {
                session.removeAttribute("bookingDraft");
                session.setAttribute("bookingExpiredMessage", "Đơn giữ chỗ đã quá 10 phút chưa thanh toán nên hệ thống đã nhả slot. Vui lòng tạo lại booking.");
                response.sendRedirect(request.getContextPath() + "/customer/booking/create?tourId=" + draft.tourId);
                return;
            }
        } finally {
            if (holdBookingDAO != null) {
                holdBookingDAO.close();
            }
        }

        // couponCode chỉ được xử lý ở màn payment theo yêu cầu nghiệp vụ.
        // Nếu coupon hợp lệ, draft được cập nhật lại discount/vat/total trước khi tạo lại VietQR.
        CouponDAO couponDAO = null;
        String couponCode = BookingFlowSupport.safeTrim(request.getParameter("couponCode")).toUpperCase();
        if (!couponCode.isEmpty()) {
            couponDAO = new CouponDAO();
            Coupon coupon = couponDAO.getCouponByCode(couponCode);
            if (coupon == null) {
                closeCouponDao(couponDAO);
                forwardPayment(request, response, draft, "Mã giảm giá không hợp lệ hoặc đã hết hiệu lực.");
                return;
            }
            if (draft.baseAmount < coupon.getMinOrderAmount()) {
                closeCouponDao(couponDAO);
                forwardPayment(request, response, draft, "Đơn hàng chưa đạt giá trị tối thiểu của mã giảm giá.");
                return;
            }

            draft.couponId = coupon.getCouponId();
            draft.couponCode = coupon.getCouponCode();
            draft.discountAmount = BookingFlowSupport.calculateDiscount(draft.baseAmount, coupon);
            double taxableAmount = Math.max(0, draft.baseAmount - draft.discountAmount);
            // Dùng VATRate đã đọc từ bảng Invoice; nếu không có rate hợp lệ thì dừng để tránh tính sai tiền.
            Double vatRatePercent = ensureVatRatePercent(draft);
            if (vatRatePercent == null) {
                closeCouponDao(couponDAO);
                forwardPayment(request, response, draft, "Chưa cấu hình VATRate hợp lệ trong bảng Invoice. Vui lòng kiểm tra database.");
                return;
            }
            draft.vatRatePercent = vatRatePercent;
            draft.vatAmount = BookingFlowSupport.calculateVatAmount(taxableAmount, vatRatePercent);
            draft.totalAmount = taxableAmount + draft.vatAmount;
        }

        BookingDAO bookingDAO = null;
        try {
            bookingDAO = new BookingDAO();
            // Dương làm đoạn này: cập nhật lại số tiền booking nếu khách áp dụng coupon trước khi quét VietQR.
            // Payment chưa được tạo ở đây; hệ thống chỉ tạo Payment khi SePay webhook báo giao dịch tiền vào hợp lệ.
            bookingDAO.updateBookingFinancials(draft.bookingId, draft.discountAmount, draft.vatAmount, draft.totalAmount, draft.couponId);
            session.setAttribute("bookingDraft", draft);
            forwardPayment(request, response, draft, "Mã QR đã được cập nhật. Vui lòng chuyển khoản đúng số tiền và nội dung booking để SePay xác nhận tự động.");
        } finally {
            if (bookingDAO != null) {
                bookingDAO.close();
            }
            if (couponDAO != null) {
                couponDAO.close();
            }
        }
    }

    // forwardPayment nạp lại tour và schedule để màn payment có đủ dữ liệu hiển thị.
    // errorMessage có thể null khi vào màn bình thường hoặc có giá trị khi coupon/payment lỗi.
    private void forwardPayment(HttpServletRequest request, HttpServletResponse response, BookingDraft draft, String errorMessage)
            throws ServletException, IOException {
        TourDAO tourDAO = null;
        TourScheduleDAO tourScheduleDAO = null;
        try {
            tourDAO = new TourDAO();
            tourScheduleDAO = new TourScheduleDAO();
            Tour tour = tourDAO.getTourById(draft.tourId);
            request.setAttribute("tour", tour);
            // Dương làm đoạn này: lấy lịch thanh toán trực tiếp từ TourScheduleDAO để hiển thị đúng DepartureDate của booking.
            request.setAttribute("selectedSchedule", tourScheduleDAO.getScheduleByIdForTour(draft.scheduleId, draft.tourId));
            request.setAttribute("draft", draft);
            request.setAttribute("errorMessage", errorMessage);
            request.getRequestDispatcher("/customer/booking-payment.jsp").forward(request, response);
        } finally {
            if (tourScheduleDAO != null) {
                tourScheduleDAO.close();
            }
            if (tourDAO != null) {
                tourDAO.close();
            }
        }
    }

    // Hàm ensureVatRatePercent đảm bảo draft luôn có VATRate hợp lệ trước khi tính lại tiền sau coupon.
    // Draft mới sẽ có vatRatePercent từ màn create; draft cũ trong session nếu chưa có thì đọc lại từ database.
    private Double ensureVatRatePercent(BookingDraft draft) {
        if (draft.vatRatePercent > 0) {
            return draft.vatRatePercent;
        }

        InvoiceDAO invoiceDAO = null;
        try {
            invoiceDAO = new InvoiceDAO();
            return invoiceDAO.getDefaultVatRatePercent();
        } finally {
            if (invoiceDAO != null) {
                invoiceDAO.close();
            }
        }
    }

    // Lấy BookingDraft từ session để dùng cho cả GET và POST màn payment.
    private BookingDraft getDraft(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null ? (BookingDraft) session.getAttribute("bookingDraft") : null;
    }

    // Đóng CouponDAO sớm ở các nhánh lỗi coupon để tránh giữ connection không cần thiết.
    private void closeCouponDao(CouponDAO couponDAO) {
        if (couponDAO != null) {
            couponDAO.close();
        }
    }
}
