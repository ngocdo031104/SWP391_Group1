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
        String sql = "MERGE INTO BuddyRequest AS target " +
                     "USING (SELECT ? AS SenderId, ? AS ReceiverId) AS source " +
                     "ON target.SenderId = source.SenderId AND target.ReceiverId = source.ReceiverId " +
                     "WHEN MATCHED THEN " +
                     "    UPDATE SET Status = 'Pending', UpdatedAt = SYSDATETIME() " +
                     "WHEN NOT MATCHED THEN " +
                     "    INSERT (SenderId, ReceiverId, Status, CreatedAt, UpdatedAt) " +
                     "    VALUES (source.SenderId, source.ReceiverId, 'Pending', SYSDATETIME(), SYSDATETIME());";
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

    public BuddyRequest getRequestById(int requestId) {
        String sql = "SELECT * FROM BuddyRequest WHERE RequestId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new BuddyRequest(
                    rs.getInt("RequestId"),
                    rs.getInt("SenderId"),
                    rs.getInt("ReceiverId"),
                    rs.getString("Status"),
                    rs.getTimestamp("CreatedAt"),
                    rs.getTimestamp("UpdatedAt")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<BuddyRequest> getPendingRequests(int receiverId) {
        return getReceivedRequests(receiverId).stream().filter(r -> "Pending".equals(r.getStatus())).toList();
    }

    public List<BuddyRequest> getReceivedRequests(int receiverId) {
        List<BuddyRequest> list = new ArrayList<>();
        String sql = "SELECT b.*, u.FullName, u.Email, p.AvatarURL FROM BuddyRequest b "
                   + "JOIN [User] u ON b.SenderId = u.UserID "
                   + "LEFT JOIN UserProfile p ON u.UserID = p.UserID "
                   + "WHERE b.ReceiverId = ? ORDER BY b.CreatedAt DESC";
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
                // We reuse User's profile field to hold the avatar URL
                Entities.UserProfile profile = new Entities.UserProfile();
                profile.setAvatarUrl(rs.getString("AvatarURL"));
                sender.setProfile(profile);
                req.setSender(sender);
                list.add(req);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<BuddyRequest> getSentRequests(int senderId) {
        List<BuddyRequest> list = new ArrayList<>();
        String sql = "SELECT b.*, u.FullName, u.Email, p.AvatarURL FROM BuddyRequest b "
                   + "JOIN [User] u ON b.ReceiverId = u.UserID "
                   + "LEFT JOIN UserProfile p ON u.UserID = p.UserID "
                   + "WHERE b.SenderId = ? ORDER BY b.CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, senderId);
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
                // Sender field in this context holds the Receiver's info to display in UI
                User receiver = new User();
                receiver.setUserId(rs.getInt("ReceiverId"));
                receiver.setFullName(rs.getString("FullName"));
                receiver.setEmail(rs.getString("Email"));
                Entities.UserProfile profile = new Entities.UserProfile();
                profile.setAvatarUrl(rs.getString("AvatarURL"));
                receiver.setProfile(profile);
                req.setSender(receiver); // Abusing the sender field for convenience in UI
                list.add(req);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean cancelRequest(int requestId, int senderId) {
        String sql = "UPDATE BuddyRequest SET Status = 'Cancelled', UpdatedAt = SYSDATETIME() WHERE RequestId = ? AND SenderId = ? AND Status = 'Pending'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            ps.setInt(2, senderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<User> getAcceptedBuddies(int userId) {
        List<User> list = new ArrayList<>();
        // Get buddies where user is sender OR receiver
        String sql = "SELECT u.UserID, u.FullName, u.Email, p.AvatarURL, p.Address, p.Biography FROM [User] u "
                   + "JOIN BuddyRequest b ON (u.UserID = b.ReceiverId OR u.UserID = b.SenderId) "
                   + "LEFT JOIN UserProfile p ON u.UserID = p.UserID "
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
                Entities.UserProfile profile = new Entities.UserProfile();
                profile.setAvatarUrl(rs.getString("AvatarURL"));
                profile.setAddress(rs.getString("Address"));
                profile.setBiography(rs.getString("Biography"));
                u.setProfile(profile);
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
