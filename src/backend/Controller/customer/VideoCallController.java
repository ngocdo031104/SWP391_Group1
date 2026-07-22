/*
 * Liên quan đến UCs: Schedule Video Calls
 * Tác giả: Đỗ Vũ Minh Ngọc
 * MSSV: HE182479
 */
package Controller.customer;

import Entities.Message;
import Entities.User;
import Entities.VideoCallSchedule;
import Model.ChatDAO;
import Model.VideoCallDAO;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet(name = "VideoCallController", urlPatterns = {"/customer/video-call"})
public class VideoCallController extends HttpServlet {

    private final VideoCallDAO videoCallDAO = new VideoCallDAO();
    private final ChatDAO chatDAO = new ChatDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("sessionUser");
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String action = request.getParameter("action");

        if ("list".equals(action)) {
            response.setContentType("application/json;charset=UTF-8");
            try {
                int conversationId = Integer.parseInt(request.getParameter("conversationId"));
                List<VideoCallSchedule> calls = videoCallDAO.getUpcomingCallsForConversation(conversationId);
                response.getWriter().write(gson.toJson(calls));
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": \"Invalid parameters\"}");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("sessionUser");
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String action = request.getParameter("action");

        if ("create".equals(action) || "update".equals(action)) {
            response.setContentType("application/json;charset=UTF-8");
            try {
                int conversationId = Integer.parseInt(request.getParameter("conversationId"));
                
                // Kiểm tra quyền truy cập hội thoại
                if (!videoCallDAO.isUserInConversation(user.getUserId(), conversationId)) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    response.getWriter().write("{\"success\": false, \"message\": \"You are not a participant of this conversation.\"}");
                    return;
                }

                String title = request.getParameter("title");
                String dateStr = request.getParameter("scheduledAt");
                int durationMin = 0;
                try {
                    durationMin = Integer.parseInt(request.getParameter("durationMin"));
                } catch (NumberFormatException ignored) {}
                String meetingUrl = request.getParameter("meetingUrl");

                // Kiểm tra tính hợp lệ của dữ liệu
                if (title == null || title.trim().isEmpty() ||
                    dateStr == null || dateStr.trim().isEmpty() ||
                    meetingUrl == null || meetingUrl.trim().isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\": false, \"message\": \"Title, Date, and Meeting URL cannot be empty.\"}");
                    return;
                }

                // BR-02
                if (durationMin <= 0) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\": false, \"message\": \"Duration must be greater than 0.\"}");
                    return;
                }
                
                // BR-04
                if (!meetingUrl.startsWith("http://") && !meetingUrl.startsWith("https://")) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\": false, \"message\": \"Meeting URL must be a valid HTTP link.\"}");
                    return;
                }

                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
                LocalDateTime localDateTime = LocalDateTime.parse(dateStr, formatter);
                Timestamp scheduledAt = Timestamp.valueOf(localDateTime);

                // BR-01
                if (scheduledAt.before(new Timestamp(System.currentTimeMillis()))) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\": false, \"message\": \"Scheduled time must be in the future.\"}");
                    return;
                }

                if ("create".equals(action)) {
                    VideoCallSchedule call = new VideoCallSchedule();
                    call.setConversationId(conversationId);
                    call.setOrganizedBy(user.getUserId());
                    call.setTitle(title);
                    call.setScheduledAt(scheduledAt);
                    call.setDurationMin(durationMin);
                    call.setMeetingUrl(meetingUrl);

                    VideoCallSchedule savedCall = videoCallDAO.scheduleCall(call);

                    if (savedCall != null && savedCall.getCallId() > 0) {
                        Message msg = new Message();
                        msg.setConversationId(conversationId);
                        msg.setSenderId(user.getUserId());
                        msg.setContent("\uD83D\uDCC5 ÄĂ£ lên lịch gá»i Video: " + title + " vào lúc " + dateStr.replace("T", " ") + ". Tham gia tại: " + meetingUrl);
                        chatDAO.saveMessage(msg);
                        
                        response.getWriter().write(gson.toJson(savedCall));
                    } else {
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        response.getWriter().write("{\"success\": false, \"message\": \"Failed to schedule call\"}");
                    }
                } else if ("update".equals(action)) {
                    int callId = Integer.parseInt(request.getParameter("callId"));
                    VideoCallSchedule existing = videoCallDAO.getCallById(callId);
                    
                    if (existing == null) {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        response.getWriter().write("{\"success\": false, \"message\": \"Call not found.\"}");
                        return;
                    }
                    
                    // BR-03 (Edit)
                    if (existing.getOrganizedBy() != user.getUserId()) {
                        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                        response.getWriter().write("{\"success\": false, \"message\": \"Only the organizer can edit this call.\"}");
                        return;
                    }
                    
                    // BR-07
                    if ("Completed".equals(existing.getStatus()) || "Cancelled".equals(existing.getStatus())) {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        response.getWriter().write("{\"success\": false, \"message\": \"Cannot edit a Completed or Cancelled call.\"}");
                        return;
                    }

                    existing.setTitle(title);
                    existing.setScheduledAt(scheduledAt);
                    existing.setDurationMin(durationMin);
                    existing.setMeetingUrl(meetingUrl);

                    boolean success = videoCallDAO.updateCall(existing);
                    if (success) {
                        Message msg = new Message();
                        msg.setConversationId(conversationId);
                        msg.setSenderId(user.getUserId());
                        msg.setContent("\u270F\uFE0F ÄĂ£ cập nhật lịch gá»i Video: " + title + " sang lúc " + dateStr.replace("T", " ") + ". Tham gia tại: " + meetingUrl);
                        chatDAO.saveMessage(msg);
                        
                        response.getWriter().write(gson.toJson(existing));
                    } else {
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        response.getWriter().write("{\"success\": false, \"message\": \"Failed to update call\"}");
                    }
                }
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"Invalid parameters format.\"}");
            }
        } else if ("cancel".equals(action)) {
            response.setContentType("application/json;charset=UTF-8");
            try {
                int callId = Integer.parseInt(request.getParameter("callId"));
                int conversationId = Integer.parseInt(request.getParameter("conversationId"));
                
                VideoCallSchedule existing = videoCallDAO.getCallById(callId);
                if (existing == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write("{\"success\": false, \"message\": \"Call not found.\"}");
                    return;
                }
                
                // BR-03 (Cancel)
                if (existing.getOrganizedBy() != user.getUserId()) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    response.getWriter().write("{\"success\": false, \"message\": \"Only the organizer can cancel this call.\"}");
                    return;
                }
                
                // BR-07
                if ("Completed".equals(existing.getStatus()) || "Cancelled".equals(existing.getStatus())) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\": false, \"message\": \"Call is already completed or cancelled.\"}");
                    return;
                }
                
                boolean success = videoCallDAO.updateCallStatus(callId, "Cancelled");
                if (success) {
                    Message msg = new Message();
                    msg.setConversationId(conversationId);
                    msg.setSenderId(user.getUserId());
                    msg.setContent("\u274C ÄĂ£ hủy lịch gá»i Video: " + existing.getTitle());
                    chatDAO.saveMessage(msg);
                    
                    response.getWriter().write("{\"success\": true}");
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write("{\"success\": false, \"message\": \"Failed to cancel call\"}");
                }
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"Invalid parameters.\"}");
            }
        }
    }
}

