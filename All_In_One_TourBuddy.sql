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
-- ============================================================
-- TourBuddyDB - Consolidated Migration & Seed Data Script
-- Includes all schema fixes, tables migrations, account setup,
-- and analytics seeds for different tour categories.
-- ============================================================

USE TourBuddyDB;
GO

-- ============================================================
-- 1. CLEAN & REBUILD PERMISSION SYSTEM (RBAC)
-- ============================================================
PRINT '1. Rebuilding RBAC Tables...';
IF OBJECT_ID('dbo.Role_Permission', 'U') IS NOT NULL DROP TABLE dbo.Role_Permission;
IF OBJECT_ID('dbo.RolePermission', 'U') IS NOT NULL DROP TABLE dbo.RolePermission;
IF OBJECT_ID('dbo.Permission', 'U') IS NOT NULL DROP TABLE dbo.Permission;
IF OBJECT_ID('dbo.Audit_Log', 'U') IS NOT NULL DROP TABLE dbo.Audit_Log;
GO

-- Alter Role table (IsSystemRole column)
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'IsSystemRole' AND Object_ID = Object_ID(N'Role'))
BEGIN
    ALTER TABLE Role ADD IsSystemRole BIT DEFAULT 0;
END
GO
UPDATE Role SET IsSystemRole = 1 WHERE RoleName IN ('Admin', 'Customer');
GO

-- Recreate Permission Table
CREATE TABLE Permission (
    PermissionID INT IDENTITY(1,1) PRIMARY KEY,
    ModuleName NVARCHAR(100) NOT NULL,
    Action NVARCHAR(50) NOT NULL,
    Description NVARCHAR(255),
    IsCritical BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT SYSDATETIME()
);
GO

-- Recreate Role_Permission Table
CREATE TABLE Role_Permission (
    RoleID INT FOREIGN KEY REFERENCES Role(RoleID) ON DELETE CASCADE,
    PermissionID INT FOREIGN KEY REFERENCES Permission(PermissionID) ON DELETE CASCADE,
    PRIMARY KEY (RoleID, PermissionID)
);
GO

-- Recreate Audit_Log Table
CREATE TABLE Audit_Log (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    AdminID INT FOREIGN KEY REFERENCES [User](UserID) ON DELETE NO ACTION,
    ActionType NVARCHAR(100),
    TargetRoleID INT NULL,
    Details NVARCHAR(500),
    CreatedAt DATETIME DEFAULT SYSDATETIME()
);
GO

-- Insert Seed Data for Permissions
INSERT INTO Permission (ModuleName, Action, Description, IsCritical) VALUES
('User Management', 'Read', N'Xem danh sách người dùng', 0),
('User Management', 'Create', N'Tạo người dùng mới', 0),
('User Management', 'Update', N'Cập nhật người dùng', 0),
('User Management', 'Delete', N'Xóa người dùng', 1),
('Tour Management', 'Read', N'Xem danh sách tour', 0),
('Tour Management', 'Create', N'Tạo tour mới', 0),
('Tour Management', 'Update', N'Cập nhật tour', 0),
('Tour Management', 'Delete', N'Xóa tour', 0),
('Booking Management', 'Read', N'Xem danh sách booking', 0),
('Booking Management', 'Create', N'Tạo booking mới', 0),
('Booking Management', 'Update', N'Sửa trạng thái booking', 0),
('Booking Management', 'Delete', N'Hủy booking', 0),
('Booking Management', 'Approve', N'Duyệt booking', 0),
('System Settings', 'Read', N'Xem cấu hình', 1),
('System Settings', 'Update', N'Cập nhật cấu hình', 1),
('Role Management', 'Read', N'Xem danh sách vai trò', 1),
('Role Management', 'Create', N'Tạo vai trò', 1),
('Role Management', 'Update', N'Sửa vai trò', 1),
('Role Management', 'Delete', N'Xóa vai trò', 1);
GO

-- Assign all permissions to Super Admin (RoleID = 1)
INSERT INTO Role_Permission (RoleID, PermissionID)
SELECT 1, PermissionID FROM Permission;
GO

-- Assign basic permissions to Staff (RoleID = 2)
INSERT INTO Role_Permission (RoleID, PermissionID)
SELECT 2, PermissionID FROM Permission 
WHERE (ModuleName = 'Tour Management' AND Action IN ('Read', 'Create', 'Update'))
   OR (ModuleName = 'Booking Management' AND Action IN ('Read', 'Update'));
GO

-- Assign basic permissions to Guide (RoleID = 3)
INSERT INTO Role_Permission (RoleID, PermissionID)
SELECT 3, PermissionID FROM Permission 
WHERE ModuleName = 'Tour Management' AND Action = 'Read';
GO


-- ============================================================
-- 2. CREATE REMAINING SCHEMA TABLES (MIGRATIONS V3, V4, V5, NOTIFICATION)
-- ============================================================
PRINT '2. Migrating Schema Tables...';

-- Create BuddyRequest table (Migration v3)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BuddyRequest]') AND type in (N'U'))
BEGIN
    CREATE TABLE BuddyRequest (
        RequestId INT IDENTITY(1,1) PRIMARY KEY,
        SenderId INT FOREIGN KEY REFERENCES [User](UserID) ON DELETE NO ACTION,
        ReceiverId INT FOREIGN KEY REFERENCES [User](UserID) ON DELETE NO ACTION,
        Status INT DEFAULT 0, -- 0: Pending, 1: Accepted, 2: Rejected
        CreatedAt DATETIME DEFAULT SYSDATETIME(),
        UpdatedAt DATETIME DEFAULT SYSDATETIME(),
        CONSTRAINT UQ_BuddyRequest UNIQUE (SenderId, ReceiverId)
    );
END
GO

-- Create TravelPreference table (Migration v4)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TravelPreference')
BEGIN
    CREATE TABLE TravelPreference (
        PreferenceId INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT FOREIGN KEY REFERENCES [User](UserID) ON DELETE CASCADE,
        Destination NVARCHAR(255),
        StartDate DATE,
        EndDate DATE,
        TravelStyle NVARCHAR(100),
        MinBudget DECIMAL(18,2),
        MaxBudget DECIMAL(18,2),
        TargetAgeMin INT,
        TargetAgeMax INT,
        TargetGender NVARCHAR(20),
        Languages NVARCHAR(255),
        Tags NVARCHAR(500),
        CreatedAt DATETIME DEFAULT SYSDATETIME(),
        UpdatedAt DATETIME DEFAULT SYSDATETIME(),
        CONSTRAINT UQ_TravelPreference_User UNIQUE (UserId)
    );
END
GO

-- Add extra columns to TravelPreference (Migration v5)
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'TripDuration' AND Object_ID = Object_ID(N'TravelPreference'))
BEGIN
    ALTER TABLE TravelPreference ADD TripDuration NVARCHAR(50) NULL;
END
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'TravelFrequency' AND Object_ID = Object_ID(N'TravelPreference'))
BEGIN
    ALTER TABLE TravelPreference ADD TravelFrequency NVARCHAR(50) NULL;
END
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'ActivityPreferences' AND Object_ID = Object_ID(N'TravelPreference'))
BEGIN
    ALTER TABLE TravelPreference ADD ActivityPreferences NVARCHAR(500) NULL;
END
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'SmokingPreference' AND Object_ID = Object_ID(N'TravelPreference'))
BEGIN
    ALTER TABLE TravelPreference ADD SmokingPreference NVARCHAR(50) NULL;
END
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'DrinkingPreference' AND Object_ID = Object_ID(N'TravelPreference'))
BEGIN
    ALTER TABLE TravelPreference ADD DrinkingPreference NVARCHAR(50) NULL;
END
GO

-- Create Notifications table (notification.sql)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Notifications' and xtype='U')
BEGIN
    CREATE TABLE Notifications (
        notificationId INT IDENTITY(1,1) PRIMARY KEY,
        userId INT FOREIGN KEY REFERENCES [User](userId),
        senderId INT FOREIGN KEY REFERENCES [User](userId) NULL,
        title NVARCHAR(255) NOT NULL,
        content NVARCHAR(MAX) NOT NULL,
        channel VARCHAR(50) NOT NULL, -- 'SYSTEM', 'EMAIL', 'BOTH'
        category VARCHAR(50) DEFAULT 'System Announcement',
        isRead BIT DEFAULT 0,
        createdAt DATETIME DEFAULT GETDATE(),
        scheduledAt DATETIME NULL,
        status VARCHAR(50) DEFAULT 'SENT' -- 'SCHEDULED', 'SENT', 'FAILED'
    );
END
GO

-- Alter Tour table to support soft delete (IsDeleted)
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'IsDeleted' AND Object_ID = Object_ID(N'Tour'))
BEGIN
    ALTER TABLE Tour ADD IsDeleted BIT NOT NULL DEFAULT 0;
END
GO

-- Alter Coupon table to support MaxDiscountAmount
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'MaxDiscountAmount' AND Object_ID = Object_ID(N'Coupon'))
BEGIN
    ALTER TABLE Coupon ADD MaxDiscountAmount DECIMAL(18, 2) NULL;
END
GO


-- ============================================================
-- 3. SETUP & SEED TARGET ACCOUNTS
-- ============================================================
PRINT '3. Seeding Target Users and Roles...';

DECLARE @hashed_pass NVARCHAR(512) = 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f'; -- SHA-256 of '12345678'

-- 1. sonkbgnh@gmail.com -> Admin (RoleID = 1)
IF EXISTS (SELECT 1 FROM [User] WHERE Email = 'sonkbgnh@gmail.com')
BEGIN
    UPDATE [User] SET RoleID = 1 WHERE Email = 'sonkbgnh@gmail.com';
END
ELSE
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt, UpdatedAt)
    VALUES (1, 'sonkbgnh@gmail.com', @hashed_pass, N'Admin Son KB', '0911111111', 1, 1, SYSDATETIME(), SYSDATETIME());
END

-- 2. sondqhe186525@fpt.edu.vn -> Accountant (RoleID = 5)
IF EXISTS (SELECT 1 FROM [User] WHERE Email = 'sondqhe186525@fpt.edu.vn')
BEGIN
    UPDATE [User] SET RoleID = 5 WHERE Email = 'sondqhe186525@fpt.edu.vn';
END
ELSE
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt, UpdatedAt)
    VALUES (5, 'sondqhe186525@fpt.edu.vn', @hashed_pass, N'Accountant Son DQ', '0922222222', 1, 1, SYSDATETIME(), SYSDATETIME());
END

-- 3. sonkbgnh112@gmail.com -> Customer (RoleID = 4)
IF EXISTS (SELECT 1 FROM [User] WHERE Email = 'sonkbgnh112@gmail.com')
BEGIN
    UPDATE [User] SET RoleID = 4 WHERE Email = 'sonkbgnh112@gmail.com';
END
ELSE
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt, UpdatedAt)
    VALUES (4, 'sonkbgnh112@gmail.com', @hashed_pass, N'Customer Son KB 112', '0933333333', 1, 1, SYSDATETIME(), SYSDATETIME());
END

-- 4. test_rbac_data.sql Users
IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'admin.test@tourbuddy.com')
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt)
    VALUES (1, 'admin.test@tourbuddy.com', @hashed_pass, N'Super Admin Test', '0901234567', 1, 1, SYSDATETIME());

IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'staff.test@tourbuddy.com')
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt)
    VALUES (2, 'staff.test@tourbuddy.com', @hashed_pass, N'Nhân viên điều hành Test', '0902345678', 1, 1, SYSDATETIME());

IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'guide.test@tourbuddy.com')
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt)
    VALUES (3, 'guide.test@tourbuddy.com', @hashed_pass, N'Hướng dẫn viên Test', '0903456789', 1, 1, SYSDATETIME());

