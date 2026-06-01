package Model;

import Entities.Role;
import Entities.User;
import Entities.UserProfile;
import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UserDAO extends DBContext {

    /**
     * Authenticates user with email and password hash.
     * @param email user email
     * @param passwordHash user password hash
     * @return User object with Role details, or null if authentication fails
     */
    public User login(String email, String passwordHash) {
        String sql = "SELECT u.UserID, u.RoleID, u.Email, u.FullName, u.PhoneNumber, u.IsActive, u.IsVerified, u.CreatedAt, u.UpdatedAt, u.LastLoginAt, "
                   + "r.RoleName, r.Description AS RoleDesc "
                   + "FROM [User] u "
                   + "JOIN Role r ON u.RoleID = r.RoleID "
                   + "WHERE u.Email = ? AND u.PasswordHash = ? AND u.IsActive = 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, passwordHash);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("UserID"));
                    user.setRoleId(rs.getInt("RoleID"));
                    user.setEmail(rs.getString("Email"));
                    user.setFullName(rs.getString("FullName"));
                    user.setPhoneNumber(rs.getString("PhoneNumber"));
                    user.setIsActive(rs.getBoolean("IsActive"));
                    user.setIsVerified(rs.getBoolean("IsVerified"));
                    user.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    user.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                    user.setLastLoginAt(rs.getTimestamp("LastLoginAt"));

                    Role role = new Role();
                    role.setRoleId(rs.getInt("RoleID"));
                    role.setRoleName(rs.getString("RoleName"));
                    role.setDescription(rs.getString("RoleDesc"));
                    user.setRole(role);
                    
                    // Update LastLoginAt in the background
                    updateLastLogin(user.getUserId());
                    
                    return user;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    /**
     * Registers a new user and creates their profile within a database transaction.
     * @param user user details
     * @param profile profile details
     * @return true if registration is successful, false otherwise
     */
    public boolean register(User user, UserProfile profile) {
        String insertUserSql = "INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt, UpdatedAt) "
                             + "VALUES (?, ?, ?, ?, ?, 1, 0, SYSDATETIME(), SYSDATETIME())";
        String insertProfileSql = "INSERT INTO UserProfile (UserID, AvatarURL, Biography, DateOfBirth, Gender, Address, TravelInterests, UpdatedAt) "
                                + "VALUES (?, ?, ?, ?, ?, ?, ?, SYSDATETIME())";
        
        try {
            connection.setAutoCommit(false); // Start Transaction
            
            try (PreparedStatement psUser = connection.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS)) {
                psUser.setInt(1, user.getRoleId());
                psUser.setString(2, user.getEmail());
                psUser.setString(3, user.getPasswordHash());
                psUser.setString(4, user.getFullName());
                psUser.setString(5, user.getPhoneNumber());
                
                int affectedRows = psUser.executeUpdate();
                if (affectedRows == 0) {
                    throw new SQLException("Creating user failed, no rows affected.");
                }
                
                int userId;
                try (ResultSet generatedKeys = psUser.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        userId = generatedKeys.getInt(1);
                    } else {
                        throw new SQLException("Creating user failed, no ID obtained.");
                    }
                }
                
                try (PreparedStatement psProfile = connection.prepareStatement(insertProfileSql)) {
                    psProfile.setInt(1, userId);
                    psProfile.setString(2, profile.getAvatarUrl());
                    psProfile.setString(3, profile.getBiography());
                    psProfile.setDate(4, profile.getDateOfBirth());
                    psProfile.setString(5, profile.getGender());
                    psProfile.setString(6, profile.getAddress());
                    psProfile.setString(7, profile.getTravelInterests());
                    
                    psProfile.executeUpdate();
                }
            }
            
            connection.commit(); // Commit Transaction
            return true;
        } catch (SQLException ex) {
            try {
                if (connection != null) {
                    connection.rollback(); // Rollback Transaction on error
                }
            } catch (SQLException rollbackEx) {
                Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, rollbackEx);
            }
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                connection.setAutoCommit(true);
            } catch (SQLException ex) {
                Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        return false;
    }

    /**
     * Gets complete user details including role and profile by user ID.
     * @param userId user ID
     * @return User object or null if not found
     */
    public User getUserById(int userId) {
        String sql = "SELECT u.UserID, u.RoleID, u.Email, u.FullName, u.PhoneNumber, u.IsActive, u.IsVerified, u.CreatedAt, u.UpdatedAt, u.LastLoginAt, "
                   + "r.RoleName, r.Description AS RoleDesc, "
                   + "p.ProfileID, p.AvatarURL, p.Biography, p.DateOfBirth, p.Gender, p.Address, p.TravelInterests "
                   + "FROM [User] u "
                   + "JOIN Role r ON u.RoleID = r.RoleID "
                   + "LEFT JOIN UserProfile p ON u.UserID = p.UserID "
                   + "WHERE u.UserID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("UserID"));
                    user.setRoleId(rs.getInt("RoleID"));
                    user.setEmail(rs.getString("Email"));
                    user.setFullName(rs.getString("FullName"));
                    user.setPhoneNumber(rs.getString("PhoneNumber"));
                    user.setIsActive(rs.getBoolean("IsActive"));
                    user.setIsVerified(rs.getBoolean("IsVerified"));
                    user.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    user.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                    user.setLastLoginAt(rs.getTimestamp("LastLoginAt"));

                    Role role = new Role();
                    role.setRoleId(rs.getInt("RoleID"));
                    role.setRoleName(rs.getString("RoleName"));
                    role.setDescription(rs.getString("RoleDesc"));
                    user.setRole(role);

                    if (rs.getObject("ProfileID") != null) {
                        UserProfile profile = new UserProfile();
                        profile.setProfileId(rs.getInt("ProfileID"));
                        profile.setUserId(userId);
                        profile.setAvatarUrl(rs.getString("AvatarURL"));
                        profile.setBiography(rs.getString("Biography"));
                        profile.setDateOfBirth(rs.getDate("DateOfBirth"));
                        profile.setGender(rs.getString("Gender"));
                        profile.setAddress(rs.getString("Address"));
                        profile.setTravelInterests(rs.getString("TravelInterests"));
                        user.setProfile(profile);
                    }
                    return user;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    /**
     * Updates profile and user details within a transaction.
     * @param user user details to update
     * @param profile profile details to update
     * @return true if updated successfully, false otherwise
     */
    public boolean updateProfile(User user, UserProfile profile) {
        String updateUserSql = "UPDATE [User] SET FullName = ?, PhoneNumber = ?, UpdatedAt = SYSDATETIME() WHERE UserID = ?";
        String updateProfileSql = "UPDATE UserProfile SET AvatarURL = ?, Biography = ?, DateOfBirth = ?, Gender = ?, Address = ?, TravelInterests = ?, UpdatedAt = SYSDATETIME() WHERE UserID = ?";
        try {
            connection.setAutoCommit(false); // Start Transaction
            
            try (PreparedStatement psUser = connection.prepareStatement(updateUserSql)) {
                psUser.setString(1, user.getFullName());
                psUser.setString(2, user.getPhoneNumber());
                psUser.setInt(3, user.getUserId());
                psUser.executeUpdate();
            }
            
            try (PreparedStatement psProfile = connection.prepareStatement(updateProfileSql)) {
                psProfile.setString(1, profile.getAvatarUrl());
                psProfile.setString(2, profile.getBiography());
                psProfile.setDate(3, profile.getDateOfBirth());
                psProfile.setString(4, profile.getGender());
                psProfile.setString(5, profile.getAddress());
                psProfile.setString(6, profile.getTravelInterests());
                psProfile.setInt(7, profile.getUserId());
                psProfile.executeUpdate();
            }
            
            connection.commit(); // Commit Transaction
            return true;
        } catch (SQLException ex) {
            try {
                if (connection != null) {
                    connection.rollback(); // Rollback on error
                }
            } catch (SQLException rollbackEx) {
                Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, rollbackEx);
            }
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                connection.setAutoCommit(true);
            } catch (SQLException ex) {
                Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        return false;
    }

    /**
     * Changes user password.
     * @param userId user ID
     * @param newPasswordHash new password hash
     * @return true if change successful, false otherwise
     */
    public boolean changePassword(int userId, String newPasswordHash) {
        String sql = "UPDATE [User] SET PasswordHash = ?, UpdatedAt = SYSDATETIME() WHERE UserID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    private void updateLastLogin(int userId) {
        String sql = "UPDATE [User] SET LastLoginAt = SYSDATETIME() WHERE UserID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, "Failed to update last login time", ex);
        }
    }
}
