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

        // --- ÄĂ¡nh dấu một thông báo đã Ä‘á»c (AJAX) ---
        if (path.equals("/customer/notifications/read")) {
            NotificationDAO dao = new NotificationDAO();
            try {
                String idStr = request.getParameter("id");
                if (idStr != null) {
                    try {
                        int notifId = Integer.parseInt(idStr);
                        dao.markAsRead(notifId);
                    } catch (NumberFormatException e) {
                        // Bỏ qua ID không hợp lệ
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

        // --- ÄĂ¡nh dấu tất cả đã Ä‘á»c ---
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

        // --- Xem danh sách thông báo (tạo DAO mới mỗi request) ---
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

