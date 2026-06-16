import java.sql.*;

public class FixDB {
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://localhost:1433;databaseName=TourBuddyDB;encrypt=true;trustServerCertificate=true;";
        String user = "sa";
        String pass = "123";

        try (Connection conn = DriverManager.getConnection(url, user, pass)) {
            System.out.println("Connected to DB!");
            try (Statement st = conn.createStatement()) {
                String createTable = 
                    "CREATE TABLE [dbo].[GuideProfile](" +
                    "  [GuideProfileID] [int] IDENTITY(1,1) NOT NULL," +
                    "  [UserID] [int] NOT NULL," +
                    "  [YearsOfExperience] [int] NULL DEFAULT ((0))," +
                    "  [TotalToursLed] [int] NULL DEFAULT ((0))," +
                    "  [Rating] [decimal](3, 2) NULL DEFAULT ((5.0))," +
                    "  [Bio] [nvarchar](1000) NULL," +
                    "  [Specialization] [nvarchar](255) NULL," +
                    "  [Languages] [nvarchar](255) NULL," +
                    "  [Certifications] [nvarchar](500) NULL," +
                    "  [EmergencyPhone] [nvarchar](20) NULL," +
                    "  [IsActive] [bit] NOT NULL DEFAULT ((1))," +
                    "  [CreatedAt] [datetime2](7) NOT NULL DEFAULT (sysdatetime())," +
                    "  [UpdatedAt] [datetime2](7) NOT NULL DEFAULT (sysdatetime())," +
                    "  PRIMARY KEY CLUSTERED ([GuideProfileID] ASC)" +
                    ")";
                st.execute(createTable);
                System.out.println("Table GuideProfile created successfully!");
                
                String alterTable = 
                    "ALTER TABLE [dbo].[GuideProfile] WITH CHECK ADD FOREIGN KEY([UserID]) REFERENCES [dbo].[User] ([UserID])";
                st.execute(alterTable);
                System.out.println("Foreign key added successfully!");
            } catch (SQLException e) {
                System.out.println("SQL ERROR: " + e.getMessage());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
