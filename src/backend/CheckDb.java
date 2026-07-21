import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;

public class CheckDb {
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://localhost:1433;databaseName=TourBuddyDB;encrypt=true;trustServerCertificate=true;characterEncoding=UTF-8;";
        String user = "sa";
        String pass = "123";
        
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            try (Connection conn = DriverManager.getConnection(url, user, pass);
                 Statement stmt = conn.createStatement()) {
                System.out.println("Connection successful!");
                
                System.out.println("--- TourInclusion Table Contents ---");
                try (ResultSet rs = stmt.executeQuery("SELECT * FROM TourInclusion")) {
                    ResultSetMetaData meta = rs.getMetaData();
                    int cols = meta.getColumnCount();
                    for (int i = 1; i <= cols; i++) {
                        System.out.print(meta.getColumnName(i) + "\t");
                    }
                    System.out.println();
                    while (rs.next()) {
                        for (int i = 1; i <= cols; i++) {
                            System.out.print(rs.getObject(i) + "\t");
                        }
                        System.out.println();
                    }
                }
                
                System.out.println("--- Tour Table Contents (Recent 5) ---");
                try (ResultSet rs = stmt.executeQuery("SELECT TOP 5 TourID, TourName, Status FROM Tour ORDER BY TourID DESC")) {
                    while (rs.next()) {
                        System.out.println("ID: " + rs.getInt("TourID") + " | Name: " + rs.getString("TourName") + " | Status: " + rs.getString("Status"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
