/*
 * Liên quan đến UCs: Manage Roles and Permissions
 * Tác giả: Đỗ Vũ Minh Ngọc
 * MSSV: HE182479
 */
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
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("sessionUser") : null;
        int adminId = (sessionUser != null) ? sessionUser.getUserId() : 1;
        
        try {
            int roleId = Integer.parseInt(request.getParameter("roleId"));
            String[] permissionIds = request.getParameterValues("permissions[]");
            if (permissionIds == null) {
                // X\u00f3a t\u1ea5t c\u1ea3 quy\u1ec1n n\u1ebfu danh s\u00e1ch b\u1ecb r\u1ed7ng
                permissionIds = new String[0];
            }
            
            RoleDAO roleDAO = new RoleDAO();
            roleDAO.updateRolePermissions(roleId, permissionIds, adminId);
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": true, \"message\": \"C\u1eadp nh\u1eadt quy\u00e1\u00bb\u0081n th\u00e0nh c\u00f4ng!\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }
}

