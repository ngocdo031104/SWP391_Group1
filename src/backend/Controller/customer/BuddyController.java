/*
 * Liên quan đến UCs: Match Travel Companions, Manage Buddy Requests
 * Tác giả: Đỗ Vũ Minh Ngọc
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
            // Khởi tạo sở thích mặc định nếu chưa có
            if (myPref == null) {
                myPref = new TravelPreference();
                myPref.setDestination("Any Destination");
                myPref.setTravelStyle("Explorer");
                myPref.setLanguages("Tiáº¿ng Viá»‡t");
            }
            
            List<MatchedUser> topMatches = matchingDAO.getTopMatches(currentUserId);
            
            // Tính toán phần trăm hoàn thiện hồ sơ
            int completeness = 40;
            if (myPref.getDestination() != null && !myPref.getDestination().isEmpty()) completeness += 15;
            if (myPref.getTravelStyle() != null && !myPref.getTravelStyle().isEmpty()) completeness += 15;
            if (myPref.getMinBudget() > 0) completeness += 15;
            if (myPref.getTags() != null && !myPref.getTags().isEmpty()) completeness += 15;
            
            request.setAttribute("myPref", myPref);
            request.setAttribute("topMatches", topMatches);
            request.setAttribute("completeness", completeness);
            
            // Lấy danh sách yêu cầu ghép cặp cho các tab
            List<BuddyRequest> receivedRequests = buddyRequestDAO.getReceivedRequests(currentUserId);
            request.setAttribute("receivedRequests", receivedRequests);
            List<BuddyRequest> sentRequests = buddyRequestDAO.getSentRequests(currentUserId);
            request.setAttribute("sentRequests", sentRequests);
            List<User> acceptedBuddies = buddyRequestDAO.getAcceptedBuddies(currentUserId);
            request.setAttribute("acceptedBuddies", acceptedBuddies);
            
            // Lấy sở thích du lịch của những người đã được ghép cặp
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
                            session.setAttribute("successMsg", "ÄĂ£ gá»­i lá»i má»i káº¿t ná»‘i thĂ nh cĂ´ng!");
                            Notification notif = new Notification();
                            notif.setUserId(receiverId);
                            notif.setSenderId(currentUserId);
                            notif.setTitle("Lá»i má»i káº¿t ná»‘i má»›i");
                            notif.setContent(sessionUser.getFullName() + " vá»«a gá»­i cho báº¡n má»™t lá»i má»i káº¿t ná»‘i Buddy. HĂ£y kiá»ƒm tra vĂ  pháº£n há»“i nhĂ©!");
                            notif.setChannel("In-App");
                            notif.setCategory("Buddy Request");
                            NotificationDAO notifDAO = new NotificationDAO();
                            notifDAO.insertNotification(notif);
                        } else {
                            session.setAttribute("errorMsg", "KhĂ´ng thá»ƒ gá»­i lá»i má»i. Vui lĂ²ng thá»­ láº¡i.");
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
                        session.setAttribute("successMsg", "ÄĂ£ cháº¥p nháº­n lá»i má»i káº¿t ná»‘i!");
                        if (reqToAccept != null) {
                            Notification notif = new Notification();
                            notif.setUserId(reqToAccept.getSenderId());
                            notif.setSenderId(currentUserId);
                            notif.setTitle("Lá»i má»i káº¿t báº¡n Ä‘Æ°á»£c cháº¥p nháº­n");
                            notif.setContent(sessionUser.getFullName() + " Ä‘Ă£ cháº¥p nháº­n lá»i má»i káº¿t ná»‘i Buddy cá»§a báº¡n. KhĂ¡m phĂ¡ chuyáº¿n Ä‘i ngay!");
                            notif.setChannel("In-App");
                            notif.setCategory("System Announcement");
                            NotificationDAO notifDAO = new NotificationDAO();
                            notifDAO.insertNotification(notif);
                        }
                    } else {
                        session.setAttribute("errorMsg", "Lá»—i khi cháº¥p nháº­n lá»i má»i.");
                    }
                    break;

                case "reject":
                    int reqIdReject = Integer.parseInt(request.getParameter("requestId"));
                    boolean rejected = buddyRequestDAO.updateRequestStatus(reqIdReject, "Rejected");
                    if (rejected) {
                        session.setAttribute("successMsg", "ÄĂ£ tá»« chá»‘i lá»i má»i.");
                    } else {
                        session.setAttribute("errorMsg", "Lá»—i khi tá»« chá»‘i lá»i má»i.");
                    }
                    break;

                case "cancel":
                    int reqIdCancel = Integer.parseInt(request.getParameter("requestId"));
                    boolean cancelled = buddyRequestDAO.cancelRequest(reqIdCancel, currentUserId);
                    if (cancelled) {
                        session.setAttribute("successMsg", "ÄĂ£ há»§y lá»i má»i gá»­i Ä‘i.");
                    } else {
                        session.setAttribute("errorMsg", "KhĂ´ng thá»ƒ há»§y lá»i má»i. Lá»i má»i cĂ³ thá»ƒ Ä‘Ă£ Ä‘Æ°á»£c cháº¥p nháº­n hoáº·c bá»‹ tá»« chá»‘i.");
                    }
                    break;

                case "unfriend":
                    int targetId = Integer.parseInt(request.getParameter("targetId"));
                    boolean unfriended = buddyRequestDAO.unfriendBuddy(currentUserId, targetId);
                    if (unfriended) {
                        session.setAttribute("successMsg", "ÄĂ£ há»§y káº¿t báº¡n thĂ nh cĂ´ng.");
                    } else {
                        session.setAttribute("errorMsg", "Lá»—i khi há»§y káº¿t báº¡n.");
                    }
                    break;
            }
        } catch (Exception e) {
            session.setAttribute("errorMsg", "ÄĂ£ cĂ³ lá»—i xáº£y ra: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/customer/buddies");
    }
}

