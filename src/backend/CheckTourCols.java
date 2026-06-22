import java.sql.*;

public class CheckTourCols {
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://localhost:1433;databaseName=TourBuddyDB;encrypt=true;trustServerCertificate=true;";
        String user = "sa";
        String pass = "123";

        try (Connection conn = DriverManager.getConnection(url, user, pass)) {
            try (Statement st = conn.createStatement()) {
                ResultSet rs = st.executeQuery("SELECT TOP 1 Languages, GroupSizeMin, DepartureCity FROM Tour");
                if (rs.next()) {
                    System.out.println("Columns exist! " + rs.getString("DepartureCity"));
                }
            } catch (SQLException e) {
                System.out.println("SQL Error: " + e.getMessage());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