-- 5. Seed 3 Guides (from add_guides.sql)
IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'guide1@tourbuddy.com')
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt, UpdatedAt)
    VALUES (3, 'guide1@tourbuddy.com', @hashed_pass, N'Nguyễn Văn Hướng Dẫn', '0912345678', 1, 1, SYSDATETIME(), SYSDATETIME());
    DECLARE @G1 INT = SCOPE_IDENTITY();

    INSERT INTO UserProfile (UserID, AvatarURL, Biography, DateOfBirth, Gender, Address, TravelInterests, UpdatedAt)
    VALUES (@G1, 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', N'Kinh nghiệm 5 năm dẫn tour mạo hiểm.', '1995-05-15', 'Male', N'Hà Nội', N'Trekking, Leo núi', SYSDATETIME());

    INSERT INTO GuideProfile (UserID, YearsOfExperience, TotalToursLed, Rating, Bio, Specialization, Languages, Certifications, EmergencyPhone, IsActive, CreatedAt, UpdatedAt)
    VALUES (@G1, 5, 12, 4.8, N'HDV chuyên nghiệp về trekking Sapa và Hà Giang.', N'Trekking, Khám phá rừng núi', N'Tiếng Việt, Tiếng Anh', N'Chứng chỉ HDV Quốc tế', '0912345678', 1, SYSDATETIME(), SYSDATETIME());
END

IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'guide2@tourbuddy.com')
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt, UpdatedAt)
    VALUES (3, 'guide2@tourbuddy.com', @hashed_pass, N'Trần Thị Dẫn Đường', '0987654321', 1, 1, SYSDATETIME(), SYSDATETIME());
    DECLARE @G2 INT = SCOPE_IDENTITY();

    INSERT INTO UserProfile (UserID, AvatarURL, Biography, DateOfBirth, Gender, Address, TravelInterests, UpdatedAt)
    VALUES (@G2, 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150', N'Đam mê lịch sử và văn hóa cố đô.', '1997-09-20', 'Female', N'Huế', N'Lịch sử, Ẩm thực', SYSDATETIME());

    INSERT INTO GuideProfile (UserID, YearsOfExperience, TotalToursLed, Rating, Bio, Specialization, Languages, Certifications, EmergencyPhone, IsActive, CreatedAt, UpdatedAt)
    VALUES (@G2, 3, 8, 4.7, N'HDV chuyên tuyến văn hóa Huế - Hội An.', N'Văn hóa, Lịch sử, Ẩm thực', N'Tiếng Việt, Tiếng Trung', N'Chứng chỉ HDV Nội địa', '0987654321', 1, SYSDATETIME(), SYSDATETIME());
END

IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'guide3@tourbuddy.com')
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt, UpdatedAt)
    VALUES (3, 'guide3@tourbuddy.com', @hashed_pass, N'Lê Hoàng Phượt', '0905123456', 1, 1, SYSDATETIME(), SYSDATETIME());
    DECLARE @G3 INT = SCOPE_IDENTITY();

    INSERT INTO UserProfile (UserID, AvatarURL, Biography, DateOfBirth, Gender, Address, TravelInterests, UpdatedAt)
    VALUES (@G3, 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', N'Thích khám phá đại dương và các hòn đảo hoang sơ.', '1993-02-10', 'Male', N'Đà Nẵng', N'Lặn biển, Khám phá đảo', SYSDATETIME());

    INSERT INTO GuideProfile (UserID, YearsOfExperience, TotalToursLed, Rating, Bio, Specialization, Languages, Certifications, EmergencyPhone, IsActive, CreatedAt, UpdatedAt)
    VALUES (@G3, 7, 25, 4.9, N'HDV chuyên nghiệp tuyến biển đảo Nha Trang, Phú Quốc.', N'Lặn biển, Sinh tồn', N'Tiếng Việt, Tiếng Anh, Tiếng Nhật', N'Chứng chỉ HDV Quốc tế, Cứu hộ bờ biển', '0905123456', 1, SYSDATETIME(), SYSDATETIME());
END
GO


-- ============================================================
-- 4. SEED SCHEDULES & REVENUE DATA FOR DIVERSE CATEGORIES
-- ============================================================
PRINT '4. Seeding Schedules and Bookings...';

-- Clear old schedules and dependencies for clean seeding
DELETE FROM Review;
DELETE FROM BookingParticipant;
DELETE FROM Booking;
DELETE FROM TourSchedule;
GO

-- Seed Schedules for Tours 1-5
-- Tour 1 (Hạ Long - Cat 1)
INSERT INTO TourSchedule (TourID, DepartureDate, ReturnDate, TotalSeats, AvailableSeats, PriceAdult, PriceChild, PriceInfant, Status, TourStatus)
VALUES 
(1, '2026-07-10', '2026-07-12', 20, 15, 3900000, 1950000, 500000, 'Open', 'Scheduled'),
(1, '2026-08-15', '2026-08-17', 20, 20, 3900000, 1950000, 500000, 'Open', 'Scheduled');

-- Tour 2 (Đà Nẵng - Cat 1)
INSERT INTO TourSchedule (TourID, DepartureDate, ReturnDate, TotalSeats, AvailableSeats, PriceAdult, PriceChild, PriceInfant, Status, TourStatus)
VALUES (2, '2026-07-20', '2026-07-24', 25, 22, 4800000, 2400000, 500000, 'Open', 'Scheduled');

-- Tour 3 (Fansipan - Cat 2: Núi & Rừng)
INSERT INTO TourSchedule (TourID, DepartureDate, ReturnDate, TotalSeats, AvailableSeats, PriceAdult, PriceChild, PriceInfant, Status, TourStatus)
VALUES (3, '2026-07-05', '2026-07-07', 15, 13, 2800000, 1400000, 500000, 'Open', 'Scheduled');

-- Tour 4 (Huế - Cat 3: Văn hóa & Di sản)
INSERT INTO TourSchedule (TourID, DepartureDate, ReturnDate, TotalSeats, AvailableSeats, PriceAdult, PriceChild, PriceInfant, Status, TourStatus)
VALUES (4, '2026-07-12', '2026-07-15', 20, 17, 3100000, 1550000, 500000, 'Open', 'Scheduled');

-- Tour 5 (Hà Nội City Tour - Cat 4: City Tour)
INSERT INTO TourSchedule (TourID, DepartureDate, ReturnDate, TotalSeats, AvailableSeats, PriceAdult, PriceChild, PriceInfant, Status, TourStatus)
VALUES (5, '2026-07-01', '2026-07-01', 30, 26, 850000, 425000, 200000, 'Open', 'Scheduled');
GO

-- Seed Customers
IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'tuan.tran@gmail.com')
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified)
    VALUES (4, 'tuan.tran@gmail.com', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', N'Trần Anh Tuấn', '0901234567', 1, 1);
END
IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'thu.le@gmail.com')
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified)
    VALUES (4, 'thu.le@gmail.com', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', N'Lê Minh Thư', '0912345678', 1, 1);
END
IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'hoang.pham@gmail.com')
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified)
    VALUES (4, 'hoang.pham@gmail.com', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', N'Phạm Minh Hoàng', '0923456789', 1, 1);
END
GO

-- Fetch IDs for inserting Bookings
DECLARE @Cust1 INT, @Cust2 INT, @Cust3 INT;
SELECT @Cust1 = UserID FROM [User] WHERE Email = 'tuan.tran@gmail.com';
SELECT @Cust2 = UserID FROM [User] WHERE Email = 'thu.le@gmail.com';
SELECT @Cust3 = UserID FROM [User] WHERE Email = 'hoang.pham@gmail.com';

DECLARE @Sch1 INT, @Sch2 INT, @Sch3 INT, @Sch4 INT, @Sch5 INT, @Sch6 INT;
SELECT @Sch1 = ScheduleID FROM TourSchedule WHERE TourID = 1 AND DepartureDate = '2026-07-10';
SELECT @Sch2 = ScheduleID FROM TourSchedule WHERE TourID = 1 AND DepartureDate = '2026-08-15';
SELECT @Sch3 = ScheduleID FROM TourSchedule WHERE TourID = 2 AND DepartureDate = '2026-07-20';
SELECT @Sch4 = ScheduleID FROM TourSchedule WHERE TourID = 3 AND DepartureDate = '2026-07-05';
SELECT @Sch5 = ScheduleID FROM TourSchedule WHERE TourID = 4 AND DepartureDate = '2026-07-12';
SELECT @Sch6 = ScheduleID FROM TourSchedule WHERE TourID = 5 AND DepartureDate = '2026-07-01';

-- Insert Bookings (Beach & Island Category - Tour 1 & 2)
INSERT INTO Booking (BookingCode, ScheduleID, CustomerID, NumParticipants, BaseAmount, VATAmount, DiscountAmount, TotalAmount, Status, Notes, CreatedAt, UpdatedAt) VALUES
('BK001', @Sch1, @Cust1, 2, 7560000.00, 0, 0, 7560000.00, 'Completed', 'Seeded booking', SYSDATETIME(), SYSDATETIME()),
('BK002', @Sch1, @Cust2, 1, 3780000.00, 0, 0, 3780000.00, 'Completed', 'Seeded booking', SYSDATETIME(), SYSDATETIME()),
('BK003', @Sch2, @Cust2, 2, 9072000.00, 0, 0, 9072000.00, 'Completed', 'Seeded booking', SYSDATETIME(), SYSDATETIME()),
('BK004', @Sch3, @Cust3, 1, 3024000.00, 0, 0, 3024000.00, 'Completed', 'Seeded booking', SYSDATETIME(), SYSDATETIME());

-- Insert Bookings (Mountain & Forest Category - Tour 3)
INSERT INTO Booking (BookingCode, ScheduleID, CustomerID, NumParticipants, BaseAmount, VATAmount, DiscountAmount, TotalAmount, Status, Notes, CreatedAt, UpdatedAt) VALUES
('BK005', @Sch4, @Cust1, 2, 5600000.00, 0, 0, 5600000.00, 'Completed', 'Seeded mountain tour booking', SYSDATETIME(), SYSDATETIME());

-- Insert Bookings (Culture & Heritage Category - Tour 4)
INSERT INTO Booking (BookingCode, ScheduleID, CustomerID, NumParticipants, BaseAmount, VATAmount, DiscountAmount, TotalAmount, Status, Notes, CreatedAt, UpdatedAt) VALUES
('BK006', @Sch5, @Cust2, 3, 9300000.00, 0, 0, 9300000.00, 'Completed', 'Seeded cultural tour booking', SYSDATETIME(), SYSDATETIME());

-- Insert Bookings (City Tour Category - Tour 5)
INSERT INTO Booking (BookingCode, ScheduleID, CustomerID, NumParticipants, BaseAmount, VATAmount, DiscountAmount, TotalAmount, Status, Notes, CreatedAt, UpdatedAt) VALUES
('BK007', @Sch6, @Cust3, 4, 3400000.00, 0, 0, 3400000.00, 'Completed', 'Seeded city tour booking', SYSDATETIME(), SYSDATETIME());
GO

PRINT 'All Migrations and Seeds successfully executed!';
GO
-- SQL Migration: Add Tables for Wishlist, Newsletter, and Contact Message
-- Target DB: TourBuddyDB
-- Run this script to add these new tables without losing any existing data.

-- 1. Create table for Contact Message (Form Contact / Liên Hệ)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ContactMessage')
BEGIN
    CREATE TABLE ContactMessage (
        MessageID INT IDENTITY(1,1) PRIMARY KEY,
        FullName NVARCHAR(100) NOT NULL,
        Email NVARCHAR(100) NOT NULL,
        Subject NVARCHAR(150) NULL,
        MessageText NVARCHAR(MAX) NOT NULL,
        IsRead BIT DEFAULT 0,
        CreatedAt DATETIME2 DEFAULT SYSDATETIME()
    );
    PRINT 'Created table: ContactMessage';
END
ELSE
BEGIN
    PRINT 'Table ContactMessage already exists.';
END

-- 2. Create table for Newsletter Subscriptions (Đăng ký nhận khuyến mãi ở Footer)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'NewsletterSubscription')
BEGIN
    CREATE TABLE NewsletterSubscription (
        SubscriptionID INT IDENTITY(1,1) PRIMARY KEY,
        Email NVARCHAR(150) UNIQUE NOT NULL,
        IsActive BIT DEFAULT 1,
        SubscribedAt DATETIME2 DEFAULT SYSDATETIME()
    );
    PRINT 'Created table: NewsletterSubscription';
