/*
 * Liên quan đến UCs: Review Financial Audit Logs
 * Tác giả: Đỗ Vũ Minh Ngọc
 * MSSV: HE182479
 */
package Controller.admin;

import Entities.FinancialAuditDTO;
import Entities.User;
import Model.AuditLogDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "FinancialAuditController", urlPatterns = {"/admin/financial-audit"})
public class FinancialAuditController extends HttpServlet {
    private static final int PAGE_SIZE = 20;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("sessionUser");
        // Ch\u1ec9 c\u00f3 Admin v\u00e0 K\u1ebf to\u00e1n \u0111\u01b0\u1ee3c truy c\u1eadp trang n\u00e0y
        if (user.getRoleId() != 1 && user.getRoleId() != 5) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: You do not have permission to view this page.");
            return;
        }

        String dateFrom = request.getParameter("dateFrom");
        String dateTo = request.getParameter("dateTo");
        String operator = request.getParameter("operator");
        String status = request.getParameter("status");
        String transactionRef = request.getParameter("transactionRef");
        String discrepancy = request.getParameter("discrepancy");
        
        int page = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        AuditLogDAO auditLogDAO = new AuditLogDAO();
        List<FinancialAuditDTO> logs = auditLogDAO.getFinancialAuditLogs(dateFrom, dateTo, operator, status, transactionRef, discrepancy, page, PAGE_SIZE);
        int totalRecords = auditLogDAO.getTotalFinancialAuditLogs(dateFrom, dateTo, operator, status, transactionRef, discrepancy);
        int totalPages = (int) Math.ceil((double) totalRecords / PAGE_SIZE);
        
        java.util.Map<String, Object> stats = auditLogDAO.getFinancialAuditStats(dateFrom, dateTo, operator, status, transactionRef, discrepancy);

        request.setAttribute("logs", logs);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("stats", stats);
        
        // Gi\u1eef l\u1ea1i c\u00e1c tham s\u1ed1 t\u00ecm ki\u1ebfm (Filter)
        request.setAttribute("dateFrom", dateFrom);
        request.setAttribute("dateTo", dateTo);
        request.setAttribute("operator", operator);
        request.setAttribute("status", status);
        request.setAttribute("transactionRef", transactionRef);
        request.setAttribute("discrepancy", discrepancy);
        
        request.setAttribute("activePage", "financial-audit");

        request.getRequestDispatcher("/admin/financial-audit.jsp").forward(request, response);
    }
}

