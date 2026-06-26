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

@WebFilter(urlPatterns = {"/admin/roles/*", "/admin/permissions/*"})
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
        
        // Check if user has permission to manage roles
        boolean hasManageRolePerm = false;
        if (user.getRole() != null && user.getRole().getPermissions() != null) {
            for (Entities.Permission p : user.getRole().getPermissions()) {
                if ("Role Management".equals(p.getModuleName())) {
                    hasManageRolePerm = true;
                    break;
                }
            }
        }
        
        if (!hasManageRolePerm && user.getRoleId() != 1) { // Super Admin always allowed as fallback
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
