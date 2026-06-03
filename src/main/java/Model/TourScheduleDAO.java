package Model;

// Người làm: Dương
// Thời gian tạo: 04/06/2026
// Chức năng: DAO xử lý dữ liệu bảng TourSchedule.
// Ý nghĩa: Cung cấp lịch khởi hành cho luồng booking Customer, lấy trực tiếp DepartureDate, ReturnDate, số ghế, giá và trạng thái từ database.

import Entities.TourSchedule;
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
    // Chỉ lấy các cột thực tế có trong bảng TourSchedule để tránh lỗi SQL làm danh sách lịch bị rỗng.
    private static final String SCHEDULE_SELECT =
            "SELECT ScheduleID, TourID, DepartureDate, ReturnDate, TotalSeats, AvailableSeats, "
            + "PriceAdult, PriceChild, PriceInfant, Transportation, Status, TourStatus, CreatedAt "
            + "FROM TourSchedule ";

    // Lấy toàn bộ lịch khởi hành thuộc một tour từ bảng TourSchedule.
    // Hàm không lọc cứng theo ngày hiện tại để dữ liệu seed/test trong DB vẫn hiện DepartureDate trên màn booking.
    public List<TourSchedule> getSchedulesByTourId(int tourId) {
        List<TourSchedule> schedules = new ArrayList<>();
        String sql = SCHEDULE_SELECT
                + "WHERE TourID = ? "
                + "ORDER BY DepartureDate ASC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
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

    // Lấy một lịch khởi hành theo cả ScheduleID và TourID.
    // Mục đích là validate lịch khách chọn thật sự thuộc tour hiện tại, tránh submit scheduleId của tour khác.
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

    // mapSchedule chuyển một dòng ResultSet thành entity TourSchedule.
    // Các trường ngày khởi hành, ngày về, số ghế và giá được lấy trực tiếp từ bảng TourSchedule để booking tính tiền đúng theo lịch đã chọn.
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

        // TourStatus mô tả trạng thái vận hành của lịch, ví dụ Scheduled/InProgress/Completed nếu database có lưu giá trị này.
        schedule.setTourStatus(rs.getString("TourStatus"));
        return schedule;
    }
}