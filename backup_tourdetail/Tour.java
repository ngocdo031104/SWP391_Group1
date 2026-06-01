package Entities;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.List;

public class Tour implements Serializable {
    private int tourId;
    private int categoryId;
    private String tourName;
    private String description;
    private String destination;
    private int durationDays;
    private String itinerary;
    private String difficultyLevel;
    private double basePrice;
    private int maxParticipants;
    private String status;
    private boolean isFeatured;
    
    // New fields matching the updated DB schema
    private String languages;
    private int groupSizeMin;
    private int groupSizeMax;
    private String departureCity;
    private Double latitude;
    private Double longitude;
    private String videoUrl;
    
    // Derived fields
    private double rating = 4.8;
    private int reviewsCount = 45;

    private Integer createdBy;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // --- CÁC THỰC THỂ LIÊN KẾT (RELATIONAL ENTITIES) ---
    // Lý do khai báo các trường này:
    // - Tour đóng vai trò là thực thể cha (Aggregate Root). Việc khai báo các thực thể liên kết này giúp
    //   đóng gói tất cả thông tin liên quan của một chuyến đi vào cùng một đối tượng Java.
    // - Khi DetailController gọi TourDAO.getTourById(id), toàn bộ các danh sách này sẽ được nạp từ các bảng
    //   tương ứng trong Database và gán vào đối tượng Tour, giúp trang detail.jsp có đầy đủ dữ liệu để kết xuất giao diện.

    // Danh mục của tour du lịch (ví dụ: Nghỉ dưỡng, Bãi biển, Thử thách trekking...)
    // Liên kết: Tham chiếu tới bảng TourCategory qua khóa ngoại CategoryID.
    private TourCategory category;

    // Danh sách các lịch khởi hành sắp tới của tour (ngày đi, ngày về, số chỗ trống, giá vé...)
    // Liên kết: Nạp từ bảng TourSchedule dựa theo TourID, dùng để hiển thị hộp đặt tour ở sidebar bên phải trang detail.jsp.
    private List<TourSchedule> schedules;

    // Danh sách hình ảnh và video quảng bá cho tour
    // Liên kết: Nạp từ bảng TourMedia, dùng để kết xuất slideshow ảnh đẹp ở phần đầu trang detail.jsp.
    private List<TourMedia> mediaList;

    // Lịch trình chi tiết từng ngày của tour (ngày 1 đi đâu làm gì, ngày 2 đi đâu...)
    // Liên kết: Nạp từ bảng TourItinerary, dùng để vẽ Timeline lịch trình động (bằng JS/HTML) ở thân giữa trang detail.jsp.
    private List<TourItinerary> itineraries;

    // Danh sách các dịch vụ đi kèm bao gồm (Included) và không bao gồm (Excluded)
    // Liên kết: Nạp từ bảng TourInclusion, hiển thị dạng hai cột trong thẻ dịch vụ ở thân trang detail.jsp.
    private List<TourInclusion> inclusions;

    // Các câu hỏi và giải đáp thắc mắc thường gặp liên quan đến tour này
    // Liên kết: Nạp từ bảng TourFAQ, hiển thị dưới dạng Accordion bấm để thả câu trả lời ở gần cuối trang detail.jsp.
    private List<TourFAQ> faqs;
    // Danh sách các đánh giá (Reviews) của Tour du lịch này.
    // Lý do cần thiết lập thuộc tính này: 
    // - Tour là thực thể gốc (Aggregate Root), chứa thông tin chung của chuyến đi.
    // - Việc khai báo thêm List<Review> giúp đối tượng Tour đóng gói trọn vẹn cả dữ liệu
    //   đánh giá của nó, tạo điều kiện thuận lợi khi đẩy dữ liệu sang detail.jsp.
    // Liên kết: Nạp từ bảng Review trong DB thông qua TourDAO.getReviewsByTourId.
    private List<Review> reviews;

    public Tour() {
    }

    public int getTourId() {
        return tourId;
    }

    public void setTourId(int tourId) {
        this.tourId = tourId;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getTourName() {
        return tourName;
    }

    public void setTourName(String tourName) {
        this.tourName = tourName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getDestination() {
        return destination;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public int getDurationDays() {
        return durationDays;
    }

    public void setDurationDays(int durationDays) {
        this.durationDays = durationDays;
    }

    public String getItinerary() {
        return itinerary;
    }

    public void setItinerary(String itinerary) {
        this.itinerary = itinerary;
    }

    public String getDifficultyLevel() {
        return difficultyLevel;
    }

    public void setDifficultyLevel(String difficultyLevel) {
        this.difficultyLevel = difficultyLevel;
    }

    public double getBasePrice() {
        return basePrice;
    }

    public void setBasePrice(double basePrice) {
        this.basePrice = basePrice;
    }

    public int getMaxParticipants() {
        return maxParticipants;
    }

    public void setMaxParticipants(int maxParticipants) {
        this.maxParticipants = maxParticipants;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isIsFeatured() {
        return isFeatured;
    }

    public void setIsFeatured(boolean isFeatured) {
        this.isFeatured = isFeatured;
    }

    public String getLanguages() {
        return languages;
    }

    public void setLanguages(String languages) {
        this.languages = languages;
    }

    public int getGroupSizeMin() {
        return groupSizeMin;
    }

    public void setGroupSizeMin(int groupSizeMin) {
        this.groupSizeMin = groupSizeMin;
    }

    public int getGroupSizeMax() {
        return groupSizeMax;
    }

    public void setGroupSizeMax(int groupSizeMax) {
        this.groupSizeMax = groupSizeMax;
    }

    public String getDepartureCity() {
        return departureCity;
    }

    public void setDepartureCity(String departureCity) {
        this.departureCity = departureCity;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public String getVideoUrl() {
        return videoUrl;
    }

    public void setVideoUrl(String videoUrl) {
        this.videoUrl = videoUrl;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public int getReviewsCount() {
        return reviewsCount;
    }

    public void setReviewsCount(int reviewsCount) {
        this.reviewsCount = reviewsCount;
    }

    public Integer getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public TourCategory getCategory() {
        return category;
    }

    public void setCategory(TourCategory category) {
        this.category = category;
    }

    public List<TourSchedule> getSchedules() {
        return schedules;
    }

    public void setSchedules(List<TourSchedule> schedules) {
        this.schedules = schedules;
    }

    public List<TourMedia> getMediaList() {
        return mediaList;
    }

    public void setMediaList(List<TourMedia> mediaList) {
        this.mediaList = mediaList;
    }

    public List<TourItinerary> getItineraries() {
        return itineraries;
    }

    public void setItineraries(List<TourItinerary> itineraries) {
        this.itineraries = itineraries;
    }

    public List<TourInclusion> getInclusions() {
        return inclusions;
    }

    public void setInclusions(List<TourInclusion> inclusions) {
        this.inclusions = inclusions;
    }

    public List<TourFAQ> getFaqs() {
        return faqs;
    }

    public void setFaqs(List<TourFAQ> faqs) {
        this.faqs = faqs;
    }

    // Lấy ra danh sách Đánh giá của Tour (detail.jsp sẽ đọc thông qua biểu thức activeTour.getReviews())
    public List<Review> getReviews() {
        return reviews;
    }

    // Thiết lập danh sách Đánh giá cho Tour (thực hiện ở tầng TourDAO khi gọi getTourById)
    public void setReviews(List<Review> reviews) {
        this.reviews = reviews;
    }
}
