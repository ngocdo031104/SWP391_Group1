package Controller;

import Entities.AnalyticsReport;
import Entities.User;
import Model.AnalyticsDAO;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminAnalyticsController", urlPatterns = {"/admin/analytics"})
public class AdminAnalyticsController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminAnalyticsController.class.getName());

    private boolean hasAnalyticsPermission(User user) {
        if (user == null) return false;
        if (user.getRoleId() == 1) return true; // Super Admin bypass
        if (user.getRoleId() == 5 || (user.getRole() != null && "Accountant".equalsIgnoreCase(user.getRole().getRoleName()))) return true; // Accountant bypass
        if (user.getRole() != null && user.getRole().getPermissions() != null) {
            for (Entities.Permission p : user.getRole().getPermissions()) {
                if ("System Settings".equalsIgnoreCase(p.getModuleName()) 
                    && ("Read".equalsIgnoreCase(p.getAction()) || "Export".equalsIgnoreCase(p.getAction()))) {
                    return true;
                }
            }
        }
        return false;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // 1. Check permissions
        User sessionUser = (User) request.getSession().getAttribute("sessionUser");
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!hasAnalyticsPermission(sessionUser)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String ajax = request.getParameter("ajax");
        if ("true".equalsIgnoreCase(ajax)) {
            response.setContentType("application/json;charset=UTF-8");
            String type = request.getParameter("type");
            AnalyticsDAO dao = new AnalyticsDAO();
            Gson gson = new Gson();
            PrintWriter out = response.getWriter();

            try {
                if ("revenue".equalsIgnoreCase(type)) {
                    int limit = parseInt(request.getParameter("limit"), 6);
                    Map<String, Object> data = new HashMap<>();
                    data.put("monthly", dao.getRevenueByMonth(limit));
                    data.put("category", dao.getRevenueByCategory());
                    data.put("tours", dao.getRevenueByTour());
                    out.print(gson.toJson(data));
                } else if ("bookings".equalsIgnoreCase(type)) {
                    int limit = parseInt(request.getParameter("limit"), 30);
                    Map<String, Object> data = new HashMap<>();
                    data.put("distribution", dao.getBookingStatusDistribution());
                    data.put("trends", dao.getBookingTrends(limit));
                    out.print(gson.toJson(data));
                } else if ("performance".equalsIgnoreCase(type)) {
                    out.print(gson.toJson(dao.getTourPerformanceList()));
                } else if ("guides".equalsIgnoreCase(type)) {
                    out.print(gson.toJson(dao.getGuideActivitySummary()));
                } else if ("reports".equalsIgnoreCase(type)) {
                    out.print(gson.toJson(dao.getAllSavedReports()));
                } else if ("reportDetail".equalsIgnoreCase(type)) {
                    int reportId = parseInt(request.getParameter("reportId"), 0);
                    out.print(gson.toJson(dao.getSavedReportById(reportId)));
                } else {
                    JsonObject err = new JsonObject();
                    err.addProperty("error", "Invalid type");
                    out.print(gson.toJson(err));
                }
            } catch (Exception ex) {
                LOGGER.log(Level.SEVERE, "AJAX Analytics failure", ex);
                JsonObject err = new JsonObject();
                err.addProperty("error", ex.getMessage());
                out.print(gson.toJson(err));
            } finally {
                dao.close();
            }
            return;
        }

        // Standard GET request, forward to JSP page
        if (sessionUser.getRoleId() == 5) {
            Model.CancellationRequestDAO cancelDAO = null;
            try {
                cancelDAO = new Model.CancellationRequestDAO();
                int pendingRefunds = cancelDAO.getRequestsByStatusForAccountant("Pending").size();
                request.setAttribute("pendingRefunds", pendingRefunds);
            } finally {
                if (cancelDAO != null) cancelDAO.close();
            }
        }
        
        request.getRequestDispatcher("/admin/analytics.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Check permissions
        User sessionUser = (User) request.getSession().getAttribute("sessionUser");
        if (sessionUser == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            return;
        }
        if (!hasAnalyticsPermission(sessionUser)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        String action = request.getParameter("action");
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();
        AnalyticsDAO dao = new AnalyticsDAO();

        try {
            if ("saveSnapshot".equalsIgnoreCase(action)) {
                String reportType = request.getParameter("reportType"); // Revenue, Booking, TourPerformance, GuideActivity
                if (reportType == null || reportType.trim().isEmpty()) {
                    reportType = "Revenue";
                }

                // Determine default periods or parse
                String startStr = request.getParameter("periodStart");
                String endStr = request.getParameter("periodEnd");
                Date periodStart;
                Date periodEnd;

                if (startStr != null && !startStr.isEmpty()) {
                    periodStart = Date.valueOf(startStr);
                } else {
                    Calendar cal = Calendar.getInstance();
                    if ("Booking".equalsIgnoreCase(reportType)) {
                        cal.add(Calendar.DAY_OF_YEAR, -30);
                    } else {
                        cal.add(Calendar.MONTH, -6);
                    }
                    periodStart = new Date(cal.getTimeInMillis());
                }

                if (endStr != null && !endStr.isEmpty()) {
                    periodEnd = Date.valueOf(endStr);
                } else {
                    periodEnd = new java.sql.Date(System.currentTimeMillis());
                }

                // Fetch statistics for snapshot data based on reportType
                Object dataToSave = null;
                if ("Revenue".equalsIgnoreCase(reportType)) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("monthly", dao.getRevenueByMonth(6));
                    data.put("category", dao.getRevenueByCategory());
                    data.put("tours", dao.getRevenueByTour());
                    dataToSave = data;
                } else if ("Booking".equalsIgnoreCase(reportType)) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("distribution", dao.getBookingStatusDistribution());
                    data.put("trends", dao.getBookingTrends(30));
                    dataToSave = data;
                } else if ("TourPerformance".equalsIgnoreCase(reportType)) {
                    dataToSave = dao.getTourPerformanceList();
                } else if ("GuideActivity".equalsIgnoreCase(reportType)) {
                    dataToSave = dao.getGuideActivitySummary();
                }

                String jsonData = gson.toJson(dataToSave);

                AnalyticsReport report = new AnalyticsReport();
                report.setReportType(reportType);
                report.setPeriodStart(periodStart);
                report.setPeriodEnd(periodEnd);
                report.setData(jsonData);
                report.setGeneratedBy(sessionUser.getUserId());

                int resultId = dao.insertReport(report);
                JsonObject res = new JsonObject();
                if (resultId > 0) {
                    res.addProperty("success", true);
                    res.addProperty("reportId", resultId);
                    res.addProperty("message", "Báo cáo snapshot lưu thành công!");
                } else {
                    res.addProperty("success", false);
                    res.addProperty("message", "Không thể lưu báo cáo vào cơ sở dữ liệu.");
                }
                out.print(gson.toJson(res));
            } else {
                JsonObject res = new JsonObject();
                res.addProperty("success", false);
                res.addProperty("message", "Hành động không hợp lệ.");
                out.print(gson.toJson(res));
            }
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Save snapshot failure", ex);
            JsonObject res = new JsonObject();
            res.addProperty("success", false);
            res.addProperty("message", "Lỗi: " + ex.getMessage());
            out.print(gson.toJson(res));
        } finally {
            dao.close();
        }
    }

    private int parseInt(String val, int defaultVal) {
        if (val == null || val.trim().isEmpty()) {
            return defaultVal;
        }
        try {
            return Integer.parseInt(val);
        } catch (NumberFormatException e) {
            return defaultVal;
        }
    }
}
