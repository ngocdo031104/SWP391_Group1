USE TourBuddyDB;
GO

-- SHA-256 hash of '12345678'
DECLARE @hashed_pass NVARCHAR(512) = 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f';

-- 1. Guide 1: Nguyễn Văn Hướng Dẫn
INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt, UpdatedAt)
VALUES (3, 'guide1@tourbuddy.com', @hashed_pass, N'Nguyễn Văn Hướng Dẫn', '0912345678', 1, 1, SYSDATETIME(), SYSDATETIME());
DECLARE @UserID1 INT = SCOPE_IDENTITY();

INSERT INTO UserProfile (UserID, AvatarURL, Biography, DateOfBirth, Gender, Address, TravelInterests, UpdatedAt)
VALUES (@UserID1, 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', N'Kinh nghiệm 5 năm dẫn tour mạo hiểm.', '1995-05-15', 'Male', N'Hà Nội', N'Trekking, Leo núi', SYSDATETIME());

INSERT INTO GuideProfile (UserID, YearsOfExperience, TotalToursLed, Rating, Bio, Specialization, Languages, Certifications, EmergencyPhone, IsActive, CreatedAt, UpdatedAt)
VALUES (@UserID1, 5, 12, 4.8, N'HDV chuyên nghiệp về trekking Sapa và Hà Giang.', N'Trekking, Khám phá rừng núi', N'Tiếng Việt, Tiếng Anh', N'Chứng chỉ HDV Quốc tế', '0912345678', 1, SYSDATETIME(), SYSDATETIME());


-- 2. Guide 2: Trần Thị Dẫn Đường
INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt, UpdatedAt)
VALUES (3, 'guide2@tourbuddy.com', @hashed_pass, N'Trần Thị Dẫn Đường', '0987654321', 1, 1, SYSDATETIME(), SYSDATETIME());
DECLARE @UserID2 INT = SCOPE_IDENTITY();

INSERT INTO UserProfile (UserID, AvatarURL, Biography, DateOfBirth, Gender, Address, TravelInterests, UpdatedAt)
VALUES (@UserID2, 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150', N'Đam mê lịch sử và văn hóa cố đô.', '1997-09-20', 'Female', N'Huế', N'Lịch sử, Ẩm thực', SYSDATETIME());

INSERT INTO GuideProfile (UserID, YearsOfExperience, TotalToursLed, Rating, Bio, Specialization, Languages, Certifications, EmergencyPhone, IsActive, CreatedAt, UpdatedAt)
VALUES (@UserID2, 3, 8, 4.7, N'HDV chuyên tuyến văn hóa Huế - Hội An.', N'Văn hóa, Lịch sử, Ẩm thực', N'Tiếng Việt, Tiếng Trung', N'Chứng chỉ HDV Nội địa', '0987654321', 1, SYSDATETIME(), SYSDATETIME());


-- 3. Guide 3: Lê Hoàng Phượt
INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt, UpdatedAt)
VALUES (3, 'guide3@tourbuddy.com', @hashed_pass, N'Lê Hoàng Phượt', '0905123456', 1, 1, SYSDATETIME(), SYSDATETIME());
DECLARE @UserID3 INT = SCOPE_IDENTITY();

INSERT INTO UserProfile (UserID, AvatarURL, Biography, DateOfBirth, Gender, Address, TravelInterests, UpdatedAt)
VALUES (@UserID3, 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', N'Thích khám phá đại dương và các hòn đảo hoang sơ.', '1993-02-10', 'Male', N'Đà Nẵng', N'Lặn biển, Khám phá đảo', SYSDATETIME());

INSERT INTO GuideProfile (UserID, YearsOfExperience, TotalToursLed, Rating, Bio, Specialization, Languages, Certifications, EmergencyPhone, IsActive, CreatedAt, UpdatedAt)
VALUES (@UserID3, 7, 25, 4.9, N'HDV chuyên nghiệp tuyến biển đảo Nha Trang, Phú Quốc.', N'Lặn biển, Sinh tồn', N'Tiếng Việt, Tiếng Anh, Tiếng Nhật', N'Chứng chỉ HDV Quốc tế, Cứu hộ bờ biển', '0905123456', 1, SYSDATETIME(), SYSDATETIME());

PRINT N'Chèn 3 hướng dẫn viên thành công!';
