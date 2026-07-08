package Controller.admin;

import Entities.User;
import Entities.TourAssignment;
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

@WebServlet(name = "AdminAssignmentController", urlPatterns = {"/admin/assignments"})
public class AdminAssignmentController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AdminAssignmentController.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User sessionUser = (User) request.getSession().getAttribute("sessionUser");
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        boolean hasPermission = false;
        if (sessionUser.getRoleId() == 1) {
            hasPermission = true;
        } else if (sessionUser.getRole() != null && sessionUser.getRole().getPermissions() != null) {
            for (Entities.Permission p : sessionUser.getRole().getPermissions()) {
                if (p.getPermissionId() == 32) {
                    hasPermission = true;
                    break;
                }
            }
        }

        if (!hasPermission) {
            response.sendRedirect(request.getContextPath() + "/403-forbidden.jsp");
            return;
        }

        // Đọc tham số phân trang & tìm kiếm từ request
        int page = 1;
        int size = 10;
        String pageStr = request.getParameter("page");
        String sizeStr = request.getParameter("size");
        String search = request.getParameter("search");

        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
            } catch (NumberFormatException e) {}
        }
        if (sizeStr != null && !sizeStr.trim().isEmpty()) {
            try {
                size = Integer.parseInt(sizeStr);
            } catch (NumberFormatException e) {}
        }

        GuideDAO guideDAO = new GuideDAO();
        try {
            List<TourAssignment> assignments = guideDAO.getAssignmentsPaged(page, size, search);
            int totalCount = guideDAO.getAssignmentsCount(search);
            int totalPages = (int) Math.ceil((double) totalCount / size);

            request.setAttribute("assignments", assignments);
            request.setAttribute("currentPage", page);
            request.setAttribute("pageSize", size);
            request.setAttribute("search", search != null ? search : "");
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalCount", totalCount);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading guide assignments history log", e);
        } finally {
            guideDAO.close();
        }

        request.getRequestDispatcher("/admin/assignments.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        JsonObject result = new JsonObject();
        PrintWriter out = response.getWriter();

        User sessionUser = (User) request.getSession().getAttribute("sessionUser");
        if (sessionUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            result.addProperty("status", "error");
            result.addProperty("message", "Vui lòng đăng nhập để thực hiện hành động này!");
            out.print(result.toString());
            return;
        }

        boolean hasPermission = false;
        if (sessionUser.getRoleId() == 1) {
            hasPermission = true;
        } else if (sessionUser.getRole() != null && sessionUser.getRole().getPermissions() != null) {
            for (Entities.Permission p : sessionUser.getRole().getPermissions()) {
                if (p.getPermissionId() == 32) {
                    hasPermission = true;
                    break;
                }
            }
        }

        if (!hasPermission) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            result.addProperty("status", "error");
            result.addProperty("message", "Không có quyền thực hiện hành động này!");
            out.print(result.toString());
            return;
        }

        String action = request.getParameter("action");
        String scheduleIdStr = request.getParameter("scheduleId");
        String guideIdStr = request.getParameter("guideId");

        if (!"unassign".equalsIgnoreCase(action) || scheduleIdStr == null || guideIdStr == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.addProperty("status", "error");
            result.addProperty("message", "Tham số yêu cầu không hợp lệ!");
            out.print(result.toString());
            return;
        }

        int scheduleId;
        int guideId;
        try {
            scheduleId = Integer.parseInt(scheduleIdStr);
            guideId = Integer.parseInt(guideIdStr);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.addProperty("status", "error");
            result.addProperty("message", "ID tham số không hợp lệ!");
            out.print(result.toString());
            return;
        }

        GuideDAO guideDAO = new GuideDAO();
        try {
            boolean success = guideDAO.unassignGuide(scheduleId, guideId, sessionUser.getUserId());
            if (success) {
                result.addProperty("status", "success");
                result.addProperty("message", "Hủy phân công hướng dẫn viên thành công!");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                result.addProperty("status", "error");
                result.addProperty("message", "Hủy phân công hướng dẫn viên trong CSDL thất bại.");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error unassigning guide", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.addProperty("status", "error");
            result.addProperty("message", "Đã xảy ra lỗi: " + e.getMessage());
        } finally {
            guideDAO.close();
        }

        out.print(result.toString());
    }
}
