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
            if (action != null && "details".equals(action) && scheduleIdStr != null && !scheduleIdStr.isEmpty()) {
                // Hiển thị danh sách khách của một schedule
                try {
                    int scheduleId = Integer.parseInt(scheduleIdStr);
                    List<Map<String, Object>> participants = attendanceDAO.getAttendanceByScheduleId(scheduleId);
                    var schedule = scheduleDAO.getScheduleById(scheduleId);

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
                    // Fall through to redirect
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

    private boolean isAuthorized(HttpSession session) {
        if (session == null) return false;
        User user = (User) session.getAttribute("sessionUser");
        if (user == null || user.getRole() == null) return false;
        String role = user.getRole().getRoleName();
        return "Staff".equals(role) || "Admin".equals(role);
    }
}
