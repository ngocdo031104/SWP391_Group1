/*
 * Li\u00ean quan \u0111\u1ebfn UCs: Recover Password
 * T\u00e1c gi\u1ea3: \u0110\u1ed7 V\u0169 Minh Ng\u1ecdc
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
            request.setAttribute("errorMessage", "\u00c4\u0090\u00c6\u00b0\u00e1\u00bb\u009dng d\u1eabn kh\u00f4ng h\u1ee3p l\u1ec7.");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserByResetToken(token);
        
        if (user == null || user.getResetTokenExpiry() == null || user.getResetTokenExpiry().getTime() < System.currentTimeMillis()) {
            request.setAttribute("errorMessage", "\u00c4\u0090\u00c6\u00b0\u00e1\u00bb\u009dng d\u1eabn kh\u00f4i ph\u1ee5c m\u1eadt kh\u1ea9u kh\u00f4ng h\u1ee3p l\u1ec7 ho\u1eb7c \u0111\u00e3 h\u1ebft h\u1ea1n.");
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
            request.setAttribute("errorMessage", "Y\u00eau c\u1ea7u kh\u00f4ng h\u1ee3p l\u1ec7.");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }
        
        if (newPassword == null || newPassword.length() < 8) {
            request.setAttribute("errorMessage", "M\u1eadt kh\u1ea9u ph\u1ea3i d\u00e0i \u00edt nh\u1ea5t 8 k\u00fd t\u1ef1.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/views/reset-password.jsp").forward(request, response);
            return;
        }
        
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "M\u1eadt kh\u1ea9u x\u00e1c nh\u1eadn kh\u00f4ng kh\u1edbp.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/views/reset-password.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserByResetToken(token);
        
        if (user == null || user.getResetTokenExpiry() == null || user.getResetTokenExpiry().getTime() < System.currentTimeMillis()) {
            request.setAttribute("errorMessage", "Phi\u00ean kh\u00f4i ph\u1ee5c \u0111\u00e3 h\u1ebft h\u1ea1n. Vui l\u00f2ng y\u00eau c\u1ea7u l\u1ea1i.");
            request.getRequestDispatcher("/views/forgot-password.jsp").forward(request, response);
            return;
        }

        try {
            String newPasswordHash = PasswordUtil.hashPassword(newPassword);
            if (userDAO.resetPassword(user.getUserId(), newPasswordHash)) {
                request.setAttribute("successMessage", "M\u1eadt kh\u1ea9u c\u1ee7a b\u1ea1n \u0111\u00e3 \u0111\u01b0\u1ee3c thay \u0111\u1ed5i th\u00e0nh c\u00f4ng. B\u1ea1n c\u00f3 th\u1ec3 \u0111\u0103ng nh\u1eadp ngay b\u00e2y gi\u00e1\u00bb\u009d.");
                request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", "\u00c4\u0090\u0102\u00a3 x\u1ea3y ra l\u1ed7i khi \u0111\u1ed5i m\u1eadt kh\u1ea9u. Vui l\u00f2ng th\u1eed l\u1ea1i sau.");
                request.setAttribute("token", token);
                request.getRequestDispatcher("/views/reset-password.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "\u00c4\u0090\u0102\u00a3 x\u1ea3y ra l\u1ed7i h\u1ec7 th\u1ed1ng.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/views/reset-password.jsp").forward(request, response);
        }
    }
}

