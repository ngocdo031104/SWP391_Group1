import java.sql.*;

public class CheckSchedules {
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://localhost:1433;databaseName=TourBuddyDB;encrypt=true;trustServerCertificate=true;";
        String user = "sa";
        String pass = "123";

        try (Connection conn = DriverManager.getConnection(url, user, pass)) {
            try (Statement st = conn.createStatement()) {
                ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM TourSchedule");
                if (rs.next()) {
                    System.out.println("Total Schedules: " + rs.getInt(1));
                }
                
                rs = st.executeQuery("SELECT TOP 5 ScheduleID, TourID, DepartureDate, Status FROM TourSchedule");
                while (rs.next()) {
                    System.out.println("Schedule: " + rs.getInt("ScheduleID") + ", Tour: " + rs.getInt("TourID") + 
                                       ", Date: " + rs.getDate("DepartureDate") + ", Status: " + rs.getString("Status"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
