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
        // UC40/41: Lay danh sach CancellationRequest theo status cho Accountant.
    // JOIN Booking + [User] + TourSchedule + Tour de hien thi du thong tin.
    // status: "Pending", "Approved", "Rejected"
    public List<CancellationRequest> getRequestsByStatusForAccountant(String status) {
        List<CancellationRequest> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT cr.RequestID, cr.BookingID, cr.RequestedBy, cr.Reason, cr.Status, " +
            "cr.ProcessedBy, cr.ProcessedAt, cr.Notes, cr.CreatedAt, " +
            "b.BookingCode, b.TotalAmount, b.ScheduleID, " +
            "u.FullName AS CustomerName, u.Email AS CustomerEmail, " +
            "t.TourName, s.DepartureDate " +
            "FROM CancellationRequest cr " +
            "JOIN Booking b ON cr.BookingID = b.BookingID " +
            "JOIN [User] u ON cr.RequestedBy = u.UserID " +
            "JOIN TourSchedule s ON b.ScheduleID = s.ScheduleID " +
            "JOIN Tour t ON s.TourID = t.TourID " +
            "WHERE 1=1 "
        );
        if (status != null && !status.isEmpty() && !"All".equals(status)) {
            sql.append("AND cr.Status = '" + status.replace("'", "''") + "' ");
        }
        sql.append("ORDER BY cr.CreatedAt DESC");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
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
                    // Extra fields cho Accountant view
                    req.setBookingCode(rs.getString("BookingCode"));
                    req.setTotalAmount(rs.getDouble("TotalAmount"));
                    req.setCustomerName(rs.getString("CustomerName"));
                    req.setCustomerEmail(rs.getString("CustomerEmail"));
                    req.setTourName(rs.getString("TourName"));
                    req.setDepartureDate(rs.getDate("DepartureDate"));
                    list.add(req);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(CancellationRequestDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    // UC40: Cap nhat trang thai xu ly cua CancellationRequest (Approved/Rejected).
    // processedBy: UserID cua Accountant xu ly.
    // notes: Ghi chu ly do.
    public boolean processRequest(int requestId, int processedBy, String status, String notes) {
        String sql = "UPDATE CancellationRequest SET Status = ?, ProcessedBy = ?, ProcessedAt = SYSDATETIME(), Notes = ? " +
                     "WHERE RequestID = ? AND Status = 'Pending'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, processedBy);
            ps.setString(3, notes != null ? notes.trim() : "");
            ps.setInt(4, requestId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(CancellationRequestDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }
}
