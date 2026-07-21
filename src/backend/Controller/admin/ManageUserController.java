/*
 * Liên quan đến UCs: Manage User Accounts
 * Tác giả: Đỗ Vũ Minh Ngọc
 * MSSV: HE182479
 */
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
            
            // Self-protection: admin khĂ´ng Ä‘Æ°á»£c tá»± khĂ³a chĂ­nh mĂ¬nh, ká»ƒ cáº£ Master Admin.
            if (currentAdmin != null && userId == currentAdmin.getUserId()) {
                request.getSession().setAttribute("errorMsg", "Báº¡n khĂ´ng thá»ƒ tá»± thay Ä‘á»•i tráº¡ng thĂ¡i tĂ i khoáº£n cá»§a chĂ­nh mĂ¬nh.");
                response.sendRedirect(request.getContextPath() + "/admin/users");
                return;
            }

            User targetUser = userDAO.getUserById(userId);
            if (targetUser != null && "Admin".equalsIgnoreCase(targetUser.getRole().getRoleName()) && !isMaster) {
                request.getSession().setAttribute("errorMsg", "Báº¡n khĂ´ng cĂ³ quyá»n thao tĂ¡c vá»›i tĂ i khoáº£n Admin khĂ¡c!");
                response.sendRedirect(request.getContextPath() + "/admin/users");
                return;
            }
            
            boolean success = userDAO.updateUserStatus(userId, status);
            
            if (success) {
                String msg = "ÄĂ£ " + (status ? "má»Ÿ khĂ³a" : "khĂ³a") + " tĂ i khoáº£n thĂ nh cĂ´ng!";
                request.getSession().setAttribute("successMsg", msg);
                
                // Ghi nhật ký hệ thống (Audit Log)
                if (currentAdmin != null) {
                    String action = status ? "UNLOCK_USER" : "LOCK_USER";
                    String details = "Admin " + currentAdmin.getEmail() 
                                     + (status ? " unlocked" : " locked") 
                                     + " user ID: " + userId;
                    auditLogDAO.insertLog(currentAdmin.getUserId(), action, null, details);
                }
            } else {
                request.getSession().setAttribute("errorMsg", "Cáº­p nháº­t tráº¡ng thĂ¡i tháº¥t báº¡i!");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "Dá»¯ liá»‡u khĂ´ng há»£p lá»‡!");
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
                
                // Cháº·n Admin thÆ°á»ng cáº¥p quyá»n Admin cho ngÆ°á»i khĂ¡c
                if (roleId == 1 && !isMaster) {
                    request.getSession().setAttribute("errorMsg", "Chá»‰ Master Admin má»›i cĂ³ quyá»n cáº¥p vai trĂ² Admin!");
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
                    msgBuilder.append("ÄĂ£ cáº­p nháº­t vai trĂ² cho ").append(count).append(" ngÆ°á»i dĂ¹ng thĂ nh cĂ´ng! ");
                }
                if (adminSkipCount > 0) {
                    msgBuilder.append("KhĂ´ng thá»ƒ Ä‘á»•i vai trĂ² cá»§a ").append(adminSkipCount).append(" tĂ i khoáº£n Admin.");
                }

                if (msgBuilder.length() == 0) {
                    request.getSession().setAttribute("errorMsg", "KhĂ´ng cĂ³ thay Ä‘á»•i nĂ o Ä‘Æ°á»£c Ă¡p dá»¥ng.");
                } else if (count > 0) {
                    request.getSession().setAttribute("successMsg", msgBuilder.toString().trim());
                } else {
                    request.getSession().setAttribute("errorMsg", msgBuilder.toString().trim());
                }

                // Ghi nhật ký hệ thống (Audit Log)
                if (currentAdmin != null && count > 0) {
                    String details = "Admin " + currentAdmin.getEmail() + " assigned role ID: "
                                     + roleId + " to " + count + " users";
                    auditLogDAO.insertLog(currentAdmin.getUserId(), "BULK_ASSIGN_ROLE", null, details);
                }
            } else {
                request.getSession().setAttribute("errorMsg", "Dá»¯ liá»‡u khĂ´ng há»£p lá»‡!");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "Dá»¯ liá»‡u khĂ´ng há»£p lá»‡!");
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

                    // Self-protection #1: khĂ´ng admin nĂ o Ä‘Æ°á»£c xĂ³a chĂ­nh mĂ¬nh,
                    // ká»ƒ cáº£ Master Admin â€” trĂ¡nh khĂ³a há»‡ thá»‘ng vÄ©nh viá»…n.
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
                    // Self-protection #2: cháº·n admin thÆ°á»ng xĂ³a cĂ¡c admin khĂ¡c Ä‘á»ƒ trĂ¡nh
                    // chá»‰ cĂ²n láº¡i 1 admin duy nháº¥t. Master Admin thĂ¬ Ä‘Æ°á»£c phĂ©p.
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
                    request.getSession().setAttribute("successMsg", "ÄĂ£ xĂ³a vÄ©nh viá»…n " + successCount + " tĂ i khoáº£n!");
                    User admin = (User) request.getSession().getAttribute("sessionUser");
                    if (admin != null) {
                        auditLogDAO.insertLog(admin.getUserId(), "BULK_DELETE_USER", null, "Admin deleted " + successCount + " users");
                    }
                }
                
                StringBuilder errorMsgBuilder = new StringBuilder();
                if (selfSkipCount > 0) {
                    errorMsgBuilder.append("KhĂ´ng thá»ƒ tá»± xĂ³a chĂ­nh tĂ i khoáº£n Ä‘ang Ä‘Äƒng nháº­p. ");
                }
                if (adminSkipCount > 0) {
                    errorMsgBuilder.append("KhĂ´ng thá»ƒ xĂ³a ").append(adminSkipCount).append(" tĂ i khoáº£n vĂ¬ lĂ  Admin. ");
                }
                if (bookingErrorCount > 0) {
                    errorMsgBuilder.append("KhĂ´ng thá»ƒ xĂ³a ").append(bookingErrorCount).append(" tĂ i khoáº£n vĂ¬ Ä‘ang cĂ³ Booking. ");
                }
                if (otherErrorCount > 0) {
                    errorMsgBuilder.append("KhĂ´ng thá»ƒ xĂ³a ").append(otherErrorCount).append(" tĂ i khoáº£n do rĂ ng buá»™c dá»¯ liá»‡u khĂ¡c.");
                }
                
                if (errorMsgBuilder.length() > 0) {
                    request.getSession().setAttribute("errorMsg", errorMsgBuilder.toString().trim());
                }
            } else {
                request.getSession().setAttribute("errorMsg", "Dá»¯ liá»‡u khĂ´ng há»£p lá»‡!");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "Dá»¯ liá»‡u khĂ´ng há»£p lá»‡!");
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

                    // Self-protection: khĂ´ng admin nĂ o Ä‘Æ°á»£c tá»± khĂ³a chĂ­nh mĂ¬nh trong bulk action.
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
                
                String actionStr = status ? "má»Ÿ khĂ³a" : "khĂ³a";
                StringBuilder msgBuilder = new StringBuilder();
                if (count > 0) {
                    msgBuilder.append("ÄĂ£ ").append(actionStr).append(" ").append(count).append(" tĂ i khoáº£n! ");
                }
                if (adminSkipCount > 0) {
                    msgBuilder.append("KhĂ´ng thá»ƒ thao tĂ¡c vá»›i ").append(adminSkipCount).append(" tĂ i khoáº£n Admin.");
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
                request.getSession().setAttribute("errorMsg", "Dá»¯ liá»‡u khĂ´ng há»£p lá»‡!");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "Dá»¯ liá»‡u khĂ´ng há»£p lá»‡!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
}

