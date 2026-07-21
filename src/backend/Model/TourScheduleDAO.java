package Model;

// Người làm: Dương (Updated by Antigravity)
// Thời gian tạo: 04/06/2026
// Chức năng: DAO xử lý dữ liệu bảng TourSchedule.
// Ý nghĩa: Cung cấp lịch khởi hành cho luồng booking Customer và các tác vụ CRUD của Admin.

import Entities.TourSchedule;
import Entities.Tour;
import Entities.User;
import Entities.UserProfile;
import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class TourScheduleDAO extends DBContext {

    // Câu SELECT dùng chung cho các hàm lấy lịch khởi hành.
    private static final String SCHEDULE_SELECT =
            "SELECT ScheduleID, TourID, DepartureDate, ReturnDate, TotalSeats, AvailableSeats, "
            + "PriceAdult, PriceChild, PriceInfant, Transportation, Status, TourStatus, CreatedAt "
            + "FROM TourSchedule ";

    // Lấy toàn bộ lịch khởi hành thuộc một tour từ bảng TourSchedule.
    public List<TourSchedule> getSchedulesByTourId(int tourId) {
        return getSchedulesByTourId(tourId, false);
    }

    // Lấy lịch khởi hành thuộc một tour, có tuỳ chọn lọc theo ngày hiện tại.
    // BR-19 / BR-20: với luồng Customer, chỉ trả về các lịch có DepartureDate >= hôm nay
    // để tránh khách đặt tour có ngày khởi hành ở quá khứ.
    public List<TourSchedule> getSchedulesByTourId(int tourId, boolean futureOnly) {
        List<TourSchedule> schedules = new ArrayList<>();
        StringBuilder sql = new StringBuilder(SCHEDULE_SELECT)
                .append("WHERE TourID = ? ");
        if (futureOnly) {
            sql.append("AND CAST(DepartureDate AS DATE) >= CAST(GETDATE() AS DATE) ");
        }
        sql.append("ORDER BY DepartureDate ASC");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            ps.setInt(1, tourId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    schedules.add(mapSchedule(rs));
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourScheduleDAO.class.getName()).log(Level.SEVERE, "getSchedulesByTourId failed", ex);
        }
        return schedules;
    }

    // Lấy toàn bộ lịch khởi hành cho Admin (bao gồm cả lịch cũ và thông tin Hướng dẫn viên).
    public List<TourSchedule> getSchedulesByTourIdForAdmin(int tourId) {
        List<TourSchedule> list = new ArrayList<>();
        String sql = "SELECT ts.ScheduleID, ts.TourID, ts.DepartureDate, ts.ReturnDate, ts.TotalSeats, ts.AvailableSeats, "
                   + "ts.PriceAdult, ts.PriceChild, ts.PriceInfant, ts.Transportation, ts.Status, ts.CreatedAt, "
                   + "ts.GuideID, ts.TourStatus, "
                   + "u.Email, u.FullName, u.PhoneNumber, "
                   + "up.AvatarURL, "
                   + "ta.Notes as AssignmentNotes "
                   + "FROM TourSchedule ts "
                   + "LEFT JOIN [User] u ON ts.GuideID = u.UserID "
                   + "LEFT JOIN UserProfile up ON u.UserID = up.UserID "
                   + "LEFT JOIN TourAssignment ta ON ts.ScheduleID = ta.ScheduleID AND ts.GuideID = ta.GuideID "
                   + "WHERE ts.TourID = ? "
                   + "ORDER BY ts.DepartureDate DESC";
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
                    sched.setNotes(rs.getString("AssignmentNotes"));
                    
                    int guideId = rs.getInt("GuideID");
                    if (!rs.wasNull()) {
                        sched.setGuideId(guideId);
                        sched.setTourStatus(rs.getString("TourStatus"));
                        
                        User u = new User();
                        u.setUserId(guideId);
                        u.setEmail(rs.getString("Email"));
                        u.setFullName(rs.getString("FullName"));
                        u.setPhoneNumber(rs.getString("PhoneNumber"));
                        
                        UserProfile up = new UserProfile();
                        up.setUserId(guideId);
                        up.setAvatarUrl(rs.getString("AvatarURL"));
                        u.setProfile(up);
                        
                        sched.setGuide(u);
                    }
                    list.add(sched);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourScheduleDAO.class.getName()).log(Level.SEVERE, "getSchedulesByTourIdForAdmin failed", ex);
        }
        return list;
    }

    // Lấy một lịch khởi hành theo cả ScheduleID và TourID.
    public TourSchedule getScheduleByIdForTour(int scheduleId, int tourId) {
        String sql = SCHEDULE_SELECT
                + "WHERE ScheduleID = ? AND TourID = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            ps.setInt(2, tourId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapSchedule(rs);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourScheduleDAO.class.getName()).log(Level.SEVERE, "getScheduleByIdForTour failed", ex);
        }
        return null;
    }

    // Lấy một lịch khởi hành theo ScheduleID.
    public TourSchedule getScheduleById(int scheduleId) {
        String sql = SCHEDULE_SELECT + "WHERE ScheduleID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapSchedule(rs);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourScheduleDAO.class.getName()).log(Level.SEVERE, "getScheduleById failed", ex);
        }
        return null;
    }

    // Thêm lịch khởi hành mới
    public int insertSchedule(TourSchedule schedule) {
        String sql = "INSERT INTO TourSchedule (TourID, DepartureDate, ReturnDate, TotalSeats, AvailableSeats, "
                   + "PriceAdult, PriceChild, PriceInfant, Transportation, Status, GuideID, TourStatus, CreatedAt) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATETIME())";
        try (PreparedStatement ps = connection.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, schedule.getTourId());
            ps.setDate(2, schedule.getDepartureDate());
            ps.setDate(3, schedule.getReturnDate());
            ps.setInt(4, schedule.getTotalSeats());
            ps.setInt(5, schedule.getAvailableSeats());
            ps.setDouble(6, schedule.getPriceAdult());
            ps.setDouble(7, schedule.getPriceChild());
            ps.setDouble(8, schedule.getPriceInfant());
            ps.setString(9, schedule.getTransportation());
            ps.setString(10, schedule.getStatus());
            if (schedule.getGuideId() != null && schedule.getGuideId() > 0) {
                ps.setInt(11, schedule.getGuideId());
            } else {
                ps.setNull(11, java.sql.Types.INTEGER);
            }
            ps.setString(12, schedule.getTourStatus() != null ? schedule.getTourStatus() : "Scheduled");
            
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        return keys.getInt(1);
                    }
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourScheduleDAO.class.getName()).log(Level.SEVERE, "insertSchedule failed", ex);
        }
        return -1;
    }

    // Cập nhật lịch khởi hành
    public boolean updateSchedule(TourSchedule schedule) {
        String sql = "UPDATE TourSchedule SET DepartureDate = ?, ReturnDate = ?, TotalSeats = ?, AvailableSeats = ?, "
                   + "PriceAdult = ?, PriceChild = ?, PriceInfant = ?, Transportation = ?, Status = ?, GuideID = ?, TourStatus = ? "
                   + "WHERE ScheduleID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, schedule.getDepartureDate());
            ps.setDate(2, schedule.getReturnDate());
            ps.setInt(3, schedule.getTotalSeats());
            ps.setInt(4, schedule.getAvailableSeats());
            ps.setDouble(5, schedule.getPriceAdult());
            ps.setDouble(6, schedule.getPriceChild());
            ps.setDouble(7, schedule.getPriceInfant());
            ps.setString(8, schedule.getTransportation());
            ps.setString(9, schedule.getStatus());
            if (schedule.getGuideId() != null && schedule.getGuideId() > 0) {
                ps.setInt(10, schedule.getGuideId());
            } else {
                ps.setNull(10, java.sql.Types.INTEGER);
            }
            ps.setString(11, schedule.getTourStatus());
            ps.setInt(12, schedule.getScheduleId());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(TourScheduleDAO.class.getName()).log(Level.SEVERE, "updateSchedule failed", ex);
        }
        return false;
    }

    // Xóa lịch khởi hành
    public boolean deleteSchedule(int scheduleId) {
        String sql = "DELETE FROM TourSchedule WHERE ScheduleID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(TourScheduleDAO.class.getName()).log(Level.SEVERE, "deleteSchedule failed", ex);
        }
        return false;
    }

    private TourSchedule mapSchedule(ResultSet rs) throws SQLException {
        TourSchedule schedule = new TourSchedule(
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

        schedule.setTourStatus(rs.getString("TourStatus"));

        // Load tour info if available
        try {
            TourDAO tourDAO = new TourDAO();
            Tour tour = tourDAO.getTourById(rs.getInt("TourID"));
            schedule.setTour(tour);
        } catch (Exception e) {
            // Ignore if tour loading fails
        }

        return schedule;
    }

    // Lấy danh sách lịch khởi hành chưa có guide
    public List<TourSchedule> getUnassignedSchedules() {
        List<TourSchedule> list = new ArrayList<>();
        String sql = SCHEDULE_SELECT
                + "WHERE GuideID IS NULL AND TourStatus != 'Completed' AND TourStatus != 'Cancelled' "
                + "ORDER BY DepartureDate ASC";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapSchedule(rs));
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourScheduleDAO.class.getName()).log(Level.SEVERE, "getUnassignedSchedules failed", ex);
        }
        return list;
    }

    // Lấy danh sách tất cả lịch khởi hành có guide
    public List<TourSchedule> getAssignedSchedules() {
        List<TourSchedule> list = new ArrayList<>();
        String sql = SCHEDULE_SELECT
                + "WHERE GuideID IS NOT NULL "
                + "ORDER BY DepartureDate DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapSchedule(rs));
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourScheduleDAO.class.getName()).log(Level.SEVERE, "getAssignedSchedules failed", ex);
        }
        return list;
    }
}