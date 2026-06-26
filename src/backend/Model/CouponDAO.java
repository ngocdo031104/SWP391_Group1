package Model;

import Entities.Coupon;
import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
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

    /**
     * Gets all coupons for admin panel.
     * @return List of Coupon objects
     */
    public List<Coupon> getAllCouponsAdmin() {
        List<Coupon> list = new ArrayList<>();
        String sql = "SELECT CouponID, CouponCode, DiscountType, DiscountValue, MinOrderAmount, MaxUses, UsedCount, StartDate, EndDate, IsActive, CreatedBy, CreatedAt "
                   + "FROM Coupon ORDER BY CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
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
                list.add(coupon);
            }
        } catch (SQLException ex) {
            Logger.getLogger(CouponDAO.class.getName()).log(Level.SEVERE, "getAllCouponsAdmin failed", ex);
        }
        return list;
    }

    /**
     * Retrieves coupon details by ID.
     */
    public Coupon getCouponById(int couponId) {
        String sql = "SELECT CouponID, CouponCode, DiscountType, DiscountValue, MinOrderAmount, MaxUses, UsedCount, StartDate, EndDate, IsActive, CreatedBy, CreatedAt "
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
            Logger.getLogger(CouponDAO.class.getName()).log(Level.SEVERE, "getCouponById failed", ex);
        }
        return null;
    }

    /**
     * Inserts a new coupon code.
     */
    public boolean insertCoupon(Coupon coupon) {
        String sql = "INSERT INTO Coupon (CouponCode, DiscountType, DiscountValue, MinOrderAmount, MaxUses, UsedCount, StartDate, EndDate, IsActive, CreatedBy, CreatedAt) "
                   + "VALUES (?, ?, ?, ?, ?, 0, ?, ?, ?, ?, SYSDATETIME())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, coupon.getCouponCode().trim().toUpperCase());
            ps.setString(2, coupon.getDiscountType());
            ps.setDouble(3, coupon.getDiscountValue());
            ps.setDouble(4, coupon.getMinOrderAmount());
            if (coupon.getMaxUses() != null) {
                ps.setInt(5, coupon.getMaxUses());
            } else {
                ps.setNull(5, java.sql.Types.INTEGER);
            }
            ps.setDate(6, coupon.getStartDate());
            ps.setDate(7, coupon.getEndDate());
            ps.setBoolean(8, coupon.isIsActive());
            if (coupon.getCreatedBy() != null && coupon.getCreatedBy() > 0) {
                ps.setInt(9, coupon.getCreatedBy());
            } else {
                ps.setNull(9, java.sql.Types.INTEGER);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(CouponDAO.class.getName()).log(Level.SEVERE, "insertCoupon failed", ex);
        }
        return false;
    }

    /**
     * Updates an existing coupon.
     */
    public boolean updateCoupon(Coupon coupon) {
        String sql = "UPDATE Coupon SET CouponCode = ?, DiscountType = ?, DiscountValue = ?, MinOrderAmount = ?, MaxUses = ?, StartDate = ?, EndDate = ?, IsActive = ? "
                   + "WHERE CouponID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, coupon.getCouponCode().trim().toUpperCase());
            ps.setString(2, coupon.getDiscountType());
            ps.setDouble(3, coupon.getDiscountValue());
            ps.setDouble(4, coupon.getMinOrderAmount());
            if (coupon.getMaxUses() != null) {
                ps.setInt(5, coupon.getMaxUses());
            } else {
                ps.setNull(5, java.sql.Types.INTEGER);
            }
            ps.setDate(6, coupon.getStartDate());
            ps.setDate(7, coupon.getEndDate());
            ps.setBoolean(8, coupon.isIsActive());
            ps.setInt(9, coupon.getCouponId());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(CouponDAO.class.getName()).log(Level.SEVERE, "updateCoupon failed", ex);
        }
        return false;
    }

    /**
     * Toggles the active status of a coupon.
     */
    public boolean toggleCouponStatus(int couponId, boolean isActive) {
        String sql = "UPDATE Coupon SET IsActive = ? WHERE CouponID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setBoolean(1, isActive);
            ps.setInt(2, couponId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(CouponDAO.class.getName()).log(Level.SEVERE, "toggleCouponStatus failed", ex);
        }
        return false;
    }

    /**
     * Deletes a coupon code.
     */
    public boolean deleteCoupon(int couponId) {
        String sql = "DELETE FROM Coupon WHERE CouponID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, couponId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(CouponDAO.class.getName()).log(Level.SEVERE, "deleteCoupon failed", ex);
        }
        return false;
    }
}
