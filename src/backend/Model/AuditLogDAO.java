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

    public java.util.List<Entities.FinancialAuditDTO> getFinancialAuditLogs(String dateFrom, String dateTo, String operator, String status, String transactionRef, String discrepancy, int page, int pageSize) {
        java.util.List<Entities.FinancialAuditDTO> list = new java.util.ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT f.AuditID, f.Action, f.NewValues, f.PerformedBy, u.FullName as OperatorName, " +
            "f.CreatedAt, p.TransactionRef, p.BookingID, p.Amount, p.Currency, p.Status as PaymentStatus, " +
            "LTRIM(RTRIM(" +
            "   CASE WHEN p.Status = 'Success' AND i.InvoiceID IS NULL THEN N'Thiếu hóa đơn; ' ELSE '' END + " +
            "   CASE WHEN p.Status = 'Success' AND p.Amount <> b.TotalAmount THEN N'Lệch số tiền với Đơn hàng; ' ELSE '' END " +
            ")) AS DiscrepancyReason " +
            "FROM FinancialAuditLog f " +
            "LEFT JOIN Payment p ON f.EntityType = 'Payment' AND f.EntityID = p.PaymentID " +
            "LEFT JOIN [User] u ON f.PerformedBy = u.UserID " +
            "LEFT JOIN Booking b ON p.BookingID = b.BookingID " +
            "LEFT JOIN Invoice i ON p.PaymentID = i.PaymentID " +
            "WHERE 1=1 "
        );

        if (dateFrom != null && !dateFrom.trim().isEmpty()) {
            sql.append(" AND CAST(f.CreatedAt AS DATE) >= ?");
        }
        if (dateTo != null && !dateTo.trim().isEmpty()) {
            sql.append(" AND CAST(f.CreatedAt AS DATE) <= ?");
        }
        if (operator != null && !operator.trim().isEmpty()) {
            sql.append(" AND u.FullName LIKE ?");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND p.Status = ?");
        }
        if (transactionRef != null && !transactionRef.trim().isEmpty()) {
            sql.append(" AND p.TransactionRef LIKE ?");
        }
        if ("yes".equals(discrepancy)) {
            sql.append(" AND (p.Status = 'Success' AND (i.InvoiceID IS NULL OR p.Amount <> b.TotalAmount))");
        } else if ("no".equals(discrepancy)) {
            sql.append(" AND NOT (p.Status = 'Success' AND (i.InvoiceID IS NULL OR p.Amount <> b.TotalAmount))");
        }

        sql.append(" ORDER BY f.CreatedAt DESC");
        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (dateFrom != null && !dateFrom.trim().isEmpty()) {
                ps.setString(paramIndex++, dateFrom);
            }
            if (dateTo != null && !dateTo.trim().isEmpty()) {
                ps.setString(paramIndex++, dateTo);
            }
            if (operator != null && !operator.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + operator + "%");
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(paramIndex++, status);
            }
            if (transactionRef != null && !transactionRef.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + transactionRef + "%");
            }
            
            ps.setInt(paramIndex++, (page - 1) * pageSize);
            ps.setInt(paramIndex++, pageSize);

            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Entities.FinancialAuditDTO dto = new Entities.FinancialAuditDTO();
                    dto.setAuditId(rs.getInt("AuditID"));
                    dto.setActionType(rs.getString("Action"));
                    dto.setDescription(rs.getString("NewValues"));
                    dto.setOperatorId(rs.getInt("PerformedBy"));
                    dto.setOperatorName(rs.getString("OperatorName"));
                    dto.setTransactionRef(rs.getString("TransactionRef"));
                    dto.setBookingId(rs.getInt("BookingID"));
                    dto.setAmount(rs.getBigDecimal("Amount"));
                    dto.setCurrency(rs.getString("Currency"));
                    dto.setPaymentStatus(rs.getString("PaymentStatus"));
                    dto.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    
                    String discrepancyStr = rs.getString("DiscrepancyReason");
                    if (discrepancyStr != null && !discrepancyStr.trim().isEmpty()) {
                        dto.setIsDiscrepancy(true);
                        dto.setDiscrepancyReason(discrepancyStr);
                    } else {
                        dto.setIsDiscrepancy(false);
                    }
                    
                    list.add(dto);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getTotalFinancialAuditLogs(String dateFrom, String dateTo, String operator, String status, String transactionRef, String discrepancy) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM FinancialAuditLog f " +
            "LEFT JOIN Payment p ON f.EntityType = 'Payment' AND f.EntityID = p.PaymentID " +
            "LEFT JOIN [User] u ON f.PerformedBy = u.UserID " +
            "LEFT JOIN Booking b ON p.BookingID = b.BookingID " +
            "LEFT JOIN Invoice i ON p.PaymentID = i.PaymentID " +
            "WHERE 1=1 "
        );

        if (dateFrom != null && !dateFrom.trim().isEmpty()) {
            sql.append(" AND CAST(f.CreatedAt AS DATE) >= ?");
        }
        if (dateTo != null && !dateTo.trim().isEmpty()) {
            sql.append(" AND CAST(f.CreatedAt AS DATE) <= ?");
        }
        if (operator != null && !operator.trim().isEmpty()) {
            sql.append(" AND u.FullName LIKE ?");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND p.Status = ?");
        }
        if (transactionRef != null && !transactionRef.trim().isEmpty()) {
            sql.append(" AND p.TransactionRef LIKE ?");
        }
        if ("yes".equals(discrepancy)) {
            sql.append(" AND (p.Status = 'Success' AND (i.InvoiceID IS NULL OR p.Amount <> b.TotalAmount))");
        } else if ("no".equals(discrepancy)) {
            sql.append(" AND NOT (p.Status = 'Success' AND (i.InvoiceID IS NULL OR p.Amount <> b.TotalAmount))");
        }

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (dateFrom != null && !dateFrom.trim().isEmpty()) {
                ps.setString(paramIndex++, dateFrom);
            }
            if (dateTo != null && !dateTo.trim().isEmpty()) {
                ps.setString(paramIndex++, dateTo);
            }
            if (operator != null && !operator.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + operator + "%");
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(paramIndex++, status);
            }
            if (transactionRef != null && !transactionRef.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + transactionRef + "%");
            }

            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public java.util.Map<String, Object> getFinancialAuditStats(String dateFrom, String dateTo, String operator, String status, String transactionRef, String discrepancy) {
        java.util.Map<String, Object> stats = new java.util.HashMap<>();
        stats.put("total", 0);
        stats.put("success", 0);
        stats.put("failed", 0);
        stats.put("pending", 0);
        stats.put("totalAmount", java.math.BigDecimal.ZERO);

        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) as Total, " +
            "SUM(CASE WHEN p.Status = 'Success' THEN 1 ELSE 0 END) as SuccessCount, " +
            "SUM(CASE WHEN p.Status = 'Failed' THEN 1 ELSE 0 END) as FailedCount, " +
            "SUM(CASE WHEN p.Status = 'Pending' THEN 1 ELSE 0 END) as PendingCount, " +
            "SUM(CASE WHEN p.Status = 'Success' THEN p.Amount ELSE 0 END) as TotalAmount " +
            "FROM FinancialAuditLog f " +
            "LEFT JOIN Payment p ON f.EntityType = 'Payment' AND f.EntityID = p.PaymentID " +
            "LEFT JOIN [User] u ON f.PerformedBy = u.UserID " +
            "LEFT JOIN Booking b ON p.BookingID = b.BookingID " +
            "LEFT JOIN Invoice i ON p.PaymentID = i.PaymentID " +
            "WHERE 1=1 "
        );

        if (dateFrom != null && !dateFrom.trim().isEmpty()) {
            sql.append(" AND CAST(f.CreatedAt AS DATE) >= ?");
        }
        if (dateTo != null && !dateTo.trim().isEmpty()) {
            sql.append(" AND CAST(f.CreatedAt AS DATE) <= ?");
        }
        if (operator != null && !operator.trim().isEmpty()) {
            sql.append(" AND u.FullName LIKE ?");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND p.Status = ?");
        }
        if (transactionRef != null && !transactionRef.trim().isEmpty()) {
            sql.append(" AND p.TransactionRef LIKE ?");
        }
        if ("yes".equals(discrepancy)) {
            sql.append(" AND (p.Status = 'Success' AND (i.InvoiceID IS NULL OR p.Amount <> b.TotalAmount))");
        } else if ("no".equals(discrepancy)) {
            sql.append(" AND NOT (p.Status = 'Success' AND (i.InvoiceID IS NULL OR p.Amount <> b.TotalAmount))");
        }

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (dateFrom != null && !dateFrom.trim().isEmpty()) {
                ps.setString(paramIndex++, dateFrom);
            }
            if (dateTo != null && !dateTo.trim().isEmpty()) {
                ps.setString(paramIndex++, dateTo);
            }
            if (operator != null && !operator.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + operator + "%");
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(paramIndex++, status);
            }
            if (transactionRef != null && !transactionRef.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + transactionRef + "%");
            }

            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("total", rs.getInt("Total"));
                    stats.put("success", rs.getInt("SuccessCount"));
                    stats.put("failed", rs.getInt("FailedCount"));
                    stats.put("pending", rs.getInt("PendingCount"));
                    
                    java.math.BigDecimal totalAmount = rs.getBigDecimal("TotalAmount");
                    if (totalAmount != null) {
                        stats.put("totalAmount", totalAmount);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }

    public boolean createFinancialAuditLog(String entityType, int entityId, String action, String oldValues, String newValues, Integer performedBy) {
        String sql = "INSERT INTO FinancialAuditLog (EntityType, EntityID, Action, OldValues, NewValues, PerformedBy, CreatedAt) VALUES (?, ?, ?, ?, ?, ?, SYSDATETIME())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, entityType);
            ps.setInt(2, entityId);
            ps.setString(3, action);
            ps.setString(4, oldValues);
            ps.setString(5, newValues);
            if (performedBy != null && performedBy > 0) {
                ps.setInt(6, performedBy);
            } else {
                ps.setNull(6, java.sql.Types.INTEGER);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
