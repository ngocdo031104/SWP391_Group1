package Model;

import Entities.AuditLog;
import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class AuditLogDAO extends DBContext {
    public void insertLog(int adminId, String actionType, Integer targetRoleId, String details) {
        String sql = "INSERT INTO Audit_Log (AdminID, ActionType, TargetRoleID, Details) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, adminId);
            ps.setString(2, actionType);
            if (targetRoleId != null && targetRoleId > 0) {
                ps.setInt(3, targetRoleId);
            } else {
                ps.setNull(3, java.sql.Types.INTEGER);
            }
            ps.setString(4, details);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public java.util.List<AuditLog> getAllAuditLogs() {
        java.util.List<AuditLog> list = new java.util.ArrayList<>();
        String sql = "SELECT l.LogID, l.AdminID, u.Email as AdminEmail, l.ActionType, l.TargetRoleID, l.Details, l.CreatedAt "
                   + "FROM Audit_Log l "
                   + "JOIN [User] u ON l.AdminID = u.UserID "
                   + "ORDER BY l.CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             java.sql.ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                AuditLog log = new AuditLog();
                log.setLogId(rs.getInt("LogID"));
                log.setAdminId(rs.getInt("AdminID"));
                log.setActionType(rs.getString("ActionType"));
                if (rs.getObject("TargetRoleID") != null) {
                    log.setTargetRoleId(rs.getInt("TargetRoleID"));
                }
                // we'll prepend the admin email to the details for display convenience, 
                // or just store it in details but let's just append it for UI
                log.setDetails("Admin (" + rs.getString("AdminEmail") + "): " + rs.getString("Details"));
                log.setCreatedAt(rs.getTimestamp("CreatedAt"));
                list.add(log);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
