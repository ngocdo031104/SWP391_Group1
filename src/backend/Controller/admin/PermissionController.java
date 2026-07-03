package Controller.admin;

import Entities.User;
import Model.RoleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(urlPatterns = {"/admin/permissions/update"})
public class PermissionController extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("sessionUser") : null;
        int adminId = (sessionUser != null) ? sessionUser.getUserId() : 1;
        
        try {
            int roleId = Integer.parseInt(request.getParameter("roleId"));
            String[] permissionIds = request.getParameterValues("permissions[]");
            if (permissionIds == null) {
                // If no permissions selected, array might be null, so we pass empty array to clear all
                permissionIds = new String[0];
            }
            
            RoleDAO roleDAO = new RoleDAO();
            roleDAO.updateRolePermissions(roleId, permissionIds, adminId);
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": true, \"message\": \"Cập nhật quyền thành công!\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }
}
