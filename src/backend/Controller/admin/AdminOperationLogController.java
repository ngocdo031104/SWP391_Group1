/*
 * Màn hình 44: Review Tour Operation Logs - Nhật ký vận hành tour (Admin)
 * Tác giả: Dương Quang Sơn
 * MSSV: HE186525
 * Ngày tạo: 2026-07-21
 */
package Controller.admin;

import Entities.TourOperationLog;
import Entities.User;
import Model.TourOperationLogDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/admin/operation-logs"})
public class AdminOperationLogController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("sessionUser");
        String roleName = user.getRole().getRoleName();
        if (!"Admin".equals(roleName) && !"Staff".equals(roleName)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String search = request.getParameter("search");
        String pageStr = request.getParameter("page");
        
        int page = 1;
        int size = 15; // Hiển thị 15 dòng mỗi trang

        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        TourOperationLogDAO logDAO = new TourOperationLogDAO();
        try {
            List<TourOperationLog> logs = logDAO.getAllLogsPaged(page, size, search);
            int totalLogs = logDAO.getLogsCount(search);
            int totalPages = (int) Math.ceil((double) totalLogs / size);

            request.setAttribute("logs", logs);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("search", search);
            
            request.getRequestDispatcher("/admin/operation-logs.jsp").forward(request, response);
        } finally {
            logDAO.close();
        }
    }
}
