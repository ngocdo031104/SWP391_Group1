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
                // Xóa tất cả quyền nếu danh sách bị rỗng
                permissionIds = new String[0];
            }
            
            RoleDAO roleDAO = new RoleDAO();
            roleDAO.updateRolePermissions(roleId, permissionIds, adminId);
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": true, \"message\": \"Cáº­p nháº­t quyá»n thĂ nh cĂ´ng!\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }
}

