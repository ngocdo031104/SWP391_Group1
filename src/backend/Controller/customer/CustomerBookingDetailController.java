package Controller.customer;

import Entities.Booking;
import Entities.Payment;
import Entities.User;
import Entities.CancellationRequest;
import Model.BookingDAO;
import Model.CancellationRequestDAO;
import Model.PaymentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

// Dương làm đoạn này
// Thời gian tạo: 26/06/2026
// Chức năng: Hiển thị chi tiết một đơn đặt tour cụ thể
@WebServlet(name = "CustomerBookingDetailController", urlPatterns = {"/customer/booking/detail"})
public class CustomerBookingDetailController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("sessionUser");
        String bookingCode = request.getParameter("code");

        if (bookingCode == null || bookingCode.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/booking/history");
            return;
        }

        BookingDAO bookingDAO = null;
        PaymentDAO paymentDAO = null;
        try {
            bookingDAO = new BookingDAO();
            Booking booking = bookingDAO.getBookingWithTourByCode(bookingCode);
            
            // Xác thực: Booking phải tồn tại và thuộc về user đang đăng nhập
            if (booking == null || booking.getCustomerId() != user.getUserId()) {
                response.sendRedirect(request.getContextPath() + "/customer/booking/history");
                return;
            }

            // Lấy thông tin thanh toán (nếu có)
            paymentDAO = new PaymentDAO();
            Payment payment = paymentDAO.getPaymentByBookingId(booking.getBookingId());

            CancellationRequestDAO cancelDAO = new CancellationRequestDAO();
            CancellationRequest pendingCancel = cancelDAO.getPendingRequestByBookingId(booking.getBookingId());

            request.setAttribute("booking", booking);
            request.setAttribute("payment", payment);
            request.setAttribute("pendingCancel", pendingCancel);
            
            request.getRequestDispatcher("/customer/booking-detail.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/customer/booking/history");
        }
    }
}
