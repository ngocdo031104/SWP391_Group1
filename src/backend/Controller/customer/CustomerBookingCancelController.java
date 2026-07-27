package Controller.customer;

// Người làm: Dương
// Thời gian tạo: 14/07/2026
// Chức năng: Controller tiếp nhận yêu cầu hủy tour từ phía Customer.
// Ý nghĩa: Cho phép khách hàng gửi đơn yêu cầu hủy các booking đã thanh toán thành công (Success), tự động kiểm tra thời gian trước khi khởi hành (chặn hủy nếu dưới 24h), ghi nhận lý do và gửi thông báo hệ thống.

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

    // Sử dụng doPost để tiếp nhận yêu cầu gửi từ Form hủy đặt tour
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // 1. Kiểm tra trạng thái đăng nhập của khách hàng
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("sessionUser");
        String bookingCode = request.getParameter("bookingCode");
        String reason = request.getParameter("reason");

        // 2. Validate thông tin đầu vào bắt buộc
        if (bookingCode == null || bookingCode.trim().isEmpty() || reason == null || reason.trim().isEmpty()) {
            request.getSession().setAttribute("cancelError", "Vui lòng cung cấp đầy đủ thông tin yêu cầu hủy.");
            response.sendRedirect(request.getContextPath() + "/customer/booking/detail?code=" + (bookingCode != null ? bookingCode : ""));
            return;
        }

        // 3. Truy vấn thông tin booking kèm theo lịch trình tour từ database
        BookingDAO bookingDAO = new BookingDAO();
        Booking booking = bookingDAO.getBookingWithTourByCode(bookingCode);

        // 4. Bảo mật: Đảm bảo booking tồn tại và thuộc về đúng tài khoản đang đăng nhập
        if (booking == null || booking.getCustomerId() != user.getUserId()) {
            response.sendRedirect(request.getContextPath() + "/customer/booking/history");
            return;
        }

        // 5. Kiểm tra trạng thái booking: Chỉ cho phép gửi yêu cầu hủy đối với booking đã thanh toán thành công
        if (!"Success".equals(booking.getStatus())) {
            request.getSession().setAttribute("cancelError", "Đơn hàng này không thể gửi yêu cầu hủy và hoàn tiền.");
            response.sendRedirect(request.getContextPath() + "/customer/booking/detail?code=" + bookingCode);
            return;
        }

        // 6. Ràng buộc thời gian (Policy): Chặn gửi yêu cầu hủy nếu thời gian khởi hành còn lại dưới 7 ngày
        if (booking.getSchedule() != null && booking.getSchedule().getDepartureDate() != null) {
            long departureMs = booking.getSchedule().getDepartureDate().getTime();
            long nowMs = System.currentTimeMillis();
            long daysLeft = (departureMs - nowMs) / 86_400_000L;
            if (daysLeft < 7) {
                request.getSession().setAttribute("cancelError",
                        "Đã quá thời hạn cho phép hủy tour (trước 7 ngày so với ngày khởi hành). Vui lòng liên hệ hỗ trợ nếu có sự cố đặc biệt.");
                response.sendRedirect(request.getContextPath() + "/customer/booking/detail?code=" + bookingCode);
                return;
            }
        }

        CancellationRequestDAO cancelDAO = new CancellationRequestDAO();
        
        // 7. Kiểm tra trùng lặp: Đảm bảo booking chưa có yêu cầu hủy nào khác đang chờ xử lý
        if (cancelDAO.getPendingRequestByBookingId(booking.getBookingId()) != null) {
            request.getSession().setAttribute("cancelError", "Đã có yêu cầu hủy đang chờ duyệt cho đơn hàng này.");
            response.sendRedirect(request.getContextPath() + "/customer/booking/detail?code=" + bookingCode);
            return;
        }

        // 8. Khởi tạo đối tượng yêu cầu hủy và lưu vào database
        CancellationRequest cancelRequest = new CancellationRequest();
        cancelRequest.setBookingId(booking.getBookingId());
        cancelRequest.setRequestedBy(user.getUserId());
        cancelRequest.setReason(reason.trim());

        if (cancelDAO.createRequest(cancelRequest)) {
            // 9. Gửi thông báo tự động (in-app notification) cho khách hàng xác nhận đã tiếp nhận đơn hủy
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

        // 10. Chuyển hướng khách hàng về lại trang chi tiết booking để theo dõi trạng thái
        response.sendRedirect(request.getContextPath() + "/customer/booking/detail?code=" + bookingCode);
    }
}
