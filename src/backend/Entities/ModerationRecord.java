package Entities;

import java.io.Serializable;
import java.sql.Timestamp;

public class ModerationRecord implements Serializable {
    private int moderationId;
    private String entityType; // Review, CommunityPost, Comment
    private int entityId;
    private String action;     // Hide, Restore
    private String reason;
    private int moderatedBy;
    private Timestamp moderatedAt;
    
    // Joined field
    private String moderatedByName;
    private boolean isEntityVisible;

    public ModerationRecord() {
    }

    public int getModerationId() {
        return moderationId;
    }

    public void setModerationId(int moderationId) {
        this.moderationId = moderationId;
    }

    public String getEntityType() {
        return entityType;
    }

    public void setEntityType(String entityType) {
        this.entityType = entityType;
    }

    public int getEntityId() {
        return entityId;
    }

    public void setEntityId(int entityId) {
        this.entityId = entityId;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public int getModeratedBy() {
        return moderatedBy;
    }

    public void setModeratedBy(int moderatedBy) {
        this.moderatedBy = moderatedBy;
    }

    public Timestamp getModeratedAt() {
        return moderatedAt;
    }

    public void setModeratedAt(Timestamp moderatedAt) {
        this.moderatedAt = moderatedAt;
    }

    public String getModeratedByName() {
        return moderatedByName;
    }

    public void setModeratedByName(String moderatedByName) {
        this.moderatedByName = moderatedByName;
    }

    public boolean isIsEntityVisible() {
        return isEntityVisible;
    }

    public void setIsEntityVisible(boolean isEntityVisible) {
        this.isEntityVisible = isEntityVisible;
    }
}
