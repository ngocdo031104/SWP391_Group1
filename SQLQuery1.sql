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