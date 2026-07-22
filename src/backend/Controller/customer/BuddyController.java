/*
 * Li\u00ean quan \u0111\u1ebfn UCs: Match Travel Companions, Manage Buddy Requests
 * T\u00e1c gi\u1ea3: \u0110\u1ed7 V\u0169 Minh Ng\u1ecdc
 * MSSV: HE182479
 */
package Controller.customer;

import Entities.BuddyRequest;
import Entities.User;
import Entities.TravelPreference;
import Entities.MatchedUser;
import Model.BuddyRequestDAO;
import Model.MatchingDAO;
import Model.TourDAO;
import Entities.DestinationInfo;
import Entities.Notification;
import Model.NotificationDAO;
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
            // Kh\u1edfi t\u1ea1o s\u1edf th\u00edch m\u1eb7c \u0111\u1ecbnh n\u1ebfu ch\u01b0a c\u00f3
            if (myPref == null) {
                myPref = new TravelPreference();
                myPref.setDestination("Any Destination");
                myPref.setTravelStyle("Explorer");
                myPref.setLanguages("Ti\u1ebfng Vi\u1ec7t");
            }
            
            List<MatchedUser> topMatches = matchingDAO.getTopMatches(currentUserId);
            
            // T\u00ednh to\u00e1n ph\u1ea7n tr\u0103m ho\u00e0n thi\u1ec7n h\u1ed3 s\u01a1
            int completeness = 40;
            if (myPref.getDestination() != null && !myPref.getDestination().isEmpty()) completeness += 15;
            if (myPref.getTravelStyle() != null && !myPref.getTravelStyle().isEmpty()) completeness += 15;
            if (myPref.getMinBudget() > 0) completeness += 15;
            if (myPref.getTags() != null && !myPref.getTags().isEmpty()) completeness += 15;
            
            request.setAttribute("myPref", myPref);
            request.setAttribute("topMatches", topMatches);
            request.setAttribute("completeness", completeness);
            
            // L\u1ea5y danh s\u00e1ch y\u00eau c\u1ea7u gh\u00e9p c\u1eb7p cho c\u00e1c tab
            List<BuddyRequest> receivedRequests = buddyRequestDAO.getReceivedRequests(currentUserId);
            request.setAttribute("receivedRequests", receivedRequests);
            List<BuddyRequest> sentRequests = buddyRequestDAO.getSentRequests(currentUserId);
            request.setAttribute("sentRequests", sentRequests);
            List<User> acceptedBuddies = buddyRequestDAO.getAcceptedBuddies(currentUserId);
            request.setAttribute("acceptedBuddies", acceptedBuddies);
            
            // L\u1ea5y s\u1edf th\u00edch du l\u1ecbch c\u1ee7a nh\u1eefng ng\u01b0\u1eddi \u0111\u00e3 \u0111\u01b0\u1ee3c gh\u00e9p c\u1eb7p
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
                            session.setAttribute("successMsg", "\u00c4\u0090\u0102\u00a3 g\u1eedi l\u00e1\u00bb\u009di m\u00e1\u00bb\u009di k\u1ebft n\u1ed1i th\u00e0nh c\u00f4ng!");
                            Notification notif = new Notification();
                            notif.setUserId(receiverId);
                            notif.setSenderId(currentUserId);
                            notif.setTitle("L\u00e1\u00bb\u009di m\u00e1\u00bb\u009di k\u1ebft n\u1ed1i m\u1edbi");
                            notif.setContent(sessionUser.getFullName() + " v\u1eeba g\u1eedi cho b\u1ea1n m\u1ed9t l\u00e1\u00bb\u009di m\u00e1\u00bb\u009di k\u1ebft n\u1ed1i Buddy. H\u00e3y ki\u1ec3m tra v\u00e0 ph\u1ea3n h\u1ed3i nh\u00e9!");
                            notif.setChannel("In-App");
                            notif.setCategory("Buddy Request");
                            NotificationDAO notifDAO = new NotificationDAO();
                            notifDAO.insertNotification(notif);
                        } else {
                            session.setAttribute("errorMsg", "Kh\u00f4ng th\u1ec3 g\u1eedi l\u00e1\u00bb\u009di m\u00e1\u00bb\u009di. Vui l\u00f2ng th\u1eed l\u1ea1i.");
                        }
                    } catch (Exception ex) {
                        session.setAttribute("errorMsg", "DB Error: " + ex.getMessage());
                    }
                    break;

                case "accept":
                    int reqIdAccept = Integer.parseInt(request.getParameter("requestId"));
                    BuddyRequest reqToAccept = buddyRequestDAO.getRequestById(reqIdAccept);
                    boolean accepted = buddyRequestDAO.updateRequestStatus(reqIdAccept, "Accepted");
                    if (accepted) {
                        session.setAttribute("successMsg", "\u00c4\u0090\u0102\u00a3 ch\u1ea5p nh\u1eadn l\u00e1\u00bb\u009di m\u00e1\u00bb\u009di k\u1ebft n\u1ed1i!");
                        if (reqToAccept != null) {
                            Notification notif = new Notification();
                            notif.setUserId(reqToAccept.getSenderId());
                            notif.setSenderId(currentUserId);
                            notif.setTitle("L\u00e1\u00bb\u009di m\u00e1\u00bb\u009di k\u1ebft b\u1ea1n \u0111\u01b0\u1ee3c ch\u1ea5p nh\u1eadn");
                            notif.setContent(sessionUser.getFullName() + " \u0111\u00e3 ch\u1ea5p nh\u1eadn l\u00e1\u00bb\u009di m\u00e1\u00bb\u009di k\u1ebft n\u1ed1i Buddy c\u1ee7a b\u1ea1n. Kh\u00e1m ph\u00e1 chuy\u1ebfn \u0111i ngay!");
                            notif.setChannel("In-App");
                            notif.setCategory("System Announcement");
                            NotificationDAO notifDAO = new NotificationDAO();
                            notifDAO.insertNotification(notif);
                        }
                    } else {
                        session.setAttribute("errorMsg", "L\u1ed7i khi ch\u1ea5p nh\u1eadn l\u00e1\u00bb\u009di m\u00e1\u00bb\u009di.");
                    }
                    break;

                case "reject":
                    int reqIdReject = Integer.parseInt(request.getParameter("requestId"));
                    boolean rejected = buddyRequestDAO.updateRequestStatus(reqIdReject, "Rejected");
                    if (rejected) {
                        session.setAttribute("successMsg", "\u00c4\u0090\u0102\u00a3 t\u1eeb ch\u1ed1i l\u00e1\u00bb\u009di m\u00e1\u00bb\u009di.");
                    } else {
                        session.setAttribute("errorMsg", "L\u1ed7i khi t\u1eeb ch\u1ed1i l\u00e1\u00bb\u009di m\u00e1\u00bb\u009di.");
                    }
                    break;

                case "cancel":
                    int reqIdCancel = Integer.parseInt(request.getParameter("requestId"));
                    boolean cancelled = buddyRequestDAO.cancelRequest(reqIdCancel, currentUserId);
                    if (cancelled) {
                        session.setAttribute("successMsg", "\u00c4\u0090\u0102\u00a3 h\u1ee7y l\u00e1\u00bb\u009di m\u00e1\u00bb\u009di g\u1eedi \u0111i.");
                    } else {
                        session.setAttribute("errorMsg", "Kh\u00f4ng th\u1ec3 h\u1ee7y l\u00e1\u00bb\u009di m\u00e1\u00bb\u009di. L\u00e1\u00bb\u009di m\u00e1\u00bb\u009di c\u00f3 th\u1ec3 \u0111\u00e3 \u0111\u01b0\u1ee3c ch\u1ea5p nh\u1eadn ho\u1eb7c b\u1ecb t\u1eeb ch\u1ed1i.");
                    }
                    break;

                case "unfriend":
                    int targetId = Integer.parseInt(request.getParameter("targetId"));
                    boolean unfriended = buddyRequestDAO.unfriendBuddy(currentUserId, targetId);
                    if (unfriended) {
                        session.setAttribute("successMsg", "\u00c4\u0090\u0102\u00a3 h\u1ee7y k\u1ebft b\u1ea1n th\u00e0nh c\u00f4ng.");
                    } else {
                        session.setAttribute("errorMsg", "L\u1ed7i khi h\u1ee7y k\u1ebft b\u1ea1n.");
                    }
                    break;
            }
        } catch (Exception e) {
            session.setAttribute("errorMsg", "\u00c4\u0090\u0102\u00a3 c\u00f3 l\u1ed7i x\u1ea3y ra: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/customer/buddies");
    }
}

