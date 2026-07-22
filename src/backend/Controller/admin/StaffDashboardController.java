package Controller.admin;

// Nguoi lam: Duong
// Hien thi tong quan: so luong booking theo trang thai, loi tat den cac chuc nang chinh.

import Entities.User;
import Model.BookingDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "StaffDashboardController", urlPatterns = {"/staff/dashboard"})
public class StaffDashboardController extends HttpServlet {

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
        String role = user.getRole() != null ? user.getRole().getRoleName() : "";
        if (!"Staff".equals(role) && !"Admin".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // Load thong ke tong quan booking de hien thi tren dashboard
        BookingDAO bookingDAO = null;
        try {
            bookingDAO = new BookingDAO();
            int totalAll       = bookingDAO.countAllBookingsForStaff("All", "");
            int totalSuccess   = bookingDAO.countAllBookingsForStaff("Success", "");
            int totalPending   = bookingDAO.countAllBookingsForStaff("PendingPayment", "");
            int totalCancelled = bookingDAO.countAllBookingsForStaff("Cancelled", "");

            request.setAttribute("totalAll",       totalAll);
            request.setAttribute("totalSuccess",   totalSuccess);
            request.setAttribute("totalPending",   totalPending);
            request.setAttribute("totalCancelled", totalCancelled);

            request.getRequestDispatcher("/views/staff/dashboard.jsp").forward(request, response);
        } finally {
            if (bookingDAO != null) bookingDAO.close();
        }
    }
}
