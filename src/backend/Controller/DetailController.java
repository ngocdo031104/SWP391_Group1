package Controller;

import Entities.Tour;
import Entities.Coupon;
import Entities.User;
import Model.TourDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * DetailController là Servlet xử lý các yêu cầu liên quan đến Trang chi tiết Tour.
 * - Địa chỉ URL ánh xạ: /detail (ví dụ: http://localhost:8080/Group1_SWP/detail?id=1)
 * - doGet: Nạp thông tin chi tiết của một Tour từ DB (bao gồm Lịch trình, Inclusions, FAQs, Reviews) và trả về trang hiển thị detail.jsp.
 * - doPost: Tiếp nhận dữ liệu khi người dùng gửi đánh giá mới từ form, lưu trữ vào DB và tải lại trang chi tiết.
 */
@WebServlet(name = "DetailController", urlPatterns = {"/detail"})
public class DetailController extends HttpServlet {

    /**
     * Phương thức doGet được gọi khi khách hàng click xem chi tiết một tour bất kỳ từ:
     * - Trang chủ (HomePage.jsp)
     * - Trang khám phá (tourdiscovery.jsp)
     * - Hoặc các tour liên quan ở cuối trang.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Thiết lập bộ mã UTF-8 để đảm bảo khi đọc tham số tiếng Việt từ URL hoặc request không bị lỗi hiển thị.
        request.setCharacterEncoding("UTF-8");
        
        // Đọc tham số "id" của tour từ query string (?id=X)
        String idStr = request.getParameter("id");
        int id = 1; // Giá trị ID mặc định nếu không truyền hoặc truyền sai định dạng.
        if (idStr != null && !idStr.trim().isEmpty()) {
            try {
                id = Integer.parseInt(idStr);
            } catch (NumberFormatException e) {
                // Nếu tham số không phải là số hợp lệ, giữ nguyên id = 1 làm mặc định.
            }
        }
        
        TourDAO tourDAO = null;
        try {
            // Khởi tạo đối tượng truy cập cơ sở dữ liệu
            tourDAO = new TourDAO();
            
            // Gọi DAO nạp thông tin chi tiết tour bằng ID.
            // Hàm getTourById(id) đã được viết để nạp kèm tất cả Itineraries, Inclusions, FAQs, Reviews.
            Tour tour = tourDAO.getTourById(id);
            
            if (tour != null) {
                // Đưa đối tượng tour vào request attribute để trang detail.jsp có thể đọc ra hiển thị.
                request.setAttribute("tour", tour);
                
                // Nạp thêm danh sách tất cả các tour trong hệ thống để làm phần gợi ý "Hành Trình Tương Tự Bạn Sẽ Thích" ở cuối trang.
                List<Tour> tours = tourDAO.searchTours(null, null, null, null);
                if (tours != null) {
                    for (Tour t : tours) {
                        // Nạp lịch trình đi cho từng tour gợi ý để lấy số chỗ trống và ngày đi hiển thị lên card.
                        t.setSchedules(tourDAO.getSchedulesByTourId(t.getTourId()));
                    }
                }
                // Đưa danh sách tour gợi ý vào request attribute.
                request.setAttribute("tours", tours);
                
                // Nạp danh sách các mã giảm giá hoạt động để sử dụng trong booking sidebar
                List<Coupon> activeCoupons = tourDAO.getActiveCoupons(10);
                request.setAttribute("activeCoupons", activeCoupons);
                
                // Nạp wishlist nếu người dùng đã đăng nhập
                Entities.User sessionUser = (Entities.User) request.getSession().getAttribute("sessionUser");
                if (sessionUser != null) {
                    Model.WishlistDAO wishlistDAO = new Model.WishlistDAO();
                    List<Integer> wishlistTourIds = wishlistDAO.getWishlistTourIds(sessionUser.getUserId());
                    request.setAttribute("wishlistTourIds", wishlistTourIds);
                    wishlistDAO.close();
                }
            } else {
                // Nếu không tìm thấy Tour với ID tương ứng trong DB, chuyển hướng người dùng về Trang chủ.
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            // Đảm bảo đóng kết nối cơ sở dữ liệu an toàn để tránh rò rỉ kết nối (connection leak).
            if (tourDAO != null) {
                tourDAO.close();
            }
        }
        
        // Chuyển tiếp yêu cầu (forward) sang trang giao diện detail.jsp nằm trong thư mục web/views/
        request.getRequestDispatcher("/views/detail.jsp").forward(request, response);
    }

    /**
     * Phương thức doPost được gọi khi người dùng nhấn nút "Gửi Đánh Giá" từ biểu mẫu
     * "Chia Sẻ Trải Nghiệm Của Bạn" ở cuối trang detail.jsp.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        jakarta.servlet.http.HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("sessionUser") : null;
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String name = sessionUser.getFullName(); // Use secure credentials from session
        String email = sessionUser.getEmail();   // Use secure credentials from session
        String content = request.getParameter("content"); 
        String ratingStr = request.getParameter("rating"); 
        String tourIdStr = request.getParameter("tourId"); 
        
        int tourId = 1;
        int rating = 5;
        
        try {
            if (tourIdStr != null) tourId = Integer.parseInt(tourIdStr);
            if (ratingStr != null) rating = Integer.parseInt(ratingStr);
        } catch (NumberFormatException e) {
            // Bỏ qua lỗi định dạng số nếu có
        }
        
        TourDAO tourDAO = null;
        try {
            tourDAO = new TourDAO();
            // Kiểm tra tính hợp lệ của dữ liệu trước khi chèn vào DB
            if (name != null && email != null && content != null) {
                // Gọi hàm insertReview của DAO để thực hiện logic lưu đánh giá mới vào bảng Review trong cơ sở dữ liệu.
                tourDAO.insertReview(name.trim(), email.trim(), tourId, rating, content.trim());
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            // Đảm bảo đóng kết nối DB
            if (tourDAO != null) {
                tourDAO.close();
            }
        }
        
        // Sau khi thêm đánh giá thành công, dùng kỹ thuật PRG (Post-Redirect-Get) chuyển hướng (Redirect)
        // người dùng quay trở lại chính trang chi tiết của tour đó (?id=tourId) để tránh hiện tượng
        // người dùng nhấn F5 bị gửi lại đánh giá lần thứ 2.
        response.sendRedirect(request.getContextPath() + "/detail?id=" + tourId);
    }
}
