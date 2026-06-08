package Utils;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;

public class EmailUtil {

    // REPLACE WITH YOUR ACTUAL EMAIL AND APP PASSWORD
    private static final String SENDER_EMAIL = "ngocdo031104@gmail.com"; 
    private static final String SENDER_PASSWORD = "okgswxvuxeafspvr";

    public static void sendOTP(String recipientEmail, String otp) throws Exception {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(SENDER_EMAIL, "TourBuddy System"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
        message.setSubject("Mã xác nhận tài khoản TourBuddy");

        String htmlContent = "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;'>"
                + "<h2 style='color: #1E7D4B; text-align: center;'>TourBuddy - Xác thực tài khoản</h2>"
                + "<p>Chào bạn,</p>"
                + "<p>Cảm ơn bạn đã đăng ký tài khoản tại TourBuddy. Để hoàn tất việc đăng ký, vui lòng sử dụng mã xác nhận (OTP) gồm 6 chữ số dưới đây:</p>"
                + "<div style='text-align: center; margin: 30px 0;'>"
                + "  <span style='font-size: 24px; font-weight: bold; background-color: #f4f4f4; padding: 10px 20px; border-radius: 5px; letter-spacing: 5px; color: #333;'>" + otp + "</span>"
                + "</div>"
                + "<p>Mã này sẽ hết hạn trong vòng 10 phút.</p>"
                + "<p>Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email này.</p>"
                + "<br><p>Trân trọng,<br>Đội ngũ TourBuddy</p>"
                + "</div>";

        message.setContent(htmlContent, "text/html; charset=UTF-8");
        Transport.send(message);
    }
}
