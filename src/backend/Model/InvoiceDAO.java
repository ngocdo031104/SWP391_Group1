package Model;

// Người làm: Dương
// Thời gian tạo: 04/06/2026
// Chức năng: DAO xử lý dữ liệu liên quan bảng Invoice.
// Ý nghĩa: Đọc VATRate từ cấu hình cột Invoice.VATRate trong database

import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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
}
