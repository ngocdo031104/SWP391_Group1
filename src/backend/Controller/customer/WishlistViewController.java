/*
 * Màn hình 15: Manage Favorite Tours - Quản lý tour yêu thích (view)
 * Tác giả: Dương Quang Sơn
 * MSSV: HE186525
 * Ngày tạo: 2026-07-21
 */
package Controller.customer;

import Entities.Tour;
import Entities.User;
import Model.TourDAO;
import Model.WishlistDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "WishlistViewController", urlPatterns = {"/customer/wishlist"})
public class WishlistViewController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User sessionUser = (User) session.getAttribute("sessionUser");
        
        WishlistDAO wishlistDAO = null;
        TourDAO tourDAO = null;
        try {
            wishlistDAO = new WishlistDAO();
            tourDAO = new TourDAO();
            
            // Lấy danh sách tour yêu thích của khách hàng
            List<Tour> wishlistTours = wishlistDAO.getWishlistTours(sessionUser.getUserId());
            
            // Nạp schedules cho từng tour yêu thích để hiển thị chỗ trống & ngày khởi hành gần nhất
            if (wishlistTours != null) {
                for (Tour tour : wishlistTours) {
                    tour.setSchedules(tourDAO.getSchedulesByTourId(tour.getTourId()));
                }
            }
            
            request.setAttribute("wishlistTours", wishlistTours);
            request.setAttribute("extraCss", "css/wishlist.css");
            request.setAttribute("extraScript", "js/wishlist.js");
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (wishlistDAO != null) {
                wishlistDAO.close();
            }
            if (tourDAO != null) {
                tourDAO.close();
            }
        }

        request.getRequestDispatcher("/customer/wishlist.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
