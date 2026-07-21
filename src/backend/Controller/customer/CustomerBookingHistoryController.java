package Controller.customer;

import Entities.Booking;
import Entities.User;
import Model.BookingDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

// Người làm: Dương
// Ngày tạo file: 26/06/2026
// Ý nghĩa: Controller này xử lý việc hiển thị danh sách lịch sử đặt tour của khách hàng (Customer).
// Dữ liệu được lấy từ DB thông qua BookingDAO, sau đó lọc theo tên tour, trạng thái, và thời gian.

@WebServlet(name = "CustomerBookingHistoryController", urlPatterns = {"/customer/booking/history"})
public class CustomerBookingHistoryController extends HttpServlet {

    // Phương thức doGet xử lý request hiển thị trang lịch sử booking.
    // Kiểm tra đăng nhập, lấy các tham số bộ lọc, truy vấn dữ liệu từ DB, lọc dữ liệu và trả về view.
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Thiết lập encoding UTF-8 để hỗ trợ tiếng Việt cho request và response.
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // Kiểm tra session đăng nhập. Nếu khách hàng chưa đăng nhập (hoặc session đã hết hạn),
        // sẽ bị điều hướng về trang đăng nhập.
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Lấy thông tin user hiện tại và các tham số tìm kiếm/lọc từ request URL.
        User user = (User) session.getAttribute("sessionUser");
        String searchName = request.getParameter("searchName");
        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");
        String filterStatus = request.getParameter("status");

        BookingDAO bookingDAO = null;
        try {
            bookingDAO = new BookingDAO();
            // Truy vấn danh sách toàn bộ booking của khách hàng này từ database.
            List<Booking> bookings = bookingDAO.getBookingsWithTourByCustomerId(user.getUserId());
            
            // Xây dựng danh sách tên tour (không trùng lặp) dưới định dạng JSON.
            // Mục đích là để sử dụng cho tính năng autocomplete (gợi ý từ khóa) trên giao diện.
            java.util.Set<String> uniqueTourNames = new java.util.HashSet<>();
            for (Booking b : bookings) {
                if (b.getSchedule() != null && b.getSchedule().getTour() != null) {
                    uniqueTourNames.add(b.getSchedule().getTour().getTourName());
                }
            }
            StringBuilder sb = new StringBuilder("[");
            int count = 0;
            for (String name : uniqueTourNames) {
                sb.append("\"").append(name.replace("\"", "\\\"")).append("\"");
                if (++count < uniqueTourNames.size()) {
                    sb.append(",");
                }
            }
            sb.append("]");
            // Đưa JSON chứa tên tour vào attribute để JSP có thể đọc được.
            request.setAttribute("tourNamesJson", sb.toString());
            
            // Lọc danh sách booking ngay trên bộ nhớ (In-memory filtering) dựa theo các tiêu chí từ user.
            
            // Lọc theo tên tour (nếu user có nhập từ khóa).
            if (searchName != null && !searchName.trim().isEmpty()) {
                final String lowerSearch = searchName.trim().toLowerCase();
                bookings.removeIf(b -> b.getSchedule() == null || b.getSchedule().getTour() == null 
                                     || !b.getSchedule().getTour().getTourName().toLowerCase().contains(lowerSearch));
            }
            
            // Lọc theo trạng thái của booking (nếu trạng thái khác "All").
            if (filterStatus != null && !filterStatus.trim().isEmpty() && !filterStatus.equals("All")) {
                bookings.removeIf(b -> !b.getStatus().equalsIgnoreCase(filterStatus));
            }
            
            // Lọc theo ngày bắt đầu (chỉ lấy những booking được tạo từ ngày này trở đi).
            if (fromDate != null && !fromDate.trim().isEmpty()) {
                java.sql.Date fd = java.sql.Date.valueOf(fromDate);
                bookings.removeIf(b -> b.getCreatedAt().before(new java.util.Date(fd.getTime())));
            }
            
            // Lọc theo ngày kết thúc (cộng thêm 1 ngày để bao gồm trọn vẹn ngày toDate).
            if (toDate != null && !toDate.trim().isEmpty()) {
                java.sql.Date td = java.sql.Date.valueOf(toDate);
                long nextDayMillis = td.getTime() + (1000 * 60 * 60 * 24);
                bookings.removeIf(b -> b.getCreatedAt().after(new java.util.Date(nextDayMillis)));
            }

            // Đẩy danh sách booking sau khi lọc cùng các giá trị bộ lọc hiện tại xuống JSP để giữ trạng thái form.
            request.setAttribute("bookings", bookings);
            request.setAttribute("searchName", searchName);
            request.setAttribute("fromDate", fromDate);
            request.setAttribute("toDate", toDate);
            request.setAttribute("status", filterStatus);

            // Chuyển tiếp (forward) request tới trang booking-history.jsp để hiển thị kết quả.
            request.getRequestDispatcher("/customer/booking-history.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }
}
