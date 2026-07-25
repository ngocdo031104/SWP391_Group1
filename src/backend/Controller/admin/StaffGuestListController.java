/*
 * Màn hình 36: View Guest List and Check-in - Quản lý danh sách hành khách và Check-in (Staff)
 * Tác giả: Dương Quang Sơn
 * MSSV: HE186525
 * Ngày tạo: 2026-07-21
 */
package Controller.admin;

import Entities.User;
import Entities.Booking;
import Entities.BookingParticipant;
import Model.BookingDAO;
import Model.AttendanceDAO;
import Model.TourScheduleDAO;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "StaffGuestListController", urlPatterns = {"/staff/guests"})
public class StaffGuestListController extends HttpServlet {

    /**
     * Xử lý yêu cầu HTTP GET.
     * 1. Xác thực quyền nhân viên (Staff/Admin).
     * 2. Nếu có tham số action = "details" và scheduleId, lấy danh sách hành khách và thông tin điểm danh (check-in) cho chuyến đi cụ thể.
     * 3. Mặc định (action không truyền hoặc rỗng): lấy danh sách tất cả các Booking có lịch khởi hành để hiển thị.
     * 4. Điều hướng tới JSP hiển thị tương ứng.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (!isAuthorized(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String scheduleIdStr = request.getParameter("scheduleId");
        String action = request.getParameter("action");

        BookingDAO bookingDAO = new BookingDAO();
        AttendanceDAO attendanceDAO = new AttendanceDAO();
        TourScheduleDAO scheduleDAO = new TourScheduleDAO();

        try {
            // Xem chi tiết danh sách hành khách của 1 lịch khởi hành
            if (action != null && "details".equals(action) && scheduleIdStr != null && !scheduleIdStr.isEmpty()) {
                try {
                    int scheduleId = Integer.parseInt(scheduleIdStr);
                    List<Map<String, Object>> participants = attendanceDAO.getAttendanceByScheduleId(scheduleId);
                    var schedule = scheduleDAO.getScheduleById(scheduleId);

                    String bookingIdStr = request.getParameter("bookingId");
                    if (bookingIdStr != null && !bookingIdStr.isEmpty()) {
                        int bookingId = Integer.parseInt(bookingIdStr);
                        participants.removeIf(p -> {
                            Object bIdObj = p.get("bookingId");
                            if (bIdObj instanceof Integer) {
                                return (Integer) bIdObj != bookingId;
                            }
                            return false;
                        });
                    }

                    // Tính toán số lượng hành khách đã điểm danh check-in
                    int totalCount = participants.size();
                    int checkedInCount = 0;
                    for (Map<String, Object> p : participants) {
                        if (Boolean.TRUE.equals(p.get("checkedIn"))) {
                            checkedInCount++;
                        }
                    }

                    request.setAttribute("schedule", schedule);
                    request.setAttribute("participants", participants);
                    request.setAttribute("totalCount", totalCount);
                    request.setAttribute("checkedInCount", checkedInCount);
                    request.getRequestDispatcher("/views/staff/guest-list.jsp").forward(request, response);
                    return;
                } catch (NumberFormatException e) {
                    // Xử lý khi ID sai định dạng
                }
            }

            // Mặc định: hiển thị danh sách bookings có schedule
            List<Booking> bookings = bookingDAO.getAllBookingsWithSchedules();
            request.setAttribute("bookings", bookings);
            request.getRequestDispatcher("/views/staff/guest-list.jsp").forward(request, response);

        } finally {
            bookingDAO.close();
            attendanceDAO.close();
            scheduleDAO.close();
        }
    }

    /**
     * Helper kiểm tra quyền của Staff hoặc Admin.
     */
    private boolean isAuthorized(HttpSession session) {
        if (session == null) return false;
        User user = (User) session.getAttribute("sessionUser");
        if (user == null || user.getRole() == null) return false;
        String role = user.getRole().getRoleName();
        return "Staff".equals(role) || "Admin".equals(role);
    }
}
