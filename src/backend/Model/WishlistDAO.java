package Model;

import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class WishlistDAO extends DBContext {

    public boolean toggleWishlist(int userId, int tourId) {
        // Kiểm tra xem đã yêu thích chưa
        String checkSql = "SELECT 1 FROM Wishlist WHERE UserID = ? AND TourID = ?";
        try (PreparedStatement psCheck = connection.prepareStatement(checkSql)) {
            psCheck.setInt(1, userId);
            psCheck.setInt(2, tourId);
            
            try (ResultSet rs = psCheck.executeQuery()) {
                if (rs.next()) {
                    // Nếu đã yêu thích -> Xóa đi
                    String deleteSql = "DELETE FROM Wishlist WHERE UserID = ? AND TourID = ?";
                    try (PreparedStatement psDel = connection.prepareStatement(deleteSql)) {
                        psDel.setInt(1, userId);
                        psDel.setInt(2, tourId);
                        psDel.executeUpdate();
                        return false; // Trả về false báo đã hủy lưu
                    }
                } else {
                    // Nếu chưa -> Thêm vào
                    String insertSql = "INSERT INTO Wishlist (UserID, TourID) VALUES (?, ?)";
                    try (PreparedStatement psIns = connection.prepareStatement(insertSql)) {
                        psIns.setInt(1, userId);
                        psIns.setInt(2, tourId);
                        psIns.executeUpdate();
                        return true; // Trả về true báo đã lưu
                    }
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(WishlistDAO.class.getName()).log(Level.SEVERE, "Error toggling wishlist", ex);
        }
        return false;
    }
}
