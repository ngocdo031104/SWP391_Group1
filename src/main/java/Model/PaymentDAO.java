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
}
