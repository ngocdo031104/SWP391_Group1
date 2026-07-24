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
            
            // Self-protection: admin kh\u00f4ng \u0111\u01b0\u1ee3c t\u1ef1 kh\u00f3a ch\u00ednh m\u00ecnh, k\u1ec3 c\u1ea3 Master Admin.
            if (currentAdmin != null && userId == currentAdmin.getUserId()) {
                request.getSession().setAttribute("errorMsg", "B\u1ea1n kh\u00f4ng th\u1ec3 t\u1ef1 thay \u0111\u1ed5i tr\u1ea1ng th\u00e1i t\u00e0i kho\u1ea3n c\u1ee7a ch\u00ednh m\u00ecnh.");
                response.sendRedirect(request.getContextPath() + "/admin/users");
                return;
            }

            User targetUser = userDAO.getUserById(userId);
            if (targetUser != null && "Admin".equalsIgnoreCase(targetUser.getRole().getRoleName()) && !isMaster) {
                request.getSession().setAttribute("errorMsg", "B\u1ea1n kh\u00f4ng c\u00f3 quy\u1ec1n thao t\u00e1c v\u1edbi t\u00e0i kho\u1ea3n Admin kh\u00e1c!");
                response.sendRedirect(request.getContextPath() + "/admin/users");
                return;
            }
            
            boolean success = userDAO.updateUserStatus(userId, status);
            
            if (success) {
                String msg = "\u0110\u00e3 " + (status ? "m\u1edf kh\u00f3a" : "kh\u00f3a") + " t\u00e0i kho\u1ea3n th\u00e0nh c\u00f4ng!";
                request.getSession().setAttribute("successMsg", msg);
                
                // Ghi nh\u1eadt k\u00fd h\u1ec7 th\u1ed1ng (Audit Log)
                if (currentAdmin != null) {
                    String action = status ? "UNLOCK_USER" : "LOCK_USER";
                    String details = "Admin " + currentAdmin.getEmail() 
                                     + (status ? " unlocked" : " locked") 
                                     + " user ID: " + userId;
                    auditLogDAO.insertLog(currentAdmin.getUserId(), action, null, details);
                }
            } else {
                request.getSession().setAttribute("errorMsg", "C\u1eadp nh\u1eadt tr\u1ea1ng th\u00e1i th\u1ea5t b\u1ea1i!");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "D\u1eef li\u1ec7u kh\u00f4ng h\u1ee3p l\u1ec7!");
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
                
                // Ch\u1eb7n Admin th\u01b0\u1eddng c\u1ea5p quy\u1ec1n Admin cho ng\u01b0\u1eddi kh\u00e1c
                if (roleId == 1 && !isMaster) {
                    request.getSession().setAttribute("errorMsg", "Ch\u1ec9 Master Admin m\u1edbi c\u00f3 quy\u1ec1n c\u1ea5p vai tr\u00f2 Admin!");
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
                    msgBuilder.append("\u0110\u00e3 c\u1eadp nh\u1eadt vai tr\u00f2 cho ").append(count).append(" ng\u01b0\u1eddi d\u00f9ng th\u00e0nh c\u00f4ng! ");
                }
                if (adminSkipCount > 0) {
                    msgBuilder.append("Kh\u00f4ng th\u1ec3 \u0111\u1ed5i vai tr\u00f2 c\u1ee7a ").append(adminSkipCount).append(" t\u00e0i kho\u1ea3n Admin.");
                }

                if (msgBuilder.length() == 0) {
                    request.getSession().setAttribute("errorMsg", "Kh\u00f4ng c\u00f3 thay \u0111\u1ed5i n\u00e0o \u0111\u01b0\u1ee3c \u00e1p d\u1ee5ng.");
                } else if (count > 0) {
                    request.getSession().setAttribute("successMsg", msgBuilder.toString().trim());
                } else {
                    request.getSession().setAttribute("errorMsg", msgBuilder.toString().trim());
                }

                // Ghi nh\u1eadt k\u00fd h\u1ec7 th\u1ed1ng (Audit Log)
                if (currentAdmin != null && count > 0) {
                    String details = "Admin " + currentAdmin.getEmail() + " assigned role ID: "
                                     + roleId + " to " + count + " users";
                    auditLogDAO.insertLog(currentAdmin.getUserId(), "BULK_ASSIGN_ROLE", null, details);
                }
            } else {
                request.getSession().setAttribute("errorMsg", "D\u1eef li\u1ec7u kh\u00f4ng h\u1ee3p l\u1ec7!");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "D\u1eef li\u1ec7u kh\u00f4ng h\u1ee3p l\u1ec7!");
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

                    // Self-protection #1: kh\u00f4ng admin n\u00e0o \u0111\u01b0\u1ee3c x\u00f3a ch\u00ednh m\u00ecnh,
                    // k\u1ec3 c\u1ea3 Master Admin \u2014 tr\u00e1nh kh\u00f3a h\u1ec7 th\u1ed1ng v\u0129nh vi\u1ec5n.
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
                    // Self-protection #2: ch\u1eb7n admin th\u01b0\u1eddng x\u00f3a c\u00e1c admin kh\u00e1c \u0111\u1ec3 tr\u00e1nh
                    // ch\u1ec9 c\u00f2n l\u1ea1i 1 admin duy nh\u1ea5t. Master Admin th\u00ec \u0111\u01b0\u1ee3c ph\u00e9p.
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
                    request.getSession().setAttribute("successMsg", "\u0110\u00e3 x\u00f3a v\u0129nh vi\u1ec5n " + successCount + " t\u00e0i kho\u1ea3n!");
                    User admin = (User) request.getSession().getAttribute("sessionUser");
                    if (admin != null) {
                        auditLogDAO.insertLog(admin.getUserId(), "BULK_DELETE_USER", null, "Admin deleted " + successCount + " users");
                    }
                }
                
                StringBuilder errorMsgBuilder = new StringBuilder();
                if (selfSkipCount > 0) {
                    errorMsgBuilder.append("Kh\u00f4ng th\u1ec3 t\u1ef1 x\u00f3a ch\u00ednh t\u00e0i kho\u1ea3n \u0111ang \u0111\u0103ng nh\u1eadp. ");
                }
                if (adminSkipCount > 0) {
                    errorMsgBuilder.append("Kh\u00f4ng th\u1ec3 x\u00f3a ").append(adminSkipCount).append(" t\u00e0i kho\u1ea3n v\u00ec l\u00e0 Admin. ");
                }
                if (bookingErrorCount > 0) {
                    errorMsgBuilder.append("Kh\u00f4ng th\u1ec3 x\u00f3a ").append(bookingErrorCount).append(" t\u00e0i kho\u1ea3n v\u00ec \u0111ang c\u00f3 Booking. ");
                }
                if (otherErrorCount > 0) {
                    errorMsgBuilder.append("Kh\u00f4ng th\u1ec3 x\u00f3a ").append(otherErrorCount).append(" t\u00e0i kho\u1ea3n do r\u00e0ng bu\u1ed9c d\u1eef li\u1ec7u kh\u00e1c.");
                }
                
                if (errorMsgBuilder.length() > 0) {
                    request.getSession().setAttribute("errorMsg", errorMsgBuilder.toString().trim());
                }
            } else {
                request.getSession().setAttribute("errorMsg", "D\u1eef li\u1ec7u kh\u00f4ng h\u1ee3p l\u1ec7!");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "D\u1eef li\u1ec7u kh\u00f4ng h\u1ee3p l\u1ec7!");
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

                    // Self-protection: kh\u00f4ng admin n\u00e0o \u0111\u01b0\u1ee3c t\u1ef1 kh\u00f3a ch\u00ednh m\u00ecnh trong bulk action.
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
                
                String actionStr = status ? "m\u1edf kh\u00f3a" : "kh\u00f3a";
                StringBuilder msgBuilder = new StringBuilder();
                if (count > 0) {
                    msgBuilder.append("\u0110\u00e3 ").append(actionStr).append(" ").append(count).append(" t\u00e0i kho\u1ea3n! ");
                }
                if (adminSkipCount > 0) {
                    msgBuilder.append("Kh\u00f4ng th\u1ec3 thao t\u00e1c v\u1edbi ").append(adminSkipCount).append(" t\u00e0i kho\u1ea3n Admin.");
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
                request.getSession().setAttribute("errorMsg", "D\u1eef li\u1ec7u kh\u00f4ng h\u1ee3p l\u1ec7!");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "D\u1eef li\u1ec7u kh\u00f4ng h\u1ee3p l\u1ec7!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
}

