package test;

import Model.ChatDAO;
import Entities.Conversation;
import java.util.List;

public class TestChat {
    public static void main(String[] args) {
        ChatDAO dao = new ChatDAO();
        // Assuming we want to fetch for UserID = 13 (the one who clicked most recently based on DB logs)
        List<Conversation> list = dao.getUserConversations(13);
        System.out.println("User 13 has " + list.size() + " conversations");
        for (Conversation c : list) {
            System.out.println("Conv " + c.getConversationId() + ": " + c.getTitle() + " - " + c.getAvatarUrl());
        }
    }
}
