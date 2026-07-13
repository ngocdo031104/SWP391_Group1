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

    public java.util.List<Entities.FraudTransactionDTO> getFraudulentTransactions(String dateFrom, String dateTo, String bookingId, String transactionRef, String gateway, String paymentStatus, String reviewStatus, int page, int pageSize) {
        java.util.List<Entities.FraudTransactionDTO> list = new java.util.ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "WITH FraudScan AS (" +
            "   SELECT p.PaymentID, p.TransactionRef, p.BookingID, p.Amount, p.Currency, " +
            "          p.Status AS PaymentStatus, p.GatewayResponse, p.PaidAt, p.ReviewStatus, " +
            "          b.TotalAmount AS ExpectedAmount, u.FullName AS CustomerName, i.InvoiceID, " +
            "          LTRIM(RTRIM(" +
            "              CASE WHEN EXISTS (SELECT 1 FROM Payment p2 WHERE p2.TransactionRef = p.TransactionRef AND p2.PaymentID <> p.PaymentID AND p.TransactionRef IS NOT NULL AND p.TransactionRef <> '') THEN N'Trùng lặp mã giao dịch (Nghi ngờ Replay Attack); ' ELSE '' END + " +
            "              CASE WHEN p.Amount <> b.TotalAmount THEN N'Sai lệch số tiền so với hóa đơn (Rủi ro can thiệp dữ liệu); ' ELSE '' END + " +
            "              CASE WHEN (SELECT COUNT(*) FROM Payment p3 WHERE p3.BookingID = p.BookingID AND p3.Status = 'Failed') > 1 THEN N'Thanh toán thất bại liên tiếp (Dấu hiệu dò thẻ/BIN Attack); ' ELSE '' END + " +
            "              CASE WHEN p.GatewayResponse LIKE '%ERROR%' OR p.GatewayResponse LIKE '%TIMEOUT%' OR p.GatewayResponse LIKE '%FAILED%' OR p.GatewayResponse LIKE '%DUPLICATE%' OR p.GatewayResponse LIKE '%INVALID%' THEN N'Phản hồi cổng thanh toán bất thường (Cảnh báo thẻ bị đánh cắp/IP blacklist); ' ELSE '' END + " +
            "              CASE WHEN b.Status = 'Paid' AND p.Status = 'Success' AND EXISTS (SELECT 1 FROM Payment p4 WHERE p4.BookingID = p.BookingID AND p4.Status = 'Success' AND p4.PaymentID <> p.PaymentID) THEN N'Thanh toán thành công nhiều lần cho 1 đặt chỗ (Rủi ro Chargeback); ' ELSE '' END + " +
            "              CASE WHEN p.Amount >= 50000000 THEN N'Giá trị GD cực lớn (Rủi ro rửa tiền); ' ELSE '' END + " +
            "              CASE WHEN DATEPART(hour, p.PaidAt) BETWEEN 0 AND 4 THEN N'Giao dịch đêm khuya (Giờ rủi ro cao); ' ELSE '' END + " +
            "              CASE WHEN (SELECT COUNT(*) FROM Payment p5 WHERE p5.BookingID = p.BookingID AND p5.PaidAt >= DATEADD(minute, -10, ISNULL(p.PaidAt, SYSDATETIME())) AND p5.PaidAt <= ISNULL(p.PaidAt, SYSDATETIME())) > 3 THEN N'Booking Spam (Giao dịch liên tục); ' ELSE '' END " +
            "          )) AS FraudReason " +
            "   FROM Payment p " +
            "   JOIN Booking b ON p.BookingID = b.BookingID " +
            "   JOIN [User] u ON b.CustomerID = u.UserID " +
            "   LEFT JOIN Invoice i ON p.PaymentID = i.PaymentID " +
            "   WHERE 1=1 "
        );

        if (dateFrom != null && !dateFrom.trim().isEmpty()) sql.append(" AND CAST(p.PaidAt AS DATE) >= ? ");
        if (dateTo != null && !dateTo.trim().isEmpty()) sql.append(" AND CAST(p.PaidAt AS DATE) <= ? ");
        if (bookingId != null && !bookingId.trim().isEmpty()) sql.append(" AND p.BookingID = ? ");
        if (transactionRef != null && !transactionRef.trim().isEmpty()) sql.append(" AND p.TransactionRef LIKE ? ");
        if (gateway != null && !gateway.trim().isEmpty()) sql.append(" AND p.GatewayResponse LIKE ? ");
        if (paymentStatus != null && !paymentStatus.trim().isEmpty()) sql.append(" AND p.Status = ? ");

        sql.append(") SELECT * FROM FraudScan WHERE (FraudReason <> '' OR ReviewStatus IN ('Under Review', 'Suspicious', 'Cleared')) ");

        if (reviewStatus != null && !reviewStatus.trim().isEmpty()) sql.append(" AND ReviewStatus = ? ");

        sql.append(" ORDER BY PaidAt DESC ");
        
        if (page > 0 && pageSize > 0) {
            sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        }

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (dateFrom != null && !dateFrom.trim().isEmpty()) ps.setString(paramIndex++, dateFrom);
            if (dateTo != null && !dateTo.trim().isEmpty()) ps.setString(paramIndex++, dateTo);
            if (bookingId != null && !bookingId.trim().isEmpty()) ps.setInt(paramIndex++, Integer.parseInt(bookingId));
            if (transactionRef != null && !transactionRef.trim().isEmpty()) ps.setString(paramIndex++, "%" + transactionRef + "%");
            if (gateway != null && !gateway.trim().isEmpty()) ps.setString(paramIndex++, "%" + gateway + "%");
            if (paymentStatus != null && !paymentStatus.trim().isEmpty()) ps.setString(paramIndex++, paymentStatus);
            if (reviewStatus != null && !reviewStatus.trim().isEmpty()) ps.setString(paramIndex++, reviewStatus);
            
            if (page > 0 && pageSize > 0) {
                ps.setInt(paramIndex++, (page - 1) * pageSize);
                ps.setInt(paramIndex++, pageSize);
            }

            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Entities.FraudTransactionDTO dto = new Entities.FraudTransactionDTO();
                    dto.setPaymentId(rs.getInt("PaymentID"));
                    dto.setTransactionRef(rs.getString("TransactionRef"));
                    dto.setBookingId(rs.getInt("BookingID"));
                    dto.setInvoiceId(rs.getInt("InvoiceID"));
                    dto.setCustomerName(rs.getString("CustomerName"));
                    dto.setAmount(rs.getBigDecimal("Amount"));
                    dto.setExpectedAmount(rs.getBigDecimal("ExpectedAmount"));
                    dto.setCurrency(rs.getString("Currency"));
                    dto.setPaymentStatus(rs.getString("PaymentStatus"));
                    dto.setGatewayResponse(rs.getString("GatewayResponse"));
                    dto.setPaidAt(rs.getTimestamp("PaidAt"));
                    dto.setFraudReason(rs.getString("FraudReason"));
                    dto.setReviewStatus(rs.getString("ReviewStatus"));
                    list.add(dto);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getTotalFraudulentTransactions(String dateFrom, String dateTo, String bookingId, String transactionRef, String gateway, String paymentStatus, String reviewStatus) {
        StringBuilder sql = new StringBuilder(
            "WITH FraudScan AS (" +
            "   SELECT p.PaymentID, p.ReviewStatus, " +
            "          LTRIM(RTRIM(" +
            "              CASE WHEN EXISTS (SELECT 1 FROM Payment p2 WHERE p2.TransactionRef = p.TransactionRef AND p2.PaymentID <> p.PaymentID AND p.TransactionRef IS NOT NULL AND p.TransactionRef <> '') THEN N'Trùng lặp mã giao dịch (Nghi ngờ Replay Attack); ' ELSE '' END + " +
            "              CASE WHEN p.Amount <> b.TotalAmount THEN N'Sai lệch số tiền so với hóa đơn (Rủi ro can thiệp dữ liệu); ' ELSE '' END + " +
            "              CASE WHEN (SELECT COUNT(*) FROM Payment p3 WHERE p3.BookingID = p.BookingID AND p3.Status = 'Failed') > 1 THEN N'Thanh toán thất bại liên tiếp (Dấu hiệu dò thẻ/BIN Attack); ' ELSE '' END + " +
            "              CASE WHEN p.GatewayResponse LIKE '%ERROR%' OR p.GatewayResponse LIKE '%TIMEOUT%' OR p.GatewayResponse LIKE '%FAILED%' OR p.GatewayResponse LIKE '%DUPLICATE%' OR p.GatewayResponse LIKE '%INVALID%' THEN N'Phản hồi cổng thanh toán bất thường (Cảnh báo thẻ bị đánh cắp/IP blacklist); ' ELSE '' END + " +
            "              CASE WHEN b.Status = 'Paid' AND p.Status = 'Success' AND EXISTS (SELECT 1 FROM Payment p4 WHERE p4.BookingID = p.BookingID AND p4.Status = 'Success' AND p4.PaymentID <> p.PaymentID) THEN N'Thanh toán thành công nhiều lần cho 1 đặt chỗ (Rủi ro Chargeback); ' ELSE '' END + " +
            "              CASE WHEN p.Amount >= 50000000 THEN N'Giá trị GD cực lớn (Rủi ro rửa tiền); ' ELSE '' END + " +
            "              CASE WHEN DATEPART(hour, p.PaidAt) BETWEEN 0 AND 4 THEN N'Giao dịch đêm khuya (Giờ rủi ro cao); ' ELSE '' END + " +
            "              CASE WHEN (SELECT COUNT(*) FROM Payment p5 WHERE p5.BookingID = p.BookingID AND p5.PaidAt >= DATEADD(minute, -10, ISNULL(p.PaidAt, SYSDATETIME())) AND p5.PaidAt <= ISNULL(p.PaidAt, SYSDATETIME())) > 3 THEN N'Booking Spam (Giao dịch liên tục); ' ELSE '' END " +
            "          )) AS FraudReason " +
            "   FROM Payment p JOIN Booking b ON p.BookingID = b.BookingID " +
            "   WHERE 1=1 "
        );

        if (dateFrom != null && !dateFrom.trim().isEmpty()) sql.append(" AND CAST(p.PaidAt AS DATE) >= ? ");
        if (dateTo != null && !dateTo.trim().isEmpty()) sql.append(" AND CAST(p.PaidAt AS DATE) <= ? ");
        if (bookingId != null && !bookingId.trim().isEmpty()) sql.append(" AND p.BookingID = ? ");
        if (transactionRef != null && !transactionRef.trim().isEmpty()) sql.append(" AND p.TransactionRef LIKE ? ");
        if (gateway != null && !gateway.trim().isEmpty()) sql.append(" AND p.GatewayResponse LIKE ? ");
        if (paymentStatus != null && !paymentStatus.trim().isEmpty()) sql.append(" AND p.Status = ? ");

        sql.append(") SELECT COUNT(*) FROM FraudScan WHERE (FraudReason <> '' OR ReviewStatus IN ('Under Review', 'Suspicious', 'Cleared')) ");

        if (reviewStatus != null && !reviewStatus.trim().isEmpty()) sql.append(" AND ReviewStatus = ? ");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (dateFrom != null && !dateFrom.trim().isEmpty()) ps.setString(paramIndex++, dateFrom);
            if (dateTo != null && !dateTo.trim().isEmpty()) ps.setString(paramIndex++, dateTo);
            if (bookingId != null && !bookingId.trim().isEmpty()) ps.setInt(paramIndex++, Integer.parseInt(bookingId));
            if (transactionRef != null && !transactionRef.trim().isEmpty()) ps.setString(paramIndex++, "%" + transactionRef + "%");
            if (gateway != null && !gateway.trim().isEmpty()) ps.setString(paramIndex++, "%" + gateway + "%");
            if (paymentStatus != null && !paymentStatus.trim().isEmpty()) ps.setString(paramIndex++, paymentStatus);
            if (reviewStatus != null && !reviewStatus.trim().isEmpty()) ps.setString(paramIndex++, reviewStatus);
            
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public java.util.Map<String, Object> getFraudulentStats() {
        java.util.Map<String, Object> stats = new java.util.HashMap<>();
        stats.put("total", 0);
        stats.put("suspicious", 0);
        stats.put("duplicate", 0);
        stats.put("mismatch", 0);
        stats.put("successCount", 0);

        String sql = "WITH FraudScan AS (" +
            "   SELECT p.PaymentID, p.ReviewStatus, p.Status AS PaymentStatus, " +
            "          CASE WHEN EXISTS (SELECT 1 FROM Payment p2 WHERE p2.TransactionRef = p.TransactionRef AND p2.PaymentID <> p.PaymentID AND p.TransactionRef IS NOT NULL AND p.TransactionRef <> '') THEN 1 ELSE 0 END AS IsDuplicate, " +
            "          CASE WHEN p.Amount <> b.TotalAmount THEN 1 ELSE 0 END AS IsMismatch, " +
            "          CASE WHEN (SELECT COUNT(*) FROM Payment p3 WHERE p3.BookingID = p.BookingID AND p3.Status = 'Failed') > 1 THEN 1 ELSE 0 END AS IsMultipleFailed, " +
            "          CASE WHEN p.GatewayResponse LIKE '%ERROR%' OR p.GatewayResponse LIKE '%TIMEOUT%' OR p.GatewayResponse LIKE '%FAILED%' OR p.GatewayResponse LIKE '%DUPLICATE%' OR p.GatewayResponse LIKE '%INVALID%' THEN 1 ELSE 0 END AS IsGatewaySuspicious, " +
            "          CASE WHEN b.Status = 'Paid' AND p.Status = 'Success' AND EXISTS (SELECT 1 FROM Payment p4 WHERE p4.BookingID = p.BookingID AND p4.Status = 'Success' AND p4.PaymentID <> p.PaymentID) THEN 1 ELSE 0 END AS IsMultipleSuccess " +
            "   FROM Payment p JOIN Booking b ON p.BookingID = b.BookingID " +
            ") SELECT " +
            "  COUNT(*) AS Total, " +
            "  SUM(CASE WHEN IsDuplicate=1 OR IsMismatch=1 OR IsMultipleFailed=1 OR IsGatewaySuspicious=1 OR IsMultipleSuccess=1 OR ReviewStatus='Suspicious' THEN 1 ELSE 0 END) AS Suspicious, " +
            "  SUM(IsDuplicate) AS DuplicateCount, " +
            "  SUM(IsMismatch) AS MismatchCount, " +
            "  SUM(CASE WHEN PaymentStatus='Success' THEN 1 ELSE 0 END) AS SuccessCount " +
            "FROM FraudScan";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             java.sql.ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("total", rs.getInt("Total"));
                stats.put("suspicious", rs.getInt("Suspicious"));
                stats.put("duplicate", rs.getInt("DuplicateCount"));
                stats.put("mismatch", rs.getInt("MismatchCount"));
                stats.put("successCount", rs.getInt("SuccessCount"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }

    public String getReviewStatus(int paymentId) {
        String sql = "SELECT ReviewStatus FROM Payment WHERE PaymentID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, paymentId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "Normal";
    }

    public boolean updateReviewStatus(int paymentId, String status) {
        String sql = "UPDATE Payment SET ReviewStatus = ? WHERE PaymentID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, paymentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
