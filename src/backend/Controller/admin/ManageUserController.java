package Controller.admin;

import Entities.AuditLog;
import Entities.User;
import Model.AuditLogDAO;
import Model.UserDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import java.io.PrintWriter;

@WebServlet(name = "ManageUserController", urlPatterns = {"/admin/users"})
public class ManageUserController extends HttpServlet {

    private UserDAO userDAO;
    private AuditLogDAO auditLogDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        auditLogDAO = new AuditLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "view":
                viewUser(request, response);
                break;
            case "history":
                viewHistory(request, response);
                break;
            case "api_get":
                getUserApi(request, response);
                break;
            case "bulkAssignRole":
                bulkAssignRole(request, response);
                break;
            case "list":
            default:
                listUsers(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("toggleStatus".equals(action)) {
            toggleUserStatus(request, response);
        } else if ("bulkAssignRole".equals(action)) {
            bulkAssignRole(request, response);
        } else if ("bulkDeleteUsers".equals(action)) {
            bulkDeleteUsers(request, response);
        } else if ("bulkToggleStatus".equals(action)) {
            bulkToggleStatus(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/users");
        }
    }

    private void listUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<User> users = userDAO.getAllUsers();
        
        long totalUsers = users.size();
        long activeUsers = users.stream().filter(User::isIsActive).count();
        long lockedUsers = users.stream().filter(u -> !u.isIsActive()).count();
        long guideUsers = users.stream().filter(u -> "Guide".equals(u.getRole().getRoleName())).count();
        long premiumUsers = 0; // Placeholder for future feature
        
        request.setAttribute("users", users);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("activeUsers", activeUsers);
        request.setAttribute("lockedUsers", lockedUsers);
        request.setAttribute("guideUsers", guideUsers);
        request.setAttribute("premiumUsers", premiumUsers);
        
        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }

