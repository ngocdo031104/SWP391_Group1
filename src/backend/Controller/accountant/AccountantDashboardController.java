package Controller.accountant;
// Dương làm đoạn này:
// Tạo ngày 14/07/2026
// UC: Accountant dashboard — trang chu sau khi Accountant dang nhap.
// Hien thi tong quan: so luong giao dich, yeu cau hoan tien dang cho xu ly.

import Entities.User;
import Model.CancellationRequestDAO;
import Model.PaymentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "AccountantDashboardController", urlPatterns = {"/accountant/dashboard"})
public class AccountantDashboardController extends HttpServlet {

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
        if (!"Accountant".equals(role) && !"Admin".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        CancellationRequestDAO cancelDAO = null;
        try {
            cancelDAO = new CancellationRequestDAO();
            int pendingRefunds = cancelDAO.getRequestsByStatusForAccountant("Pending").size();
            request.setAttribute("pendingRefunds", pendingRefunds);
            request.getRequestDispatcher("/views/accountant/dashboard.jsp").forward(request, response);
        } finally {
            if (cancelDAO != null) cancelDAO.close();
        }
    }
}
