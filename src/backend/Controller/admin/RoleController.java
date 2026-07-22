/*
 * Li\u00ean quan \u0111\u1ebfn UCs: Manage Roles and Permissions
 * T\u00e1c gi\u1ea3: \u0110\u1ed7 V\u0169 Minh Ng\u1ecdc
 * MSSV: HE182479
 */
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
                session.setAttribute("successMsg", "T\u1ea1o vai tr\u00f2 th\u00e0nh c\u00f4ng!");
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
                session.setAttribute("successMsg", "C\u1eadp nh\u1eadt vai tr\u00f2 th\u00e0nh c\u00f4ng!");
            }
            else if ("deleteRole".equals(action)) {
                int roleId = Integer.parseInt(request.getParameter("roleId"));
                roleDAO.deleteRole(roleId, adminId);
                session.setAttribute("successMsg", "X\u00f3a vai tr\u00f2 th\u00e0nh c\u00f4ng!");
            }
        } catch (RoleInUseException | Utils.SystemRoleException re) {
            session.setAttribute("errorMsg", re.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "\u00c4\u0090\u0102\u00a3 x\u1ea3y ra l\u1ed7i h\u1ec7 th\u1ed1ng: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/roles");
    }
}

