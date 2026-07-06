package Model;

import Entities.Conversation;
import Entities.ConversationParticipant;
import Entities.Message;
import Utils.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ChatDAO extends DBContext {

    // Get or Create Direct Conversation between two users
    public int getOrCreateDirectConversation(int user1, int user2) {
        String checkSql = "SELECT c.ConversationID FROM Conversation c " +
                          "JOIN ConversationParticipant cp1 ON c.ConversationID = cp1.ConversationID " +
                          "JOIN ConversationParticipant cp2 ON c.ConversationID = cp2.ConversationID " +
                          "WHERE c.Type = 'Direct' AND cp1.UserID = ? AND cp2.UserID = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(checkSql)) {
            ps.setInt(1, user1);
            ps.setInt(2, user2);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("ConversationID"); // Found existing
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(ChatDAO.class.getName()).log(Level.SEVERE, null, ex);
        }

        // Create new
        int newConversationId = -1;
        String insertConv = "INSERT INTO Conversation (Type) VALUES ('Direct')";
        try (PreparedStatement ps = connection.prepareStatement(insertConv, Statement.RETURN_GENERATED_KEYS)) {
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    newConversationId = rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(ChatDAO.class.getName()).log(Level.SEVERE, null, ex);
        }

        if (newConversationId != -1) {
            String insertPart = "INSERT INTO ConversationParticipant (ConversationID, UserID, Role) VALUES (?, ?, 'Member')";
            try (PreparedStatement ps = connection.prepareStatement(insertPart)) {
                ps.setInt(1, newConversationId);
                ps.setInt(2, user1);
                ps.addBatch();
                ps.setInt(1, newConversationId);
                ps.setInt(2, user2);
                ps.addBatch();
                ps.executeBatch();
            } catch (SQLException ex) {
                Logger.getLogger(ChatDAO.class.getName()).log(Level.SEVERE, null, ex);
            }
        }

        return newConversationId;
    }

    // Insert a new message
    public Message saveMessage(Message msg) {
        String sql = "INSERT INTO Message (ConversationID, SenderID, Content, MessageType) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, msg.getConversationId());
            ps.setInt(2, msg.getSenderId());
            ps.setString(3, msg.getContent());
            ps.setString(4, msg.getMessageType() != null ? msg.getMessageType() : "Text");
            
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    msg.setMessageId(rs.getInt(1));
                }
            }
            
            // Update conversation updated_at
            String updateConv = "UPDATE Conversation SET UpdatedAt = SYSDATETIME() WHERE ConversationID = ?";
            try (PreparedStatement pUpdate = connection.prepareStatement(updateConv)) {
                pUpdate.setInt(1, msg.getConversationId());
                pUpdate.executeUpdate();
            }
            
            return msg;
        } catch (SQLException ex) {
            Logger.getLogger(ChatDAO.class.getName()).log(Level.SEVERE, null, ex);
            return null;
        }
    }

    // Get messages for a conversation
    public List<Message> getMessages(int conversationId, int limit, int offset) {
        List<Message> list = new ArrayList<>();
        // Note: MS SQL Server uses OFFSET FETCH for pagination
        String sql = "SELECT m.*, u.FullName as SenderName, u.ProfilePicture as SenderAvatar " +
                     "FROM Message m " +
                     "JOIN [User] u ON m.SenderID = u.UserID " +
                     "WHERE m.ConversationID = ? AND m.IsDeleted = 0 " +
                     "ORDER BY m.CreatedAt DESC " +
                     "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            ps.setInt(2, offset);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Message m = new Message();
                    m.setMessageId(rs.getInt("MessageID"));
                    m.setConversationId(rs.getInt("ConversationID"));
                    m.setSenderId(rs.getInt("SenderID"));
                    m.setContent(rs.getString("Content"));
                    m.setMessageType(rs.getString("MessageType"));
                    m.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    m.setIsDeleted(rs.getBoolean("IsDeleted"));
                    m.setSenderName(rs.getString("SenderName"));
                    m.setSenderAvatar(rs.getString("SenderAvatar"));
                    // Reverse the order later in UI or here so newest is at bottom
                    list.add(0, m); 
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(ChatDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    // Get active conversations for a user
    public List<Conversation> getUserConversations(int userId) {
        List<Conversation> list = new ArrayList<>();
        String sql = "SELECT c.*, u.FullName AS OtherName, u.ProfilePicture AS OtherAvatar, u.UserID AS OtherID " +
                     "FROM Conversation c " +
                     "JOIN ConversationParticipant cp1 ON c.ConversationID = cp1.ConversationID " +
                     "LEFT JOIN ConversationParticipant cp2 ON c.ConversationID = cp2.ConversationID AND cp2.UserID != ? " +
                     "LEFT JOIN [User] u ON cp2.UserID = u.UserID " +
                     "WHERE cp1.UserID = ? " +
                     "ORDER BY c.UpdatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Conversation c = new Conversation();
                    c.setConversationId(rs.getInt("ConversationID"));
                    c.setType(rs.getString("Type"));
                    
                    if ("Direct".equals(rs.getString("Type"))) {
                        c.setTitle(rs.getString("OtherName"));
                        c.setAvatarUrl(rs.getString("OtherAvatar"));
                        c.setOtherUserId(rs.getInt("OtherID"));
                    } else {
                        c.setTitle(rs.getString("Title"));
                    }
                    
                    c.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    c.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                    list.add(c);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(ChatDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }
    
    // Check if user1 has blocked user2 or vice versa
    public boolean isBlocked(int user1, int user2) {
        String sql = "SELECT COUNT(*) FROM BlockList WHERE (BlockerID = ? AND BlockedID = ?) OR (BlockerID = ? AND BlockedID = ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, user1);
            ps.setInt(2, user2);
            ps.setInt(3, user2);
            ps.setInt(4, user1);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(ChatDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }
}
