/*
 * Liên quan đến UCs: Monitor Fraudulent Transactions
 * Tác giả: Đỗ Vũ Minh Ngọc
 * MSSV: HE182479
 */
package Controller.admin;

import Entities.FraudTransactionDTO;
import Entities.User;
import Model.AuditLogDAO;
import Model.PaymentDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/fraud-monitor")
public class FraudMonitoringController extends HttpServlet {
    private static final int PAGE_SIZE = 10;
    private PaymentDAO paymentDAO;
    private AuditLogDAO auditLogDAO;

    @Override
    public void init() throws ServletException {
        paymentDAO = new PaymentDAO();
        auditLogDAO = new AuditLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("sessionUser");
        if (user.getRoleId() != 1 && user.getRoleId() != 5) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        String dateFrom = request.getParameter("dateFrom");
        String dateTo = request.getParameter("dateTo");
        String bookingId = request.getParameter("bookingId");
        String transactionRef = request.getParameter("transactionRef");
        String gateway = request.getParameter("gateway");
        String paymentStatus = request.getParameter("paymentStatus");
        String reviewStatus = request.getParameter("reviewStatus");
        
        int page = 1;
        if (request.getParameter("page") != null) {
            try {
                page = Integer.parseInt(request.getParameter("page"));
            } catch (NumberFormatException ignored) {}
        }

        List<FraudTransactionDTO> transactions = paymentDAO.getFraudulentTransactions(dateFrom, dateTo, bookingId, transactionRef, gateway, paymentStatus, reviewStatus, page, PAGE_SIZE);
        int totalRecords = paymentDAO.getTotalFraudulentTransactions(dateFrom, dateTo, bookingId, transactionRef, gateway, paymentStatus, reviewStatus);
        int totalPages = (int) Math.ceil((double) totalRecords / PAGE_SIZE);
        
        Map<String, Object> stats = paymentDAO.getFraudulentStats();

        request.setAttribute("transactions", transactions);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("stats", stats);
        
        request.setAttribute("dateFrom", dateFrom);
        request.setAttribute("dateTo", dateTo);
        request.setAttribute("bookingId", bookingId);
        request.setAttribute("transactionRef", transactionRef);
        request.setAttribute("gateway", gateway);
        request.setAttribute("paymentStatus", paymentStatus);
        request.setAttribute("reviewStatus", reviewStatus);

        request.getRequestDispatcher("/admin/fraud-monitor.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("sessionUser");
        if (user.getRoleId() != 1 && user.getRoleId() != 5) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        String action = request.getParameter("action");
        if ("updateStatus".equals(action)) {
            try {
                int paymentId = Integer.parseInt(request.getParameter("paymentId"));
                String newStatus = request.getParameter("newStatus");
                String comment = request.getParameter("comment");
                
                String oldStatus = paymentDAO.getReviewStatus(paymentId);
                
                if (paymentDAO.updateReviewStatus(paymentId, newStatus)) {
                    String oldValues = "ReviewStatus: " + oldStatus;
                    String newValues = "ReviewStatus: " + newStatus + (comment != null && !comment.trim().isEmpty() ? " | Comment: " + comment : "");
                    auditLogDAO.createFinancialAuditLog("Payment", paymentId, "Review Fraud", oldValues, newValues, user.getUserId());
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        // Chuyển hướng về trang danh sách (GET)
        String referer = request.getHeader("Referer");
        if (referer != null) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/fraud-monitor");
        }
    }
}

