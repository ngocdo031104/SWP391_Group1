package Entities;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * LỚP THỰC THỂ REVIEW (ĐÁNH GIÁ KHÁCH HÀNG)
 * Lý do tại sao phải tạo class này:
 * - Để làm đối tượng đóng gói dữ liệu (Data Transfer Object) vận chuyển thông tin đánh giá
 *   từ cơ sở dữ liệu (thông qua TourDAO) truyền qua DetailController (Servlet) để đưa ra hiển thị trên detail.jsp.
 * - Giúp quản lý lập trình hướng đối tượng trong ứng dụng Java Web JSP/Servlet.
 * - Liên kết trực tiếp với bảng `Review` trong cơ sở dữ liệu SQL Server.
 */
public class Review implements Serializable {
    
    // Khóa chính tự tăng trong bảng Review (ReviewID)
    // Chức năng: Định danh duy nhất cho từng đánh giá trong DB.
    private int reviewId;
    
    // Khóa ngoại liên kết tới bảng Tour (TourID)
    // Chức năng: Xác định đánh giá này viết cho tour du lịch cụ thể nào.
    // Liên kết: Liên kết đến trường TourID trong class Entities.Tour và bảng Tour.
    private int tourId;
    
    // Khóa ngoại liên kết tới bảng Booking (BookingID)
    // Chức năng: Thỏa mãn ràng buộc khóa ngoại trong DB (bảng Review yêu cầu BookingID không được NULL).
    // Đồng thời giúp kiểm tra xem người dùng đã thực hiện chuyến đi thực tế chưa để dán nhãn "Đã trải nghiệm".
    // Liên kết: Liên kết tới cột BookingID trong bảng Booking.
    private int bookingId;
    
    // Khóa ngoại liên kết tới bảng User (CustomerID)
    // Chức năng: Xác định tài khoản nào (người dùng nào) là tác giả của đánh giá này.
    // Liên kết: Cột CustomerID tham chiếu tới cột UserID trong bảng [User].
    private int customerId;
    
    // Điểm đánh giá (Rating) từ 1 đến 5 sao
    // Chức năng: Lưu số sao người dùng bình chọn cho tour.
    // Sử dụng: JavaScript (detail.js) sẽ đọc giá trị này để vẽ các ngôi sao vàng tương ứng.
    private int rating;
    
    // Nội dung bình luận chi tiết (Content)
    // Chức năng: Lưu cảm nghĩ, ý kiến phản hồi của khách hàng về chuyến đi.
    // Định dạng trong DB: NVARCHAR(MAX) để lưu được tiếng Việt có dấu.
    private String content;
    
    // Trạng thái hiển thị (IsVisible)
    // Chức năng: 1 (true) nghĩa là được hiển thị, 0 (false) nghĩa là bị ẩn đi (ví dụ do quản trị viên kiểm duyệt nội dung xấu).
    private boolean isVisible = true;
    
    // Ngày giờ tạo đánh giá (CreatedAt)
    // Chức năng: Tự động ghi lại thời gian gửi đánh giá.
    // Sử dụng: Giúp sắp xếp các đánh giá mới nhất lên đầu danh sách hiển thị trên detail.jsp.
    private Timestamp createdAt;
    
    // Ngày giờ cập nhật đánh giá (UpdatedAt)
    // Chức năng: Ghi nhận thời gian cập nhật nội dung đánh giá nếu có chỉnh sửa.
    private Timestamp updatedAt;

    // --- CÁC TRƯỜNG THÔNG TIN PHỤ TRỢ (JOIN DỮ LIỆU ĐỂ HIỂN THỊ TRÊN UI) ---
    // Lý do cần các trường này: Trong DB, bảng Review chỉ lưu IDs (CustomerID, BookingID).
    // Nếu không có các trường này, khi hiển thị ra detail.jsp, ta không thể hiển thị ngay Tên khách hàng hay Avatar
    // mà phải thực hiện truy vấn riêng lẻ khác, gây chậm hệ thống.
    
    // Họ tên đầy đủ của người đánh giá
    // Chức năng: Lưu tên hiển thị (ví dụ: "Phạm Minh Hoàng") trên giao diện.
    // Lấy dữ liệu: Lấy từ cột FullName trong bảng [User] bằng truy vấn JOIN trong TourDAO.getReviewsByTourId.
    private String customerName;
    
