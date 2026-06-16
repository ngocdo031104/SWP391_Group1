package Entities;

import java.io.Serializable;
import java.sql.Timestamp;

public class BookingParticipant implements Serializable {
    private int participantId;
    private int bookingId;
    private String fullName;
    private String ageType; // Adult, Child, Infant
    private String phoneNumber;
    private String email;
    private boolean isLeader;
    private Timestamp createdAt;

    public BookingParticipant() {
    }

    public BookingParticipant(int participantId, int bookingId, String fullName, String ageType, String phoneNumber, String email, boolean isLeader, Timestamp createdAt) {
        this.participantId = participantId;
        this.bookingId = bookingId;
        this.fullName = fullName;
        this.ageType = ageType;
        this.phoneNumber = phoneNumber;
        this.email = email;
        this.isLeader = isLeader;
        this.createdAt = createdAt;
    }

    public int getParticipantId() {
        return participantId;
    }

    public void setParticipantId(int participantId) {
        this.participantId = participantId;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getAgeType() {
        return ageType;
    }

    public void setAgeType(String ageType) {
        this.ageType = ageType;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public boolean isIsLeader() {
        return isLeader;
    }

    public void setIsLeader(boolean isLeader) {
        this.isLeader = isLeader;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
