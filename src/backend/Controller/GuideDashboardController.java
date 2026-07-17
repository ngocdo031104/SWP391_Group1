package Controller;

import Entities.IncidentReport;
import Entities.Notification;
import Entities.Notification;
import Entities.TourAssignment;
import Entities.TourOperationLog;
import Entities.TourSchedule;
import Entities.User;
import Model.AttendanceDAO;
import Model.GuideDAO;
import Model.IncidentReportDAO;
import Model.NotificationDAO;
import Model.TourOperationLogDAO;
import Model.TourScheduleDAO;
import Model.TourScheduleDAO;
import Model.UserDAO;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(urlPatterns = {"/guide/dashboard"})
public class GuideDashboardController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(GuideDashboardController.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("sessionUser");
        if (!"Guide".equals(user.getRole().getRoleName())) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.isEmpty()) {
            action = "list";
        }

        GuideDAO guideDAO = new GuideDAO();
        AttendanceDAO attendanceDAO = new AttendanceDAO();
        IncidentReportDAO incidentReportDAO = new IncidentReportDAO();
        TourOperationLogDAO logDAO = new TourOperationLogDAO();

        try {
            int guideId = user.getUserId();
            // Nạp danh sách assignments một lần ở đầu khối try
            List<TourAssignment> assignments = guideDAO.getAssignmentsByGuideId(guideId);

            if ("list".equals(action)) {
                // Hiển thị lịch phân công dẫn đoàn
                request.setAttribute("assignments", assignments);
                request.getRequestDispatcher("/views/guide/dashboard.jsp").forward(request, response);
                
            } else if ("participants".equals(action)) {
                // Hiển thị danh sách hành khách và điểm danh
                String scheduleIdStr = request.getParameter("scheduleId");
                if (scheduleIdStr == null || scheduleIdStr.isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/guide/dashboard");
                    return;
                }

                try {
                    int scheduleId = Integer.parseInt(scheduleIdStr);
                    
                    // Ràng buộc bảo mật: Chỉ cho phép Guide xem danh sách hành khách của tour đã được phân công cho họ
                    boolean isAssigned = false;
                    TourAssignment selectedAssignment = null;
                    for (TourAssignment assignment : assignments) {
                        if (assignment.getScheduleId() == scheduleId) {
                            isAssigned = true;
                            selectedAssignment = assignment;
                            break;
                        }
                    }

                    if (!isAssigned) {
                        request.setAttribute("errorMessage", "Bạn không có quyền truy cập danh sách hành khách của lịch khởi hành này.");
                        request.setAttribute("assignments", assignments);
                        request.getRequestDispatcher("/views/guide/dashboard.jsp").forward(request, response);
                        return;
                    }

                    // Lấy danh sách điểm danh
                    List<Map<String, Object>> participants = attendanceDAO.getAttendanceByScheduleId(scheduleId);
                    
                    // Tính toán thống kê điểm danh
                    int totalCount = participants.size();
                    int checkedInCount = 0;
                    for (Map<String, Object> p : participants) {
                        if (Boolean.TRUE.equals(p.get("checkedIn"))) {
                            checkedInCount++;
                        }
                    }

                    request.setAttribute("participants", participants);
                    request.setAttribute("assignment", selectedAssignment);
                    request.setAttribute("totalCount", totalCount);
                    request.setAttribute("checkedInCount", checkedInCount);
                    request.getRequestDispatcher("/views/guide/participants.jsp").forward(request, response);
                    
                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath() + "/guide/dashboard");
                }
            } else if ("incidents".equals(action)) {
                // Hiển thị danh sách báo cáo sự cố của Tour
                String scheduleIdStr = request.getParameter("scheduleId");
                if (scheduleIdStr == null || scheduleIdStr.isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/guide/dashboard");
                    return;
                }

                try {
                    int scheduleId = Integer.parseInt(scheduleIdStr);

                    // Ràng buộc bảo mật: Kiểm tra xem Guide có thực sự được phân công lịch này không
                    boolean isAssigned = false;
                    TourAssignment selectedAssignment = null;
                    for (TourAssignment assignment : assignments) {
                        if (assignment.getScheduleId() == scheduleId) {
                            isAssigned = true;
                            selectedAssignment = assignment;
                            break;
                        }
                    }

                    if (!isAssigned) {
                        request.setAttribute("errorMessage", "Bạn không có quyền truy cập nhật ký sự cố của lịch trình này.");
                        request.setAttribute("assignments", assignments);
                        request.getRequestDispatcher("/views/guide/dashboard.jsp").forward(request, response);
                        return;
                    }

                    List<IncidentReport> incidents = incidentReportDAO.getIncidentsByScheduleId(scheduleId);
                    request.setAttribute("incidents", incidents);
                    request.setAttribute("assignment", selectedAssignment);
                    request.getRequestDispatcher("/views/guide/incidents.jsp").forward(request, response);

                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath() + "/guide/dashboard");
                }
            } else if ("operationLogs".equals(action)) {
                // Hiển thị dòng thời gian timeline nhật ký vận hành
                String scheduleIdStr = request.getParameter("scheduleId");
                if (scheduleIdStr == null || scheduleIdStr.isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/guide/dashboard");
                    return;
                }

                try {
                    int scheduleId = Integer.parseInt(scheduleIdStr);

                    // Ràng buộc bảo mật: Kiểm tra quyền phân công gán tour
                    boolean isAssigned = false;
                    TourAssignment selectedAssignment = null;
                    for (TourAssignment assignment : assignments) {
                        if (assignment.getScheduleId() == scheduleId) {
                            isAssigned = true;
                            selectedAssignment = assignment;
                            break;
                        }
                    }

                    if (!isAssigned) {
                        request.setAttribute("errorMessage", "Bạn không có quyền truy cập nhật ký vận hành của lịch trình này.");
                        request.setAttribute("assignments", assignments);
                        request.getRequestDispatcher("/views/guide/dashboard.jsp").forward(request, response);
                        return;
                    }

                    String pageStr = request.getParameter("page");
                    int page = 1;
                    int size = 10;
                    if (pageStr != null && !pageStr.isEmpty()) {
                        try {
                            page = Integer.parseInt(pageStr);
                            if (page < 1) page = 1;
                        } catch (NumberFormatException e) {
                            page = 1;
                        }
                    }

                    List<TourOperationLog> logs = logDAO.getLogsByScheduleIdPaged(scheduleId, page, size);
                    int totalLogs = logDAO.getLogsCountByScheduleId(scheduleId);
                    int totalPages = (int) Math.ceil((double) totalLogs / size);

                    request.setAttribute("logs", logs);
                    request.setAttribute("currentPage", page);
                    request.setAttribute("totalPages", totalPages);
                    request.setAttribute("assignment", selectedAssignment);
                    request.getRequestDispatcher("/views/guide/operation-logs.jsp").forward(request, response);

                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath() + "/guide/dashboard");
                }
            } else {
                // Fallback nếu action không xác định, chuyển hướng tránh màn hình trắng (Lỗi 3)
                response.sendRedirect(request.getContextPath() + "/guide/dashboard");
                return;
            }
        } finally {
            guideDAO.close();
            attendanceDAO.close();
            incidentReportDAO.close();
            logDAO.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        JsonObject result = new JsonObject();
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            result.addProperty("status", "error");
            result.addProperty("message", "Vui lòng đăng nhập để tiếp tục!");
            out.print(result.toString());
            return;
        }

        User user = (User) session.getAttribute("sessionUser");
        if (!"Guide".equals(user.getRole().getRoleName())) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            result.addProperty("status", "error");
            result.addProperty("message", "Bạn không có quyền thực hiện hành động này!");
            out.print(result.toString());
            return;
        }

        String action = request.getParameter("action");
        if (!"checkin".equalsIgnoreCase(action) && !"updateNotes".equalsIgnoreCase(action) && 
            ! "updateStatus".equalsIgnoreCase(action) && !"reportIncident".equalsIgnoreCase(action) &&
            !"updateIncidentStatus".equalsIgnoreCase(action)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.addProperty("status", "error");
            result.addProperty("message", "Hành động yêu cầu không hợp lệ!");
            out.print(result.toString());
            return;
        }

        int scheduleId = 0;
        int incidentId = 0;
        String statusParam = null;

        if ("updateIncidentStatus".equalsIgnoreCase(action)) {
            String incidentIdStr = request.getParameter("incidentId");
            statusParam = request.getParameter("status");
            if (incidentIdStr == null || incidentIdStr.isEmpty() || statusParam == null || statusParam.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result.addProperty("status", "error");
                result.addProperty("message", "Thiếu các tham số bắt buộc của sự cố!");
                out.print(result.toString());
                return;
            }
            try {
                incidentId = Integer.parseInt(incidentIdStr);
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result.addProperty("status", "error");
                result.addProperty("message", "Mã sự cố không hợp lệ!");
                out.print(result.toString());
                return;
            }

            IncidentReportDAO incidentDAO = new IncidentReportDAO();
            try {
                IncidentReport ir = incidentDAO.getIncidentById(incidentId);
                if (ir == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    result.addProperty("status", "error");
                    result.addProperty("message", "Không tìm thấy sự cố này!");
                    out.print(result.toString());
                    return;
                }
                scheduleId = ir.getScheduleId();
            } finally {
                incidentDAO.close();
            }
        } else {
            String scheduleIdStr = request.getParameter("scheduleId");
            if (scheduleIdStr == null || scheduleIdStr.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result.addProperty("status", "error");
                result.addProperty("message", "Thiếu tham số mã lịch khởi hành!");
                out.print(result.toString());
                return;
            }
            try {
                scheduleId = Integer.parseInt(scheduleIdStr);
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result.addProperty("status", "error");
                result.addProperty("message", "Mã lịch khởi hành không đúng định dạng!");
                out.print(result.toString());
                return;
            }
        }

        // Kiểm tra bảo mật: Hướng dẫn viên chỉ có quyền thao tác trên lịch khởi hành của chính họ
        GuideDAO guideDAO = new GuideDAO();
        try {
            List<TourAssignment> assignments = guideDAO.getAssignmentsByGuideId(user.getUserId());
            boolean isAssigned = false;
            for (TourAssignment assignment : assignments) {
                if (assignment.getScheduleId() == scheduleId) {
                    isAssigned = true;
                    break;
                }
            }
            if (!isAssigned) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                result.addProperty("status", "error");
                result.addProperty("message", "Bạn không có quyền thao tác trên lịch khởi hành này!");
                out.print(result.toString());
                return;
            }

            // Xử lý action updateIncidentStatus ngay tại đây
            if ("updateIncidentStatus".equalsIgnoreCase(action)) {
                if (!"Open".equals(statusParam) && !"InProgress".equals(statusParam) && 
                    !"Resolved".equals(statusParam) && !"Closed".equals(statusParam)) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    result.addProperty("status", "error");
                    result.addProperty("message", "Trạng thái mới không hợp lệ!");
                    out.print(result.toString());
                    return;
                }

                IncidentReportDAO incidentDAO = new IncidentReportDAO();
                try {
                    boolean success = incidentDAO.updateIncidentStatus(incidentId, statusParam, user.getUserId());
                    if (success) {
                        result.addProperty("status", "success");
                        result.addProperty("message", "Trạng thái sự cố đã được cập nhật thành công!");
                    } else {
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        result.addProperty("status", "error");
                        result.addProperty("message", "Cập nhật trạng thái sự cố thất bại.");
                    }
                } finally {
                    incidentDAO.close();
                }
                out.print(result.toString());
                return;
            }

            if ("updateStatus".equalsIgnoreCase(action)) {
                String newStatus = request.getParameter("newStatus");
                String notes = request.getParameter("notes");

                if (newStatus == null || newStatus.trim().isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    result.addProperty("status", "error");
                    result.addProperty("message", "Trạng thái mới không được để trống!");
                    out.print(result.toString());
                    return;
                }

                // Kiểm tra các trạng thái hợp lệ
                if (!"Preparing".equals(newStatus) && !"Scheduled".equals(newStatus) && 
                    !"InProgress".equals(newStatus) && !"Completed".equals(newStatus) && 
                    !"Cancelled".equals(newStatus)) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    result.addProperty("status", "error");
                    result.addProperty("message", "Trạng thái mới gửi lên không hợp lệ!");
                    out.print(result.toString());
                    return;
                }

                boolean success = guideDAO.updateTourStatus(scheduleId, newStatus, notes, user.getUserId());
                if (success) {
                    result.addProperty("status", "success");
                    result.addProperty("message", "Trạng thái đoàn đã được cập nhật thành công!");
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    result.addProperty("status", "error");
                    result.addProperty("message", "Cập nhật trạng thái trong cơ sở dữ liệu thất bại.");
                }
                out.print(result.toString());
                return;
            }

            // 2. Nhánh Xử lý báo cáo sự cố (reportIncident)
            if ("reportIncident".equalsIgnoreCase(action)) {
                String title = request.getParameter("title");
                String severity = request.getParameter("severity");
                String description = request.getParameter("description");

                if (title == null || title.trim().isEmpty() || severity == null || severity.trim().isEmpty() || description == null || description.trim().isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    result.addProperty("status", "error");
                    result.addProperty("message", "Vui lòng nhập đầy đủ các trường thông tin sự cố!");
                    out.print(result.toString());
                    return;
                }

                // Validate severity
                if (!"Low".equals(severity) && !"Medium".equals(severity) && !"High".equals(severity) && !"Critical".equals(severity)) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    result.addProperty("status", "error");
                    result.addProperty("message", "Mức độ nghiêm trọng không hợp lệ!");
                    out.print(result.toString());
                    return;
                }

                IncidentReport report = new IncidentReport();
                report.setScheduleId(scheduleId);
                report.setReportedBy(user.getUserId());
                report.setTitle(title);
                report.setSeverity(severity);
                report.setDescription(description);

                IncidentReportDAO incidentDAO = new IncidentReportDAO();
                try {
                    boolean success = incidentDAO.insertIncidentReport(report);
                    if (success) {
                        result.addProperty("status", "success");
                        result.addProperty("message", "Báo cáo sự cố đã được ghi nhận thành công!");

                        // Tự động gửi thông báo cho Staff/Admin về sự cố mới
                        sendIncidentNotificationToStaff(scheduleId, title, severity, description, user);
                    } else {
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        result.addProperty("status", "error");
                        result.addProperty("message", "Báo cáo sự cố vào cơ sở dữ liệu thất bại.");
                    }
                } finally {
                    incidentDAO.close();
                }
                out.print(result.toString());
                return;
            }

        } finally {
            guideDAO.close();
        }

        // 3. Nhánh Xử lý điểm danh hành khách (checkin / updateNotes)
        String participantIdStr = request.getParameter("participantId");
        String checkedInStr = request.getParameter("checkedIn");
        String notes = request.getParameter("notes");

        if (participantIdStr == null || ("checkin".equalsIgnoreCase(action) && checkedInStr == null)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.addProperty("status", "error");
            result.addProperty("message", "Thiếu các tham số bắt buộc để thực hiện điểm danh!");
            out.print(result.toString());
            return;
        }

        int participantId;
        boolean checkedIn = false;
        try {
            participantId = Integer.parseInt(participantIdStr);
            if ("checkin".equalsIgnoreCase(action)) {
                checkedIn = Boolean.parseBoolean(checkedInStr);
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.addProperty("status", "error");
            result.addProperty("message", "Mã hành khách không hợp lệ!");
            out.print(result.toString());
            return;
        }

        AttendanceDAO attendanceDAO = new AttendanceDAO();
        try {
            boolean success;
            if ("updateNotes".equalsIgnoreCase(action)) {
                success = attendanceDAO.updateAttendanceNotes(scheduleId, participantId, notes);
                if (success) {
                    result.addProperty("status", "success");
                    result.addProperty("message", "Đã cập nhật ghi chú thành công!");
                }
            } else {
                success = attendanceDAO.saveAttendance(scheduleId, participantId, checkedIn, user.getUserId(), notes);
                if (success) {
                    result.addProperty("status", "success");
                    String timeStr = "";
                    if (checkedIn) {
                        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm dd/MM/yyyy");
                        timeStr = sdf.format(new Timestamp(System.currentTimeMillis()));
                    }
                    result.addProperty("checkInTime", timeStr);
                    result.addProperty("message", checkedIn ? "Đã điểm danh thành công!" : "Đã hủy điểm danh thành công!");
                }
            }
            if (!success) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                result.addProperty("status", "error");
                result.addProperty("message", "Lưu trạng thái điểm danh/ghi chú vào cơ sở dữ liệu thất bại.");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi xảy ra trong AJAX checkin POST", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.addProperty("status", "error");
            result.addProperty("message", "Lỗi máy chủ: " + e.getMessage());
        } finally {
            attendanceDAO.close();
        }

        out.print(result.toString());
    }

    private void sendIncidentNotificationToStaff(int scheduleId, String title, String severity, String description, User reporter) {
        try {
            // Lấy thông tin schedule để biết tour
            TourScheduleDAO scheduleDAO = new TourScheduleDAO();
            TourSchedule schedule = scheduleDAO.getScheduleById(scheduleId);
            scheduleDAO.close();

            if (schedule != null) {
                // Tạo nội dung notification
                String tourName = schedule.getTour() != null ? schedule.getTour().getTourName() : "Tour #" + scheduleId;
                String content = String.format(
                    "Guide %s đã báo cáo sự cố mới:\n" +
                    "Tour: %s\n" +
                    "Tiêu đề: %s\n" +
                    "Mức độ: %s\n" +
                    "Mô tả: %s",
                    reporter.getFullName(), tourName, title, severity, description
                );

                // Gửi notification cho tất cả Staff và Admin
                UserDAO userDAO = new UserDAO();
                List<User> staffAndAdmins = userDAO.getUsersByRoles(new int[]{1, 2}); // Admin=1, Staff=2
                userDAO.close();

                NotificationDAO notifDAO = new NotificationDAO();
                try {
                    for (User recipient : staffAndAdmins) {
                        Notification notif = new Notification();
                        notif.setUserId(recipient.getUserId());
                        notif.setSenderId(reporter.getUserId());
                        notif.setTitle("⚠️ Sự cố mới: " + title);
                        notif.setContent(content);
                        notif.setChannel("SYSTEM");
                        notif.setCategory("Incident Report");
                        notif.setStatus("SENT");
                        notifDAO.insertNotification(notif);
                    }
                } finally {
                    notifDAO.close();
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Không thể gửi notification về sự cố cho Staff", e);
        }
    }
}
