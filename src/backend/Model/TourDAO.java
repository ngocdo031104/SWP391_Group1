package Model;

import Entities.Tour;
import Entities.TourCategory;
import Entities.TourMedia;
import Entities.TourSchedule;
import Entities.TourItinerary;
import Entities.TourInclusion;
import Entities.TourFAQ;
import Entities.Review;
import Entities.DestinationInfo;
import Entities.GuideProfile;
import Entities.User;
import Entities.UserProfile;
import Entities.Coupon;
import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class TourDAO extends DBContext {

    /**
     * Gets all active categories.
     * @return list of TourCategory objects
     */
    public List<TourCategory> getAllCategories() {
        // Khởi tạo danh sách rỗng để lưu trữ các danh mục tour sẽ lấy ra từ database
        List<TourCategory> list = new ArrayList<>();
        
        // Chuỗi SQL để SELECT các cột của danh mục tour. Chỉ lấy các danh mục đang hoạt động (IsActive = 1)
        String sql = "SELECT CategoryID, CategoryName, Description, IsActive FROM TourCategory WHERE IsActive = 1";
        
        // Sử dụng try-with-resources để tự động đóng PreparedStatement và ResultSet sau khi dùng xong
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            // Duyệt qua từng dòng kết quả trả về từ database
            while (rs.next()) {
                // Khởi tạo đối tượng TourCategory và gán giá trị tương ứng từ cột cơ sở dữ liệu
                TourCategory cat = new TourCategory(
                    rs.getInt("CategoryID"),
                    rs.getString("CategoryName"),
                    rs.getString("Description"),
                    rs.getBoolean("IsActive")
                );
                // Thêm đối tượng danh mục vừa tạo vào danh sách kết quả
                list.add(cat);
            }
        } catch (SQLException ex) {
            // Ghi log lỗi chi tiết ra console nếu quá trình kết nối hoặc thực thi SQL gặp sự cố
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        // Trả về danh sách danh mục đã nạp đầy đủ dữ liệu
        return list;
    }

    /**
     * Retrieves featured tours.
     * @return list of featured Tour objects
     */
    public List<Tour> getFeaturedTours() {
        // Khởi tạo danh sách rỗng chứa các tour nổi bật
        List<Tour> list = new ArrayList<>();
        
        // Chuỗi SELECT lấy thông tin chi tiết tour và tính điểm rating trung bình + tổng số lượng review bằng subquery.
        // Điều kiện lọc: Chỉ lấy những tour nổi bật (IsFeatured = 1) và đang hoạt động (Status = 'Active')
        String sql = "SELECT TourID, CategoryID, TourName, Description, Destination, DurationDays, Itinerary, DifficultyLevel, BasePrice, MaxParticipants, Status, IsFeatured, IsDeleted, Languages, GroupSizeMin, GroupSizeMax, DepartureCity, Latitude, Longitude, VideoURL, CreatedBy, CreatedAt, UpdatedAt, "
                   + "ISNULL((SELECT AVG(CAST(Rating AS FLOAT)) FROM Review r WHERE r.TourID = Tour.TourID), 0.0) as AvgRating, "
                   + "(SELECT COUNT(*) FROM Review r WHERE r.TourID = Tour.TourID) as ReviewCount "
                   + "FROM Tour WHERE IsFeatured = 1 AND Status = 'Active' AND IsDeleted = 0";
                   
        // Thực thi câu lệnh SQL kết nối database
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
             
            // Vòng lặp duyệt qua từng tour trả về
            while (rs.next()) {
                // Gọi helper method mapTour để tự động map dữ liệu từ ResultSet sang đối tượng Java Tour
                Tour tour = mapTour(rs);
                
                // Mỗi tour hiển thị ở trang chủ cần 1 ảnh đại diện (thumbnail), ta gọi hàm getMediaForTour với tham số onlyFirst = true
                tour.setMediaList(getMediaForTour(tour.getTourId(), true));
                
                // Thêm tour đã hoàn thiện thông tin ảnh đại diện vào list
                list.add(tour);
            }
        } catch (SQLException ex) {
            // Ghi nhận lỗi nếu xảy ra sự cố truy vấn CSDL
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        // Trả về danh sách các tour nổi bật cho HomeController sử dụng
        return list;
    }

    /**
     * Searches and filters tours dynamically.
     * @param destination destination string (fuzzy search)
     * @param categoryId category ID filter (optional)
     * @param maxPrice maximum price filter (optional)
     * @param departureDate departure date filter (optional)
     * @return list of matching tours
     */
    public List<Tour> searchTours(String destination, Integer categoryId, Double maxPrice, String departureDate) {
        List<Tour> list = new ArrayList<>();
        
        // Khởi tạo câu SQL gốc. Lấy các tour có status là Active.
        // Đồng thời dùng truy vấn con (Subquery) để tính AvgRating (số sao trung bình) và ReviewCount của từng tour.
        StringBuilder sql = new StringBuilder(
            "SELECT t.TourID, t.CategoryID, t.TourName, t.Description, t.Destination, t.DurationDays, t.Itinerary, t.DifficultyLevel, t.BasePrice, t.MaxParticipants, t.Status, t.IsFeatured, t.IsDeleted, t.Languages, t.GroupSizeMin, t.GroupSizeMax, t.DepartureCity, t.Latitude, t.Longitude, t.VideoURL, t.CreatedBy, t.CreatedAt, t.UpdatedAt, " +
            "ISNULL((SELECT AVG(CAST(Rating AS FLOAT)) FROM Review r WHERE r.TourID = t.TourID), 0.0) as AvgRating, " +
            "(SELECT COUNT(*) FROM Review r WHERE r.TourID = t.TourID) as ReviewCount " +
            "FROM Tour t " +
            "WHERE t.Status = 'Active' AND t.IsDeleted = 0"
        );
        
        // List này lưu các tham số tương ứng với các dấu "?" động để gán vào PreparedStatement sau nhằm tránh SQL Injection
        List<Object> params = new ArrayList<>();
        
        // Nếu user nhập điểm đến, nối thêm điều kiện lọc theo tên Destination (tìm kiếm tương đối dùng LIKE)
        if (destination != null && !destination.trim().isEmpty()) {
            sql.append(" AND t.Destination LIKE ?");
            params.add("%" + destination.trim() + "%");
        }
        
        // Nếu có chọn danh mục tour cụ thể
        if (categoryId != null) {
            sql.append(" AND t.CategoryID = ?");
            params.add(categoryId);
        }
        
        // Nếu có nhập giá trần (ngân sách tối đa)
        if (maxPrice != null) {
            sql.append(" AND t.BasePrice <= ?");
            params.add(maxPrice);
        }
        
        // Nếu lọc theo ngày khởi hành, kiểm tra ngày đi của lịch trình (DepartureDate) phải lớn hơn hoặc bằng ngày tìm kiếm
        if (departureDate != null && !departureDate.trim().isEmpty()) {
            sql.append(" AND EXISTS (SELECT 1 FROM TourSchedule s WHERE s.TourID = t.TourID AND s.DepartureDate >= ? AND s.Status = 'Open')");
            params.add(java.sql.Date.valueOf(departureDate));
        }

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            // Duyệt qua list params và gán giá trị tương ứng vào từng dấu "?" trong câu SQL động
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Tour tour = mapTour(rs);
                    // Lấy thêm 1 ảnh đại diện (thumbnail) của tour để hiển thị trên giao diện danh sách
                    tour.setMediaList(getMediaForTour(tour.getTourId(), true));
                    list.add(tour);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        return list;
    }

    /**
     * Retrieves a full tour details including category, media list, and upcoming schedules.
     * @param tourId tour ID
     * @return Tour object or null if not found
     */
    public Tour getTourById(int tourId) {
        // Chuỗi SELECT lấy thông tin chi tiết tour bằng ID, đồng thời JOIN với bảng TourCategory
        // để lấy thêm CategoryName và CategoryDesc phục vụ hiển thị Breadcrumb và nhãn danh mục ở trang Detail.
        String sql = "SELECT t.TourID, t.CategoryID, t.TourName, t.Description, t.Destination, t.DurationDays, t.Itinerary, t.DifficultyLevel, t.BasePrice, t.MaxParticipants, t.Status, t.IsFeatured, t.IsDeleted, t.Languages, t.GroupSizeMin, t.GroupSizeMax, t.DepartureCity, t.Latitude, t.Longitude, t.VideoURL, t.CreatedBy, t.CreatedAt, t.UpdatedAt, "
                   + "ISNULL((SELECT AVG(CAST(Rating AS FLOAT)) FROM Review r WHERE r.TourID = t.TourID), 0.0) as AvgRating, "
                   + "(SELECT COUNT(*) FROM Review r WHERE r.TourID = t.TourID) as ReviewCount, "
                   + "c.CategoryName, c.Description AS CategoryDesc "
                   + "FROM Tour t "
                   + "JOIN TourCategory c ON t.CategoryID = c.CategoryID "
                   + "WHERE t.TourID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            // Truyền tham số ID tour cần tìm vào câu lệnh SQL
            ps.setInt(1, tourId);
            try (ResultSet rs = ps.executeQuery()) {
                // Nếu tìm thấy tour khớp với ID trong DB
                if (rs.next()) {
                    // Map các trường cơ bản của Tour
                    Tour tour = mapTour(rs);
                    
                    // Khởi tạo và gán đối tượng TourCategory đi kèm
                    TourCategory cat = new TourCategory();
                    cat.setCategoryId(rs.getInt("CategoryID"));
                    cat.setCategoryName(rs.getString("CategoryName"));
                    cat.setDescription(rs.getString("CategoryDesc"));
                    tour.setCategory(cat);
                    
                    // Nạp danh sách hình ảnh/video của tour từ bảng TourMedia để hiển thị lên slideshow ảnh ở đầu trang detail.jsp
                    tour.setMediaList(getMediaForTour(tourId, false));
                    
                    // Nạp danh sách các đợt khởi hành còn chỗ trong tương lai từ bảng TourSchedule để tính toán số ghế trống và giá ở sidebar
                    tour.setSchedules(getSchedulesByTourId(tourId));
                    
                    // Nạp lịch trình đi cụ thể từng ngày từ bảng TourItinerary để hiển thị sơ đồ Timeline động ở thân trang
                    tour.setItineraries(getItineraryByTourId(tourId));
                    
                    // Nạp danh sách dịch vụ bao gồm (Included) và loại trừ (Excluded) từ bảng TourInclusion
                    tour.setInclusions(getInclusionsByTourId(tourId));
                    
                    // Nạp danh sách câu hỏi thường gặp FAQ từ bảng TourFAQ phục vụ Accordion ở cuối trang
                    tour.setFaqs(getFaqsByTourId(tourId));
                    
                    // Nạp tất cả các bình luận, đánh giá và số sao thực tế từ khách hàng từ bảng Review để hiển thị lên khung nhận xét
                    tour.setReviews(getReviewsByTourId(tourId));
                    return tour;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    /**
     * Gets all upcoming schedules for a specific tour.
     * @param tourId tour ID
     * @return list of TourSchedule objects
     */
    public List<TourSchedule> getSchedulesByTourId(int tourId) {
        // Khởi tạo danh sách rỗng chứa các lịch trình khởi hành
        List<TourSchedule> list = new ArrayList<>();
        
        // Truy vấn danh sách lịch khởi hành của tour này lớn hơn hoặc bằng ngày hôm nay (DepartureDate >= GETDATE())
        // Đồng thời LEFT JOIN bảng [User] và UserProfile để lấy thông tin chi tiết của Hướng dẫn viên (Guide) phục vụ tour đó.
        String sql = "SELECT ts.ScheduleID, ts.TourID, ts.DepartureDate, ts.ReturnDate, ts.TotalSeats, ts.AvailableSeats, "
                   + "ts.PriceAdult, ts.PriceChild, ts.PriceInfant, ts.Transportation, ts.Status, ts.CreatedAt, "
                   + "ts.GuideID, ts.TourStatus, "
                   + "u.Email, u.FullName, u.PhoneNumber, "
                   + "up.AvatarURL "
                   + "FROM TourSchedule ts "
                   + "LEFT JOIN [User] u ON ts.GuideID = u.UserID "
                   + "LEFT JOIN UserProfile up ON u.UserID = up.UserID "
                   + "WHERE ts.TourID = ? AND ts.DepartureDate >= CAST(GETDATE() AS DATE) "
                   + "ORDER BY ts.DepartureDate ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            // Truyền ID tour vào tham số truy vấn
            ps.setInt(1, tourId);
            try (ResultSet rs = ps.executeQuery()) {
                // Duyệt qua từng bản ghi lịch trình
                while (rs.next()) {
                    TourSchedule sched = new TourSchedule(
                        rs.getInt("ScheduleID"),
                        rs.getInt("TourID"),
                        rs.getDate("DepartureDate"),
                        rs.getDate("ReturnDate"),
                        rs.getInt("TotalSeats"),
                        rs.getInt("AvailableSeats"),
                        rs.getDouble("PriceAdult"),
                        rs.getDouble("PriceChild"),
                        rs.getDouble("PriceInfant"),
                        rs.getString("Transportation"),
                        rs.getString("Status"),
                        rs.getTimestamp("CreatedAt")
                    );
                    
                    // Đọc ID của Hướng dẫn viên du lịch
                    int guideId = rs.getInt("GuideID");
                    // rs.wasNull() kiểm tra xem cột GuideID vừa đọc có giá trị NULL hay không (chưa được phân công HDV)
                    if (!rs.wasNull()) {
                        sched.setGuideId(guideId);
                        sched.setTourStatus(rs.getString("TourStatus"));
                        
                        // Nếu đã được phân công HDV, khởi tạo đối tượng User và nạp thông tin tên, email, sđt
                        User u = new User();
                        u.setUserId(guideId);
                        u.setEmail(rs.getString("Email"));
                        u.setFullName(rs.getString("FullName"));
                        u.setPhoneNumber(rs.getString("PhoneNumber"));
                        
                        // Đọc avatar của HDV từ bảng UserProfile
                        UserProfile up = new UserProfile();
                        up.setUserId(guideId);
                        up.setAvatarUrl(rs.getString("AvatarURL"));
                        u.setProfile(up);
                        
                        // Gán đối tượng HDV hoàn thiện vào lịch trình
                        sched.setGuide(u);
                    }
                    // Thêm lịch trình khởi hành vào list
                    list.add(sched);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    private List<TourMedia> getMediaForTour(int tourId, boolean onlyFirst) {
        List<TourMedia> list = new ArrayList<>();
        String sql = "SELECT MediaID, TourID, MediaURL, MediaType, Caption, SortOrder, IsVisible FROM TourMedia "
                   + "WHERE TourID = ? AND IsVisible = 1 ORDER BY SortOrder ASC";
        if (onlyFirst) {
            sql = "SELECT TOP 1 MediaID, TourID, MediaURL, MediaType, Caption, SortOrder, IsVisible FROM TourMedia "
                 + "WHERE TourID = ? AND IsVisible = 1 ORDER BY SortOrder ASC";
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, tourId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TourMedia media = new TourMedia();
                    media.setMediaId(rs.getInt("MediaID"));
                    media.setTourId(rs.getInt("TourID"));
                    media.setMediaUrl(rs.getString("MediaURL"));
                    media.setMediaType(rs.getString("MediaType"));
                    media.setCaption(rs.getString("Caption"));
                    media.setSortOrder(rs.getInt("SortOrder"));
                    media.setIsVisible(rs.getBoolean("IsVisible"));
                    list.add(media);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    private Tour mapTour(ResultSet rs) throws SQLException {
        Tour tour = new Tour();
        tour.setTourId(rs.getInt("TourID"));
        tour.setCategoryId(rs.getInt("CategoryID"));
        tour.setTourName(rs.getString("TourName"));
        tour.setDescription(rs.getString("Description"));
        tour.setDestination(rs.getString("Destination"));
        tour.setDurationDays(rs.getInt("DurationDays"));
        tour.setItinerary(rs.getString("Itinerary"));
        tour.setDifficultyLevel(rs.getString("DifficultyLevel"));
        tour.setBasePrice(rs.getDouble("BasePrice"));
        tour.setMaxParticipants(rs.getInt("MaxParticipants"));
        tour.setStatus(rs.getString("Status"));
        tour.setIsFeatured(rs.getBoolean("IsFeatured"));
        tour.setIsDeleted(rs.getBoolean("IsDeleted"));
        
        tour.setLanguages(rs.getString("Languages"));
        tour.setGroupSizeMin(rs.getInt("GroupSizeMin"));
        tour.setGroupSizeMax(rs.getInt("GroupSizeMax"));
        tour.setDepartureCity(rs.getString("DepartureCity"));
        tour.setLatitude(rs.getObject("Latitude") != null ? rs.getDouble("Latitude") : null);
        tour.setLongitude(rs.getObject("Longitude") != null ? rs.getDouble("Longitude") : null);
        tour.setVideoUrl(rs.getString("VideoURL"));
        
        double avgRating = rs.getDouble("AvgRating");
        int reviewCount = rs.getInt("ReviewCount");
        tour.setRating(reviewCount > 0 ? avgRating : 0.0);
        tour.setReviewsCount(reviewCount);
        
        // Người làm đoạn này: Dương
        // Lấy thông tin bổ sung về số ghế và ngày khởi hành tiếp theo (nếu có trong ResultSet).
        if (columnExists(rs, "TotalSeats")) {
            tour.setTotalSeats(rs.getInt("TotalSeats"));
        }
        if (columnExists(rs, "AvailableSeats")) {
            tour.setAvailableSeats(rs.getInt("AvailableSeats"));
        }
        if (columnExists(rs, "NextDeparture")) {
            java.sql.Date nextDep = rs.getDate("NextDeparture");
            tour.setNextDeparture(nextDep != null ? nextDep.toString() : "");
        }

        
        tour.setCreatedBy(rs.getObject("CreatedBy") != null ? rs.getInt("CreatedBy") : null);
        tour.setCreatedAt(rs.getTimestamp("CreatedAt"));
        tour.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        return tour;
    }

    /**
     * Kiểm tra một cột có tồn tại trong ResultSet hay không (dùng cho việc map linh hoạt).
     * Tránh lỗi SQLException khi truy vấn không SELECT cột đó.
     */
    private boolean columnExists(ResultSet rs, String columnName) {
        try {
            rs.findColumn(columnName);
            return true;
        } catch (SQLException e) {
            return false;
        }
    }

    /**
     * TRUY VẤN LỊCH TRÌNH CHI TIẾT TỪNG NGÀY (ITINERARY) CỦA TOUR
     * @param tourId ID của tour cần lấy lịch trình
     * @return Danh sách đối tượng TourItinerary sắp xếp tăng dần theo DayNumber và SortOrder
     */
    public List<TourItinerary> getItineraryByTourId(int tourId) {
        List<TourItinerary> list = new ArrayList<>();
        String sql = "SELECT ItineraryID, TourID, DayNumber, Title, ShortDescription, Description, Activities, Meals, Accommodation, ImageURL, SortOrder, CreatedAt, UpdatedAt "
                   + "FROM TourItinerary WHERE TourID = ? ORDER BY DayNumber ASC, SortOrder ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, tourId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TourItinerary item = new TourItinerary();
                    item.setItineraryId(rs.getInt("ItineraryID"));
                    item.setTourId(rs.getInt("TourID"));
                    item.setDayNumber(rs.getInt("DayNumber"));
                    item.setTitle(rs.getString("Title"));
                    item.setShortDescription(rs.getString("ShortDescription"));
                    item.setDescription(rs.getString("Description"));
                    item.setActivities(rs.getString("Activities"));
                    item.setMeals(rs.getString("Meals"));
                    item.setAccommodation(rs.getString("Accommodation"));
                    item.setImageUrl(rs.getString("ImageURL"));
                    item.setSortOrder(rs.getInt("SortOrder"));
                    item.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    item.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                    list.add(item);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    /**
     * Đồng bộ hóa dữ liệu lịch trình chi tiết từng ngày (TourItinerary) từ chuỗi văn bản Outline.
     * Phương thức này sẽ xóa các dòng cũ và phân tích chuỗi văn bản dòng-by-dòng để lưu mới.
     * @param tourId ID của tour cần đồng bộ
     * @param itineraryText Chuỗi văn bản mô tả lịch trình (tách biệt bằng dấu xuống dòng)
     */
    public void syncTourItineraryFromText(int tourId, String itineraryText) {
        // Bước 1: Xóa tất cả các bản ghi lịch trình chi tiết cũ của TourID này
        // Việc xóa này để dọn sạch dữ liệu cũ trước khi đồng bộ dữ liệu mới từ ô nhập liệu của Admin
        String deleteSql = "DELETE FROM TourItinerary WHERE TourID = ?";
        try (PreparedStatement ps = connection.prepareStatement(deleteSql)) {
            ps.setInt(1, tourId);
            ps.executeUpdate();
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, "syncTourItineraryFromText delete failed", ex);
        }

        // Nếu chuỗi text lịch trình trống rỗng thì kết thúc luôn không làm gì tiếp
        if (itineraryText == null || itineraryText.trim().isEmpty()) {
            return;
        }

        // Bước 2: Phân tách chuỗi văn bản theo dấu xuống dòng để lấy từng ngày lịch trình
        String[] lines = itineraryText.split("\\n");
        // Câu lệnh SQL để chèn một dòng lịch trình chi tiết mới vào DB
        String insertSql = "INSERT INTO TourItinerary (TourID, DayNumber, Title, ShortDescription, Description, Activities, Meals, Accommodation, ImageURL, SortOrder) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        // Khởi tạo regex pattern để nhận diện số ngày (Ví dụ: "Ngày 1: Khởi hành", "Day 2 - Tham quan")
        java.util.regex.Pattern dayPattern = java.util.regex.Pattern.compile("^(?:ngày|day)\\s+(\\d+)", java.util.regex.Pattern.CASE_INSENSITIVE);
        int dayCount = 1;
        
        // Duyệt qua từng dòng văn bản lịch trình
        for (int i = 0; i < lines.length; i++) {
            String line = lines[i].trim();
            // Bỏ qua dòng trống
            if (line.isEmpty()) {
                continue;
            }

            // Mặc định số ngày sẽ là số thứ tự tăng dần (nếu dòng text không chỉ rõ Ngày mấy)
            int currentDay = dayCount;
            java.util.regex.Matcher matcher = dayPattern.matcher(line);
            
            // Nếu tìm thấy chữ "Ngày X" hoặc "Day X" ở đầu dòng
            if (matcher.find()) {
                try {
                    // Ép kiểu số ngày (X) thành kiểu int
                    currentDay = Integer.parseInt(matcher.group(1));
                    // Cắt bỏ phần "Ngày X" ra khỏi chuỗi để lấy phần nội dung đằng sau
                    line = line.substring(matcher.end()).trim();
                    // Loại bỏ dấu hai chấm hoặc gạch ngang thừa ở đầu chuỗi (ví dụ: ": Khởi hành" -> "Khởi hành")
                    if (line.startsWith(":") || line.startsWith("-")) {
                        line = line.substring(1).trim();
                    }
                } catch (NumberFormatException e) {
                    // Nếu lỗi ép kiểu, giữ nguyên giá trị dayCount tự tăng làm mặc định
                }
            }

            // Mặc định toàn bộ dòng text là Tiêu đề
            String title = line;
            String desc = "";
            
            // Tách Tiêu đề (Title) và Mô tả (Description) qua dấu hai chấm (:) hoặc gạch ngang (-) nếu có
            if (line.contains(":")) {
                int colonIdx = line.indexOf(":");
                title = line.substring(0, colonIdx).trim();
                desc = line.substring(colonIdx + 1).trim();
            } else if (line.contains("-")) {
                int dashIdx = line.indexOf("-");
                title = line.substring(0, dashIdx).trim();
                desc = line.substring(dashIdx + 1).trim();
            }

            // Quy tắc tự động gán tên Icon (Sparkles, Plane, Hotel, Ship...) dựa theo các từ khóa xuất hiện trong Tiêu đề hoặc Mô tả
            // Tên Icon này sẽ được lưu tạm vào cột ImageURL để detail.jsp hiển thị đúng icon Lucide tương ứng.
            String iconName = "activity";
            String tL = title.toLowerCase();
            String dL = desc.toLowerCase();
            if (tL.contains("bay") || tL.contains("plane") || tL.contains("tiễn") || tL.contains("sân bay") || dL.contains("sân bay")) {
                iconName = "plane";
            } else if (tL.contains("tàu") || tL.contains("boat") || tL.contains("cruise") || tL.contains("du thuyền") || tL.contains("canô") || dL.contains("du thuyền")) {
                iconName = "ship";
            } else if (tL.contains("leo") || tL.contains("trek") || tL.contains("chinh phục") || tL.contains("đỉnh") || tL.contains("núi") || dL.contains("leo núi")) {
                iconName = "mountain";
            } else if (tL.contains("khách sạn") || tL.contains("hotel") || tL.contains("resort") || tL.contains("nhận phòng") || dL.contains("khách sạn")) {
                iconName = "hotel";
            } else if (tL.contains("chụp ảnh") || tL.contains("check") || tL.contains("quay") || dL.contains("chụp ảnh")) {
                iconName = "camera";
            } else if (tL.contains("tự do") || tL.contains("free") || tL.contains("vui chơi") || dL.contains("vui chơi")) {
                iconName = "sparkles";
            } else if (tL.contains("đón") || tL.contains("chào")) {
                iconName = "map-pin";
            }

            // Tiến hành chèn bản ghi lịch trình chi tiết ngày này vào Database
            try (PreparedStatement ps = connection.prepareStatement(insertSql)) {
                ps.setInt(1, tourId);
                ps.setInt(2, currentDay);
                ps.setString(3, title);
                ps.setString(4, null); // Cột ShortDescription để trống
                ps.setString(5, desc);  // Cột Description lưu mô tả chi tiết của ngày
                ps.setString(6, null); // Cột Activities để trống
                ps.setString(7, null); // Cột Meals để trống
                ps.setString(8, null); // Cột Accommodation để trống
                ps.setString(9, iconName); // Lưu tên icon vào cột ImageURL
                ps.setInt(10, i); // Thứ tự sắp xếp (SortOrder) theo thứ tự dòng text nhập vào
                
                ps.executeUpdate();
            } catch (SQLException ex) {
                Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, "syncTourItineraryFromText insert failed", ex);
            }
            
            // Tăng biến đếm ngày lên 1
            dayCount++;
        }
    }

    /**
     * TRUY VẤN CÁC DỊCH VỤ ĐI KÈM TOUR (INCLUSIONS/EXCLUSIONS)
     * @param tourId ID của tour cần lấy dịch vụ
     * @return Danh sách các đối tượng TourInclusion của tour
     */
    public List<TourInclusion> getInclusionsByTourId(int tourId) {
        List<TourInclusion> list = new ArrayList<>();
        String sql = "SELECT InclusionID, TourID, InclusionType, ServiceName, IconName, SortOrder, IsActive, CreatedAt "
                   + "FROM TourInclusion WHERE TourID = ? AND IsActive = 1 ORDER BY SortOrder ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, tourId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TourInclusion item = new TourInclusion();
                    item.setInclusionId(rs.getInt("InclusionID"));
                    item.setTourId(rs.getInt("TourID"));
                    item.setInclusionType(rs.getString("InclusionType"));
                    item.setServiceName(rs.getString("ServiceName"));
                    item.setDescription(null);
                    item.setIconName(rs.getString("IconName"));
                    item.setSortOrder(rs.getInt("SortOrder"));
                    item.setIsActive(rs.getBoolean("IsActive"));
                    item.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    list.add(item);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    /**
     * TRUY VẤN BỘ CÂU HỎI THƯỜNG GẶP (FAQs) CỦA TOUR
     * @param tourId ID của tour
     * @return Danh sách các câu hỏi & câu trả lời (TourFAQ) đang hoạt động (IsActive = 1)
     */
    public List<TourFAQ> getFaqsByTourId(int tourId) {
        List<TourFAQ> list = new ArrayList<>();
        String sql = "SELECT FAQID, TourID, Question, Answer, SortOrder, IsActive, CreatedAt "
                   + "FROM TourFAQ WHERE TourID = ? AND IsActive = 1 ORDER BY SortOrder ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, tourId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TourFAQ item = new TourFAQ();
                    item.setFaqId(rs.getInt("FAQID"));
                    item.setTourId(rs.getInt("TourID"));
                    item.setQuestion(rs.getString("Question"));
                    item.setAnswer(rs.getString("Answer"));
                    item.setSortOrder(rs.getInt("SortOrder"));
                    item.setIsActive(rs.getBoolean("IsActive"));
                    item.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    list.add(item);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    public List<DestinationInfo> getTopDestinations() {
        List<DestinationInfo> list = new ArrayList<>();
        String sql = "SELECT Destination, COUNT(*) as TourCount FROM Tour WHERE Status = 'Active' AND IsDeleted = 0 GROUP BY Destination";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String fullDest = rs.getString("Destination");
                int count = rs.getInt("TourCount");
                
                String name = fullDest;
                if (fullDest.contains(",")) {
                    name = fullDest.split(",")[0].trim();
                }
                
                String imgUrl = "assets/images/tour_halong.png";
                String lowerName = name.toLowerCase();
                if (lowerName.contains("đà nẵng")) imgUrl = "assets/images/tour_danang.png";
                else if (lowerName.contains("phú quốc")) imgUrl = "assets/images/tour_phuquoc.png";
                else if (lowerName.contains("hạ long")) imgUrl = "assets/images/tour_halong.png";
                else if (lowerName.contains("hội an")) imgUrl = "assets/images/tour_hoian.png";
                else if (lowerName.contains("đà lạt")) imgUrl = "assets/images/tour_dalat.png";
                else if (lowerName.contains("sa pa") || lowerName.contains("sapa")) imgUrl = "assets/images/tour_sapa.png";
                else if (lowerName.contains("nha trang")) imgUrl = "assets/images/tour_nhatrang.png";
                else if (lowerName.contains("hà giang")) imgUrl = "assets/images/tour_hagiang.png";
                
                boolean exists = false;
                for (DestinationInfo d : list) {
                    if (d.getName().equalsIgnoreCase(name)) {
                        d.setTourCount(d.getTourCount() + count);
                        exists = true;
                        break;
                    }
                }
                if (!exists) {
                    list.add(new DestinationInfo(name, count, imgUrl));
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    /**
     * Truy vấn danh sách đánh giá (Reviews) của một Tour cụ thể từ cơ sở dữ liệu.
     * @param tourId ID của tour cần lấy đánh giá
     * @return danh sách các đối tượng Review của tour đó, sắp xếp theo thời gian mới nhất lên đầu.
     */
    public List<Review> getReviewsByTourId(int tourId) {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT r.ReviewID, r.TourID, r.BookingID, r.CustomerID, r.Rating, r.Content, r.IsVisible, r.CreatedAt, r.UpdatedAt, r.ImageURL, "
                   + "u.FullName, p.AvatarURL, "
                   + "CASE WHEN b.Status = 'Completed' THEN 1 ELSE 0 END as IsVerified "
                   + "FROM Review r "
                   + "JOIN [User] u ON r.CustomerID = u.UserID "
                   + "LEFT JOIN UserProfile p ON u.UserID = p.UserID "
                   + "LEFT JOIN Booking b ON r.BookingID = b.BookingID "
                   + "WHERE r.TourID = ? AND r.IsVisible = 1 "
                   + "ORDER BY r.CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, tourId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review rev = new Review();
                    rev.setReviewId(rs.getInt("ReviewID"));
                    rev.setTourId(rs.getInt("TourID"));
                    rev.setBookingId(rs.getInt("BookingID"));
                    rev.setCustomerId(rs.getInt("CustomerID"));
                    rev.setRating(rs.getInt("Rating"));
                    rev.setContent(rs.getString("Content"));
                    rev.setIsVisible(rs.getBoolean("IsVisible"));
                    rev.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    rev.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                    rev.setImageUrl(rs.getString("ImageURL"));
                    rev.setCustomerName(rs.getString("FullName"));
                    rev.setCustomerAvatar(rs.getString("AvatarURL"));
                    rev.setIsVerified(rs.getBoolean("IsVerified"));
                    list.add(rev);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    /**
     * Thêm mới một Đánh giá của khách hàng vào database.
     * @param name Họ tên người đánh giá nhập vào form
     * @param email Email người đánh giá nhập vào form
     * @param tourId ID của tour đang được đánh giá
     * @param rating Số sao (từ 1 đến 5)
     * @param content Nội dung bình luận
     * @return true nếu lưu thành công, ngược lại trả về false.
     */
    public boolean insertReview(String name, String email, int tourId, int rating, String content) {
        return insertReview(name, email, tourId, rating, content, null);
    }

    public boolean insertReview(String name, String email, int tourId, int rating, String content, String imageUrl) {
        int userId = -1;
        // Bước 1: Tìm xem email của người review đã tồn tại trong DB chưa
        String findUserSql = "SELECT UserID FROM [User] WHERE Email = ?";
        try (PreparedStatement ps = connection.prepareStatement(findUserSql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    userId = rs.getInt("UserID");
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        // Nếu không có tài khoản ứng với email này -> Trả về false luôn vì chưa mua/chưa đi tour
        if (userId == -1) {
            return false;
        }

        // Bước 1.5: Kiểm tra xem tài khoản này đã từng đánh giá tour này chưa (chống trùng lặp)
        String checkReviewSql = "SELECT COUNT(*) FROM Review WHERE CustomerID = ? AND TourID = ?";
        try (PreparedStatement ps = connection.prepareStatement(checkReviewSql)) {
            ps.setInt(1, userId);
            ps.setInt(2, tourId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return false;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        // Bước 2: Tìm booking thỏa mãn điều kiện đã hoàn thành (Status = 'Completed') của tour này
        int bookingId = -1;
        String findBookingSql = "SELECT b.BookingID FROM Booking b JOIN TourSchedule s ON b.ScheduleID = s.ScheduleID WHERE b.CustomerID = ? AND s.TourID = ? AND b.Status = 'Completed'";
        try (PreparedStatement ps = connection.prepareStatement(findBookingSql)) {
            ps.setInt(1, userId);
            ps.setInt(2, tourId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    bookingId = rs.getInt("BookingID");
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        // Nếu không tìm thấy bất kỳ booking nào ở trạng thái Completed -> Từ chối đánh giá
        if (bookingId == -1) {
            return false;
        }
        
        // Bước 3: Chèn trực tiếp đánh giá vào bảng Review
        String insertReviewSql = "INSERT INTO Review (TourID, BookingID, CustomerID, Rating, Content, IsVisible, CreatedAt, UpdatedAt, ImageURL) VALUES (?, ?, ?, ?, ?, 1, SYSDATETIME(), SYSDATETIME(), ?)";
        try (PreparedStatement ps = connection.prepareStatement(insertReviewSql)) {
            ps.setInt(1, tourId);
            ps.setInt(2, bookingId);
            ps.setInt(3, userId);
            ps.setInt(4, rating);
            ps.setString(5, content);
            ps.setString(6, imageUrl);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
            return false;
        }
    }

    /**
     * Lấy danh sách các đánh giá hàng đầu (Rating >= 4) từ cơ sở dữ liệu để hiển thị ở trang chủ.
     */
    public List<Review> getTopReviews(int limit) {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT TOP (?) r.ReviewID, r.TourID, r.BookingID, r.CustomerID, r.Rating, r.Content, r.CreatedAt, "
                   + "u.FullName, p.AvatarURL "
                   + "FROM Review r "
                   + "INNER JOIN [User] u ON r.CustomerID = u.UserID "
                   + "LEFT JOIN UserProfile p ON u.UserID = p.UserID "
                   + "WHERE r.IsVisible = 1 AND r.Rating >= 4 "
                   + "ORDER BY r.CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review r = new Review();
                    r.setReviewId(rs.getInt("ReviewID"));
                    r.setTourId(rs.getInt("TourID"));
                    r.setBookingId(rs.getInt("BookingID"));
                    r.setCustomerId(rs.getInt("CustomerID"));
                    r.setRating(rs.getInt("Rating"));
                    r.setContent(rs.getString("Content"));
                    r.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    r.setCustomerName(rs.getString("FullName"));
                    r.setCustomerAvatar(rs.getString("AvatarURL"));
                    list.add(r);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    /**
     * Lấy danh sách các mã giảm giá đang hoạt động và còn thời hạn từ cơ sở dữ liệu.
     */
    public List<Coupon> getActiveCoupons(int limit) {
        List<Coupon> list = new ArrayList<>();
        String sql = "SELECT TOP (?) CouponID, CouponCode, DiscountType, DiscountValue, MinOrderAmount, MaxUses, UsedCount, StartDate, EndDate, IsActive, CreatedBy, CreatedAt "
                   + "FROM Coupon "
                   + "WHERE IsActive = 1 "
                   + "AND StartDate <= CAST(GETDATE() AS DATE) "
                   + "AND EndDate >= CAST(GETDATE() AS DATE) "
                   + "ORDER BY CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Coupon c = new Coupon();
                    c.setCouponId(rs.getInt("CouponID"));
                    c.setCouponCode(rs.getString("CouponCode"));
                    c.setDiscountType(rs.getString("DiscountType"));
                    c.setDiscountValue(rs.getDouble("DiscountValue"));
                    c.setMinOrderAmount(rs.getDouble("MinOrderAmount"));
                    
                    int maxUses = rs.getInt("MaxUses");
                    c.setMaxUses(rs.wasNull() ? null : maxUses);
                    
                    c.setUsedCount(rs.getInt("UsedCount"));
                    c.setStartDate(rs.getDate("StartDate"));
                    c.setEndDate(rs.getDate("EndDate"));
                    c.setIsActive(rs.getBoolean("IsActive"));
                    
                    int createdBy = rs.getInt("CreatedBy");
                    c.setCreatedBy(rs.wasNull() ? null : createdBy);
                    
                    c.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    list.add(c);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    public Coupon getCouponByCode(String code) {
        if (code == null || code.trim().isEmpty()) return null;
        String sql = "SELECT CouponID, CouponCode, DiscountType, DiscountValue, MinOrderAmount, MaxUses, UsedCount, StartDate, EndDate, IsActive, CreatedBy, CreatedAt "
                   + "FROM Coupon "
                   + "WHERE CouponCode = ? AND IsActive = 1 "
                   + "AND StartDate <= CAST(GETDATE() AS DATE) "
                   + "AND EndDate >= CAST(GETDATE() AS DATE)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Coupon c = new Coupon();
                    c.setCouponId(rs.getInt("CouponID"));
                    c.setCouponCode(rs.getString("CouponCode"));
                    c.setDiscountType(rs.getString("DiscountType"));
                    c.setDiscountValue(rs.getDouble("DiscountValue"));
                    c.setMinOrderAmount(rs.getDouble("MinOrderAmount"));
                    
                    int maxUses = rs.getInt("MaxUses");
                    c.setMaxUses(rs.wasNull() ? null : maxUses);
                    
                    c.setUsedCount(rs.getInt("UsedCount"));
                    c.setStartDate(rs.getDate("StartDate"));
                    c.setEndDate(rs.getDate("EndDate"));
                    c.setIsActive(rs.getBoolean("IsActive"));
                    
                    int createdBy = rs.getInt("CreatedBy");
                    c.setCreatedBy(rs.wasNull() ? null : createdBy);
                    
                    c.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    return c;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    public List<String> getDistinctDestinations() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT Destination FROM Tour WHERE Status = 'Active' AND IsDeleted = 0";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String dest = rs.getString("Destination");
                if (dest != null && !dest.trim().isEmpty()) {
                    String clean = dest.split(",")[0].trim();
                    if (!list.contains(clean)) {
                        list.add(clean);
                    }
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    public List<String> getDistinctDepartureCities() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT DepartureCity FROM Tour WHERE Status = 'Active' AND IsDeleted = 0";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String city = rs.getString("DepartureCity");
                if (city != null && !city.trim().isEmpty()) {
                    if (!list.contains(city)) {
                        list.add(city);
                    }
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    /**
     * Inserts a new Tour into the database.
     * @param tour Tour entity to insert
     * @return generated TourID or -1 if failed
     */
    public int insertTour(Tour tour) {
        String sql = "INSERT INTO Tour (CategoryID, TourName, Description, Destination, DurationDays, Itinerary, DifficultyLevel, BasePrice, MaxParticipants, Status, IsFeatured, Languages, GroupSizeMin, GroupSizeMax, DepartureCity, Latitude, Longitude, VideoURL, CreatedBy, CreatedAt, UpdatedAt) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, tour.getCategoryId());
            ps.setString(2, tour.getTourName());
            ps.setString(3, tour.getDescription());
            ps.setString(4, tour.getDestination());
            ps.setInt(5, tour.getDurationDays());
            ps.setString(6, tour.getItinerary());
            ps.setString(7, tour.getDifficultyLevel());
            ps.setDouble(8, tour.getBasePrice());
            ps.setInt(9, tour.getMaxParticipants());
            ps.setString(10, tour.getStatus() != null ? tour.getStatus() : "Draft");
            ps.setBoolean(11, tour.isIsFeatured());
            ps.setString(12, tour.getLanguages());
            ps.setInt(13, tour.getGroupSizeMin());
            ps.setInt(14, tour.getGroupSizeMax());
            ps.setString(15, tour.getDepartureCity());
            if (tour.getLatitude() != null) ps.setDouble(16, tour.getLatitude()); else ps.setNull(16, java.sql.Types.DOUBLE);
            if (tour.getLongitude() != null) ps.setDouble(17, tour.getLongitude()); else ps.setNull(17, java.sql.Types.DOUBLE);
            ps.setString(18, tour.getVideoUrl());
            if (tour.getCreatedBy() != null) ps.setInt(19, tour.getCreatedBy()); else ps.setNull(19, java.sql.Types.INTEGER);
            
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, "insertTour failed", ex);
        }
        return -1;
    }

    /**
     * Updates an existing Tour in the database.
     * @param tour Tour entity to update
     * @return true if successful, false otherwise
     */
    public boolean updateTour(Tour tour) {
        String sql = "UPDATE Tour SET CategoryID = ?, TourName = ?, Description = ?, Destination = ?, DurationDays = ?, Itinerary = ?, DifficultyLevel = ?, BasePrice = ?, MaxParticipants = ?, Status = ?, IsFeatured = ?, Languages = ?, GroupSizeMin = ?, GroupSizeMax = ?, DepartureCity = ?, Latitude = ?, Longitude = ?, VideoURL = ?, UpdatedAt = GETDATE() "
                   + "WHERE TourID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, tour.getCategoryId());
            ps.setString(2, tour.getTourName());
            ps.setString(3, tour.getDescription());
            ps.setString(4, tour.getDestination());
            ps.setInt(5, tour.getDurationDays());
            ps.setString(6, tour.getItinerary());
            ps.setString(7, tour.getDifficultyLevel());
            ps.setDouble(8, tour.getBasePrice());
            ps.setInt(9, tour.getMaxParticipants());
            ps.setString(10, tour.getStatus());
            ps.setBoolean(11, tour.isIsFeatured());
            ps.setString(12, tour.getLanguages());
            ps.setInt(13, tour.getGroupSizeMin());
            ps.setInt(14, tour.getGroupSizeMax());
            ps.setString(15, tour.getDepartureCity());
            if (tour.getLatitude() != null) ps.setDouble(16, tour.getLatitude()); else ps.setNull(16, java.sql.Types.DOUBLE);
            if (tour.getLongitude() != null) ps.setDouble(17, tour.getLongitude()); else ps.setNull(17, java.sql.Types.DOUBLE);
            ps.setString(18, tour.getVideoUrl());
            ps.setInt(19, tour.getTourId());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, "updateTour failed", ex);
        }
        return false;
    }

    /**
     * Deletes a Tour (hard delete).
     * @param tourId ID of the tour to delete
     * @return true if successful
     */
    public boolean deleteTour(int tourId) {
        String sql = "UPDATE Tour SET Status = 'Inactive', IsDeleted = 1, UpdatedAt = GETDATE() WHERE TourID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, tourId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, "deleteTour failed", ex);
        }
        return false;
    }

    /**
     * Quick update status (Active, Draft, Disabled)
     */
    public boolean updateTourStatus(int tourId, String status) {
        String sql = "UPDATE Tour SET Status = ?, UpdatedAt = GETDATE() WHERE TourID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, tourId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, "updateTourStatus failed", ex);
        }
        return false;
    }

    /**
     * Get all tours for admin panel (including draft, disabled, active)
     */
    public List<Tour> getAllToursAdmin() {
        List<Tour> list = new ArrayList<>();
        String sql = "SELECT t.TourID, t.CategoryID, t.TourName, t.Description, t.Destination, t.DurationDays, t.Itinerary, t.DifficultyLevel, t.BasePrice, t.MaxParticipants, t.Status, t.IsFeatured, t.IsDeleted, t.Languages, t.GroupSizeMin, t.GroupSizeMax, t.DepartureCity, t.Latitude, t.Longitude, t.VideoURL, t.CreatedBy, t.CreatedAt, t.UpdatedAt, "
                   + "ISNULL((SELECT AVG(CAST(Rating AS FLOAT)) FROM Review r WHERE r.TourID = t.TourID), 0.0) as AvgRating, "
                   + "(SELECT COUNT(*) FROM Review r WHERE r.TourID = t.TourID) as ReviewCount, "
                   + "ISNULL((SELECT SUM(TotalSeats) FROM TourSchedule s WHERE s.TourID = t.TourID), t.MaxParticipants) as TotalSeats, "
                   + "ISNULL((SELECT SUM(AvailableSeats) FROM TourSchedule s WHERE s.TourID = t.TourID), t.MaxParticipants) as AvailableSeats, "
                   + "ISNULL((SELECT TOP 1 DepartureDate FROM TourSchedule s WHERE s.TourID = t.TourID AND s.DepartureDate >= CAST(GETDATE() AS DATE) ORDER BY DepartureDate ASC), "
                   + "        (SELECT TOP 1 DepartureDate FROM TourSchedule s WHERE s.TourID = t.TourID ORDER BY DepartureDate ASC)) as NextDeparture, "
                   + "c.CategoryName, c.Description AS CategoryDesc "
                   + "FROM Tour t "
                   + "JOIN TourCategory c ON t.CategoryID = c.CategoryID "
                   + "WHERE t.IsDeleted = 0 "
                   + "ORDER BY t.TourID DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Tour tour = mapTour(rs);
                TourCategory cat = new TourCategory();
                cat.setCategoryId(rs.getInt("CategoryID"));
                cat.setCategoryName(rs.getString("CategoryName"));
                cat.setDescription(rs.getString("CategoryDesc"));
                tour.setCategory(cat);
                list.add(tour);
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, "getAllToursAdmin failed", ex);
        }
        return list;
    }

    /**
     * Get monthly revenue for the last 6 months dynamically from Booking table
     */
    public double[] getMonthlyRevenueLast6Months() {
        double[] revenue = new double[6];
        java.util.Calendar cal = java.util.Calendar.getInstance();
        int currentMonth = cal.get(java.util.Calendar.MONTH) + 1;
        int currentYear = cal.get(java.util.Calendar.YEAR);
        
        String sql = "SELECT MONTH(CreatedAt) as MonthVal, YEAR(CreatedAt) as YearVal, SUM(TotalAmount) as Total "
                   + "FROM Booking "
                   + "WHERE Status NOT IN ('Cancelled', 'Failed', 'Refunded') AND CreatedAt >= DATEADD(month, -5, GETDATE()) "
                   + "GROUP BY YEAR(CreatedAt), MONTH(CreatedAt)";
                   
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int m = rs.getInt("MonthVal");
                int y = rs.getInt("YearVal");
                double total = rs.getDouble("Total");
                
                int diff = (currentYear - y) * 12 + (currentMonth - m);
                if (diff >= 0 && diff < 6) {
                    revenue[5 - diff] = total;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, "getMonthlyRevenueLast6Months failed", ex);
        }
        return revenue;
    }

    /**
     * Get total all-time revenue from all non-cancelled bookings.
     * Includes PendingPayment (holds), Success, Confirmed, Completed.
     * Excludes only Cancelled, Failed, Refunded.
     */
    public long getTotalRevenue() {
        String sql = "SELECT ISNULL(SUM(TotalAmount), 0) as Total FROM Booking "
                   + "WHERE Status NOT IN ('Cancelled', 'Failed', 'Refunded')";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getLong("Total");
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, "getTotalRevenue failed", ex);
        }
        return 0L;
    }

    /**
     * Delete and insert batch of inclusions for a tour to synchronize them.
     */
    public boolean saveTourInclusions(int tourId, List<TourInclusion> inclusions) {
        // 1. Delete existing inclusions
        String deleteSql = "DELETE FROM TourInclusion WHERE TourID = ?";
        try (PreparedStatement psDel = connection.prepareStatement(deleteSql)) {
            psDel.setInt(1, tourId);
            psDel.executeUpdate();
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, "delete existing inclusions failed", ex);
            return false;
        }
        
        // 2. Insert new inclusions if any
        if (inclusions == null || inclusions.isEmpty()) {
            return true;
        }
        
        String insertSql = "INSERT INTO TourInclusion (TourID, InclusionType, ServiceName, IconName, SortOrder, IsActive, CreatedAt) VALUES (?, ?, ?, ?, ?, 1, GETDATE())";
        try (PreparedStatement psIns = connection.prepareStatement(insertSql)) {
            for (TourInclusion item : inclusions) {
                psIns.setInt(1, tourId);
                psIns.setString(2, item.getInclusionType());
                psIns.setString(3, item.getServiceName());
                psIns.setString(4, item.getIconName() != null ? item.getIconName() : "sparkles");
                psIns.setInt(5, item.getSortOrder());
                psIns.addBatch();
            }
            psIns.executeBatch();
            return true;
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, "insert batch inclusions failed", ex);
            return false;
        }
    }
}