END
ELSE
BEGIN
    PRINT 'Table NewsletterSubscription already exists.';
END

-- 3. Create table for Wishlist (Tour Yêu Thích)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Wishlist')
BEGIN
    CREATE TABLE Wishlist (
        WishlistID INT IDENTITY(1,1) PRIMARY KEY,
        UserID INT NOT NULL,
        TourID INT NOT NULL,
        CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
        CONSTRAINT FK_Wishlist_User FOREIGN KEY (UserID) REFERENCES [User](UserID) ON DELETE CASCADE,
        CONSTRAINT FK_Wishlist_Tour FOREIGN KEY (TourID) REFERENCES Tour(TourID) ON DELETE CASCADE,
        CONSTRAINT UC_User_Tour UNIQUE(UserID, TourID)
    );
    PRINT 'Created table: Wishlist';
END
ELSE
BEGIN
    PRINT 'Table Wishlist already exists.';
END
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Notifications' and xtype='U')
BEGIN
    CREATE TABLE Notifications (
        notificationId INT IDENTITY(1,1) PRIMARY KEY,
        userId INT FOREIGN KEY REFERENCES [User](userId),
        senderId INT FOREIGN KEY REFERENCES [User](userId) NULL,
        title NVARCHAR(255) NOT NULL,
        content NVARCHAR(MAX) NOT NULL,
        channel VARCHAR(50) NOT NULL, -- 'SYSTEM', 'EMAIL', 'BOTH'
        category VARCHAR(50) DEFAULT 'System Announcement',
        isRead BIT DEFAULT 0,
        createdAt DATETIME DEFAULT GETDATE(),
        scheduledAt DATETIME NULL,
        status VARCHAR(50) DEFAULT 'SENT' -- 'SCHEDULED', 'SENT', 'FAILED'
    );
END
GO
-- ============================================================
-- TourBuddy - Online Tour Booking System
-- Database Script for Microsoft SQL Server 2022
-- SWP391 - FPT University - Group 1
-- ============================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'TourBuddyDB')
BEGIN
    ALTER DATABASE TourBuddyDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TourBuddyDB;
END
GO

CREATE DATABASE TourBuddyDB
    COLLATE Vietnamese_CI_AS;
GO

USE TourBuddyDB;
GO

-- ============================================================
-- 1. ROLE & PERMISSION MANAGEMENT
-- ============================================================

