package Controller;

// Người làm: Dương
// Thời gian tạo: 04/06/2026
// Chức năng: Webhook nhận thông báo giao dịch tiền vào từ SePay.
// Ý nghĩa: Khi SePay báo khách đã chuyển khoản đúng nội dung booking, controller tạo Payment và cập nhật Booking sang Success sau khi thanh toán hợp lệ.

import Entities.Booking;
import Entities.Payment;
import Model.BookingDAO;
import Model.CouponDAO;
import Model.PaymentDAO;
import Utils.SepayConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@WebServlet(name = "SepayWebhookController", urlPatterns = {"/webhook/sepay"})
public class SepayWebhookController extends HttpServlet {
    private static final DateTimeFormatter SEPAY_DATE_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    // doPost là cửa vào cho SePay, không yêu cầu login vì request đến từ server SePay chứ không phải trình duyệt customer.
    // Controller xác thực bằng header Authorization trước khi đọc payload và cập nhật database.
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String expectedAuth = "Apikey " + SepayConfig.WEBHOOK_API_KEY;
        String actualAuth = request.getHeader("Authorization");
        if (!expectedAuth.equals(actualAuth)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\":false,\"message\":\"Unauthorized webhook\"}");
            return;
        }

        String payload = readBody(request);
        String transferType = extractString(payload, "transferType");
        String content = extractString(payload, "content");
        String referenceCode = extractString(payload, "referenceCode");
        String transactionDate = extractString(payload, "transactionDate");
        double transferAmount = extractDouble(payload, "transferAmount");
        String bookingCode = extractBookingCode(content);

        if (!"in".equalsIgnoreCase(transferType) || bookingCode.isEmpty()) {
            response.getWriter().write("{\"success\":true,\"matched\":false}");
            return;
        }

        BookingDAO bookingDAO = null;
        PaymentDAO paymentDAO = null;
        CouponDAO couponDAO = null;
        try {
            bookingDAO = new BookingDAO();
            paymentDAO = new PaymentDAO();
            bookingDAO.releaseExpiredPendingPaymentBookings(Controller.customer.BookingFlowSupport.PAYMENT_HOLD_MINUTES);

            Booking booking = bookingDAO.getBookingByCode(bookingCode);
            if (booking == null || "Cancelled".equalsIgnoreCase(booking.getStatus()) || transferAmount < booking.getTotalAmount()) {
                response.getWriter().write("{\"success\":true,\"matched\":false}");
                return;
            }

            String transactionRef = !referenceCode.isEmpty() ? referenceCode : "SEPAY-" + bookingCode;
            if (!paymentDAO.existsByTransactionRef(transactionRef)) {
                Payment payment = new Payment();
                payment.setBookingId(booking.getBookingId());
                payment.setPaymentMethod("BankTransfer");
                payment.setTransactionRef(transactionRef);
                payment.setAmount(transferAmount);
                payment.setCurrency("VND");
                payment.setStatus("Success");
                payment.setPaidAt(parsePaidAt(transactionDate));
                payment.setGatewayResponse(payload);
                paymentDAO.createPayment(payment);
            }

            bookingDAO.updateBookingStatus(booking.getBookingId(), "Success");
            if (booking.getCouponId() != null) {
                couponDAO = new CouponDAO();
                couponDAO.updateCouponUsage(booking.getCouponId());
            }

            response.getWriter().write("{\"success\":true,\"matched\":true,\"bookingCode\":\"" + escapeJson(bookingCode) + "\"}");
        } finally {
            if (couponDAO != null) {
                couponDAO.close();
            }
            if (paymentDAO != null) {
                paymentDAO.close();
            }
            if (bookingDAO != null) {
                bookingDAO.close();
            }
        }
    }

    // readBody gom toàn bộ JSON body SePay gửi đến thành một chuỗi để xử lý các field cần thiết.
    private String readBody(HttpServletRequest request) throws IOException {
        StringBuilder body = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                body.append(line);
            }
        }
        return body.toString();
    }

    // extractString lấy giá trị chuỗi từ JSON webhook theo tên field, đủ dùng cho payload SePay dạng phẳng.
    private String extractString(String json, String fieldName) {
        Pattern pattern = Pattern.compile("\\\"" + Pattern.quote(fieldName) + "\\\"\\s*:\\s*\\\"(.*?)\\\"");
        Matcher matcher = pattern.matcher(json);
        return matcher.find() ? matcher.group(1) : "";
    }

    // extractDouble lấy số tiền từ JSON webhook để so sánh với TotalAmount của booking.
    private double extractDouble(String json, String fieldName) {
        Pattern pattern = Pattern.compile("\\\"" + Pattern.quote(fieldName) + "\\\"\\s*:\\s*([0-9]+(?:\\.[0-9]+)?)");
        Matcher matcher = pattern.matcher(json);
        return matcher.find() ? Double.parseDouble(matcher.group(1)) : 0;
    }

    // extractBookingCode tìm mã booking trong nội dung chuyển khoản để biết giao dịch thuộc booking nào.
    // SePay/ngân hàng đôi khi bỏ dấu gạch ngang, ví dụ TB1780570170226, nên hàm chuẩn hóa về dạng TB-1780570170226 trước khi tìm Booking.
    private String extractBookingCode(String content) {
        Pattern pattern = Pattern.compile("TB-?([A-Za-z0-9]+)", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(content != null ? content : "");
        return matcher.find() ? ("TB-" + matcher.group(1)).toUpperCase() : "";
    }
    // parsePaidAt chuyển thời gian giao dịch của SePay sang Timestamp; nếu không parse được thì dùng thời điểm server nhận webhook.
    private Timestamp parsePaidAt(String transactionDate) {
        try {
            if (transactionDate != null && !transactionDate.isEmpty()) {
                return Timestamp.valueOf(LocalDateTime.parse(transactionDate, SEPAY_DATE_FORMAT));
            }
        } catch (RuntimeException ex) {
            // Bỏ qua lỗi định dạng thời gian từ webhook và dùng thời gian hiện tại để không làm rớt giao dịch hợp lệ.
        }
        return new Timestamp(System.currentTimeMillis());
    }

    // escapeJson xử lý ký tự đặc biệt trước khi trả response JSON cho SePay.
    private String escapeJson(String value) {
        return value == null ? "" : value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
