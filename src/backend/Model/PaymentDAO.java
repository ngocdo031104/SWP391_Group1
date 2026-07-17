package Model;

import Entities.Payment;
import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PaymentDAO extends DBContext {

    /**
     * Records a new payment transaction.
     * @param payment payment details
     * @return true if created successfully, false otherwise
     */
    public boolean createPayment(Payment payment) {
        String sql = "INSERT INTO Payment (BookingID, PaymentMethod, TransactionRef, Amount, Currency, Status, PaidAt, GatewayResponse, CreatedAt) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, SYSDATETIME())";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, payment.getBookingId());
            ps.setString(2, payment.getPaymentMethod());
            ps.setString(3, payment.getTransactionRef());
            ps.setDouble(4, payment.getAmount());
            ps.setString(5, payment.getCurrency());
            ps.setString(6, payment.getStatus());
            ps.setTimestamp(7, payment.getPaidAt());
            ps.setString(8, payment.getGatewayResponse());
            
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet gk = ps.getGeneratedKeys()) {
                    if (gk.next()) {
                        payment.setPaymentId(gk.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException ex) {
            Logger.getLogger(PaymentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    /**
     * Updates payment status by transaction reference (often used in callbacks from payment gateways).
     * @param transactionRef the payment gateway transaction reference
     * @param status the payment status (e.g. Success, Failed)
     * @param paidAt timestamp of payment completion
     * @return true if updated, false otherwise
     */
    public boolean updatePaymentStatus(String transactionRef, String status, Timestamp paidAt) {
        String sql = "UPDATE Payment SET Status = ?, PaidAt = ? WHERE TransactionRef = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setTimestamp(2, paidAt);
            ps.setString(3, transactionRef);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(PaymentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }
    // Dương làm đoạn này: kiểm tra mã giao dịch SePay đã từng được lưu chưa.
    // Method này giúp webhook không tạo trùng Payment khi SePay gửi lại cùng một giao dịch nhiều lần.
    public boolean existsByTransactionRef(String transactionRef) {
        String sql = "SELECT 1 FROM Payment WHERE TransactionRef = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, transactionRef);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException ex) {
            Logger.getLogger(PaymentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    // Dương làm phần này: lấy thông tin thanh toán theo mã đơn đặt
    public Payment getPaymentByBookingId(int bookingId) {
        String sql = "SELECT PaymentID, BookingID, PaymentMethod, TransactionRef, Amount, Currency, Status, PaidAt, GatewayResponse, CreatedAt "
                   + "FROM Payment WHERE BookingID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Payment(
                        rs.getInt("PaymentID"),
                        rs.getInt("BookingID"),
                        rs.getString("PaymentMethod"),
                        rs.getString("TransactionRef"),
                        rs.getDouble("Amount"),
                        rs.getString("Currency"),
                        rs.getString("Status"),
                        rs.getTimestamp("PaidAt"),
                        rs.getString("GatewayResponse"),
                        rs.getTimestamp("CreatedAt")
                    );
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(PaymentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    public java.util.List<Payment> getPaymentsByStatusForAccountant(String statusFilter, String dateFrom, String dateTo, String keyword, int offset, int pageSize) {
        java.util.List<Payment> list = new java.util.ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT PaymentID, BookingID, PaymentMethod, TransactionRef, Amount, Currency, Status, PaidAt, GatewayResponse, CreatedAt FROM Payment WHERE Status = ? ");
        
        if (dateFrom != null && !dateFrom.trim().isEmpty()) {
            sql.append(" AND CAST(PaidAt AS DATE) >= ? ");
        }
        if (dateTo != null && !dateTo.trim().isEmpty()) {
            sql.append(" AND CAST(PaidAt AS DATE) <= ? ");
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (TransactionRef LIKE ? OR CAST(BookingID AS VARCHAR) LIKE ?) ");
        }
        
        sql.append(" ORDER BY PaidAt DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            ps.setString(paramIndex++, statusFilter);
            
            if (dateFrom != null && !dateFrom.trim().isEmpty()) {
                ps.setString(paramIndex++, dateFrom);
            }
            if (dateTo != null && !dateTo.trim().isEmpty()) {
                ps.setString(paramIndex++, dateTo);
            }
            if (keyword != null && !keyword.trim().isEmpty()) {
                String likeKeyword = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, likeKeyword);
                ps.setString(paramIndex++, likeKeyword);
            }
            
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex++, pageSize);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Payment(
                        rs.getInt("PaymentID"),
                        rs.getInt("BookingID"),
                        rs.getString("PaymentMethod"),
                        rs.getString("TransactionRef"),
                        rs.getDouble("Amount"),
                        rs.getString("Currency"),
                        rs.getString("Status"),
                        rs.getTimestamp("PaidAt"),
                        rs.getString("GatewayResponse"),
                        rs.getTimestamp("CreatedAt")
                    ));
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(PaymentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    public int countPaymentsByStatus(String statusFilter, String dateFrom, String dateTo, String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Payment WHERE Status = ? ");
        
        if (dateFrom != null && !dateFrom.trim().isEmpty()) {
            sql.append(" AND CAST(PaidAt AS DATE) >= ? ");
        }
        if (dateTo != null && !dateTo.trim().isEmpty()) {
            sql.append(" AND CAST(PaidAt AS DATE) <= ? ");
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (TransactionRef LIKE ? OR CAST(BookingID AS VARCHAR) LIKE ?) ");
        }
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            ps.setString(paramIndex++, statusFilter);
            
            if (dateFrom != null && !dateFrom.trim().isEmpty()) {
                ps.setString(paramIndex++, dateFrom);
            }
            if (dateTo != null && !dateTo.trim().isEmpty()) {
                ps.setString(paramIndex++, dateTo);
            }
            if (keyword != null && !keyword.trim().isEmpty()) {
                String likeKeyword = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, likeKeyword);
                ps.setString(paramIndex++, likeKeyword);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(PaymentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return 0;
    }

    public double sumPaymentsByStatus(String statusFilter, String dateFrom, String dateTo) {
        StringBuilder sql = new StringBuilder("SELECT SUM(Amount) FROM Payment WHERE Status = ? ");
        
        if (dateFrom != null && !dateFrom.trim().isEmpty()) {
            sql.append(" AND CAST(PaidAt AS DATE) >= ? ");
        }
        if (dateTo != null && !dateTo.trim().isEmpty()) {
            sql.append(" AND CAST(PaidAt AS DATE) <= ? ");
        }
        
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            ps.setString(paramIndex++, statusFilter);
            
            if (dateFrom != null && !dateFrom.trim().isEmpty()) {
                ps.setString(paramIndex++, dateFrom);
            }
            if (dateTo != null && !dateTo.trim().isEmpty()) {
                ps.setString(paramIndex++, dateTo);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(PaymentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return 0.0;
    }

    public java.util.List<Entities.FraudTransactionDTO> getFraudulentTransactions(String dateFrom, String dateTo, String bookingId, String transactionRef, String gateway, String paymentStatus, String reviewStatus, int page, int pageSize) {
        java.util.List<Entities.FraudTransactionDTO> list = new java.util.ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT p.PaymentID, p.TransactionRef, p.BookingID, p.Amount, p.Currency, p.Status as PaymentStatus, p.PaidAt, p.GatewayResponse, " +
            "b.TotalAmount as ExpectedAmount, u.FullName as CustomerName, " +
            "COALESCE(fa.Status, 'Pending') as ReviewStatus, " +
            "COALESCE(fa.Description, " +
            "  CASE " +
            "    WHEN p.Amount <> b.TotalAmount THEN N'Lệch số tiền thanh toán' " +
            "    WHEN (SELECT COUNT(*) FROM Payment p2 WHERE p2.BookingID = p.BookingID AND p2.Status = 'Success') > 1 THEN N'Thanh toán trùng lặp cho đơn hàng' " +
            "    ELSE N'Nghi vấn chung' " +
            "  END" +
            ") as FraudReason " +
            "FROM Payment p " +
            "JOIN Booking b ON p.BookingID = b.BookingID " +
            "JOIN [User] u ON b.CustomerID = u.UserID " +
            "LEFT JOIN FraudAlert fa ON p.PaymentID = fa.PaymentID " +
            "WHERE (p.Amount <> b.TotalAmount OR (SELECT COUNT(*) FROM Payment p2 WHERE p2.BookingID = p.BookingID AND p2.Status = 'Success') > 1) "
        );

        if (dateFrom != null && !dateFrom.trim().isEmpty()) {
            sql.append(" AND CAST(p.PaidAt AS DATE) >= ? ");
        }
        if (dateTo != null && !dateTo.trim().isEmpty()) {
            sql.append(" AND CAST(p.PaidAt AS DATE) <= ? ");
        }
        if (bookingId != null && !bookingId.trim().isEmpty()) {
            sql.append(" AND p.BookingID = ? ");
        }
        if (transactionRef != null && !transactionRef.trim().isEmpty()) {
            sql.append(" AND p.TransactionRef LIKE ? ");
        }
        if (gateway != null && !gateway.trim().isEmpty()) {
            sql.append(" AND p.PaymentMethod LIKE ? ");
        }
        if (paymentStatus != null && !paymentStatus.trim().isEmpty()) {
            sql.append(" AND p.Status = ? ");
        }
        if (reviewStatus != null && !reviewStatus.trim().isEmpty()) {
            if ("Pending".equals(reviewStatus)) {
                sql.append(" AND (fa.Status IS NULL OR fa.Status = 'Pending') ");
            } else {
                sql.append(" AND fa.Status = ? ");
            }
        }

        sql.append(" ORDER BY p.PaidAt DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (dateFrom != null && !dateFrom.trim().isEmpty()) ps.setString(paramIndex++, dateFrom);
            if (dateTo != null && !dateTo.trim().isEmpty()) ps.setString(paramIndex++, dateTo);
            if (bookingId != null && !bookingId.trim().isEmpty()) ps.setInt(paramIndex++, Integer.parseInt(bookingId));
            if (transactionRef != null && !transactionRef.trim().isEmpty()) ps.setString(paramIndex++, "%" + transactionRef + "%");
            if (gateway != null && !gateway.trim().isEmpty()) ps.setString(paramIndex++, "%" + gateway + "%");
            if (paymentStatus != null && !paymentStatus.trim().isEmpty()) ps.setString(paramIndex++, paymentStatus);
            if (reviewStatus != null && !reviewStatus.trim().isEmpty() && !"Pending".equals(reviewStatus)) ps.setString(paramIndex++, reviewStatus);
            
            ps.setInt(paramIndex++, (page - 1) * pageSize);
            ps.setInt(paramIndex++, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Entities.FraudTransactionDTO dto = new Entities.FraudTransactionDTO();
                    dto.setPaymentId(rs.getInt("PaymentID"));
                    dto.setTransactionRef(rs.getString("TransactionRef"));
                    dto.setBookingId(rs.getInt("BookingID"));
                    dto.setAmount(rs.getBigDecimal("Amount"));
                    dto.setExpectedAmount(rs.getBigDecimal("ExpectedAmount"));
                    dto.setCustomerName(rs.getString("CustomerName"));
                    dto.setCurrency(rs.getString("Currency"));
                    dto.setPaymentStatus(rs.getString("PaymentStatus"));
                    dto.setPaidAt(rs.getTimestamp("PaidAt"));
                    dto.setGatewayResponse(rs.getString("GatewayResponse"));
                    dto.setFraudReason(rs.getString("FraudReason"));
                    dto.setReviewStatus(rs.getString("ReviewStatus"));
                    list.add(dto);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(PaymentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    public int getTotalFraudulentTransactions(String dateFrom, String dateTo, String bookingId, String transactionRef, String gateway, String paymentStatus, String reviewStatus) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM Payment p " +
            "JOIN Booking b ON p.BookingID = b.BookingID " +
            "LEFT JOIN FraudAlert fa ON p.PaymentID = fa.PaymentID " +
            "WHERE (p.Amount <> b.TotalAmount OR (SELECT COUNT(*) FROM Payment p2 WHERE p2.BookingID = p.BookingID AND p2.Status = 'Success') > 1) "
        );

        if (dateFrom != null && !dateFrom.trim().isEmpty()) {
            sql.append(" AND CAST(p.PaidAt AS DATE) >= ? ");
        }
        if (dateTo != null && !dateTo.trim().isEmpty()) {
            sql.append(" AND CAST(p.PaidAt AS DATE) <= ? ");
        }
        if (bookingId != null && !bookingId.trim().isEmpty()) {
            sql.append(" AND p.BookingID = ? ");
        }
        if (transactionRef != null && !transactionRef.trim().isEmpty()) {
            sql.append(" AND p.TransactionRef LIKE ? ");
        }
        if (gateway != null && !gateway.trim().isEmpty()) {
            sql.append(" AND p.PaymentMethod LIKE ? ");
        }
        if (paymentStatus != null && !paymentStatus.trim().isEmpty()) {
            sql.append(" AND p.Status = ? ");
        }
        if (reviewStatus != null && !reviewStatus.trim().isEmpty()) {
            if ("Pending".equals(reviewStatus)) {
                sql.append(" AND (fa.Status IS NULL OR fa.Status = 'Pending') ");
            } else {
                sql.append(" AND fa.Status = ? ");
            }
        }

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (dateFrom != null && !dateFrom.trim().isEmpty()) ps.setString(paramIndex++, dateFrom);
            if (dateTo != null && !dateTo.trim().isEmpty()) ps.setString(paramIndex++, dateTo);
            if (bookingId != null && !bookingId.trim().isEmpty()) ps.setInt(paramIndex++, Integer.parseInt(bookingId));
            if (transactionRef != null && !transactionRef.trim().isEmpty()) ps.setString(paramIndex++, "%" + transactionRef + "%");
            if (gateway != null && !gateway.trim().isEmpty()) ps.setString(paramIndex++, "%" + gateway + "%");
            if (paymentStatus != null && !paymentStatus.trim().isEmpty()) ps.setString(paramIndex++, paymentStatus);
            if (reviewStatus != null && !reviewStatus.trim().isEmpty() && !"Pending".equals(reviewStatus)) ps.setString(paramIndex++, reviewStatus);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException ex) {
            Logger.getLogger(PaymentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return 0;
    }

    public java.util.Map<String, Object> getFraudulentStats() {
        java.util.Map<String, Object> stats = new java.util.HashMap<>();
        stats.put("suspicious", 0);
        stats.put("duplicate", 0);
        stats.put("mismatch", 0);
        stats.put("successCount", 0);
        
        String sql = "SELECT " +
            "SUM(CASE WHEN (SELECT COUNT(*) FROM Payment p2 WHERE p2.BookingID = p.BookingID AND p2.Status = 'Success') > 1 THEN 1 ELSE 0 END) as DuplicateCount, " +
            "SUM(CASE WHEN p.Amount <> b.TotalAmount THEN 1 ELSE 0 END) as MismatchCount, " +
            "COUNT(*) as SuspiciousCount " +
            "FROM Payment p " +
            "JOIN Booking b ON p.BookingID = b.BookingID " +
            "WHERE (p.Amount <> b.TotalAmount OR (SELECT COUNT(*) FROM Payment p2 WHERE p2.BookingID = p.BookingID AND p2.Status = 'Success') > 1)";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("suspicious", rs.getInt("SuspiciousCount"));
                stats.put("duplicate", rs.getInt("DuplicateCount"));
                stats.put("mismatch", rs.getInt("MismatchCount"));
            }
        } catch (SQLException ex) {
            Logger.getLogger(PaymentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        String sqlSuccess = "SELECT COUNT(*) FROM Payment WHERE Status = 'Success'";
        try (PreparedStatement ps = connection.prepareStatement(sqlSuccess);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("successCount", rs.getInt(1));
            }
        } catch (SQLException ex) {
            Logger.getLogger(PaymentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        return stats;
    }

    public String getReviewStatus(int paymentId) {
        String sql = "SELECT Status FROM FraudAlert WHERE PaymentID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, paymentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("Status");
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(PaymentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return "Pending";
    }

    public boolean updateReviewStatus(int paymentId, String status) {
        String checkSql = "SELECT AlertID FROM FraudAlert WHERE PaymentID = ?";
        try (PreparedStatement checkPs = connection.prepareStatement(checkSql)) {
            checkPs.setInt(1, paymentId);
            try (ResultSet rs = checkPs.executeQuery()) {
                if (rs.next()) {
                    // Update existing
                    String updateSql = "UPDATE FraudAlert SET Status = ?, ReviewedAt = SYSDATETIME() WHERE PaymentID = ?";
                    try (PreparedStatement updatePs = connection.prepareStatement(updateSql)) {
                        updatePs.setString(1, status);
                        updatePs.setInt(2, paymentId);
                        return updatePs.executeUpdate() > 0;
                    }
                } else {
                    // Insert new
                    String insertSql = "INSERT INTO FraudAlert (PaymentID, AlertType, Severity, Status, CreatedAt, ReviewedAt) VALUES (?, 'Manual Review', 'Medium', ?, SYSDATETIME(), SYSDATETIME())";
                    try (PreparedStatement insertPs = connection.prepareStatement(insertSql)) {
                        insertPs.setInt(1, paymentId);
                        insertPs.setString(2, status);
                        return insertPs.executeUpdate() > 0;
                    }
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(PaymentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }
}
