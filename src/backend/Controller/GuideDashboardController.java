package Controller;

import Entities.BookingParticipant;
import Entities.TourAssignment;
import Entities.User;
import Model.BookingDAO;
import Model.GuideDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/guide/dashboard"})
public class GuideDashboardController extends HttpServlet {

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
        BookingDAO bookingDAO = new BookingDAO();

        int guideId = user.getUserId();

        if ("list".equals(action)) {
            // View assigned departures and tours
            List<TourAssignment> assignments = guideDAO.getAssignmentsByGuideId(guideId);
            request.setAttribute("assignments", assignments);
            request.getRequestDispatcher("/views/guide/dashboard.jsp").forward(request, response);
            
        } else if ("participants".equals(action)) {
            // View participant list for a specific departure
            String scheduleIdStr = request.getParameter("scheduleId");
            if (scheduleIdStr == null || scheduleIdStr.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/guide/dashboard");
                return;
            }

            try {
                int scheduleId = Integer.parseInt(scheduleIdStr);
                
                // Security check: Verify the schedule is assigned to this guide
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
                    // Guide cannot access departures not assigned to them
                    request.setAttribute("errorMessage", "You do not have permission to view participants for this departure.");
                    request.getRequestDispatcher("/views/guide/dashboard.jsp").forward(request, response);
                    return;
                }

                List<BookingParticipant> participants = bookingDAO.getParticipantsByScheduleId(scheduleId);
                request.setAttribute("participants", participants);
                request.setAttribute("assignment", selectedAssignment);
                request.getRequestDispatcher("/views/guide/participants.jsp").forward(request, response);
                
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/guide/dashboard");
            }
        }
    }
}
