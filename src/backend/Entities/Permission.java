package Entities;

import java.io.Serializable;
import java.sql.Timestamp;

public class Permission implements Serializable {
    private int permissionId;
    private String moduleName;
    private String action;
    private String description;
    private boolean isCritical;
    private Timestamp createdAt;

    public Permission() {
    }

    public Permission(int permissionId, String moduleName, String action, String description, boolean isCritical, Timestamp createdAt) {
        this.permissionId = permissionId;
        this.moduleName = moduleName;
        this.action = action;
        this.description = description;
        this.isCritical = isCritical;
        this.createdAt = createdAt;
    }

    public int getPermissionId() {
        return permissionId;
    }

    public void setPermissionId(int permissionId) {
        this.permissionId = permissionId;
    }

    public String getModuleName() {
        return moduleName;
    }

    public void setModuleName(String moduleName) {
        this.moduleName = moduleName;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isIsCritical() {
        return isCritical;
    }

    public void setIsCritical(boolean isCritical) {
        this.isCritical = isCritical;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
