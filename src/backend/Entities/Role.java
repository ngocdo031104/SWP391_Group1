package Entities;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.List;

public class Role implements Serializable {
    private int roleId;
    private String roleName;
    private String description;
    private boolean isActive;
    private Timestamp createdAt;
    private List<Permission> permissions;
    private boolean isSystemRole;
    private int userCount;

    public Role() {
    }

    public int getUserCount() {
        return userCount;
    }

    public void setUserCount(int userCount) {
        this.userCount = userCount;
    }

    public Role(int roleId, String roleName, String description, boolean isActive, Timestamp createdAt) {
        this.roleId = roleId;
        this.roleName = roleName;
        this.description = description;
        this.isActive = isActive;
        this.createdAt = createdAt;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public List<Permission> getPermissions() {
        return permissions;
    }

    public void setPermissions(List<Permission> permissions) {
        this.permissions = permissions;
    }

    public boolean isSystemRole() {
        return isSystemRole;
    }

    public void setSystemRole(boolean isSystemRole) {
        this.isSystemRole = isSystemRole;
    }
}
