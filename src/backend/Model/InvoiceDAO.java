package Model;

// Người làm: Dương
// Thời gian tạo: 04/06/2026
// Chức năng: DAO xử lý dữ liệu liên quan bảng Invoice.
// Ý nghĩa: Đọc VATRate từ cấu hình cột Invoice.VATRate trong database

import Entities.Invoice;
import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;

public class InvoiceDAO extends DBContext {

    // Hàm getDefaultVatRatePercent đọc default value của cột Invoice.VATRate trong SQL Server.
    // Nếu DB không khai báo VATRate hợp lệ thì trả null để controller báo lỗi, không tự gán fallback trong code.
    public Double getDefaultVatRatePercent() {
        String sql = "SELECT OBJECT_DEFINITION(c.default_object_id) AS DefaultDefinition "
                   + "FROM sys.columns c "
                   + "JOIN sys.tables t ON c.object_id = t.object_id "
                   + "WHERE t.name = 'Invoice' AND c.name = 'VATRate'";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return parseVatRateDefault(rs.getString("DefaultDefinition"));
            }
        } catch (SQLException ex) {
            Logger.getLogger(InvoiceDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    // Hàm parseVatRateDefault chuyển chuỗi default constraint của SQL Server thành số phần trăm VAT.
    // Ví dụ OBJECT_DEFINITION có thể trả về dạng có ngoặc, nên cần lọc ra phần số trước khi parse.
    // Nếu không đọc được số hợp lệ hoặc số <= 0 thì trả null để luồng booking không tính sai thuế.
    private Double parseVatRateDefault(String defaultDefinition) {
        if (defaultDefinition == null || defaultDefinition.trim().isEmpty()) {
            return null;
        }

        String numericText = defaultDefinition.replaceAll("[^0-9.]", "");
        if (numericText.isEmpty()) {
            return null;
        }

        try {
            double vatRatePercent = Double.parseDouble(numericText);
            return vatRatePercent > 0 ? vatRatePercent : null;
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    // Dương làm phần này: tạo mới một bản ghi Invoice trong database sau khi thanh toán thành công.
    // Hàm nhận đầy đủ thông tin hóa đơn từ controller, INSERT vào bảng Invoice và
    // cập nhật lại invoiceId trên object để caller có thể dùng ngay mà không cần query lại.
    // RETURN_GENERATED_KEYS giúp lấy InvoiceID tự tăng vừa được tạo bởi SQL Server.
    public boolean createInvoice(Invoice invoice) {
        String sql = "INSERT INTO Invoice (InvoiceCode, BookingID, PaymentID, SubTotal, VATRate, VATAmount, DiscountAmount, TotalAmount, IssuedAt, IssuedBy) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, SYSDATETIME(), ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, invoice.getInvoiceCode());
            ps.setInt(2, invoice.getBookingId());
            ps.setInt(3, invoice.getPaymentId());
            ps.setDouble(4, invoice.getSubTotal());
            ps.setDouble(5, invoice.getVatRate());
            ps.setDouble(6, invoice.getVatAmount());
            ps.setDouble(7, invoice.getDiscountAmount());
            ps.setDouble(8, invoice.getTotalAmount());
            
            if (invoice.getIssuedBy() != null) {
                ps.setInt(9, invoice.getIssuedBy());
            } else {
                ps.setNull(9, java.sql.Types.INTEGER);
            }
            
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet gk = ps.getGeneratedKeys()) {
                    if (gk.next()) {
                        invoice.setInvoiceId(gk.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException ex) {
            Logger.getLogger(InvoiceDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    // Dương làm phần này: lấy hóa đơn theo BookingID để kiểm tra hoặc hiển thị cho khách.
    // Một booking chỉ có tối đa một Invoice nên hàm trả về đối tượng đơn lẻ thay vì List.
    // Dùng rs.wasNull() sau getInt("IssuedBy") vì cột này cho phép NULL (hệ thống tự tạo).
    public Invoice getInvoiceByBookingId(int bookingId) {
        String sql = "SELECT * FROM Invoice WHERE BookingID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Invoice invoice = new Invoice();
                    invoice.setInvoiceId(rs.getInt("InvoiceID"));
                    invoice.setInvoiceCode(rs.getString("InvoiceCode"));
                    invoice.setBookingId(rs.getInt("BookingID"));
                    invoice.setPaymentId(rs.getInt("PaymentID"));
                    invoice.setSubTotal(rs.getDouble("SubTotal"));
                    invoice.setVatRate(rs.getDouble("VATRate"));
                    invoice.setVatAmount(rs.getDouble("VATAmount"));
                    invoice.setDiscountAmount(rs.getDouble("DiscountAmount"));
                    invoice.setTotalAmount(rs.getDouble("TotalAmount"));
                    invoice.setIssuedAt(rs.getTimestamp("IssuedAt"));
                    
                    int issuedBy = rs.getInt("IssuedBy");
                    if (!rs.wasNull()) {
                        invoice.setIssuedBy(issuedBy);
                    }
                    return invoice;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(InvoiceDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }
}
