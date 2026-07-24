/*
 * Màn hình 23: View Analytics Dashboard - Dashboard thống kê & phân tích
 * Tác giả: Dương Quang Sơn
 * MSSV: HE186525
 * Ngày tạo: 2026-07-21
 */
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

    /**
     * Kiểm tra quyền truy cập vào màn hình thống kê & báo cáo (Analytics).
     * Cho phép truy cập nếu:
     * - Người dùng là Super Admin (RoleId = 1)
     * - Người dùng là Kế toán / Accountant (RoleId = 5 hoặc tên vai trò là "Accountant")
     * - Người dùng có quyền "Read" hoặc "Export" trong module "System Settings"
     * 
     * @param user Đối tượng người dùng cần kiểm tra
     * @return true nếu có quyền, ngược lại false
     */
    private boolean hasAnalyticsPermission(User user) {
        if (user == null) return false;
        if (user.getRoleId() == 1) return true; // Cho phép Super Admin truy cập trực tiếp
        if (user.getRoleId() == 5 || (user.getRole() != null && "Accountant".equalsIgnoreCase(user.getRole().getRoleName()))) return true; // Cho phép Kế toán truy cập trực tiếp
        
        // Kiểm tra quyền cụ thể theo phân quyền chi tiết của vai trò (Role)
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

    /**
     * Xử lý yêu cầu HTTP GET.
     * Phương thức này thực hiện hai nhiệm vụ chính:
     * 1. Phản hồi các yêu cầu lấy dữ liệu thống kê bằng AJAX (trả về định dạng JSON).
     * 2. Điều hướng người dùng đến giao diện trang Dashboard phân tích (JSP) nếu là yêu cầu tải trang thông thường.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // 1. Kiểm tra quyền truy cập của tài khoản hiện tại từ Session
        User sessionUser = (User) request.getSession().getAttribute("sessionUser");
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!hasAnalyticsPermission(sessionUser)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Xử lý yêu cầu AJAX lấy dữ liệu phân tích dạng JSON
        String ajax = request.getParameter("ajax");
        if ("true".equalsIgnoreCase(ajax)) {
            response.setContentType("application/json;charset=UTF-8");
            String type = request.getParameter("type");
            AnalyticsDAO dao = new AnalyticsDAO();
            Gson gson = new Gson();
            PrintWriter out = response.getWriter();

            try {
                if ("revenue".equalsIgnoreCase(type)) {
                    // Lấy dữ liệu doanh thu theo tháng, theo danh mục và theo tour
                    int limit = parseInt(request.getParameter("limit"), 6);
                    Map<String, Object> data = new HashMap<>();
                    data.put("monthly", dao.getRevenueByMonth(limit));
                    data.put("category", dao.getRevenueByCategory());
                    data.put("tours", dao.getRevenueByTour());
                    out.print(gson.toJson(data));
                } else if ("bookings".equalsIgnoreCase(type)) {
                    // Lấy dữ liệu tỷ lệ trạng thái đặt tour và xu hướng đặt tour theo thời gian
                    int limit = parseInt(request.getParameter("limit"), 30);
                    Map<String, Object> data = new HashMap<>();
                    data.put("distribution", dao.getBookingStatusDistribution());
                    data.put("trends", dao.getBookingTrends(limit));
                    out.print(gson.toJson(data));
                } else if ("performance".equalsIgnoreCase(type)) {
                    // Lấy dữ liệu hiệu suất của các tour (số khách, đánh giá, doanh thu...)
                    out.print(gson.toJson(dao.getTourPerformanceList()));
                } else if ("guides".equalsIgnoreCase(type)) {
                    // Lấy tóm tắt hoạt động của các hướng dẫn viên (số tour đã dẫn, trạng thái...)
                    out.print(gson.toJson(dao.getGuideActivitySummary()));
                } else if ("reports".equalsIgnoreCase(type)) {
                    // Lấy danh sách toàn bộ các báo cáo đã lưu (Snapshot Reports)
                    out.print(gson.toJson(dao.getAllSavedReports()));
                } else if ("reportDetail".equalsIgnoreCase(type)) {
                    // Xem chi tiết một báo cáo đã lưu cụ thể theo mã reportId
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

        // 3. Xử lý yêu cầu GET thông thường: Hiển thị giao diện Dashboard
        // Nếu là Kế toán (RoleId = 5), lấy thêm số lượng yêu cầu hoàn tiền đang chờ để hiển thị thông báo
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
        
        // Chuyển hướng yêu cầu tới trang JSP hiển thị Dashboard
        request.getRequestDispatcher("/admin/analytics.jsp").forward(request, response);
    }

    /**
     * Xử lý yêu cầu HTTP POST.
     * Hiện tại chức năng chính là thực hiện việc lưu một bản chụp báo cáo thống kê (Save Snapshot Report)
     * giúp lưu giữ lại dữ liệu tại một thời điểm nhất định vào cơ sở dữ liệu để xem lại sau này.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Kiểm tra quyền truy cập của người dùng
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
            // Xử lý hành động lưu Snapshot (bản chụp dữ liệu báo cáo)
            if ("saveSnapshot".equalsIgnoreCase(action)) {
                String reportType = request.getParameter("reportType"); // Các loại: Revenue, Booking, TourPerformance, GuideActivity
                if (reportType == null || reportType.trim().isEmpty()) {
                    reportType = "Revenue";
                }

                // Xác định khoảng thời gian của báo cáo snapshot
                String startStr = request.getParameter("periodStart");
                String endStr = request.getParameter("periodEnd");
                Date periodStart;
                Date periodEnd;

                if (startStr != null && !startStr.isEmpty()) {
                    periodStart = Date.valueOf(startStr);
                } else {
                    Calendar cal = Calendar.getInstance();
                    if ("Booking".equalsIgnoreCase(reportType)) {
                        cal.add(Calendar.DAY_OF_YEAR, -30); // Mặc định 30 ngày trước đối với Booking
                    } else {
                        cal.add(Calendar.MONTH, -6); // Mặc định 6 tháng trước đối với Revenue và các mục khác
                    }
                    periodStart = new Date(cal.getTimeInMillis());
                }

                if (endStr != null && !endStr.isEmpty()) {
                    periodEnd = Date.valueOf(endStr);
                } else {
                    periodEnd = new java.sql.Date(System.currentTimeMillis()); // Mặc định đến ngày hiện tại
                }

                // Lấy dữ liệu thống kê hiện tại tương ứng với loại báo cáo để chuẩn bị lưu trữ dưới dạng JSON
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

                // Chuyển đổi dữ liệu sang định dạng JSON để lưu vào cột Text/LongText trong cơ sở dữ liệu
                String jsonData = gson.toJson(dataToSave);

                // Tạo đối tượng báo cáo AnalyticsReport và gán các thông tin cần thiết
                AnalyticsReport report = new AnalyticsReport();
                report.setReportType(reportType);
                report.setPeriodStart(periodStart);
                report.setPeriodEnd(periodEnd);
                report.setData(jsonData);
                report.setGeneratedBy(sessionUser.getUserId()); // Lưu ID của người thực hiện xuất/lưu báo cáo

                // Thực hiện chèn bản ghi báo cáo vào database thông qua DAO
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

    /**
     * Phương thức bổ trợ (Helper method) giúp chuyển đổi chuỗi String sang số nguyên Integer an toàn.
     * Tránh lỗi NumberFormatException bằng cách trả về giá trị mặc định nếu xảy ra lỗi chuyển đổi hoặc chuỗi null/rỗng.
     * 
     * @param val Giá trị chuỗi đầu vào cần phân tích
     * @param defaultVal Giá trị trả về mặc định nếu chuỗi không hợp lệ
     * @return Số nguyên sau khi chuyển đổi hoặc giá trị mặc định
     */
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
