/*
 * Màn hình 15: Manage Favorite Tours - Quản lý tour yêu thích (toggle)
 * Tác giả: Dương Quang Sơn
 * MSSV: HE186525
 * Ngày tạo: 2026-07-21
 */
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
        boolean isSaved;
        try {
            isSaved = dao.toggleWishlist(sessionUser.getUserId(), tourId);
        } catch (Exception ex) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"status\":\"error\",\"message\":\"Lỗi hệ thống khi lưu yêu thích: " + ex.getMessage().replace("\"", "'") + "\"}");
            }
            return;
        } finally {
            dao.close();
        }

        try (PrintWriter out = response.getWriter()) {
            String msg = isSaved ? "Đã lưu vào danh sách yêu thích!" : "Đã xóa khỏi danh sách yêu thích!";
            out.print("{\"status\":\"" + (isSaved ? "added" : "removed") + "\",\"isSaved\":" + isSaved + ",\"message\":\"" + msg + "\"}");
        }
    }
}
