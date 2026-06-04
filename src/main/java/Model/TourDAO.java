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
                   + "ISNULL((SELECT AVG(CAST(Rating AS FLOAT)) FROM Review r WHERE r.TourID = Tour.TourID), 0.0) as AvgRating, "
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
            "ISNULL((SELECT AVG(CAST(Rating AS FLOAT)) FROM Review r WHERE r.TourID = t.TourID), 0.0) as AvgRating, " +
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
                   + "ISNULL((SELECT AVG(CAST(Rating AS FLOAT)) FROM Review r WHERE r.TourID = t.TourID), 0.0) as AvgRating, "
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
                    
                    // Nạp tất cả các bình luận, đánh giá và số sao thực tế từ khách hàng từ bảng Review để hiển thị lên khung nhận xét.
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
        List<TourSchedule> list = new ArrayList<>();
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
                    
                    int guideId = rs.getInt("GuideID");
                    if (!rs.wasNull()) {
                        sched.setGuideId(guideId);
                        sched.setTourStatus(rs.getString("TourStatus"));
                        
                        User u = new User();
                        u.setUserId(guideId);
                        u.setEmail(rs.getString("Email"));
                        u.setFullName(rs.getString("FullName"));
                        u.setPhoneNumber(rs.getString("PhoneNumber"));
                        
                        UserProfile up = new UserProfile();
                        up.setUserId(guideId);
                        up.setAvatarUrl(rs.getString("AvatarURL"));
                        u.setProfile(up);
                        
                        sched.setGuide(u);
                    }
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
        tour.setRating(reviewCount > 0 ? avgRating : 0.0);
        tour.setReviewsCount(reviewCount);
        
        // Dương làm đoạn này: Không map TotalSeats, AvailableSeats và NextDeparture vào Tour vì các dữ liệu này thuộc bảng TourSchedule.
        // Khi cần số ghế hoặc ngày khởi hành, màn hình sẽ lấy từ danh sách TourSchedule của tour để tránh sai mô hình dữ liệu.

        
        tour.setCreatedBy(rs.getObject("CreatedBy") != null ? rs.getInt("CreatedBy") : null);
        tour.setCreatedAt(rs.getTimestamp("CreatedAt"));
        tour.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        return tour;
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
     * TRUY VẤN CÁC DỊCH VỤ ĐI KÈM TOUR (INCLUSIONS/EXCLUSIONS)
     * @param tourId ID của tour cần lấy dịch vụ
     * @return Danh sách các đối tượng TourInclusion của tour
     */
    public List<TourInclusion> getInclusionsByTourId(int tourId) {
        List<TourInclusion> list = new ArrayList<>();
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

    /**
     * Truy vấn danh sách đánh giá (Reviews) của một Tour cụ thể từ cơ sở dữ liệu.
     * @param tourId ID của tour cần lấy đánh giá
     * @return danh sách các đối tượng Review của tour đó, sắp xếp theo thời gian mới nhất lên đầu.
     */
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
                String insertBookingSql = "INSERT INTO Booking (BookingCode, ScheduleID, CustomerID, NumParticipants, BaseAmount, VATAmount, DiscountAmount, TotalAmount, Status, CreatedAt, UpdatedAt) VALUES (?, ?, ?, 1, 0, 0, 0, 0, 'Completed', SYSDATETIME(), SYSDATETIME())";
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
        
        String insertReviewSql = "INSERT INTO Review (TourID, BookingID, CustomerID, Rating, Content, IsVisible, CreatedAt, UpdatedAt) VALUES (?, ?, ?, ?, ?, 1, SYSDATETIME(), SYSDATETIME())";
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
        String sql = "SELECT DISTINCT Destination FROM Tour WHERE Status = 'Active'";
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
        String sql = "SELECT DISTINCT DepartureCity FROM Tour WHERE Status = 'Active'";
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
        try {
            connection.setAutoCommit(false);
            
            // 1. Delete reviews referencing TourID directly
            try (PreparedStatement ps = connection.prepareStatement("DELETE FROM Review WHERE TourID = ?")) {
                ps.setInt(1, tourId);
                ps.executeUpdate();
            }
            
            // 2. Delete media
            try (PreparedStatement ps = connection.prepareStatement("DELETE FROM TourMedia WHERE TourID = ?")) {
                ps.setInt(1, tourId);
                ps.executeUpdate();
            }
            
            // 3. Delete inclusion
            try (PreparedStatement ps = connection.prepareStatement("DELETE FROM TourInclusion WHERE TourID = ?")) {
                ps.setInt(1, tourId);
                ps.executeUpdate();
            }
            
            // 4. Delete faq
            try (PreparedStatement ps = connection.prepareStatement("DELETE FROM TourFAQ WHERE TourID = ?")) {
                ps.setInt(1, tourId);
                ps.executeUpdate();
            }
            
            // 5. Delete itinerary
            try (PreparedStatement ps = connection.prepareStatement("DELETE FROM TourItinerary WHERE TourID = ?")) {
                ps.setInt(1, tourId);
                ps.executeUpdate();
            }
            
            // 6. Delete attendance
            try (PreparedStatement ps = connection.prepareStatement(
                "DELETE FROM Attendance WHERE ScheduleID IN (SELECT ScheduleID FROM TourSchedule WHERE TourID = ?)")) {
                ps.setInt(1, tourId);
                ps.executeUpdate();
            }
            
            // 7. Delete assignments
            try (PreparedStatement ps = connection.prepareStatement(
                "DELETE FROM TourAssignment WHERE ScheduleID IN (SELECT ScheduleID FROM TourSchedule WHERE TourID = ?)")) {
                ps.setInt(1, tourId);
                ps.executeUpdate();
            }
            
            // 8. Delete payment
            try (PreparedStatement ps = connection.prepareStatement(
                "DELETE FROM Payment WHERE BookingID IN (SELECT BookingID FROM Booking WHERE ScheduleID IN (SELECT ScheduleID FROM TourSchedule WHERE TourID = ?))")) {
                ps.setInt(1, tourId);
                ps.executeUpdate();
            }
            
            // 9. Delete booking-level reviews
            try (PreparedStatement ps = connection.prepareStatement(
                "DELETE FROM Review WHERE BookingID IN (SELECT BookingID FROM Booking WHERE ScheduleID IN (SELECT ScheduleID FROM TourSchedule WHERE TourID = ?))")) {
                ps.setInt(1, tourId);
                ps.executeUpdate();
            }
            
            // 10. Delete booking participants
            try (PreparedStatement ps = connection.prepareStatement(
                "DELETE FROM BookingParticipant WHERE BookingID IN (SELECT BookingID FROM Booking WHERE ScheduleID IN (SELECT ScheduleID FROM TourSchedule WHERE TourID = ?))")) {
                ps.setInt(1, tourId);
                ps.executeUpdate();
            }
            
            // 11. Delete bookings
            try (PreparedStatement ps = connection.prepareStatement(
                "DELETE FROM Booking WHERE ScheduleID IN (SELECT ScheduleID FROM TourSchedule WHERE TourID = ?)")) {
                ps.setInt(1, tourId);
                ps.executeUpdate();
            }
            
            // 12. Delete schedules
            try (PreparedStatement ps = connection.prepareStatement("DELETE FROM TourSchedule WHERE TourID = ?")) {
                ps.setInt(1, tourId);
                ps.executeUpdate();
            }
            
            // 13. Delete Tour itself
            boolean success = false;
            try (PreparedStatement ps = connection.prepareStatement("DELETE FROM Tour WHERE TourID = ?")) {
                ps.setInt(1, tourId);
                success = ps.executeUpdate() > 0;
            }
            
            connection.commit();
            return success;
        } catch (SQLException ex) {
            try {
                connection.rollback();
            } catch (SQLException rollbackEx) {
                Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, "rollback failed", rollbackEx);
            }
            Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, "deleteTour failed", ex);
        } finally {
            try {
                connection.setAutoCommit(true);
            } catch (SQLException ex) {
                Logger.getLogger(TourDAO.class.getName()).log(Level.SEVERE, "setAutoCommit failed", ex);
            }
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
        String sql = "SELECT t.TourID, t.CategoryID, t.TourName, t.Description, t.Destination, t.DurationDays, t.Itinerary, t.DifficultyLevel, t.BasePrice, t.MaxParticipants, t.Status, t.IsFeatured, t.Languages, t.GroupSizeMin, t.GroupSizeMax, t.DepartureCity, t.Latitude, t.Longitude, t.VideoURL, t.CreatedBy, t.CreatedAt, t.UpdatedAt, "
                   + "ISNULL((SELECT AVG(CAST(Rating AS FLOAT)) FROM Review r WHERE r.TourID = t.TourID), 0.0) as AvgRating, "
                   + "(SELECT COUNT(*) FROM Review r WHERE r.TourID = t.TourID) as ReviewCount, "
                   + "ISNULL((SELECT SUM(TotalSeats) FROM TourSchedule s WHERE s.TourID = t.TourID), t.MaxParticipants) as TotalSeats, "
                   + "ISNULL((SELECT SUM(AvailableSeats) FROM TourSchedule s WHERE s.TourID = t.TourID), t.MaxParticipants) as AvailableSeats, "
                   + "ISNULL((SELECT TOP 1 DepartureDate FROM TourSchedule s WHERE s.TourID = t.TourID AND s.DepartureDate >= CAST(GETDATE() AS DATE) ORDER BY DepartureDate ASC), "
                   + "        (SELECT TOP 1 DepartureDate FROM TourSchedule s WHERE s.TourID = t.TourID ORDER BY DepartureDate ASC)) as NextDeparture, "
                   + "c.CategoryName, c.Description AS CategoryDesc "
                   + "FROM Tour t "
                   + "JOIN TourCategory c ON t.CategoryID = c.CategoryID "
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
                   + "WHERE Status IN ('Confirmed', 'Completed') AND CreatedAt >= DATEADD(month, -5, GETDATE()) "
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
