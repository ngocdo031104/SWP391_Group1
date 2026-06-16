import java.sql.*;

public class CheckTours {
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://localhost:1433;databaseName=TourBuddyDB;encrypt=true;trustServerCertificate=true;";
        String user = "sa";
        String pass = "123";

        try (Connection conn = DriverManager.getConnection(url, user, pass)) {
            try (Statement st = conn.createStatement()) {
                ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM Tour WHERE Status = 'Active'");
                if (rs.next()) {
                    System.out.println("Active Tours: " + rs.getInt(1));
                }
                
                rs = st.executeQuery("SELECT Status, COUNT(*) FROM Tour GROUP BY Status");
                while (rs.next()) {
                    System.out.println("Status: " + rs.getString(1) + ", Count: " + rs.getInt(2));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
