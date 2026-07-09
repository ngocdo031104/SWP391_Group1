package Controller.admin;

import Entities.Permission;
import Entities.Role;
import Entities.User;
import Model.PermissionDAO;
import Model.RoleDAO;
import Utils.RoleInUseException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/admin/roles"})
public class RoleController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        RoleDAO roleDAO = new RoleDAO();
        PermissionDAO permissionDAO = new PermissionDAO();
        
        List<Role> roles = roleDAO.getAllRoles();
        List<Permission> allPermissions = permissionDAO.getAllPermissions();
        
        request.setAttribute("roles", roles);
        request.setAttribute("allPermissions", allPermissions);
        request.getRequestDispatcher("/admin/role-management.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User sessionUser = (User) session.getAttribute("sessionUser");
        int adminId = (sessionUser != null) ? sessionUser.getUserId() : 1; 

        String action = request.getParameter("action");
        RoleDAO roleDAO = new RoleDAO();

        try {
            if ("createRole".equals(action)) {
                String roleName = request.getParameter("roleName");
                String description = request.getParameter("description");
                Role role = new Role();
                role.setRoleName(roleName);
                role.setDescription(description);
                roleDAO.createRole(role, adminId);
                session.setAttribute("successMsg", "Tạo vai trò thành công!");
            }
            else if ("updateRole".equals(action)) {
                int roleId = Integer.parseInt(request.getParameter("roleId"));
                String roleName = request.getParameter("roleName");
                String description = request.getParameter("description");
                Role role = new Role();
                role.setRoleId(roleId);
                role.setRoleName(roleName);
                role.setDescription(description);
                roleDAO.updateRole(role, adminId);
                session.setAttribute("successMsg", "Cập nhật vai trò thành công!");
            }
            else if ("deleteRole".equals(action)) {
                int roleId = Integer.parseInt(request.getParameter("roleId"));
                roleDAO.deleteRole(roleId, adminId);
                session.setAttribute("successMsg", "Xóa vai trò thành công!");
            }
        } catch (RoleInUseException | Utils.SystemRoleException re) {
            session.setAttribute("errorMsg", re.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Đã xảy ra lỗi hệ thống: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/roles");
    }
}
