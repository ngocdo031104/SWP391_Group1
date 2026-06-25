package Controller.customer;

import Entities.Booking;
import Entities.BookingParticipant;
import Entities.CancellationRequest;
import Entities.User;
import Model.BookingDAO;
import Model.CancellationRequestDAO;
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
            request.getSession().setAttribute("cancelSuccess", "Yêu cầu hủy đã được gửi thành công. Chúng tôi sẽ liên hệ lại với bạn sớm nhất.");
        } else {
            request.getSession().setAttribute("cancelError", "Có lỗi xảy ra khi gửi yêu cầu hủy. Vui lòng thử lại sau.");
        }

        response.sendRedirect(request.getContextPath() + "/customer/booking/detail?code=" + bookingCode);
    }
}
