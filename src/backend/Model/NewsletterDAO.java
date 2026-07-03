package Model;

import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class NewsletterDAO extends DBContext {

    public boolean subscribe(String email) {
        // Sử dụng MERGE hoặc chèn bỏ qua để tránh trùng lặp email
        String sql = "IF NOT EXISTS (SELECT 1 FROM NewsletterSubscription WHERE Email = ?) " +
                     "INSERT INTO NewsletterSubscription (Email) VALUES (?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, email);
            
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException ex) {
            Logger.getLogger(NewsletterDAO.class.getName()).log(Level.SEVERE, "Error saving newsletter email", ex);
        }
        return false;
    }
}
