package Utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DBContext manages the database connection to Microsoft SQL Server for the TourBuddy application.
 */
public class DBContext {
    protected Connection connection;

    public DBContext() {
        try {
            // Change security settings or credentials as per your local SQL Server instance setup
            String user = "sa";
            String pass = "123"; 
            String url = "jdbc:sqlserver://localhost:1433;databaseName=TourBuddyDB;encrypt=true;trustServerCertificate=true;characterEncoding=UTF-8;MultipleActiveResultSets=true;";
            
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            connection = DriverManager.getConnection(url, user, pass);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "SQL Server Driver not found!", ex);
            throw new RuntimeException("SQL Server Driver not found! Make sure the JDBC driver jar is in the classpath.", ex);
        } catch (SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "Database connection failed!", ex);
            throw new RuntimeException("Database connection failed! Check your connection URL, username, and password.", ex);
        }
    }

    /**
     * Gets the database connection.
     * @return the connection object or null if failed
     */
    public Connection getConnection() {
        return connection;
    }

    /**
     * Closes the connection safely.
     */
    public void close() {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException ex) {
                Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }
}
