/*
 * Liên quan đến UCs: View Notifications
 * Tác giả: Đỗ Vũ Minh Ngọc
 * MSSV: HE182479
 */
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

        // --- \u00c4\u0090\u0102\u00a1nh d\u1ea5u m\u1ed9t th\u00f4ng b\u00e1o \u0111\u00e3 \u00c4\u2018\u00e1\u00bb\u008dc (AJAX) ---
        if (path.equals("/customer/notifications/read")) {
            NotificationDAO dao = new NotificationDAO();
            try {
                String idStr = request.getParameter("id");
                if (idStr != null) {
                    try {
                        int notifId = Integer.parseInt(idStr);
                        dao.markAsRead(notifId);
                    } catch (NumberFormatException e) {
                        // B\u1ecf qua ID kh\u00f4ng h\u1ee3p l\u1ec7
                    }
                }
            } finally {
                dao.close();
            }
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\": true}");
            return;
        }

        // --- \u00c4\u0090\u0102\u00a1nh d\u1ea5u t\u1ea5t c\u1ea3 \u0111\u00e3 \u00c4\u2018\u00e1\u00bb\u008dc ---
        if (path.equals("/customer/notifications/read-all")) {
            NotificationDAO dao = new NotificationDAO();
            try {
                dao.markAllAsRead(currentUser.getUserId());
            } finally {
                dao.close();
            }
            response.sendRedirect(request.getContextPath() + "/customer/notifications");
            return;
        }

        // --- Xem danh s\u00e1ch th\u00f4ng b\u00e1o (t\u1ea1o DAO m\u1edbi m\u1ed7i request) ---
        NotificationDAO dao = new NotificationDAO();
        try {
            String category = request.getParameter("category");
            String keyword = request.getParameter("keyword");
            String unreadOnlyStr = request.getParameter("unreadOnly");
            boolean unreadOnly = "on".equals(unreadOnlyStr);

            List<Notification> notifications = dao.getNotificationsWithFilters(
                    currentUser.getUserId(), category, keyword, unreadOnly);
            int unreadCount = dao.getUnreadCount(currentUser.getUserId());

            request.setAttribute("notifications", notifications);
            request.setAttribute("unreadCount", unreadCount);
            request.setAttribute("currentCategory", category);
            request.setAttribute("currentKeyword", keyword);
            request.setAttribute("currentUnreadOnly", unreadOnly);

            request.getRequestDispatcher("/views/customer/notifications.jsp").forward(request, response);
        } finally {
            dao.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}

