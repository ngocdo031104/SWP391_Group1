package Model;

import Entities.TourOperationLog;
import Utils.DBContext;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class TourOperationLogDAO extends DBContext {
    private static final Logger LOGGER = Logger.getLogger(TourOperationLogDAO.class.getName());

    /**
     * Thêm mới log hoạt động.
     */
    public boolean insertLog(int scheduleId, String activity, Integer operatedBy) {
        String sql = "INSERT INTO TourOperationLog (ScheduleID, Activity, OperatedBy, CreatedAt) VALUES (?, ?, ?, SYSDATETIME())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            ps.setString(2, activity);
            if (operatedBy != null) {
                ps.setInt(3, operatedBy);
            } else {
                ps.setNull(3, java.sql.Types.INTEGER);
            }
            
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi ghi nhật ký vận hành", ex);
        }
        return false;
    }

    /**
     * Lấy danh sách log hoạt động của một lịch trình cụ thể (dành cho Guide).
     */
    public List<TourOperationLog> getLogsByScheduleId(int scheduleId) {
        List<TourOperationLog> list = new ArrayList<>();
        String sql = "SELECT tol.LogID, tol.ScheduleID, tol.Activity, tol.OperatedBy, tol.CreatedAt, "
                   + "       u.FullName AS OperatorName, r.RoleName AS OperatorRole "
                   + "FROM TourOperationLog tol "
                   + "LEFT JOIN [User] u ON tol.OperatedBy = u.UserID "
                   + "LEFT JOIN [Role] r ON u.RoleID = r.RoleID "
                   + "WHERE tol.ScheduleID = ? "
                   + "ORDER BY tol.CreatedAt DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TourOperationLog log = new TourOperationLog();
                    log.setLogId(rs.getInt("LogID"));
                    log.setScheduleId(rs.getInt("ScheduleID"));
                    log.setActivity(rs.getString("Activity"));
                    
                    int operatedBy = rs.getInt("OperatedBy");
                    if (!rs.wasNull()) {
                        log.setOperatedBy(operatedBy);
                    }
                    log.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    log.setOperatorName(rs.getString("OperatorName"));
                    log.setOperatorRole(rs.getString("OperatorRole"));
                    list.add(log);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy nhật ký vận hành cho ScheduleID: " + scheduleId, ex);
        }
        return list;
    }

    /**
     * Lấy danh sách log hoạt động của một lịch trình cụ thể phân trang (dành cho Guide).
     */
    public List<TourOperationLog> getLogsByScheduleIdPaged(int scheduleId, int page, int size) {
        List<TourOperationLog> list = new ArrayList<>();
        String sql = "SELECT tol.LogID, tol.ScheduleID, tol.Activity, tol.OperatedBy, tol.CreatedAt, "
                   + "       u.FullName AS OperatorName, r.RoleName AS OperatorRole "
                   + "FROM TourOperationLog tol "
                   + "LEFT JOIN [User] u ON tol.OperatedBy = u.UserID "
                   + "LEFT JOIN [Role] r ON u.RoleID = r.RoleID "
                   + "WHERE tol.ScheduleID = ? "
                   + "ORDER BY tol.CreatedAt DESC "
                   + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        int offset = (page - 1) * size;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            ps.setInt(2, offset);
            ps.setInt(3, size);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TourOperationLog log = new TourOperationLog();
                    log.setLogId(rs.getInt("LogID"));
                    log.setScheduleId(rs.getInt("ScheduleID"));
                    log.setActivity(rs.getString("Activity"));
                    
                    int operatedBy = rs.getInt("OperatedBy");
                    if (!rs.wasNull()) {
                        log.setOperatedBy(operatedBy);
                    }
                    log.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    log.setOperatorName(rs.getString("OperatorName"));
                    log.setOperatorRole(rs.getString("OperatorRole"));
                    list.add(log);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy nhật ký vận hành phân trang cho ScheduleID: " + scheduleId, ex);
        }
        return list;
    }

    /**
     * Đếm tổng số log vận hành của một lịch trình để phân trang.
     */
    public int getLogsCountByScheduleId(int scheduleId) {
        String sql = "SELECT COUNT(*) FROM TourOperationLog WHERE ScheduleID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi đếm nhật ký vận hành cho ScheduleID: " + scheduleId, ex);
        }
        return 0;
    }

    /**
     * Lấy toàn bộ nhật ký vận hành có phân trang và tìm kiếm (dành cho Admin).
     */
    public List<TourOperationLog> getAllLogsPaged(int page, int size, String search) {
        List<TourOperationLog> list = new ArrayList<>();
        String searchPattern = (search == null || search.trim().isEmpty()) ? null : "%" + search.trim() + "%";
        
        String sql = "SELECT tol.LogID, tol.ScheduleID, tol.Activity, tol.OperatedBy, tol.CreatedAt, "
                   + "       t.TourName, ts.DepartureDate, "
                   + "       u.FullName AS OperatorName, r.RoleName AS OperatorRole "
                   + "FROM TourOperationLog tol "
                   + "JOIN TourSchedule ts ON tol.ScheduleID = ts.ScheduleID "
                   + "JOIN Tour t ON ts.TourID = t.TourID "
                   + "LEFT JOIN [User] u ON tol.OperatedBy = u.UserID "
                   + "LEFT JOIN [Role] r ON u.RoleID = r.RoleID "
                   + "WHERE (? IS NULL OR tol.Activity LIKE ? OR u.FullName LIKE ? OR t.TourName LIKE ?) "
                   + "ORDER BY tol.CreatedAt DESC "
                   + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        int offset = (page - 1) * size;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            ps.setInt(5, offset);
            ps.setInt(6, size);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TourOperationLog log = new TourOperationLog();
                    log.setLogId(rs.getInt("LogID"));
                    log.setScheduleId(rs.getInt("ScheduleID"));
                    log.setActivity(rs.getString("Activity"));
                    
                    int operatedBy = rs.getInt("OperatedBy");
                    if (!rs.wasNull()) {
                        log.setOperatedBy(operatedBy);
                    }
                    log.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    log.setTourName(rs.getString("TourName"));
                    log.setDepartureDate(rs.getTimestamp("DepartureDate"));
                    log.setOperatorName(rs.getString("OperatorName"));
                    log.setOperatorRole(rs.getString("OperatorRole"));
                    list.add(log);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy danh sách nhật ký vận hành phân trang", ex);
        }
        return list;
    }

    /**
     * Đếm tổng số log vận hành khớp tìm kiếm để phân trang.
     */
    public int getLogsCount(String search) {
        String searchPattern = (search == null || search.trim().isEmpty()) ? null : "%" + search.trim() + "%";
        String sql = "SELECT COUNT(*) "
                   + "FROM TourOperationLog tol "
                   + "JOIN TourSchedule ts ON tol.ScheduleID = ts.ScheduleID "
                   + "JOIN Tour t ON ts.TourID = t.TourID "
                   + "LEFT JOIN [User] u ON tol.OperatedBy = u.UserID "
                   + "WHERE (? IS NULL OR tol.Activity LIKE ? OR u.FullName LIKE ? OR t.TourName LIKE ?)";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi đếm nhật ký vận hành", ex);
        }
        return 0;
    }

    /**
     * Lấy tất cả nhật ký vận hành với phân trang (không tìm kiếm).
     */
    public List<TourOperationLog> getAllLogsPaged(int offset, int pageSize) {
        List<TourOperationLog> list = new ArrayList<>();
        String sql = "SELECT tol.LogID, tol.ScheduleID, tol.Activity, tol.OperatedBy, tol.CreatedAt, "
                   + "       t.TourName, ts.DepartureDate, "
                   + "       u.FullName AS OperatorName, r.RoleName AS OperatorRole "
                   + "FROM TourOperationLog tol "
                   + "JOIN TourSchedule ts ON tol.ScheduleID = ts.ScheduleID "
                   + "JOIN Tour t ON ts.TourID = t.TourID "
                   + "LEFT JOIN [User] u ON tol.OperatedBy = u.UserID "
                   + "LEFT JOIN [Role] r ON u.RoleID = r.RoleID "
                   + "ORDER BY tol.CreatedAt DESC "
                   + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, offset);
            ps.setInt(2, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TourOperationLog log = new TourOperationLog();
                    log.setLogId(rs.getInt("LogID"));
                    log.setScheduleId(rs.getInt("ScheduleID"));
                    log.setActivity(rs.getString("Activity"));

                    int operatedBy = rs.getInt("OperatedBy");
                    if (!rs.wasNull()) {
                        log.setOperatedBy(operatedBy);
                    }
                    log.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    log.setTourName(rs.getString("TourName"));
                    log.setDepartureDate(rs.getTimestamp("DepartureDate"));
                    log.setOperatorName(rs.getString("OperatorName"));
                    log.setOperatorRole(rs.getString("OperatorRole"));
                    list.add(log);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy tất cả nhật ký vận hành", ex);
        }
        return list;
    }

    /**
     * Đếm tổng số nhật ký vận hành.
     */
    public int getTotalLogsCount() {
        String sql = "SELECT COUNT(*) FROM TourOperationLog";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi đếm tổng nhật ký vận hành", ex);
        }
        return 0;
    }
}
