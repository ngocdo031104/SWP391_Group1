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
        String checkSql = "SELECT c.ConversationID FROM ChatConversation c " +
                          "JOIN ConversationParticipant cp1 ON c.ConversationID = cp1.ConversationID " +
                          "JOIN ConversationParticipant cp2 ON c.ConversationID = cp2.ConversationID " +
                          "WHERE c.ConversationType = 'Direct' AND cp1.UserID = ? AND cp2.UserID = ?";
        
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
        String insertConv = "INSERT INTO ChatConversation (ConversationType, CreatedBy) OUTPUT INSERTED.ConversationID VALUES ('Direct', ?)";
        try (PreparedStatement ps = connection.prepareStatement(insertConv)) {
            ps.setInt(1, user1);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    newConversationId = rs.getInt(1);
                    System.out.println("Created ConversationID: " + newConversationId);
                }
            }
        } catch (SQLException ex) {
            System.err.println("Error inserting Conversation: " + ex.getMessage());
            Logger.getLogger(ChatDAO.class.getName()).log(Level.SEVERE, null, ex);
        }

        if (newConversationId != -1) {
            String insertPart = "INSERT INTO ConversationParticipant (ConversationID, UserID) VALUES (?, ?)";
            try (PreparedStatement ps = connection.prepareStatement(insertPart)) {
                // Add user 1
                ps.setInt(1, newConversationId);
                ps.setInt(2, user1);
                ps.executeUpdate();
                System.out.println("Added user1 to conversation");

                // Add user 2
                ps.setInt(1, newConversationId);
                ps.setInt(2, user2);
                ps.executeUpdate();
                System.out.println("Added user2 to conversation");
            } catch (SQLException ex) {
                System.err.println("Error inserting ConversationParticipant: " + ex.getMessage());
                Logger.getLogger(ChatDAO.class.getName()).log(Level.SEVERE, null, ex);
            }
        }

        return newConversationId;
    }

    // Insert a new message
    public Message saveMessage(Message msg) {
        String sql = "INSERT INTO ChatMessage (ConversationID, SenderID, Content, MessageType, IsVisible) OUTPUT INSERTED.MessageID VALUES (?, ?, ?, ?, 1)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, msg.getConversationId());
            ps.setInt(2, msg.getSenderId());
            ps.setString(3, msg.getContent());
            ps.setString(4, msg.getMessageType() != null ? msg.getMessageType() : "Text");
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    msg.setMessageId(rs.getInt(1));
                }
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
        String sql = "SELECT m.*, u.FullName as SenderName, up.AvatarURL as SenderAvatar " +
                     "FROM ChatMessage m " +
                     "JOIN [User] u ON m.SenderID = u.UserID " +
                     "LEFT JOIN UserProfile up ON u.UserID = up.UserID " +
                     "WHERE m.ConversationID = ? AND m.IsVisible = 1 " +
                     "ORDER BY m.SentAt DESC " +
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
                    m.setCreatedAt(rs.getTimestamp("SentAt"));
                    m.setIsDeleted(!rs.getBoolean("IsVisible"));
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
        java.util.Set<Integer> addedIds = new java.util.HashSet<>();
        
        // Removed c.UpdatedAt since ChatConversation doesn't have it
        String sql = "SELECT c.*, u.FullName AS OtherName, up.AvatarURL AS OtherAvatar, u.UserID AS OtherID " +
                     "FROM ChatConversation c " +
                     "JOIN ConversationParticipant cp1 ON c.ConversationID = cp1.ConversationID " +
                     "LEFT JOIN ConversationParticipant cp2 ON c.ConversationID = cp2.ConversationID AND cp2.UserID != ? " +
                     "LEFT JOIN [User] u ON cp2.UserID = u.UserID " +
                     "LEFT JOIN UserProfile up ON u.UserID = up.UserID " +
                     "WHERE cp1.UserID = ? " +
                     "ORDER BY c.CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int convId = rs.getInt("ConversationID");
                    if (!addedIds.add(convId)) {
                        continue; // Skip duplicate rows for group chats
                    }
                    
                    Conversation c = new Conversation();
                    c.setConversationId(convId);
                    c.setType(rs.getString("ConversationType"));
                    
                    if ("Direct".equals(rs.getString("ConversationType"))) {
                        c.setTitle(rs.getString("OtherName"));
                        c.setAvatarUrl(rs.getString("OtherAvatar"));
                        c.setOtherUserId(rs.getInt("OtherID"));
                    } else {
                        c.setTitle(rs.getString("GroupName"));
                    }
                    
                    c.setCreatedAt(rs.getTimestamp("CreatedAt"));
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

    // Count unread messages for a specific user
    public int getUnreadMessageCount(int userId) {
        String sql = "SELECT COUNT(*) FROM ChatMessage m " +
                     "JOIN ConversationParticipant cp ON m.ConversationID = cp.ConversationID " +
                     "WHERE cp.UserID = ? AND m.SenderID != ? AND m.IsRead = 0 AND m.IsVisible = 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(ChatDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return 0;
    }

    // Mark all messages in a conversation as read by a specific user
    public void markConversationAsRead(int conversationId, int userId) {
        String sql = "UPDATE ChatMessage SET IsRead = 1 WHERE ConversationID = ? AND SenderID != ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } catch (SQLException ex) {
            Logger.getLogger(ChatDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    // Create Group Conversation
    public int createGroupConversation(String groupName, int createdBy, String[] participantIds) {
        int newConversationId = -1;
        String insertConv = "INSERT INTO ChatConversation (ConversationType, GroupName, CreatedBy) OUTPUT INSERTED.ConversationID VALUES ('Group', ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(insertConv)) {
            ps.setString(1, groupName);
            ps.setInt(2, createdBy);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    newConversationId = rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(ChatDAO.class.getName()).log(Level.SEVERE, null, ex);
        }

        if (newConversationId != -1) {
            String insertPart = "INSERT INTO ConversationParticipant (ConversationID, UserID) VALUES (?, ?)";
            try (PreparedStatement ps = connection.prepareStatement(insertPart)) {
                // Add the creator
                ps.setInt(1, newConversationId);
                ps.setInt(2, createdBy);
                ps.executeUpdate();

                // Add all selected participants
                if (participantIds != null) {
                    for (String pIdStr : participantIds) {
                        try {
                            int pId = Integer.parseInt(pIdStr);
                            ps.setInt(1, newConversationId);
                            ps.setInt(2, pId);
                            ps.executeUpdate();
                        } catch (NumberFormatException ignored) {}
                    }
                }
            } catch (SQLException ex) {
                Logger.getLogger(ChatDAO.class.getName()).log(Level.SEVERE, null, ex);
            }
        }

        return newConversationId;
    }
}
