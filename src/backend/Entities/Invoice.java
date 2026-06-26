package Entities;

// Người làm: Dương
// Thời gian tạo: 25/06/2026
// Chức năng: Entity ánh xạ bảng Invoice trong database.
// Ý nghĩa: Mỗi đối tượng Invoice đại diện cho một hóa đơn được tạo tự động
//           sau khi SePay xác nhận thanh toán thành công. Hóa đơn lưu lại
//           đầy đủ các thông tin tài chính: tiền gốc, VAT, giảm giá, tổng tiền.

import java.io.Serializable;
import java.sql.Timestamp;

public class Invoice implements Serializable {

    // Các field ánh xạ trực tiếp từ cột trong bảng Invoice của database
    private int invoiceId;          // Khóa chính, tự tăng (InvoiceID)
    private String invoiceCode;     // Mã hóa đơn duy nhất, ví dụ: INV-42-83921
    private int bookingId;          // Khóa ngoại tới bảng Booking
    private int paymentId;          // Khóa ngoại tới bảng Payment (giao dịch đã thanh toán)
    private double subTotal;        // Tiền gốc trước VAT và giảm giá (= BaseAmount của Booking)
    private double vatRate;         // Tỉ lệ VAT tính theo %, mặc định 8.0 theo schema
    private double vatAmount;       // Số tiền VAT thực tế (= VATAmount của Booking)
    private double discountAmount;  // Số tiền được giảm qua coupon (= DiscountAmount của Booking)
    private double totalAmount;     // Tổng tiền khách phải trả sau tất cả điều chỉnh
    private Timestamp issuedAt;     // Thời điểm hóa đơn được tạo (do SYSDATETIME() gán)
    private Integer issuedBy;       // UserID của người tạo hóa đơn, null nếu hệ thống tự tạo

    // Các entity liên kết để thuận tiện truy cập từ JSP mà không cần query thêm
    private Booking booking;
    private Payment payment;

    public Invoice() {
    }

    // Constructor đầy đủ để khởi tạo Invoice từ ResultSet trong DAO
    public Invoice(int invoiceId, String invoiceCode, int bookingId, int paymentId,
                   double subTotal, double vatRate, double vatAmount,
                   double discountAmount, double totalAmount,
                   Timestamp issuedAt, Integer issuedBy) {
        this.invoiceId = invoiceId;
        this.invoiceCode = invoiceCode;
        this.bookingId = bookingId;
        this.paymentId = paymentId;
        this.subTotal = subTotal;
        this.vatRate = vatRate;
        this.vatAmount = vatAmount;
        this.discountAmount = discountAmount;
        this.totalAmount = totalAmount;
        this.issuedAt = issuedAt;
        this.issuedBy = issuedBy;
    }

    public int getInvoiceId() {
        return invoiceId;
    }

    public void setInvoiceId(int invoiceId) {
        this.invoiceId = invoiceId;
    }

    public String getInvoiceCode() {
        return invoiceCode;
    }

    public void setInvoiceCode(String invoiceCode) {
        this.invoiceCode = invoiceCode;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public int getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(int paymentId) {
        this.paymentId = paymentId;
    }

    public double getSubTotal() {
        return subTotal;
    }

    public void setSubTotal(double subTotal) {
        this.subTotal = subTotal;
    }

    public double getVatRate() {
        return vatRate;
    }

    public void setVatRate(double vatRate) {
        this.vatRate = vatRate;
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

    public Timestamp getIssuedAt() {
        return issuedAt;
    }

    public void setIssuedAt(Timestamp issuedAt) {
        this.issuedAt = issuedAt;
    }

    public Integer getIssuedBy() {
        return issuedBy;
    }

    public void setIssuedBy(Integer issuedBy) {
        this.issuedBy = issuedBy;
    }

    public Booking getBooking() {
        return booking;
    }

    public void setBooking(Booking booking) {
        this.booking = booking;
    }

    public Payment getPayment() {
        return payment;
    }

    public void setPayment(Payment payment) {
        this.payment = payment;
    }
}
