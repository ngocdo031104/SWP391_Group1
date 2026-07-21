package Controller.accountant;

// Dương làm đoạn này
// Thời gian tạo: 14/07/2026

import Entities.Payment;
import Entities.User;
import Model.PaymentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AccountantPaymentController", urlPatterns = {"/accountant/payments"})
public class AccountantPaymentController extends HttpServlet {

    private static final int PAGE_SIZE = 20;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (!isAuthorized(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String tab      = request.getParameter("tab"); // 'in' or 'out'
        String dateFrom = request.getParameter("dateFrom");
        String dateTo   = request.getParameter("dateTo");
        String keyword  = request.getParameter("keyword");
        String pageStr  = request.getParameter("page");

        if (tab == null || tab.isEmpty()) tab = "in"; // default to In
        String statusFilter = "in".equals(tab) ? "Success" : "Refunded";

        int page = 1;
        try {
            if (pageStr != null) page = Integer.parseInt(pageStr);
            if (page < 1) page = 1;
        } catch (NumberFormatException ignored) {}

        int offset = (page - 1) * PAGE_SIZE;

        PaymentDAO paymentDAO = null;
        try {
            paymentDAO = new PaymentDAO();
            
            // Lấy danh sách giao dịch theo tab
            List<Payment> payments = paymentDAO.getPaymentsByStatusForAccountant(statusFilter, dateFrom, dateTo, keyword, offset, PAGE_SIZE);
            int totalRecords = paymentDAO.countPaymentsByStatus(statusFilter, dateFrom, dateTo, keyword);
            int totalPages = (int) Math.ceil((double) totalRecords / PAGE_SIZE);

            // Tính tổng tiền (cho thẻ thống kê)
            double totalIn = paymentDAO.sumPaymentsByStatus("Success", dateFrom, dateTo);
            double totalOut = paymentDAO.sumPaymentsByStatus("Refunded", dateFrom, dateTo);
            double netRevenue = totalIn - totalOut;

            request.setAttribute("payments", payments);
            request.setAttribute("totalRecords", totalRecords);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            
            request.setAttribute("totalIn", totalIn);
            request.setAttribute("totalOut", totalOut);
            request.setAttribute("netRevenue", netRevenue);
            
            request.setAttribute("activeTab", tab);
            request.setAttribute("dateFrom", dateFrom != null ? dateFrom : "");
            request.setAttribute("dateTo", dateTo != null ? dateTo : "");
            request.setAttribute("keyword", keyword != null ? keyword : "");

            request.getRequestDispatcher("/views/accountant/payment-list.jsp").forward(request, response);
        } finally {
            if (paymentDAO != null) paymentDAO.close();
        }
    }

    private boolean isAuthorized(HttpSession session) {
        if (session == null) return false;
        User user = (User) session.getAttribute("sessionUser");
        if (user == null || user.getRole() == null) return false;
        String role = user.getRole().getRoleName();
        return "Accountant".equals(role) || "Admin".equals(role);
    }
}
