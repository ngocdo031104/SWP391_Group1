package Entities;

import java.io.Serializable;
import java.sql.Timestamp;

public class CancellationRequest implements Serializable {
    private int requestId;
    private int bookingId;
    private int requestedBy;
    private String reason;
    private String status;
    private Integer processedBy;
    private Timestamp processedAt;
    private String notes;
    private Timestamp createdAt;

    // Extra fields for Accountant View
    private String bookingCode;
    private double totalAmount;
    private String customerName;
    private String customerEmail;
    private String tourName;
    private java.sql.Date departureDate;

    public String getBookingCode() { return bookingCode; }
    public void setBookingCode(String bookingCode) { this.bookingCode = bookingCode; }
    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    public String getCustomerEmail() { return customerEmail; }
    public void setCustomerEmail(String customerEmail) { this.customerEmail = customerEmail; }
    public String getTourName() { return tourName; }
    public void setTourName(String tourName) { this.tourName = tourName; }
    public java.sql.Date getDepartureDate() { return departureDate; }
    public void setDepartureDate(java.sql.Date departureDate) { this.departureDate = departureDate; }

    public CancellationRequest() {
    }

    public CancellationRequest(int requestId, int bookingId, int requestedBy, String reason, String status, Integer processedBy, Timestamp processedAt, String notes, Timestamp createdAt) {
        this.requestId = requestId;
        this.bookingId = bookingId;
        this.requestedBy = requestedBy;
        this.reason = reason;
        this.status = status;
        this.processedBy = processedBy;
        this.processedAt = processedAt;
        this.notes = notes;
        this.createdAt = createdAt;
    }

    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public int getRequestedBy() {
        return requestedBy;
    }

    public void setRequestedBy(int requestedBy) {
        this.requestedBy = requestedBy;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getProcessedBy() {
        return processedBy;
    }

    public void setProcessedBy(Integer processedBy) {
        this.processedBy = processedBy;
    }

    public Timestamp getProcessedAt() {
        return processedAt;
    }

    public void setProcessedAt(Timestamp processedAt) {
        this.processedAt = processedAt;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
