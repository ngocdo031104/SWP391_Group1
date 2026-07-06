package test;

import Model.ChatDAO;

public class TestChat {
    public static void main(String[] args) {
        ChatDAO dao = new ChatDAO();
        // Assuming user 1 and user 2 exist. Let's try to create a conversation.
        // We need real user IDs. Let's use 1 and 2.
        int convId = dao.getOrCreateDirectConversation(1, 2);
        System.out.println("Created conv: " + convId);
    }
}
