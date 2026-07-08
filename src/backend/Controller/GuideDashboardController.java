package Controller;

import Entities.TourAssignment;
import Entities.User;
import Model.AttendanceDAO;
import Model.GuideDAO;
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

        try {
            int guideId = user.getUserId();

            if ("list".equals(action)) {
                // Hiển thị lịch phân công dẫn đoàn
                List<TourAssignment> assignments = guideDAO.getAssignmentsByGuideId(guideId);
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
                    List<TourAssignment> assignments = guideDAO.getAssignmentsByGuideId(guideId);
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
            }
        } finally {
            guideDAO.close();
            attendanceDAO.close();
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
        if (!"checkin".equalsIgnoreCase(action)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.addProperty("status", "error");
            result.addProperty("message", "Hành động yêu cầu không hợp lệ!");
            out.print(result.toString());
            return;
        }

        String scheduleIdStr = request.getParameter("scheduleId");
        String participantIdStr = request.getParameter("participantId");
        String checkedInStr = request.getParameter("checkedIn");
        String notes = request.getParameter("notes");

        if (scheduleIdStr == null || participantIdStr == null || checkedInStr == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.addProperty("status", "error");
            result.addProperty("message", "Thiếu các tham số bắt buộc!");
            out.print(result.toString());
            return;
        }

        int scheduleId;
        int participantId;
        boolean checkedIn;
        try {
            scheduleId = Integer.parseInt(scheduleIdStr);
            participantId = Integer.parseInt(participantIdStr);
            checkedIn = Boolean.parseBoolean(checkedInStr);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.addProperty("status", "error");
            result.addProperty("message", "Định dạng tham số ID không hợp lệ!");
            out.print(result.toString());
            return;
        }

        AttendanceDAO attendanceDAO = new AttendanceDAO();
        try {
            boolean success = attendanceDAO.saveAttendance(scheduleId, participantId, checkedIn, user.getUserId(), notes);
            if (success) {
                result.addProperty("status", "success");
                
                String timeStr = "";
                if (checkedIn) {
                    SimpleDateFormat sdf = new SimpleDateFormat("HH:mm dd/MM/yyyy");
                    timeStr = sdf.format(new Timestamp(System.currentTimeMillis()));
                }
                result.addProperty("checkInTime", timeStr);
                result.addProperty("message", checkedIn ? "Đã điểm danh thành công!" : "Đã hủy điểm danh thành công!");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                result.addProperty("status", "error");
                result.addProperty("message", "Lưu trạng thái điểm danh vào cơ sở dữ liệu thất bại.");
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
}
