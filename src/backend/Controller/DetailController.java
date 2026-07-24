/*
 * Màn hình 5: View Tour Details - Chi tiết tour
 * Tác giả: Dương Quang Sơn
 * MSSV: HE186525
 * Ngày tạo: 2026-07-21
 */
package Controller;

import Entities.Tour;
import Entities.Coupon;
import Entities.User;
import Model.TourDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;

/**
 * DetailController là Servlet xử lý các yêu cầu liên quan đến Trang chi tiết Tour.
 * - Địa chỉ URL ánh xạ: /detail (ví dụ: http://localhost:8080/Group1_SWP/detail?id=1)
 * - doGet: Nạp thông tin chi tiết của một Tour từ DB (bao gồm Lịch trình, Inclusions, FAQs, Reviews) và trả về trang hiển thị detail.jsp.
 * - doPost: Tiếp nhận dữ liệu khi người dùng gửi đánh giá mới từ form, lưu trữ vào DB và tải lại trang chi tiết.
 */
@WebServlet(name = "DetailController", urlPatterns = {"/detail"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2 MB
    maxFileSize = 1024 * 1024 * 10,      // 10 MB limit for single file
    maxRequestSize = 1024 * 1024 * 50    // 50 MB limit for total request
)
public class DetailController extends HttpServlet {

    /**
     * Phương thức doGet được gọi khi khách hàng click xem chi tiết một tour bất kỳ từ:
     * - Trang chủ (HomePage.jsp)
     * - Trang khám phá (tourdiscovery.jsp)
     * - Hoặc các tour liên quan ở cuối trang.
     * Nạp toàn bộ dữ liệu chi tiết của Tour và các đề xuất tour liên quan, mã giảm giá để hiển thị ở UI.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // 1. Đọc và kiểm tra tham số "id" của tour từ query string (?id=X)
        String idStr = request.getParameter("id");
        int id;
        if (idStr != null && !idStr.trim().isEmpty()) {
            try {
                id = Integer.parseInt(idStr);
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        
        TourDAO tourDAO = null;
        try {
            tourDAO = new TourDAO();
            
            // 2. Gọi DAO nạp thông tin chi tiết tour bằng ID.
            // Hàm getTourById(id) tự động nạp kèm danh sách lịch trình (itinerary), dịch vụ đi kèm (inclusion), danh mục và đánh giá
            Tour tour = tourDAO.getTourById(id);
            
            if (tour != null) {
                request.setAttribute("tour", tour);
                
                // 3. Nạp thêm danh sách tất cả các tour trong hệ thống để làm phần gợi ý "Hành Trình Tương Tự Bạn Sẽ Thích" ở cuối trang.
                List<Tour> tours = tourDAO.searchTours(null, null, null, null);
                if (tours != null) {
                    for (Tour t : tours) {
                        // Nạp lịch trình đi cho từng tour gợi ý để lấy số chỗ trống và ngày đi hiển thị lên card.
                        t.setSchedules(tourDAO.getSchedulesByTourId(t.getTourId()));
                    }
                }
                request.setAttribute("tours", tours);
                
                // 4. Nạp danh sách các mã giảm giá hoạt động để hiển thị ở Booking Sidebar
                List<Coupon> activeCoupons = tourDAO.getActiveCoupons(10);
                request.setAttribute("activeCoupons", activeCoupons);
                
                // 5. Nạp danh sách các ID Tour trong Wishlist nếu người dùng đã đăng nhập, phục vụ thả tim nhanh
                Entities.User sessionUser = (Entities.User) request.getSession().getAttribute("sessionUser");
                if (sessionUser != null) {
                    Model.WishlistDAO wishlistDAO = new Model.WishlistDAO();
                    List<Integer> wishlistTourIds = wishlistDAO.getWishlistTourIds(sessionUser.getUserId());
                    request.setAttribute("wishlistTourIds", wishlistTourIds);
                    wishlistDAO.close();
                }
                
                // Chuyển tiếp yêu cầu sang trang hiển thị chi tiết tour
                request.getRequestDispatcher("/views/detail.jsp").forward(request, response);
                return;
            } else {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        } finally {
            if (tourDAO != null) {
                tourDAO.close();
            }
        }
    }

    /**
     * Phương thức doPost được gọi khi người dùng gửi đánh giá mới (Review) từ biểu mẫu.
     * Hỗ trợ lưu trữ ý kiến bình luận, số sao đánh giá (1-5) và ảnh chụp trải nghiệm thực tế (nếu có).
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        // 1. Kiểm tra trạng thái đăng nhập, chỉ người dùng đã đăng nhập mới được đánh giá tour
        jakarta.servlet.http.HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("sessionUser") : null;
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // 2. Đọc giá trị gửi lên từ form bình luận/đánh giá
        String formName = request.getParameter("name");
        String formEmail = request.getParameter("email");
        String content = request.getParameter("content"); 
        String ratingStr = request.getParameter("rating"); 
        String tourIdStr = request.getParameter("tourId"); 
        
        // Lấy thông tin họ tên & email của user đã đăng nhập, nếu thiếu sẽ sử dụng dữ liệu điền từ Form
        String name = (sessionUser.getFullName() != null && !sessionUser.getFullName().trim().isEmpty()) ? sessionUser.getFullName() : formName;
        String email = (sessionUser.getEmail() != null && !sessionUser.getEmail().trim().isEmpty()) ? sessionUser.getEmail() : formEmail;
        
        int tourId = 1;
        int rating = 5;
        
        try {
            if (tourIdStr != null) tourId = Integer.parseInt(tourIdStr);
            if (ratingStr != null) {
                rating = Integer.parseInt(ratingStr);
                if (rating < 1 || rating > 5) {
                    rating = 5;
                }
            }
        } catch (NumberFormatException e) {
            // Fallback giá trị mặc định khi định dạng số sai
        }
        
        // 3. Xử lý tải ảnh đính kèm đánh giá (nếu có tải tệp file)
        String imageUrl = null;
        try {
            Part filePart = request.getPart("reviewImage");
            if (filePart != null && filePart.getSize() > 0) {
                String submittedName = filePart.getSubmittedFileName();
                String ext = ".jpg";
                if (submittedName != null && submittedName.contains(".")) {
                    ext = submittedName.substring(submittedName.lastIndexOf("."));
                }
                String uniqueName = "review_" + tourId + "_" + System.currentTimeMillis() + ext;
                String uploadDir = request.getServletContext().getRealPath("") + File.separator + "assets" + File.separator + "images";
                File dir = new File(uploadDir);
                if (!dir.exists()) {
                    dir.mkdirs();
                }
                filePart.write(uploadDir + File.separator + uniqueName);
                imageUrl = request.getContextPath() + "/assets/images/" + uniqueName; // URL ảnh lưu DB
            }
        } catch (Exception e) {
            System.err.println("Error uploading review image: " + e.getMessage());
        }
        
        // 4. Lưu đánh giá vào DB thông qua DAO
        TourDAO tourDAO = null;
        try {
            tourDAO = new TourDAO();
            if (content == null || content.trim().isEmpty()) {
                session.setAttribute("reviewError", "Vui lòng nhập nội dung đánh giá!");
            } else if (name == null || name.trim().isEmpty() || email == null || email.trim().isEmpty()) {
                session.setAttribute("reviewError", "Vui lòng cung cấp đầy đủ họ tên và email!");
            } else {
                // Gọi DAO ghi nhận đánh giá của người dùng
                boolean success = tourDAO.insertReview(name.trim(), email.trim(), tourId, rating, content.trim(), imageUrl);
                if (success) {
                    session.setAttribute("reviewSuccess", "Cảm ơn bạn đã gửi đánh giá! Đang chờ ban quản trị kiểm duyệt.");
                } else {
                    session.setAttribute("reviewError", "Gửi đánh giá thất bại. Bạn chỉ được phép đánh giá một lần duy nhất cho mỗi tour sau khi đã hoàn thành chuyến đi!");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (tourDAO != null) {
                tourDAO.close();
            }
        }
        
        // 5. Áp dụng kỹ thuật PRG (Post-Redirect-Get) để tránh lỗi gửi lại form khi người dùng tải lại trang F5
        response.sendRedirect(request.getContextPath() + "/detail?id=" + tourId);
    }
}
