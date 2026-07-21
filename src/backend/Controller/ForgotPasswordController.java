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
            request.setAttribute("errorMessage", "Vui lĂ²ng nháº­p Ä‘á»‹a chá»‰ email.");
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
                    request.setAttribute("errorMessage", "KhĂ´ng thá»ƒ gá»­i email khĂ´i phá»¥c. Vui lĂ²ng thá»­ láº¡i sau.");
                    request.getRequestDispatcher("/views/forgot-password.jsp").forward(request, response);
                    return;
                }
            } else {
                request.setAttribute("errorMessage", "Lá»—i há»‡ thá»‘ng khi táº¡o yĂªu cáº§u khĂ´i phá»¥c.");
                request.getRequestDispatcher("/views/forgot-password.jsp").forward(request, response);
                return;
            }
        }
        
        // Always show success message to prevent email enumeration
        request.setAttribute("successMessage", "Náº¿u email tá»“n táº¡i trong há»‡ thá»‘ng, chĂºng tĂ´i Ä‘Ă£ gá»­i hÆ°á»›ng dáº«n khĂ´i phá»¥c máº­t kháº©u. Vui lĂ²ng kiá»ƒm tra há»™p thÆ° cá»§a báº¡n.");
        request.getRequestDispatcher("/views/forgot-password.jsp").forward(request, response);
    }
}

