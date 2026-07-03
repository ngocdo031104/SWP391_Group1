package Entities;

import java.io.Serializable;
import java.sql.Timestamp;

public class AuditLog implements Serializable {
    private int logId;
    private int adminId;
    private String actionType;
    private Integer targetRoleId;
    private String details;
    private Timestamp createdAt;

    public AuditLog() {
    }

    public AuditLog(int logId, int adminId, String actionType, Integer targetRoleId, String details, Timestamp createdAt) {
        this.logId = logId;
        this.adminId = adminId;
        this.actionType = actionType;
        this.targetRoleId = targetRoleId;
        this.details = details;
        this.createdAt = createdAt;
    }

    public int getLogId() {
        return logId;
    }

    public void setLogId(int logId) {
        this.logId = logId;
    }

    public int getAdminId() {
        return adminId;
    }

    public void setAdminId(int adminId) {
        this.adminId = adminId;
    }

    public String getActionType() {
        return actionType;
    }

    public void setActionType(String actionType) {
        this.actionType = actionType;
    }

    public Integer getTargetRoleId() {
        return targetRoleId;
    }

    public void setTargetRoleId(Integer targetRoleId) {
        this.targetRoleId = targetRoleId;
    }

    public String getDetails() {
        return details;
    }

    public void setDetails(String details) {
        this.details = details;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
