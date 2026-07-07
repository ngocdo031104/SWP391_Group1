package Controller;

import Entities.ModerationRecord;
import Entities.User;
import Model.ModerationDAO;
import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminModerationController", urlPatterns = {"/admin/moderation"})
public class AdminModerationController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AdminModerationController.class.getName());

    private boolean hasModerationPermission(User user) {
        if (user == null) return false;
        if (user.getRoleId() == 1) return true; // Super Admin bypass
        if (user.getRole() != null && user.getRole().getPermissions() != null) {
            for (Entities.Permission p : user.getRole().getPermissions()) {
                if ("Content Management".equalsIgnoreCase(p.getModuleName())) {
                    return true;
                }
            }
        }
        return false;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User sessionUser = (User) request.getSession().getAttribute("sessionUser");
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!hasModerationPermission(sessionUser)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String ajax = request.getParameter("ajax");
        ModerationDAO dao = new ModerationDAO();
        Gson gson = new Gson();

        try {
            if ("true".equalsIgnoreCase(ajax)) {
                response.setContentType("application/json;charset=UTF-8");
                String type = request.getParameter("type");

                if ("reviews".equalsIgnoreCase(type)) {
                    List<Map<String, Object>> reviews = dao.getPendingReviews();
                    try (PrintWriter out = response.getWriter()) {
                        out.print(gson.toJson(reviews));
                    }
                } else if ("posts".equalsIgnoreCase(type)) {
                    List<Map<String, Object>> posts = dao.getPendingPosts();
                    try (PrintWriter out = response.getWriter()) {
                        out.print(gson.toJson(posts));
                    }
                } else if ("comments".equalsIgnoreCase(type)) {
                    List<Map<String, Object>> comments = dao.getPendingComments();
                    try (PrintWriter out = response.getWriter()) {
                        out.print(gson.toJson(comments));
                    }
                } else if ("history".equalsIgnoreCase(type)) {
                    List<ModerationRecord> history = dao.getModerationHistory();
                    try (PrintWriter out = response.getWriter()) {
                        out.print(gson.toJson(history));
                    }
                } else {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    try (PrintWriter out = response.getWriter()) {
                        out.print("{\"status\":\"error\",\"message\":\"Loại yêu cầu không hợp lệ\"}");
                    }
                }
            } else {
                request.getRequestDispatcher("/admin/moderation.jsp").forward(request, response);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Moderation data load failure", e);
            if ("true".equalsIgnoreCase(ajax)) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.setContentType("application/json;charset=UTF-8");
                try (PrintWriter out = response.getWriter()) {
                    out.print("{\"status\":\"error\",\"message\":\"Lỗi tải dữ liệu kiểm duyệt\"}");
                }
            } else {
                throw new ServletException(e);
            }
        } finally {
            dao.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User sessionUser = (User) request.getSession().getAttribute("sessionUser");
        if (sessionUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        if (!hasModerationPermission(sessionUser)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String entityType = request.getParameter("entityType");
        String entityIdStr = request.getParameter("entityId");
        String action = request.getParameter("action");
        String reason = request.getParameter("reason");

        if (entityType == null || entityIdStr == null || action == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("application/json;charset=UTF-8");
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"status\":\"error\",\"message\":\"Thiếu tham số bắt buộc\"}");
            }
            return;
        }

        int entityId = 0;
        try {
            entityId = Integer.parseInt(entityIdStr);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("application/json;charset=UTF-8");
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"status\":\"error\",\"message\":\"EntityID không hợp lệ\"}");
            }
            return;
        }

        response.setContentType("application/json;charset=UTF-8");
        ModerationDAO dao = new ModerationDAO();

        try {
            boolean success = dao.moderateContent(entityType, entityId, action, reason, sessionUser.getUserId());
            if (success) {
                try (PrintWriter out = response.getWriter()) {
                    out.print("{\"status\":\"success\",\"message\":\"Cập nhật kiểm duyệt nội dung thành công!\"}");
                }
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                try (PrintWriter out = response.getWriter()) {
                    out.print("{\"status\":\"error\",\"message\":\"Lưu kết quả kiểm duyệt vào CSDL thất bại.\"}");
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Content moderation execution failure", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"status\":\"error\",\"message\":\"Đã xảy ra lỗi hệ thống: " + e.getMessage() + "\"}");
            }
        } finally {
            dao.close();
        }
    }
}
