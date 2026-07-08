package WebSockets;

import Entities.Message;
import Model.ChatDAO;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.websocket.*;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@ServerEndpoint(value = "/ws/chat/{userId}")
public class ChatEndpoint {

    // Store active sessions: Map<UserID, Session>
    private static final Map<Integer, Session> activeSessions = new ConcurrentHashMap<>();
    private static final Gson gson = new Gson();
    private final ChatDAO chatDAO = new ChatDAO();

    @OnOpen
    public void onOpen(Session session, @PathParam("userId") String userIdStr) {
        try {
            int userId = Integer.parseInt(userIdStr);
            activeSessions.put(userId, session);
            System.out.println("User " + userId + " connected to chat.");
        } catch (NumberFormatException e) {
            try {
                session.close(new CloseReason(CloseReason.CloseCodes.CANNOT_ACCEPT, "Invalid User ID"));
            } catch (IOException ioException) {
                ioException.printStackTrace();
            }
        }
    }

    @OnMessage
    public void onMessage(String messageJson, Session session, @PathParam("userId") String userIdStr) {
        try {
            int senderId = Integer.parseInt(userIdStr);
            JsonObject jsonMsg = gson.fromJson(messageJson, JsonObject.class);
            
            // Format expected from client:
            // { "conversationId": 1, "content": "Hello", "recipientId": 2 }
            
            int conversationId = jsonMsg.has("conversationId") ? jsonMsg.get("conversationId").getAsInt() : -1;
            String content = jsonMsg.get("content").getAsString();
            int recipientId = jsonMsg.has("recipientId") ? jsonMsg.get("recipientId").getAsInt() : -1;

            if (content == null || content.trim().isEmpty()) {
                return;
            }

            // Create conversation if it doesn't exist (e.g. starting a new chat)
            if (conversationId <= 0 && recipientId > 0) {
                conversationId = chatDAO.getOrCreateDirectConversation(senderId, recipientId);
            }

            if (conversationId > 0) {
                // Check block list before sending
                if (recipientId > 0 && chatDAO.isBlocked(senderId, recipientId)) {
                    // Send error back to sender
                    JsonObject error = new JsonObject();
                    error.addProperty("type", "error");
                    error.addProperty("message", "Cannot send message. User is blocked.");
                    session.getBasicRemote().sendText(error.toString());
                    return;
                }

                // Save to DB
                Message msg = new Message();
                msg.setConversationId(conversationId);
                msg.setSenderId(senderId);
                msg.setContent(content);
                msg.setMessageType("Text");
                
                Message savedMsg = chatDAO.saveMessage(msg);

                if (savedMsg != null) {
                    // Prepare response JSON
                    JsonObject responseMsg = new JsonObject();
                    responseMsg.addProperty("type", "chatMessage");
                    responseMsg.addProperty("messageId", savedMsg.getMessageId());
                    responseMsg.addProperty("conversationId", savedMsg.getConversationId());
                    responseMsg.addProperty("senderId", savedMsg.getSenderId());
                    responseMsg.addProperty("content", savedMsg.getContent());
                    responseMsg.addProperty("messageType", savedMsg.getMessageType());
                    
                    String payload = responseMsg.toString();
                    
                    // Send to sender so they see it's delivered
                    session.getBasicRemote().sendText(payload);
                    
                    // Send to recipient if they are online
                    // In a real group chat, we would fetch all participants from DB and broadcast
                    if (recipientId > 0) {
                        Session recipientSession = activeSessions.get(recipientId);
                        if (recipientSession != null && recipientSession.isOpen()) {
                            recipientSession.getBasicRemote().sendText(payload);
                        }
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @OnClose
    public void onClose(Session session, @PathParam("userId") String userIdStr) {
        try {
            int userId = Integer.parseInt(userIdStr);
            activeSessions.remove(userId);
            System.out.println("User " + userId + " disconnected.");
        } catch (NumberFormatException ignored) {}
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        System.err.println("Chat WebSocket error: " + throwable.getMessage());
    }
}
