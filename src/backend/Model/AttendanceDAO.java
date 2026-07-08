package Model;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import Utils.DBContext;

public class AttendanceDAO extends DBContext {
    private static final Logger LOGGER = Logger.getLogger(AttendanceDAO.class.getName());

    /**
     * Lấy danh sách điểm danh của các hành khách trong một lịch trình cụ thể.
     */
    public List<Map<String, Object>> getAttendanceByScheduleId(int scheduleId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT bp.ParticipantID, bp.BookingID, bp.FullName, bp.PhoneNumber, bp.Email, bp.AgeType, bp.IsLeader, "
                   + "       a.CheckedIn, a.CheckInTime, a.Notes "
                   + "FROM BookingParticipant bp "
                   + "JOIN Booking b ON bp.BookingID = b.BookingID "
                   + "LEFT JOIN Attendance a ON bp.ParticipantID = a.ParticipantID AND a.ScheduleID = ? "
                   + "WHERE b.ScheduleID = ? AND b.Status != 'Cancelled'";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            ps.setInt(2, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("participantId", rs.getInt("ParticipantID"));
                    map.put("bookingId", rs.getInt("BookingID"));
                    map.put("fullName", rs.getString("FullName"));
                    map.put("phoneNumber", rs.getString("PhoneNumber"));
                    map.put("email", rs.getString("Email"));
                    map.put("ageType", rs.getString("AgeType"));
                    map.put("isLeader", rs.getBoolean("IsLeader"));
                    
                    // Boolean CheckedIn (bit trong database)
                    // Nếu LEFT JOIN không có bản ghi thì CheckedIn là false
                    boolean checkedIn = rs.getObject("CheckedIn") != null ? rs.getBoolean("CheckedIn") : false;
                    map.put("checkedIn", checkedIn);
                    map.put("checkInTime", rs.getTimestamp("CheckInTime"));
                    map.put("notes", rs.getString("Notes"));
                    list.add(map);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy danh sách điểm danh cho ScheduleID: " + scheduleId, ex);
        }
        return list;
    }

    /**
     * Lưu thông tin điểm danh (Thêm mới hoặc Cập nhật sử dụng MERGE).
     */
    public boolean saveAttendance(int scheduleId, int participantId, boolean checkedIn, int checkedBy, String notes) {
        String sql = "MERGE INTO Attendance AS target "
                   + "USING (SELECT ? AS ScheduleID, ? AS ParticipantID) AS source "
                   + "ON (target.ScheduleID = source.ScheduleID AND target.ParticipantID = source.ParticipantID) "
                   + "WHEN MATCHED THEN "
                   + "    UPDATE SET CheckedIn = ?, CheckInTime = ?, CheckedBy = ?, Notes = ? "
                   + "WHEN NOT MATCHED THEN "
                   + "    INSERT (ScheduleID, ParticipantID, CheckedIn, CheckInTime, CheckedBy, Notes) "
                   + "    VALUES (source.ScheduleID, source.ParticipantID, ?, ?, ?, ?);";

        Timestamp checkInTime = checkedIn ? new Timestamp(System.currentTimeMillis()) : null;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            // USING parameters
            ps.setInt(1, scheduleId);
            ps.setInt(2, participantId);
            
            // WHEN MATCHED (UPDATE) parameters
            ps.setBoolean(3, checkedIn);
            ps.setTimestamp(4, checkInTime);
            ps.setInt(5, checkedBy);
            ps.setString(6, notes);
            
            // WHEN NOT MATCHED (INSERT) parameters
            ps.setBoolean(7, checkedIn);
            ps.setTimestamp(8, checkInTime);
            ps.setInt(9, checkedBy);
            ps.setString(10, notes);
            
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi thực hiện lưu điểm danh", ex);
        }
        return false;
    }

    /**
     * Chỉ cập nhật ghi chú của hành khách (giữ nguyên trạng thái điểm danh hiện tại).
     */
    public boolean updateAttendanceNotes(int scheduleId, int participantId, String notes) {
        String sql = "MERGE INTO Attendance AS target "
                   + "USING (SELECT ? AS ScheduleID, ? AS ParticipantID) AS source "
                   + "ON (target.ScheduleID = source.ScheduleID AND target.ParticipantID = source.ParticipantID) "
                   + "WHEN MATCHED THEN "
                   + "    UPDATE SET Notes = ? "
                   + "WHEN NOT MATCHED THEN "
                   + "    INSERT (ScheduleID, ParticipantID, CheckedIn, CheckInTime, CheckedBy, Notes) "
                   + "    VALUES (source.ScheduleID, source.ParticipantID, 0, NULL, NULL, ?);";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            ps.setInt(2, participantId);
            ps.setString(3, notes);
            ps.setString(4, notes);
            
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi thực hiện cập nhật ghi chú điểm danh", ex);
        }
        return false;
    }
}
