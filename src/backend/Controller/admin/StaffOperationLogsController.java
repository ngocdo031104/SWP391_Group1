package Controller.admin;

import Entities.User;
import Model.TourOperationLogDAO;
import Model.TourScheduleDAO;
import Entities.TourOperationLog;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "StaffOperationLogsController", urlPatterns = {"/staff/operation-logs"})
public class StaffOperationLogsController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (!isAuthorized(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String pageStr = request.getParameter("page");
        int page = 1;
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        int pageSize = 20;
        int offset = (page - 1) * pageSize;

        TourOperationLogDAO logDAO = new TourOperationLogDAO();
        TourScheduleDAO scheduleDAO = new TourScheduleDAO();

        try {
            // Lấy danh sách tất cả logs với phân trang
            List<TourOperationLog> logs = logDAO.getAllLogsPaged(offset, pageSize);
            int totalLogs = logDAO.getTotalLogsCount();
            int totalPages = (int) Math.ceil((double) totalLogs / pageSize);

            request.setAttribute("logs", logs);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalLogs", totalLogs);

            request.getRequestDispatcher("/views/staff/operation-logs.jsp").forward(request, response);

        } finally {
            logDAO.close();
            scheduleDAO.close();
        }
    }

    private boolean isAuthorized(HttpSession session) {
        if (session == null) return false;
        User user = (User) session.getAttribute("sessionUser");
        if (user == null || user.getRole() == null) return false;
        String role = user.getRole().getRoleName();
        return "Staff".equals(role) || "Admin".equals(role);
    }
}
