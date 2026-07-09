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

// Dương làm đoạn này
// Thời gian tạo: 26/06/2026
// Chức năng: Hiển thị danh sách lịch sử đặt tour của khách hàng
@WebServlet(name = "CustomerBookingHistoryController", urlPatterns = {"/customer/booking/history"})
public class CustomerBookingHistoryController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("sessionUser");
        String searchName = request.getParameter("searchName");
        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");
        String filterStatus = request.getParameter("status");

        BookingDAO bookingDAO = null;
        try {
            bookingDAO = new BookingDAO();
            List<Booking> bookings = bookingDAO.getBookingsWithTourByCustomerId(user.getUserId());
            
            // Lấy danh sách tên tour duy nhất để làm autocomplete
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
            request.setAttribute("tourNamesJson", sb.toString());
            
            // In-memory filtering
            if (searchName != null && !searchName.trim().isEmpty()) {
                final String lowerSearch = searchName.trim().toLowerCase();
                bookings.removeIf(b -> b.getSchedule() == null || b.getSchedule().getTour() == null 
                                     || !b.getSchedule().getTour().getTourName().toLowerCase().contains(lowerSearch));
            }
            if (filterStatus != null && !filterStatus.trim().isEmpty() && !filterStatus.equals("All")) {
                bookings.removeIf(b -> !b.getStatus().equalsIgnoreCase(filterStatus));
            }
            if (fromDate != null && !fromDate.trim().isEmpty()) {
                java.sql.Date fd = java.sql.Date.valueOf(fromDate);
                bookings.removeIf(b -> b.getCreatedAt().before(new java.util.Date(fd.getTime())));
            }
            if (toDate != null && !toDate.trim().isEmpty()) {
                // To include the whole day, we add 1 day to 'toDate'
                java.sql.Date td = java.sql.Date.valueOf(toDate);
                long nextDayMillis = td.getTime() + (1000 * 60 * 60 * 24);
                bookings.removeIf(b -> b.getCreatedAt().after(new java.util.Date(nextDayMillis)));
            }

            request.setAttribute("bookings", bookings);
            request.setAttribute("searchName", searchName);
            request.setAttribute("fromDate", fromDate);
            request.setAttribute("toDate", toDate);
            request.setAttribute("status", filterStatus);

            request.getRequestDispatcher("/customer/booking-history.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }
}
