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
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
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
                
                JsonObject stats = userDAO.getUserStats(userId, user.getRole().getRoleName());
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
            
            User currentAdmin = (User) request.getSession().getAttribute("sessionUser");
            boolean isMaster = isMasterAdmin(currentAdmin);
            
            // Self-protection: admin không được tự khóa chính mình, kể cả Master Admin.
            if (currentAdmin != null && userId == currentAdmin.getUserId()) {
                request.getSession().setAttribute("errorMsg", "Bạn không thể tự thay đổi trạng thái tài khoản của chính mình.");
                response.sendRedirect(request.getContextPath() + "/admin/users");
                return;
            }

            User targetUser = userDAO.getUserById(userId);
            if (targetUser != null && "Admin".equalsIgnoreCase(targetUser.getRole().getRoleName()) && !isMaster) {
                request.getSession().setAttribute("errorMsg", "Bạn không có quyền thao tác với tài khoản Admin khác!");
                response.sendRedirect(request.getContextPath() + "/admin/users");
                return;
            }
            
            boolean success = userDAO.updateUserStatus(userId, status);
            
            if (success) {
                String msg = "Đã " + (status ? "mở khóa" : "khóa") + " tài khoản thành công!";
                request.getSession().setAttribute("successMsg", msg);
                
                // Log action
                if (currentAdmin != null) {
                    String action = status ? "UNLOCK_USER" : "LOCK_USER";
                    String details = "Admin " + currentAdmin.getEmail() 
                                     + (status ? " unlocked" : " locked") 
                                     + " user ID: " + userId;
                    auditLogDAO.insertLog(currentAdmin.getUserId(), action, null, details);
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
            
            User currentAdmin = (User) request.getSession().getAttribute("sessionUser");
            boolean isMaster = isMasterAdmin(currentAdmin);
            
            if (userIds != null && roleIdStr != null) {
                int roleId = Integer.parseInt(roleIdStr);
                
                // Chặn Admin thường cấp quyền Admin cho người khác
                if (roleId == 1 && !isMaster) {
                    request.getSession().setAttribute("errorMsg", "Chỉ Master Admin mới có quyền cấp vai trò Admin!");
                    response.sendRedirect(request.getContextPath() + "/admin/users");
                    return;
                }
                
                int count = 0;
                int adminSkipCount = 0;
                for (String idStr : userIds) {
                    int userId = Integer.parseInt(idStr);
                    
                    User targetUser = userDAO.getUserById(userId);
                    if (targetUser != null && "Admin".equalsIgnoreCase(targetUser.getRole().getRoleName()) && !isMaster) {
                        adminSkipCount++;
                        continue;
                    }
                    
                    if (userDAO.updateUserRole(userId, roleId)) {
                        count++;
                    }
                }
                
                StringBuilder msgBuilder = new StringBuilder();
                if (count > 0) {
                    msgBuilder.append("Đã cập nhật vai trò cho ").append(count).append(" người dùng thành công! ");
                }
                if (adminSkipCount > 0) {
                    msgBuilder.append("Không thể đổi vai trò của ").append(adminSkipCount).append(" tài khoản Admin.");
                }

                if (msgBuilder.length() == 0) {
                    request.getSession().setAttribute("errorMsg", "Không có thay đổi nào được áp dụng.");
                } else if (count > 0) {
                    request.getSession().setAttribute("successMsg", msgBuilder.toString().trim());
                } else {
                    request.getSession().setAttribute("errorMsg", msgBuilder.toString().trim());
                }

                // Log action
                if (currentAdmin != null && count > 0) {
                    String details = "Admin " + currentAdmin.getEmail() + " assigned role ID: "
                                     + roleId + " to " + count + " users";
                    auditLogDAO.insertLog(currentAdmin.getUserId(), "BULK_ASSIGN_ROLE", null, details);
                }
            } else {
                request.getSession().setAttribute("errorMsg", "Dữ liệu không hợp lệ!");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "Dữ liệu không hợp lệ!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private boolean isMasterAdmin(User user) {
        return user != null && "admin.test@tourbuddy.com".equalsIgnoreCase(user.getEmail());
    }

    private void bulkDeleteUsers(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            String[] userIds = request.getParameterValues("userIds");
            if (userIds != null) {
                int successCount = 0;
                int bookingErrorCount = 0;
                int otherErrorCount = 0;
                int adminSkipCount = 0;
                
                User currentAdmin = (User) request.getSession().getAttribute("sessionUser");
                boolean isMaster = isMasterAdmin(currentAdmin);

                int selfSkipCount = 0;

                for (String idStr : userIds) {
                    int userId = Integer.parseInt(idStr);

                    // Self-protection #1: không admin nào được xóa chính mình,
                    // kể cả Master Admin — tránh khóa hệ thống vĩnh viễn.
                    if (currentAdmin != null && userId == currentAdmin.getUserId()) {
                        selfSkipCount++;
                        continue;
                    }

                    User userToDelete = userDAO.getUserById(userId);
                    if (userToDelete == null) {
                        otherErrorCount++;
                        continue;
                    }
                    boolean targetIsAdmin = "Admin".equalsIgnoreCase(userToDelete.getRole().getRoleName());
                    // Self-protection #2: chặn admin thường xóa các admin khác để tránh
                    // chỉ còn lại 1 admin duy nhất. Master Admin thì được phép.
                    if (targetIsAdmin && !isMaster) {
                        adminSkipCount++;
                        continue;
                    }

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
                
                StringBuilder errorMsgBuilder = new StringBuilder();
                if (selfSkipCount > 0) {
                    errorMsgBuilder.append("Không thể tự xóa chính tài khoản đang đăng nhập. ");
                }
                if (adminSkipCount > 0) {
                    errorMsgBuilder.append("Không thể xóa ").append(adminSkipCount).append(" tài khoản vì là Admin. ");
                }
                if (bookingErrorCount > 0) {
                    errorMsgBuilder.append("Không thể xóa ").append(bookingErrorCount).append(" tài khoản vì đang có Booking. ");
                }
                if (otherErrorCount > 0) {
                    errorMsgBuilder.append("Không thể xóa ").append(otherErrorCount).append(" tài khoản do ràng buộc dữ liệu khác.");
                }
                
                if (errorMsgBuilder.length() > 0) {
                    request.getSession().setAttribute("errorMsg", errorMsgBuilder.toString().trim());
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
            
            User currentAdmin = (User) request.getSession().getAttribute("sessionUser");
            boolean isMaster = isMasterAdmin(currentAdmin);
            
            if (userIds != null) {
                int count = 0;
                int adminSkipCount = 0;
                
                for (String idStr : userIds) {
                    int userId = Integer.parseInt(idStr);

                    // Self-protection: không admin nào được tự khóa chính mình trong bulk action.
                    if (currentAdmin != null && userId == currentAdmin.getUserId()) {
                        adminSkipCount++;
                        continue;
                    }

                    User targetUser = userDAO.getUserById(userId);
                    if (targetUser != null && "Admin".equalsIgnoreCase(targetUser.getRole().getRoleName()) && !isMaster) {
                        adminSkipCount++;
                        continue;
                    }
                    
                    if (userDAO.updateUserStatus(userId, status)) {
                        count++;
                    }
                }
                
                String actionStr = status ? "mở khóa" : "khóa";
                StringBuilder msgBuilder = new StringBuilder();
                if (count > 0) {
                    msgBuilder.append("Đã ").append(actionStr).append(" ").append(count).append(" tài khoản! ");
                }
                if (adminSkipCount > 0) {
                    msgBuilder.append("Không thể thao tác với ").append(adminSkipCount).append(" tài khoản Admin.");
                }
                
                if (count > 0 && adminSkipCount == 0) {
                    request.getSession().setAttribute("successMsg", msgBuilder.toString().trim());
                } else if (count > 0 && adminSkipCount > 0) {
                    request.getSession().setAttribute("successMsg", msgBuilder.toString().trim());
                } else if (count == 0 && adminSkipCount > 0) {
                    request.getSession().setAttribute("errorMsg", msgBuilder.toString().trim());
                }
                
                if (currentAdmin != null && count > 0) {
                    String logMsg = "Admin " + (status ? "unlocked " : "locked ") + count + " users";
                    auditLogDAO.insertLog(currentAdmin.getUserId(), status ? "BULK_UNLOCK_USER" : "BULK_LOCK_USER", null, logMsg);
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
