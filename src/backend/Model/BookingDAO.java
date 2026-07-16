package Model;

import Entities.Booking;
import Entities.BookingParticipant;
import Entities.User;
import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class BookingDAO extends DBContext {

    /**
     * Creates a new booking, inserts participants, and decrements available seats in a single database transaction.
     * @param booking Booking object containing participants and schedule info
     * @return true if successful, false if failed or if there are not enough seats
     */
    public boolean createBooking(Booking booking) {
        String checkSeatsSql = "SELECT AvailableSeats, TotalSeats FROM TourSchedule WHERE ScheduleID = ?";
        String updateSeatsSql = "UPDATE TourSchedule SET AvailableSeats = AvailableSeats - ? WHERE ScheduleID = ? AND AvailableSeats >= ?";
        
        String insertBookingSql = "INSERT INTO Booking (BookingCode, ScheduleID, CustomerID, NumParticipants, BaseAmount, VATAmount, DiscountAmount, TotalAmount, Status, Notes, CouponID, CreatedAt, UpdatedAt) "
                                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATETIME(), SYSDATETIME())";
        
        String insertParticipantSql = "INSERT INTO BookingParticipant (BookingID, FullName, AgeType, PhoneNumber, Email, IsLeader) "
                                    + "VALUES (?, ?, ?, ?, ?, ?)";

        try {
            connection.setAutoCommit(false); // Start Transaction

            // 1. Check available seats first
            int availableSeats = 0;
            try (PreparedStatement psCheck = connection.prepareStatement(checkSeatsSql)) {
                psCheck.setInt(1, booking.getScheduleId());
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next()) {
                        availableSeats = rs.getInt("AvailableSeats");
                    } else {
                        throw new SQLException("Tour schedule not found.");
                    }
                }
            }

            if (availableSeats < booking.getNumParticipants()) {
                throw new SQLException("Not enough available seats for this tour schedule. Available: " + availableSeats + ", Requested: " + booking.getNumParticipants());
            }

            // 2. Decrement available seats
            try (PreparedStatement psUpdateSeats = connection.prepareStatement(updateSeatsSql)) {
                psUpdateSeats.setInt(1, booking.getNumParticipants());
                psUpdateSeats.setInt(2, booking.getScheduleId());
                psUpdateSeats.setInt(3, booking.getNumParticipants());
                int updatedSeatsRows = psUpdateSeats.executeUpdate();
                if (updatedSeatsRows == 0) {
                    throw new SQLException("Failed to reserve seats (possibly concurrently booked).");
                }
            }

            // 3. Insert Booking
            int bookingId = 0;
            try (PreparedStatement psBooking = connection.prepareStatement(insertBookingSql, Statement.RETURN_GENERATED_KEYS)) {
                psBooking.setString(1, booking.getBookingCode());
                psBooking.setInt(2, booking.getScheduleId());
                psBooking.setInt(3, booking.getCustomerId());
                psBooking.setInt(4, booking.getNumParticipants());
                psBooking.setDouble(5, booking.getBaseAmount());
                psBooking.setDouble(6, booking.getVatAmount());
                psBooking.setDouble(7, booking.getDiscountAmount());
                psBooking.setDouble(8, booking.getTotalAmount());
                psBooking.setString(9, booking.getStatus());
                psBooking.setString(10, booking.getNotes());
                if (booking.getCouponId() != null) {
                    psBooking.setInt(11, booking.getCouponId());
                } else {
                    psBooking.setNull(11, java.sql.Types.INTEGER);
                }

                psBooking.executeUpdate();

                try (ResultSet generatedKeys = psBooking.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        bookingId = generatedKeys.getInt(1);
                        booking.setBookingId(bookingId);
                    } else {
                        throw new SQLException("Creating booking failed, no ID obtained.");
                    }
                }
            }

            // 4. Insert Participants
            if (booking.getParticipants() != null && !booking.getParticipants().isEmpty()) {
                try (PreparedStatement psPart = connection.prepareStatement(insertParticipantSql)) {
                    for (BookingParticipant p : booking.getParticipants()) {
                        psPart.setInt(1, bookingId);
                        psPart.setString(2, p.getFullName());
                        psPart.setString(3, p.getAgeType());
                        psPart.setString(4, p.getPhoneNumber());
                        psPart.setString(5, p.getEmail());
                        psPart.setBoolean(6, p.isIsLeader());
                        psPart.addBatch();
                    }
                    psPart.executeBatch();
                }
            }

            connection.commit(); // Commit all operations
            return true;
        } catch (SQLException ex) {
            try {
                if (connection != null) {
                    connection.rollback(); // Rollback on failure
                }
            } catch (SQLException rollbackEx) {
                Logger.getLogger(BookingDAO.class.getName()).log(Level.SEVERE, null, rollbackEx);
            }
            Logger.getLogger(BookingDAO.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                connection.setAutoCommit(true);
            } catch (SQLException ex) {
                Logger.getLogger(BookingDAO.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        return false;
    }


    // Dương làm đoạn này: nhả các slot đã bị giữ quá thời gian thanh toán cho booking PendingPayment.
    // Hàm này tìm booking chưa thanh toán quá holdMinutes, cộng lại NumParticipants vào TourSchedule.AvailableSeats và chuyển booking sang Cancelled.
    public int releaseExpiredPendingPaymentBookings(int holdMinutes) {
        String selectExpiredSql = "SELECT BookingID, ScheduleID, NumParticipants FROM Booking "
                + "WHERE Status = 'PendingPayment' AND CreatedAt <= DATEADD(MINUTE, ?, SYSDATETIME())";
        String releaseSeatsSql = "UPDATE TourSchedule SET AvailableSeats = CASE "
                + "WHEN AvailableSeats + ? > TotalSeats THEN TotalSeats ELSE AvailableSeats + ? END "
                + "WHERE ScheduleID = ?";
        String cancelBookingSql = "UPDATE Booking SET Status = 'Cancelled', "
                + "Notes = LEFT(CONCAT(ISNULL(Notes, ''), N' | Hết hạn giữ chỗ sau ', ?, N' phút chưa thanh toán.'), 500), "
                + "UpdatedAt = SYSDATETIME() WHERE BookingID = ? AND Status = 'PendingPayment'";

        int releasedCount = 0;
        try {
            connection.setAutoCommit(false);
            List<int[]> expiredBookings = new ArrayList<>();
            try (PreparedStatement psSelect = connection.prepareStatement(selectExpiredSql)) {
                psSelect.setInt(1, -Math.abs(holdMinutes));
                try (ResultSet rs = psSelect.executeQuery()) {
                    while (rs.next()) {
                        expiredBookings.add(new int[] {
                            rs.getInt("BookingID"),
                            rs.getInt("ScheduleID"),
                            rs.getInt("NumParticipants")
                        });
                    }
                }
            }

            for (int[] item : expiredBookings) {
                int bookingId = item[0];
                int scheduleId = item[1];
                int numParticipants = item[2];

                try (PreparedStatement psSeats = connection.prepareStatement(releaseSeatsSql)) {
                    psSeats.setInt(1, numParticipants);
                    psSeats.setInt(2, numParticipants);
                    psSeats.setInt(3, scheduleId);
                    psSeats.executeUpdate();
                }

                try (PreparedStatement psCancel = connection.prepareStatement(cancelBookingSql)) {
                    psCancel.setInt(1, holdMinutes);
                    psCancel.setInt(2, bookingId);
                    releasedCount += psCancel.executeUpdate();
                }
            }

            connection.commit();
        } catch (SQLException ex) {
            try {
                if (connection != null) {
                    connection.rollback();
                }
            } catch (SQLException rollbackEx) {
                Logger.getLogger(BookingDAO.class.getName()).log(Level.SEVERE, null, rollbackEx);
            }
            Logger.getLogger(BookingDAO.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                connection.setAutoCommit(true);
            } catch (SQLException ex) {
                Logger.getLogger(BookingDAO.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        return releasedCount;
    }
    /**
     * Gets booking list for a specific customer.
     * @param customerId customer user ID
     * @return list of bookings
     */
    public List<Booking> getBookingsByCustomerId(int customerId) {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT BookingID, BookingCode, ScheduleID, CustomerID, NumParticipants, BaseAmount, VATAmount, DiscountAmount, TotalAmount, Status, Notes, CouponID, CreatedAt, UpdatedAt "
                   + "FROM Booking WHERE CustomerID = ? ORDER BY CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapBooking(rs));
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(BookingDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    // Dương làm phần này: lấy danh sách booking kèm thông tin Tour để hiển thị Lịch sử Tour
    public List<Booking> getBookingsWithTourByCustomerId(int customerId) {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT b.BookingID, b.BookingCode, b.ScheduleID, b.CustomerID, b.NumParticipants, "
                   + "b.BaseAmount, b.VATAmount, b.DiscountAmount, b.TotalAmount, b.Status, b.Notes, b.CouponID, b.CreatedAt, b.UpdatedAt, "
                   + "s.DepartureDate, s.ReturnDate, s.Transportation, "
                   + "t.TourName, t.Destination, t.DurationDays "
                   + "FROM Booking b "
                   + "JOIN TourSchedule s ON b.ScheduleID = s.ScheduleID "
                   + "JOIN Tour t ON s.TourID = t.TourID "
                   + "WHERE b.CustomerID = ? ORDER BY b.CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Booking booking = mapBooking(rs);
                    Entities.TourSchedule schedule = new Entities.TourSchedule();
                    schedule.setScheduleId(booking.getScheduleId());
                    schedule.setDepartureDate(rs.getDate("DepartureDate"));
                    schedule.setReturnDate(rs.getDate("ReturnDate"));
                    schedule.setTransportation(rs.getString("Transportation"));

                    Entities.Tour tour = new Entities.Tour();
                    tour.setTourName(rs.getString("TourName"));
                    tour.setDestination(rs.getString("Destination"));
                    tour.setDurationDays(rs.getInt("DurationDays"));

                    schedule.setTour(tour);
                    booking.setSchedule(schedule);
                    list.add(booking);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(BookingDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    /**
     * Gets details of a booking using its unique booking code.
     * @param bookingCode unique booking code
     * @return Booking object with participants loaded, or null if not found
     */
    public Booking getBookingByCode(String bookingCode) {
        String sql = "SELECT BookingID, BookingCode, ScheduleID, CustomerID, NumParticipants, BaseAmount, VATAmount, DiscountAmount, TotalAmount, Status, Notes, CouponID, CreatedAt, UpdatedAt "
                   + "FROM Booking WHERE BookingCode = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, bookingCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Booking booking = mapBooking(rs);
                    booking.setParticipants(getParticipantsByBookingId(booking.getBookingId()));
                    return booking;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(BookingDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    // Dương làm phần này: lấy thông tin booking kèm thông tin Tour và TourSchedule bằng cách JOIN 3 bảng.
    // Mục đích là phục vụ trang hóa đơn, nơi cần hiển thị tên tour, điểm đến, ngày đi, ngày về
    // và phương tiện di chuyển. Dùng hàm này thay cho getBookingByCode khi cần render hóa đơn.
    public Booking getBookingWithTourByCode(String bookingCode) {
        // SQL JOIN Booking -> TourSchedule -> Tour để lấy hết thông tin cần thiết trong một lần truy vấn
        String sql = "SELECT b.BookingID, b.BookingCode, b.ScheduleID, b.CustomerID, b.NumParticipants, "
                   + "b.BaseAmount, b.VATAmount, b.DiscountAmount, b.TotalAmount, b.Status, b.Notes, b.CouponID, b.CreatedAt, b.UpdatedAt, "
                   + "s.DepartureDate, s.ReturnDate, s.Transportation, "
                   + "t.TourName, t.Destination, t.DurationDays "
                   + "FROM Booking b "
                   + "JOIN TourSchedule s ON b.ScheduleID = s.ScheduleID "
                   + "JOIN Tour t ON s.TourID = t.TourID "
                   + "WHERE b.BookingCode = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, bookingCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // mapBooking xử lý các cột thuần Booking; các cột JOIN được đọc thêm bên dưới
                    Booking booking = mapBooking(rs);
                    // Load danh sách người tham gia để hiển thị trên hóa đơn
                    booking.setParticipants(getParticipantsByBookingId(booking.getBookingId()));

                    // Tạo đối tượng TourSchedule chứa thông tin lịch trình cần thiết cho hóa đơn
                    Entities.TourSchedule schedule = new Entities.TourSchedule();
                    schedule.setScheduleId(booking.getScheduleId());
                    schedule.setDepartureDate(rs.getDate("DepartureDate"));
                    schedule.setReturnDate(rs.getDate("ReturnDate"));
                    schedule.setTransportation(rs.getString("Transportation"));

                    // Tạo đối tượng Tour chứa tên tour, điểm đến và số ngày để hiển thị trên hóa đơn
                    Entities.Tour tour = new Entities.Tour();
                    tour.setTourName(rs.getString("TourName"));
                    tour.setDestination(rs.getString("Destination"));
                    tour.setDurationDays(rs.getInt("DurationDays"));

                    // Lắp ghép: tour vào schedule, schedule vào booking để JSP truy cập qua EL
                    schedule.setTour(tour);
                    booking.setSchedule(schedule);
                    return booking;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(BookingDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    /**
     * Updates booking status (e.g. Confirmed, Cancelled, Completed).
     * @param bookingId booking ID
     * @param status new status
     * @return true if updated, false otherwise
     */
    public boolean updateBookingStatus(int bookingId, String status) {
        String sql = "UPDATE Booking SET Status = ?, UpdatedAt = SYSDATETIME() WHERE BookingID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, bookingId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(BookingDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    /**
     * Gets participants for a specific schedule, considering only valid bookings.
     * @param scheduleId the schedule ID
     * @return list of confirmed/completed participants
     */
    public List<BookingParticipant> getParticipantsByScheduleId(int scheduleId) {
        List<BookingParticipant> list = new ArrayList<>();
        String sql = "SELECT bp.ParticipantID, bp.BookingID, bp.FullName, bp.AgeType, bp.PhoneNumber, bp.Email, bp.IsLeader, bp.CreatedAt "
                   + "FROM BookingParticipant bp "
                   + "JOIN Booking b ON bp.BookingID = b.BookingID "
                   + "WHERE b.ScheduleID = ? AND b.Status IN ('Confirmed', 'Completed', 'Success')";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookingParticipant p = new BookingParticipant(
                        rs.getInt("ParticipantID"),
                        rs.getInt("BookingID"),
                        rs.getString("FullName"),
                        rs.getString("AgeType"),
                        rs.getString("PhoneNumber"),
                        rs.getString("Email"),
                        rs.getBoolean("IsLeader"),
                        rs.getTimestamp("CreatedAt")
                    );
                    list.add(p);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(BookingDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    private List<BookingParticipant> getParticipantsByBookingId(int bookingId) {
        List<BookingParticipant> list = new ArrayList<>();
        String sql = "SELECT ParticipantID, BookingID, FullName, AgeType, PhoneNumber, Email, IsLeader, CreatedAt FROM BookingParticipant WHERE BookingID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookingParticipant p = new BookingParticipant(
                        rs.getInt("ParticipantID"),
                        rs.getInt("BookingID"),
                        rs.getString("FullName"),
                        rs.getString("AgeType"),
                        rs.getString("PhoneNumber"),
                        rs.getString("Email"),
                        rs.getBoolean("IsLeader"),
                        rs.getTimestamp("CreatedAt")
                    );
                    list.add(p);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(BookingDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    private Booking mapBooking(ResultSet rs) throws SQLException {
        Booking b = new Booking();
        b.setBookingId(rs.getInt("BookingID"));
        b.setBookingCode(rs.getString("BookingCode"));
        b.setScheduleId(rs.getInt("ScheduleID"));
        b.setCustomerId(rs.getInt("CustomerID"));
        b.setNumParticipants(rs.getInt("NumParticipants"));
        b.setBaseAmount(rs.getDouble("BaseAmount"));
        b.setVatAmount(rs.getDouble("VATAmount"));
        b.setDiscountAmount(rs.getDouble("DiscountAmount"));
        b.setTotalAmount(rs.getDouble("TotalAmount"));
        b.setStatus(rs.getString("Status"));
        b.setNotes(rs.getString("Notes"));
        b.setCouponId(rs.getObject("CouponID") != null ? rs.getInt("CouponID") : null);
        b.setCreatedAt(rs.getTimestamp("CreatedAt"));
        b.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        return b;
    }

    // Dương làm đoạn này: cập nhật lại phần tiền của booking sau khi khách nhập coupon ở màn hình thanh toán.
    // Method này chỉ thay đổi các cột tài chính, không đụng tới lịch khởi hành hay danh sách người tham gia.
    public boolean updateBookingFinancials(int bookingId, double discountAmount, double vatAmount, double totalAmount, Integer couponId) {
        String sql = "UPDATE Booking SET DiscountAmount = ?, VATAmount = ?, TotalAmount = ?, CouponID = ?, UpdatedAt = SYSDATETIME() WHERE BookingID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDouble(1, discountAmount);
            ps.setDouble(2, vatAmount);
            ps.setDouble(3, totalAmount);
            if (couponId != null) {
                ps.setInt(4, couponId);
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            ps.setInt(5, bookingId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(BookingDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    /**
     * Cancels a booking, releases seats in TourSchedule, and logs the change in BookingHistory.
     * Usually called by staff when approving a cancellation request, or by system/customer for unpaid bookings.
     */
    // UC11: L\u1ea5y to\u00e0n b\u1ed9 booking c\u1ee7a h\u1ec7 th\u1ed1ng cho Staff qu\u1ea3n l\u00fd.
    // JOIN TourSchedule + Tour \u0111\u1ec3 hi\u1ec3n th\u1ecb t\u00ean tour, ng\u00e0y kh\u1edfi h\u00e0nh.
    // JOIN [User] \u0111\u1ec3 hi\u1ec3n th\u1ecb t\u00ean kh\u00e1ch h\u00e0ng.
    // statusFilter = "All" \u0111\u1ec3 l\u1ea5y t\u1ea5t c\u1ea3, ho\u1eb7c t\u00ean status c\u1ee5 th\u1ec3.
    // keyword t\u00ecm theo BookingCode ho\u1eb7c FullName kh\u00e1ch.
    public List<Booking> getAllBookingsForStaff(String statusFilter, String keyword, int offset, int pageSize) {
        List<Booking> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT b.BookingID, b.BookingCode, b.ScheduleID, b.CustomerID, b.NumParticipants, " +
            "b.BaseAmount, b.VATAmount, b.DiscountAmount, b.TotalAmount, b.Status, b.Notes, b.CouponID, b.CreatedAt, b.UpdatedAt, " +
            "s.DepartureDate, t.TourName, t.Destination, " +
            "u.FullName AS CustomerName, u.Email AS CustomerEmail, u.PhoneNumber AS CustomerPhone " +
            "FROM Booking b " +
            "JOIN TourSchedule s ON b.ScheduleID = s.ScheduleID " +
            "JOIN Tour t ON s.TourID = t.TourID " +
            "JOIN [User] u ON b.CustomerID = u.UserID " +
            "WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.isEmpty() && !"All".equals(statusFilter)) {
            sql.append("AND b.Status = ? ");
            params.add(statusFilter);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (b.BookingCode LIKE ? OR u.FullName LIKE ?) ");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }
        sql.append("ORDER BY b.CreatedAt DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(pageSize);

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Booking b = mapBooking(rs);
                    // G\u1eafn th\u00f4ng tin kh\u00e1ch h\u00e0ng v\u00e0o Booking.customer \u0111\u1ec3 JSP truy c\u1eadp qua EL
                    User customer = new User();
                    customer.setUserId(rs.getInt("CustomerID"));
                    customer.setFullName(rs.getString("CustomerName"));
                    customer.setEmail(rs.getString("CustomerEmail"));
                    customer.setPhoneNumber(rs.getString("CustomerPhone"));
                    b.setCustomer(customer);
                    // G\u1eafn th\u00f4ng tin l\u1ecbch kh\u1edfi h\u00e0nh + t\u00ean tour
                    Entities.TourSchedule schedule = new Entities.TourSchedule();
                    schedule.setDepartureDate(rs.getDate("DepartureDate"));
                    Entities.Tour tour = new Entities.Tour();
                    tour.setTourName(rs.getString("TourName"));
                    tour.setDestination(rs.getString("Destination"));
                    schedule.setTour(tour);
                    b.setSchedule(schedule);
                    list.add(b);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(BookingDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    // UC11: \u0110\u1ebfm t\u1ed5ng s\u1ed1 booking \u0111\u1ec3 t\u00ednh ph\u00e2n trang cho Staff.
    public int countAllBookingsForStaff(String statusFilter, String keyword) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM Booking b " +
            "JOIN [User] u ON b.CustomerID = u.UserID " +
            "WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.isEmpty() && !"All".equals(statusFilter)) {
            sql.append("AND b.Status = ? ");
            params.add(statusFilter);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (b.BookingCode LIKE ? OR u.FullName LIKE ?) ");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException ex) {
            Logger.getLogger(BookingDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return 0;
    }

    // UC11: Staff c\u1eadp nh\u1eadt ghi ch\u00fa v\u1eadn h\u00e0nh n\u1ed9i b\u1ed9 v\u00e0o booking.
    // Notes \u0111\u01b0\u1ee3c gi\u1edbi h\u1ea1n 500 k\u00fd t\u1ef1 \u0111\u1ec3 ph\u00f9 h\u1ee3p v\u1edbi constraint c\u1ee7a DB.
    public boolean updateOperationalNotes(int bookingId, String notes) {
        String sql = "UPDATE Booking SET Notes = ?, UpdatedAt = SYSDATETIME() WHERE BookingID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            String safeNotes = notes != null ? notes.trim() : "";
            ps.setString(1, safeNotes.length() > 500 ? safeNotes.substring(0, 500) : safeNotes);
            ps.setInt(2, bookingId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(BookingDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    public boolean cancelBookingAndReleaseSeats(int bookingId, int changedBy, String reason) {
        String getBookingSql = "SELECT ScheduleID, NumParticipants, Status FROM Booking WHERE BookingID = ?";
        String updateSeatsSql = "UPDATE TourSchedule SET AvailableSeats = CASE "
                + "WHEN AvailableSeats + ? > TotalSeats THEN TotalSeats ELSE AvailableSeats + ? END "
                + "WHERE ScheduleID = ?";
        String cancelBookingSql = "UPDATE Booking SET Status = 'Cancelled', UpdatedAt = SYSDATETIME() WHERE BookingID = ?";
        String insertHistorySql = "INSERT INTO BookingHistory (BookingID, OldStatus, NewStatus, ChangedBy, Reason, ChangedAt) "
                + "VALUES (?, ?, 'Cancelled', ?, ?, SYSDATETIME())";

        try {
            connection.setAutoCommit(false);

            int scheduleId = 0;
            int numParticipants = 0;
            String oldStatus = "";

            try (PreparedStatement psGet = connection.prepareStatement(getBookingSql)) {
                psGet.setInt(1, bookingId);
                try (ResultSet rs = psGet.executeQuery()) {
                    if (rs.next()) {
                        scheduleId = rs.getInt("ScheduleID");
                        numParticipants = rs.getInt("NumParticipants");
                        oldStatus = rs.getString("Status");
                    } else {
                        throw new SQLException("Booking not found");
                    }
                }
            }

            if ("Cancelled".equals(oldStatus)) {
                connection.rollback();
                return false; // Already cancelled
            }

            // Release seats
            try (PreparedStatement psSeats = connection.prepareStatement(updateSeatsSql)) {
                psSeats.setInt(1, numParticipants);
                psSeats.setInt(2, numParticipants);
                psSeats.setInt(3, scheduleId);
                psSeats.executeUpdate();
            }

            // Update booking status
            try (PreparedStatement psCancel = connection.prepareStatement(cancelBookingSql)) {
                psCancel.setInt(1, bookingId);
                psCancel.executeUpdate();
            }

            // Insert history
            try (PreparedStatement psHistory = connection.prepareStatement(insertHistorySql)) {
                psHistory.setInt(1, bookingId);
                psHistory.setString(2, oldStatus);
                if (changedBy > 0) {
                    psHistory.setInt(3, changedBy);
                } else {
                    psHistory.setNull(3, java.sql.Types.INTEGER);
                }
                psHistory.setString(4, reason);
                psHistory.executeUpdate();
            }

            connection.commit();
            return true;
        } catch (SQLException ex) {
            try {
                if (connection != null) connection.rollback();
            } catch (SQLException rollbackEx) {
                Logger.getLogger(BookingDAO.class.getName()).log(Level.SEVERE, null, rollbackEx);
            }
            Logger.getLogger(BookingDAO.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (connection != null) connection.setAutoCommit(true);
            } catch (SQLException ex) {
                Logger.getLogger(BookingDAO.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        return false;
    }
}
