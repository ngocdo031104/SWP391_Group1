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
            // L\u1ea5y l\u1ecbch s\u1eed tin nh\u1eafn c\u1ee7a cu\u1ed9c h\u1ed9i tho\u1ea1i
            response.setContentType("application/json;charset=UTF-8");
            try {
                int conversationId = Integer.parseInt(request.getParameter("conversationId"));
                int offset = 0;
                int limit = 50;
                if (request.getParameter("offset") != null) {
                    offset = Integer.parseInt(request.getParameter("offset"));
                }
                
                // \u0110\u00e1nh d\u1ea5u tin nh\u1eafn \u0111\u00e3 \u0111\u01b0\u1ee3c \u0111\u1ecdc
                chatDAO.markConversationAsRead(conversationId, user.getUserId());
                
                List<Message> messages = chatDAO.getMessages(conversationId, limit, offset);
                response.getWriter().write(gson.toJson(messages));
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": \"Invalid parameters\"}");
            }
            return;
        }

        // L\u1ea5y danh s\u00e1ch b\u1ea1n \u0111\u1ed3ng h\u00e0nh \u0111\u1ec3 t\u1ea1o nh\u00f3m chat
        BuddyRequestDAO buddyDAO = new BuddyRequestDAO();
        List<User> buddies = buddyDAO.getAcceptedBuddies(user.getUserId());
        request.setAttribute("buddies", buddies);

        // T\u1ea3i trang chat ch\u00ednh
        List<Conversation> conversations = chatDAO.getUserConversations(user.getUserId());
        request.setAttribute("conversations", conversations);
        request.getRequestDispatcher("/customer/chat.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // X\u1eed l\u00fd c\u00e1c h\u00e0nh \u0111\u1ed9ng ph\u1ee5 nh\u01b0 ch\u1eb7n ng\u01b0\u1eddi d\u00f9ng
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("sessionUser");
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        
        String action = request.getParameter("action");
        if ("create".equals(action)) {
            // Ki\u1ec3m tra ho\u1eb7c t\u1ea1o m\u1edbi cu\u1ed9c h\u1ed9i tho\u1ea1i
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

