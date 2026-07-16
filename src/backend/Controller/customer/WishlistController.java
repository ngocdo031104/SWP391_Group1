package Controller.customer;

import Entities.User;
import Model.WishlistDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "WishlistController", urlPatterns = {"/customer/wishlist/toggle"})
public class WishlistController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        User sessionUser = (User) request.getSession().getAttribute("sessionUser");
        
        if (sessionUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"status\":\"error\",\"message\":\"Vui lòng đăng nhập để lưu tour yêu thích.\"}");
            }
            return;
        }
        
        int tourId = 0;
        try {
            tourId = Integer.parseInt(request.getParameter("tourId"));
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"status\":\"error\",\"message\":\"Mã tour không hợp lệ.\"}");
            }
            return;
        }
        
        WishlistDAO dao = new WishlistDAO();
        boolean isSaved = dao.toggleWishlist(sessionUser.getUserId(), tourId);
        dao.close();
        
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"status\":\"success\",\"message\":\"" + (isSaved ? "Đã lưu vào danh sách yêu thích!" : "Đã xóa khỏi danh sách yêu thích!") + "\"}");
        }
    }
}
