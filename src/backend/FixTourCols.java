import java.sql.*;

public class FixTourCols {
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://localhost:1433;databaseName=TourBuddyDB;encrypt=true;trustServerCertificate=true;";
        String user = "sa";
        String pass = "123";

        try (Connection conn = DriverManager.getConnection(url, user, pass)) {
            System.out.println("Connected to DB!");
            try (Statement st = conn.createStatement()) {
                String alterTable = 
                    "ALTER TABLE [dbo].[Tour] ADD " +
                    "[Languages] [nvarchar](255) NULL, " +
                    "[GroupSizeMin] [int] NULL DEFAULT ((1)), " +
                    "[GroupSizeMax] [int] NULL DEFAULT ((20)), " +
                    "[DepartureCity] [nvarchar](100) NULL, " +
                    "[Latitude] [float] NULL, " +
                    "[Longitude] [float] NULL, " +
                    "[VideoURL] [nvarchar](500) NULL";
                st.execute(alterTable);
                System.out.println("Tour table updated successfully with missing columns!");
            } catch (SQLException e) {
                System.out.println("SQL ERROR: " + e.getMessage());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
