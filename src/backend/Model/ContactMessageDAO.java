package Model;

import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ContactMessageDAO extends DBContext {

    public boolean insertMessage(String fullName, String email, String subject, String messageText) {
        String sql = "INSERT INTO ContactMessage (FullName, Email, Subject, MessageText) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, subject);
            ps.setString(4, messageText);
            
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException ex) {
            Logger.getLogger(ContactMessageDAO.class.getName()).log(Level.SEVERE, "Error inserting contact message", ex);
        }
        return false;
    }
}
