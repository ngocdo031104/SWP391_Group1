package Utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class AddIsDeletedColumn {
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://localhost:1433;databaseName=TourBuddyDB;encrypt=true;trustServerCertificate=true;characterEncoding=UTF-8";
        String user = "sa";
        String pass = "123";
        
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            try (Connection conn = DriverManager.getConnection(url, user, pass);
                 Statement stmt = conn.createStatement()) {
                
                System.out.println("Connected to TourBuddyDB successfully!");
                try {
                    stmt.execute("ALTER TABLE Tour ADD IsDeleted BIT NOT NULL DEFAULT 0");
                    System.out.println("Successfully added column IsDeleted to Tour table.");
                } catch (Exception e) {
                    if (e.getMessage().contains("already") || e.getMessage().contains("Duplicate")) {
                        System.out.println("Column IsDeleted already exists in Tour table.");
                    } else {
                        throw e;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
