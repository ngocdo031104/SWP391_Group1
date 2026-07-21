/*
 * Màn hình 42: Update Tour Status - Cập nhật trạng thái vận hành tour
 * Tác giả: Dương Quang Sơn
 * MSSV: HE186525
 * Ngày tạo: 2026-07-21
 */
package Controller.admin;

import Entities.User;
import Entities.TourSchedule;
import Entities.TourAssignment;
import Model.TourScheduleDAO;
import Model.GuideDAO;
import Model.TourOperationLogDAO;
import Model.NotificationDAO;
import Entities.Notification;
import com.google.gson.JsonObject;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "StaffTourStatusController", urlPatterns = {"/staff/tour-status"})
public class StaffTourStatusController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(StaffTourStatusController.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (!isAuthorized(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "list";

        TourScheduleDAO scheduleDAO = new TourScheduleDAO();
        GuideDAO guideDAO = new GuideDAO();

        try {
            if ("list".equals(action)) {
                // Lấy danh sách tour có guide đang hoạt động
                List<TourSchedule> schedules = scheduleDAO.getAssignedSchedules();
                request.setAttribute("schedules", schedules);
                request.getRequestDispatcher("/views/staff/tour-status.jsp").forward(request, response);

            } else if ("logs".equals(action)) {
                String scheduleIdStr = request.getParameter("scheduleId");
                if (scheduleIdStr != null && !scheduleIdStr.isEmpty()) {
                    try {
                        int scheduleId = Integer.parseInt(scheduleIdStr);
                        TourSchedule schedule = scheduleDAO.getScheduleById(scheduleId);

                        TourOperationLogDAO logDAO = new TourOperationLogDAO();
                        List<Entities.TourOperationLog> logs = logDAO.getLogsByScheduleId(scheduleId);

                        request.setAttribute("schedule", schedule);
                        request.setAttribute("logs", logs);
                        logDAO.close();
                        request.getRequestDispatcher("/views/staff/tour-status.jsp").forward(request, response);
                        return;
                    } catch (NumberFormatException e) {
                        // Fall through
                    }
                }
                response.sendRedirect(request.getContextPath() + "/staff/tour-status");
            } else {
                response.sendRedirect(request.getContextPath() + "/staff/tour-status");
            }
        } finally {
            scheduleDAO.close();
            guideDAO.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        JsonObject result = new JsonObject();
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (!isAuthorized(session)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            result.addProperty("status", "error");
            result.addProperty("message", "Vui lòng đăng nhập!");
            out.print(result.toString());
            return;
        }

        User currentUser = (User) session.getAttribute("sessionUser");
        String action = request.getParameter("action");

        if ("updateStatus".equals(action)) {
            String scheduleIdStr = request.getParameter("scheduleId");
            String newStatus = request.getParameter("newStatus");
            String notes = request.getParameter("notes");

            if (scheduleIdStr == null || newStatus == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result.addProperty("status", "error");
                result.addProperty("message", "Thiếu thông tin bắt buộc!");
                out.print(result.toString());
                return;
            }

            // Validate status
            if (!"Preparing".equals(newStatus) && !"Scheduled".equals(newStatus) &&
                !"InProgress".equals(newStatus) && !"Completed".equals(newStatus) &&
                !"Cancelled".equals(newStatus)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result.addProperty("status", "error");
                result.addProperty("message", "Trạng thái không hợp lệ!");
                out.print(result.toString());
                return;
            }

            try {
                int scheduleId = Integer.parseInt(scheduleIdStr);

                GuideDAO guideDAO = new GuideDAO();
                try {
                    boolean success = guideDAO.updateTourStatus(scheduleId, newStatus, notes, currentUser.getUserId());

                    if (success) {
                        // Gửi notification cho guide nếu tour được cập nhật
                        sendStatusNotification(scheduleId, newStatus, currentUser);

                        result.addProperty("status", "success");
                        result.addProperty("message", "Cập nhật trạng thái thành công!");
                    } else {
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        result.addProperty("status", "error");
                        result.addProperty("message", "Cập nhật thất bại!");
                    }
                } finally {
                    guideDAO.close();
                }
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result.addProperty("status", "error");
                result.addProperty("message", "ID không hợp lệ!");
            }
            out.print(result.toString());

        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.addProperty("status", "error");
            result.addProperty("message", "Hành động không hợp lệ!");
            out.print(result.toString());
        }
    }

    private void sendStatusNotification(int scheduleId, String newStatus, User updatedBy) {
        try {
            TourScheduleDAO scheduleDAO = new TourScheduleDAO();
            GuideDAO guideDAO = new GuideDAO();
            NotificationDAO notifDAO = new NotificationDAO();

            try {
                TourSchedule schedule = scheduleDAO.getScheduleById(scheduleId);
                if (schedule != null && schedule.getGuideId() != null) {
                    String statusText = getStatusText(newStatus);
                    String title = "Tour được cập nhật trạng thái";
                    String content = "Tour \"" + schedule.getTour().getTourName() +
                            "\" đã được cập nhật trạng thái thành: " + statusText +
                            " bởi " + updatedBy.getFullName() + ".";

                    Notification notif = new Notification();
                    notif.setUserId(schedule.getGuideId());
                    notif.setSenderId(updatedBy.getUserId());
                    notif.setTitle(title);
                    notif.setContent(content);
                    notif.setChannel("SYSTEM");
                    notif.setCategory("Tour Update");
                    notif.setStatus("SENT");
                    notifDAO.insertNotification(notif);
                }
            } finally {
                scheduleDAO.close();
                guideDAO.close();
                notifDAO.close();
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Không thể gửi notification cập nhật tour", e);
        }
    }

    private String getStatusText(String status) {
        switch (status) {
            case "Preparing": return "Chuẩn bị";
            case "Scheduled": return "Đã lên lịch";
            case "InProgress": return "Đang diễn ra";
            case "Completed": return "Hoàn thành";
            case "Cancelled": return "Đã hủy";
            default: return status;
        }
    }

    private boolean isAuthorized(HttpSession session) {
        if (session == null) return false;
        User user = (User) session.getAttribute("sessionUser");
        if (user == null || user.getRole() == null) return false;
        String role = user.getRole().getRoleName();
        return "Staff".equals(role) || "Admin".equals(role);
    }
}
