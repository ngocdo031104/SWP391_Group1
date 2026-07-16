package Model;

import Entities.Notification;
import Utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO extends DBContext {

    public boolean insertNotification(Notification notification) {
        String sql = "INSERT INTO Notifications (userId, senderId, title, content, channel, category, isRead, createdAt, scheduledAt, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, 0, GETDATE(), ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notification.getUserId());
            if (notification.getSenderId() != null) {
                ps.setInt(2, notification.getSenderId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, notification.getTitle());
            ps.setString(4, notification.getContent());
            ps.setString(5, notification.getChannel());
            ps.setString(6, notification.getCategory() != null ? notification.getCategory() : "System Announcement");
            
            if (notification.getScheduledAt() != null) {
                ps.setTimestamp(7, notification.getScheduledAt());
            } else {
                ps.setNull(7, Types.TIMESTAMP);
            }
            
            ps.setString(8, notification.getStatus() != null ? notification.getStatus() : "SENT");
            
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Notification> getNotificationsByUserId(int userId) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT n.*, u.FullName as senderName FROM Notifications n "
                   + "LEFT JOIN [User] u ON n.senderId = u.UserID "
                   + "WHERE n.userId = ? AND (n.scheduledAt IS NULL OR n.scheduledAt <= GETDATE()) "
                   + "ORDER BY n.createdAt DESC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification();
                    n.setNotificationId(rs.getInt("notificationId"));
                    n.setUserId(rs.getInt("userId"));
                    n.setSenderId(rs.getObject("senderId") != null ? rs.getInt("senderId") : null);
                    n.setTitle(rs.getString("title"));
                    n.setContent(rs.getString("content"));
                    n.setChannel(rs.getString("channel"));
                    n.setCategory(rs.getString("category"));
                    n.setIsRead(rs.getBoolean("isRead"));
                    n.setCreatedAt(rs.getTimestamp("createdAt"));
                    n.setScheduledAt(rs.getTimestamp("scheduledAt"));
                    n.setStatus(rs.getString("status"));
                    n.setSenderName(rs.getString("senderName"));
                    list.add(n);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean markAsRead(int notificationId) {
        String sql = "UPDATE Notifications SET isRead = 1 WHERE notificationId = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public int getUnreadCount(int userId) {
        String sql = "SELECT COUNT(*) FROM Notifications "
                   + "WHERE userId = ? AND isRead = 0 AND (scheduledAt IS NULL OR scheduledAt <= GETDATE())";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean markAllAsRead(int userId) {
        String sql = "UPDATE Notifications SET isRead = 1 WHERE userId = ? AND isRead = 0";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Notification> getNotificationsWithFilters(int userId, String category, String keyword, boolean unreadOnly) {
        List<Notification> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT n.*, u.FullName as senderName FROM Notifications n ");
        sql.append("LEFT JOIN [User] u ON n.senderId = u.UserID ");
        sql.append("WHERE n.userId = ? AND (n.scheduledAt IS NULL OR n.scheduledAt <= GETDATE()) ");
        
        List<Object> params = new ArrayList<>();
        params.add(userId);
        
        if (category != null && !category.trim().isEmpty() && !category.equals("All")) {
            sql.append("AND n.category = ? ");
            params.add(category);
        }
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (n.title LIKE ? OR n.content LIKE ?) ");
            params.add("%" + keyword + "%");
            params.add("%" + keyword + "%");
        }
        
        if (unreadOnly) {
            sql.append("AND n.isRead = 0 ");
        }
        
        sql.append("ORDER BY CASE WHEN n.isRead = 0 THEN 0 ELSE 1 END ASC, n.createdAt DESC");
        
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification();
                    n.setNotificationId(rs.getInt("notificationId"));
                    n.setUserId(rs.getInt("userId"));
                    n.setSenderId(rs.getObject("senderId") != null ? rs.getInt("senderId") : null);
                    n.setTitle(rs.getString("title"));
                    n.setContent(rs.getString("content"));
                    n.setChannel(rs.getString("channel"));
                    n.setCategory(rs.getString("category"));
                    n.setIsRead(rs.getBoolean("isRead"));
                    n.setCreatedAt(rs.getTimestamp("createdAt"));
                    n.setScheduledAt(rs.getTimestamp("scheduledAt"));
                    n.setStatus(rs.getString("status"));
                    n.setSenderName(rs.getString("senderName"));
                    list.add(n);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
