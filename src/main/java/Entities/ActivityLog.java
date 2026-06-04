package Entities;

import java.sql.Timestamp;

public class ActivityLog {
    private String type;
    private String action;
    private Timestamp createdAt;

    public ActivityLog() {
    }

    public ActivityLog(String type, String action, Timestamp createdAt) {
        this.type = type;
        this.action = action;
        this.createdAt = createdAt;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
