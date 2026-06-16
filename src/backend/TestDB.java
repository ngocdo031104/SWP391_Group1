import java.sql.*;

public class TestDB {
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://localhost:1433;databaseName=TourBuddyDB;encrypt=true;trustServerCertificate=true;";
        String user = "sa";
        String pass = "123";

        try (Connection conn = DriverManager.getConnection(url, user, pass)) {
            System.out.println("Connected!");
            
            int userId = 0;
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT TOP 1 UserID FROM [User] WHERE RoleID = 3")) {
                if (rs.next()) {
                    userId = rs.getInt(1);
                    System.out.println("Found guide UserID: " + userId);
                }
            }

            if (userId == 0) return;

            String sql = "INSERT INTO GuideProfile (UserID, YearsOfExperience, TotalToursLed, Rating, Bio, Specialization, Languages, Certifications, EmergencyPhone, IsActive, CreatedAt, UpdatedAt) "
                       + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATETIME(), SYSDATETIME())";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setInt(2, 0);
                ps.setInt(3, 0);
                ps.setDouble(4, 5.0);
                ps.setString(5, "");
                ps.setString(6, "");
                ps.setString(7, "");
                ps.setString(8, "");
                ps.setString(9, "");
                ps.setBoolean(10, true);
                
                int rows = ps.executeUpdate();
                System.out.println("Insert successful! Rows: " + rows);
            } catch (SQLException e) {
                System.out.println("INSERT FAILED: " + e.getMessage());
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
