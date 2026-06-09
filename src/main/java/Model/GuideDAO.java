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
        String sql = "SELECT gp.GuideProfileID, gp.UserID, gp.YearsOfExperience, gp.TotalToursLed, gp.Rating, gp.Bio, gp.Specialization, gp.Languages, gp.Certifications, gp.EmergencyPhone, gp.IsActive as ProfileActive, gp.CreatedAt as ProfileCreated, gp.UpdatedAt as ProfileUpdated, "
                   + "u.Email, u.FullName, u.PhoneNumber, u.IsActive as UserActive, u.IsVerified, u.CreatedAt as UserCreated, u.RoleID, "
                   + "up.AvatarURL "
                   + "FROM GuideProfile gp "
                   + "JOIN [User] u ON gp.UserID = u.UserID "
                   + "LEFT JOIN UserProfile up ON u.UserID = up.UserID "
                   + "WHERE u.RoleID = 3 AND gp.IsActive = 1 "
                   + "ORDER BY gp.Rating DESC, gp.YearsOfExperience DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
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

                // Gán Profile
                UserProfile up = new UserProfile();
                up.setUserId(rs.getInt("UserID"));
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
        }
        return false;
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
        }
        return false;
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
        String insertStatusSql = "INSERT INTO TourStatus (ScheduleID, Status, Notes, UpdatedBy, UpdatedAt) VALUES (?, 'Scheduled', N'Phân công Hướng dẫn viên', ?, SYSDATETIME())";
        String insertAssignmentSql = "INSERT INTO TourAssignment (ScheduleID, GuideID, AssignedBy, AssignedAt, Notes) VALUES (?, ?, ?, SYSDATETIME(), ?)";

        try {
            // Thiết lập chế độ chạy Transaction thủ công
            connection.setAutoCommit(false);

            try (PreparedStatement psStatus = connection.prepareStatement(insertStatusSql);
                 PreparedStatement psInsert = connection.prepareStatement(insertAssignmentSql)) {
                
                // Bước 1: Thêm lịch sử trạng thái
                psStatus.setInt(1, scheduleId);
                psStatus.setInt(2, assignedBy);
                psStatus.executeUpdate();

                // Bước 2: Chèn bản ghi lịch sử phân công TourAssignment
                psInsert.setInt(1, scheduleId);
                psInsert.setInt(2, guideId);
                psInsert.setInt(3, assignedBy);
                psInsert.setString(4, notes);
                psInsert.executeUpdate();

                // Commit giao dịch
                connection.commit();
                return true;
            } catch (SQLException ex) {
                // Có lỗi xảy ra, thực hiện rollback để tránh bất đồng bộ dữ liệu
                connection.rollback();
                LOGGER.log(Level.SEVERE, "Lỗi xảy ra trong transaction phân công HDV, đã thực hiện rollback", ex);
            } finally {
                // Khôi phục lại chế độ AutoCommit mặc định
                connection.setAutoCommit(true);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi kết nối cơ sở dữ liệu khi phân công HDV", ex);
        }
        return false;
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
}
