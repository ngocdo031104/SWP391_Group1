package Controller.customer;

// Người làm: Dương
// Thời gian tạo: 04/06/2026
// Chức năng: Controller màn Customer thanh toán booking.
// Ý nghĩa: Nạp màn thanh toán, xử lý coupon ở bước payment, tạo Payment và cập nhật Booking sang Confirmed.

import Controller.customer.BookingFlowSupport.BookingDraft;
import Entities.Coupon;
import Entities.Payment;
import Entities.Tour;
import Model.BookingDAO;
import Model.CouponDAO;
import Model.InvoiceDAO;
import Model.PaymentDAO;
import Model.TourDAO;
import Model.TourScheduleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;

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

        forwardPayment(request, response, draft, null);
    }

    // doPost xử lý thanh toán.
    // Logic gồm: đọc paymentMethod, kiểm tra coupon nếu có, cập nhật tổng tiền booking, tạo payment và xác nhận booking.
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

        // paymentMethod là phương thức khách chọn trên form payment.
        // Nếu request không gửi giá trị thì mặc định VNPay để tránh tạo Payment thiếu method.
        String paymentMethod = BookingFlowSupport.safeTrim(request.getParameter("paymentMethod"));
        if (paymentMethod.isEmpty()) {
            paymentMethod = "VNPay";
        }

        // couponCode chỉ được xử lý ở màn payment theo yêu cầu nghiệp vụ.
        // Nếu coupon hợp lệ, draft được cập nhật lại discount/vat/total trước khi tạo Payment.
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

        // payment là entity giao dịch thanh toán để insert vào bảng Payment.
        // Luồng hiện tại mô phỏng thanh toán thành công nên status được set là Success.
        Payment payment = new Payment();
        payment.setBookingId(draft.bookingId);
        payment.setPaymentMethod(paymentMethod);
        payment.setTransactionRef("TBPAY-" + System.currentTimeMillis());
        payment.setAmount(draft.totalAmount);
        payment.setCurrency("VND");
        payment.setStatus("Success");
        payment.setPaidAt(new Timestamp(System.currentTimeMillis()));
        payment.setGatewayResponse("Simulated payment success from customer booking payment screen");

        PaymentDAO paymentDAO = null;
        BookingDAO bookingDAO = null;
        try {
            paymentDAO = new PaymentDAO();
            bookingDAO = new BookingDAO();

            // Cập nhật lại các cột tài chính của Booking trước khi tạo Payment để DB khớp với coupon đã áp dụng.
            bookingDAO.updateBookingFinancials(draft.bookingId, draft.discountAmount, draft.vatAmount, draft.totalAmount, draft.couponId);
            boolean paid = paymentDAO.createPayment(payment);
            if (!paid) {
                forwardPayment(request, response, draft, "Thanh toán chưa thành công. Vui lòng thử lại.");
                return;
            }

            // Khi payment thành công, booking chuyển từ PendingPayment sang Confirmed.
            bookingDAO.updateBookingStatus(draft.bookingId, "Confirmed");
            if (draft.couponId != null && couponDAO != null) {
                couponDAO.updateCouponUsage(draft.couponId);
            }
            session.removeAttribute("bookingDraft");
            response.sendRedirect(request.getContextPath() + "/customer/booking/success?code=" + draft.bookingCode);
        } finally {
            if (paymentDAO != null) {
                paymentDAO.close();
            }
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
