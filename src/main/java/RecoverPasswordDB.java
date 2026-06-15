import Utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;

public class RecoverPasswordDB extends DBContext {

    public static void main(String[] args) {
        RecoverPasswordDB db = new RecoverPasswordDB();
        db.addResetTokenColumns();
    }

    public void addResetTokenColumns() {
        String sql = "ALTER TABLE [User] " +
                     "ADD ResetToken VARCHAR(100) NULL, " +
                     "ResetTokenExpiry DATETIME NULL";
        
        try (Connection conn = getConnection(); 
             Statement stmt = conn.createStatement()) {
            
            stmt.executeUpdate(sql);
            System.out.println("ResetToken columns added to User table successfully.");
            
        } catch (SQLException e) {
            System.err.println("Error adding columns: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
