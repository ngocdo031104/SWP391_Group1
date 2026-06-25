package Controller.customer;

// Người làm: Dương
// Thời gian tạo: 25/06/2026
// Chức năng: Controller xử lý yêu cầu xem hóa đơn của khách hàng sau khi thanh toán.
// Ý nghĩa: Nhận mã booking từ query string, dùng BookingDAO để lấy đầy đủ thông tin booking
//           (bao gồm cả tên tour, ngày đi, ngày về), sau đó lấy hóa đơn tương ứng qua InvoiceDAO
//           và forward tất cả dữ liệu sang booking-invoice.jsp để hiển thị.

import Entities.Booking;
import Entities.Invoice;
import Model.BookingDAO;
import Model.InvoiceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "CustomerInvoiceController", urlPatterns = {"/customer/booking/invoice"})
public class CustomerInvoiceController extends HttpServlet {

    // doGet nhận code booking từ URL (?code=TB-...) và chuẩn bị dữ liệu cho trang hóa đơn.
    // Chỉ cho phép khách đã đăng nhập xem, dùng BookingFlowSupport.requireLogin để kiểm tra.
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // Kiểm tra đăng nhập; nếu chưa login thì redirect sang trang đăng nhập
        if (!BookingFlowSupport.requireLogin(request, response)) {
            return;
        }

        // Lấy mã booking từ query string; nếu rỗng thì về trang chủ để tránh trang lỗi trống
        String bookingCode = BookingFlowSupport.safeTrim(request.getParameter("code"));
        if (bookingCode.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        BookingDAO bookingDAO = null;
        InvoiceDAO invoiceDAO = null;
        try {
            bookingDAO = new BookingDAO();

            // Dùng getBookingWithTourByCode thay vì getBookingByCode để lấy thêm thông tin
            // tour (tên tour, điểm đến, ngày khởi hành, ngày về) phục vụ hiển thị trên hóa đơn
            Booking booking = bookingDAO.getBookingWithTourByCode(bookingCode);

            // Nếu không tìm thấy booking thì báo lỗi thay vì để trang bị null pointer
            if (booking == null) {
                request.setAttribute("error", "Không tìm thấy thông tin đơn hàng.");
                request.getRequestDispatcher("/customer/booking-invoice.jsp").forward(request, response);
                return;
            }

            invoiceDAO = new InvoiceDAO();

            // Lấy hóa đơn theo bookingId; có thể null nếu webhook chưa tạo kịp
            Invoice invoice = invoiceDAO.getInvoiceByBookingId(booking.getBookingId());

            // Đẩy booking và invoice vào request scope để booking-invoice.jsp dùng bằng EL
            request.setAttribute("booking", booking);
            request.setAttribute("invoice", invoice);
            request.getRequestDispatcher("/customer/booking-invoice.jsp").forward(request, response);
        } finally {
            // Đóng kết nối DB trong finally để đảm bảo không bị rò rỉ dù xảy ra exception
            if (invoiceDAO != null) {
                invoiceDAO.close();
            }
            if (bookingDAO != null) {
                bookingDAO.close();
            }
        }
    }
}
