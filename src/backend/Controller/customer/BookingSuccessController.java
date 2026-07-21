package Controller.customer;

// Người làm: Dương
// Thời gian tạo: 04/06/2026
// Chức năng: Controller màn Customer hoàn tất booking.
// Ý nghĩa: Hiển thị mã booking, tên tour, số tiền và ngày khởi hành sau khi SePay ghi nhận thanh toán.

import Entities.Booking;
import Model.BookingDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "CustomerBookingSuccessController", urlPatterns = {"/customer/booking/success"})
public class BookingSuccessController extends HttpServlet {

    // doGet nhận mã booking từ query string và render màn thành công.
    // Controller vẫn kiểm tra đăng nhập để màn thành công chỉ thuộc luồng Customer đã đăng nhập.
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        if (!BookingFlowSupport.requireLogin(request, response)) {
            return;
        }

        // bookingCode là mã đơn vừa thanh toán xong, được truyền từ BookingPaymentController.
        String bookingCode = BookingFlowSupport.safeTrim(request.getParameter("code"));
        request.setAttribute("bookingCode", bookingCode);

        // Load thêm booking + tour để màn success hiển thị tên tour, số tiền và ngày khởi hành.
        // Dùng getBookingWithTourByCode để JOIN Booking -> TourSchedule -> Tour trong 1 query.
        BookingDAO bookingDAO = null;
        try {
            bookingDAO = new BookingDAO();
            if (!bookingCode.isEmpty()) {
                Booking booking = bookingDAO.getBookingWithTourByCode(bookingCode);
                request.setAttribute("booking", booking);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (bookingDAO != null) {
                bookingDAO.close();
            }
        }

        request.getRequestDispatcher("/customer/booking-success.jsp").forward(request, response);
    }
}