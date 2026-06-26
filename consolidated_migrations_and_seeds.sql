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
