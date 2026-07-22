/*
 * Liên quan đến UCs: Register Account
 * Tác giả: Đỗ Vũ Minh Ngọc
 * MSSV: HE182479
 */
package Controller;

import Model.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/verify")
public class VerifyController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        request.getRequestDispatcher("/views/verify.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String userOtp = request.getParameter("otp");
        
        if (session != null) {
            String verifyEmail = (String) session.getAttribute("verify_email");
            String sessionOtp = (String) session.getAttribute("verify_otp");
            
            if (verifyEmail != null && sessionOtp != null) {
                if (sessionOtp.equals(userOtp)) {
                    // Update user as verified
                    UserDAO userDAO = new UserDAO();
                    userDAO.verifyUser(verifyEmail);
                    
                    // Clear session data
                    session.removeAttribute("verify_email");
                    session.removeAttribute("verify_otp");
                    
                    request.setAttribute("successMessage", "Xác thực thành công! Vui lòng đăng nhập.");
                    request.getRequestDispatcher("/views/login.jsp").forward(request, response);
                    return;
                } else {
                    request.setAttribute("errorMessage", "Mã xác thực không đúng. Vui lòng thử lại.");
                }
            } else {
                request.setAttribute("errorMessage", "Phiên xác thực đã hết hạn. Vui lòng đăng ký lại.");
            }
        }
        
        request.getRequestDispatcher("/views/verify.jsp").forward(request, response);
    }
}

