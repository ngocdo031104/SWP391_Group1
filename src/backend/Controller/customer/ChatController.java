/*
 * Liên quan đến UCs: Exchange Messages
 * Tác giả: Đỗ Vũ Minh Ngọc
 * MSSV: HE182479
 */
package Controller.customer;

import Entities.Conversation;
import Entities.Message;
import Entities.User;
import Model.ChatDAO;
import Model.BuddyRequestDAO;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ChatController", urlPatterns = {"/customer/chat"})
public class ChatController extends HttpServlet {

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
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        if ("history".equals(action)) {
            // Lấy lịch sử tin nhắn của cuộc hội thoại
            response.setContentType("application/json;charset=UTF-8");
            try {
                int conversationId = Integer.parseInt(request.getParameter("conversationId"));
                int offset = 0;
                int limit = 50;
                if (request.getParameter("offset") != null) {
                    offset = Integer.parseInt(request.getParameter("offset"));
                }
                
                // Đánh dấu tin nhắn đã được đọc
                chatDAO.markConversationAsRead(conversationId, user.getUserId());
                
                List<Message> messages = chatDAO.getMessages(conversationId, limit, offset);
                response.getWriter().write(gson.toJson(messages));
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": \"Invalid parameters\"}");
            }
            return;
        }

        // Lấy danh sách bạn đồng hành để tạo nhóm chat
        BuddyRequestDAO buddyDAO = new BuddyRequestDAO();
        List<User> buddies = buddyDAO.getAcceptedBuddies(user.getUserId());
        request.setAttribute("buddies", buddies);

        // Tải trang chat chính
        List<Conversation> conversations = chatDAO.getUserConversations(user.getUserId());
        request.setAttribute("conversations", conversations);
        request.getRequestDispatcher("/customer/chat.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Xử lý các hành động phụ như chặn người dùng
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("sessionUser");
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        
        String action = request.getParameter("action");
        if ("create".equals(action)) {
            // Kiểm tra hoặc tạo mới cuộc hội thoại
            try {
                int targetUserId = Integer.parseInt(request.getParameter("targetUserId"));
                int conversationId = chatDAO.getOrCreateDirectConversation(user.getUserId(), targetUserId);
                
                response.sendRedirect(request.getContextPath() + "/customer/chat?convId=" + conversationId);
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            }
        } else if ("createGroup".equals(action)) {
            try {
                String groupName = request.getParameter("groupName");
                String[] participants = request.getParameterValues("participants");
                if (groupName != null && !groupName.trim().isEmpty() && participants != null && participants.length > 0) {
                    int conversationId = chatDAO.createGroupConversation(groupName.trim(), user.getUserId(), participants);
                    response.sendRedirect(request.getContextPath() + "/customer/chat?convId=" + conversationId);
                } else {
                    response.sendRedirect(request.getContextPath() + "/customer/chat?error=InvalidGroupData");
                }
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            }
        }
    }
}

