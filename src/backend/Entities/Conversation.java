package Entities;

import java.sql.Timestamp;

public class Conversation {
    private int conversationId;
    private String type; // "Direct" or "Group"
    private String title; // Nullable for Direct
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Conversation() {}

    public Conversation(int conversationId, String type, String title, Timestamp createdAt, Timestamp updatedAt) {
        this.conversationId = conversationId;
        this.type = type;
        this.title = title;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getConversationId() { return conversationId; }
    public void setConversationId(int conversationId) { this.conversationId = conversationId; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
