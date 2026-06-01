package Controller;

import Entities.Tour;
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
        
        // Chuyển tiếp yêu cầu (forward) sang trang giao diện detail.jsp nằm trong thư mục web/JSP/
        request.getRequestDispatcher("JSP/detail.jsp").forward(request, response);
    }

    /**
     * Phương thức doPost được gọi khi người dùng nhấn nút "Gửi Đánh Giá" từ biểu mẫu
     * "Chia Sẻ Trải Nghiệm Của Bạn" ở cuối trang detail.jsp.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Thiết lập mã hóa UTF-8 để nhận đúng các ký tự tiếng Việt có dấu do người dùng nhập vào Form bình luận.
        request.setCharacterEncoding("UTF-8");
        
        // Đọc các giá trị gửi lên từ thẻ input trong Form (qua thuộc tính name của thẻ)
        String name = request.getParameter("name"); // Họ và tên người đánh giá
        String email = request.getParameter("email"); // Địa chỉ email
        String content = request.getParameter("content"); // Nội dung bình luận chi tiết
        String ratingStr = request.getParameter("rating"); // Số sao đánh giá (1-5), nhận giá trị từ input ẩn do JS thiết lập
        String tourIdStr = request.getParameter("tourId"); // ID của tour đang được đánh giá (để lưu và quay lại đúng trang)
        
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
