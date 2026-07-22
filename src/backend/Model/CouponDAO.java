package Model;

import Entities.Coupon;
import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CouponDAO extends DBContext {

    /**
     * Gets a coupon by its code and validates whether it's active and in date range.
     * @param couponCode the coupon code string
     * @return Coupon object or null if not found/inactive/expired
     */
    public Coupon getCouponByCode(String couponCode) {
        String sql = "SELECT CouponID, CouponCode, DiscountType, DiscountValue, MinOrderAmount, MaxDiscountAmount, MaxUses, UsedCount, StartDate, EndDate, IsActive, CreatedBy, CreatedAt "
                   + "FROM Coupon WHERE CouponCode = ? AND IsActive = 1 AND CAST(GETDATE() AS DATE) BETWEEN StartDate AND EndDate";        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, couponCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Coupon coupon = new Coupon(
                        rs.getInt("CouponID"),
                        rs.getString("CouponCode"),
                        rs.getString("DiscountType"),
                        rs.getDouble("DiscountValue"),
                        rs.getDouble("MinOrderAmount"),
                        rs.getObject("MaxDiscountAmount") != null ? rs.getDouble("MaxDiscountAmount") : null,
                        rs.getObject("MaxUses") != null ? rs.getInt("MaxUses") : null,
                        rs.getInt("UsedCount"),
                        rs.getDate("StartDate"),
                        rs.getDate("EndDate"),
                        rs.getBoolean("IsActive"),
                        rs.getObject("CreatedBy") != null ? rs.getInt("CreatedBy") : null,
                        rs.getTimestamp("CreatedAt")
                    );
                    
                    // Check if it has reached max uses limit
                    if (coupon.getMaxUses() != null && coupon.getUsedCount() >= coupon.getMaxUses()) {
                        return null; // Expired by usage limit
                    }
                    return coupon;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(CouponDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    /**
     * Increments the usage count of a coupon.
     * @param couponId coupon ID
     * @return true if updated, false otherwise
     */
    public boolean updateCouponUsage(int couponId) {
        String sql = "UPDATE Coupon SET UsedCount = UsedCount + 1 WHERE CouponID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, couponId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(CouponDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    // Người làm đoạn này: Dương
    // Lấy tất cả danh sách coupon trong hệ thống để hiển thị trên bảng quản lý (Admin).
    public java.util.List<Coupon> getAllCoupons() {
        java.util.List<Coupon> list = new java.util.ArrayList<>();
        String sql = "SELECT * FROM Coupon ORDER BY CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Coupon coupon = new Coupon(
                    rs.getInt("CouponID"),
                    rs.getString("CouponCode"),
                    rs.getString("DiscountType"),
                    rs.getDouble("DiscountValue"),
                    rs.getDouble("MinOrderAmount"),
                    rs.getObject("MaxDiscountAmount") != null ? rs.getDouble("MaxDiscountAmount") : null,
                    rs.getObject("MaxUses") != null ? rs.getInt("MaxUses") : null,
                    rs.getInt("UsedCount"),
                    rs.getDate("StartDate"),
                    rs.getDate("EndDate"),
                    rs.getBoolean("IsActive"),
                    rs.getObject("CreatedBy") != null ? rs.getInt("CreatedBy") : null,
                    rs.getTimestamp("CreatedAt")
                );
                list.add(coupon);
            }
        } catch (SQLException ex) {
            Logger.getLogger(CouponDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    // Người làm đoạn này: Dương
    // Thêm mới một coupon vào cơ sở dữ liệu.
    public boolean createCoupon(Coupon coupon) {
        String sql = "INSERT INTO Coupon (CouponCode, DiscountType, DiscountValue, MinOrderAmount, MaxDiscountAmount, MaxUses, StartDate, EndDate, IsActive, CreatedBy) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, coupon.getCouponCode());
            ps.setString(2, coupon.getDiscountType());
            ps.setDouble(3, coupon.getDiscountValue());
            ps.setDouble(4, coupon.getMinOrderAmount());
            if (coupon.getMaxDiscountAmount() != null) {
                ps.setDouble(5, coupon.getMaxDiscountAmount());
            } else {
                ps.setNull(5, java.sql.Types.DECIMAL);
            }
            if (coupon.getMaxUses() != null) {
                ps.setInt(6, coupon.getMaxUses());
            } else {
                ps.setNull(6, java.sql.Types.INTEGER);
            }
            ps.setDate(7, coupon.getStartDate());
            ps.setDate(8, coupon.getEndDate());
            ps.setBoolean(9, coupon.isIsActive());
            if (coupon.getCreatedBy() != null) {
                ps.setInt(10, coupon.getCreatedBy());
            } else {
                ps.setNull(10, java.sql.Types.INTEGER);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(CouponDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    // Người làm đoạn này: Dương
    // Cập nhật thông tin chi tiết của một coupon có sẵn.
    public boolean updateCoupon(Coupon coupon) {
        String sql = "UPDATE Coupon SET CouponCode=?, DiscountType=?, DiscountValue=?, MinOrderAmount=?, MaxDiscountAmount=?, MaxUses=?, StartDate=?, EndDate=?, IsActive=? "
                   + "WHERE CouponID=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, coupon.getCouponCode());
            ps.setString(2, coupon.getDiscountType());
            ps.setDouble(3, coupon.getDiscountValue());
            ps.setDouble(4, coupon.getMinOrderAmount());
            if (coupon.getMaxDiscountAmount() != null) {
                ps.setDouble(5, coupon.getMaxDiscountAmount());
            } else {
                ps.setNull(5, java.sql.Types.DECIMAL);
            }
            if (coupon.getMaxUses() != null) {
                ps.setInt(6, coupon.getMaxUses());
            } else {
                ps.setNull(6, java.sql.Types.INTEGER);
            }
            ps.setDate(7, coupon.getStartDate());
            ps.setDate(8, coupon.getEndDate());
            ps.setBoolean(9, coupon.isIsActive());
            ps.setInt(10, coupon.getCouponId());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(CouponDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    // Người làm đoạn này: Dương
    // Đổi trạng thái kích hoạt (Active/Inactive) của coupon.
    public boolean toggleStatus(int couponId, boolean newStatus) {
        String sql = "UPDATE Coupon SET IsActive = ? WHERE CouponID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setBoolean(1, newStatus);
            ps.setInt(2, couponId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(CouponDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    // Kiểm tra trùng mã coupon.
    // excludeId: khi update, truyền couponId hiện tại để bỏ qua chính nó.
    // Khi tạo mới, truyền -1 để kiểm tra toàn bộ bảng.
    public boolean isCouponCodeExists(String couponCode, int excludeId) {
        String sql = "SELECT COUNT(*) FROM Coupon WHERE UPPER(CouponCode) = UPPER(?) AND CouponID != ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, couponCode);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(CouponDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    // Người làm đoạn này: Dương
    // Xóa một coupon khỏi hệ thống dựa trên ID.
    public boolean deleteCoupon(int couponId) {
        String sql = "DELETE FROM Coupon WHERE CouponID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, couponId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(CouponDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    /**
     * Lấy coupon theo ID (dùng cho form edit — không filter trạng thái).
     */
    public Coupon getCouponById(int couponId) {
        String sql = "SELECT CouponID, CouponCode, DiscountType, DiscountValue, MinOrderAmount, MaxDiscountAmount, MaxUses, UsedCount, StartDate, EndDate, IsActive, CreatedBy, CreatedAt "
                   + "FROM Coupon WHERE CouponID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, couponId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Coupon(
                        rs.getInt("CouponID"),
                        rs.getString("CouponCode"),
                        rs.getString("DiscountType"),
                        rs.getDouble("DiscountValue"),
                        rs.getDouble("MinOrderAmount"),
                        rs.getObject("MaxDiscountAmount") != null ? rs.getDouble("MaxDiscountAmount") : null,
                        rs.getObject("MaxUses") != null ? rs.getInt("MaxUses") : null,
                        rs.getInt("UsedCount"),
                        rs.getDate("StartDate"),
                        rs.getDate("EndDate"),
                        rs.getBoolean("IsActive"),
                        rs.getObject("CreatedBy") != null ? rs.getInt("CreatedBy") : null,
                        rs.getTimestamp("CreatedAt")
                    );
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(CouponDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }
}

