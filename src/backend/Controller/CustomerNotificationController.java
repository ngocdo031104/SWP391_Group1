package Controller;

import Entities.Notification;
import Entities.User;
import Model.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "CustomerNotificationController", urlPatterns = {"/customer/notifications", "/customer/notifications/read", "/customer/notifications/read-all"})
public class CustomerNotificationController extends HttpServlet {

    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("sessionUser");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();
        
        if (path.equals("/customer/notifications/read")) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                try {
                    int notifId = Integer.parseInt(idStr);
                    notificationDAO.markAsRead(notifId);
                } catch (NumberFormatException e) {
                    // ignore
                }
            }
            response.sendRedirect(request.getContextPath() + "/customer/notifications");
            return;
        }

        if (path.equals("/customer/notifications/read-all")) {
            notificationDAO.markAllAsRead(currentUser.getUserId());
            response.sendRedirect(request.getContextPath() + "/customer/notifications");
            return;
        }

        // View notifications
        String category = request.getParameter("category");
        String keyword = request.getParameter("keyword");
        String unreadOnlyStr = request.getParameter("unreadOnly");
        boolean unreadOnly = unreadOnlyStr != null && unreadOnlyStr.equals("on");
        
        List<Notification> notifications = notificationDAO.getNotificationsWithFilters(currentUser.getUserId(), category, keyword, unreadOnly);
        int unreadCount = notificationDAO.getUnreadCount(currentUser.getUserId());
        
        request.setAttribute("notifications", notifications);
        request.setAttribute("unreadCount", unreadCount);
        request.setAttribute("currentCategory", category);
        request.setAttribute("currentKeyword", keyword);
        request.setAttribute("currentUnreadOnly", unreadOnly);
        
        request.getRequestDispatcher("/views/customer/notifications.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
