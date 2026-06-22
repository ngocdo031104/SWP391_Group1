import Utils.DBContext;
import java.sql.Connection;
import java.sql.Statement;

public class CreateNotificationsDB {
    public static void main(String[] args) {
        try {
            DBContext db = new DBContext();
            Connection conn = db.getConnection();
            Statement stmt = conn.createStatement();
            
            String sql = "IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Notifications' and xtype='U') " +
                         "CREATE TABLE Notifications (" +
                         "notificationId INT IDENTITY(1,1) PRIMARY KEY, " +
                         "userId INT FOREIGN KEY REFERENCES Users(userId), " +
                         "senderId INT FOREIGN KEY REFERENCES Users(userId), " +
                         "title NVARCHAR(255) NOT NULL, " +
                         "content NVARCHAR(MAX) NOT NULL, " +
                         "channel VARCHAR(50) NOT NULL, " +
                         "category VARCHAR(50) DEFAULT 'System Announcement', " +
                         "isRead BIT DEFAULT 0, " +
                         "createdAt DATETIME DEFAULT GETDATE(), " +
                         "scheduledAt DATETIME NULL, " +
                         "status VARCHAR(50) DEFAULT 'SENT'" +
                         ")";
            stmt.executeUpdate(sql);
            System.out.println("Notifications table created successfully.");
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
