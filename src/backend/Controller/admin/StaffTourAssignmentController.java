/*
 * Màn hình 28: Assign Tour Guide - Phân công hướng dẫn viên (Staff)
 * Tác giả: Dương Quang Sơn
 * MSSV: HE186525
 * Ngày tạo: 2026-07-21
 */
package Controller.admin;

import Entities.User;
import Entities.TourAssignment;
import Entities.TourSchedule;
import Entities.Tour;
import Entities.GuideProfile;
import Model.GuideDAO;
import Model.TourScheduleDAO;
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

@WebServlet(name = "StaffTourAssignmentController", urlPatterns = {"/staff/tour-assignments"})
public class StaffTourAssignmentController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(StaffTourAssignmentController.class.getName());

    /**
     * Xử lý yêu cầu HTTP GET.
     * 1. Xác thực thông tin người dùng từ session (chỉ Staff/Admin được phép).
     * 2. Nếu action = "list" (mặc định):
     *    - Lấy danh sách TourSchedule chưa có Hướng dẫn viên (Guide).
     *    - Lấy danh sách tất cả Hướng dẫn viên (GuideProfile) đang hoạt động.
     *    - Lấy danh sách lịch sử phân công (TourAssignment).
     *    - Lưu vào request attributes và chuyển hướng sang trang tour-assignments.jsp.
     * 3. Nếu action = "details":
     *    - Lấy thông tin chi tiết về lịch trình khởi hành cụ thể, danh sách HDV, các phân công liên quan.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (!isAuthorized(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "list";

        GuideDAO guideDAO = new GuideDAO();
        TourScheduleDAO scheduleDAO = new TourScheduleDAO();

        try {
            // Hiển thị danh sách chính
            if ("list".equals(action)) {
                List<TourSchedule> unassignedSchedules = scheduleDAO.getUnassignedSchedules();
                List<GuideProfile> guides = guideDAO.getAllGuides();
                List<TourAssignment> assignments = guideDAO.getAllAssignments();

                request.setAttribute("unassignedSchedules", unassignedSchedules);
                request.setAttribute("guides", guides);
                request.setAttribute("assignments", assignments);
                request.getRequestDispatcher("/views/staff/tour-assignments.jsp").forward(request, response);

            // Hiển thị chi tiết phân công cho một scheduleId cụ thể
            } else if ("details".equals(action)) {
                String scheduleIdStr = request.getParameter("scheduleId");
                if (scheduleIdStr != null && !scheduleIdStr.isEmpty()) {
                    try {
                        int scheduleId = Integer.parseInt(scheduleIdStr);
                        TourSchedule schedule = scheduleDAO.getScheduleById(scheduleId);
                        List<GuideProfile> guides = guideDAO.getAllGuides();
                        List<TourAssignment> assignments = guideDAO.getAssignmentsByScheduleId(scheduleId);

                        request.setAttribute("schedule", schedule);
                        request.setAttribute("guides", guides);
                        request.setAttribute("assignments", assignments);
                        request.getRequestDispatcher("/views/staff/tour-assignments.jsp").forward(request, response);
                        return;
                    } catch (NumberFormatException e) {
                        // Bỏ qua lỗi định dạng và quay về trang danh sách chính
                    }
                }
                response.sendRedirect(request.getContextPath() + "/staff/tour-assignments");
            } else {
                response.sendRedirect(request.getContextPath() + "/staff/tour-assignments");
            }
        } finally {
            guideDAO.close();
            scheduleDAO.close();
        }
    }

    /**
     * Xử lý các yêu cầu HTTP POST để cập nhật phân công (phản hồi định dạng JSON).
     * Hỗ trợ các hành động:
     * - "assign": Phân công một Hướng dẫn viên vào Lịch khởi hành cụ thể (bao gồm kiểm tra bận trùng lịch, gửi thông báo hệ thống notification).
     * - "unassign": Hủy phân công hướng dẫn viên khỏi Lịch khởi hành.
     */
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
            result.addProperty("message", "Vui lòng đăng nhập để thực hiện hành động này!");
            out.print(result.toString());
            return;
        }

        User currentUser = (User) session.getAttribute("sessionUser");
        String action = request.getParameter("action");

        if ("assign".equals(action)) {
            String scheduleIdStr = request.getParameter("scheduleId");
            String guideIdStr = request.getParameter("guideId");
            String notes = request.getParameter("notes");

            if (scheduleIdStr == null || guideIdStr == null || scheduleIdStr.isEmpty() || guideIdStr.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result.addProperty("status", "error");
                result.addProperty("message", "Thiếu thông tin bắt buộc!");
                out.print(result.toString());
                return;
            }

            try {
                int scheduleId = Integer.parseInt(scheduleIdStr);
                int guideId = Integer.parseInt(guideIdStr);

                GuideDAO guideDAO = new GuideDAO();
                TourScheduleDAO scheduleDAO = new TourScheduleDAO();

                try {
                    // Lấy thông tin schedule và guide để gửi notification
                    TourSchedule schedule = scheduleDAO.getScheduleById(scheduleId);
                    GuideProfile guide = guideDAO.getGuideProfileByUserId(guideId);

                    if (schedule == null || guide == null) {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        result.addProperty("status", "error");
                        result.addProperty("message", "Không tìm thấy thông tin tour hoặc hướng dẫn viên!");
                        out.print(result.toString());
                        return;
                    }

                    // Kiểm tra trùng lịch dẫn đoàn của HDV
                    if (guideDAO.isGuideBusy(guideId, scheduleId)) {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        result.addProperty("status", "error");
                        result.addProperty("message", "Hướng dẫn viên này đã có lịch dẫn đoàn trùng với thời gian chuyến đi này!");
                        out.print(result.toString());
                        return;
                    }

                    // Phân công guide
                    boolean success = guideDAO.assignGuideToSchedule(scheduleId, guideId, currentUser.getUserId(), notes);

                    if (success) {
                        // Gửi notification cho guide
                        sendAssignmentNotification(guideId, schedule, currentUser);

                        result.addProperty("status", "success");
                        result.addProperty("message", "Phân công hướng dẫn viên thành công!");
                    } else {
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        result.addProperty("status", "error");
                        result.addProperty("message", "Phân công thất bại. Vui lòng thử lại!");
                    }
                } finally {
                    guideDAO.close();
                    scheduleDAO.close();
                }
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result.addProperty("status", "error");
                result.addProperty("message", "ID không hợp lệ!");
            }
            out.print(result.toString());

        } else if ("unassign".equals(action)) {
            String scheduleIdStr = request.getParameter("scheduleId");
            String guideIdStr = request.getParameter("guideId");

            if (scheduleIdStr == null || guideIdStr == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result.addProperty("status", "error");
                result.addProperty("message", "Thiếu thông tin bắt buộc!");
                out.print(result.toString());
                return;
            }

            try {
                int scheduleId = Integer.parseInt(scheduleIdStr);
                int guideId = Integer.parseInt(guideIdStr);

                GuideDAO guideDAO = new GuideDAO();
                try {
                    boolean success = guideDAO.unassignGuide(scheduleId, guideId, currentUser.getUserId());
                    if (success) {
                        result.addProperty("status", "success");
                        result.addProperty("message", "Hủy phân công thành công!");
                    } else {
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        result.addProperty("status", "error");
                        result.addProperty("message", "Hủy phân công thất bại!");
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

    private void sendAssignmentNotification(int guideId, TourSchedule schedule, User assignedBy) {
        try {
            NotificationDAO notifDAO = new NotificationDAO();
            try {
                Notification notif = new Notification();
                notif.setUserId(guideId);
                notif.setSenderId(assignedBy.getUserId());
                notif.setTitle("Bạn được phân công dẫn tour mới!");
                notif.setContent("Bạn đã được phân công dẫn tour: " + schedule.getTour().getTourName() +
                        ". Ngày khởi hành: " + schedule.getDepartureDate() +
                        ". Vui lòng kiểm tra lịch dẫn đoàn để biết thêm chi tiết.");
                notif.setChannel("SYSTEM");
                notif.setCategory("Tour Assignment");
                notif.setStatus("SENT");
                notifDAO.insertNotification(notif);
            } finally {
                notifDAO.close();
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Không thể gửi notification phân công guide", e);
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
