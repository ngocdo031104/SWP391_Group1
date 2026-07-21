import java.sql.*;

public class FixDB {
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://localhost:1433;databaseName=TourBuddyDB;encrypt=true;trustServerCertificate=true;characterEncoding=UTF-8;";
        String user = "sa";
        String pass = "123";

        try (Connection conn = DriverManager.getConnection(url, user, pass)) {
            System.out.println("Connected to DB!");
            try (Statement st = conn.createStatement()) {
                st.executeUpdate("DELETE FROM Comment");
                st.executeUpdate("DELETE FROM CommunityPost");
                st.executeUpdate("DELETE FROM Review");
                st.executeUpdate("DELETE FROM ModerationRecord");
                st.executeUpdate("DELETE FROM FraudAlert");
                st.executeUpdate("DELETE FROM FinancialAuditLog");
                st.executeUpdate("DELETE FROM TourOperationLog");
                System.out.println("Cleared old test records!");
            }

            // Insert clean Vietnamese Reviews
            String sqlReview = "INSERT INTO Review (TourID, BookingID, CustomerID, Rating, Content, IsVisible, IsFlagged, CreatedAt, UpdatedAt) VALUES (?, ?, ?, ?, ?, ?, ?, SYSDATETIME(), SYSDATETIME())";
            try (PreparedStatement ps = conn.prepareStatement(sqlReview);
                 Statement st = conn.createStatement()) {

                int custId = 0, tourId = 0;
                ResultSet rsUser = st.executeQuery("SELECT TOP 1 UserID FROM [User] WHERE RoleID = 4");
                if (rsUser.next()) custId = rsUser.getInt(1);
                rsUser.close();

                ResultSet rsTour = st.executeQuery("SELECT TOP 1 TourID FROM Tour");
                if (rsTour.next()) tourId = rsTour.getInt(1);
                rsTour.close();

                ResultSet rsBk = st.executeQuery("SELECT BookingID FROM Booking");
                int count = 0;
                String[] reviewContents = {
                    "Chuyến đi tuyệt vời! Hướng dẫn viên rất nhiệt tình và chu đáo.",
                    "Dịch vụ xe đưa đón muộn 30 phút, cần cải thiện thái độ phục vụ.",
                    "Cảnh đẹp, đồ ăn ngon nhưng hành trình hơi gấp gáp.",
                    "Trải nghiệm tuyệt vời, dịch vụ tốt, nhân viên thân thiện!",
                    "Khách sạn sạch sẽ, lịch trình hợp lý, 10/10 điểm!"
                };
                int[] ratings = {5, 2, 4, 5, 5};
                boolean[] isFlagged = {false, true, false, false, false};

                while (rsBk.next() && count < reviewContents.length) {
                    int bkId = rsBk.getInt("BookingID");
                    ps.setInt(1, tourId);
                    ps.setInt(2, bkId);
                    ps.setInt(3, custId);
                    ps.setInt(4, ratings[count]);
                    ps.setString(5, reviewContents[count]);
                    ps.setBoolean(6, true);
                    ps.setBoolean(7, isFlagged[count]);
                    ps.executeUpdate();
                    count++;
                }
                rsBk.close();
                System.out.println("Inserted " + count + " clean Vietnamese reviews!");
            }

            // Insert clean Vietnamese Community Posts & Comments
            String sqlPost = "INSERT INTO CommunityPost (AuthorID, Title, Content, ImageURL, IsVisible, IsFlagged, LikeCount, CreatedAt, UpdatedAt) VALUES (?, ?, ?, ?, 1, ?, 15, SYSDATETIME(), SYSDATETIME())";
            int postId = 0;
            try (PreparedStatement ps = conn.prepareStatement(sqlPost, Statement.RETURN_GENERATED_KEYS);
                 Statement st = conn.createStatement()) {
                
                int custId = 0;
                ResultSet rsUser = st.executeQuery("SELECT TOP 1 UserID FROM [User] WHERE RoleID = 4");
                if (rsUser.next()) custId = rsUser.getInt(1);
                rsUser.close();

                ps.setInt(1, custId);
                ps.setString(2, "Kinh nghiệm du lịch Sapa mùa lúa chín");
                ps.setString(3, "Sapa mùa này lúa chín vàng rực các thửa ruộng bậc thang. Các bạn nên đi vào tầm giữa tháng 9 đến đầu tháng 10 nhé!");
                ps.setString(4, "https://images.unsplash.com/photo-1540555700478-4be289fbecef");
                ps.setBoolean(5, false);
                ps.executeUpdate();
                ResultSet keys = ps.getGeneratedKeys();
                if (keys.next()) postId = keys.getInt(1);
                keys.close();

                ps.setInt(1, custId);
                ps.setString(2, "Bán vé tour giá rẻ chiết khấu 50%");
                ps.setString(3, "Liên hệ Zalo 0999xxx để mua vé tour ưu đãi siêu rẻ không qua trung gian!");
                ps.setString(4, null);
                ps.setBoolean(5, true);
                ps.executeUpdate();
                System.out.println("Inserted clean Community Posts!");
            }

            if (postId > 0) {
                String sqlComment = "INSERT INTO Comment (PostID, AuthorID, Content, IsVisible, IsFlagged, CreatedAt) VALUES (?, ?, ?, 1, ?, SYSDATETIME())";
                try (PreparedStatement ps = conn.prepareStatement(sqlComment);
                     Statement st = conn.createStatement()) {
                    int custId = 0;
                    ResultSet rsUser = st.executeQuery("SELECT TOP 1 UserID FROM [User] WHERE RoleID = 4");
                    if (rsUser.next()) custId = rsUser.getInt(1);
                    rsUser.close();

                    ps.setInt(1, postId);
                    ps.setInt(2, custId);
                    ps.setString(3, "Cảm ơn bài viết chia sẻ rất chi tiết của bạn!");
                    ps.setBoolean(4, false);
                    ps.executeUpdate();

                    ps.setInt(1, postId);
                    ps.setInt(2, custId);
                    ps.setString(3, "Cho mình hỏi chi phí đi 3 ngày 2 đêm hết khoảng bao nhiêu ạ?");
                    ps.setBoolean(4, false);
                    ps.executeUpdate();

                    ps.setInt(1, postId);
                    ps.setInt(2, custId);
                    ps.setString(3, "Truy cập ngay web https://spam-link.xyz nhận quà 100k");
                    ps.setBoolean(4, true);
                    ps.executeUpdate();
                    System.out.println("Inserted clean Comments!");
                }
            }

            // Insert clean ModerationRecords
            String sqlMod = "INSERT INTO ModerationRecord (EntityType, EntityID, Action, Reason, ModeratedBy, ModeratedAt) VALUES (?, ?, ?, ?, 1, SYSDATETIME())";
            try (PreparedStatement ps = conn.prepareStatement(sqlMod)) {
                ps.setString(1, "Review"); ps.setInt(2, 1); ps.setString(3, "HIDE"); ps.setString(4, "Chứa ngôn từ không phù hợp và quảng cáo rác"); ps.executeUpdate();
                ps.setString(1, "CommunityPost"); ps.setInt(2, 2); ps.setString(3, "APPROVE"); ps.setString(4, "Bài viết chia sẻ kinh nghiệm chất lượng cao"); ps.executeUpdate();
                ps.setString(1, "Comment"); ps.setInt(2, 5); ps.setString(3, "DELETE"); ps.setString(4, "Spam link lừa đảo"); ps.executeUpdate();
                System.out.println("Inserted clean ModerationRecords!");
            }

            // Insert clean FraudAlerts
            String sqlFraud = "INSERT INTO FraudAlert (PaymentID, AlertType, Description, Severity, Status, ReviewedBy, ReviewedAt, CreatedAt) VALUES (?, ?, ?, ?, ?, 1, SYSDATETIME(), SYSDATETIME())";
            try (PreparedStatement ps = conn.prepareStatement(sqlFraud);
                 Statement st = conn.createStatement()) {
                ResultSet rsPay = st.executeQuery("SELECT TOP 1 PaymentID FROM Payment");
                if (rsPay.next()) {
                    int payId = rsPay.getInt(1);
                    ps.setInt(1, payId); ps.setString(2, "Multiple Failed Attempts"); ps.setString(3, "Phát hiện 5 giao dịch thất bại liên tiếp từ IP lạ 113.190.12.4"); ps.setString(4, "High"); ps.setString(5, "Investigating"); ps.executeUpdate();
                    ps.setInt(1, payId); ps.setString(2, "High Value Transaction"); ps.setString(3, "Giao dịch thanh toán giá trị bất thường 50.000.000đ qua thẻ Visa quốc tế"); ps.setString(4, "Medium"); ps.setString(5, "Open"); ps.executeUpdate();
                    ps.setInt(1, payId); ps.setString(2, "Unusual Location IP"); ps.setString(3, "Khách hàng đăng nhập từ nước ngoài (Nga) đặt tour tại Việt Nam"); ps.setString(4, "Low"); ps.setString(5, "Resolved"); ps.executeUpdate();
                }
                rsPay.close();
                System.out.println("Inserted clean FraudAlerts!");
            }

            // Insert clean FinancialAuditLog
            String sqlAudit = "INSERT INTO FinancialAuditLog (EntityType, EntityID, Action, OldValues, NewValues, PerformedBy, CreatedAt) VALUES (?, ?, ?, ?, ?, 1, SYSDATETIME())";
            try (PreparedStatement ps = conn.prepareStatement(sqlAudit)) {
                ps.setString(1, "Payment"); ps.setInt(2, 1); ps.setString(3, "UPDATE_STATUS"); ps.setString(4, "Status: Pending"); ps.setString(5, "Status: Success"); ps.executeUpdate();
                ps.setString(1, "Refund"); ps.setInt(2, 1); ps.setString(3, "APPROVE_REFUND"); ps.setString(4, "Status: Pending"); ps.setString(5, "Status: Completed | Amount: 1.500.000đ"); ps.executeUpdate();
                ps.setString(1, "Coupon"); ps.setInt(2, 2); ps.setString(3, "CREATE_PROMO"); ps.setString(4, "None"); ps.setString(5, "Code: SUMMER2026 | Discount: 15%"); ps.executeUpdate();
                ps.setString(1, "Booking"); ps.setInt(2, 3); ps.setString(3, "CANCEL_BOOKING"); ps.setString(4, "Status: Confirmed"); ps.setString(5, "Status: Cancelled | Reason: Khách thay đổi lịch"); ps.executeUpdate();
                System.out.println("Inserted clean FinancialAuditLog!");
            }

            // Insert clean TourOperationLog
            String sqlOp = "INSERT INTO TourOperationLog (ScheduleID, Activity, OperatedBy, CreatedAt) VALUES (?, ?, 1, SYSDATETIME())";
            try (PreparedStatement ps = conn.prepareStatement(sqlOp);
                 Statement st = conn.createStatement()) {
                ResultSet rsSch = st.executeQuery("SELECT TOP 1 ScheduleID FROM TourSchedule");
                if (rsSch.next()) {
                    int schId = rsSch.getInt(1);
                    ps.setInt(1, schId); ps.setString(2, "Khởi hành tour đúng giờ tại điểm đón Nhà Hát Lớn"); ps.executeUpdate();
                    ps.setInt(1, schId); ps.setString(2, "Điểm danh hoàn tất: 18/20 khách có mặt"); ps.executeUpdate();
                    ps.setInt(1, schId); ps.setString(2, "Cập nhật sự cố: Thời tiết mưa nhẹ, đoàn chuyển sang tham quan bảo tàng"); ps.executeUpdate();
                }
                rsSch.close();
                System.out.println("Inserted clean TourOperationLog!");
            }

            System.out.println("ALL DATA SUCCESSFULLY FIXED WITH 100% CLEAN UNICODE VIETNAMESE!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
