package Controller;

import Entities.Tour;
import Entities.TourCategory;
import Entities.DestinationInfo;
import Entities.Review;
import Entities.Coupon;
import Model.TourDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

// Định nghĩa URL mapping cho servlet này, gán route "/home" cho trang chủ
@WebServlet(name = "HomeController", urlPatterns = {"/home"})
public class HomeController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        TourDAO tourDAO = null;
        try {
            // Khởi tạo DAO để chuẩn bị kết nối và thao tác với Database SQL Server
            tourDAO = new TourDAO();
            
            // 1. Lấy tất cả danh mục tour đang hoạt động để làm bộ lọc phân loại ở trang chủ
            List<TourCategory> categories = tourDAO.getAllCategories();
            
            // 2. Lấy danh sách các tour nổi bật (đánh dấu IsFeatured = 1) để hiển thị ở grid chính
            List<Tour> featuredTours = tourDAO.getFeaturedTours();
            
            // 3. Lấy danh sách điểm đến phổ biến kèm số lượng tour để hiển thị section "Điểm Đến Hot"
            List<DestinationInfo> destinations = tourDAO.getTopDestinations();
            
            // 4. Lấy tối đa 5 đánh giá tốt (>= 4 sao) để làm slider phản hồi khách hàng (Testimonials)
            List<Review> topReviews = tourDAO.getTopReviews(5);
            
            // 5. Lấy tối đa 5 mã giảm giá đang hoạt động cho banner Flash Sale / Coupons
            List<Coupon> activeCoupons = tourDAO.getActiveCoupons(5);
            
            // 6. Với mỗi tour nổi bật ở trên, cần gọi thêm DB để lấy danh sách lịch trình (schedules)
            // để JSP tính toán và hiển thị thanh phần trăm chỗ trống (available seats) thực tế.
            if (featuredTours != null) {
                for (Tour tour : featuredTours) {
                    tour.setSchedules(tourDAO.getSchedulesByTourId(tour.getTourId()));
                }
            }
            
            // Đóng gói toàn bộ list dữ liệu vừa query được vào request attribute để chuyển giao cho tầng View (JSP)
            request.setAttribute("categories", categories);
            request.setAttribute("featuredTours", featuredTours);
            request.setAttribute("destinations", destinations);
            request.setAttribute("topReviews", topReviews);
            request.setAttribute("activeCoupons", activeCoupons);
        } catch (Exception e) {
            // In stack trace ra console để debug khi chạy local nếu phát sinh lỗi DB
            e.printStackTrace();
        } finally {
            // Quan trọng: Phải đóng connection DB trong khối finally để tránh bị tràn (leak) connection pool dẫn đến sập DB
            if (tourDAO != null) {
                tourDAO.close();
            }
        }
        
        // Forward (chuyển tiếp âm thầm) request này sang file JSP để render HTML trả về cho client
        request.getRequestDispatcher("/views/HomePage.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Ở trang chủ thì POST hay GET đều quy về doGet để xử lý render giao diện như nhau
        doGet(request, response);
    }
}
