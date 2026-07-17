package Model;

import Entities.IncidentReport;
import Utils.DBContext;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class IncidentReportDAO extends DBContext {
    private static final Logger LOGGER = Logger.getLogger(IncidentReportDAO.class.getName());

    /**
     * Báo cáo sự cố mới (Trạng thái mặc định là 'Open').
     */
    public boolean insertIncidentReport(IncidentReport report) {
        String sql = "INSERT INTO IncidentReport (ScheduleID, ReportedBy, Title, Description, Severity, Status) "
                   + "VALUES (?, ?, ?, ?, ?, 'Open')";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, report.getScheduleId());
            ps.setInt(2, report.getReportedBy());
            ps.setString(3, report.getTitle());
            ps.setString(4, report.getDescription());
            ps.setString(5, report.getSeverity());
            
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi báo cáo sự cố mới", ex);
        }
        return false;
    }

    /**
     * Lấy danh sách sự cố đã báo cáo của lịch trình cụ thể.
     */
    public List<IncidentReport> getIncidentsByScheduleId(int scheduleId) {
        List<IncidentReport> list = new ArrayList<>();
        String sql = "SELECT ir.IncidentID, ir.ScheduleID, ir.ReportedBy, u.FullName AS ReporterName, "
                   + "       ir.Title, ir.Description, ir.Severity, ir.Status, ir.ResolvedBy, ir.ResolvedAt, ir.CreatedAt "
                   + "FROM IncidentReport ir "
                   + "JOIN [User] u ON ir.ReportedBy = u.UserID "
                   + "WHERE ir.ScheduleID = ? "
                   + "ORDER BY ir.CreatedAt DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    IncidentReport ir = new IncidentReport();
                    ir.setIncidentId(rs.getInt("IncidentID"));
                    ir.setScheduleId(rs.getInt("ScheduleID"));
                    ir.setReportedBy(rs.getInt("ReportedBy"));
                    ir.setReportedByName(rs.getString("ReporterName"));
                    ir.setTitle(rs.getString("Title"));
                    ir.setDescription(rs.getString("Description"));
                    ir.setSeverity(rs.getString("Severity"));
                    ir.setStatus(rs.getString("Status"));
                    
                    int resolvedBy = rs.getInt("ResolvedBy");
                    if (!rs.wasNull()) {
                        ir.setResolvedBy(resolvedBy);
                    }
                    ir.setResolvedAt(rs.getTimestamp("ResolvedAt"));
                    ir.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    
                    list.add(ir);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy danh sách sự cố cho ScheduleID: " + scheduleId, ex);
        }
        return list;
    }

    /**
     * Lấy thông tin một sự cố cụ thể bằng ID.
     */
    public IncidentReport getIncidentById(int incidentId) {
        String sql = "SELECT * FROM IncidentReport WHERE IncidentID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, incidentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    IncidentReport ir = new IncidentReport();
                    ir.setIncidentId(rs.getInt("IncidentID"));
                    ir.setScheduleId(rs.getInt("ScheduleID"));
                    ir.setReportedBy(rs.getInt("ReportedBy"));
                    ir.setTitle(rs.getString("Title"));
                    ir.setDescription(rs.getString("Description"));
                    ir.setSeverity(rs.getString("Severity"));
                    ir.setStatus(rs.getString("Status"));
                    return ir;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy thông tin sự cố ID: " + incidentId, ex);
        }
        return null;
    }

    /**
     * Cập nhật trạng thái xử lý sự cố.
     */
    public boolean updateIncidentStatus(int incidentId, String status, int resolvedBy) {
        String sql;
        if ("Resolved".equals(status) || "Closed".equals(status) || "Dismissed".equals(status)) {
            sql = "UPDATE IncidentReport SET Status = ?, ResolvedBy = ?, ResolvedAt = ? WHERE IncidentID = ?";
        } else {
            sql = "UPDATE IncidentReport SET Status = ?, ResolvedBy = NULL, ResolvedAt = NULL WHERE IncidentID = ?";
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            if ("Resolved".equals(status) || "Closed".equals(status) || "Dismissed".equals(status)) {
                ps.setInt(2, resolvedBy);
                ps.setTimestamp(3, new java.sql.Timestamp(System.currentTimeMillis()));
            }
            ps.setInt(status.startsWith("Resolved") || status.startsWith("Closed") || status.startsWith("Dismissed") ? 4 : 2, incidentId);

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi cập nhật trạng thái sự cố ID: " + incidentId, ex);
        }
        return false;
    }

    /**
     * Lấy tất cả incidents với thông tin chi tiết (tour, guide).
     */
    public List<IncidentReport> getAllIncidentsWithDetails(String statusFilter) {
        List<IncidentReport> list = new ArrayList<>();
        String sql = "SELECT ir.IncidentID, ir.ScheduleID, ir.ReportedBy, ir.Title, ir.Description, ir.Severity, ir.Status, "
                   + "ir.ResolvedBy, ir.ResolvedAt, ir.CreatedAt, "
                   + "reporter.FullName AS ReporterName, "
                   + "ts.DepartureDate, ts.ReturnDate, "
                   + "t.TourName, t.Destination, "
                   + "g.FullName AS GuideName "
                   + "FROM IncidentReport ir "
                   + "JOIN [User] reporter ON ir.ReportedBy = reporter.UserID "
                   + "JOIN TourSchedule ts ON ir.ScheduleID = ts.ScheduleID "
                   + "JOIN Tour t ON ts.TourID = t.TourID "
                   + "LEFT JOIN [User] g ON ts.GuideID = g.UserID "
                   + "WHERE 1=1 ";

        if (statusFilter != null && !statusFilter.isEmpty() && !"All".equals(statusFilter)) {
            sql += "AND ir.Status = ? ";
        }
        sql += "ORDER BY ir.CreatedAt DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (statusFilter != null && !statusFilter.isEmpty() && !"All".equals(statusFilter)) {
                ps.setString(1, statusFilter);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    IncidentReport ir = new IncidentReport();
                    ir.setIncidentId(rs.getInt("IncidentID"));
                    ir.setScheduleId(rs.getInt("ScheduleID"));
                    ir.setReportedBy(rs.getInt("ReportedBy"));
                    ir.setReportedByName(rs.getString("ReporterName"));
                    ir.setTitle(rs.getString("Title"));
                    ir.setDescription(rs.getString("Description"));
                    ir.setSeverity(rs.getString("Severity"));
                    ir.setStatus(rs.getString("Status"));

                    int resolvedBy = rs.getInt("ResolvedBy");
                    if (!rs.wasNull()) {
                        ir.setResolvedBy(resolvedBy);
                    }
                    ir.setResolvedAt(rs.getTimestamp("ResolvedAt"));
                    ir.setCreatedAt(rs.getTimestamp("CreatedAt"));

                    // Thông tin tour
                    ir.setTourName(rs.getString("TourName"));
                    ir.setDestination(rs.getString("Destination"));
                    ir.setDepartureDate(rs.getDate("DepartureDate"));
                    ir.setGuideName(rs.getString("GuideName"));

                    list.add(ir);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy danh sách tất cả incidents", ex);
        }
        return list;
    }

    /**
     * Đếm số incidents theo trạng thái.
     */
    public int countIncidentsByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM IncidentReport WHERE Status = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi đếm incidents", ex);
        }
        return 0;
    }
}
