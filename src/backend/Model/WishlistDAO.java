package Model;

import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import Entities.Tour;
import Entities.TourMedia;
import java.util.logging.Level;
import java.util.logging.Logger;


public class WishlistDAO extends DBContext {

    public boolean toggleWishlist(int userId, int tourId) {
        // Lưu ý: bảng thực tế trong DB là FavoriteTour(CustomerID, TourID, AddedAt)
        // Kiểm tra xem đã yêu thích chưa
        String checkSql = "SELECT 1 FROM FavoriteTour WHERE CustomerID = ? AND TourID = ?";
        try (PreparedStatement psCheck = connection.prepareStatement(checkSql)) {
            psCheck.setInt(1, userId);
            psCheck.setInt(2, tourId);

            try (ResultSet rs = psCheck.executeQuery()) {
                if (rs.next()) {
                    // Nếu đã yêu thích -> Xóa đi
                    String deleteSql = "DELETE FROM FavoriteTour WHERE CustomerID = ? AND TourID = ?";
                    try (PreparedStatement psDel = connection.prepareStatement(deleteSql)) {
                        psDel.setInt(1, userId);
                        psDel.setInt(2, tourId);
                        psDel.executeUpdate();
                        return false; // Trả về false báo đã hủy lưu
                    }
                } else {
                    // Nếu chưa -> Thêm vào
                    String insertSql = "INSERT INTO FavoriteTour (CustomerID, TourID, AddedAt) VALUES (?, ?, SYSDATETIME())";
                    try (PreparedStatement psIns = connection.prepareStatement(insertSql)) {
                        psIns.setInt(1, userId);
                        psIns.setInt(2, tourId);
                        psIns.executeUpdate();
                        return true; // Trả về true báo đã lưu
                    }
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(WishlistDAO.class.getName()).log(Level.SEVERE, "Error toggling wishlist for user " + userId + " tour " + tourId, ex);
        }
        return false;
    }

    public List<Integer> getWishlistTourIds(int userId) {
        List<Integer> list = new ArrayList<>();
        String sql = "SELECT TourID FROM FavoriteTour WHERE CustomerID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getInt("TourID"));
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(WishlistDAO.class.getName()).log(Level.SEVERE, "Error getting wishlist tour IDs", ex);
        }
        return list;
    }

    public List<Tour> getWishlistTours(int userId) {
        List<Tour> list = new ArrayList<>();
        String sql = "SELECT t.TourID, t.CategoryID, t.TourName, t.Description, t.Destination, t.DurationDays, t.Itinerary, t.DifficultyLevel, t.BasePrice, t.MaxParticipants, t.Status, t.IsFeatured, t.IsDeleted, t.Languages, t.GroupSizeMin, t.GroupSizeMax, t.DepartureCity, t.Latitude, t.Longitude, t.VideoURL, t.CreatedBy, t.CreatedAt, t.UpdatedAt, "
                   + "ISNULL((SELECT AVG(CAST(Rating AS FLOAT)) FROM Review r WHERE r.TourID = t.TourID), 0.0) as AvgRating, "
                   + "(SELECT COUNT(*) FROM Review r WHERE r.TourID = t.TourID) as ReviewCount, "
                   + "(SELECT TOP 1 MediaURL FROM TourMedia m WHERE m.TourID = t.TourID AND m.IsVisible = 1 ORDER BY m.SortOrder ASC) as ThumbnailURL "
                   + "FROM FavoriteTour w "
                   + "JOIN Tour t ON w.TourID = t.TourID "
                   + "WHERE w.CustomerID = ? AND t.Status = 'Active' AND t.IsDeleted = 0";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
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

                    tour.setCreatedBy(rs.getObject("CreatedBy") != null ? rs.getInt("CreatedBy") : null);
                    tour.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    tour.setUpdatedAt(rs.getTimestamp("UpdatedAt"));

                    String thumbUrl = rs.getString("ThumbnailURL");
                    if (thumbUrl != null) {
                        TourMedia media = new TourMedia();
                        media.setMediaUrl(thumbUrl);
                        List<TourMedia> mediaList = new ArrayList<>();
                        mediaList.add(media);
                        tour.setMediaList(mediaList);
                    }

                    list.add(tour);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(WishlistDAO.class.getName()).log(Level.SEVERE, "Error getting wishlist tours", ex);
        }
        return list;
    }

    public int countWishlistTours(int userId) {
        String sql = "SELECT COUNT(*) FROM FavoriteTour WHERE CustomerID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(WishlistDAO.class.getName()).log(Level.SEVERE, "Error counting wishlist tours", ex);
        }
        return 0;
    }
}
