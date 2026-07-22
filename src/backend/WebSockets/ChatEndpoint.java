/*
 * Li\u00ean quan \u0111\u1ebfn UCs: Exchange Messages
 * T\u00e1c gi\u1ea3: \u0110\u1ed7 V\u0169 Minh Ng\u1ecdc
 * MSSV: HE182479
 */
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

    // L\u01b0u tr\u1eef c\u00e1c phi\u00ean WebSocket \u0111ang ho\u1ea1t \u0111\u1ed9ng
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
            
            // \u0110\u1ecbnh d\u1ea1ng d\u1eef li\u1ec7u mong \u0111\u1ee3i t\u1eeb client:
            // { "conversationId": 1, "content": "Hello", "recipientId": 2 }
            
            int conversationId = jsonMsg.has("conversationId") ? jsonMsg.get("conversationId").getAsInt() : -1;
            String content = jsonMsg.get("content").getAsString();
            int recipientId = jsonMsg.has("recipientId") ? jsonMsg.get("recipientId").getAsInt() : -1;
            String messageType = jsonMsg.has("messageType") ? jsonMsg.get("messageType").getAsString() : "Text";

            if (content == null || content.trim().isEmpty()) {
                return;
            }

            // T\u1ea1o m\u1edbi h\u1ed9i tho\u1ea1i n\u1ebfu ch\u01b0a t\u1ed3n t\u1ea1i
            if (conversationId <= 0 && recipientId > 0) {
                conversationId = chatDAO.getOrCreateDirectConversation(senderId, recipientId);
            }

            if (conversationId > 0) {
                // Ki\u1ec3m tra danh s\u00e1ch ch\u1eb7n tr\u01b0\u1edbc khi g\u1eedi
                if (recipientId > 0 && chatDAO.isBlocked(senderId, recipientId)) {
                    // G\u1eedi th\u00f4ng b\u00e1o l\u1ed7i v\u1ec1 cho ng\u01b0\u1eddi g\u1eedi
                    JsonObject error = new JsonObject();
                    error.addProperty("type", "error");
                    error.addProperty("message", "Cannot send message. User is blocked.");
                    session.getBasicRemote().sendText(error.toString());
                    return;
                }

                // L\u01b0u d\u1eef li\u1ec7u v\u00e0o Database
                Message msg = new Message();
                msg.setConversationId(conversationId);
                msg.setSenderId(senderId);
                msg.setContent(content);
                msg.setMessageType(messageType);
                
                Message savedMsg = chatDAO.saveMessage(msg);

                if (savedMsg != null) {
                    // Chu\u1ea9n b\u1ecb d\u1eef li\u1ec7u JSON \u0111\u1ec3 ph\u1ea3n h\u1ed3i
                    JsonObject responseMsg = new JsonObject();
                    responseMsg.addProperty("type", "chatMessage");
                    responseMsg.addProperty("messageId", savedMsg.getMessageId());
                    responseMsg.addProperty("conversationId", savedMsg.getConversationId());
                    responseMsg.addProperty("senderId", savedMsg.getSenderId());
                    responseMsg.addProperty("content", savedMsg.getContent());
                    responseMsg.addProperty("messageType", savedMsg.getMessageType());
                    
                    String payload = responseMsg.toString();
                    
                    // Tr\u1ea3 v\u1ec1 cho ng\u01b0\u1eddi g\u1eedi \u0111\u1ec3 x\u00e1c nh\u1eadn \u0111\u00e3 g\u1eedi
                    session.getBasicRemote().sendText(payload);
                    
                    // G\u1eedi cho ng\u01b0\u1eddi nh\u1eadn n\u1ebfu h\u1ecd \u0111ang tr\u1ef1c tuy\u1ebfn
                    // Broadcast tin nh\u1eafn cho t\u1ea5t c\u1ea3 th\u00e0nh vi\u00ean trong nh\u00f3m
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

