$connString = "Server=localhost;Database=TourBuddyDB;User Id=sa;Password=123;Encrypt=False;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
$conn.Open()

$cmd = $conn.CreateCommand()

# Clear ALL records from child to parent
$cmd.CommandText = "DELETE FROM Comment; DELETE FROM CommunityPost; DELETE FROM Review; DELETE FROM ModerationRecord; DELETE FROM FraudAlert; DELETE FROM FinancialAuditLog; DELETE FROM TourOperationLog;"
$cmd.ExecuteNonQuery()

# 1. Insert Reviews with clean Vietnamese UTF-16
$cmd.CommandText = @"
DECLARE @CustID INT, @TourID INT, @BookingID INT;
SELECT TOP 1 @CustID = UserID FROM [User] WHERE RoleID = 4;
SELECT TOP 1 @TourID = TourID FROM Tour;
SELECT TOP 1 @BookingID = BookingID FROM Booking;

IF @CustID IS NOT NULL AND @TourID IS NOT NULL AND @BookingID IS NOT NULL BEGIN
    INSERT INTO Review (TourID, BookingID, CustomerID, Rating, Content, IsVisible, IsFlagged, CreatedAt, UpdatedAt)
    VALUES 
    (@TourID, @BookingID, @CustID, 5, N'Chuyến đi tuyệt vời! Hướng dẫn viên rất nhiệt tình và chu đáo.', 1, 0, SYSDATETIME(), SYSDATETIME());

    DECLARE @Bk2 INT, @Bk3 INT;
    SELECT TOP 1 @Bk2 = BookingID FROM Booking WHERE BookingID <> @BookingID;
    SELECT TOP 1 @Bk3 = BookingID FROM Booking WHERE BookingID NOT IN (@BookingID, @Bk2);

    IF @Bk2 IS NOT NULL BEGIN
        INSERT INTO Review (TourID, BookingID, CustomerID, Rating, Content, IsVisible, IsFlagged, CreatedAt, UpdatedAt)
        VALUES 
        (@TourID, @Bk2, @CustID, 2, N'Dịch vụ xe đưa đón muộn 30 phút, cần cải thiện thái độ phục vụ.', 1, 1, DATEADD(hour, -5, SYSDATETIME()), SYSDATETIME());
    END

    IF @Bk3 IS NOT NULL BEGIN
        INSERT INTO Review (TourID, BookingID, CustomerID, Rating, Content, IsVisible, IsFlagged, CreatedAt, UpdatedAt)
        VALUES 
        (@TourID, @Bk3, @CustID, 4, N'Cảnh đẹp, đồ ăn ngon nhưng hành trình hơi gấp gáp.', 1, 0, DATEADD(day, -1, SYSDATETIME()), SYSDATETIME());
    END
END
"@
$cmd.ExecuteNonQuery()

# 2. Insert Community Posts & Comments
$cmd.CommandText = @"
DECLARE @CustID INT;
SELECT TOP 1 @CustID = UserID FROM [User] WHERE RoleID = 4;

IF @CustID IS NOT NULL BEGIN
    INSERT INTO CommunityPost (AuthorID, Title, Content, ImageURL, IsVisible, IsFlagged, LikeCount, CreatedAt, UpdatedAt)
    VALUES 
    (@CustID, N'Kinh nghiệm du lịch Sapa mùa lúa chín', N'Sapa mùa này lúa chín vàng rực các thửa ruộng bậc thang. Các bạn nên đi vào tầm giữa tháng 9 đến đầu tháng 10 nhé!', N'https://images.unsplash.com/photo-1540555700478-4be289fbecef', 1, 0, 15, DATEADD(day, -2, SYSDATETIME()), SYSDATETIME()),
    (@CustID, N'Bán vé tour giá rẻ chiết khấu 50%', N'Liên hệ Zalo 0999xxx để mua vé tour ưu đãi siêu rẻ không qua trung gian!', NULL, 1, 1, 12, DATEADD(hour, -3, SYSDATETIME()), SYSDATETIME());

    DECLARE @PostID INT;
    SELECT TOP 1 @PostID = PostID FROM CommunityPost;

    IF @PostID IS NOT NULL BEGIN
        INSERT INTO Comment (PostID, AuthorID, Content, IsVisible, IsFlagged, CreatedAt)
        VALUES 
        (@PostID, @CustID, N'Cảm ơn bài viết chia sẻ rất chi tiết của bạn!', 1, 0, DATEADD(hour, -1, SYSDATETIME())),
        (@PostID, @CustID, N'Cho mình hỏi chi phí đi 3 ngày 2 đêm hết khoảng bao nhiêu ạ?', 1, 0, SYSDATETIME()),
        (@PostID, @CustID, N'Truy cập ngay web https://spam-link.xyz nhận quà 100k', 1, 1, DATEADD(minute, -30, SYSDATETIME()));
    END
