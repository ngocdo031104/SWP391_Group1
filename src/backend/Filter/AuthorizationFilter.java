package Filter;

import Entities.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(urlPatterns = {
    "/admin/roles/*", 
    "/admin/permissions/*", 
    "/admin/moderation", 
    "/admin/analytics", 
    "/admin/forecast",
    "/admin/assignments",
    "/admin/operation-logs"
})
public class AuthorizationFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
            
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        boolean isAuthenticated = (session != null && session.getAttribute("sessionUser") != null);
        
        if (!isAuthenticated) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("sessionUser");
        String uri = req.getRequestURI();
        
        boolean hasPermission = false;
        String requiredModule = "";
        
        if (uri.contains("/admin/roles") || uri.contains("/admin/permissions")) {
            requiredModule = "Role Management";
        } else if (uri.contains("/admin/moderation")) {
            requiredModule = "Content Management";
        } else if (uri.contains("/admin/assignments")) {
            if (user.getRole() != null && user.getRole().getPermissions() != null) {
                for (Entities.Permission p : user.getRole().getPermissions()) {
                    if (p.getPermissionId() == 32) {
                        hasPermission = true;
                        break;
                    }
                }
            }
        } else if (uri.contains("/admin/analytics")) {
            requiredModule = "System Settings";
        } else if (uri.contains("/admin/forecast")) {
            requiredModule = "Perform Predictive Analytics";
        }
        
        if (user.getRoleId() == 1) { // Super Admin bypass
            hasPermission = true;
        } else if (!requiredModule.isEmpty() && user.getRole() != null && user.getRole().getPermissions() != null) {
            for (Entities.Permission p : user.getRole().getPermissions()) {
                if (requiredModule.equalsIgnoreCase(p.getModuleName()) 
                    || requiredModule.equalsIgnoreCase(p.getAction())
                    || (requiredModule.equals("Perform Predictive Analytics") && p.getPermissionId() == 39)) {
                    hasPermission = true;
                    break;
                }
            }
        }
        
        // Thống kê hỗ trợ thêm action Export
        if (!hasPermission && "System Settings".equals(requiredModule) && user.getRole() != null && user.getRole().getPermissions() != null) {
            for (Entities.Permission p : user.getRole().getPermissions()) {
                if ("System Settings".equalsIgnoreCase(p.getModuleName()) && "Export".equalsIgnoreCase(p.getAction())) {
                    hasPermission = true;
                    break;
                }
            }
        }

        if (!hasPermission) {
            res.sendRedirect(req.getContextPath() + "/403-forbidden.jsp");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void destroy() {}
}
