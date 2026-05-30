package Entities;

import java.io.Serializable;
import java.sql.Timestamp;

public class Payment implements Serializable {
    private int paymentId;
    private int bookingId;
    private String paymentMethod; // CreditCard, BankTransfer, MoMo, VNPay
    private String transactionRef;
    private double amount;
    private String currency;
    private String status; // Pending, Success, Failed, Refunded
    private Timestamp paidAt;
    private String gatewayResponse;
    private Timestamp createdAt;

    public Payment() {
    }

    public Payment(int paymentId, int bookingId, String paymentMethod, String transactionRef, double amount, String currency, String status, Timestamp paidAt, String gatewayResponse, Timestamp createdAt) {
        this.paymentId = paymentId;
        this.bookingId = bookingId;
        this.paymentMethod = paymentMethod;
        this.transactionRef = transactionRef;
        this.amount = amount;
        this.currency = currency;
        this.status = status;
        this.paidAt = paidAt;
        this.gatewayResponse = gatewayResponse;
        this.createdAt = createdAt;
    }

    public int getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(int paymentId) {
        this.paymentId = paymentId;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getTransactionRef() {
        return transactionRef;
    }

    public void setTransactionRef(String transactionRef) {
        this.transactionRef = transactionRef;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getPaidAt() {
        return paidAt;
    }

    public void setPaidAt(Timestamp paidAt) {
        this.paidAt = paidAt;
    }

    public String getGatewayResponse() {
        return gatewayResponse;
    }

    public void setGatewayResponse(String gatewayResponse) {
        this.gatewayResponse = gatewayResponse;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
