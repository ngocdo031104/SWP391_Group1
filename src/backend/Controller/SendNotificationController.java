package Controller;

import Entities.Notification;
import Entities.User;
import Model.NotificationDAO;
import Model.UserDAO;
import Utils.EmailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@WebServlet(name = "SendNotificationController", urlPatterns = {"/staff/send-notification"})
public class SendNotificationController extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("sessionUser");
        
        // Basic auth check
        if (currentUser == null || (!currentUser.getRole().getRoleName().equals("Staff") && !currentUser.getRole().getRoleName().equals("Admin"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<User> customers = userDAO.getAllCustomers();
        request.setAttribute("customers", customers);
        request.getRequestDispatcher("/views/staff/send-notification.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("sessionUser");

        if (currentUser == null || (!currentUser.getRole().getRoleName().equals("Staff") && !currentUser.getRole().getRoleName().equals("Admin"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String[] selectedUsers = request.getParameterValues("userIds");
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String channel = request.getParameter("channel"); // SYSTEM, EMAIL, BOTH
        String category = request.getParameter("category");
        String scheduledAtStr = request.getParameter("scheduledAt"); // e.g. 2026-06-15T14:30

        if (selectedUsers == null || selectedUsers.length == 0 || title == null || title.trim().isEmpty() || content == null || content.trim().isEmpty() || channel == null || category == null) {
            request.setAttribute("error", "Vui lòng điền đầy đủ thông tin.");
            doGet(request, response);
            return;
        }

        Timestamp scheduledAt = null;
        if (scheduledAtStr != null && !scheduledAtStr.trim().isEmpty()) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
                Date date = sdf.parse(scheduledAtStr);
                scheduledAt = new Timestamp(date.getTime());
                if (scheduledAt.before(new Date())) {
                    request.setAttribute("error", "Thời gian lên lịch phải ở tương lai.");
                    doGet(request, response);
                    return;
                }
            } catch (ParseException e) {
                request.setAttribute("error", "Định dạng thời gian không hợp lệ.");
                doGet(request, response);
                return;
            }
        }

        boolean hasError = false;

        for (String userIdStr : selectedUsers) {
            int userId = Integer.parseInt(userIdStr);
            User targetUser = userDAO.getUserById(userId);
            
            if (targetUser != null) {
                // Save to DB
                Notification notification = new Notification();
                notification.setUserId(userId);
                notification.setSenderId(currentUser.getUserId());
                notification.setTitle(title);
                notification.setContent(content);
                notification.setChannel(channel);
                notification.setCategory(category);
                notification.setScheduledAt(scheduledAt);
                
                if (scheduledAt != null) {
                    notification.setStatus("SCHEDULED");
                } else {
                    notification.setStatus("SENT");
                }
                
                notificationDAO.insertNotification(notification);
                
                // Send email immediately if not scheduled
                if (scheduledAt == null && (channel.equals("EMAIL") || channel.equals("BOTH"))) {
                    try {
                        EmailUtil.sendNotificationEmail(targetUser.getEmail(), title, content);
                    } catch (Exception e) {
                        e.printStackTrace();
                        hasError = true;
                    }
                }
            }
        }

        if (hasError) {
            request.setAttribute("warning", "Một số email có thể chưa được gửi đi, nhưng thông báo hệ thống đã được lưu.");
        } else {
            if (scheduledAt != null) {
                request.setAttribute("success", "Đã lên lịch gửi thông báo thành công.");
            } else {
                request.setAttribute("success", "Gửi thông báo thành công.");
            }
        }
        
        doGet(request, response);
    }
}
