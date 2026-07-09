package test;

import Entities.VideoCallSchedule;
import Model.VideoCallDAO;
import java.sql.Timestamp;

public class TestVideoCall {
    public static void main(String[] args) {
        VideoCallDAO dao = new VideoCallDAO();
        VideoCallSchedule call = new VideoCallSchedule();
        call.setConversationId(2); // valid conversation
        call.setOrganizedBy(13); // valid user
        call.setTitle("Test Call");
        call.setScheduledAt(new Timestamp(System.currentTimeMillis() + 86400000));
        call.setDurationMin(30);
        call.setMeetingUrl("http://test.com");
        
        System.out.println("Attempting to schedule call...");
        VideoCallSchedule saved = dao.scheduleCall(call);
        if (saved != null) {
            System.out.println("Success! ID: " + saved.getCallId());
        } else {
            System.out.println("Failed!");
        }
    }
}
