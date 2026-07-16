package Controller.customer;

// Người làm: Dương
// Thời gian tạo: 04/06/2026
// Chức năng: API kiểm tra trạng thái thanh toán SePay cho màn Customer payment.
// Ý nghĩa: Cho JavaScript polling trạng thái Booking sau khi webhook SePay ghi nhận thanh toán và chuyển đơn sang trạng thái Success.

import Entities.Booking;
import Entities.Notification;
import Entities.User;
import Model.BookingDAO;
import Model.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "CustomerBookingPaymentStatusController", urlPatterns = {"/customer/booking/payment-status"})
public class BookingPaymentStatusController extends HttpServlet {

    // doGet trả JSON đơn giản để màn payment biết booking đã được SePay xác nhận hay chưa.
    // Request vẫn yêu cầu đăng nhập vì endpoint này thuộc trải nghiệm Customer đang xem đơn của chính mình.
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        if (!BookingFlowSupport.requireLogin(request, response)) {
            return;
        }

        String bookingCode = BookingFlowSupport.safeTrim(request.getParameter("code"));
        BookingDAO bookingDAO = null;
        try {
            bookingDAO = new BookingDAO();
            bookingDAO.releaseExpiredPendingPaymentBookings(BookingFlowSupport.PAYMENT_HOLD_MINUTES);
            Booking booking = bookingDAO.getBookingByCode(bookingCode);
            boolean paid = booking != null && ("Success".equalsIgnoreCase(booking.getStatus()) || "Completed".equalsIgnoreCase(booking.getStatus()));
            String status = booking != null ? booking.getStatus() : "NotFound";
            boolean expired = booking != null && "Cancelled".equalsIgnoreCase(booking.getStatus());

            // UC30: Gửi thông báo 1 lần duy nhất khi phát hiện booking vừa chuyển sang Success.
            // Dùng session flag "notif_sent_{bookingCode}" để tránh gửi trùng qua mỗi lần polling.
            if (paid && booking != null) {
                HttpSession session = request.getSession(false);
                String flagKey = "notif_sent_" + bookingCode;
                if (session != null && session.getAttribute(flagKey) == null) {
                    session.setAttribute(flagKey, true);
                    try {
                        User currentUser = (User) session.getAttribute("sessionUser");
                        int customerId = (currentUser != null) ? currentUser.getUserId() : booking.getCustomerId();

                        NotificationDAO notifDAO = new NotificationDAO();
                        Notification notif = new Notification();
                        notif.setUserId(customerId);
                        notif.setSenderId(null);
                        notif.setTitle("Đặt tour thành công — " + bookingCode);
                        notif.setContent("Booking " + bookingCode + " đã được xác nhận thanh toán. Cảm ơn bạn đã đặt tour tại TourBuddy! Xem chi tiết tại mục Lịch sử đặt tour.");
                        notif.setChannel("SYSTEM");
                        notif.setCategory("Booking");
                        notif.setScheduledAt(null);
                        notif.setStatus("SENT");
                        notifDAO.insertNotification(notif);
                        notifDAO.close();
                    } catch (Exception notifEx) {
                        // Không để lỗi notification làm hỏng response polling
                        notifEx.printStackTrace();
                    }
                }
            }

            response.getWriter().write("{\"paid\":" + paid + ",\"expired\":" + expired + ",\"status\":\"" + escapeJson(status) + "\"}");
        } finally {
            if (bookingDAO != null) {
                bookingDAO.close();
            }
        }
    }

    // escapeJson xử lý các ký tự đặc biệt để status luôn là chuỗi JSON hợp lệ.
    private String escapeJson(String value) {
        return value == null ? "" : value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
