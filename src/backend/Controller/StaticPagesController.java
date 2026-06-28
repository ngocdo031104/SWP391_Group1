package Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "StaticPagesController", urlPatterns = {
    "/help", 
    "/guide-booking", 
    "/policy/cancel", 
    "/terms", 
    "/privacy",
    "/contact"
})
public class StaticPagesController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        
        if ("/help".equals(path)) {
            request.getRequestDispatcher("/views/static/help.jsp").forward(request, response);
        } else if ("/guide-booking".equals(path)) {
            request.getRequestDispatcher("/views/static/guide-booking.jsp").forward(request, response);
        } else if ("/policy/cancel".equals(path)) {
            request.getRequestDispatcher("/views/static/policy-cancel.jsp").forward(request, response);
        } else if ("/terms".equals(path)) {
            request.getRequestDispatcher("/views/static/terms.jsp").forward(request, response);
        } else if ("/privacy".equals(path)) {
            request.getRequestDispatcher("/views/static/privacy.jsp").forward(request, response);
        } else if ("/contact".equals(path)) {
            // Chặn truy cập nếu chưa đăng nhập để tránh spam
            if (request.getSession().getAttribute("sessionUser") == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            request.getRequestDispatcher("/views/static/contact.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/contact".equals(path)) {
            // Chặn gửi tin nếu chưa đăng nhập
            if (request.getSession().getAttribute("sessionUser") == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            // Giả lập nhận form liên hệ thành công
            request.setAttribute("successMessage", "Cảm ơn bạn đã liên hệ! Chúng tôi sẽ phản hồi trong vòng 24 giờ.");
            request.getRequestDispatcher("/views/static/contact.jsp").forward(request, response);
        } else {
            doGet(request, response);
        }
    }
}
