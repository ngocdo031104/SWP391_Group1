package Entities;

import java.sql.Timestamp;

public class ConversationParticipant {
    private int participantId;
    private int conversationId;
    private int userId;
    private String role; // "Admin", "Member"
    private Timestamp joinedAt;
    private Integer lastReadMessageId;

    // Additional fields for displaying in UI
    private String userName;
    private String userAvatar;

    public ConversationParticipant() {}

    public ConversationParticipant(int participantId, int conversationId, int userId, String role, Timestamp joinedAt, Integer lastReadMessageId) {
        this.participantId = participantId;
        this.conversationId = conversationId;
        this.userId = userId;
        this.role = role;
        this.joinedAt = joinedAt;
        this.lastReadMessageId = lastReadMessageId;
    }

    public int getParticipantId() { return participantId; }
    public void setParticipantId(int participantId) { this.participantId = participantId; }
    public int getConversationId() { return conversationId; }
    public void setConversationId(int conversationId) { this.conversationId = conversationId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public Timestamp getJoinedAt() { return joinedAt; }
    public void setJoinedAt(Timestamp joinedAt) { this.joinedAt = joinedAt; }
    public Integer getLastReadMessageId() { return lastReadMessageId; }
    public void setLastReadMessageId(Integer lastReadMessageId) { this.lastReadMessageId = lastReadMessageId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
    public String getUserAvatar() { return userAvatar; }
    public void setUserAvatar(String userAvatar) { this.userAvatar = userAvatar; }
}
