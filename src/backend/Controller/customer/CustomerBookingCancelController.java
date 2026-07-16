package Controller.customer;

import Entities.Booking;
import Entities.CancellationRequest;
import Entities.Notification;
import Entities.User;
import Model.BookingDAO;
import Model.CancellationRequestDAO;
import Model.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "CustomerBookingCancelController", urlPatterns = {"/customer/booking/cancel"})
public class CustomerBookingCancelController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("sessionUser");
        String bookingCode = request.getParameter("bookingCode");
        String reason = request.getParameter("reason");

        if (bookingCode == null || bookingCode.trim().isEmpty() || reason == null || reason.trim().isEmpty()) {
            request.getSession().setAttribute("cancelError", "Vui lòng cung cấp đầy đủ thông tin yêu cầu hủy.");
            response.sendRedirect(request.getContextPath() + "/customer/booking/detail?code=" + (bookingCode != null ? bookingCode : ""));
            return;
        }

        BookingDAO bookingDAO = new BookingDAO();
        Booking booking = bookingDAO.getBookingWithTourByCode(bookingCode);

        if (booking == null || booking.getCustomerId() != user.getUserId()) {
            response.sendRedirect(request.getContextPath() + "/customer/booking/history");
            return;
        }

        // Only allow cancel request for 'Success' bookings
        if (!"Success".equals(booking.getStatus())) {
            request.getSession().setAttribute("cancelError", "Đơn hàng này không thể gửi yêu cầu hủy và hoàn tiền.");
            response.sendRedirect(request.getContextPath() + "/customer/booking/detail?code=" + bookingCode);
            return;
        }

        // BR (UC26 Alternative 5a): chặn gửi yêu cầu hủy khi còn dưới 24 giờ trước departure.
        // Policy: ngoài 24h trước departure mới được yêu cầu hủy; trong 24h thuộc non-refundable window.
        if (booking.getSchedule() != null && booking.getSchedule().getDepartureDate() != null) {
            long departureMs = booking.getSchedule().getDepartureDate().getTime();
            long nowMs = System.currentTimeMillis();
            long hoursLeft = (departureMs - nowMs) / 3_600_000L;
            if (hoursLeft < 24) {
                request.getSession().setAttribute("cancelError",
                        "Đã quá thời hạn cho phép hủy tour (trước 24 giờ so với giờ khởi hành). Vui lòng liên hệ hỗ trợ nếu có sự cố đặc biệt.");
                response.sendRedirect(request.getContextPath() + "/customer/booking/detail?code=" + bookingCode);
                return;
            }
        }

        CancellationRequestDAO cancelDAO = new CancellationRequestDAO();
        
        // Check if there's already a pending request
        if (cancelDAO.getPendingRequestByBookingId(booking.getBookingId()) != null) {
            request.getSession().setAttribute("cancelError", "Đã có yêu cầu hủy đang chờ duyệt cho đơn hàng này.");
            response.sendRedirect(request.getContextPath() + "/customer/booking/detail?code=" + bookingCode);
            return;
        }

        CancellationRequest cancelRequest = new CancellationRequest();
        cancelRequest.setBookingId(booking.getBookingId());
        cancelRequest.setRequestedBy(user.getUserId());
        cancelRequest.setReason(reason.trim());

        if (cancelDAO.createRequest(cancelRequest)) {
            // UC30: Gửi thông báo in-app xác nhận đã tiếp nhận yêu cầu hủy.
            // Không để lỗi notification chặn redirect vì createRequest() đã thành công.
            try {
                NotificationDAO notifDAO = new NotificationDAO();
                Notification notif = new Notification();
                notif.setUserId(user.getUserId());
                notif.setSenderId(null);
                notif.setTitle("Yêu cầu hủy đã được tiếp nhận — " + bookingCode);
                notif.setContent("Yêu cầu hủy đặt tour của bạn (đơn " + bookingCode + ") đã được ghi nhận. Kế toán sẽ xử lý trong 1–3 ngày làm việc. Theo dõi trạng thái trong mục Lịch sử đặt tour.");
                notif.setChannel("SYSTEM");
                notif.setCategory("Booking");
                notif.setScheduledAt(null);
                notif.setStatus("SENT");
                notifDAO.insertNotification(notif);
            } catch (Exception notifEx) {
                notifEx.printStackTrace();
            }
            request.getSession().setAttribute("cancelSuccess", "Yêu cầu hủy đã được gửi thành công. Chúng tôi sẽ liên hệ lại với bạn sớm nhất.");
        } else {
            request.getSession().setAttribute("cancelError", "Có lỗi xảy ra khi gửi yêu cầu hủy. Vui lòng thử lại sau.");
        }

        response.sendRedirect(request.getContextPath() + "/customer/booking/detail?code=" + bookingCode);
    }
}
