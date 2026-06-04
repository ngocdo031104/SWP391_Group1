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
            String url = "jdbc:sqlserver://localhost:1433;databaseName=TourBuddyDB;encrypt=true;trustServerCertificate=true;characterEncoding=UTF-8";
            
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            connection = DriverManager.getConnection(url, user, pass);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "SQL Server Driver not found!", ex);
        } catch (SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "Database connection failed!", ex);
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
