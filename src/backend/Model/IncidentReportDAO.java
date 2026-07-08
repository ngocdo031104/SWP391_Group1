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
}
