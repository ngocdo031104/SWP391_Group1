package Entities;

import java.sql.Timestamp;

public class VideoCallSchedule {
    private int callId;
    private int conversationId;
    private int organizedBy;
    private String title;
    private Timestamp scheduledAt;
    private int durationMin;
    private String meetingUrl;
    private String status; // 'Scheduled', 'Ongoing', 'Completed', 'Cancelled'
    private Timestamp createdAt;
    
    // Additional fields for UI display
    private String organizerName;

    public VideoCallSchedule() {
    }

    public int getCallId() {
        return callId;
    }

    public void setCallId(int callId) {
        this.callId = callId;
    }

    public int getConversationId() {
        return conversationId;
    }

    public void setConversationId(int conversationId) {
        this.conversationId = conversationId;
    }

    public int getOrganizedBy() {
        return organizedBy;
    }

    public void setOrganizedBy(int organizedBy) {
        this.organizedBy = organizedBy;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public Timestamp getScheduledAt() {
        return scheduledAt;
    }

    public void setScheduledAt(Timestamp scheduledAt) {
        this.scheduledAt = scheduledAt;
    }

    public int getDurationMin() {
        return durationMin;
    }

    public void setDurationMin(int durationMin) {
        this.durationMin = durationMin;
    }

    public String getMeetingUrl() {
        return meetingUrl;
    }

    public void setMeetingUrl(String meetingUrl) {
        this.meetingUrl = meetingUrl;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getOrganizerName() {
        return organizerName;
    }

    public void setOrganizerName(String organizerName) {
        this.organizerName = organizerName;
    }
}
