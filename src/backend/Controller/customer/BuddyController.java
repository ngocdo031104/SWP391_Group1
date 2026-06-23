package Controller.customer;

import Entities.BuddyRequest;
import Entities.User;
import Model.BuddyRequestDAO;
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

    // Removed init() to instantiate DAO per request

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        buddyRequestDAO = new BuddyRequestDAO();
        HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("sessionUser") : null;

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int userId = sessionUser.getUserId();

        List<User> suggestedBuddies = buddyRequestDAO.getSuggestedBuddies(userId);
        List<BuddyRequest> pendingRequests = buddyRequestDAO.getPendingRequests(userId);
        List<User> acceptedBuddies = buddyRequestDAO.getAcceptedBuddies(userId);

        request.setAttribute("suggestedBuddies", suggestedBuddies);
        request.setAttribute("pendingRequests", pendingRequests);
        request.setAttribute("acceptedBuddies", acceptedBuddies);

        request.getRequestDispatcher("/customer/buddies.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        buddyRequestDAO = new BuddyRequestDAO();
        HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("sessionUser") : null;

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/customer/buddies");
            return;
        }

        int currentUserId = sessionUser.getUserId();

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
            }
        } catch (Exception e) {
            session.setAttribute("errorMsg", "Đã có lỗi xảy ra: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/customer/buddies");
    }
}
