package Model;

import Entities.Tour;
import Entities.TourCategory;
import Entities.TourMedia;
import Entities.TourSchedule;
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
        String sql = "SELECT TourID, CategoryID, TourName, Description, Destination, DurationDays, Itinerary, DifficultyLevel, BasePrice, MaxParticipants, Status, IsFeatured, CreatedBy, CreatedAt, UpdatedAt "
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
            "SELECT DISTINCT t.TourID, t.CategoryID, t.TourName, t.Description, t.Destination, t.DurationDays, t.Itinerary, t.DifficultyLevel, t.BasePrice, t.MaxParticipants, t.Status, t.IsFeatured, t.CreatedBy, t.CreatedAt, t.UpdatedAt " +
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
        String sql = "SELECT t.TourID, t.CategoryID, t.TourName, t.Description, t.Destination, t.DurationDays, t.Itinerary, t.DifficultyLevel, t.BasePrice, t.MaxParticipants, t.Status, t.IsFeatured, t.CreatedBy, t.CreatedAt, t.UpdatedAt, "
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
        tour.setCreatedBy(rs.getObject("CreatedBy") != null ? rs.getInt("CreatedBy") : null);
        tour.setCreatedAt(rs.getTimestamp("CreatedAt"));
        tour.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        return tour;
    }
}