    // Đường dẫn ảnh đại diện của người đánh giá
    // Chức năng: Hiển thị hình ảnh avatar nhỏ tròn bên cạnh tên khách hàng.
    // Lấy dữ liệu: Lấy từ cột AvatarURL trong bảng UserProfile thông qua phép LEFT JOIN.
    private String customerAvatar;
    
    // Trạng thái đã xác minh trải nghiệm (IsVerified)
    // Chức năng: Đánh giá sẽ được hiển thị nhãn xanh "Đã trải nghiệm" nếu booking liên kết có trạng thái 'Completed'.
    // Điều này tăng độ uy tín, tin cậy đối với khách hàng mới khi đọc reviews trên detail.jsp.
    private boolean isVerified;

    // Constructor mặc định (Không tham số)
    // Chức năng: Bắt buộc phải có để JSP/Servlet hoặc các thư viện mapping Java Bean có thể khởi tạo đối tượng rỗng.
    public Review() {
    }

    // Lấy ra ID của Đánh giá
    public int getReviewId() {
        return reviewId;
    }

    // Thiết lập ID của Đánh giá (chủ yếu được gán tự động khi nạp từ cơ sở dữ liệu ResultSet)
    public void setReviewId(int reviewId) {
        this.reviewId = reviewId;
    }

    // Lấy ra ID của Tour liên kết
    public int getTourId() {
        return tourId;
    }

    // Thiết lập ID của Tour liên kết (giúp gán xem review này thuộc về tour nào)
    public void setTourId(int tourId) {
        this.tourId = tourId;
    }

    // Lấy ra ID của Booking tương ứng
    public int getBookingId() {
        return bookingId;
    }

    // Thiết lập ID của Booking tương ứng
    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    // Lấy ra ID của Khách hàng viết đánh giá
    public int getCustomerId() {
        return customerId;
    }

    // Thiết lập ID của Khách hàng viết đánh giá
    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    // Lấy ra số sao đánh giá (1-5)
    public int getRating() {
        return rating;
    }

    // Thiết lập số sao đánh giá (chạy khi người dùng chọn sao trên stars-selector và submit)
    public void setRating(int rating) {
        this.rating = rating;
    }

    // Lấy ra nội dung văn bản bình luận
    public String getContent() {
        return content;
    }

    // Thiết lập nội dung văn bản bình luận
    public void setContent(String content) {
        this.content = content;
    }

    // Lấy ra trạng thái hiển thị
    public boolean isIsVisible() {
        return isVisible;
    }

    // Thiết lập trạng thái ẩn hiện đánh giá
    public void setIsVisible(boolean isVisible) {
        this.isVisible = isVisible;
    }

    // Lấy ra ngày giờ tạo
    public Timestamp getCreatedAt() {
        return createdAt;
    }

    // Thiết lập ngày giờ tạo
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    // Lấy ra ngày giờ cập nhật
    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    // Thiết lập ngày giờ cập nhật
    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    // Lấy ra Tên khách hàng (Dùng trực tiếp trong detail.jsp qua thẻ biểu thức <%= review.getCustomerName() %>)
    public String getCustomerName() {
        return customerName;
    }

    // Thiết lập Tên khách hàng (gán dữ liệu sau khi JOIN dữ liệu từ bảng [User] ở tầng DAO)
    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    // Lấy ra Avatar khách hàng (Dùng để hiển thị ảnh tròn trên UI detail.jsp)
    public String getCustomerAvatar() {
        return customerAvatar;
    }

    // Thiết lập Avatar khách hàng (lấy từ UserProfile ở tầng DAO)
    public void setCustomerAvatar(String customerAvatar) {
        this.customerAvatar = customerAvatar;
    }

    // Lấy ra trạng thái đã xác thực đi tour (Dùng trong detail.jsp để quyết định hiển thị badge "Đã trải nghiệm")
    public boolean isIsVerified() {
        return isVerified;
    }

    // Thiết lập trạng thái xác thực đi tour
    public void setIsVerified(boolean isVerified) {
        this.isVerified = isVerified;
    }
}
