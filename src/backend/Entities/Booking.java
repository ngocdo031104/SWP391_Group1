package Entities;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.List;

public class Booking implements Serializable {
    private int bookingId;
    private String bookingCode;
    private int scheduleId;
    private int customerId;
    private int numParticipants;
    private double baseAmount;
    private double vatAmount;
    private double discountAmount;
    private double totalAmount;
    private String status;
    private String notes;
    private Integer couponId;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Linked Entities
    private User customer;
    private TourSchedule schedule;
    private Coupon coupon;
    private List<BookingParticipant> participants;

    public Booking() {
    }

    public Booking(int bookingId, String bookingCode, int scheduleId, int customerId, int numParticipants, double baseAmount, double vatAmount, double discountAmount, double totalAmount, String status, String notes, Integer couponId, Timestamp createdAt, Timestamp updatedAt) {
        this.bookingId = bookingId;
        this.bookingCode = bookingCode;
        this.scheduleId = scheduleId;
        this.customerId = customerId;
        this.numParticipants = numParticipants;
        this.baseAmount = baseAmount;
        this.vatAmount = vatAmount;
        this.discountAmount = discountAmount;
        this.totalAmount = totalAmount;
        this.status = status;
        this.notes = notes;
        this.couponId = couponId;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public String getBookingCode() {
        return bookingCode;
    }

    public void setBookingCode(String bookingCode) {
        this.bookingCode = bookingCode;
    }

    public int getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(int scheduleId) {
        this.scheduleId = scheduleId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public int getNumParticipants() {
        return numParticipants;
    }

    public void setNumParticipants(int numParticipants) {
        this.numParticipants = numParticipants;
    }

    public double getBaseAmount() {
        return baseAmount;
    }

    public void setBaseAmount(double baseAmount) {
        this.baseAmount = baseAmount;
    }

    public double getVatAmount() {
        return vatAmount;
    }

    public void setVatAmount(double vatAmount) {
        this.vatAmount = vatAmount;
    }

    public double getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(double discountAmount) {
        this.discountAmount = discountAmount;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Integer getCouponId() {
        return couponId;
    }

    public void setCouponId(Integer couponId) {
        this.couponId = couponId;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public User getCustomer() {
        return customer;
    }

    public void setCustomer(User customer) {
        this.customer = customer;
    }

    public TourSchedule getSchedule() {
        return schedule;
    }

    public void setSchedule(TourSchedule schedule) {
        this.schedule = schedule;
    }

    public Coupon getCoupon() {
        return coupon;
    }

    public void setCoupon(Coupon coupon) {
        this.coupon = coupon;
    }

    public List<BookingParticipant> getParticipants() {
        return participants;
    }

    public void setParticipants(List<BookingParticipant> participants) {
        this.participants = participants;
    }
}
