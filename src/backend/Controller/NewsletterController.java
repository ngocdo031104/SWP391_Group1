package Controller;

import Model.NewsletterDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "NewsletterController", urlPatterns = {"/newsletter/subscribe"})
public class NewsletterController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        String email = request.getParameter("email");
        
        boolean success = false;
        String message = "Email không hợp lệ.";
        
        if (email != null && !email.trim().isEmpty()) {
            NewsletterDAO dao = new NewsletterDAO();
            success = dao.subscribe(email.trim().toLowerCase());
            dao.close();
            
            if (success) {
                message = "Đăng ký nhận tin khuyến mãi thành công!";
            } else {
                message = "Email này đã được đăng ký từ trước hoặc có lỗi hệ thống xảy ra.";
            }
        }
        
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"status\":\"" + (success ? "success" : "error") + "\",\"message\":\"" + message + "\"}");
        }
    }
}
