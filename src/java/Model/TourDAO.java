package Model;

import Entities.Tour;
import Entities.TourCategory;
import Entities.TourMedia;
import Entities.TourSchedule;
import Entities.TourItinerary;
import Entities.TourInclusion;
import Entities.TourFAQ;
import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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
                    
                    // Fetch media and schedules
                    tour.setMediaList(getMediaForTour(tourId, false));
                    tour.setSchedules(getSchedulesByTourId(tourId));
                    tour.setItineraries(getItineraryByTourId(tourId));
                    tour.setInclusions(getInclusionsByTourId(tourId));
                    tour.setFaqs(getFaqsByTourId(tourId));
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
}
