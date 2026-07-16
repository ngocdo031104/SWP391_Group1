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
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        // Thiết lập bộ mã UTF-8 để đảm bảo khi đọc tham số tiếng Việt từ URL hoặc request không bị lỗi hiển thị.
        request.setCharacterEncoding("UTF-8");
        
        // Đọc tham số "id" của tour từ query string (?id=X)
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
                // Chuyển tiếp yêu cầu (forward) sang trang giao diện detail.jsp
                request.getRequestDispatcher("/views/detail.jsp").forward(request, response);
                return;
            } else {
                // Nếu không tìm thấy Tour với ID tương ứng trong DB, chuyển hướng người dùng về Trang chủ.
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        } finally {
            // Đảm bảo đóng kết nối cơ sở dữ liệu an toàn để tránh rò rỉ kết nối (connection leak).
            if (tourDAO != null) {
                tourDAO.close();
            }
        }
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
        
        // Đọc giá trị gửi lên từ form
        String formName = request.getParameter("name");
        String formEmail = request.getParameter("email");
        String content = request.getParameter("content"); 
        String ratingStr = request.getParameter("rating"); 
        String tourIdStr = request.getParameter("tourId"); 
        
        // Sử dụng sessionUser làm nguồn xác thực, fallback về form nếu sessionUser thiếu
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
            // Bỏ qua lỗi định dạng số nếu có
        }
        
        // Xử lý upload ảnh thật từ file input có name="reviewImage"
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
                imageUrl = request.getContextPath() + "/assets/images/" + uniqueName;
            }
        } catch (Exception e) {
            System.err.println("Error uploading review image: " + e.getMessage());
        }
        
        TourDAO tourDAO = null;
        try {
            tourDAO = new TourDAO();
            // Kiểm tra tính hợp lệ của dữ liệu trước khi chèn vào DB
            if (content == null || content.trim().isEmpty()) {
                session.setAttribute("reviewError", "Vui lòng nhập nội dung đánh giá!");
            } else if (name == null || name.trim().isEmpty() || email == null || email.trim().isEmpty()) {
                session.setAttribute("reviewError", "Vui lòng cung cấp đầy đủ họ tên và email!");
            } else {
                // Gọi hàm insertReview của DAO (phương thức 6 tham số có kèm imageUrl)
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
