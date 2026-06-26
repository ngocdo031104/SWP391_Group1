package Model;

import Entities.CancellationRequest;
import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CancellationRequestDAO extends DBContext {

    public boolean createRequest(CancellationRequest request) {
        String sql = "INSERT INTO CancellationRequest (BookingID, RequestedBy, Reason, Status, CreatedAt) VALUES (?, ?, ?, 'Pending', SYSDATETIME())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, request.getBookingId());
            ps.setInt(2, request.getRequestedBy());
            ps.setString(3, request.getReason());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(CancellationRequestDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    public CancellationRequest getPendingRequestByBookingId(int bookingId) {
        String sql = "SELECT RequestID, BookingID, RequestedBy, Reason, Status, ProcessedBy, ProcessedAt, Notes, CreatedAt "
                   + "FROM CancellationRequest WHERE BookingID = ? AND Status = 'Pending'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CancellationRequest req = new CancellationRequest();
                    req.setRequestId(rs.getInt("RequestID"));
                    req.setBookingId(rs.getInt("BookingID"));
                    req.setRequestedBy(rs.getInt("RequestedBy"));
                    req.setReason(rs.getString("Reason"));
                    req.setStatus(rs.getString("Status"));
                    if (rs.getObject("ProcessedBy") != null) {
                        req.setProcessedBy(rs.getInt("ProcessedBy"));
                    }
                    req.setProcessedAt(rs.getTimestamp("ProcessedAt"));
                    req.setNotes(rs.getString("Notes"));
                    req.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    return req;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(CancellationRequestDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }
    
    public List<CancellationRequest> getRequestsByBookingId(int bookingId) {
        List<CancellationRequest> list = new ArrayList<>();
        String sql = "SELECT RequestID, BookingID, RequestedBy, Reason, Status, ProcessedBy, ProcessedAt, Notes, CreatedAt "
                   + "FROM CancellationRequest WHERE BookingID = ? ORDER BY CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CancellationRequest req = new CancellationRequest();
                    req.setRequestId(rs.getInt("RequestID"));
                    req.setBookingId(rs.getInt("BookingID"));
                    req.setRequestedBy(rs.getInt("RequestedBy"));
                    req.setReason(rs.getString("Reason"));
                    req.setStatus(rs.getString("Status"));
                    if (rs.getObject("ProcessedBy") != null) {
                        req.setProcessedBy(rs.getInt("ProcessedBy"));
                    }
                    req.setProcessedAt(rs.getTimestamp("ProcessedAt"));
                    req.setNotes(rs.getString("Notes"));
                    req.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    list.add(req);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(CancellationRequestDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }
}
