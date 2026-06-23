package Model;

import Entities.BuddyRequest;
import Entities.User;
import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class BuddyRequestDAO extends DBContext {

    public boolean sendRequest(int senderId, int receiverId) throws Exception {
        String sql = "INSERT INTO BuddyRequest (SenderId, ReceiverId, Status, CreatedAt, UpdatedAt) VALUES (?, ?, 'Pending', SYSDATETIME(), SYSDATETIME())";
        if (connection == null) {
            throw new Exception("Database connection is null in BuddyRequestDAO");
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, senderId);
            ps.setInt(2, receiverId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            throw new Exception("SQL Error: " + e.getMessage());
        }
    }

    public boolean updateRequestStatus(int requestId, String status) {
        String sql = "UPDATE BuddyRequest SET Status = ?, UpdatedAt = SYSDATETIME() WHERE RequestId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, requestId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<BuddyRequest> getPendingRequests(int receiverId) {
        List<BuddyRequest> list = new ArrayList<>();
        String sql = "SELECT b.*, u.FullName, u.Email FROM BuddyRequest b "
                   + "JOIN [User] u ON b.SenderId = u.UserID "
                   + "WHERE b.ReceiverId = ? AND b.Status = 'Pending'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, receiverId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                BuddyRequest req = new BuddyRequest(
                    rs.getInt("RequestId"),
                    rs.getInt("SenderId"),
                    rs.getInt("ReceiverId"),
                    rs.getString("Status"),
                    rs.getTimestamp("CreatedAt"),
                    rs.getTimestamp("UpdatedAt")
                );
                User sender = new User();
                sender.setUserId(rs.getInt("SenderId"));
                sender.setFullName(rs.getString("FullName"));
                sender.setEmail(rs.getString("Email"));
                req.setSender(sender);
                list.add(req);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<User> getAcceptedBuddies(int userId) {
        List<User> list = new ArrayList<>();
        // Get buddies where user is sender OR receiver
        String sql = "SELECT u.UserID, u.FullName, u.Email FROM [User] u "
                   + "JOIN BuddyRequest b ON (u.UserID = b.ReceiverId OR u.UserID = b.SenderId) "
                   + "WHERE ((b.SenderId = ? AND u.UserID != ?) OR (b.ReceiverId = ? AND u.UserID != ?)) "
                   + "AND b.Status = 'Accepted'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            ps.setInt(4, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("UserID"));
                u.setFullName(rs.getString("FullName"));
                u.setEmail(rs.getString("Email"));
                list.add(u);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<User> getSuggestedBuddies(int userId) {
        List<User> list = new ArrayList<>();
        // For now, get active customers who are not the user and not already in a request with the user
        String sql = "SELECT u.UserID, u.FullName, u.Email FROM [User] u "
                   + "WHERE u.RoleID = 4 AND u.UserID != ? AND u.IsActive = 1 "
                   + "AND u.UserID NOT IN ("
                   + "  SELECT ReceiverId FROM BuddyRequest WHERE SenderId = ? "
                   + "  UNION "
                   + "  SELECT SenderId FROM BuddyRequest WHERE ReceiverId = ? "
                   + ")";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("UserID"));
                u.setFullName(rs.getString("FullName"));
                u.setEmail(rs.getString("Email"));
                list.add(u);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
