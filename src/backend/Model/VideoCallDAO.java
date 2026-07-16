package Model;

import Entities.VideoCallSchedule;
import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class VideoCallDAO extends DBContext {

    // Schedule a new video call
    public VideoCallSchedule scheduleCall(VideoCallSchedule call) {
        String sql = "INSERT INTO VideoCallSchedule (ConversationID, OrganizedBy, Title, ScheduledAt, DurationMin, MeetingURL, Status) " +
                     "OUTPUT INSERTED.CallID, INSERTED.CreatedAt " +
                     "VALUES (?, ?, ?, ?, ?, ?, 'Scheduled')";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, call.getConversationId());
            ps.setInt(2, call.getOrganizedBy());
            ps.setString(3, call.getTitle());
            ps.setTimestamp(4, call.getScheduledAt());
            ps.setInt(5, call.getDurationMin());
            ps.setString(6, call.getMeetingUrl());
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    call.setCallId(rs.getInt("CallID"));
                    call.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    call.setStatus("Scheduled");
                }
            }
            return call;
        } catch (SQLException ex) {
            Logger.getLogger(VideoCallDAO.class.getName()).log(Level.SEVERE, null, ex);
            return null;
        }
    }

    // Get upcoming calls for a conversation
    public List<VideoCallSchedule> getUpcomingCallsForConversation(int conversationId) {
        List<VideoCallSchedule> list = new ArrayList<>();
        // Fetch Scheduled or Ongoing calls, ordered by scheduled time
        String sql = "SELECT v.*, u.FullName as OrganizerName " +
                     "FROM VideoCallSchedule v " +
                     "JOIN [User] u ON v.OrganizedBy = u.UserID " +
                     "WHERE v.ConversationID = ? AND v.Status IN ('Scheduled', 'Ongoing') " +
                     "ORDER BY v.ScheduledAt ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    VideoCallSchedule v = new VideoCallSchedule();
                    v.setCallId(rs.getInt("CallID"));
                    v.setConversationId(rs.getInt("ConversationID"));
                    v.setOrganizedBy(rs.getInt("OrganizedBy"));
                    v.setTitle(rs.getString("Title"));
                    v.setScheduledAt(rs.getTimestamp("ScheduledAt"));
                    v.setDurationMin(rs.getInt("DurationMin"));
                    v.setMeetingUrl(rs.getString("MeetingURL"));
                    v.setStatus(rs.getString("Status"));
                    v.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    v.setOrganizerName(rs.getString("OrganizerName"));
                    list.add(v);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(VideoCallDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    // Update call status
    public boolean updateCallStatus(int callId, String status) {
        String sql = "UPDATE VideoCallSchedule SET Status = ? WHERE CallID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, callId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(VideoCallDAO.class.getName()).log(Level.SEVERE, null, ex);
            return false;
        }
    }

    // Get a specific call by ID
    public VideoCallSchedule getCallById(int callId) {
        String sql = "SELECT * FROM VideoCallSchedule WHERE CallID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, callId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    VideoCallSchedule v = new VideoCallSchedule();
                    v.setCallId(rs.getInt("CallID"));
                    v.setConversationId(rs.getInt("ConversationID"));
                    v.setOrganizedBy(rs.getInt("OrganizedBy"));
                    v.setTitle(rs.getString("Title"));
                    v.setScheduledAt(rs.getTimestamp("ScheduledAt"));
                    v.setDurationMin(rs.getInt("DurationMin"));
                    v.setMeetingUrl(rs.getString("MeetingURL"));
                    v.setStatus(rs.getString("Status"));
                    v.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    return v;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(VideoCallDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    // Update call details (Edit)
    public boolean updateCall(VideoCallSchedule call) {
        String sql = "UPDATE VideoCallSchedule SET Title = ?, ScheduledAt = ?, DurationMin = ?, MeetingURL = ? WHERE CallID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, call.getTitle());
            ps.setTimestamp(2, call.getScheduledAt());
            ps.setInt(3, call.getDurationMin());
            ps.setString(4, call.getMeetingUrl());
            ps.setInt(5, call.getCallId());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(VideoCallDAO.class.getName()).log(Level.SEVERE, null, ex);
            return false;
        }
    }

    // Check if user is in a conversation
    public boolean isUserInConversation(int userId, int conversationId) {
        String sql = "SELECT 1 FROM ConversationParticipant WHERE UserID = ? AND ConversationID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, conversationId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException ex) {
            Logger.getLogger(VideoCallDAO.class.getName()).log(Level.SEVERE, null, ex);
            return false;
        }
    }
}
