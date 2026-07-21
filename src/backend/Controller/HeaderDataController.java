package Controller;

import Entities.User;
import Model.ChatDAO;
import Model.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "HeaderDataController", urlPatterns = {"/api/header-counts"})
public class HeaderDataController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            response.getWriter().write("{\"unreadMessages\": 0, \"unreadNotifications\": 0}");
            return;
        }

        User currentUser = (User) session.getAttribute("sessionUser");
        int userId = currentUser.getUserId();

        int unreadMessages = 0;
        int unreadNotifications = 0;

        ChatDAO chatDAO = new ChatDAO();
        try {
            unreadMessages = chatDAO.getUnreadMessageCount(userId);
        } finally {
            chatDAO.close();
        }

        NotificationDAO notifDAO = new NotificationDAO();
        try {
            unreadNotifications = notifDAO.getUnreadCount(userId);
        } finally {
            notifDAO.close();
        }

        String json = String.format("{\"unreadMessages\": %d, \"unreadNotifications\": %d}",
                unreadMessages, unreadNotifications);
        response.getWriter().write(json);
    }
}
