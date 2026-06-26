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
        request.getRequestDispatcher("/views/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Vui lòng nhập địa chỉ email.");
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
                    request.setAttribute("errorMessage", "Không thể gửi email khôi phục. Vui lòng thử lại sau.");
                    request.getRequestDispatcher("/views/forgot-password.jsp").forward(request, response);
                    return;
                }
            } else {
                request.setAttribute("errorMessage", "Lỗi hệ thống khi tạo yêu cầu khôi phục.");
                request.getRequestDispatcher("/views/forgot-password.jsp").forward(request, response);
                return;
            }
        }
        
        // Always show success message to prevent email enumeration
        request.setAttribute("successMessage", "Nếu email tồn tại trong hệ thống, chúng tôi đã gửi hướng dẫn khôi phục mật khẩu. Vui lòng kiểm tra hộp thư của bạn.");
        request.getRequestDispatcher("/views/forgot-password.jsp").forward(request, response);
    }
}
