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
        String sql = "SELECT CouponID, CouponCode, DiscountType, DiscountValue, MinOrderAmount, MaxUses, UsedCount, StartDate, EndDate, IsActive, CreatedBy, CreatedAt "
                   + "FROM Coupon WHERE CouponCode = ? AND IsActive = 1 AND CAST(GETDATE() AS DATE) BETWEEN StartDate AND EndDate";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, couponCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Coupon coupon = new Coupon(
                        rs.getInt("CouponID"),
                        rs.getString("CouponCode"),
                        rs.getString("DiscountType"),
                        rs.getDouble("DiscountValue"),
                        rs.getDouble("MinOrderAmount"),
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
}