    private void viewUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("id"));
            User user = userDAO.getUserById(userId);
            if (user != null) {
                request.setAttribute("user", user);
                request.getRequestDispatcher("/admin/user-details.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/users");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
        }
    }

    private void viewHistory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<AuditLog> logs = auditLogDAO.getAllAuditLogs();
        request.setAttribute("logs", logs);
        request.getRequestDispatcher("/admin/admin-history.jsp").forward(request, response);
    }

    private void getUserApi(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();
        JsonObject result = new JsonObject();

        try {
            int userId = Integer.parseInt(request.getParameter("id"));
            User user = userDAO.getUserById(userId);
            if (user != null) {
                result.addProperty("status", "success");
                result.add("data", gson.toJsonTree(user));
                // Mock stats for UI demonstration since these fields don't exist in DB
                JsonObject stats = new JsonObject();
                stats.addProperty("trips", (int)(Math.random() * 20));
                stats.addProperty("bookings", (int)(Math.random() * 50));
                stats.addProperty("reviews", (int)(Math.random() * 15));
                stats.addProperty("companions", (int)(Math.random() * 10));
                result.add("stats", stats);
            } else {
                result.addProperty("status", "error");
                result.addProperty("message", "User not found");
            }
        } catch (NumberFormatException e) {
            result.addProperty("status", "error");
            result.addProperty("message", "Invalid ID");
        }
        out.print(gson.toJson(result));
        out.flush();
    }

    private void toggleUserStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            boolean status = Boolean.parseBoolean(request.getParameter("status"));
            
            boolean success = userDAO.updateUserStatus(userId, status);
            
            if (success) {
                String msg = "Đã " + (status ? "mở khóa" : "khóa") + " tài khoản thành công!";
                request.getSession().setAttribute("successMsg", msg);
                
                // Log action
                User admin = (User) request.getSession().getAttribute("sessionUser");
                if (admin != null) {
                    String action = status ? "UNLOCK_USER" : "LOCK_USER";
                    String details = "Admin " + admin.getEmail() 
                                     + (status ? " unlocked" : " locked") 
                                     + " user ID: " + userId;
                    auditLogDAO.insertLog(admin.getUserId(), action, null, details);
                }
            } else {
                request.getSession().setAttribute("errorMsg", "Cập nhật trạng thái thất bại!");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "Dữ liệu không hợp lệ!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private void bulkAssignRole(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            String[] userIds = request.getParameterValues("userIds");
            String roleIdStr = request.getParameter("newRoleId");
            
            if (userIds != null && roleIdStr != null) {
                int roleId = Integer.parseInt(roleIdStr);
                int count = 0;
                for (String idStr : userIds) {
                    int userId = Integer.parseInt(idStr);
                    if (userDAO.updateUserRole(userId, roleId)) {
                        count++;
                    }
                }
                String msg = "Đã cập nhật vai trò cho " + count + " người dùng thành công!";
                request.getSession().setAttribute("successMsg", msg);
                
                // Log action
                User admin = (User) request.getSession().getAttribute("sessionUser");
                if (admin != null) {
                    String details = "Admin " + admin.getEmail() + " assigned role ID: " 
                                     + roleId + " to " + count + " users";
                    auditLogDAO.insertLog(admin.getUserId(), "BULK_ASSIGN_ROLE", null, details);
                }
            } else {
                request.getSession().setAttribute("errorMsg", "Dữ liệu không hợp lệ!");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "Dữ liệu không hợp lệ!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private void bulkDeleteUsers(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            String[] userIds = request.getParameterValues("userIds");
            if (userIds != null) {
                int successCount = 0;
                int bookingErrorCount = 0;
                int otherErrorCount = 0;
                
                for (String idStr : userIds) {
                    int userId = Integer.parseInt(idStr);
                    String status = userDAO.deleteUserWithCheck(userId);
                    if ("success".equals(status)) {
                        successCount++;
                    } else if ("has_booking".equals(status)) {
                        bookingErrorCount++;
                    } else if ("fk_constraint".equals(status) || "error".equals(status)) {
                        otherErrorCount++;
                    }
                }
                
                if (successCount > 0) {
                    request.getSession().setAttribute("successMsg", "Đã xóa vĩnh viễn " + successCount + " tài khoản!");
                    User admin = (User) request.getSession().getAttribute("sessionUser");
                    if (admin != null) {
                        auditLogDAO.insertLog(admin.getUserId(), "BULK_DELETE_USER", null, "Admin deleted " + successCount + " users");
                    }
                }
                
                if (bookingErrorCount > 0) {
                    request.getSession().setAttribute("errorMsg", "Không thể xóa " + bookingErrorCount + " tài khoản vì đang có Booking!");
                } else if (otherErrorCount > 0) {
                    request.getSession().setAttribute("errorMsg", "Không thể xóa " + otherErrorCount + " tài khoản do ràng buộc dữ liệu khác!");
                }
            } else {
                request.getSession().setAttribute("errorMsg", "Dữ liệu không hợp lệ!");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "Dữ liệu không hợp lệ!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private void bulkToggleStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            String[] userIds = request.getParameterValues("userIds");
            boolean status = Boolean.parseBoolean(request.getParameter("status"));
            if (userIds != null) {
                int count = 0;
                for (String idStr : userIds) {
                    int userId = Integer.parseInt(idStr);
                    if (userDAO.updateUserStatus(userId, status)) {
                        count++;
                    }
                }
                String actionStr = status ? "mở khóa" : "khóa";
                request.getSession().setAttribute("successMsg", "Đã " + actionStr + " " + count + " tài khoản!");
                
                User admin = (User) request.getSession().getAttribute("sessionUser");
                if (admin != null) {
                    String logMsg = "Admin " + (status ? "unlocked " : "locked ") + count + " users";
                    auditLogDAO.insertLog(admin.getUserId(), status ? "BULK_UNLOCK_USER" : "BULK_LOCK_USER", null, logMsg);
                }
            } else {
                request.getSession().setAttribute("errorMsg", "Dữ liệu không hợp lệ!");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "Dữ liệu không hợp lệ!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
}
