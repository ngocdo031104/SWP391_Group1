package Model;

import Entities.ModerationRecord;
import Utils.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ModerationDAO extends DBContext {
    private static final Logger LOGGER = Logger.getLogger(ModerationDAO.class.getName());

    public ModerationDAO() {
        super();
    }

    /**
     * getPendingReviews()
     */
    public List<Map<String, Object>> getPendingReviews() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT r.ReviewID, r.TourID, r.BookingID, r.CustomerID, r.Rating, r.Content, r.IsVisible, r.IsFlagged, r.CreatedAt, "
                   + "       u.FullName as AuthorName, t.TourName "
                   + "FROM Review r "
                   + "JOIN [User] u ON r.CustomerID = u.UserID "
                   + "JOIN Tour t ON r.TourID = t.TourID "
                   + "WHERE r.IsVisible = 1 "
                   + "ORDER BY r.CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("reviewId", rs.getInt("ReviewID"));
                map.put("tourId", rs.getInt("TourID"));
                map.put("bookingId", rs.getInt("BookingID"));
                map.put("customerId", rs.getInt("CustomerID"));
                map.put("rating", rs.getInt("Rating"));
                map.put("content", rs.getString("Content"));
                map.put("isVisible", rs.getBoolean("IsVisible"));
                map.put("isFlagged", rs.getBoolean("IsFlagged"));
                map.put("createdAt", rs.getTimestamp("CreatedAt"));
                map.put("authorName", rs.getString("AuthorName"));
                map.put("tourName", rs.getString("TourName"));
                list.add(map);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "getPendingReviews failed", ex);
        }
        return list;
    }

    /**
     * getPendingPosts()
     */
    public List<Map<String, Object>> getPendingPosts() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT p.PostID, p.AuthorID, p.Title, p.Content, p.IsVisible, p.IsFlagged, p.CreatedAt, u.FullName as AuthorName "
                   + "FROM CommunityPost p "
                   + "JOIN [User] u ON p.AuthorID = u.UserID "
                   + "WHERE p.IsVisible = 1 "
                   + "ORDER BY p.CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("postId", rs.getInt("PostID"));
                map.put("authorId", rs.getInt("AuthorID"));
                map.put("title", rs.getString("Title"));
                map.put("content", rs.getString("Content"));
                map.put("isVisible", rs.getBoolean("IsVisible"));
                map.put("isFlagged", rs.getBoolean("IsFlagged"));
                map.put("createdAt", rs.getTimestamp("CreatedAt"));
                map.put("authorName", rs.getString("AuthorName"));
                list.add(map);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "getPendingPosts failed", ex);
        }
        return list;
    }

    /**
     * getPendingComments()
     */
    public List<Map<String, Object>> getPendingComments() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT c.CommentID, c.PostID, c.AuthorID, c.Content, c.IsVisible, c.IsFlagged, c.CreatedAt, "
                   + "       u.FullName as AuthorName, p.Title as PostTitle "
                   + "FROM Comment c "
                   + "JOIN [User] u ON c.AuthorID = u.UserID "
                   + "JOIN CommunityPost p ON c.PostID = p.PostID "
                   + "WHERE c.IsVisible = 1 "
                   + "ORDER BY c.CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("commentId", rs.getInt("CommentID"));
                map.put("postId", rs.getInt("PostID"));
                map.put("authorId", rs.getInt("AuthorID"));
                map.put("content", rs.getString("Content"));
                map.put("isVisible", rs.getBoolean("IsVisible"));
                map.put("isFlagged", rs.getBoolean("IsFlagged"));
                map.put("createdAt", rs.getTimestamp("CreatedAt"));
                map.put("authorName", rs.getString("AuthorName"));
                map.put("postTitle", rs.getString("PostTitle"));
                list.add(map);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "getPendingComments failed", ex);
        }
        return list;
    }

    /**
     * moderateContent(String entityType, int entityId, String action, String reason, int moderatorId)
     */
    public boolean moderateContent(String entityType, int entityId, String action, String reason, int moderatorId) {
        String updateSql = "";
        if ("Review".equalsIgnoreCase(entityType)) {
            updateSql = "UPDATE Review SET IsVisible = ?, IsFlagged = 0 WHERE ReviewID = ?";
        } else if ("CommunityPost".equalsIgnoreCase(entityType)) {
            updateSql = "UPDATE CommunityPost SET IsVisible = ?, IsFlagged = 0 WHERE PostID = ?";
        } else if ("Comment".equalsIgnoreCase(entityType)) {
            updateSql = "UPDATE Comment SET IsVisible = ?, IsFlagged = 0 WHERE CommentID = ?";
        } else {
            return false;
        }

        boolean isVisible = "Restore".equalsIgnoreCase(action);

        String insertRecordSql = "INSERT INTO ModerationRecord (EntityType, EntityID, Action, Reason, ModeratedBy, ModeratedAt) "
                               + "VALUES (?, ?, ?, ?, ?, SYSDATETIME())";

        try {
            connection.setAutoCommit(false);

            // 1. Update IsVisible flag
            try (PreparedStatement psUpdate = connection.prepareStatement(updateSql)) {
                psUpdate.setBoolean(1, isVisible);
                psUpdate.setInt(2, entityId);
                int affected = psUpdate.executeUpdate();
                if (affected <= 0) {
                    connection.rollback();
                    return false;
                }
            }

            // 2. Insert Moderation Log Record
            try (PreparedStatement psInsert = connection.prepareStatement(insertRecordSql)) {
                psInsert.setString(1, entityType);
                psInsert.setInt(2, entityId);
                psInsert.setString(3, action);
                psInsert.setString(4, reason != null ? reason : "");
                psInsert.setInt(5, moderatorId);
                int affected = psInsert.executeUpdate();
                if (affected <= 0) {
                    connection.rollback();
                    return false;
                }
            }

            connection.commit();
            return true;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "moderateContent failed", ex);
            try {
                connection.rollback();
            } catch (SQLException rollbackEx) {
                LOGGER.log(Level.SEVERE, "rollback failed", rollbackEx);
            }
        } finally {
            try {
                connection.setAutoCommit(true);
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "setAutoCommit failed", e);
            }
        }
        return false;
    }

    /**
     * getModerationHistory()
     */
    public List<ModerationRecord> getModerationHistory() {
        List<ModerationRecord> list = new ArrayList<>();
        String sql = "SELECT m.ModerationID, m.EntityType, m.EntityID, m.Action, m.Reason, m.ModeratedBy, m.ModeratedAt, "
                   + "       u.FullName as ModeratedByName, "
                   + "       CASE "
                   + "           WHEN m.EntityType = 'Review' THEN (SELECT IsVisible FROM Review WHERE ReviewID = m.EntityID) "
                   + "           WHEN m.EntityType = 'CommunityPost' THEN (SELECT IsVisible FROM CommunityPost WHERE PostID = m.EntityID) "
                   + "           WHEN m.EntityType = 'Comment' THEN (SELECT IsVisible FROM Comment WHERE CommentID = m.EntityID) "
                   + "           ELSE 0 "
                   + "       END as IsEntityVisible "
                   + "FROM ModerationRecord m "
                   + "JOIN [User] u ON m.ModeratedBy = u.UserID "
                   + "ORDER BY m.ModeratedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ModerationRecord mr = new ModerationRecord();
                mr.setModerationId(rs.getInt("ModerationID"));
                mr.setEntityType(rs.getString("EntityType"));
                mr.setEntityId(rs.getInt("EntityID"));
                mr.setAction(rs.getString("Action"));
                mr.setReason(rs.getString("Reason"));
                mr.setModeratedBy(rs.getInt("ModeratedBy"));
                mr.setModeratedAt(rs.getTimestamp("ModeratedAt"));
                mr.setModeratedByName(rs.getString("ModeratedByName"));
                mr.setIsEntityVisible(rs.getBoolean("IsEntityVisible"));
                list.add(mr);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "getModerationHistory failed", ex);
        }
        return list;
    }

    /**
     * flagContent(String entityType, int entityId)
     */
    public boolean flagContent(String entityType, int entityId) {
        String sql = "";
        if ("Review".equalsIgnoreCase(entityType)) {
            sql = "UPDATE Review SET IsFlagged = 1 WHERE ReviewID = ?";
        } else if ("CommunityPost".equalsIgnoreCase(entityType)) {
            sql = "UPDATE CommunityPost SET IsFlagged = 1 WHERE PostID = ?";
        } else if ("Comment".equalsIgnoreCase(entityType)) {
            sql = "UPDATE Comment SET IsFlagged = 1 WHERE CommentID = ?";
        } else {
            return false;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, entityId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "flagContent failed", ex);
        }
        return false;
    }

    /**
     * dismissFlag(String entityType, int entityId)
     */
    public boolean dismissFlag(String entityType, int entityId) {
        String sql = "";
        if ("Review".equalsIgnoreCase(entityType)) {
            sql = "UPDATE Review SET IsFlagged = 0 WHERE ReviewID = ?";
        } else if ("CommunityPost".equalsIgnoreCase(entityType)) {
            sql = "UPDATE CommunityPost SET IsFlagged = 0 WHERE PostID = ?";
        } else if ("Comment".equalsIgnoreCase(entityType)) {
            sql = "UPDATE Comment SET IsFlagged = 0 WHERE CommentID = ?";
        } else {
            return false;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, entityId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "dismissFlag failed", ex);
        }
        return false;
    }
}
