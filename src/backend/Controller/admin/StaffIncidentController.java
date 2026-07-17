package Controller.admin;

import Entities.User;
import Entities.IncidentReport;
import Model.IncidentReportDAO;
import Model.TourScheduleDAO;
import Model.GuideDAO;
import com.google.gson.JsonObject;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "StaffIncidentController", urlPatterns = {"/staff/incidents"})
public class StaffIncidentController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(StaffIncidentController.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (!isAuthorized(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String statusFilter = request.getParameter("status");
        if (statusFilter == null || statusFilter.isEmpty()) {
            statusFilter = "All";
        }

        IncidentReportDAO incidentDAO = new IncidentReportDAO();
        try {
            List<IncidentReport> incidents = incidentDAO.getAllIncidentsWithDetails(statusFilter);
            request.setAttribute("incidents", incidents);
            request.setAttribute("statusFilter", statusFilter);

            // Đếm số lượng theo status
            int openCount = incidentDAO.countIncidentsByStatus("Open");
            int investigatingCount = incidentDAO.countIncidentsByStatus("Investigating");
            int resolvedCount = incidentDAO.countIncidentsByStatus("Resolved");
            request.setAttribute("openCount", openCount);
            request.setAttribute("investigatingCount", investigatingCount);
            request.setAttribute("resolvedCount", resolvedCount);

            request.getRequestDispatcher("/views/staff/incident-management.jsp").forward(request, response);
        } finally {
            incidentDAO.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        JsonObject result = new JsonObject();
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (!isAuthorized(session)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            result.addProperty("status", "error");
            result.addProperty("message", "Vui lòng đăng nhập!");
            out.print(result.toString());
            return;
        }

        User currentUser = (User) session.getAttribute("sessionUser");
        String action = request.getParameter("action");

        if ("updateStatus".equals(action)) {
            String incidentIdStr = request.getParameter("incidentId");
            String newStatus = request.getParameter("status");

            if (incidentIdStr == null || newStatus == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result.addProperty("status", "error");
                result.addProperty("message", "Thiếu thông tin!");
                out.print(result.toString());
                return;
            }

            try {
                int incidentId = Integer.parseInt(incidentIdStr);
                IncidentReportDAO incidentDAO = new IncidentReportDAO();
                try {
                    boolean validStatus = "Open".equals(newStatus) || "Investigating".equals(newStatus)
                            || "Resolved".equals(newStatus) || "Dismissed".equals(newStatus);
                    if (!validStatus) {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        result.addProperty("status", "error");
                        result.addProperty("message", "Trạng thái không hợp lệ!");
                        out.print(result.toString());
                        return;
                    }

                    boolean success = incidentDAO.updateIncidentStatus(incidentId, newStatus, currentUser.getUserId());
                    if (success) {
                        result.addProperty("status", "success");
                        result.addProperty("message", "Cập nhật trạng thái thành công!");
                    } else {
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        result.addProperty("status", "error");
                        result.addProperty("message", "Cập nhật thất bại!");
                    }
                } finally {
                    incidentDAO.close();
                }
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result.addProperty("status", "error");
                result.addProperty("message", "ID không hợp lệ!");
            }
            out.print(result.toString());
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.addProperty("status", "error");
            result.addProperty("message", "Hành động không hợp lệ!");
            out.print(result.toString());
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
