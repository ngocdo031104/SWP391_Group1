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
                myPref.setLanguages("Tiếng Việt");
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
                            session.setAttribute("successMsg", "ÄĂ£ gửi lá»i má»i kết nối thành công!");
                            Notification notif = new Notification();
                            notif.setUserId(receiverId);
                            notif.setSenderId(currentUserId);
                            notif.setTitle("Lá»i má»i kết nối mới");
                            notif.setContent(sessionUser.getFullName() + " vừa gửi cho bạn một lá»i má»i kết nối Buddy. Hãy kiểm tra và phản hồi nhé!");
                            notif.setChannel("In-App");
                            notif.setCategory("Buddy Request");
                            NotificationDAO notifDAO = new NotificationDAO();
                            notifDAO.insertNotification(notif);
                        } else {
                            session.setAttribute("errorMsg", "Không thể gửi lá»i má»i. Vui lòng thử lại.");
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
                        session.setAttribute("successMsg", "ÄĂ£ chấp nhận lá»i má»i kết nối!");
                        if (reqToAccept != null) {
                            Notification notif = new Notification();
                            notif.setUserId(reqToAccept.getSenderId());
                            notif.setSenderId(currentUserId);
                            notif.setTitle("Lá»i má»i kết bạn được chấp nhận");
                            notif.setContent(sessionUser.getFullName() + " đã chấp nhận lá»i má»i kết nối Buddy của bạn. Khám phá chuyến đi ngay!");
                            notif.setChannel("In-App");
                            notif.setCategory("System Announcement");
                            NotificationDAO notifDAO = new NotificationDAO();
                            notifDAO.insertNotification(notif);
                        }
                    } else {
                        session.setAttribute("errorMsg", "Lỗi khi chấp nhận lá»i má»i.");
                    }
                    break;

                case "reject":
                    int reqIdReject = Integer.parseInt(request.getParameter("requestId"));
                    boolean rejected = buddyRequestDAO.updateRequestStatus(reqIdReject, "Rejected");
                    if (rejected) {
                        session.setAttribute("successMsg", "ÄĂ£ từ chối lá»i má»i.");
                    } else {
                        session.setAttribute("errorMsg", "Lỗi khi từ chối lá»i má»i.");
                    }
                    break;

                case "cancel":
                    int reqIdCancel = Integer.parseInt(request.getParameter("requestId"));
                    boolean cancelled = buddyRequestDAO.cancelRequest(reqIdCancel, currentUserId);
                    if (cancelled) {
                        session.setAttribute("successMsg", "ÄĂ£ hủy lá»i má»i gửi đi.");
                    } else {
                        session.setAttribute("errorMsg", "Không thể hủy lá»i má»i. Lá»i má»i có thể đã được chấp nhận hoặc bị từ chối.");
                    }
                    break;

                case "unfriend":
                    int targetId = Integer.parseInt(request.getParameter("targetId"));
                    boolean unfriended = buddyRequestDAO.unfriendBuddy(currentUserId, targetId);
                    if (unfriended) {
                        session.setAttribute("successMsg", "ÄĂ£ hủy kết bạn thành công.");
                    } else {
                        session.setAttribute("errorMsg", "Lỗi khi hủy kết bạn.");
                    }
                    break;
            }
        } catch (Exception e) {
            session.setAttribute("errorMsg", "ÄĂ£ có lỗi xảy ra: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/customer/buddies");
    }
}