CREATE TABLE Role (
    RoleID      INT IDENTITY(1,1) PRIMARY KEY,
    RoleName    NVARCHAR(50)  NOT NULL UNIQUE,   -- Customer, Guide, Staff, Admin, Accountant
    Description NVARCHAR(255) NULL,
    IsActive    BIT           NOT NULL DEFAULT 1,
    CreatedAt   DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE Permission (
    PermissionID   INT IDENTITY(1,1) PRIMARY KEY,
    PermissionName NVARCHAR(100) NOT NULL UNIQUE, -- e.g. BOOKING_CREATE, TOUR_MANAGE
    Module         NVARCHAR(100) NOT NULL,
    Description    NVARCHAR(255) NULL,
    CreatedAt      DATETIME2    NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE RolePermission (
    RolePermissionID INT IDENTITY(1,1) PRIMARY KEY,
    RoleID           INT NOT NULL REFERENCES Role(RoleID),
    PermissionID     INT NOT NULL REFERENCES Permission(PermissionID),
    GrantedAt        DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    GrantedBy        INT NULL,
    CONSTRAINT UQ_RolePermission UNIQUE (RoleID, PermissionID)
);
GO

-- ============================================================
-- 2. USER MANAGEMENT
-- ============================================================

CREATE TABLE [User] (
    UserID        INT IDENTITY(1,1) PRIMARY KEY,
    RoleID        INT           NOT NULL REFERENCES Role(RoleID),
    Email         NVARCHAR(150) NOT NULL UNIQUE,
    PasswordHash  NVARCHAR(512) NOT NULL,
    FullName      NVARCHAR(100) NOT NULL,
    PhoneNumber   NVARCHAR(15)  NULL,
    IsActive      BIT           NOT NULL DEFAULT 1,
    IsVerified    BIT           NOT NULL DEFAULT 0,
    CreatedAt     DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt     DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    LastLoginAt   DATETIME2     NULL
);
GO

CREATE TABLE UserProfile (
    ProfileID      INT IDENTITY(1,1) PRIMARY KEY,
    UserID         INT           NOT NULL UNIQUE REFERENCES [User](UserID),
    AvatarURL      NVARCHAR(500) NULL,
    Biography      NVARCHAR(MAX) NULL,
    DateOfBirth    DATE          NULL,
    Gender         NVARCHAR(10)  NULL CHECK (Gender IN ('Male', 'Female', 'Other')),
    Address        NVARCHAR(255) NULL,
    TravelInterests NVARCHAR(500) NULL,   -- JSON or comma-separated tags
    UpdatedAt      DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE PasswordRecovery (
    RecoveryID    INT IDENTITY(1,1) PRIMARY KEY,
    UserID        INT           NOT NULL REFERENCES [User](UserID),
    Token         NVARCHAR(512) NOT NULL UNIQUE,
    IsUsed        BIT           NOT NULL DEFAULT 0,
    ExpiresAt     DATETIME2     NOT NULL,
    CreatedAt     DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE AccountActivityLog (
    LogID      INT IDENTITY(1,1) PRIMARY KEY,
    UserID     INT           NOT NULL REFERENCES [User](UserID),
    Action     NVARCHAR(100) NOT NULL,  -- LOGIN, LOGOUT, PASSWORD_CHANGE, etc.
    IPAddress  NVARCHAR(45)  NULL,
    DeviceInfo NVARCHAR(255) NULL,
    CreatedAt  DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================================
-- 3. TOUR MANAGEMENT
-- ============================================================

CREATE TABLE TourCategory (
    CategoryID   INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL UNIQUE,
    Description  NVARCHAR(255) NULL,
    IsActive     BIT           NOT NULL DEFAULT 1
);
GO

CREATE TABLE Tour (
    TourID          INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID      INT            NOT NULL REFERENCES TourCategory(CategoryID),
    TourName        NVARCHAR(200)  NOT NULL,
    Description     NVARCHAR(MAX)  NULL,
    Destination     NVARCHAR(200)  NOT NULL,
    DurationDays    INT            NOT NULL CHECK (DurationDays > 0),
    Itinerary       NVARCHAR(MAX)  NULL,        -- JSON or rich text
    DifficultyLevel NVARCHAR(20)   NULL CHECK (DifficultyLevel IN ('Easy','Medium','Hard')),
    BasePrice       DECIMAL(18,2)  NOT NULL CHECK (BasePrice >= 0),
    MaxParticipants INT            NOT NULL DEFAULT 20,
    Status          NVARCHAR(20)   NOT NULL DEFAULT 'Active'
                        CHECK (Status IN ('Active','Inactive','Draft')),
    IsFeatured      BIT            NOT NULL DEFAULT 0,
    CreatedBy       INT            NULL REFERENCES [User](UserID),
    CreatedAt       DATETIME2      NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt       DATETIME2      NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE TourSchedule (
    ScheduleID      INT IDENTITY(1,1) PRIMARY KEY,
    TourID          INT           NOT NULL REFERENCES Tour(TourID),
    DepartureDate   DATE          NOT NULL,
    ReturnDate      DATE          NOT NULL,
    TotalSeats      INT           NOT NULL CHECK (TotalSeats > 0),
    AvailableSeats  INT           NOT NULL,
    PriceAdult      DECIMAL(18,2) NOT NULL,
    PriceChild      DECIMAL(18,2) NOT NULL DEFAULT 0,
    PriceInfant     DECIMAL(18,2) NOT NULL DEFAULT 0,
    Transportation  NVARCHAR(100) NULL,
    Status          NVARCHAR(20)  NOT NULL DEFAULT 'Open'
                        CHECK (Status IN ('Open','Full','Closed','Cancelled')),
    CreatedAt       DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT CHK_AvailableSeats CHECK (AvailableSeats <= TotalSeats AND AvailableSeats >= 0),
    CONSTRAINT CHK_ReturnAfterDepart CHECK (ReturnDate >= DepartureDate)
);
GO

CREATE TABLE TourMedia (
    MediaID     INT IDENTITY(1,1) PRIMARY KEY,
    TourID      INT           NOT NULL REFERENCES Tour(TourID),
    MediaURL    NVARCHAR(500) NOT NULL,
    MediaType   NVARCHAR(20)  NOT NULL DEFAULT 'Image'
                    CHECK (MediaType IN ('Image','Video')),
    Caption     NVARCHAR(255) NULL,
    SortOrder   INT           NOT NULL DEFAULT 0,
    IsVisible   BIT           NOT NULL DEFAULT 1,
    UploadedBy  INT           NULL REFERENCES [User](UserID),
    UploadedAt  DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE TourStatus (
    TourStatusID  INT IDENTITY(1,1) PRIMARY KEY,
    ScheduleID    INT           NOT NULL REFERENCES TourSchedule(ScheduleID),
    Status        NVARCHAR(50)  NOT NULL, -- Preparing, InProgress, Completed, Cancelled
    Notes         NVARCHAR(500) NULL,
    UpdatedBy     INT           NULL REFERENCES [User](UserID),
    UpdatedAt     DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE TourOperationLog (
    LogID       INT IDENTITY(1,1) PRIMARY KEY,
    ScheduleID  INT           NOT NULL REFERENCES TourSchedule(ScheduleID),
    Activity    NVARCHAR(500) NOT NULL,
    OperatedBy  INT           NULL REFERENCES [User](UserID),
    CreatedAt   DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================================
-- 4. BOOKING & PARTICIPANTS
-- ============================================================

CREATE TABLE Booking (
    BookingID       INT IDENTITY(1,1) PRIMARY KEY,
    BookingCode     NVARCHAR(20)  NOT NULL UNIQUE, -- e.g. TB-742918
    ScheduleID      INT           NOT NULL REFERENCES TourSchedule(ScheduleID),
    CustomerID      INT           NOT NULL REFERENCES [User](UserID),
    NumParticipants INT           NOT NULL CHECK (NumParticipants BETWEEN 1 AND 10),
    BaseAmount      DECIMAL(18,2) NOT NULL,
    VATAmount       DECIMAL(18,2) NOT NULL DEFAULT 0,
    DiscountAmount  DECIMAL(18,2) NOT NULL DEFAULT 0,
    TotalAmount     DECIMAL(18,2) NOT NULL,
    Status          NVARCHAR(30)  NOT NULL DEFAULT 'PendingPayment'
                        CHECK (Status IN ('PendingPayment','PendingApproval','Confirmed',
                                          'Rejected','Cancelled','Completed','Success')),
    Notes           NVARCHAR(500) NULL,
    CouponID        INT           NULL,   -- FK added after Coupon table
    CreatedAt       DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt       DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE BookingParticipant (
    ParticipantID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID     INT           NOT NULL REFERENCES Booking(BookingID),
    FullName      NVARCHAR(100) NOT NULL,
    AgeType       NVARCHAR(10)  NOT NULL CHECK (AgeType IN ('Adult','Child','Infant')),
    PhoneNumber   NVARCHAR(15)  NULL,
    Email         NVARCHAR(150) NULL,
    IsLeader      BIT           NOT NULL DEFAULT 0,
    CreatedAt     DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE BookingHistory (
    HistoryID   INT IDENTITY(1,1) PRIMARY KEY,
    BookingID   INT           NOT NULL REFERENCES Booking(BookingID),
    OldStatus   NVARCHAR(30)  NULL,
    NewStatus   NVARCHAR(30)  NOT NULL,
    ChangedBy   INT           NULL REFERENCES [User](UserID),
    Reason      NVARCHAR(500) NULL,
    ChangedAt   DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE CancellationRequest (
    RequestID    INT IDENTITY(1,1) PRIMARY KEY,
    BookingID    INT           NOT NULL REFERENCES Booking(BookingID),
    RequestedBy  INT           NOT NULL REFERENCES [User](UserID),
    Reason       NVARCHAR(500) NOT NULL,
    Status       NVARCHAR(20)  NOT NULL DEFAULT 'Pending'
                     CHECK (Status IN ('Pending','Approved','Rejected')),
    ProcessedBy  INT           NULL REFERENCES [User](UserID),
    ProcessedAt  DATETIME2     NULL,
    Notes        NVARCHAR(500) NULL,
    CreatedAt    DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================================
-- 5. PAYMENT & FINANCIAL
-- ============================================================

CREATE TABLE Coupon (
    CouponID        INT IDENTITY(1,1) PRIMARY KEY,
    CouponCode      NVARCHAR(50)  NOT NULL UNIQUE,
    DiscountType    NVARCHAR(20)  NOT NULL CHECK (DiscountType IN ('Percentage','FixedAmount')),
    DiscountValue   DECIMAL(18,2) NOT NULL CHECK (DiscountValue > 0),
    MinOrderAmount  DECIMAL(18,2) NOT NULL DEFAULT 0,
    MaxUses         INT           NULL,
    UsedCount       INT           NOT NULL DEFAULT 0,
    StartDate       DATE          NOT NULL,
    EndDate         DATE          NOT NULL,
    IsActive        BIT           NOT NULL DEFAULT 1,
    CreatedBy       INT           NULL REFERENCES [User](UserID),
    CreatedAt       DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT CHK_CouponDates CHECK (EndDate >= StartDate)
);
GO

-- Now add FK from Booking to Coupon
ALTER TABLE Booking ADD CONSTRAINT FK_Booking_Coupon
    FOREIGN KEY (CouponID) REFERENCES Coupon(CouponID);
GO

CREATE TABLE Payment (
    PaymentID      INT IDENTITY(1,1) PRIMARY KEY,
    BookingID      INT           NOT NULL REFERENCES Booking(BookingID),
    PaymentMethod  NVARCHAR(50)  NOT NULL
                       CHECK (PaymentMethod IN ('CreditCard','BankTransfer','MoMo','VNPay')),
    TransactionRef NVARCHAR(100) NULL UNIQUE,
    Amount         DECIMAL(18,2) NOT NULL,
    Currency       NVARCHAR(10)  NOT NULL DEFAULT 'VND',
    Status         NVARCHAR(20)  NOT NULL DEFAULT 'Pending'
                       CHECK (Status IN ('Pending','Success','Failed','Refunded')),
    PaidAt         DATETIME2     NULL,
    GatewayResponse NVARCHAR(MAX) NULL,
    CreatedAt      DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE Invoice (
    InvoiceID     INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceCode   NVARCHAR(30)  NOT NULL UNIQUE,
    BookingID     INT           NOT NULL REFERENCES Booking(BookingID),
    PaymentID     INT           NOT NULL REFERENCES Payment(PaymentID),
    SubTotal      DECIMAL(18,2) NOT NULL,
    VATRate       DECIMAL(5,2)  NOT NULL DEFAULT 8.00,
    VATAmount     DECIMAL(18,2) NOT NULL,
    DiscountAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    TotalAmount   DECIMAL(18,2) NOT NULL,
    IssuedAt      DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    IssuedBy      INT           NULL REFERENCES [User](UserID)
);
GO

CREATE TABLE Refund (
    RefundID      INT IDENTITY(1,1) PRIMARY KEY,
    PaymentID     INT           NOT NULL REFERENCES Payment(PaymentID),
    BookingID     INT           NOT NULL REFERENCES Booking(BookingID),
    Amount        DECIMAL(18,2) NOT NULL,
    Reason        NVARCHAR(500) NULL,
    Status        NVARCHAR(20)  NOT NULL DEFAULT 'Pending'
                      CHECK (Status IN ('Pending','Processing','Completed','Rejected')),
    ProcessedBy   INT           NULL REFERENCES [User](UserID),
    ProcessedAt   DATETIME2     NULL,
    TransactionRef NVARCHAR(100) NULL,
    CreatedAt     DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE CurrencyExchange (
    ExchangeID    INT IDENTITY(1,1) PRIMARY KEY,
    FromCurrency  NVARCHAR(10) NOT NULL,
    ToCurrency    NVARCHAR(10) NOT NULL,
    Rate          DECIMAL(18,6) NOT NULL,
    EffectiveDate DATE          NOT NULL,
    CreatedAt     DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_CurrencyRate UNIQUE (FromCurrency, ToCurrency, EffectiveDate)
);
GO

CREATE TABLE FinancialAuditLog (
    AuditID       INT IDENTITY(1,1) PRIMARY KEY,
    EntityType    NVARCHAR(50)  NOT NULL, -- Payment, Refund, Invoice, etc.
    EntityID      INT           NOT NULL,
    Action        NVARCHAR(100) NOT NULL,
    OldValues     NVARCHAR(MAX) NULL,
    NewValues     NVARCHAR(MAX) NULL,
    PerformedBy   INT           NULL REFERENCES [User](UserID),
    CreatedAt     DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE FraudAlert (
    AlertID       INT IDENTITY(1,1) PRIMARY KEY,
    PaymentID     INT           NOT NULL REFERENCES Payment(PaymentID),
    AlertType     NVARCHAR(100) NOT NULL,
    Description   NVARCHAR(500) NULL,
    Severity      NVARCHAR(20)  NOT NULL DEFAULT 'Medium'
                      CHECK (Severity IN ('Low','Medium','High','Critical')),
    Status        NVARCHAR(20)  NOT NULL DEFAULT 'Open'
                      CHECK (Status IN ('Open','Investigating','Resolved','Dismissed')),
    ReviewedBy    INT           NULL REFERENCES [User](UserID),
    ReviewedAt    DATETIME2     NULL,
    CreatedAt     DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================================
-- 6. TOUR OPERATIONS
-- ============================================================

CREATE TABLE TourAssignment (
    AssignmentID INT IDENTITY(1,1) PRIMARY KEY,
    ScheduleID   INT           NOT NULL REFERENCES TourSchedule(ScheduleID),
    GuideID      INT           NOT NULL REFERENCES [User](UserID),
    AssignedBy   INT           NULL REFERENCES [User](UserID),
    AssignedAt   DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    Notes        NVARCHAR(500) NULL,
    CONSTRAINT UQ_TourAssignment UNIQUE (ScheduleID, GuideID)
);
GO

CREATE TABLE Attendance (
    AttendanceID   INT IDENTITY(1,1) PRIMARY KEY,
    ScheduleID     INT           NOT NULL REFERENCES TourSchedule(ScheduleID),
    ParticipantID  INT           NOT NULL REFERENCES BookingParticipant(ParticipantID),
    CheckedIn      BIT           NOT NULL DEFAULT 0,
    CheckInTime    DATETIME2     NULL,
    CheckedBy      INT           NULL REFERENCES [User](UserID),
    Notes          NVARCHAR(255) NULL,
    CONSTRAINT UQ_Attendance UNIQUE (ScheduleID, ParticipantID)
);
GO

CREATE TABLE IncidentReport (
    IncidentID    INT IDENTITY(1,1) PRIMARY KEY,
    ScheduleID    INT           NOT NULL REFERENCES TourSchedule(ScheduleID),
    ReportedBy    INT           NOT NULL REFERENCES [User](UserID),
    Title         NVARCHAR(200) NOT NULL,
    Description   NVARCHAR(MAX) NOT NULL,
    Severity      NVARCHAR(20)  NOT NULL DEFAULT 'Medium'
                      CHECK (Severity IN ('Low','Medium','High','Critical')),
    Status        NVARCHAR(30)  NOT NULL DEFAULT 'Open'
                      CHECK (Status IN ('Open','InProgress','Resolved','Closed')),
    ResolvedBy    INT           NULL REFERENCES [User](UserID),
    ResolvedAt    DATETIME2     NULL,
    CreatedAt     DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================================
-- 7. CUSTOMER EXPERIENCE
-- ============================================================

CREATE TABLE FavoriteTour (
    FavoriteID  INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID  INT       NOT NULL REFERENCES [User](UserID),
    TourID      INT       NOT NULL REFERENCES Tour(TourID),
    AddedAt     DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_FavoriteTour UNIQUE (CustomerID, TourID)
);
GO

CREATE TABLE Review (
    ReviewID    INT IDENTITY(1,1) PRIMARY KEY,
    TourID      INT           NOT NULL REFERENCES Tour(TourID),
    BookingID   INT           NOT NULL REFERENCES Booking(BookingID),
    CustomerID  INT           NOT NULL REFERENCES [User](UserID),
    Rating      TINYINT       NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Content     NVARCHAR(MAX) NULL,
    IsVisible   BIT           NOT NULL DEFAULT 1,
    CreatedAt   DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt   DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_Review UNIQUE (BookingID, CustomerID)
);
GO

CREATE TABLE ModerationRecord (
    ModerationID  INT IDENTITY(1,1) PRIMARY KEY,
    EntityType    NVARCHAR(50)  NOT NULL, -- Review, CommunityPost, Comment
    EntityID      INT           NOT NULL,
    Action        NVARCHAR(50)  NOT NULL, -- Hide, Restore, Delete, Flag
    Reason        NVARCHAR(500) NULL,
    ModeratedBy   INT           NOT NULL REFERENCES [User](UserID),
    ModeratedAt   DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================================
-- 8. COMMUNITY
-- ============================================================

CREATE TABLE CommunityPost (
    PostID       INT IDENTITY(1,1) PRIMARY KEY,
    AuthorID     INT           NOT NULL REFERENCES [User](UserID),
    Title        NVARCHAR(255) NULL,
    Content      NVARCHAR(MAX) NOT NULL,
    ImageURL     NVARCHAR(500) NULL,
    IsVisible    BIT           NOT NULL DEFAULT 1,
    LikeCount    INT           NOT NULL DEFAULT 0,
    CreatedAt    DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt    DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE Comment (
    CommentID   INT IDENTITY(1,1) PRIMARY KEY,
    PostID      INT           NOT NULL REFERENCES CommunityPost(PostID),
    AuthorID    INT           NOT NULL REFERENCES [User](UserID),
    Content     NVARCHAR(MAX) NOT NULL,
    IsVisible   BIT           NOT NULL DEFAULT 1,
    CreatedAt   DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================================
-- 9. BUDDY MATCHING & CHAT
-- ============================================================

CREATE TABLE BuddyMatch (
    MatchID        INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID     INT           NOT NULL REFERENCES [User](UserID),
    MatchedUserID  INT           NOT NULL REFERENCES [User](UserID),
    CompatibilityScore DECIMAL(5,2) NULL,
    MatchedAt      DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_BuddyMatch UNIQUE (CustomerID, MatchedUserID)
);
GO

CREATE TABLE BuddyRequest (
    RequestID   INT IDENTITY(1,1) PRIMARY KEY,
    SenderID    INT           NOT NULL REFERENCES [User](UserID),
    ReceiverID  INT           NOT NULL REFERENCES [User](UserID),
    Status      NVARCHAR(20)  NOT NULL DEFAULT 'Pending'
                    CHECK (Status IN ('Pending','Accepted','Rejected','Cancelled')),
    Message     NVARCHAR(500) NULL,
    CreatedAt   DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt   DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_BuddyRequest UNIQUE (SenderID, ReceiverID),
    CONSTRAINT CHK_NotSelf CHECK (SenderID <> ReceiverID)
);
GO

CREATE TABLE ChatConversation (
    ConversationID INT IDENTITY(1,1) PRIMARY KEY,
    ConversationType NVARCHAR(20) NOT NULL DEFAULT 'Direct'
                         CHECK (ConversationType IN ('Direct','Group')),
    GroupName      NVARCHAR(100) NULL,
    CreatedBy      INT           NULL REFERENCES [User](UserID),
    CreatedAt      DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE ConversationParticipant (
    ID             INT IDENTITY(1,1) PRIMARY KEY,
    ConversationID INT       NOT NULL REFERENCES ChatConversation(ConversationID),
    UserID         INT       NOT NULL REFERENCES [User](UserID),
    JoinedAt       DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_ConvParticipant UNIQUE (ConversationID, UserID)
);
GO

CREATE TABLE ChatMessage (
    MessageID      INT IDENTITY(1,1) PRIMARY KEY,
    ConversationID INT           NOT NULL REFERENCES ChatConversation(ConversationID),
    SenderID       INT           NOT NULL REFERENCES [User](UserID),
    Content        NVARCHAR(MAX) NOT NULL,
    IsVisible      BIT           NOT NULL DEFAULT 1,
    SentAt         DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE VideoCallSchedule (
    CallID         INT IDENTITY(1,1) PRIMARY KEY,
    ConversationID INT           NULL REFERENCES ChatConversation(ConversationID),
    OrganizedBy    INT           NOT NULL REFERENCES [User](UserID),
    Title          NVARCHAR(200) NULL,
    ScheduledAt    DATETIME2     NOT NULL,
    DurationMin    INT           NULL,
    MeetingURL     NVARCHAR(500) NULL,
    Status         NVARCHAR(20)  NOT NULL DEFAULT 'Scheduled'
                       CHECK (Status IN ('Scheduled','InProgress','Completed','Cancelled')),
    CreatedAt      DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================================
-- 10. NOTIFICATIONS & ANALYTICS
-- ============================================================

CREATE TABLE Notification (
    NotificationID INT IDENTITY(1,1) PRIMARY KEY,
    UserID         INT           NOT NULL REFERENCES [User](UserID),
    Title          NVARCHAR(200) NOT NULL,
    Content        NVARCHAR(MAX) NOT NULL,
    Type           NVARCHAR(50)  NOT NULL DEFAULT 'General',
                                  -- Booking, Payment, Tour, System, Account
    IsRead         BIT           NOT NULL DEFAULT 0,
    RelatedEntity  NVARCHAR(50)  NULL,
    RelatedID      INT           NULL,
    CreatedAt      DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE AnalyticsReport (
    ReportID    INT IDENTITY(1,1) PRIMARY KEY,
    ReportType  NVARCHAR(100) NOT NULL,  -- Revenue, Booking, TourPerformance, GuideActivity
    PeriodStart DATE          NOT NULL,
    PeriodEnd   DATE          NOT NULL,
    Data        NVARCHAR(MAX) NULL,      -- JSON payload
    GeneratedBy INT           NULL REFERENCES [User](UserID),
    GeneratedAt DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE RevenueReport (
    RevenueReportID INT IDENTITY(1,1) PRIMARY KEY,
    ReportID        INT           NOT NULL REFERENCES AnalyticsReport(ReportID),
    ExportFormat    NVARCHAR(10)  NOT NULL DEFAULT 'PDF'
                        CHECK (ExportFormat IN ('PDF','Excel','CSV')),
    FileURL         NVARCHAR(500) NULL,
    ExportedBy      INT           NULL REFERENCES [User](UserID),
    ExportedAt      DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE PredictionResult (
    PredictionID   INT IDENTITY(1,1) PRIMARY KEY,
    PredictionType NVARCHAR(100) NOT NULL, -- BookingTrend, Revenue, Demand
    ModelVersion   NVARCHAR(50)  NULL,
    InputData      NVARCHAR(MAX) NULL,
    ResultData     NVARCHAR(MAX) NULL,      -- JSON
    Confidence     DECIMAL(5,2)  NULL,
    GeneratedBy    INT           NULL REFERENCES [User](UserID),
    GeneratedAt    DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================

CREATE INDEX IX_User_Email       ON [User](Email);
CREATE INDEX IX_User_RoleID      ON [User](RoleID);
CREATE INDEX IX_Tour_Status      ON Tour(Status);
CREATE INDEX IX_Tour_CategoryID  ON Tour(CategoryID);
CREATE INDEX IX_TourSchedule_TourID       ON TourSchedule(TourID);
CREATE INDEX IX_TourSchedule_DepartureDate ON TourSchedule(DepartureDate);
CREATE INDEX IX_Booking_CustomerID ON Booking(CustomerID);
CREATE INDEX IX_Booking_ScheduleID ON Booking(ScheduleID);
CREATE INDEX IX_Booking_Status     ON Booking(Status);
CREATE INDEX IX_Booking_BookingCode ON Booking(BookingCode);
CREATE INDEX IX_Payment_BookingID  ON Payment(BookingID);
CREATE INDEX IX_Payment_Status     ON Payment(Status);
CREATE INDEX IX_Notification_UserID ON Notification(UserID);
CREATE INDEX IX_Notification_IsRead ON Notification(IsRead);
CREATE INDEX IX_ChatMessage_ConvID  ON ChatMessage(ConversationID);
CREATE INDEX IX_Review_TourID       ON Review(TourID);
CREATE INDEX IX_CommunityPost_Author ON CommunityPost(AuthorID);
GO

-- ============================================================
-- SEED DATA
-- ============================================================

-- Roles
INSERT INTO Role (RoleName, Description) VALUES
('Admin',      N'Quản trị viên hệ thống'),
('Staff',      N'Nhân viên xử lý booking'),
('Guide',      N'Hướng dẫn viên tour'),
('Customer',   N'Khách hàng'),
('Accountant', N'Kế toán');
GO

-- Permissions (sample)
INSERT INTO Permission (PermissionName, Module, Description) VALUES
('TOUR_CREATE',        'Tour',     N'Tạo tour mới'),
('TOUR_EDIT',          'Tour',     N'Chỉnh sửa tour'),
('TOUR_DELETE',        'Tour',     N'Xóa/Hủy tour'),
('BOOKING_VIEW_ALL',   'Booking',  N'Xem tất cả booking'),
('BOOKING_PROCESS',    'Booking',  N'Xử lý booking'),
('PAYMENT_VIEW',       'Payment',  N'Xem thanh toán'),
('REFUND_PROCESS',     'Payment',  N'Xử lý hoàn tiền'),
('USER_MANAGE',        'User',     N'Quản lý tài khoản'),
('ROLE_MANAGE',        'Role',     N'Quản lý vai trò'),
('REPORT_VIEW',        'Report',   N'Xem báo cáo'),
('REPORT_EXPORT',      'Report',   N'Xuất báo cáo'),
('REVIEW_MODERATE',    'Community',N'Kiểm duyệt đánh giá'),
('GUIDE_ASSIGN',       'Tour',     N'Phân công HDV'),
('CHECKIN_MANAGE',     'Tour',     N'Quản lý điểm danh'),
('ANALYTICS_VIEW',     'Report',   N'Xem analytics'),
('FRAUD_MANAGE',       'Payment',  N'Quản lý gian lận'),
('COUPON_MANAGE',      'Payment',  N'Quản lý mã giảm giá'),
('NOTIFICATION_SEND',  'System',   N'Gửi thông báo');
GO

-- Role-Permission assignments
-- Admin gets all permissions
INSERT INTO RolePermission (RoleID, PermissionID)
SELECT 1, PermissionID FROM Permission;

-- Staff permissions
INSERT INTO RolePermission (RoleID, PermissionID)
SELECT 2, PermissionID FROM Permission
WHERE PermissionName IN ('BOOKING_VIEW_ALL','BOOKING_PROCESS','GUIDE_ASSIGN',
                         'CHECKIN_MANAGE','NOTIFICATION_SEND');

-- Accountant permissions
INSERT INTO RolePermission (RoleID, PermissionID)
SELECT 5, PermissionID FROM Permission
WHERE PermissionName IN ('PAYMENT_VIEW','REFUND_PROCESS','REPORT_VIEW',
                         'REPORT_EXPORT','ANALYTICS_VIEW','FRAUD_MANAGE',
                         'COUPON_MANAGE');
GO

-- Tour Categories
INSERT INTO TourCategory (CategoryName, Description) VALUES
(N'Biển & Đảo',    N'Các tour du lịch biển đảo'),
(N'Núi & Rừng',    N'Các tour trekking, leo núi'),
(N'Văn hóa & Di sản', N'Tham quan di tích lịch sử'),
(N'City Tour',      N'Khám phá thành phố'),
(N'MICE',           N'Tour hội nghị, sự kiện');
GO

-- Sample Tours
INSERT INTO Tour (CategoryID, TourName, Destination, DurationDays, BasePrice,
                  MaxParticipants, Status, IsFeatured, Description)
VALUES
(1, N'Khám Phá Vịnh Hạ Long 3N2Đ', N'Hạ Long, Quảng Ninh', 3, 3500000, 20, 'Active', 1,
   N'Hành trình khám phá kỳ quan thiên nhiên thế giới Vịnh Hạ Long với thuyền kayak, hang động.'),
(1, N'Đà Nẵng - Hội An - Bà Nà 4N3Đ', N'Đà Nẵng, Quảng Nam', 4, 4200000, 25, 'Active', 1,
   N'Trải nghiệm phố cổ Hội An, bãi biển Mỹ Khê, Bà Nà Hills và cầu vàng nổi tiếng.'),
(2, N'Chinh Phục Fansipan 2N1Đ', N'Sa Pa, Lào Cai', 2, 2800000, 15, 'Active', 0,
   N'Trekking leo núi Fansipan - nóc nhà Đông Dương với cáp treo và đường mòn.'),
(3, N'Huế - Cố Đô Ngàn Năm 3N2Đ', N'Huế, Thừa Thiên Huế', 3, 3100000, 20, 'Active', 0,
   N'Khám phá kinh thành Huế, lăng tẩm vua chúa triều Nguyễn và ẩm thực cung đình.'),
(4, N'Hà Nội City Tour 1N', N'Hà Nội', 1, 850000, 30, 'Active', 1,
   N'Tham quan Hồ Hoàn Kiếm, Văn Miếu, lăng Bác, phố cổ 36 phố phường.');
GO

-- ============================================================
-- SEED TOUR MEDIA
-- ============================================================
INSERT INTO TourMedia (TourID, MediaURL, MediaType, Caption, SortOrder, IsVisible, UploadedBy) VALUES
-- Tour 1 (Hạ Long)
(1, 'assets/images/tour_halong.png', 'Image', N'Vịnh Hạ Long từ trên cao', 1, 1, NULL),
(1, 'assets/images/tour_phuquoc.png', 'Image', N'Resort bên bờ biển', 2, 1, NULL),
(1, 'assets/images/hero_beach.png', 'Image', N'Bình minh trên biển', 3, 1, NULL),
(1, 'assets/images/tour_dalat.png', 'Image', N'Rừng thông Đà Lạt', 4, 1, NULL),
(1, 'assets/images/tour_danang.png', 'Image', N'Cầu Rồng Đà Nẵng', 5, 1, NULL),

-- Tour 2 (Đà Nẵng)
(2, 'assets/images/tour_danang.png', 'Image', N'Cầu Vàng Bà Nà Hills', 1, 1, NULL),
(2, 'assets/images/tour_hoian.png', 'Image', N'Phố cổ Hội An về đêm', 2, 1, NULL),
(2, 'assets/images/hero_beach.png', 'Image', N'Bãi biển Mỹ Khê', 3, 1, NULL),
(2, 'assets/images/tour_dalat.png', 'Image', N'Thung lũng tình yêu', 4, 1, NULL),
(2, 'assets/images/tour_halong.png', 'Image', N'Khám phá hang động', 5, 1, NULL),

-- Tour 3 (Sapa)
(3, 'assets/images/tour_sapa.png', 'Image', N'Bản Cát Cát Sapa', 1, 1, NULL),
(3, 'assets/images/tour_dalat.png', 'Image', N'Trekking rừng thông', 2, 1, NULL),
(3, 'assets/images/tour_hagiang.png', 'Image', N'Ruộng bậc thang miền Bắc', 3, 1, NULL),
(3, 'assets/images/hero_beach.png', 'Image', N'Cảnh quan đồi núi', 4, 1, NULL),
(3, 'assets/images/tour_halong.png', 'Image', N'Đỉnh Fansipan', 5, 1, NULL),

-- Tour 4 (Huế)
(4, 'assets/images/tour_hoian.png', 'Image', N'Đại nội Huế cổ kính', 1, 1, NULL),
(4, 'assets/images/tour_danang.png', 'Image', N'Lăng Khải Định', 2, 1, NULL),
(4, 'assets/images/tour_halong.png', 'Image', N'Chùa Thiên Mụ', 3, 1, NULL),
(4, 'assets/images/tour_dalat.png', 'Image', N'Sông Hương thơ mộng', 4, 1, NULL),
(4, 'assets/images/hero_beach.png', 'Image', N'Ẩm thực cung đình Huế', 5, 1, NULL),

-- Tour 5 (Hà Nội)
(5, 'assets/images/tour_sapa.png', 'Image', N'Hồ Hoàn Kiếm', 1, 1, NULL),
(5, 'assets/images/tour_halong.png', 'Image', N'Lăng Chủ tịch Hồ Chí Minh', 2, 1, NULL),
(5, 'assets/images/tour_hagiang.png', 'Image', N'Phố cổ Hà Nội', 3, 1, NULL),
(5, 'assets/images/tour_dalat.png', 'Image', N'Văn Miếu Quốc Tử Giám', 4, 1, NULL),
(5, 'assets/images/hero_beach.png', 'Image', N'Chùa Một Cột', 5, 1, NULL);
GO

-- ============================================================
-- USEFUL VIEWS
-- ============================================================

-- Available seats per schedule
CREATE VIEW vw_TourScheduleAvailability AS
SELECT
    s.ScheduleID,
    t.TourName,
    t.Destination,
    s.DepartureDate,
    s.ReturnDate,
    s.TotalSeats,
    s.AvailableSeats,
    s.PriceAdult,
    s.Status
FROM TourSchedule s
JOIN Tour t ON t.TourID = s.TourID
WHERE s.Status = 'Open' AND t.Status = 'Active';
GO

-- Booking summary
CREATE VIEW vw_BookingSummary AS
SELECT
    b.BookingID,
    b.BookingCode,
    b.Status        AS BookingStatus,
    u.FullName      AS CustomerName,
    u.Email         AS CustomerEmail,
    t.TourName,
    s.DepartureDate,
    b.NumParticipants,
    b.TotalAmount,
    p.Status        AS PaymentStatus,
    b.CreatedAt
FROM Booking b
JOIN [User] u         ON u.UserID = b.CustomerID
JOIN TourSchedule s   ON s.ScheduleID = b.ScheduleID
JOIN Tour t           ON t.TourID = s.TourID
LEFT JOIN Payment p   ON p.BookingID = b.BookingID;
GO

PRINT N'✅ TourBuddy Database created successfully!';
PRINT N'   - 40 Tables created';
PRINT N'   - Indexes, Constraints applied';
PRINT N'   - Seed data inserted (Roles, Permissions, Categories, Sample Tours)';
GO
GO
-- Migration v6: Add missing columns to Tour table
-- Run this script in SQL Server Management Studio (SSMS)
-- These columns exist in Java code but were missing from the database schema.

USE TourBuddyDB;
GO

-- 1. Add IsDeleted column (used for soft-delete tour)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'IsDeleted' AND Object_ID = Object_ID(N'Tour'))
BEGIN
    ALTER TABLE Tour ADD IsDeleted BIT NOT NULL DEFAULT 0;
    PRINT 'Added column: IsDeleted';
END
GO

-- 2. Add Languages column
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'Languages' AND Object_ID = Object_ID(N'Tour'))
BEGIN
    ALTER TABLE Tour ADD Languages NVARCHAR(200) NULL;
    PRINT 'Added column: Languages';
END
GO

-- 3. Add GroupSizeMin column
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'GroupSizeMin' AND Object_ID = Object_ID(N'Tour'))
BEGIN
    ALTER TABLE Tour ADD GroupSizeMin INT NOT NULL DEFAULT 1;
    PRINT 'Added column: GroupSizeMin';
END
GO

-- 4. Add GroupSizeMax column
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'GroupSizeMax' AND Object_ID = Object_ID(N'Tour'))
BEGIN
    ALTER TABLE Tour ADD GroupSizeMax INT NOT NULL DEFAULT 20;
    PRINT 'Added column: GroupSizeMax';
END
GO

-- 5. Add DepartureCity column
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'DepartureCity' AND Object_ID = Object_ID(N'Tour'))
BEGIN
    ALTER TABLE Tour ADD DepartureCity NVARCHAR(200) NULL;
    PRINT 'Added column: DepartureCity';
END
GO

-- 6. Add Latitude column
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'Latitude' AND Object_ID = Object_ID(N'Tour'))
BEGIN
    ALTER TABLE Tour ADD Latitude FLOAT NULL;
    PRINT 'Added column: Latitude';
END
GO

-- 7. Add Longitude column
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'Longitude' AND Object_ID = Object_ID(N'Tour'))
BEGIN
    ALTER TABLE Tour ADD Longitude FLOAT NULL;
    PRINT 'Added column: Longitude';
END
GO

-- 8. Add VideoURL column
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'VideoURL' AND Object_ID = Object_ID(N'Tour'))
BEGIN
    ALTER TABLE Tour ADD VideoURL NVARCHAR(500) NULL;
    PRINT 'Added column: VideoURL';
END
GO

-- 9. Add missing columns to TourSchedule table
-- GuideID column (used in AdminSchedulePricingController)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'GuideID' AND Object_ID = Object_ID(N'TourSchedule'))
BEGIN
    ALTER TABLE TourSchedule ADD GuideID INT NULL REFERENCES [User](UserID);
    PRINT 'Added column: TourSchedule.GuideID';
END
GO

-- TourStatus column in TourSchedule
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'TourStatus' AND Object_ID = Object_ID(N'TourSchedule'))
BEGIN
    ALTER TABLE TourSchedule ADD TourStatus NVARCHAR(50) NULL DEFAULT 'Scheduled';
    PRINT 'Added column: TourSchedule.TourStatus';
END
GO

-- Create TourInclusion table if not exists
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TourInclusion')
BEGIN
    CREATE TABLE TourInclusion (
        InclusionID   INT IDENTITY(1,1) PRIMARY KEY,
        TourID        INT NOT NULL REFERENCES Tour(TourID) ON DELETE CASCADE,
        InclusionType NVARCHAR(20)  NOT NULL DEFAULT 'INCLUDED' CHECK (InclusionType IN ('INCLUDED','EXCLUDED')),
        ServiceName   NVARCHAR(200) NOT NULL,
        IconName      NVARCHAR(50)  NULL DEFAULT 'sparkles',
        SortOrder     INT           NOT NULL DEFAULT 0,
        IsActive      BIT           NOT NULL DEFAULT 1,
        CreatedAt     DATETIME2     NOT NULL DEFAULT SYSDATETIME()
    );
    PRINT 'Created table: TourInclusion';
END
GO

-- Create TourItinerary table if not exists
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TourItinerary')
BEGIN
    CREATE TABLE TourItinerary (
        ItineraryID      INT IDENTITY(1,1) PRIMARY KEY,
        TourID           INT NOT NULL REFERENCES Tour(TourID) ON DELETE CASCADE,
        DayNumber        INT NOT NULL,
        Title            NVARCHAR(300) NOT NULL,
        ShortDescription NVARCHAR(500) NULL,
        Description      NVARCHAR(MAX) NULL,
        Activities       NVARCHAR(MAX) NULL,
        Meals            NVARCHAR(200) NULL,
        Accommodation    NVARCHAR(200) NULL,
        ImageURL         NVARCHAR(500) NULL,
        SortOrder        INT           NOT NULL DEFAULT 0,
        CreatedAt        DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
        UpdatedAt        DATETIME2     NOT NULL DEFAULT SYSDATETIME()
    );
    PRINT 'Created table: TourItinerary';
END
GO

-- Create TourFAQ table if not exists
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TourFAQ')
BEGIN
    CREATE TABLE TourFAQ (
        FAQID     INT IDENTITY(1,1) PRIMARY KEY,
        TourID    INT NOT NULL REFERENCES Tour(TourID) ON DELETE CASCADE,
        Question  NVARCHAR(500) NOT NULL,
        Answer    NVARCHAR(MAX) NOT NULL,
        SortOrder INT NOT NULL DEFAULT 0,
        IsActive  BIT NOT NULL DEFAULT 1,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
    PRINT 'Created table: TourFAQ';
END
GO

PRINT '=== Migration v6 completed successfully! ===';
GO

USE TourBuddyDB;
GO
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT all';
GO
-- ============================================================
-- TourBuddyDB - Consolidated Migration & Seed Data Script
-- Includes all schema fixes, tables migrations, account setup,
-- and analytics seeds for different tour categories.
-- ============================================================

USE TourBuddyDB;
GO

-- ============================================================
-- 1. CLEAN & REBUILD PERMISSION SYSTEM (RBAC)
-- ============================================================
PRINT '1. Rebuilding RBAC Tables...';
IF OBJECT_ID('dbo.Role_Permission', 'U') IS NOT NULL DROP TABLE dbo.Role_Permission;
IF OBJECT_ID('dbo.RolePermission', 'U') IS NOT NULL DROP TABLE dbo.RolePermission;
IF OBJECT_ID('dbo.Permission', 'U') IS NOT NULL DROP TABLE dbo.Permission;
IF OBJECT_ID('dbo.Audit_Log', 'U') IS NOT NULL DROP TABLE dbo.Audit_Log;
GO

-- Alter Role table (IsSystemRole column)
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'IsSystemRole' AND Object_ID = Object_ID(N'Role'))
BEGIN
    ALTER TABLE Role ADD IsSystemRole BIT DEFAULT 0;
END
GO
UPDATE Role SET IsSystemRole = 1 WHERE RoleName IN ('Admin', 'Customer');
GO

-- Recreate Permission Table
CREATE TABLE Permission (
    PermissionID INT IDENTITY(1,1) PRIMARY KEY,
    ModuleName NVARCHAR(100) NOT NULL,
    Action NVARCHAR(50) NOT NULL,
    Description NVARCHAR(255),
    IsCritical BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT SYSDATETIME()
);
GO

-- Recreate Role_Permission Table
CREATE TABLE Role_Permission (
    RoleID INT FOREIGN KEY REFERENCES Role(RoleID) ON DELETE CASCADE,
    PermissionID INT FOREIGN KEY REFERENCES Permission(PermissionID) ON DELETE CASCADE,
    PRIMARY KEY (RoleID, PermissionID)
);
GO

-- Recreate Audit_Log Table
CREATE TABLE Audit_Log (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    AdminID INT FOREIGN KEY REFERENCES [User](UserID) ON DELETE NO ACTION,
    ActionType NVARCHAR(100),
    TargetRoleID INT NULL,
    Details NVARCHAR(500),
    CreatedAt DATETIME DEFAULT SYSDATETIME()
);
GO

-- Insert Seed Data for Permissions
INSERT INTO Permission (ModuleName, Action, Description, IsCritical) VALUES
('Tour Management', 'Read', N'View Tour', 0),
('Tour Management', 'Create', N'Create Tour', 0),
('Tour Management', 'Update', N'Update Tour', 0),
('Tour Management', 'Delete', N'Delete Tour', 1),
('Booking Management', 'Read', N'View Booking', 0),
('Booking Management', 'Create', N'Create Booking', 0),
('Booking Management', 'Update', N'Update Booking', 0),
('Booking Management', 'Delete', N'Delete Booking', 1),
('User Management', 'Read', N'View Users', 0),
('User Management', 'Create', N'Create Users', 0),
('User Management', 'Update', N'Update Users', 0),
('User Management', 'Delete', N'Delete Users', 1),
('Role Management', 'Read', N'View Roles', 1),
('Role Management', 'Create', N'Create Roles', 1),
('Role Management', 'Update', N'Update Roles', 1),
('Role Management', 'Delete', N'Delete Roles', 1),
('Matching Management', 'Read', N'View Matching', 0),
('Matching Management', 'Create', N'Create Matching', 0),
('Matching Management', 'Update', N'Update Matching', 0),
('Matching Management', 'Delete', N'Delete Matching', 0),
('Request Management', 'Read', N'View Requests', 0),
('Request Management', 'Create', N'Create Requests', 0),
('Request Management', 'Update', N'Update Requests', 0),
('Request Management', 'Delete', N'Delete Requests', 0),
('Review Management', 'Read', N'View Reviews', 0),
('Review Management', 'Create', N'Create Reviews', 0),
('Review Management', 'Update', N'Update Reviews', 0),
('Review Management', 'Delete', N'Delete Reviews', 0),
('Payment Management', 'Read', N'View Payments', 0),
('Payment Management', 'Create', N'Create Payments', 0),
('Payment Management', 'Update', N'Update Payments', 0),
('Payment Management', 'Delete', N'Delete Payments', 1),
('System Settings', 'Read', N'View Reports', 1),
('System Settings', 'Export', N'Export Reports', 1),
('Content Management', 'Read', N'View Content', 0),
('Content Management', 'Create', N'Create Content', 0),
('Content Management', 'Update', N'Update Content', 0),
('Content Management', 'Delete', N'Delete Content', 1);
GO

-- Assign all permissions to Super Admin (RoleID = 1)
INSERT INTO Role_Permission (RoleID, PermissionID)
SELECT 1, PermissionID FROM Permission;
GO

-- Assign basic permissions to Staff (RoleID = 2)
INSERT INTO Role_Permission (RoleID, PermissionID)
SELECT 2, PermissionID FROM Permission 
WHERE (ModuleName = 'Tour Management' AND Action IN ('Read', 'Create', 'Update'))
   OR (ModuleName = 'Booking Management' AND Action IN ('Read', 'Update'));
GO

-- Assign basic permissions to Guide (RoleID = 3)
INSERT INTO Role_Permission (RoleID, PermissionID)
SELECT 3, PermissionID FROM Permission 
WHERE ModuleName = 'Tour Management' AND Action = 'Read';
GO


-- ============================================================
-- 2. CREATE REMAINING SCHEMA TABLES (MIGRATIONS V3, V4, V5, NOTIFICATION)
-- ============================================================
PRINT '2. Migrating Schema Tables...';

-- Create BuddyRequest table (Migration v3)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BuddyRequest]') AND type in (N'U'))
BEGIN
    CREATE TABLE BuddyRequest (
        RequestId INT IDENTITY(1,1) PRIMARY KEY,
        SenderId INT FOREIGN KEY REFERENCES [User](UserID) ON DELETE NO ACTION,
        ReceiverId INT FOREIGN KEY REFERENCES [User](UserID) ON DELETE NO ACTION,
        Status INT DEFAULT 0, -- 0: Pending, 1: Accepted, 2: Rejected
        CreatedAt DATETIME DEFAULT SYSDATETIME(),
        UpdatedAt DATETIME DEFAULT SYSDATETIME(),
        CONSTRAINT UQ_BuddyRequest UNIQUE (SenderId, ReceiverId)
    );
END
GO

-- Create TravelPreference table (Migration v4)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TravelPreference')
BEGIN
    CREATE TABLE TravelPreference (
        PreferenceId INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT FOREIGN KEY REFERENCES [User](UserID) ON DELETE CASCADE,
        Destination NVARCHAR(255),
        StartDate DATE,
        EndDate DATE,
        TravelStyle NVARCHAR(100),
        MinBudget DECIMAL(18,2),
        MaxBudget DECIMAL(18,2),
        TargetAgeMin INT,
        TargetAgeMax INT,
        TargetGender NVARCHAR(20),
        Languages NVARCHAR(255),
        Tags NVARCHAR(500),
        CreatedAt DATETIME DEFAULT SYSDATETIME(),
        UpdatedAt DATETIME DEFAULT SYSDATETIME(),
        CONSTRAINT UQ_TravelPreference_User UNIQUE (UserId)
    );
END
GO

-- Add extra columns to TravelPreference (Migration v5)
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'TripDuration' AND Object_ID = Object_ID(N'TravelPreference'))
BEGIN
    ALTER TABLE TravelPreference ADD TripDuration NVARCHAR(50) NULL;
END
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'TravelFrequency' AND Object_ID = Object_ID(N'TravelPreference'))
BEGIN
    ALTER TABLE TravelPreference ADD TravelFrequency NVARCHAR(50) NULL;
END
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'ActivityPreferences' AND Object_ID = Object_ID(N'TravelPreference'))
BEGIN
    ALTER TABLE TravelPreference ADD ActivityPreferences NVARCHAR(500) NULL;
END
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'SmokingPreference' AND Object_ID = Object_ID(N'TravelPreference'))
BEGIN
    ALTER TABLE TravelPreference ADD SmokingPreference NVARCHAR(50) NULL;
END
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'DrinkingPreference' AND Object_ID = Object_ID(N'TravelPreference'))
BEGIN
    ALTER TABLE TravelPreference ADD DrinkingPreference NVARCHAR(50) NULL;
END
GO

-- Create Notifications table (notification.sql)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Notifications' and xtype='U')
BEGIN
    CREATE TABLE Notifications (
        notificationId INT IDENTITY(1,1) PRIMARY KEY,
        userId INT FOREIGN KEY REFERENCES [User](userId),
        senderId INT FOREIGN KEY REFERENCES [User](userId) NULL,
        title NVARCHAR(255) NOT NULL,
        content NVARCHAR(MAX) NOT NULL,
        channel VARCHAR(50) NOT NULL, -- 'SYSTEM', 'EMAIL', 'BOTH'
        category VARCHAR(50) DEFAULT 'System Announcement',
        isRead BIT DEFAULT 0,
        createdAt DATETIME DEFAULT GETDATE(),
        scheduledAt DATETIME NULL,
        status VARCHAR(50) DEFAULT 'SENT' -- 'SCHEDULED', 'SENT', 'FAILED'
    );
END
GO

-- Alter Tour table to support soft delete (IsDeleted)
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'IsDeleted' AND Object_ID = Object_ID(N'Tour'))
BEGIN
    ALTER TABLE Tour ADD IsDeleted BIT NOT NULL DEFAULT 0;
END
GO


-- ============================================================
-- 3. SETUP & SEED TARGET ACCOUNTS
-- ============================================================
PRINT '3. Seeding Target Users and Roles...';

DECLARE @hashed_pass NVARCHAR(512) = 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f'; -- SHA-256 of '12345678'

-- 1. sonkbgnh@gmail.com -> Admin (RoleID = 1)
IF EXISTS (SELECT 1 FROM [User] WHERE Email = 'sonkbgnh@gmail.com')
BEGIN
    UPDATE [User] SET RoleID = 1 WHERE Email = 'sonkbgnh@gmail.com';
END
ELSE
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt, UpdatedAt)
    VALUES (1, 'sonkbgnh@gmail.com', @hashed_pass, N'Admin Son KB', '0911111111', 1, 1, SYSDATETIME(), SYSDATETIME());
END

-- 2. sondqhe186525@fpt.edu.vn -> Accountant (RoleID = 5)
IF EXISTS (SELECT 1 FROM [User] WHERE Email = 'sondqhe186525@fpt.edu.vn')
BEGIN
    UPDATE [User] SET RoleID = 5 WHERE Email = 'sondqhe186525@fpt.edu.vn';
END
ELSE
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt, UpdatedAt)
    VALUES (5, 'sondqhe186525@fpt.edu.vn', @hashed_pass, N'Accountant Son DQ', '0922222222', 1, 1, SYSDATETIME(), SYSDATETIME());
END

-- 3. sonkbgnh112@gmail.com -> Customer (RoleID = 4)
IF EXISTS (SELECT 1 FROM [User] WHERE Email = 'sonkbgnh112@gmail.com')
BEGIN
    UPDATE [User] SET RoleID = 4 WHERE Email = 'sonkbgnh112@gmail.com';
END
ELSE
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt, UpdatedAt)
    VALUES (4, 'sonkbgnh112@gmail.com', @hashed_pass, N'Customer Son KB 112', '0933333333', 1, 1, SYSDATETIME(), SYSDATETIME());
END

-- 4. test_rbac_data.sql Users
IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'admin.test@tourbuddy.com')
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt)
    VALUES (1, 'admin.test@tourbuddy.com', @hashed_pass, N'Super Admin Test', '0901234567', 1, 1, SYSDATETIME());

IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'staff.test@tourbuddy.com')
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt)
    VALUES (2, 'staff.test@tourbuddy.com', @hashed_pass, N'Nhân viên điều hành Test', '0902345678', 1, 1, SYSDATETIME());

IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'guide.test@tourbuddy.com')
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt)
    VALUES (3, 'guide.test@tourbuddy.com', @hashed_pass, N'Hướng dẫn viên Test', '0903456789', 1, 1, SYSDATETIME());

-- 5. Seed 3 Guides (from add_guides.sql)
IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'guide1@tourbuddy.com')
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt, UpdatedAt)
    VALUES (3, 'guide1@tourbuddy.com', @hashed_pass, N'Nguyễn Văn Hướng Dẫn', '0912345678', 1, 1, SYSDATETIME(), SYSDATETIME());
    DECLARE @G1 INT = SCOPE_IDENTITY();

    INSERT INTO UserProfile (UserID, AvatarURL, Biography, DateOfBirth, Gender, Address, TravelInterests, UpdatedAt)
    VALUES (@G1, 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', N'Kinh nghiệm 5 năm dẫn tour mạo hiểm.', '1995-05-15', 'Male', N'Hà Nội', N'Trekking, Leo núi', SYSDATETIME());

    INSERT INTO GuideProfile (UserID, YearsOfExperience, TotalToursLed, Rating, Bio, Specialization, Languages, Certifications, EmergencyPhone, IsActive, CreatedAt, UpdatedAt)
    VALUES (@G1, 5, 12, 4.8, N'HDV chuyên nghiệp về trekking Sapa và Hà Giang.', N'Trekking, Khám phá rừng núi', N'Tiếng Việt, Tiếng Anh', N'Chứng chỉ HDV Quốc tế', '0912345678', 1, SYSDATETIME(), SYSDATETIME());
END

IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'guide2@tourbuddy.com')
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt, UpdatedAt)
    VALUES (3, 'guide2@tourbuddy.com', @hashed_pass, N'Trần Thị Dẫn Đường', '0987654321', 1, 1, SYSDATETIME(), SYSDATETIME());
    DECLARE @G2 INT = SCOPE_IDENTITY();

    INSERT INTO UserProfile (UserID, AvatarURL, Biography, DateOfBirth, Gender, Address, TravelInterests, UpdatedAt)
    VALUES (@G2, 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150', N'Đam mê lịch sử và văn hóa cố đô.', '1997-09-20', 'Female', N'Huế', N'Lịch sử, Ẩm thực', SYSDATETIME());

    INSERT INTO GuideProfile (UserID, YearsOfExperience, TotalToursLed, Rating, Bio, Specialization, Languages, Certifications, EmergencyPhone, IsActive, CreatedAt, UpdatedAt)
    VALUES (@G2, 3, 8, 4.7, N'HDV chuyên tuyến văn hóa Huế - Hội An.', N'Văn hóa, Lịch sử, Ẩm thực', N'Tiếng Việt, Tiếng Trung', N'Chứng chỉ HDV Nội địa', '0987654321', 1, SYSDATETIME(), SYSDATETIME());
END

IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'guide3@tourbuddy.com')
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt, UpdatedAt)
    VALUES (3, 'guide3@tourbuddy.com', @hashed_pass, N'Lê Hoàng Phượt', '0905123456', 1, 1, SYSDATETIME(), SYSDATETIME());
    DECLARE @G3 INT = SCOPE_IDENTITY();

    INSERT INTO UserProfile (UserID, AvatarURL, Biography, DateOfBirth, Gender, Address, TravelInterests, UpdatedAt)
    VALUES (@G3, 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', N'Thích khám phá đại dương và các hòn đảo hoang sơ.', '1993-02-10', 'Male', N'Đà Nẵng', N'Lặn biển, Khám phá đảo', SYSDATETIME());

    INSERT INTO GuideProfile (UserID, YearsOfExperience, TotalToursLed, Rating, Bio, Specialization, Languages, Certifications, EmergencyPhone, IsActive, CreatedAt, UpdatedAt)
    VALUES (@G3, 7, 25, 4.9, N'HDV chuyên nghiệp tuyến biển đảo Nha Trang, Phú Quốc.', N'Lặn biển, Sinh tồn', N'Tiếng Việt, Tiếng Anh, Tiếng Nhật', N'Chứng chỉ HDV Quốc tế, Cứu hộ bờ biển', '0905123456', 1, SYSDATETIME(), SYSDATETIME());
END
GO


-- ============================================================
-- 4. SEED SCHEDULES & REVENUE DATA FOR DIVERSE CATEGORIES
-- ============================================================
PRINT '4. Seeding Schedules and Bookings...';

-- Clear old schedules and dependencies for clean seeding
DELETE FROM Review;
DELETE FROM BookingParticipant;
DELETE FROM Booking;
DELETE FROM TourSchedule;
GO

-- Seed Schedules for Tours 1-5
-- Tour 1 (Hạ Long - Cat 1)
INSERT INTO TourSchedule (TourID, DepartureDate, ReturnDate, TotalSeats, AvailableSeats, PriceAdult, PriceChild, PriceInfant, Status, TourStatus)
VALUES 
(1, '2026-07-10', '2026-07-12', 20, 15, 3900000, 1950000, 500000, 'Open', 'Scheduled'),
(1, '2026-08-15', '2026-08-17', 20, 20, 3900000, 1950000, 500000, 'Open', 'Scheduled');

-- Tour 2 (Đà Nẵng - Cat 1)
INSERT INTO TourSchedule (TourID, DepartureDate, ReturnDate, TotalSeats, AvailableSeats, PriceAdult, PriceChild, PriceInfant, Status, TourStatus)
VALUES (2, '2026-07-20', '2026-07-24', 25, 22, 4800000, 2400000, 500000, 'Open', 'Scheduled');

-- Tour 3 (Fansipan - Cat 2: Núi & Rừng)
INSERT INTO TourSchedule (TourID, DepartureDate, ReturnDate, TotalSeats, AvailableSeats, PriceAdult, PriceChild, PriceInfant, Status, TourStatus)
VALUES (3, '2026-07-05', '2026-07-07', 15, 13, 2800000, 1400000, 500000, 'Open', 'Scheduled');

-- Tour 4 (Huế - Cat 3: Văn hóa & Di sản)
INSERT INTO TourSchedule (TourID, DepartureDate, ReturnDate, TotalSeats, AvailableSeats, PriceAdult, PriceChild, PriceInfant, Status, TourStatus)
VALUES (4, '2026-07-12', '2026-07-15', 20, 17, 3100000, 1550000, 500000, 'Open', 'Scheduled');

-- Tour 5 (Hà Nội City Tour - Cat 4: City Tour)
INSERT INTO TourSchedule (TourID, DepartureDate, ReturnDate, TotalSeats, AvailableSeats, PriceAdult, PriceChild, PriceInfant, Status, TourStatus)
VALUES (5, '2026-07-01', '2026-07-01', 30, 26, 850000, 425000, 200000, 'Open', 'Scheduled');
GO

-- Seed Customers
IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'tuan.tran@gmail.com')
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified)
    VALUES (4, 'tuan.tran@gmail.com', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', N'Trần Anh Tuấn', '0901234567', 1, 1);
END
IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'thu.le@gmail.com')
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified)
    VALUES (4, 'thu.le@gmail.com', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', N'Lê Minh Thư', '0912345678', 1, 1);
END
IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'hoang.pham@gmail.com')
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified)
    VALUES (4, 'hoang.pham@gmail.com', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', N'Phạm Minh Hoàng', '0923456789', 1, 1);
END
GO

-- Fetch IDs for inserting Bookings
DECLARE @Cust1 INT, @Cust2 INT, @Cust3 INT;
SELECT @Cust1 = UserID FROM [User] WHERE Email = 'tuan.tran@gmail.com';
SELECT @Cust2 = UserID FROM [User] WHERE Email = 'thu.le@gmail.com';
SELECT @Cust3 = UserID FROM [User] WHERE Email = 'hoang.pham@gmail.com';

DECLARE @Sch1 INT, @Sch2 INT, @Sch3 INT, @Sch4 INT, @Sch5 INT, @Sch6 INT;
SELECT @Sch1 = ScheduleID FROM TourSchedule WHERE TourID = 1 AND DepartureDate = '2026-07-10';
SELECT @Sch2 = ScheduleID FROM TourSchedule WHERE TourID = 1 AND DepartureDate = '2026-08-15';
SELECT @Sch3 = ScheduleID FROM TourSchedule WHERE TourID = 2 AND DepartureDate = '2026-07-20';
SELECT @Sch4 = ScheduleID FROM TourSchedule WHERE TourID = 3 AND DepartureDate = '2026-07-05';
SELECT @Sch5 = ScheduleID FROM TourSchedule WHERE TourID = 4 AND DepartureDate = '2026-07-12';
SELECT @Sch6 = ScheduleID FROM TourSchedule WHERE TourID = 5 AND DepartureDate = '2026-07-01';

-- Insert Bookings (Beach & Island Category - Tour 1 & 2)
INSERT INTO Booking (BookingCode, ScheduleID, CustomerID, NumParticipants, BaseAmount, VATAmount, DiscountAmount, TotalAmount, Status, Notes, CreatedAt, UpdatedAt) VALUES
('BK001', @Sch1, @Cust1, 2, 7560000.00, 0, 0, 7560000.00, 'Completed', 'Seeded booking', SYSDATETIME(), SYSDATETIME()),
('BK002', @Sch1, @Cust2, 1, 3780000.00, 0, 0, 3780000.00, 'Completed', 'Seeded booking', SYSDATETIME(), SYSDATETIME()),
('BK003', @Sch2, @Cust2, 2, 9072000.00, 0, 0, 9072000.00, 'Completed', 'Seeded booking', SYSDATETIME(), SYSDATETIME()),
('BK004', @Sch3, @Cust3, 1, 3024000.00, 0, 0, 3024000.00, 'Completed', 'Seeded booking', SYSDATETIME(), SYSDATETIME());

-- Insert Bookings (Mountain & Forest Category - Tour 3)
INSERT INTO Booking (BookingCode, ScheduleID, CustomerID, NumParticipants, BaseAmount, VATAmount, DiscountAmount, TotalAmount, Status, Notes, CreatedAt, UpdatedAt) VALUES
('BK005', @Sch4, @Cust1, 2, 5600000.00, 0, 0, 5600000.00, 'Completed', 'Seeded mountain tour booking', SYSDATETIME(), SYSDATETIME());

-- Insert Bookings (Culture & Heritage Category - Tour 4)
INSERT INTO Booking (BookingCode, ScheduleID, CustomerID, NumParticipants, BaseAmount, VATAmount, DiscountAmount, TotalAmount, Status, Notes, CreatedAt, UpdatedAt) VALUES
('BK006', @Sch5, @Cust2, 3, 9300000.00, 0, 0, 9300000.00, 'Completed', 'Seeded cultural tour booking', SYSDATETIME(), SYSDATETIME());

-- Insert Bookings (City Tour Category - Tour 5)
INSERT INTO Booking (BookingCode, ScheduleID, CustomerID, NumParticipants, BaseAmount, VATAmount, DiscountAmount, TotalAmount, Status, Notes, CreatedAt, UpdatedAt) VALUES
('BK007', @Sch6, @Cust3, 4, 3400000.00, 0, 0, 3400000.00, 'Completed', 'Seeded city tour booking', SYSDATETIME(), SYSDATETIME());
GO

PRINT 'All Migrations and Seeds successfully executed!';
GO

GO
EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all';
GO

USE TourBuddyDB;
GO

DELETE FROM Role_Permission;
DELETE FROM Permission;

DBCC CHECKIDENT ('Permission', RESEED, 0);

INSERT INTO Permission (ModuleName, Action, Description, IsCritical) VALUES
('Tour Management', 'Read', N'View Tour', 0),
('Tour Management', 'Create', N'Create Tour', 0),
('Tour Management', 'Update', N'Update Tour', 0),
('Tour Management', 'Delete', N'Delete Tour', 1),

('Booking Management', 'Read', N'View Booking', 0),
('Booking Management', 'Create', N'Create Booking', 0),
('Booking Management', 'Update', N'Update Booking', 0),
('Booking Management', 'Delete', N'Delete Booking', 1),

('User Management', 'Read', N'View Users', 0),
('User Management', 'Create', N'Create Users', 0),
('User Management', 'Update', N'Update Users', 0),
('User Management', 'Delete', N'Delete Users', 1),

('Role Management', 'Read', N'View Roles', 1),
('Role Management', 'Create', N'Create Roles', 1),
('Role Management', 'Update', N'Update Roles', 1),
('Role Management', 'Delete', N'Delete Roles', 1),

('Matching Management', 'Read', N'View Matching', 0),
('Matching Management', 'Create', N'Create Matching', 0),
('Matching Management', 'Update', N'Update Matching', 0),
('Matching Management', 'Delete', N'Delete Matching', 0),

('Request Management', 'Read', N'View Requests', 0),
('Request Management', 'Create', N'Create Requests', 0),
('Request Management', 'Update', N'Update Requests', 0),
('Request Management', 'Delete', N'Delete Requests', 0),

('Review Management', 'Read', N'View Reviews', 0),
('Review Management', 'Create', N'Create Reviews', 0),
('Review Management', 'Update', N'Update Reviews', 0),
('Review Management', 'Delete', N'Delete Reviews', 0),

('Payment Management', 'Read', N'View Payments', 0),
('Payment Management', 'Create', N'Create Payments', 0),
('Payment Management', 'Update', N'Update Payments', 0),
('Payment Management', 'Delete', N'Delete Payments', 1),

('System Settings', 'Read', N'View Reports', 1),
('System Settings', 'Export', N'Export Reports', 1),

('Content Management', 'Read', N'View Content', 0),
('Content Management', 'Create', N'Create Content', 0),
('Content Management', 'Update', N'Update Content', 0),
('Content Management', 'Delete', N'Delete Content', 1);

INSERT INTO Role_Permission (RoleID, PermissionID)
SELECT 1, PermissionID FROM Permission;
GO
