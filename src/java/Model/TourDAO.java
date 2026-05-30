package Model;

import Entities.Tour;
import Entities.TourCategory;
import Entities.TourMedia;
import Entities.TourSchedule;
import Entities.TourItinerary;
import Entities.TourInclusion;
import Entities.TourFAQ;
// import Entities.Review; (Tạm thời đóng lại khi xóa screen TourDetail)
import Entities.DestinationInfo;
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
        List<TourCategory> list = new ArrayList<>();
        String sql = "SELECT CategoryID, CategoryName, Description, IsActive FROM TourCategory WHERE IsActive = 1";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                TourCategory cat = new TourCategory(
                    rs.getInt("CategoryID"),
                    rs.getString("CategoryName"),
                    rs.getString("Description"),
                    rs.getBoolean("IsActive")
                );
                list.add(cat);
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    /**
     * Retrieves featured tours.
     * @return list of featured Tour objects
     */
    public List<Tour> getFeaturedTours() {
        List<Tour> list = new ArrayList<>();
        String sql = "SELECT TourID, CategoryID, TourName, Description, Destination, DurationDays, Itinerary, DifficultyLevel, BasePrice, MaxParticipants, Status, IsFeatured, Languages, GroupSizeMin, GroupSizeMax, DepartureCity, Latitude, Longitude, VideoURL, CreatedBy, CreatedAt, UpdatedAt, "
                   + "ISNULL((SELECT AVG(CAST(Rating AS FLOAT)) FROM Review r WHERE r.TourID = Tour.TourID), 4.8) as AvgRating, "
                   + "(SELECT COUNT(*) FROM Review r WHERE r.TourID = Tour.TourID) as ReviewCount "
                   + "FROM Tour WHERE IsFeatured = 1 AND Status = 'Active'";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Tour tour = mapTour(rs);
                // Load one thumbnail/image for listing
                tour.setMediaList(getMediaForTour(tour.getTourId(), true));
                list.add(tour);
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
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
        
        // Base Query
        StringBuilder sql = new StringBuilder(
            "SELECT DISTINCT t.TourID, t.CategoryID, t.TourName, t.Description, t.Destination, t.DurationDays, t.Itinerary, t.DifficultyLevel, t.BasePrice, t.MaxParticipants, t.Status, t.IsFeatured, t.Languages, t.GroupSizeMin, t.GroupSizeMax, t.DepartureCity, t.Latitude, t.Longitude, t.VideoURL, t.CreatedBy, t.CreatedAt, t.UpdatedAt, " +
            "ISNULL((SELECT AVG(CAST(Rating AS FLOAT)) FROM Review r WHERE r.TourID = t.TourID), 4.8) as AvgRating, " +
            "(SELECT COUNT(*) FROM Review r WHERE r.TourID = t.TourID) as ReviewCount " +
            "FROM Tour t " +
            "LEFT JOIN TourSchedule s ON t.TourID = s.TourID " +
            "WHERE t.Status = 'Active'"
        );
        
        List<Object> params = new ArrayList<>();
        
        if (destination != null && !destination.trim().isEmpty()) {
            sql.append(" AND t.Destination LIKE ?");
            params.add("%" + destination.trim() + "%");
        }
        
        if (categoryId != null) {
            sql.append(" AND t.CategoryID = ?");
            params.add(categoryId);
        }
        
        if (maxPrice != null) {
            sql.append(" AND t.BasePrice <= ?");
            params.add(maxPrice);
        }
        
        if (departureDate != null && !departureDate.trim().isEmpty()) {
            sql.append(" AND s.DepartureDate >= ? AND s.Status = 'Open'");
            params.add(java.sql.Date.valueOf(departureDate));
        }

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Tour tour = mapTour(rs);
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
        String sql = "SELECT t.TourID, t.CategoryID, t.TourName, t.Description, t.Destination, t.DurationDays, t.Itinerary, t.DifficultyLevel, t.BasePrice, t.MaxParticipants, t.Status, t.IsFeatured, t.Languages, t.GroupSizeMin, t.GroupSizeMax, t.DepartureCity, t.Latitude, t.Longitude, t.VideoURL, t.CreatedBy, t.CreatedAt, t.UpdatedAt, "
                   + "ISNULL((SELECT AVG(CAST(Rating AS FLOAT)) FROM Review r WHERE r.TourID = t.TourID), 4.8) as AvgRating, "
                   + "(SELECT COUNT(*) FROM Review r WHERE r.TourID = t.TourID) as ReviewCount, "
                   + "c.CategoryName, c.Description AS CategoryDesc "
                   + "FROM Tour t "
                   + "JOIN TourCategory c ON t.CategoryID = c.CategoryID "
                   + "WHERE t.TourID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, tourId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Tour tour = mapTour(rs);
                    
                    TourCategory cat = new TourCategory();
                    cat.setCategoryId(rs.getInt("CategoryID"));
                    cat.setCategoryName(rs.getString("CategoryName"));
                    cat.setDescription(rs.getString("CategoryDesc"));
                    tour.setCategory(cat);
                    
                    // Nạp danh sách hình ảnh/video của tour từ bảng TourMedia để cấp cho slideshow ảnh ở đầu trang detail.jsp.
                    tour.setMediaList(getMediaForTour(tourId, false));
                    
                    // Nạp danh sách các đợt khởi hành còn chỗ trong tương lai từ bảng TourSchedule để tính toán số ghế trống và giá ở sidebar.
                    tour.setSchedules(getSchedulesByTourId(tourId));
                    
                    // Nạp lịch trình đi cụ thể từng ngày từ bảng TourItinerary để hiển thị sơ đồ Timeline động ở thân trang.
                    tour.setItineraries(getItineraryByTourId(tourId));
                    
                    // Nạp danh sách dịch vụ bao gồm (Included) và loại trừ (Excluded) từ bảng TourInclusion.
                    tour.setInclusions(getInclusionsByTourId(tourId));
                    
                    // Nạp danh sách câu hỏi thường gặp FAQ từ bảng TourFAQ phục vụ Accordion ở cuối trang.
                    tour.setFaqs(getFaqsByTourId(tourId));
                    
                    // Nạp tất cả các bình luận, đánh giá và số sao thực tế từ khách hàng từ bảng Review để hiển thị lên khung nhận xét (Tạm thời đóng lại khi xóa screen TourDetail).
                    // tour.setReviews(getReviewsByTourId(tourId));
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
        List<TourSchedule> list = new ArrayList<>();
        String sql = "SELECT ScheduleID, TourID, DepartureDate, ReturnDate, TotalSeats, AvailableSeats, PriceAdult, PriceChild, PriceInfant, Transportation, Status, CreatedAt "
                   + "FROM TourSchedule WHERE TourID = ? AND DepartureDate >= CAST(GETDATE() AS DATE) ORDER BY DepartureDate ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, tourId);
            try (ResultSet rs = ps.executeQuery()) {
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
        
        tour.setLanguages(rs.getString("Languages"));
        tour.setGroupSizeMin(rs.getInt("GroupSizeMin"));
        tour.setGroupSizeMax(rs.getInt("GroupSizeMax"));
        tour.setDepartureCity(rs.getString("DepartureCity"));
        tour.setLatitude(rs.getObject("Latitude") != null ? rs.getDouble("Latitude") : null);
        tour.setLongitude(rs.getObject("Longitude") != null ? rs.getDouble("Longitude") : null);
        tour.setVideoUrl(rs.getString("VideoURL"));
        
        double avgRating = rs.getDouble("AvgRating");
        int reviewCount = rs.getInt("ReviewCount");
        tour.setRating(reviewCount > 0 ? avgRating : 4.8);
        tour.setReviewsCount(reviewCount > 0 ? reviewCount : 45);
        
        tour.setCreatedBy(rs.getObject("CreatedBy") != null ? rs.getInt("CreatedBy") : null);
        tour.setCreatedAt(rs.getTimestamp("CreatedAt"));
        tour.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        return tour;
    }

    /**
     * TRUY VẤN LỊCH TRÌNH CHI TIẾT TỪNG NGÀY (ITINERARY) CỦA TOUR
     * Lý do tại sao phải viết hàm này:
     * - Để lấy lộ trình đi thực tế của tour (ví dụ: Ngày 1 đi đâu làm gì, Ngày 2 đi đâu...) thay vì dùng dữ liệu tĩnh.
     * - Dữ liệu này sẽ được DetailController nạp, đưa sang detail.jsp và chuyển đổi sang dạng mảng JS window.itinerariesData.
     * - JS (detail.js) sẽ đọc mảng này để vẽ sơ đồ Timeline (trục hành trình) và hiệu ứng đóng mở Accordion tương tác.
     *
     * @param tourId ID của tour cần lấy lịch trình
     * @return Danh sách đối tượng TourItinerary sắp xếp tăng dần theo DayNumber và SortOrder
     */
    public List<TourItinerary> getItineraryByTourId(int tourId) {
        List<TourItinerary> list = new ArrayList<>();
        // Thực hiện SELECT tất cả cột của bảng TourItinerary theo TourID tương ứng
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
     * TRUY VẤN CÁC DỊCH VỤ ĐI KÈM TOUR (INCLUSIONS/EXCLUSIONS)
     * Lý do tại sao phải viết hàm này:
     * - Mỗi tour có các dịch vụ bao gồm (ví dụ: Bảo hiểm, hướng dẫn viên, vé tham quan)
     *   và không bao gồm (ví dụ: Chi phí cá nhân, tiền tip) khác nhau.
     * - Dữ liệu này hiển thị trực quan dưới dạng thẻ (Tab) ở giữa trang detail.jsp.
     * - Phép lọc `IsActive = 1` đảm bảo chỉ hiển thị các dịch vụ đang được cung cấp.
     *
     * @param tourId ID của tour cần lấy dịch vụ
     * @return Danh sách các đối tượng TourInclusion của tour
     */
    public List<TourInclusion> getInclusionsByTourId(int tourId) {
        List<TourInclusion> list = new ArrayList<>();
        // Thực hiện SELECT các dịch vụ hoạt động, sắp xếp theo thứ tự hiển thị SortOrder
        String sql = "SELECT InclusionID, TourID, InclusionType, ServiceName, Description, IconName, SortOrder, IsActive, CreatedAt "
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
                    item.setDescription(rs.getString("Description"));
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
     * Lý do tại sao phải viết hàm này:
     * - Giúp giải đáp ngay thắc mắc của khách hàng về chuyến đi (ví dụ: chính sách hủy tour, trẻ em đi kèm...).
     * - Dữ liệu này hiển thị dưới dạng Accordion (click để thả nội dung trả lời) ở góc dưới detail.jsp.
     *
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
        String sql = "SELECT Destination, COUNT(*) as TourCount FROM Tour WHERE Status = 'Active' GROUP BY Destination";
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

    /* (Tạm thời đóng lại khi xóa screen TourDetail)
    public List<Review> getReviewsByTourId(int tourId) {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT r.ReviewID, r.TourID, r.BookingID, r.CustomerID, r.Rating, r.Content, r.IsVisible, r.CreatedAt, r.UpdatedAt, "
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

    public boolean insertReview(String name, String email, int tourId, int rating, String content) {
        int userId = -1;
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
        
        if (userId == -1) {
            String insertUserSql = "INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified) VALUES (4, ?, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', ?, '', 1, 1)";
            try (PreparedStatement ps = connection.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, email);
                ps.setString(2, name);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        userId = rs.getInt(1);
                    }
                }
                
                String insertProfileSql = "INSERT INTO UserProfile (UserID, AvatarURL) VALUES (?, 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80')";
                try (PreparedStatement ps2 = connection.prepareStatement(insertProfileSql)) {
                    ps2.setInt(1, userId);
                    ps2.executeUpdate();
                }
            } catch (SQLException ex) {
                Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
                return false;
            }
        }
        
        int bookingId = -1;
        String findBookingSql = "SELECT BookingID FROM Booking b JOIN TourSchedule s ON b.ScheduleID = s.ScheduleID WHERE b.CustomerID = ? AND s.TourID = ?";
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
        
        if (bookingId == -1) {
            String fallbackBookingSql = "SELECT TOP 1 BookingID FROM Booking b JOIN TourSchedule s ON b.ScheduleID = s.ScheduleID WHERE s.TourID = ?";
            try (PreparedStatement ps = connection.prepareStatement(fallbackBookingSql)) {
                ps.setInt(1, tourId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        bookingId = rs.getInt("BookingID");
                    }
                }
            } catch (SQLException ex) {
                Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        
        if (bookingId == -1) {
            int scheduleId = -1;
            String findScheduleSql = "SELECT TOP 1 ScheduleID FROM TourSchedule WHERE TourID = ?";
            try (PreparedStatement ps = connection.prepareStatement(findScheduleSql)) {
                ps.setInt(1, tourId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        scheduleId = rs.getInt("ScheduleID");
                    }
                }
            } catch (SQLException ex) {
                Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
            }
            
            if (scheduleId != -1) {
                String insertBookingSql = "INSERT INTO Booking (BookingCode, ScheduleID, CustomerID, NumParticipants, BaseAmount, VATAmount, DiscountAmount, TotalAmount, Status) VALUES (?, ?, ?, 1, 0, 0, 0, 0, 'Completed')";
                try (PreparedStatement ps = connection.prepareStatement(insertBookingSql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, "BK_DUMMY_" + (System.currentTimeMillis() % 100000));
                    ps.setInt(2, scheduleId);
                    ps.setInt(3, userId);
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            bookingId = rs.getInt(1);
                        }
                    }
                } catch (SQLException ex) {
                    Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
                }
            }
        }
        
        if (bookingId == -1) {
            return false;
        }
        
        String insertReviewSql = "INSERT INTO Review (TourID, BookingID, CustomerID, Rating, Content, IsVisible) VALUES (?, ?, ?, ?, ?, 1)";
        try (PreparedStatement ps = connection.prepareStatement(insertReviewSql)) {
            ps.setInt(1, tourId);
            ps.setInt(2, bookingId);
            ps.setInt(3, userId);
            ps.setInt(4, rating);
            ps.setString(5, content);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException ex) {
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, null, ex);
            return false;
        }
    }
    */
}
