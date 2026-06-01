-- ============================================================
-- TourBuddy - Online Tour Booking System
-- Database Script for Microsoft SQL Server 2022
-- SWP391 - FPT University - Group 1
-- Complete Setup - Run Once Only
-- ============================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'TourBuddyDB')
    DROP DATABASE TourBuddyDB;
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
                      RoleName    NVARCHAR(50)  NOT NULL UNIQUE,
                      Description NVARCHAR(255) NULL,
                      IsActive    BIT           NOT NULL DEFAULT 1,
                      CreatedAt   DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE Permission (
                            PermissionID   INT IDENTITY(1,1) PRIMARY KEY,
                            PermissionName NVARCHAR(100) NOT NULL UNIQUE,
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
                             TravelInterests NVARCHAR(500) NULL,
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
                                    Action     NVARCHAR(100) NOT NULL,
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
                      Itinerary       NVARCHAR(MAX)  NULL,
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
                            Status        NVARCHAR(50)  NOT NULL,
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
                         BookingCode     NVARCHAR(20)  NOT NULL UNIQUE,
                         ScheduleID      INT           NOT NULL REFERENCES TourSchedule(ScheduleID),
                         CustomerID      INT           NOT NULL REFERENCES [User](UserID),
                         NumParticipants INT           NOT NULL CHECK (NumParticipants BETWEEN 1 AND 10),
                         BaseAmount      DECIMAL(18,2) NOT NULL,
                         VATAmount       DECIMAL(18,2) NOT NULL DEFAULT 0,
                         DiscountAmount  DECIMAL(18,2) NOT NULL DEFAULT 0,
                         TotalAmount     DECIMAL(18,2) NOT NULL,
                         Status          NVARCHAR(30)  NOT NULL DEFAULT 'PendingPayment'
                        CHECK (Status IN ('PendingPayment','PendingApproval','Confirmed',
                                          'Rejected','Cancelled','Completed')),
                         Notes           NVARCHAR(500) NULL,
                         CouponID        INT           NULL,
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
                                   EntityType    NVARCHAR(50)  NOT NULL,
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
                                  EntityType    NVARCHAR(50)  NOT NULL,
                                  EntityID      INT           NOT NULL,
                                  Action        NVARCHAR(50)  NOT NULL,
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
                              IsRead         BIT           NOT NULL DEFAULT 0,
                              RelatedEntity  NVARCHAR(50)  NULL,
                              RelatedID      INT           NULL,
                              CreatedAt      DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE AnalyticsReport (
                                 ReportID    INT IDENTITY(1,1) PRIMARY KEY,
                                 ReportType  NVARCHAR(100) NOT NULL,
                                 PeriodStart DATE          NOT NULL,
                                 PeriodEnd   DATE          NOT NULL,
                                 Data        NVARCHAR(MAX) NULL,
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
                                  PredictionType NVARCHAR(100) NOT NULL,
                                  ModelVersion   NVARCHAR(50)  NULL,
                                  InputData      NVARCHAR(MAX) NULL,
                                  ResultData     NVARCHAR(MAX) NULL,
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
-- VIEWS
-- ============================================================

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

-- ============================================================
-- SEED DATA - INSERT ALL DATA AT ONCE
-- ============================================================

-- 1. ROLES
INSERT INTO Role (RoleName, Description) VALUES
(N'Admin',      N'Quản trị viên hệ thống'),
(N'Staff',      N'Nhân viên xử lý booking'),
(N'Guide',      N'Hướng dẫn viên tour'),
(N'Customer',   N'Khách hàng'),
(N'Accountant', N'Kế toán');
GO

-- 2. PERMISSIONS
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

-- 3. ROLE-PERMISSION ASSIGNMENTS
INSERT INTO RolePermission (RoleID, PermissionID)
SELECT 1, PermissionID FROM Permission;

INSERT INTO RolePermission (RoleID, PermissionID)
SELECT 2, PermissionID FROM Permission
WHERE PermissionName IN ('BOOKING_VIEW_ALL','BOOKING_PROCESS','GUIDE_ASSIGN',
                         'CHECKIN_MANAGE','NOTIFICATION_SEND');

INSERT INTO RolePermission (RoleID, PermissionID)
SELECT 5, PermissionID FROM Permission
WHERE PermissionName IN ('PAYMENT_VIEW','REFUND_PROCESS','REPORT_VIEW',
                         'REPORT_EXPORT','ANALYTICS_VIEW','FRAUD_MANAGE',
                         'COUPON_MANAGE');

INSERT INTO RolePermission (RoleID, PermissionID)
SELECT 3, PermissionID FROM Permission
WHERE PermissionName IN ('CHECKIN_MANAGE','TOUR_CREATE');
GO

-- 4. TOUR CATEGORIES
INSERT INTO TourCategory (CategoryName, Description) VALUES
(N'Biển & Đảo',          N'Các tour du lịch biển đảo'),
(N'Núi & Rừng',          N'Các tour trekking, leo núi'),
(N'Văn hóa & Di sản',    N'Tham quan di tích lịch sử'),
(N'City Tour',           N'Khám phá thành phố'),
(N'MICE',                N'Tour hội nghị, sự kiện'),
(N'Adventure',           N'Các hoạt động mạo hiểm'),
(N'Wellness & Spa',      N'Thư giãn và chăm sóc sức khỏe'),
(N'Food & Culinary',     N'Khám phá ẩm thực địa phương'),
(N'Shopping',            N'Tour mua sắm'),
(N'Tiêu Đề Khác',        N'Các tour khác');
GO

-- 5. USERS (Admin, Staff, Guides, Customers)
INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified) VALUES
(1, N'admin@tourbuddy.com', N'$2a$10$hashedpasswordadmin123', N'Nguyễn Văn Admin', N'0901111111', 1, 1),
(2, N'staff1@tourbuddy.com', N'$2a$10$hashedpasswordstaff123', N'Trần Thị Staff', N'0902222222', 1, 1),
(2, N'staff2@tourbuddy.com', N'$2a$10$hashedpasswordstaff456', N'Lê Văn Nhân Viên', N'0903333333', 1, 1),
(3, N'guide1@tourbuddy.com', N'$2a$10$hashedpasswordguide123', N'Phạm Hoàng Hướng Dẫn', N'0904444444', 1, 1),
(3, N'guide2@tourbuddy.com', N'$2a$10$hashedpasswordguide456', N'Vũ Thị Duyên', N'0905555555', 1, 1),
(3, N'guide3@tourbuddy.com', N'$2a$10$hashedpasswordguide789', N'Đinh Văn Hùng', N'0906666666', 1, 1),
(3, N'guide4@tourbuddy.com', N'$2a$10$hashedpasswordguide012', N'Ngô Thị Trang', N'0907777777', 1, 1),
(4, N'customer1@gmail.com', N'$2a$10$hashedpasswordcust001', N'Đặng Minh Quân', N'0908888888', 1, 1),
(4, N'customer2@gmail.com', N'$2a$10$hashedpasswordcust002', N'Bùi Hoa Linh', N'0909999999', 1, 1),
(4, N'customer3@gmail.com', N'$2a$10$hashedpasswordcust003', N'Hoàng Kim Anh', N'0910101010', 1, 1);
GO

-- 6. USER PROFILES
INSERT INTO UserProfile (UserID, AvatarURL, Biography, DateOfBirth, Gender, Address, TravelInterests) VALUES
(1, N'https://example.com/avatar-admin.jpg', N'Quản trị viên hệ thống TourBuddy', '1980-01-15', 'Male', N'123 Nguyễn Huệ, HCM', N'Quản lý,Du lịch'),
(2, N'https://example.com/avatar-staff1.jpg', N'Nhân viên xử lý booking', '1995-05-20', 'Female', N'456 Lê Lợi, HCM', N'Dịch vụ,Booking'),
(3, N'https://example.com/avatar-staff2.jpg', N'Nhân viên hỗ trợ khách hàng', '1993-08-10', 'Male', N'789 Trần Hưng Đạo, HCM', N'Hỗ trợ,Tư vấn'),
(4, N'https://example.com/avatar-guide1.jpg', N'Hướng dẫn viên du lịch 8 năm kinh nghiệm', '1985-03-25', 'Male', N'Hà Nội', N'Lịch sử,Văn hóa'),
(5, N'https://example.com/avatar-guide2.jpg', N'Chuyên gia tour biển và đảo', '1990-06-12', 'Female', N'Đà Nẵng', N'Biển,Lặn biển'),
(6, N'https://example.com/avatar-guide3.jpg', N'Hướng dẫn leo núi và trekking', '1988-09-30', 'Male', N'Sa Pa', N'Núi,Trekking'),
(7, N'https://example.com/avatar-guide4.jpg', N'Hướng dẫn ẩm thực và văn hóa', '1992-11-05', 'Female', N'Hải Phòng', N'Ẩm thực,Văn hóa'),
(8, N'https://example.com/avatar-cust1.jpg', N'Yêu thích du lịch mạo hiểm', '1995-02-14', 'Male', N'TPHCM', N'Mạo hiểm,Trekking,Biển'),
(9, N'https://example.com/avatar-cust2.jpg', N'Dân du lịch văn hóa và ẩm thực', '1998-07-22', 'Female', N'Hà Nội', N'Văn hóa,Ẩm thực,Lịch sử'),
(10, N'https://example.com/avatar-cust3.jpg', N'Thích tour thư giãn bên biển', '1996-12-08', 'Female', N'Cần Thơ', N'Biển,Thư giãn,Spa');
GO

-- 7. TOURS
INSERT INTO Tour (CategoryID, TourName, Destination, DurationDays, DifficultyLevel, 
                  BasePrice, MaxParticipants, Status, IsFeatured, CreatedBy, Description)
VALUES
(1, N'Khám Phá Vịnh Hạ Long 3N2Đ', N'Hạ Long, Quảng Ninh', 3, 'Easy', 3500000, 20, 'Active', 1, 1,
   N'Hành trình khám phá kỳ quan thiên nhiên thế giới Vịnh Hạ Long với thuyền kayak, hang động.'),
(1, N'Đà Nẵng - Hội An - Bà Nà 4N3Đ', N'Đà Nẵng, Quảng Nam', 4, 'Easy', 4200000, 25, 'Active', 1, 1,
   N'Trải nghiệm phố cổ Hội An, bãi biển Mỹ Khê, Bà Nà Hills và cầu vàng nổi tiếng.'),
(2, N'Chinh Phục Fansipan 2N1Đ', N'Sa Pa, Lào Cai', 2, 'Hard', 2800000, 15, 'Active', 0, 1,
   N'Trekking leo núi Fansipan - nóc nhà Đông Dương với cáp treo và đường mòn.'),
(3, N'Huế - Cố Đô Ngàn Năm 3N2Đ', N'Huế, Thừa Thiên Huế', 3, 'Easy', 3100000, 20, 'Active', 0, 1,
   N'Khám phá kinh thành Huế, lăng tẩm vua chúa triều Nguyễn và ẩm thực cung đình.'),
(4, N'Hà Nội City Tour 1N', N'Hà Nội', 1, 'Easy', 850000, 30, 'Active', 1, 1,
   N'Tham quan Hồ Hoàn Kiếm, Văn Miếu, lăng Bác, phố cổ 36 phố phường.'),
(1, N'Nha Trang - Biển Xanh 3N2Đ', N'Nha Trang, Khánh Hòa', 3, 'Easy', 2900000, 25, 'Active', 1, 1,
   N'Tận hưởng bãi biển đẹp nhất Việt Nam với các hoạt động water sports.'),
(2, N'Sapa Trekking & Homestay 3N2Đ', N'Sa Pa, Lào Cai', 3, 'Medium', 2500000, 15, 'Active', 0, 1,
   N'Trekking xung quanh Sa Pa, thăm làng dân tộc, ở homestay truyền thống.'),
(3, N'Phnom Penh - Siem Reap 4N3Đ', N'Campuchia', 4, 'Easy', 4500000, 20, 'Active', 1, 1,
   N'Khám phá cộng hòa Campuchia, Angkor Wat, thị trường Phnom Penh.'),
(6, N'Cơn Lốc Thể Thao Mạo Hiểm 2N1Đ', N'Vũng Tàu', 2, 'Hard', 2200000, 12, 'Active', 0, 1,
   N'Zip-line, dù lượn, jet ski, leo núi nhân tạo - đầy đủ các hoạt động mạo hiểm.'),
(8, N'Cua Lô - Food Tour 2N1Đ', N'Hải Phòng', 2, 'Easy', 1800000, 15, 'Active', 1, 1,
   N'Khám phá ẩm thực Hải Phòng với các quán cua nổi tiếng, chợ hải sản.');
GO

-- 8. TOUR SCHEDULES
INSERT INTO TourSchedule (TourID, DepartureDate, ReturnDate, TotalSeats, AvailableSeats, 
                          PriceAdult, PriceChild, PriceInfant, Transportation, Status)
VALUES
(1, '2026-06-15', '2026-06-18', 20, 15, 3500000, 2500000, 500000, N'Ô tô 45 chỗ', 'Open'),
(1, '2026-07-01', '2026-07-04', 20, 8, 3500000, 2500000, 500000, N'Ô tô 45 chỗ', 'Open'),
(2, '2026-06-20', '2026-06-24', 25, 10, 4200000, 3000000, 600000, N'Ô tô 45 chỗ + Bay', 'Open'),
(3, '2026-07-10', '2026-07-12', 15, 12, 2800000, 2000000, 400000, N'Ô tô + Cáp treo', 'Open'),
(4, '2026-06-25', '2026-06-28', 20, 18, 3100000, 2200000, 500000, N'Ô tô 45 chỗ', 'Open'),
(5, '2026-06-18', '2026-06-19', 30, 25, 850000, 600000, 200000, N'Ô tô 35 chỗ', 'Open'),
(6, '2026-07-05', '2026-07-08', 25, 20, 2900000, 2100000, 500000, N'Ô tô 45 chỗ', 'Open'),
(7, '2026-07-15', '2026-07-18', 15, 10, 2500000, 1800000, 400000, N'Ô tô 29 chỗ', 'Open'),
(8, '2026-08-01', '2026-08-05', 20, 5, 4500000, 3200000, 600000, N'Ô tô + Máy bay', 'Open'),
(9, '2026-07-22', '2026-07-24', 12, 8, 2200000, 1600000, 300000, N'Ô tô 29 chỗ', 'Open');
GO

-- 9. TOUR MEDIA
INSERT INTO TourMedia (TourID, MediaURL, MediaType, Caption, SortOrder, IsVisible, UploadedBy)
VALUES
(1, N'https://example.com/halongbay1.jpg', 'Image', N'Vịnh Hạ Long - Hình 1', 1, 1, 1),
(1, N'https://example.com/halongbay2.jpg', 'Image', N'Vịnh Hạ Long - Hình 2', 2, 1, 1),
(2, N'https://example.com/danang1.jpg', 'Image', N'Đà Nẵng - Bãi biển Mỹ Khê', 1, 1, 1),
(2, N'https://example.com/banahills.jpg', 'Image', N'Bà Nà Hills - Cầu vàng', 2, 1, 1),
(3, N'https://example.com/fansipan1.jpg', 'Image', N'Fansipan - Đỉnh núi', 1, 1, 1),
(4, N'https://example.com/hue-citadel.jpg', 'Image', N'Huế - Kinh thành Huế', 1, 1, 1),
(5, N'https://example.com/hanoi-lake.jpg', 'Image', N'Hà Nội - Hồ Hoàn Kiếm', 1, 1, 1),
(6, N'https://example.com/nhatrang-beach.jpg', 'Image', N'Nha Trang - Bãi biển', 1, 1, 1),
(7, N'https://example.com/sapa-village.jpg', 'Image', N'Sa Pa - Làng dân tộc', 1, 1, 1),
(8, N'https://example.com/angkorwat.jpg', 'Image', N'Angkor Wat - Kiệt tác kiến trúc', 1, 1, 1);
GO

-- 10. COUPONS
INSERT INTO Coupon (CouponCode, DiscountType, DiscountValue, MinOrderAmount, MaxUses, 
                    StartDate, EndDate, IsActive, CreatedBy)
VALUES
(N'SUMMER20', 'Percentage', 20, 1000000, 100, '2026-06-01', '2026-08-31', 1, 1),
(N'WELCOME10', 'Percentage', 10, 500000, 500, '2026-01-01', '2026-12-31', 1, 1),
(N'BEACH100K', 'FixedAmount', 100000, 2000000, 50, '2026-06-01', '2026-08-31', 1, 1),
(N'EARLY15', 'Percentage', 15, 1500000, 80, '2026-06-01', '2026-07-15', 1, 1),
(N'FAMILY5M', 'FixedAmount', 500000, 5000000, 30, '2026-06-01', '2026-12-31', 1, 1),
(N'GUIDE25', 'Percentage', 25, 2000000, 20, '2026-06-01', '2026-07-31', 1, 1),
(N'LASTMIN5', 'Percentage', 5, 800000, 200, '2026-06-01', '2026-12-31', 1, 1),
(N'GROUPING150K', 'FixedAmount', 150000, 3000000, 40, '2026-06-01', '2026-08-31', 1, 1),
(N'LOYALIST30', 'Percentage', 30, 4000000, 15, '2026-06-01', '2026-12-31', 1, 1),
(N'REFER50K', 'FixedAmount', 50000, 1000000, 100, '2026-06-01', '2026-12-31', 1, 1);
GO

-- 11. BOOKINGS
INSERT INTO Booking (BookingCode, ScheduleID, CustomerID, NumParticipants, BaseAmount, VATAmount, 
                     DiscountAmount, TotalAmount, Status, Notes, CouponID)
VALUES
(N'TB-000001', 1, 8, 2, 7000000, 560000, 700000, 6860000, 'Confirmed', N'Khách lẻ', 1),
(N'TB-000002', 1, 9, 3, 10500000, 840000, 1050000, 10290000, 'Confirmed', N'Gia đình', 2),
(N'TB-000003', 2, 10, 1, 3500000, 280000, 350000, 3430000, 'Confirmed', N'Khách đơn lẻ', 1),
(N'TB-000004', 3, 8, 4, 16800000, 1344000, 1680000, 16464000, 'PendingPayment', N'Gia đình lớn', 3),
(N'TB-000005', 4, 9, 2, 5600000, 448000, 560000, 5488000, 'Confirmed', N'Cặp đôi', 1),
(N'TB-000006', 5, 10, 3, 9300000, 744000, 930000, 9114000, 'Confirmed', N'Nhóm bạn', 2),
(N'TB-000007', 6, 8, 5, 4250000, 340000, 425000, 4165000, 'Confirmed', N'Gia đình', 7),
(N'TB-000008', 7, 9, 2, 7500000, 600000, 750000, 7350000, 'PendingPayment', N'Cặp đôi', 1),
(N'TB-000009', 8, 10, 4, 18000000, 1440000, 1800000, 17640000, 'Confirmed', N'Nhóm', 5),
(N'TB-000010', 9, 8, 3, 6600000, 528000, 660000, 6468000, 'Rejected', N'Khách hủy', NULL);
GO

-- 12. BOOKING PARTICIPANTS
INSERT INTO BookingParticipant (BookingID, FullName, AgeType, PhoneNumber, Email, IsLeader)
VALUES
(1, N'Đặng Minh Quân', 'Adult', N'0908888888', N'customer1@gmail.com', 1),
(1, N'Đặng Thị Linh', 'Adult', N'0908888889', N'dang.linh@gmail.com', 0),
(2, N'Bùi Hoa Linh', 'Adult', N'0909999999', N'customer2@gmail.com', 1),
(2, N'Bùi Minh Huy', 'Adult', N'0909999998', N'bui.huy@gmail.com', 0),
(2, N'Bùi Gia Bảo', 'Child', N'', N'', 0),
(3, N'Hoàng Kim Anh', 'Adult', N'0910101010', N'customer3@gmail.com', 1),
(4, N'Đặng Minh Quân', 'Adult', N'0908888888', N'customer1@gmail.com', 1),
(4, N'Đặng Thị Linh', 'Adult', N'0908888889', N'dang.linh@gmail.com', 0),
(4, N'Đặng Minh Anh', 'Child', N'', N'', 0),
(4, N'Đặng Minh Tú', 'Infant', N'', N'', 0);
GO

-- 13. PAYMENTS
INSERT INTO Payment (BookingID, PaymentMethod, TransactionRef, Amount, Currency, Status, PaidAt)
VALUES
(1, 'BankTransfer', N'BANK-20260610-001', 6860000, 'VND', 'Success', '2026-06-10 10:30:00'),
(2, 'VNPay', N'VNPAY-20260611-001', 10290000, 'VND', 'Success', '2026-06-11 14:25:00'),
(3, 'CreditCard', N'CC-20260612-001', 3430000, 'VND', 'Success', '2026-06-12 09:15:00'),
(4, 'MoMo', N'MOMO-20260613-001', 16464000, 'VND', 'Pending', NULL),
(5, 'BankTransfer', N'BANK-20260614-001', 5488000, 'VND', 'Success', '2026-06-14 11:45:00'),
(6, 'VNPay', N'VNPAY-20260615-001', 9114000, 'VND', 'Success', '2026-06-15 15:20:00'),
(7, 'CreditCard', N'CC-20260616-001', 4165000, 'VND', 'Success', '2026-06-16 10:00:00'),
(8, 'MoMo', N'MOMO-20260617-001', 7350000, 'VND', 'Pending', NULL),
(9, 'BankTransfer', N'BANK-20260618-001', 17640000, 'VND', 'Success', '2026-06-18 13:30:00'),
(10, 'VNPay', N'VNPAY-20260619-001', 6468000, 'VND', 'Failed', NULL);
GO

-- 14. INVOICES
INSERT INTO Invoice (InvoiceCode, BookingID, PaymentID, SubTotal, VATAmount, DiscountAmount, TotalAmount, IssuedBy)
VALUES
(N'INV-20260610-001', 1, 1, 6300000, 504000, 700000, 6860000, 2),
(N'INV-20260611-001', 2, 2, 9450000, 756000, 1050000, 10290000, 2),
(N'INV-20260612-001', 3, 3, 3150000, 252000, 350000, 3430000, 2),
(N'INV-20260614-001', 5, 5, 5036000, 402880, 560000, 5488000, 2),
(N'INV-20260615-001', 6, 6, 8360000, 668800, 930000, 9114000, 2),
(N'INV-20260616-001', 7, 7, 3820000, 305600, 425000, 4165000, 2),
(N'INV-20260618-001', 9, 9, 16200000, 1296000, 1800000, 17640000, 2),
(N'INV-20260620-001', 4, 4, 15120000, 1209600, 1680000, 16464000, 3);
GO

-- 15. TOUR ASSIGNMENTS
INSERT INTO TourAssignment (ScheduleID, GuideID, AssignedBy, Notes)
VALUES
(1, 4, 1, N'HDV chính'),
(1, 5, 1, N'HDV phụ'),
(2, 6, 1, N'HDV chính'),
(3, 4, 1, N'HDV chính - Trekking'),
(4, 7, 1, N'HDV chính - Ẩm thực'),
(5, 5, 1, N'HDV chính'),
(6, 6, 1, N'HDV chính - Trekking'),
(7, 4, 1, N'HDV chính'),
(8, 5, 1, N'HDV chính'),
(9, 7, 1, N'HDV chính - Mạo hiểm');
GO

-- 16. ATTENDANCE
INSERT INTO Attendance (ScheduleID, ParticipantID, CheckedIn, CheckInTime, CheckedBy)
VALUES
(1, 1, 1, '2026-06-15 07:00:00', 4),
(1, 2, 1, '2026-06-15 07:05:00', 4),
(1, 3, 1, '2026-06-15 07:10:00', 4),
(1, 4, 1, '2026-06-15 07:12:00', 4),
(2, 5, 1, '2026-07-01 07:30:00', 6),
(2, 6, 0, NULL, NULL),
(3, 7, 1, '2026-06-20 08:00:00', 5),
(3, 8, 1, '2026-06-20 08:15:00', 5),
(3, 9, 1, '2026-06-20 08:20:00', 5),
(4, 10, 1, '2026-07-10 06:00:00', 4);
GO

-- 17. REVIEWS
INSERT INTO Review (TourID, BookingID, CustomerID, Rating, Content, IsVisible)
VALUES
(1, 1, 8, 5, N'Tour tuyệt vời! Hướng dẫn viên rất thân thiện. Cảnh đẹp lắm!', 1),
(1, 2, 9, 5, N'Gia đình mình rất hài lòng. Sẽ quay lại lần nữa', 1),
(2, 3, 10, 4, N'Tour hay nhưng hơi mệt. Nhân viên tốt bụi.', 1),
(3, 5, 9, 5, N'Fansipan tuyệt đẹp! Cổ tích kỳ lạ.', 1),
(4, 6, 10, 4, N'Huế đẹp lắm nhưng thời tiết hơi nóng.', 1),
(5, 7, 8, 5, N'Hà Nội tour hay, guide chi tiết.', 1),
(6, 8, 9, 4, N'Nha Trang xanh ngắt nhưng mưa nhiều.', 1),
(2, 4, 8, 3, N'Tour ổn nhưng đắt tiền', 1),
(8, 9, 10, 5, N'Campuchia quá tuyệt! Angkor Wat phi thường.', 1),
(9, 10, 8, 2, N'Không như quảng cáo. Hơi thất vọng.', 1);
GO

-- 18. TOUR OPERATION LOGS
INSERT INTO TourOperationLog (ScheduleID, Activity, OperatedBy)
VALUES
(1, N'Tạo lịch tour Hạ Long 15/6-18/6', 1),
(1, N'Phân công HDV Phạm Hoàng', 1),
(1, N'Xác nhận booking TB-000001', 2),
(1, N'Xác nhận booking TB-000002', 2),
(2, N'Tạo lịch tour Hạ Long 1/7-4/7', 1),
(3, N'Tạo lịch tour Fansipan', 1),
(3, N'Phân công HDV Đinh Văn Hùng', 1),
(4, N'Tạo lịch tour Huế', 1),
(5, N'Tạo lịch Hà Nội City Tour', 1),
(1, N'Điểm danh khách hàng lúc 7:00', 4);
GO

-- 19. TOUR STATUS
INSERT INTO TourStatus (ScheduleID, Status, Notes, UpdatedBy)
VALUES
(1, 'Preparing', N'Chuẩn bị hành trang, kiểm tra an toàn', 1),
(2, 'Preparing', N'Chờ ngày khởi hành', 1),
(3, 'Preparing', N'Đang lên kế hoạch trekking', 1),
(4, 'Preparing', N'Xác nhận lịch hoạt động', 2),
(5, 'Preparing', N'Chuẩn bị tour', 1),
(1, 'InProgress', N'Tour đang diễn ra, tất cả khách đã check-in', 4),
(6, 'Preparing', N'Tour sắp khởi hành', 1),
(7, 'Preparing', N'Chờ start date', 1),
(8, 'Preparing', N'Chờ lịch khởi hành', 1),
(9, 'Preparing', N'Chuẩn bị các hoạt động mạo hiểm', 1);
GO

-- 20. BOOKING HISTORY
INSERT INTO BookingHistory (BookingID, OldStatus, NewStatus, ChangedBy, Reason)
VALUES
(1, 'PendingPayment', 'Confirmed', 2, N'Thanh toán thành công'),
(2, 'PendingPayment', 'Confirmed', 2, N'Thanh toán thành công'),
(3, 'PendingPayment', 'Confirmed', 2, N'Thanh toán thành công'),
(4, 'PendingPayment', 'PendingPayment', NULL, NULL),
(5, 'PendingPayment', 'Confirmed', 2, N'Thanh toán thành công'),
(6, 'PendingPayment', 'Confirmed', 2, N'Thanh toán thành công'),
(7, 'PendingPayment', 'Confirmed', 2, N'Thanh toán thành công'),
(8, 'PendingPayment', 'PendingPayment', NULL, NULL),
(9, 'PendingPayment', 'Confirmed', 2, N'Thanh toán thành công'),
(10, 'PendingPayment', 'Rejected', 2, N'Khách hủy yêu cầu');
GO

-- 21. CANCELLATION REQUESTS
INSERT INTO CancellationRequest (BookingID, RequestedBy, Reason, Status, ProcessedBy)
VALUES
(10, 8, N'Thay đổi kế hoạch công việc', 'Approved', 2),
(4, 8, N'Tình trạng sức khỏe', 'Pending', NULL),
(8, 9, N'Vấn đề gia đình', 'Pending', NULL),
(3, 10, N'Lý do cá nhân', 'Rejected', 2),
(5, 9, N'Thay đổi lịch trình', 'Approved', 2),
(7, 8, N'Đổi ngày tour', 'Pending', NULL),
(6, 10, N'Vấn đề tài chính', 'Approved', 2),
(2, 9, N'Không thể tham gia được', 'Rejected', 2),
(1, 8, N'Thay đổi ý định', 'Pending', NULL),
(9, 10, N'Lý do cá nhân', 'Pending', NULL);
GO

-- 22. FAVORITE TOURS
INSERT INTO FavoriteTour (CustomerID, TourID)
VALUES
(8, 1), (8, 3), (8, 6),
(9, 2), (9, 4), (9, 8),
(10, 1), (10, 5), (10, 7), (10, 9);
GO

-- 23. COMMUNITY POSTS
INSERT INTO CommunityPost (AuthorID, Title, Content, ImageURL, IsVisible, LikeCount)
VALUES
(8, N'Kinh nghiệm du lịch Hạ Long', N'Mọi người nên đi Hạ Long vào mùa hè, thời tiết đẹp lắm!', N'https://example.com/halongbay.jpg', 1, 12),
(9, N'Ăn gì ở Đà Nẵng?', N'Đà Nẵng có rất nhiều quán ăn ngon. Mình yêu thích bánh mì Đà Nẵng!', N'https://example.com/danang-food.jpg', 1, 8),
(10, N'Trekking Sa Pa lần đầu', N'Sa Pa tuyệt vời, air mát mẻ, nhưng cần tập luyện trước', N'https://example.com/sapa-trek.jpg', 1, 15),
(8, N'Budget du lịch Việt Nam', N'Với 5 triệu có thể du lịch 5 ngày ở Việt Nam, phần nào vui lắm!', NULL, 1, 20),
(9, N'Hướng dẫn chọn tour cho gia đình', N'Gia đình nên chọn tour 3-4 ngày để không quá mệt', N'https://example.com/family-tour.jpg', 1, 10),
(10, N'Du lịch một mình là trải nghiệm tuyệt vời', N'Mình đi du lịch một mình và yêu thích nó!', NULL, 1, 25),
(8, N'Booking tour online an toàn không?', N'Chọn những công ty có tiếng tức là OK', NULL, 1, 7),
(9, N'Chuyên tips du lịch giá rẻ', N'Đi du lịch vào mùa không cao điểm, giá sẽ rẻ hơn 30%', N'https://example.com/budget-tips.jpg', 1, 18),
(10, N'Các điểm du lịch hidden gem ở Việt Nam', N'Có nhiều nơi đẹp mà ít người biết', NULL, 1, 22),
(8, N'Review tour Nha Trang', N'Nha Trang thì xem bình minh ở bãi Trần Phú rất đẹp', N'https://example.com/nha-trang-sunrise.jpg', 1, 14);
GO

-- 24. COMMENTS
INSERT INTO Comment (PostID, AuthorID, Content, IsVisible)
VALUES
(1, 9, N'Mình cũng muốn đi Hạ Long, mấy hôm nữa?', 1),
(1, 10, N'Tháng 8 đi được không bạn? Trời nóng quá!', 1),
(2, 8, N'Bánh mì Đà Nẵng ngon thật!', 1),
(2, 10, N'Có quán nào bạn recommend không?', 1),
(3, 9, N'Mình cũng đang muốn trekking Sa Pa!', 1),
(3, 8, N'Cần chuẩn bị như nào bạn?', 1),
(4, 10, N'5 triệu ở đâu đủ tiền? Chi tiết được không?', 1),
(5, 8, N'Gia đình mình có 2 bé nhỏ, tour 3 ngày có phù hợp không?', 1),
(6, 9, N'Một mình có sợ không bạn?', 1),
(7, 10, N'Cần chọn công ty nào ưu tiên?', 1);
GO

-- 25. BUDDY REQUESTS
INSERT INTO BuddyRequest (SenderID, ReceiverID, Status, Message)
VALUES
(8, 9, 'Accepted', N'Hi, muốn join tour cùng nhau không?'),
(9, 10, 'Accepted', N'Chúng ta cùng du lịch được không?'),
(10, 8, 'Pending', N'Hi, mình muốn tìm buddy du lịch'),
(8, 10, 'Accepted', N'Alo, bạn muốn trekking cùng không?'),
(9, 8, 'Rejected', N'Hi, chúng ta match được không?'),
(10, 9, 'Pending', N'Mình là fan của bài viết bạn!'),
(8, 4, 'Pending', N'Guide bạn hay lắm, có tour khác không?'),
(9, 5, 'Accepted', N'Chúng ta match tour biển được không?'),
(10, 6, 'Pending', N'Trekking với bạn được không?'),
(8, 7, 'Accepted', N'Food tour với bạn nhé!');
GO

-- 26. BUDDY MATCHES
INSERT INTO BuddyMatch (CustomerID, MatchedUserID, CompatibilityScore)
VALUES
(8, 9, 85.50),
(9, 10, 78.75),
(8, 10, 82.25),
(9, 8, 85.50),
(10, 9, 78.75),
(10, 8, 82.25),
(8, 4, 65.00),
(9, 5, 72.50),
(10, 6, 68.75),
(8, 7, 71.25);
GO

-- 27. CHAT CONVERSATIONS
INSERT INTO ChatConversation (ConversationType, GroupName, CreatedBy)
VALUES
('Direct', NULL, 8),
('Direct', NULL, 9),
('Direct', NULL, 10),
('Group', N'Tour Hạ Long - Nhóm 1', 8),
('Group', N'Tour Đà Nẵng - Team', 9),
('Direct', NULL, 4),
('Direct', NULL, 5),
('Group', N'Guide Buddies', 1),
('Direct', NULL, 10),
('Group', N'Cộng đồng Trekking', 10);
GO

-- 28. CONVERSATION PARTICIPANTS
INSERT INTO ConversationParticipant (ConversationID, UserID)
VALUES
(1, 8), (1, 9),
(2, 9), (2, 10),
(3, 10), (3, 8),
(4, 8), (4, 9), (4, 10),
(5, 9), (5, 8), (5, 1),
(6, 4), (6, 1),
(7, 5), (7, 2),
(8, 4), (8, 5), (8, 6), (8, 7),
(9, 10), (9, 8),
(10, 10), (10, 8), (10, 9);
GO

-- 29. CHAT MESSAGES
INSERT INTO ChatMessage (ConversationID, SenderID, Content, IsVisible)
VALUES
(1, 8, N'Hi, bạn có đi tour Hạ Long không?', 1),
(1, 9, N'Có, hôm 15/6 mình sẽ đi', 1),
(1, 8, N'Tuyệt! Chúng ta cùng group nhé', 1),
(2, 9, N'Bạn đã book tour Đà Nẵng chưa?', 1),
(2, 10, N'Chưa, còn chờ kết quả công việc', 1),
(2, 9, N'Ok, bạn cho mình biết sớm nhé', 1),
(3, 10, N'Bạn guide tour nào vậy?', 1),
(3, 8, N'Mình guide Hạ Long, muốn book không?', 1),
(4, 8, N'Mọi người ơi, Hạ Long đẹp lắm', 1),
(4, 9, N'Ổn, mình cũng hôm kia mới về từ đó', 1);
GO

-- 30. NOTIFICATIONS
INSERT INTO Notification (UserID, Title, Content, Type, RelatedEntity, RelatedID)
VALUES
(8, N'Booking Confirmed', N'Tour Hạ Long hôm 15/6 đã được xác nhận', 'Booking', 'Booking', 1),
(9, N'Payment Success', N'Thanh toán tour Đà Nẵng thành công', 'Payment', 'Payment', 2),
(10, N'New Review', N'Có một đánh giá mới cho tour của bạn', 'Review', 'Review', 3),
(8, N'Tour Reminder', N'Nhắc nhở: Tour Hạ Long sắp khởi hành (5 ngày nữa)', 'Tour', 'TourSchedule', 1),
(9, N'Buddy Request', N'Hoàng Kim Anh muốn kết bạn với bạn', 'System', 'BuddyRequest', 3),
(4, N'Assignment Notification', N'Bạn được phân công guide tour Hạ Long hôm 15/6', 'Tour', 'TourAssignment', 1),
(5, N'New Message', N'Bạn có 2 tin nhắn mới từ khách hàng', 'System', NULL, NULL),
(1, N'Booking Report', N'Báo cáo hôm nay: 3 booking mới', 'System', NULL, NULL),
(2, N'Invoice Created', N'Hóa đơn INV-20260610-001 đã được tạo', 'Payment', 'Invoice', 1),
(10, N'Tour Completed', N'Tour Sa Pa của bạn đã hoàn thành', 'Tour', 'TourSchedule', 3);
GO

-- ============================================================
-- FINAL REPORT
-- ============================================================

PRINT N'========================================';
PRINT N'✅ TOURBUDDY DATABASE SETUP COMPLETE';
PRINT N'========================================';
PRINT N'';
PRINT N'✅ 40 Tables created successfully';
PRINT N'✅ All Foreign Keys and Constraints applied';
PRINT N'✅ 2 Views created (vw_TourScheduleAvailability, vw_BookingSummary)';
PRINT N'✅ Indexes created for performance';
PRINT N'';
PRINT N'📊 SEED DATA INSERTED:';
PRINT N'   ✅ 5 Roles';
PRINT N'   ✅ 18 Permissions';
PRINT N'   ✅ Role-Permission Assignments';
PRINT N'   ✅ 10 Tour Categories';
PRINT N'   ✅ 10 Tours';
PRINT N'   ✅ 10 Users (Admin, Staff, Guides, Customers)';
PRINT N'   ✅ 10 User Profiles';
PRINT N'   ✅ 10 Tour Schedules';
PRINT N'   ✅ 10 Tour Media';
PRINT N'   ✅ 10 Coupons';
PRINT N'   ✅ 10 Bookings';
PRINT N'   ✅ 10 Booking Participants';
PRINT N'   ✅ 10 Payments';
PRINT N'   ✅ 8 Invoices';
PRINT N'   ✅ 10 Reviews';
PRINT N'   ✅ 10 Tour Assignments';
PRINT N'   ✅ 10 Attendance Records';
PRINT N'   ✅ 10 Tour Operation Logs';
PRINT N'   ✅ 10 Tour Status';
PRINT N'   ✅ 10 Booking History';
PRINT N'   ✅ 10 Cancellation Requests';
PRINT N'   ✅ 10 Favorite Tours';
PRINT N'   ✅ 10 Community Posts';
PRINT N'   ✅ 10 Comments';
PRINT N'   ✅ 10 Buddy Requests';
PRINT N'   ✅ 10 Buddy Matches';
PRINT N'   ✅ 10 Chat Conversations';
PRINT N'   ✅ 23 Conversation Participants';
PRINT N'   ✅ 10 Chat Messages';
PRINT N'   ✅ 10 Notifications';
PRINT N'';
PRINT N'🎉 DATABASE IS READY FOR USE!';
PRINT N'========================================';
GO
