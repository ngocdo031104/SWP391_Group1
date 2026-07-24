/*
 * Liên quan đến UCs: Recover Password
 * Tác giả: Đỗ Vũ Minh Ngọc
 * MSSV: HE182479
 */
package Controller;

import Model.UserDAO;
import Utils.EmailUtil;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ForgotPasswordController", urlPatterns = {"/forgot-password"})
public class ForgotPasswordController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        request.getRequestDispatcher("/views/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Vui l\u00f2ng nh\u1eadp \u0111\u1ecba ch\u1ec9 email.");
            request.getRequestDispatcher("/views/forgot-password.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();
        boolean exists = userDAO.checkEmailExists(email);

        if (exists) {
            String token = UUID.randomUUID().toString();
            // Token valid for 15 minutes
            long expiryTimeMs = System.currentTimeMillis() + (15 * 60 * 1000);
            Timestamp expiry = new Timestamp(expiryTimeMs);
            
            if (userDAO.setResetToken(email, token, expiry)) {
                String resetLink = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/reset-password?token=" + token;
                try {
                    EmailUtil.sendPasswordRecoveryEmail(email, resetLink);
                } catch (Exception e) {
                    e.printStackTrace();
                    request.setAttribute("errorMessage", "Kh\u00f4ng th\u1ec3 g\u1eedi email kh\u00f4i ph\u1ee5c. Vui l\u00f2ng th\u1eed l\u1ea1i sau.");
                    request.getRequestDispatcher("/views/forgot-password.jsp").forward(request, response);
                    return;
                }
            } else {
                request.setAttribute("errorMessage", "L\u1ed7i h\u1ec7 th\u1ed1ng khi t\u1ea1o y\u00eau c\u1ea7u kh\u00f4i ph\u1ee5c.");
                request.getRequestDispatcher("/views/forgot-password.jsp").forward(request, response);
                return;
            }
        }
        
        // Always show success message to prevent email enumeration
        request.setAttribute("successMessage", "N\u1ebfu email t\u1ed3n t\u1ea1i trong h\u1ec7 th\u1ed1ng, ch\u00fang t\u00f4i \u0111\u00e3 g\u1eedi h\u01b0\u1edbng d\u1eabn kh\u00f4i ph\u1ee5c m\u1eadt kh\u1ea9u. Vui l\u00f2ng ki\u1ec3m tra h\u1ed9p th\u01b0 c\u1ee7a b\u1ea1n.");
        request.getRequestDispatcher("/views/forgot-password.jsp").forward(request, response);
    }
}

