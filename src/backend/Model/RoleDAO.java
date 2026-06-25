package Model;

import Entities.Permission;
import Entities.Role;
import Utils.DBContext;
import Utils.RoleInUseException;
import Utils.SystemRoleException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class RoleDAO extends DBContext {
    private AuditLogDAO auditLogDAO = new AuditLogDAO();

    public List<Role> getAllRoles() {
        List<Role> list = new ArrayList<>();
        String sql = "SELECT r.*, (SELECT COUNT(*) FROM [User] u WHERE u.RoleID = r.RoleID) as UserCount FROM Role r";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Role r = new Role();
                r.setRoleId(rs.getInt("RoleID"));
                r.setRoleName(rs.getString("RoleName"));
                r.setDescription(rs.getString("Description"));
                r.setSystemRole(rs.getBoolean("IsSystemRole"));
                r.setUserCount(rs.getInt("UserCount"));
                r.setPermissions(getPermissionsByRoleId(r.getRoleId()));
                list.add(r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Role getRoleById(int roleId) {
        String sql = "SELECT r.*, (SELECT COUNT(*) FROM [User] u WHERE u.RoleID = r.RoleID) as UserCount FROM Role r WHERE r.RoleID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Role r = new Role();
                    r.setRoleId(rs.getInt("RoleID"));
                    r.setRoleName(rs.getString("RoleName"));
                    r.setDescription(rs.getString("Description"));
                    r.setSystemRole(rs.getBoolean("IsSystemRole"));
                    r.setUserCount(rs.getInt("UserCount"));
                    r.setPermissions(getPermissionsByRoleId(r.getRoleId()));
                    return r;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    public List<Permission> getPermissionsByRoleId(int roleId) {
        List<Permission> list = new ArrayList<>();
        String sql = "SELECT p.* FROM Permission p JOIN Role_Permission rp ON p.PermissionID = rp.PermissionID WHERE rp.RoleID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Permission p = new Permission();
                    p.setPermissionId(rs.getInt("PermissionID"));
                    p.setModuleName(rs.getString("ModuleName"));
                    p.setAction(rs.getString("Action"));
                    p.setDescription(rs.getString("Description"));
                    p.setIsCritical(rs.getBoolean("IsCritical"));
                    list.add(p);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean createRole(Role role, int adminId) {
        String sql = "INSERT INTO Role (RoleName, Description, IsSystemRole, IsActive, CreatedAt) VALUES (?, ?, 0, 1, SYSDATETIME())";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, role.getRoleName());
            ps.setString(2, role.getDescription());
            if (ps.executeUpdate() > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int newRoleId = rs.getInt(1);
                        auditLogDAO.insertLog(adminId, "CREATE_ROLE", newRoleId, "Created new role: " + role.getRoleName());
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateRole(Role role, int adminId) throws RoleInUseException, SystemRoleException {
        Role existingRole = getRoleById(role.getRoleId());
        if (existingRole != null && existingRole.isSystemRole()) {
            throw new SystemRoleException("Không thể chỉnh sửa vai trò hệ thống mặc định!");
        }
        
        String sql = "UPDATE Role SET RoleName = ?, Description = ? WHERE RoleID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, role.getRoleName());
            ps.setString(2, role.getDescription());
            ps.setInt(3, role.getRoleId());
            if (ps.executeUpdate() > 0) {
                auditLogDAO.insertLog(adminId, "UPDATE_ROLE", role.getRoleId(), "Updated role info: " + role.getRoleName());
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteRole(int roleId, int adminId) throws RoleInUseException, SystemRoleException {
        Role existingRole = getRoleById(roleId);
        if (existingRole != null && existingRole.isSystemRole()) {
            throw new SystemRoleException("Không thể xóa vai trò hệ thống mặc định!");
        }
        
        try {
            // First check if role is assigned to users
            String checkSql = "SELECT COUNT(*) FROM [User] WHERE RoleID = ?";
            try (PreparedStatement checkPs = connection.prepareStatement(checkSql)) {
                checkPs.setInt(1, roleId);
                ResultSet rs = checkPs.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    throw new RoleInUseException("Không thể xóa vai trò này vì đang có user sử dụng!");
                }
            }

            connection.setAutoCommit(false);
            
            // Delete permissions
            String delPerms = "DELETE FROM Role_Permission WHERE RoleID = ?";
            try(PreparedStatement ps1 = connection.prepareStatement(delPerms)) {
                ps1.setInt(1, roleId);
                ps1.executeUpdate();
            }
            
            // Delete Role
            String delRole = "DELETE FROM Role WHERE RoleID = ?";
            try(PreparedStatement ps2 = connection.prepareStatement(delRole)) {
                ps2.setInt(1, roleId);
                ps2.executeUpdate();
            }
            
            auditLogDAO.insertLog(adminId, "DELETE_ROLE", roleId, "Deleted role ID: " + roleId);
            connection.commit();
            return true;
        } catch (SQLException e) {
            try { connection.rollback(); } catch (SQLException ex) {}
            e.printStackTrace();
        } finally {
            try { connection.setAutoCommit(true); } catch (SQLException ex) {}
        }
        return false;
    }
    
    public void updateRolePermissions(int roleId, String[] permissionIds, int adminId) throws IllegalArgumentException {
        if (permissionIds == null || permissionIds.length == 0) {
            throw new IllegalArgumentException("Một vai trò phải có ít nhất một quyền.");
        }
        
        try {
            connection.setAutoCommit(false);
            // Delete old
            String delSql = "DELETE FROM Role_Permission WHERE RoleID = ?";
            try(PreparedStatement ps1 = connection.prepareStatement(delSql)) {
                ps1.setInt(1, roleId);
                ps1.executeUpdate();
            }
            
            // Insert new
            String insSql = "INSERT INTO Role_Permission (RoleID, PermissionID) VALUES (?, ?)";
            try(PreparedStatement ps2 = connection.prepareStatement(insSql)) {
                for (String pidStr : permissionIds) {
                    int pid = Integer.parseInt(pidStr);
                    ps2.setInt(1, roleId);
                    ps2.setInt(2, pid);
                    ps2.addBatch();
                }
                ps2.executeBatch();
            }
            
            auditLogDAO.insertLog(adminId, "UPDATE_PERMISSIONS", roleId, "Updated permissions for role ID: " + roleId);
            connection.commit();
        } catch (SQLException e) {
            try { connection.rollback(); } catch (SQLException ex) {}
            e.printStackTrace();
        } finally {
            try { connection.setAutoCommit(true); } catch (SQLException ex) {}
        }
    }
}
