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
        // Placeholder return to fix compilation error.
        // Requires join query with Booking/User if actual data is needed.
        return new java.util.ArrayList<>();
    }

    public int getTotalFraudulentTransactions(String dateFrom, String dateTo, String bookingId, String transactionRef, String gateway, String paymentStatus, String reviewStatus) {
        return 0;
    }

    public java.util.Map<String, Object> getFraudulentStats() {
        return new java.util.HashMap<>();
    }

    public String getReviewStatus(int paymentId) {
        return "Pending";
    }

    public boolean updateReviewStatus(int paymentId, String status) {
        return true;
    }
}
