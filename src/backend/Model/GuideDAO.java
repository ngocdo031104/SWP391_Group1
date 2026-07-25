package Model;

import Entities.GuideProfile;
import Entities.TourAssignment;
import Entities.TourSchedule;
import Entities.User;
import Entities.UserProfile;
import Entities.Role;
import Entities.Tour;
import Utils.DBContext;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LỚP MÔ HÌNH TRUY XUẤT DỮ LIỆU GUIDE (GUIDEDAO)
 * - Quản lý các nghiệp vụ truy vấn cơ sở dữ liệu liên quan đến Hướng dẫn viên.
 * - Hỗ trợ các chức năng: lấy hồ sơ chi tiết, lập danh sách HDV, phân công tour cho HDV, lấy lịch dẫn đoàn.
 */
public class GuideDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(GuideDAO.class.getName());

    public GuideDAO() {
        super();
    }

    /**
     * Lấy hồ sơ hướng dẫn viên chi tiết dựa theo UserID.
     * Kết hợp các bảng [User], UserProfile, GuideProfile để lấy đầy đủ thông tin liên lạc, avatar, và kinh nghiệm.
     * 
     * @param userId ID tài khoản của hướng dẫn viên
     * @return Đối tượng GuideProfile chứa đầy đủ thông tin hoặc null nếu không tìm thấy.
     */
    public GuideProfile getGuideProfileByUserId(int userId) {
        String sql = "SELECT gp.GuideProfileID, gp.UserID, gp.YearsOfExperience, gp.TotalToursLed, gp.Rating, gp.Bio, gp.Specialization, gp.Languages, gp.Certifications, gp.EmergencyPhone, gp.IsActive as ProfileActive, gp.CreatedAt as ProfileCreated, gp.UpdatedAt as ProfileUpdated, "
                   + "u.Email, u.FullName, u.PhoneNumber, u.IsActive as UserActive, u.IsVerified, u.CreatedAt as UserCreated, u.RoleID, "
                   + "up.AvatarURL "
                   + "FROM GuideProfile gp "
                   + "JOIN [User] u ON gp.UserID = u.UserID "
                   + "LEFT JOIN UserProfile up ON u.UserID = up.UserID "
                   + "WHERE gp.UserID = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    GuideProfile gp = new GuideProfile();
                    gp.setGuideProfileId(rs.getInt("GuideProfileID"));
                    gp.setUserId(rs.getInt("UserID"));
                    gp.setYearsOfExperience(rs.getInt("YearsOfExperience"));
                    gp.setTotalToursLed(rs.getInt("TotalToursLed"));
                    gp.setRating(rs.getDouble("Rating"));
                    gp.setBio(rs.getString("Bio"));
                    gp.setSpecialization(rs.getString("Specialization"));
                    gp.setLanguages(rs.getString("Languages"));
                    gp.setCertifications(rs.getString("Certifications"));
                    gp.setEmergencyPhone(rs.getString("EmergencyPhone"));
                    gp.setIsActive(rs.getBoolean("ProfileActive"));
                    gp.setCreatedAt(rs.getTimestamp("ProfileCreated"));
                    gp.setUpdatedAt(rs.getTimestamp("ProfileUpdated"));

                    // Gán thông tin User đi kèm
                    User u = new User();
                    u.setUserId(rs.getInt("UserID"));
                    u.setRoleId(rs.getInt("RoleID"));
                    u.setEmail(rs.getString("Email"));
                    u.setFullName(rs.getString("FullName"));
                    u.setPhoneNumber(rs.getString("PhoneNumber"));
                    u.setIsActive(rs.getBoolean("UserActive"));
                    u.setIsVerified(rs.getBoolean("IsVerified"));
                    u.setCreatedAt(rs.getTimestamp("UserCreated"));

                    // Gán UserProfile đi kèm cho User
                    UserProfile up = new UserProfile();
                    up.setUserId(rs.getInt("UserID"));
                    up.setAvatarUrl(rs.getString("AvatarURL"));
                    u.setProfile(up);

                    gp.setUser(u);
                    return gp;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy thông tin Guide Profile theo User ID: " + userId, ex);
        }
        return null;
    }

    /**
     * Lấy toàn bộ danh sách Hướng dẫn viên có trong cơ sở dữ liệu sắp xếp theo Rating giảm dần.
     * 
     * @return Danh sách các đối tượng GuideProfile.
     */
    public List<GuideProfile> getAllGuides() {
        List<GuideProfile> list = new ArrayList<>();
        String sql = "SELECT gp.GuideProfileID, gp.YearsOfExperience, gp.TotalToursLed, gp.Rating, gp.Bio, gp.Specialization, gp.Languages, gp.Certifications, gp.EmergencyPhone, gp.IsActive as ProfileActive, gp.CreatedAt as ProfileCreated, gp.UpdatedAt as ProfileUpdated, "
                   + "u.UserID, u.Email, u.FullName, u.PhoneNumber, u.IsActive as UserActive, u.IsVerified, u.CreatedAt as UserCreated, u.RoleID, "
                   + "up.AvatarURL "
                   + "FROM [User] u "
                   + "LEFT JOIN GuideProfile gp ON gp.UserID = u.UserID "
                   + "LEFT JOIN UserProfile up ON u.UserID = up.UserID "
                   + "WHERE u.RoleID = 3 AND u.IsActive = 1 "
                   + "ORDER BY u.FullName ASC";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                GuideProfile gp = new GuideProfile();
                int guideProfileId = rs.getInt("GuideProfileID");
                if (!rs.wasNull()) {
                    gp.setGuideProfileId(guideProfileId);
                    gp.setYearsOfExperience(rs.getInt("YearsOfExperience"));
                    gp.setTotalToursLed(rs.getInt("TotalToursLed"));
                    gp.setRating(rs.getDouble("Rating"));
                    gp.setBio(rs.getString("Bio"));
                    gp.setSpecialization(rs.getString("Specialization"));
                    gp.setLanguages(rs.getString("Languages"));
                    gp.setCertifications(rs.getString("Certifications"));
                    gp.setEmergencyPhone(rs.getString("EmergencyPhone"));
                    gp.setIsActive(rs.getBoolean("ProfileActive"));
                    gp.setCreatedAt(rs.getTimestamp("ProfileCreated"));
                    gp.setUpdatedAt(rs.getTimestamp("ProfileUpdated"));
                } else {
                    gp.setYearsOfExperience(0);
                    gp.setRating(5.0);
                    gp.setIsActive(true);
                }

                // Gán thông tin User
                User u = new User();
                u.setUserId(rs.getInt("UserID"));
                u.setRoleId(rs.getInt("RoleID"));
                u.setEmail(rs.getString("Email"));
                u.setFullName(rs.getString("FullName"));
                u.setPhoneNumber(rs.getString("PhoneNumber"));
                u.setIsActive(rs.getBoolean("UserActive"));
                u.setIsVerified(rs.getBoolean("IsVerified"));
                u.setCreatedAt(rs.getTimestamp("UserCreated"));

                gp.setUserId(u.getUserId());

                // Gán Profile
                UserProfile up = new UserProfile();
                up.setUserId(u.getUserId());
                up.setAvatarUrl(rs.getString("AvatarURL"));
                u.setProfile(up);

                gp.setUser(u);
                list.add(gp);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy danh sách toàn bộ Guides", ex);
        }
        return list;
    }

    /**
     * Kiểm tra xem Hướng dẫn viên có bị trùng lịch dẫn đoàn với đợt khởi hành khác hay không.
     * 
     * @param guideId ID của Hướng dẫn viên
     * @param scheduleId ID của lịch khởi hành đang xét
     * @return true nếu bị trùng lịch (bận), false nếu rảnh.
     */
    public boolean isGuideBusy(int guideId, int scheduleId) {
        String sql = "SELECT COUNT(*) FROM TourSchedule ts2 "
                   + "JOIN TourSchedule ts1 ON ts1.ScheduleID = ? "
                   + "WHERE ts2.GuideID = ? "
                   + "  AND ts2.ScheduleID <> ts1.ScheduleID "
                   + "  AND ISNULL(ts2.TourStatus, '') <> 'Cancelled' "
                   + "  AND ISNULL(ts2.Status, '') <> 'Cancelled' "
                   + "  AND CAST(ts2.DepartureDate AS DATE) <= CAST(ISNULL(ts1.ReturnDate, ts1.DepartureDate) AS DATE) "
                   + "  AND CAST(ISNULL(ts2.ReturnDate, ts2.DepartureDate) AS DATE) >= CAST(ts1.DepartureDate AS DATE)";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            ps.setInt(2, guideId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi kiểm tra trùng lịch HDV guideId=" + guideId + ", scheduleId=" + scheduleId, ex);
        }
        return false;
    }

    /**
     * Thêm mới một hồ sơ Hướng dẫn viên vào cơ sở dữ liệu.
     */
    public boolean insertGuideProfile(GuideProfile profile) {
        String sql = "INSERT INTO GuideProfile (UserID, YearsOfExperience, TotalToursLed, Rating, Bio, Specialization, Languages, Certifications, EmergencyPhone, IsActive, CreatedAt, UpdatedAt) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATETIME(), SYSDATETIME())";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, profile.getUserId());
            ps.setInt(2, profile.getYearsOfExperience());
            ps.setInt(3, profile.getTotalToursLed());
            ps.setDouble(4, profile.getRating());
            ps.setString(5, profile.getBio());
            ps.setString(6, profile.getSpecialization());
            ps.setString(7, profile.getLanguages());
            ps.setString(8, profile.getCertifications());
            ps.setString(9, profile.getEmergencyPhone());
            ps.setBoolean(10, profile.isIsActive());

            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi chèn Guide Profile mới", ex);
            throw new RuntimeException("SQL Error in insertGuideProfile: " + ex.getMessage(), ex);
        }
    }

    /**
     * Cập nhật thông tin hồ sơ Hướng dẫn viên.
     */
    public boolean updateGuideProfile(GuideProfile profile) {
        String sql = "UPDATE GuideProfile SET YearsOfExperience = ?, TotalToursLed = ?, Rating = ?, Bio = ?, Specialization = ?, Languages = ?, Certifications = ?, EmergencyPhone = ?, IsActive = ?, UpdatedAt = SYSDATETIME() "
                   + "WHERE UserID = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, profile.getYearsOfExperience());
            ps.setInt(2, profile.getTotalToursLed());
            ps.setDouble(3, profile.getRating());
            ps.setString(4, profile.getBio());
            ps.setString(5, profile.getSpecialization());
            ps.setString(6, profile.getLanguages());
            ps.setString(7, profile.getCertifications());
            ps.setString(8, profile.getEmergencyPhone());
            ps.setBoolean(9, profile.isIsActive());
            ps.setInt(10, profile.getUserId());

            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi cập nhật Guide Profile của UserID: " + profile.getUserId(), ex);
            throw new RuntimeException("SQL Error in updateGuideProfile: " + ex.getMessage(), ex);
        }
    }

    /**
     * Nghiệp vụ Phân công HDV phụ trách một lịch khởi hành cụ thể (Transaction-based).
     * 1. Cập nhật trường GuideID của TourSchedule thành ID của hướng dẫn viên được phân công.
     * 2. Chèn bản ghi ghi nhận phân công vào bảng TourAssignment.
     * 
     * @param scheduleId ID của đợt khởi hành
     * @param guideId ID của Hướng dẫn viên
     * @param assignedBy ID của Nhân viên điều hành thực hiện phân công
     * @param notes Ghi chú bổ sung
     * @return true nếu phân công thành công hoàn tất, ngược lại rollback và trả về false.
     */
    public boolean assignGuideToSchedule(int scheduleId, int guideId, int assignedBy, String notes) {
        String updateScheduleSql = "UPDATE TourSchedule SET GuideID = ? WHERE ScheduleID = ?";
        String insertStatusSql = "INSERT INTO TourStatus (ScheduleID, Status, Notes, UpdatedBy, UpdatedAt) VALUES (?, 'Scheduled', N'Phân công Hướng dẫn viên', ?, SYSDATETIME())";
        String mergeAssignmentSql = "MERGE INTO TourAssignment AS target "
                                  + "USING (SELECT ? AS ScheduleID, ? AS GuideID) AS source "
                                  + "ON (target.ScheduleID = source.ScheduleID AND target.GuideID = source.GuideID) "
                                  + "WHEN MATCHED THEN "
                                  + "    UPDATE SET AssignedBy = ?, AssignedAt = SYSDATETIME(), Notes = ? "
                                  + "WHEN NOT MATCHED THEN "
                                  + "    INSERT (ScheduleID, GuideID, AssignedBy, AssignedAt, Notes) "
                                  + "    VALUES (source.ScheduleID, source.GuideID, ?, SYSDATETIME(), ?);";

        try {
            connection.setAutoCommit(false);

            try (PreparedStatement psUpdate = connection.prepareStatement(updateScheduleSql);
                 PreparedStatement psStatus = connection.prepareStatement(insertStatusSql);
                 PreparedStatement psMerge = connection.prepareStatement(mergeAssignmentSql)) {
                
                // Bước 1: Cập nhật GuideID trong TourSchedule
                psUpdate.setInt(1, guideId);
                psUpdate.setInt(2, scheduleId);
                psUpdate.executeUpdate();

                // Bước 2: Thêm lịch sử trạng thái
                psStatus.setInt(1, scheduleId);
                psStatus.setInt(2, assignedBy);
                psStatus.executeUpdate();

                // Bước 3: Chèn hoặc cập nhật bản ghi lịch sử phân công TourAssignment
                psMerge.setInt(1, scheduleId);
                psMerge.setInt(2, guideId);
                psMerge.setInt(3, assignedBy);
                psMerge.setString(4, notes);
                psMerge.setInt(5, assignedBy);
                psMerge.setString(6, notes);
                psMerge.executeUpdate();

                connection.commit();
                return true;
            } catch (SQLException ex) {
                connection.rollback();
                LOGGER.log(Level.SEVERE, "Lỗi xảy ra trong transaction phân công HDV, đã thực hiện rollback", ex);
            } finally {
                connection.setAutoCommit(true);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi kết nối cơ sở dữ liệu khi phân công HDV", ex);
        }
        return false;
    }

    /**
     * Lấy toàn bộ danh sách phân công lịch dẫn đoàn trên hệ thống (Nhật ký phân công).
     */
    public List<TourAssignment> getAllAssignments() {
        List<TourAssignment> list = new ArrayList<>();
        String sql = "SELECT ta.AssignmentID, ta.ScheduleID, ta.GuideID, ta.AssignedBy, ta.AssignedAt, ta.Notes, "
                   + "       g.FullName as GuideName, "
                   + "       c.FullName as CoordinatorName, "
                   + "       ts.DepartureDate, ts.ReturnDate, "
                   + "       t.TourName "
                   + "FROM TourAssignment ta "
                   + "JOIN [User] g ON ta.GuideID = g.UserID "
                   + "LEFT JOIN [User] c ON ta.AssignedBy = c.UserID "
                   + "JOIN TourSchedule ts ON ta.ScheduleID = ts.ScheduleID "
                   + "JOIN Tour t ON ts.TourID = t.TourID "
                   + "ORDER BY ta.AssignedAt DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                TourAssignment ta = new TourAssignment();
                ta.setAssignmentId(rs.getInt("AssignmentID"));
                ta.setScheduleId(rs.getInt("ScheduleID"));
                ta.setGuideId(rs.getInt("GuideID"));
                ta.setAssignedBy(rs.getObject("AssignedBy") != null ? rs.getInt("AssignedBy") : null);
                ta.setAssignedAt(rs.getTimestamp("AssignedAt"));
                ta.setNotes(rs.getString("Notes"));
                ta.setAssignedByName(rs.getString("CoordinatorName"));

                // Gán Guide User
                User guide = new User();
                guide.setUserId(rs.getInt("GuideID"));
                guide.setFullName(rs.getString("GuideName"));
                ta.setGuide(guide);

                // Gán TourSchedule & Tour
                TourSchedule sched = new TourSchedule();
                sched.setScheduleId(rs.getInt("ScheduleID"));
                sched.setDepartureDate(rs.getDate("DepartureDate"));
                sched.setReturnDate(rs.getDate("ReturnDate"));

                Tour tour = new Tour();
                tour.setTourName(rs.getString("TourName"));
                sched.setTour(tour);

                ta.setSchedule(sched);
                list.add(ta);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy danh sách lịch sử phân công", ex);
        }
        return list;
    }

    /**
     * Lấy danh sách toàn bộ Lịch phân công dẫn đoàn của một Hướng dẫn viên theo thời gian khởi hành từ mới nhất.
     * 
     * @param guideId ID tài khoản hướng dẫn viên
     * @return Danh sách TourAssignment kèm thông tin lịch trình chi tiết.
     */
    public List<TourAssignment> getAssignmentsByGuideId(int guideId) {
        List<TourAssignment> list = new ArrayList<>();
        String sql = "SELECT ta.AssignmentID, ta.ScheduleID, ta.GuideID, ta.AssignedBy, ta.AssignedAt, ta.Notes, "
                   + "ts.DepartureDate, ts.ReturnDate, ts.TotalSeats, ts.AvailableSeats, ts.PriceAdult, ts.Transportation, ts.Status as SchedStatus, "
                   + "(SELECT TOP 1 tst.Status FROM TourStatus tst WHERE tst.ScheduleID = ts.ScheduleID ORDER BY tst.UpdatedAt DESC) as TourStatus, "
                   + "t.TourID, t.TourName, t.Destination, t.DurationDays "
                   + "FROM TourAssignment ta "
                   + "JOIN TourSchedule ts ON ta.ScheduleID = ts.ScheduleID "
                   + "JOIN Tour t ON ts.TourID = t.TourID "
                   + "WHERE ta.GuideID = ? "
                   + "ORDER BY ts.DepartureDate DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TourAssignment ta = new TourAssignment();
                    ta.setAssignmentId(rs.getInt("AssignmentID"));
                    ta.setScheduleId(rs.getInt("ScheduleID"));
                    ta.setGuideId(rs.getInt("GuideID"));
                    ta.setAssignedBy(rs.getInt("AssignedBy"));
                    ta.setAssignedAt(rs.getTimestamp("AssignedAt"));
                    ta.setNotes(rs.getString("Notes"));

                    // Gán thực thể TourSchedule đi kèm
                    TourSchedule sched = new TourSchedule();
                    sched.setScheduleId(rs.getInt("ScheduleID"));
                    sched.setTourId(rs.getInt("TourID"));
                    sched.setDepartureDate(rs.getDate("DepartureDate"));
                    sched.setReturnDate(rs.getDate("ReturnDate"));
                    sched.setTotalSeats(rs.getInt("TotalSeats"));
                    sched.setAvailableSeats(rs.getInt("AvailableSeats"));
                    sched.setPriceAdult(rs.getDouble("PriceAdult"));
                    sched.setTransportation(rs.getString("Transportation"));
                    sched.setStatus(rs.getString("SchedStatus"));
                    sched.setTourStatus(rs.getString("TourStatus"));

                    // Gán thông tin Tour cho TourSchedule
                    Tour tour = new Tour();
                    tour.setTourId(rs.getInt("TourID"));
                    tour.setTourName(rs.getString("TourName"));
                    tour.setDestination(rs.getString("Destination"));
                    tour.setDurationDays(rs.getInt("DurationDays"));
                    
                    // Kết nối các thực thể
                    sched.setTour(tour);
                    sched.setGuide(null); // Tránh vòng lặp tham chiếu đệ quy
                    ta.setSchedule(sched);
                    
                    list.add(ta);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy lịch trình dẫn đoàn của GuideID: " + guideId, ex);
        }
        return list;
    }

    /**
     * Hủy phân công hướng dẫn viên khỏi lịch trình (Transaction-based).
     */
    public boolean unassignGuide(int scheduleId, int guideId, int coordinatorId) {
        String updateScheduleSql = "UPDATE TourSchedule SET GuideID = NULL WHERE ScheduleID = ? AND GuideID = ?";
        String insertStatusSql = "INSERT INTO TourStatus (ScheduleID, Status, Notes, UpdatedBy, UpdatedAt) "
                               + "VALUES (?, 'Scheduled', N'Hủy phân công Hướng dẫn viên', ?, SYSDATETIME())";
        String deleteAssignmentSql = "DELETE FROM TourAssignment WHERE ScheduleID = ? AND GuideID = ?";

        try {
            connection.setAutoCommit(false);
            try (PreparedStatement psUpdate = connection.prepareStatement(updateScheduleSql);
                 PreparedStatement psStatus = connection.prepareStatement(insertStatusSql);
                 PreparedStatement psDelete = connection.prepareStatement(deleteAssignmentSql)) {
                
                // 1. Update TourSchedule
                psUpdate.setInt(1, scheduleId);
                psUpdate.setInt(2, guideId);
                psUpdate.executeUpdate();

                // 2. Insert TourStatus log
                psStatus.setInt(1, scheduleId);
                psStatus.setInt(2, coordinatorId);
                psStatus.executeUpdate();

                // 3. Delete TourAssignment record
                psDelete.setInt(1, scheduleId);
                psDelete.setInt(2, guideId);
                psDelete.executeUpdate();

                connection.commit();
                return true;
            } catch (SQLException ex) {
                connection.rollback();
                LOGGER.log(Level.SEVERE, "Lỗi xảy ra khi hủy phân công HDV, đã thực hiện rollback", ex);
            } finally {
                connection.setAutoCommit(true);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi kết nối cơ sở dữ liệu khi hủy phân công HDV", ex);
        }
        return false;
    }

    /**
     * Lấy danh sách phân công lịch dẫn đoàn có phân trang và tìm kiếm.
     */
    public List<TourAssignment> getAssignmentsPaged(int page, int size, String search) {
        List<TourAssignment> list = new ArrayList<>();
        int offset = (page - 1) * size;
        
        String searchClause = "";
        if (search != null && !search.trim().isEmpty()) {
            searchClause = "WHERE t.TourName LIKE ? OR g.FullName LIKE ? ";
        }
        
        String sql = "SELECT ta.AssignmentID, ta.ScheduleID, ta.GuideID, ta.AssignedBy, ta.AssignedAt, ta.Notes, "
                   + "       g.FullName as GuideName, "
                   + "       c.FullName as CoordinatorName, "
                   + "       ts.DepartureDate, ts.ReturnDate, "
                   + "       t.TourName "
                   + "FROM TourAssignment ta "
                   + "JOIN [User] g ON ta.GuideID = g.UserID "
                   + "LEFT JOIN [User] c ON ta.AssignedBy = c.UserID "
                   + "JOIN TourSchedule ts ON ta.ScheduleID = ts.ScheduleID "
                   + "JOIN Tour t ON ts.TourID = t.TourID "
                   + searchClause
                   + "ORDER BY ta.AssignedAt DESC "
                   + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex++, size);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TourAssignment ta = new TourAssignment();
                    ta.setAssignmentId(rs.getInt("AssignmentID"));
                    ta.setScheduleId(rs.getInt("ScheduleID"));
                    ta.setGuideId(rs.getInt("GuideID"));
                    ta.setAssignedBy(rs.getObject("AssignedBy") != null ? rs.getInt("AssignedBy") : null);
                    ta.setAssignedAt(rs.getTimestamp("AssignedAt"));
                    ta.setNotes(rs.getString("Notes"));
                    ta.setAssignedByName(rs.getString("CoordinatorName"));

                    User guide = new User();
                    guide.setUserId(rs.getInt("GuideID"));
                    guide.setFullName(rs.getString("GuideName"));
                    ta.setGuide(guide);

                    TourSchedule sched = new TourSchedule();
                    sched.setScheduleId(rs.getInt("ScheduleID"));
                    sched.setDepartureDate(rs.getDate("DepartureDate"));
                    sched.setReturnDate(rs.getDate("ReturnDate"));

                    Tour tour = new Tour();
                    tour.setTourName(rs.getString("TourName"));
                    sched.setTour(tour);

                    ta.setSchedule(sched);
                    list.add(ta);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy danh sách phân công phân trang", ex);
        }
        return list;
    }

    /**
     * Đếm tổng số bản ghi phân công có tìm kiếm để phục vụ phân trang.
     */
    public int getAssignmentsCount(String search) {
        String searchClause = "";
        if (search != null && !search.trim().isEmpty()) {
            searchClause = "WHERE t.TourName LIKE ? OR g.FullName LIKE ? ";
        }
        String sql = "SELECT COUNT(*) "
                   + "FROM TourAssignment ta "
                   + "JOIN [User] g ON ta.GuideID = g.UserID "
                   + "JOIN TourSchedule ts ON ta.ScheduleID = ts.ScheduleID "
                   + "JOIN Tour t ON ts.TourID = t.TourID "
                   + searchClause;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search.trim() + "%";
                ps.setString(1, searchPattern);
                ps.setString(2, searchPattern);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi đếm tổng số phân công", ex);
        }
        return 0;
    }

    /**
     * Cập nhật trạng thái vận hành của Tour (Transaction-based).
     */
    public boolean updateTourStatus(int scheduleId, String newStatus, String notes, int guideId) {
        String updateScheduleSql = "UPDATE TourSchedule SET TourStatus = ? WHERE ScheduleID = ?";
        String insertStatusSql = "INSERT INTO TourStatus (ScheduleID, Status, Notes, UpdatedBy, UpdatedAt) VALUES (?, ?, ?, ?, SYSDATETIME())";
        String insertLogSql = "INSERT INTO TourOperationLog (ScheduleID, Activity, OperatedBy, CreatedAt) VALUES (?, ?, ?, SYSDATETIME())";

        try {
            connection.setAutoCommit(false);
            try (PreparedStatement psUpdate = connection.prepareStatement(updateScheduleSql);
                 PreparedStatement psStatus = connection.prepareStatement(insertStatusSql);
                 PreparedStatement psLog = connection.prepareStatement(insertLogSql)) {
                
                // 1. Cập nhật bảng TourSchedule
                psUpdate.setString(1, newStatus);
                psUpdate.setInt(2, scheduleId);
                psUpdate.executeUpdate();

                // 2. Chèn lịch sử TourStatus
                psStatus.setInt(1, scheduleId);
                psStatus.setString(2, newStatus);
                psStatus.setString(3, notes);
                psStatus.setInt(4, guideId);
                psStatus.executeUpdate();

                // 3. Ghi log hoạt động TourOperationLog
                psLog.setInt(1, scheduleId);
                psLog.setString(2, "HDV Cập nhật trạng thái thành: " + newStatus);
                psLog.setInt(3, guideId);
                psLog.executeUpdate();

                connection.commit();
                return true;
            } catch (SQLException ex) {
                connection.rollback();
                LOGGER.log(Level.SEVERE, "Lỗi khi cập nhật trạng thái tour, thực hiện rollback", ex);
            } finally {
                connection.setAutoCommit(true);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi kết nối cơ sở dữ liệu khi cập nhật trạng thái tour", ex);
        }
        return false;
    }

    /**
     * Lấy lịch sử chuyển đổi trạng thái của lịch trình.
     */
    public List<Map<String, Object>> getTourStatusHistory(int scheduleId) {
        List<Map<String, Object>> history = new ArrayList<>();
        String sql = "SELECT ts.Status, ts.Notes, ts.UpdatedAt, u.FullName "
                   + "FROM TourStatus ts "
                   + "LEFT JOIN [User] u ON ts.UpdatedBy = u.UserID "
                   + "WHERE ts.ScheduleID = ? "
                   + "ORDER BY ts.UpdatedAt DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> log = new java.util.HashMap<>();
                    log.put("status", rs.getString("Status"));
                    log.put("notes", rs.getString("Notes"));
                    log.put("updatedAt", rs.getTimestamp("UpdatedAt"));
                    log.put("fullName", rs.getString("FullName"));
                    history.add(log);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy lịch sử trạng thái của scheduleId: " + scheduleId, ex);
        }
        return history;
    }

    /**
     * Lấy danh sách phân công theo ScheduleID.
     */
    public List<TourAssignment> getAssignmentsByScheduleId(int scheduleId) {
        List<TourAssignment> list = new ArrayList<>();
        String sql = "SELECT ta.AssignmentID, ta.ScheduleID, ta.GuideID, ta.AssignedBy, ta.AssignedAt, ta.Notes, "
                   + "g.FullName as GuideName, g.Email as GuideEmail, "
                   + "c.FullName as CoordinatorName, "
                   + "ts.DepartureDate, ts.ReturnDate, "
                   + "t.TourName "
                   + "FROM TourAssignment ta "
                   + "JOIN [User] g ON ta.GuideID = g.UserID "
                   + "LEFT JOIN [User] c ON ta.AssignedBy = c.UserID "
                   + "JOIN TourSchedule ts ON ta.ScheduleID = ts.ScheduleID "
                   + "JOIN Tour t ON ts.TourID = t.TourID "
                   + "WHERE ta.ScheduleID = ? "
                   + "ORDER BY ta.AssignedAt DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TourAssignment ta = new TourAssignment();
                    ta.setAssignmentId(rs.getInt("AssignmentID"));
                    ta.setScheduleId(rs.getInt("ScheduleID"));
                    ta.setGuideId(rs.getInt("GuideID"));
                    ta.setAssignedBy(rs.getObject("AssignedBy") != null ? rs.getInt("AssignedBy") : null);
                    ta.setAssignedAt(rs.getTimestamp("AssignedAt"));
                    ta.setNotes(rs.getString("Notes"));
                    ta.setAssignedByName(rs.getString("CoordinatorName"));

                    User guide = new User();
                    guide.setUserId(rs.getInt("GuideID"));
                    guide.setFullName(rs.getString("GuideName"));
                    guide.setEmail(rs.getString("GuideEmail"));
                    ta.setGuide(guide);

                    TourSchedule sched = new TourSchedule();
                    sched.setScheduleId(rs.getInt("ScheduleID"));
                    sched.setDepartureDate(rs.getDate("DepartureDate"));
                    sched.setReturnDate(rs.getDate("ReturnDate"));

                    Tour tour = new Tour();
                    tour.setTourName(rs.getString("TourName"));
                    sched.setTour(tour);

                    ta.setSchedule(sched);
                    list.add(ta);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy phân công theo scheduleId: " + scheduleId, ex);
        }
        return list;
    }
}
