/*
 * Liên quan đến UCs: Recover Password
 * Tác giả: Đỗ Vũ Minh Ngọc
 * MSSV: HE182479
 */
package Controller;

import Entities.User;
import Model.UserDAO;
import Utils.PasswordUtil;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ResetPasswordController", urlPatterns = {"/reset-password"})
public class ResetPasswordController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String token = request.getParameter("token");
        
        if (token == null || token.trim().isEmpty()) {
            request.setAttribute("errorMessage", "ÄÆ°á»ng dáº«n khĂ´ng há»£p lá»‡.");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserByResetToken(token);
        
        if (user == null || user.getResetTokenExpiry() == null || user.getResetTokenExpiry().getTime() < System.currentTimeMillis()) {
            request.setAttribute("errorMessage", "ÄÆ°á»ng dáº«n khĂ´i phá»¥c máº­t kháº©u khĂ´ng há»£p lá»‡ hoáº·c Ä‘Ă£ háº¿t háº¡n.");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }
        
        request.setAttribute("token", token);
        request.getRequestDispatcher("/views/reset-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String token = request.getParameter("token");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        if (token == null || token.trim().isEmpty()) {
            request.setAttribute("errorMessage", "YĂªu cáº§u khĂ´ng há»£p lá»‡.");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }
        
        if (newPassword == null || newPassword.length() < 8) {
            request.setAttribute("errorMessage", "Máº­t kháº©u pháº£i dĂ i Ă­t nháº¥t 8 kĂ½ tá»±.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/views/reset-password.jsp").forward(request, response);
            return;
        }
        
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Máº­t kháº©u xĂ¡c nháº­n khĂ´ng khá»›p.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/views/reset-password.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserByResetToken(token);
        
        if (user == null || user.getResetTokenExpiry() == null || user.getResetTokenExpiry().getTime() < System.currentTimeMillis()) {
            request.setAttribute("errorMessage", "PhiĂªn khĂ´i phá»¥c Ä‘Ă£ háº¿t háº¡n. Vui lĂ²ng yĂªu cáº§u láº¡i.");
            request.getRequestDispatcher("/views/forgot-password.jsp").forward(request, response);
            return;
        }

        try {
            String newPasswordHash = PasswordUtil.hashPassword(newPassword);
            if (userDAO.resetPassword(user.getUserId(), newPasswordHash)) {
                request.setAttribute("successMessage", "Máº­t kháº©u cá»§a báº¡n Ä‘Ă£ Ä‘Æ°á»£c thay Ä‘á»•i thĂ nh cĂ´ng. Báº¡n cĂ³ thá»ƒ Ä‘Äƒng nháº­p ngay bĂ¢y giá».");
                request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", "ÄĂ£ xáº£y ra lá»—i khi Ä‘á»•i máº­t kháº©u. Vui lĂ²ng thá»­ láº¡i sau.");
                request.setAttribute("token", token);
                request.getRequestDispatcher("/views/reset-password.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "ÄĂ£ xáº£y ra lá»—i há»‡ thá»‘ng.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/views/reset-password.jsp").forward(request, response);
        }
    }
}