END
"@
$cmd.ExecuteNonQuery()

# 3. Insert ModerationRecord
$cmd.CommandText = @"
INSERT INTO ModerationRecord (EntityType, EntityID, Action, Reason, ModeratedBy, ModeratedAt)
VALUES 
(N'Review', 1, N'HIDE', N'Chứa ngôn từ không phù hợp và quảng cáo rác', 1, DATEADD(day, -3, SYSDATETIME())),
(N'CommunityPost', 2, N'APPROVE', N'Bài viết chia sẻ kinh nghiệm chất lượng cao', 1, DATEADD(day, -1, SYSDATETIME())),
(N'Comment', 5, N'DELETE', N'Spam link lừa đảo', 1, SYSDATETIME());
"@
$cmd.ExecuteNonQuery()

# 4. Insert FraudAlert
$cmd.CommandText = @"
DECLARE @PayID INT;
SELECT TOP 1 @PayID = PaymentID FROM Payment;
IF @PayID IS NOT NULL BEGIN
    INSERT INTO FraudAlert (PaymentID, AlertType, Description, Severity, Status, ReviewedBy, ReviewedAt, CreatedAt)
    VALUES 
    (@PayID, N'Multiple Failed Attempts', N'Phát hiện 5 giao dịch thất bại liên tiếp từ IP lạ 113.190.12.4', N'High', N'Investigating', 1, SYSDATETIME(), SYSDATETIME()),
    (@PayID, N'High Value Transaction', N'Giao dịch thanh toán giá trị bất thường 50.000.000đ qua thẻ Visa quốc tế', N'Medium', N'Open', NULL, NULL, DATEADD(hour, -2, SYSDATETIME())),
    (@PayID, N'Unusual Location IP', N'Khách hàng đăng nhập từ nước ngoài (Nga) đặt tour tại Việt Nam', N'Low', N'Resolved', 1, SYSDATETIME(), DATEADD(day, -1, SYSDATETIME()));
END
"@
$cmd.ExecuteNonQuery()

# 5. Insert FinancialAuditLog
$cmd.CommandText = @"
INSERT INTO FinancialAuditLog (EntityType, EntityID, Action, OldValues, NewValues, PerformedBy, CreatedAt)
VALUES 
(N'Payment', 1, N'UPDATE_STATUS', N'Status: Pending', N'Status: Success', 1, DATEADD(hour, -5, SYSDATETIME())),
(N'Refund', 1, N'APPROVE_REFUND', N'Status: Pending', N'Status: Completed | Amount: 1.500.000đ', 1, DATEADD(hour, -3, SYSDATETIME())),
(N'Coupon', 2, N'CREATE_PROMO', N'None', N'Code: SUMMER2026 | Discount: 15%', 1, DATEADD(day, -2, SYSDATETIME())),
(N'Booking', 3, N'CANCEL_BOOKING', N'Status: Confirmed', N'Status: Cancelled | Reason: Khách thay đổi lịch', 1, DATEADD(day, -1, SYSDATETIME()));
"@
$cmd.ExecuteNonQuery()

# 6. Insert TourOperationLog
$cmd.CommandText = @"
DECLARE @SchID INT;
SELECT TOP 1 @SchID = ScheduleID FROM TourSchedule;
IF @SchID IS NOT NULL BEGIN
    INSERT INTO TourOperationLog (ScheduleID, Activity, OperatedBy, CreatedAt)
    VALUES 
    (@SchID, N'Khởi hành tour đúng giờ tại điểm đón Nhà Hát Lớn', 1, DATEADD(hour, -6, SYSDATETIME())),
    (@SchID, N'Điểm danh hoàn tất: 18/20 khách có mặt', 1, DATEADD(hour, -5, SYSDATETIME())),
    (@SchID, N'Cập nhật sự cố: Thời tiết mưa nhẹ, đoàn chuyển sang tham quan bảo tàng', 1, DATEADD(hour, -2, SYSDATETIME()));
END
"@
$cmd.ExecuteNonQuery()

$conn.Close()
Write-Host "CLEAN UNICODE DATA INSERTED SUCCESSFULLY"
