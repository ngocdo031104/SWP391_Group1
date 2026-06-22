package Entities;

import java.io.Serializable;
import java.sql.Timestamp;

public class Notification implements Serializable {
    private int notificationId;
    private int userId;
    private Integer senderId;
    private String title;
    private String content;
    private String channel;
    private String category;
    private boolean isRead;
    private Timestamp createdAt;
    private Timestamp scheduledAt;
    private String status;
    
    // For joining with User (sender)
    private String senderName;

    public Notification() {
    }

    public Notification(int notificationId, int userId, Integer senderId, String title, String content, String channel, String category, boolean isRead, Timestamp createdAt, Timestamp scheduledAt, String status) {
        this.notificationId = notificationId;
        this.userId = userId;
        this.senderId = senderId;
        this.title = title;
        this.content = content;
        this.channel = channel;
        this.category = category;
        this.isRead = isRead;
        this.createdAt = createdAt;
        this.scheduledAt = scheduledAt;
        this.status = status;
    }

    public int getNotificationId() {
        return notificationId;
    }

    public void setNotificationId(int notificationId) {
        this.notificationId = notificationId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public Integer getSenderId() {
        return senderId;
    }

    public void setSenderId(Integer senderId) {
        this.senderId = senderId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getChannel() {
        return channel;
    }

    public void setChannel(String channel) {
        this.channel = channel;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public boolean isIsRead() {
        return isRead;
    }

    public void setIsRead(boolean isRead) {
        this.isRead = isRead;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getScheduledAt() {
        return scheduledAt;
    }

    public void setScheduledAt(Timestamp scheduledAt) {
        this.scheduledAt = scheduledAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getSenderName() {
        return senderName;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }
}
