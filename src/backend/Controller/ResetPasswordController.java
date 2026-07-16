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
            request.setAttribute("errorMessage", "Đường dẫn không hợp lệ.");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserByResetToken(token);
        
        if (user == null || user.getResetTokenExpiry() == null || user.getResetTokenExpiry().getTime() < System.currentTimeMillis()) {
            request.setAttribute("errorMessage", "Đường dẫn khôi phục mật khẩu không hợp lệ hoặc đã hết hạn.");
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
            request.setAttribute("errorMessage", "Yêu cầu không hợp lệ.");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }
        
        if (newPassword == null || newPassword.length() < 8) {
            request.setAttribute("errorMessage", "Mật khẩu phải dài ít nhất 8 ký tự.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/views/reset-password.jsp").forward(request, response);
            return;
        }
        
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Mật khẩu xác nhận không khớp.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/views/reset-password.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserByResetToken(token);
        
        if (user == null || user.getResetTokenExpiry() == null || user.getResetTokenExpiry().getTime() < System.currentTimeMillis()) {
            request.setAttribute("errorMessage", "Phiên khôi phục đã hết hạn. Vui lòng yêu cầu lại.");
            request.getRequestDispatcher("/views/forgot-password.jsp").forward(request, response);
            return;
        }

        try {
            String newPasswordHash = PasswordUtil.hashPassword(newPassword);
            if (userDAO.resetPassword(user.getUserId(), newPasswordHash)) {
                request.setAttribute("successMessage", "Mật khẩu của bạn đã được thay đổi thành công. Bạn có thể đăng nhập ngay bây giờ.");
                request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", "Đã xảy ra lỗi khi đổi mật khẩu. Vui lòng thử lại sau.");
                request.setAttribute("token", token);
                request.getRequestDispatcher("/views/reset-password.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/views/reset-password.jsp").forward(request, response);
        }
    }
}
