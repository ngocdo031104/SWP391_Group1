package Model;

import Entities.AnalyticsReport;
import Utils.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class AnalyticsDAO extends DBContext {
    private static final Logger LOGGER = Logger.getLogger(AnalyticsDAO.class.getName());

    public AnalyticsDAO() {
        super();
    }

    /**
     * getRevenueByMonth(int limitMonths)
     */
    public List<Map<String, Object>> getRevenueByMonth(int limitMonths) {
        List<Map<String, Object>> list = new ArrayList<>();
        // Query to aggregate monthly revenue, starting from N months ago
        String sql = "SELECT YEAR(CreatedAt) as YearVal, MONTH(CreatedAt) as MonthVal, SUM(TotalAmount) as Total "
                   + "FROM Booking "
                   + "WHERE Status = 'Success' AND CreatedAt >= DATEADD(month, -?, GETDATE()) "
                   + "GROUP BY YEAR(CreatedAt), MONTH(CreatedAt) "
                   + "ORDER BY YearVal ASC, MonthVal ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, limitMonths - 1);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    String monthStr = String.format("%04d-%02d", rs.getInt("YearVal"), rs.getInt("MonthVal"));
                    map.put("month", monthStr);
                    map.put("revenue", rs.getDouble("Total"));
                    list.add(map);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "getRevenueByMonth failed", ex);
        }
        return list;
    }

    /**
     * getRevenueByCategory()
     */
    public List<Map<String, Object>> getRevenueByCategory() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT tc.CategoryName, SUM(b.TotalAmount) as Total "
                   + "FROM Booking b "
                   + "JOIN TourSchedule ts ON b.ScheduleID = ts.ScheduleID "
                   + "JOIN Tour t ON ts.TourID = t.TourID "
                   + "JOIN TourCategory tc ON t.CategoryID = tc.CategoryID "
                   + "WHERE b.Status = 'Success' "
                   + "GROUP BY tc.CategoryName "
                   + "ORDER BY Total DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("category", rs.getString("CategoryName"));
                map.put("revenue", rs.getDouble("Total"));
                list.add(map);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "getRevenueByCategory failed", ex);
        }
        return list;
    }

    /**
     * getRevenueByTour()
     */
    public List<Map<String, Object>> getRevenueByTour() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT TOP 10 t.TourName, SUM(b.TotalAmount) as Total "
                   + "FROM Booking b "
                   + "JOIN TourSchedule ts ON b.ScheduleID = ts.ScheduleID "
                   + "JOIN Tour t ON ts.TourID = t.TourID "
                   + "WHERE b.Status = 'Success' "
                   + "GROUP BY t.TourID, t.TourName "
                   + "ORDER BY Total DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("tourName", rs.getString("TourName"));
                map.put("revenue", rs.getDouble("Total"));
                list.add(map);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "getRevenueByTour failed", ex);
        }
        return list;
    }

    /**
     * getBookingStatusDistribution()
     */
    public List<Map<String, Object>> getBookingStatusDistribution() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT Status, COUNT(BookingID) as CountVal "
                   + "FROM Booking "
                   + "GROUP BY Status";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("status", rs.getString("Status"));
                map.put("count", rs.getInt("CountVal"));
                list.add(map);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "getBookingStatusDistribution failed", ex);
        }
        return list;
    }

    /**
     * getBookingTrends(int daysLimit)
     */
    public List<Map<String, Object>> getBookingTrends(int daysLimit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT CAST(CreatedAt AS DATE) as DateVal, COUNT(BookingID) as CountVal "
                   + "FROM Booking "
                   + "WHERE CreatedAt >= DATEADD(day, -?, GETDATE()) "
                   + "GROUP BY CAST(CreatedAt AS DATE) "
                   + "ORDER BY DateVal ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, daysLimit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("date", rs.getDate("DateVal").toString());
                    map.put("count", rs.getInt("CountVal"));
                    list.add(map);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "getBookingTrends failed", ex);
        }
        return list;
    }

    /**
     * getTourPerformanceList()
     */
    public List<Map<String, Object>> getTourPerformanceList() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT t.TourID, t.TourName, "
                   + "(SELECT COUNT(b.BookingID) FROM Booking b JOIN TourSchedule ts ON b.ScheduleID = ts.ScheduleID WHERE ts.TourID = t.TourID) as TotalBookings, "
                   + "(SELECT COALESCE(SUM(b.TotalAmount), 0) FROM Booking b JOIN TourSchedule ts ON b.ScheduleID = ts.ScheduleID WHERE ts.TourID = t.TourID AND b.Status IN ('Confirmed', 'Completed')) as TotalRevenue, "
                   + "(SELECT COALESCE(AVG(CAST(r.Rating AS DECIMAL(3,2))), 0.0) FROM Review r WHERE r.TourID = t.TourID AND r.IsVisible = 1) as AvgRating, "
                   + "(SELECT COALESCE(SUM(ts.TotalSeats - ts.AvailableSeats) * 100.0 / NULLIF(SUM(ts.TotalSeats), 0), 0.0) FROM TourSchedule ts WHERE ts.TourID = t.TourID) as AvgOccupancyRate "
                   + "FROM Tour t "
                   + "ORDER BY TotalRevenue DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("tourId", rs.getInt("TourID"));
                map.put("tourName", rs.getString("TourName"));
                map.put("totalBookings", rs.getInt("TotalBookings"));
                map.put("totalRevenue", rs.getDouble("TotalRevenue"));
                map.put("avgRating", rs.getDouble("AvgRating"));
                map.put("avgOccupancyRate", rs.getDouble("AvgOccupancyRate"));
                list.add(map);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "getTourPerformanceList failed", ex);
        }
        return list;
    }

    /**
     * getGuideActivitySummary()
     */
    public List<Map<String, Object>> getGuideActivitySummary() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT u.UserID, u.FullName, gp.YearsOfExperience, gp.Rating, gp.TotalToursLed, gp.Specialization, gp.EmergencyPhone, gp.Languages, "
                   + "(SELECT COUNT(AssignmentID) FROM TourAssignment WHERE GuideID = u.UserID) as AssignedToursCount, "
                   + "gp.IsActive "
                   + "FROM GuideProfile gp "
                   + "JOIN [User] u ON gp.UserID = u.UserID "
                   + "ORDER BY gp.Rating DESC, gp.YearsOfExperience DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("userId", rs.getInt("UserID"));
                map.put("fullName", rs.getString("FullName"));
                map.put("yearsOfExperience", rs.getInt("YearsOfExperience"));
                map.put("rating", rs.getDouble("Rating"));
                map.put("totalToursLed", rs.getInt("TotalToursLed"));
                map.put("specialization", rs.getString("Specialization"));
                map.put("emergencyPhone", rs.getString("EmergencyPhone"));
                map.put("languages", rs.getString("Languages"));
                map.put("assignedToursCount", rs.getInt("AssignedToursCount"));
                map.put("isActive", rs.getBoolean("IsActive"));
                list.add(map);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "getGuideActivitySummary failed", ex);
        }
        return list;
    }

    /**
     * insertReport(AnalyticsReport report)
     */
    public int insertReport(AnalyticsReport report) {
        String sql = "INSERT INTO AnalyticsReport (ReportType, PeriodStart, PeriodEnd, Data, GeneratedBy, GeneratedAt) "
                   + "VALUES (?, ?, ?, ?, ?, SYSDATETIME())";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, report.getReportType());
            ps.setDate(2, report.getPeriodStart());
            ps.setDate(3, report.getPeriodEnd());
            ps.setString(4, report.getData());
            if (report.getGeneratedBy() != null) {
                ps.setInt(5, report.getGeneratedBy());
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "insertReport failed", ex);
        }
        return -1;
    }

    /**
     * getAllSavedReports()
     */
    public List<AnalyticsReport> getAllSavedReports() {
        List<AnalyticsReport> list = new ArrayList<>();
        String sql = "SELECT ar.ReportID, ar.ReportType, ar.PeriodStart, ar.PeriodEnd, ar.Data, ar.GeneratedBy, ar.GeneratedAt, u.FullName as GeneratedByName "
                   + "FROM AnalyticsReport ar "
                   + "LEFT JOIN [User] u ON ar.GeneratedBy = u.UserID "
                   + "ORDER BY ar.GeneratedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                AnalyticsReport ar = new AnalyticsReport(
                    rs.getInt("ReportID"),
                    rs.getString("ReportType"),
                    rs.getDate("PeriodStart"),
                    rs.getDate("PeriodEnd"),
                    rs.getString("Data"),
                    rs.getObject("GeneratedBy") != null ? rs.getInt("GeneratedBy") : null,
                    rs.getTimestamp("GeneratedAt"),
                    rs.getString("GeneratedByName")
                );
                list.add(ar);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "getAllSavedReports failed", ex);
        }
        return list;
    }

    /**
     * getSavedReportById(int reportId)
     */
    public AnalyticsReport getSavedReportById(int reportId) {
        String sql = "SELECT ar.ReportID, ar.ReportType, ar.PeriodStart, ar.PeriodEnd, ar.Data, ar.GeneratedBy, ar.GeneratedAt, u.FullName as GeneratedByName "
                   + "FROM AnalyticsReport ar "
                   + "LEFT JOIN [User] u ON ar.GeneratedBy = u.UserID "
                   + "WHERE ar.ReportID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, reportId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new AnalyticsReport(
                        rs.getInt("ReportID"),
                        rs.getString("ReportType"),
                        rs.getDate("PeriodStart"),
                        rs.getDate("PeriodEnd"),
                        rs.getString("Data"),
                        rs.getObject("GeneratedBy") != null ? rs.getInt("GeneratedBy") : null,
                        rs.getTimestamp("GeneratedAt"),
                        rs.getString("GeneratedByName")
                    );
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "getSavedReportById failed", ex);
        }
        return null;
    }
}
