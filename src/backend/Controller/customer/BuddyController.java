package Controller.customer;

import Entities.BuddyRequest;
import Entities.User;
import Entities.TravelPreference;
import Entities.MatchedUser;
import Model.BuddyRequestDAO;
import Model.MatchingDAO;
import Model.TourDAO;
import Entities.DestinationInfo;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "BuddyController", urlPatterns = {"/customer/buddies"})
public class BuddyController extends HttpServlet {

    private BuddyRequestDAO buddyRequestDAO;
    private MatchingDAO matchingDAO;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        buddyRequestDAO = new BuddyRequestDAO();
        matchingDAO = new MatchingDAO();
        HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("sessionUser") : null;

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int currentUserId = sessionUser.getUserId();

        try {
            TravelPreference myPref = matchingDAO.getPreference(currentUserId);
            // Default preference if null
            if (myPref == null) {
                myPref = new TravelPreference();
                myPref.setDestination("Any Destination");
                myPref.setTravelStyle("Explorer");
                myPref.setLanguages("Tiếng Việt");
            }
            
            List<MatchedUser> topMatches = matchingDAO.getTopMatches(currentUserId);
            
            // Calculate completeness
            int completeness = 40;
            if (myPref.getDestination() != null && !myPref.getDestination().isEmpty()) completeness += 15;
            if (myPref.getTravelStyle() != null && !myPref.getTravelStyle().isEmpty()) completeness += 15;
            if (myPref.getMinBudget() > 0) completeness += 15;
            if (myPref.getTags() != null && !myPref.getTags().isEmpty()) completeness += 15;
            
            request.setAttribute("myPref", myPref);
            request.setAttribute("topMatches", topMatches);
            request.setAttribute("completeness", completeness);
            
            // Fetch request lists for the tabs
            List<BuddyRequest> receivedRequests = buddyRequestDAO.getReceivedRequests(currentUserId);
            request.setAttribute("receivedRequests", receivedRequests);
            List<BuddyRequest> sentRequests = buddyRequestDAO.getSentRequests(currentUserId);
            request.setAttribute("sentRequests", sentRequests);
            List<User> acceptedBuddies = buddyRequestDAO.getAcceptedBuddies(currentUserId);
            request.setAttribute("acceptedBuddies", acceptedBuddies);
            
            // Fetch preferences for accepted buddies
            java.util.Map<Integer, TravelPreference> friendPrefs = new java.util.HashMap<>();
            for (User u : acceptedBuddies) {
                TravelPreference p = matchingDAO.getPreference(u.getUserId());
                if (p != null) friendPrefs.put(u.getUserId(), p);
            }
            request.setAttribute("friendPrefs", friendPrefs);
            List<User> suggestedBuddies = buddyRequestDAO.getSuggestedBuddies(currentUserId);
            request.setAttribute("suggestedBuddies", suggestedBuddies);
            
            TourDAO tourDAO = new TourDAO();
            try {
                List<DestinationInfo> destinations = tourDAO.getTopDestinations();
                request.setAttribute("destinations", destinations);
            } finally {
                tourDAO.close();
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }

        RequestDispatcher dispatcher = request.getRequestDispatcher("/customer/buddies.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        buddyRequestDAO = new BuddyRequestDAO();
        matchingDAO = new MatchingDAO();
        HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("sessionUser") : null;

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int currentUserId = sessionUser.getUserId();
        String action = request.getParameter("action");
        try {
            switch (action) {
                case "send":
                    int receiverId = Integer.parseInt(request.getParameter("receiverId"));
                    try {
                        boolean sent = buddyRequestDAO.sendRequest(currentUserId, receiverId);
                        if (sent) {
                            session.setAttribute("successMsg", "Đã gửi lời mời kết nối thành công!");
                        } else {
                            session.setAttribute("errorMsg", "Không thể gửi lời mời. Vui lòng thử lại.");
                        }
                    } catch (Exception ex) {
                        session.setAttribute("errorMsg", "DB Error: " + ex.getMessage());
                    }
                    break;

                case "accept":
                    int reqIdAccept = Integer.parseInt(request.getParameter("requestId"));
                    boolean accepted = buddyRequestDAO.updateRequestStatus(reqIdAccept, "Accepted");
                    if (accepted) {
                        session.setAttribute("successMsg", "Đã chấp nhận lời mời kết nối!");
                    } else {
                        session.setAttribute("errorMsg", "Lỗi khi chấp nhận lời mời.");
                    }
                    break;

                case "reject":
                    int reqIdReject = Integer.parseInt(request.getParameter("requestId"));
                    boolean rejected = buddyRequestDAO.updateRequestStatus(reqIdReject, "Rejected");
                    if (rejected) {
                        session.setAttribute("successMsg", "Đã từ chối lời mời.");
                    } else {
                        session.setAttribute("errorMsg", "Lỗi khi từ chối lời mời.");
                    }
                    break;

                case "cancel":
                    int reqIdCancel = Integer.parseInt(request.getParameter("requestId"));
                    boolean cancelled = buddyRequestDAO.cancelRequest(reqIdCancel, currentUserId);
                    if (cancelled) {
                        session.setAttribute("successMsg", "Đã hủy lời mời gửi đi.");
                    } else {
                        session.setAttribute("errorMsg", "Không thể hủy lời mời. Lời mời có thể đã được chấp nhận hoặc bị từ chối.");
                    }
                    break;
            }
        } catch (Exception e) {
            session.setAttribute("errorMsg", "Đã có lỗi xảy ra: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/customer/buddies");
    }
}
