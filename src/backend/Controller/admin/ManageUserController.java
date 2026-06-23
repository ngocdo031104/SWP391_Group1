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
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/users");
        }
    }

    private void listUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<User> users = userDAO.getAllUsers();
        request.setAttribute("users", users);
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

    private void toggleUserStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            boolean newStatus = Boolean.parseBoolean(request.getParameter("status"));
            
            // Perform the update
            boolean success = userDAO.updateUserStatus(userId, newStatus);
            
            if (success) {
                // Log the action
                HttpSession session = request.getSession(false);
                int adminId = -1; // Fallback
                if (session != null && session.getAttribute("sessionUser") != null) {
                    User adminUser = (User) session.getAttribute("sessionUser");
                    adminId = adminUser.getUserId();
                }
                
                String actionType = newStatus ? "USER_UNLOCKED" : "USER_LOCKED";
                String details = (newStatus ? "Unlocked" : "Locked") + " user account ID: " + userId;
                
                auditLogDAO.insertLog(adminId, actionType, null, details);
                
                request.getSession().setAttribute("successMsg", "User status updated successfully.");
            } else {
                request.getSession().setAttribute("errorMsg", "Failed to update user status.");
            }
            
        } catch (Exception e) {
            request.getSession().setAttribute("errorMsg", "Invalid request parameters.");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
}
