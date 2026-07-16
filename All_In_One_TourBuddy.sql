-- ============================================================
-- TourBuddy - Online Tour Booking System
-- Database Script for Microsoft SQL Server 2022
-- SWP391 - FPT University - Group 1
-- All-In-One CLEAN Script v2.0
--   * All migrations merged into base table definitions
--   * Duplicate tables removed (old Notification, old RolePermission, old Permission)
--   * GuideProfile table added (was missing, used by GuideDAO.java)
--   * Audit_Log table added (was missing, used by AuditLogDAO.java)
--   * BuddyRequest schema fixed (String status, PascalCase columns)
--   * Notifications table = single notification table (matches NotificationDAO.java)
--   * Role_Permission table name = matches RoleDAO.java
--   * Permission schema = ModuleName+Action = matches Permission.java
--   * TourSchedule.GuideID + TourAssignment both kept (GuideDAO uses both)
--   * Fixed: $insertSql typo removed
-- ============================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'TourBuddyDB')
BEGIN
    ALTER DATABASE TourBuddyDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TourBuddyDB;
END
GO

CREATE DATABASE TourBuddyDB COLLATE Vietnamese_CI_AS;
GO

USE TourBuddyDB;
GO

-- ============================================================
-- 1. ROLE
-- ============================================================

CREATE TABLE Role (
    RoleID       INT IDENTITY(1,1) PRIMARY KEY,
    RoleName     NVARCHAR(50)  NOT NULL UNIQUE,
    Description  NVARCHAR(255) NULL,
    IsActive     BIT           NOT NULL DEFAULT 1,
    IsSystemRole BIT           NOT NULL DEFAULT 0,
    CreatedAt    DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================================
-- 2. USER (must come before Audit_Log FK)
-- ============================================================

CREATE TABLE [User] (
    UserID       INT IDENTITY(1,1) PRIMARY KEY,
    RoleID       INT           NOT NULL REFERENCES Role(RoleID),
    Email        NVARCHAR(150) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(512) NOT NULL,
    FullName     NVARCHAR(100) NOT NULL,
    PhoneNumber  NVARCHAR(15)  NULL,
    IsActive     BIT           NOT NULL DEFAULT 1,
    IsVerified   BIT           NOT NULL DEFAULT 0,
    CreatedAt    DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt    DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    LastLoginAt  DATETIME2     NULL
);
GO

-- ============================================================
-- 3. PERMISSION & RBAC
--    Schema matches Permission.java: moduleName, action, isCritical
--    Table name: Role_Permission (matches RoleDAO.java)
--    Table name: Audit_Log (matches AuditLogDAO.java)
-- ============================================================

CREATE TABLE Permission (
    PermissionID INT IDENTITY(1,1) PRIMARY KEY,
    ModuleName   NVARCHAR(100) NOT NULL,
    Action       NVARCHAR(50)  NOT NULL,
    Description  NVARCHAR(255) NULL,
    IsCritical   BIT           NOT NULL DEFAULT 0,
    CreatedAt    DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_Permission UNIQUE (ModuleName, Action)
);
GO

CREATE TABLE Role_Permission (
    RoleID       INT NOT NULL REFERENCES Role(RoleID) ON DELETE CASCADE,
    PermissionID INT NOT NULL REFERENCES Permission(PermissionID) ON DELETE CASCADE,
    PRIMARY KEY (RoleID, PermissionID)
);
GO

-- Audit_Log: matches AuditLogDAO.java (INSERT INTO Audit_Log, SELECT FROM Audit_Log)
CREATE TABLE Audit_Log (
    LogID        INT IDENTITY(1,1) PRIMARY KEY,
    AdminID      INT           NOT NULL REFERENCES [User](UserID) ON DELETE NO ACTION,
    ActionType   NVARCHAR(100) NOT NULL,
    TargetRoleID INT           NULL,
    Details      NVARCHAR(500) NULL,
    CreatedAt    DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================================
-- 4. USER PROFILE & EXTENSIONS
-- ============================================================

CREATE TABLE UserProfile (
    ProfileID       INT IDENTITY(1,1) PRIMARY KEY,
    UserID          INT           NOT NULL UNIQUE REFERENCES [User](UserID),
    AvatarURL       NVARCHAR(500) NULL,
    Biography       NVARCHAR(MAX) NULL,
    DateOfBirth     DATE          NULL,
    Gender          NVARCHAR(10)  NULL CHECK (Gender IN ('Male','Female','Other')),
    Address         NVARCHAR(255) NULL,
    TravelInterests NVARCHAR(500) NULL,
    UpdatedAt       DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- GuideProfile: matches GuideProfile.java and GuideDAO.java
-- Columns: GuideProfileID, UserID, YearsOfExperience, TotalToursLed, Rating,
--          Bio, Specialization, Languages, Certifications, EmergencyPhone, IsActive, CreatedAt, UpdatedAt
CREATE TABLE GuideProfile (
    GuideProfileID    INT IDENTITY(1,1) PRIMARY KEY,
    UserID            INT           NOT NULL UNIQUE REFERENCES [User](UserID),
    YearsOfExperience INT           NOT NULL DEFAULT 0,
    TotalToursLed     INT           NOT NULL DEFAULT 0,
    Rating            DECIMAL(3,2)  NOT NULL DEFAULT 0.00,
    Bio               NVARCHAR(MAX) NULL,
    Specialization    NVARCHAR(500) NULL,
    Languages         NVARCHAR(500) NULL,
    Certifications    NVARCHAR(500) NULL,
    EmergencyPhone    NVARCHAR(20)  NULL,
    IsActive          BIT           NOT NULL DEFAULT 1,
    CreatedAt         DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt         DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE PasswordRecovery (
    RecoveryID INT IDENTITY(1,1) PRIMARY KEY,
    UserID     INT           NOT NULL REFERENCES [User](UserID),
    Token      NVARCHAR(512) NOT NULL UNIQUE,
    IsUsed     BIT           NOT NULL DEFAULT 0,
    ExpiresAt  DATETIME2     NOT NULL,
    CreatedAt  DATETIME2     NOT NULL DEFAULT SYSDATETIME()
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

-- TravelPreference: matches TravelPreference.java (all v3/v4/v5 migration columns merged)
CREATE TABLE TravelPreference (
    PreferenceId        INT IDENTITY(1,1) PRIMARY KEY,
    UserId              INT           NOT NULL UNIQUE REFERENCES [User](UserID) ON DELETE CASCADE,
    Destination         NVARCHAR(255) NULL,
    StartDate           DATE          NULL,
    EndDate             DATE          NULL,
    TravelStyle         NVARCHAR(100) NULL,
    MinBudget           DECIMAL(18,2) NULL,
    MaxBudget           DECIMAL(18,2) NULL,
    TargetAgeMin        INT           NULL,
    TargetAgeMax        INT           NULL,
    TargetGender        NVARCHAR(20)  NULL,
    Languages           NVARCHAR(255) NULL,
    Tags                NVARCHAR(500) NULL,
    TripDuration        NVARCHAR(50)  NULL,
    TravelFrequency     NVARCHAR(50)  NULL,
    ActivityPreferences NVARCHAR(500) NULL,
    SmokingPreference   NVARCHAR(50)  NULL,
    DrinkingPreference  NVARCHAR(50)  NULL,
    CreatedAt           DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt           DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================================
-- 5. TOUR MANAGEMENT
-- ============================================================

CREATE TABLE TourCategory (
    CategoryID   INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL UNIQUE,
    Description  NVARCHAR(255) NULL,
    IsActive     BIT           NOT NULL DEFAULT 1
);
GO

-- Tour: base columns + all migration v6 additions merged
-- Matches Tour.java: languages, groupSizeMin, groupSizeMax, departureCity,
--                    latitude, longitude, videoUrl, isDeleted
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
    GroupSizeMin    INT            NOT NULL DEFAULT 1,
    GroupSizeMax    INT            NOT NULL DEFAULT 20,
    Languages       NVARCHAR(200)  NULL,
    DepartureCity   NVARCHAR(200)  NULL,
    Latitude        FLOAT          NULL,
    Longitude       FLOAT          NULL,
    VideoURL        NVARCHAR(500)  NULL,
    Status          NVARCHAR(20)   NOT NULL DEFAULT 'Active'
                    CHECK (Status IN ('Active','Inactive','Draft')),
    IsFeatured      BIT            NOT NULL DEFAULT 0,
    IsDeleted       BIT            NOT NULL DEFAULT 0,
    CreatedBy       INT            NULL REFERENCES [User](UserID),
    CreatedAt       DATETIME2      NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt       DATETIME2      NOT NULL DEFAULT SYSDATETIME()
);
GO

-- TourSchedule: includes GuideID + TourStatus column (migration v6)
-- Matches TourSchedule.java: guideId, tourStatus
CREATE TABLE TourSchedule (
    ScheduleID     INT IDENTITY(1,1) PRIMARY KEY,
    TourID         INT           NOT NULL REFERENCES Tour(TourID),
    DepartureDate  DATE          NOT NULL,
    ReturnDate     DATE          NOT NULL,
    TotalSeats     INT           NOT NULL CHECK (TotalSeats > 0),
    AvailableSeats INT           NOT NULL,
    PriceAdult     DECIMAL(18,2) NOT NULL,
    PriceChild     DECIMAL(18,2) NOT NULL DEFAULT 0,
    PriceInfant    DECIMAL(18,2) NOT NULL DEFAULT 0,
    Transportation NVARCHAR(100) NULL,
    GuideID        INT           NULL REFERENCES [User](UserID),
    TourStatus     NVARCHAR(50)  NOT NULL DEFAULT 'Scheduled'
                   CHECK (TourStatus IN ('Scheduled','InProgress','Completed','Cancelled')),
    Status         NVARCHAR(20)  NOT NULL DEFAULT 'Open'
                   CHECK (Status IN ('Open','Full','Closed','Cancelled')),
    CreatedAt      DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT CHK_AvailableSeats   CHECK (AvailableSeats <= TotalSeats AND AvailableSeats >= 0),
    CONSTRAINT CHK_ReturnAfterDepart CHECK (ReturnDate >= DepartureDate)
);
GO

CREATE TABLE TourMedia (
    MediaID    INT IDENTITY(1,1) PRIMARY KEY,
    TourID     INT           NOT NULL REFERENCES Tour(TourID),
    MediaURL   NVARCHAR(500) NOT NULL,
    MediaType  NVARCHAR(20)  NOT NULL DEFAULT 'Image'
               CHECK (MediaType IN ('Image','Video')),
    Caption    NVARCHAR(255) NULL,
    SortOrder  INT           NOT NULL DEFAULT 0,
    IsVisible  BIT           NOT NULL DEFAULT 1,
    UploadedBy INT           NULL REFERENCES [User](UserID),
    UploadedAt DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- TourStatus: status history log (used by GuideDAO.assignGuideToSchedule)
-- Different from TourSchedule.TourStatus (current status field)
CREATE TABLE TourStatus (
    TourStatusID INT IDENTITY(1,1) PRIMARY KEY,
    ScheduleID   INT           NOT NULL REFERENCES TourSchedule(ScheduleID),
    Status       NVARCHAR(50)  NOT NULL,
    Notes        NVARCHAR(500) NULL,
    UpdatedBy    INT           NULL REFERENCES [User](UserID),
    UpdatedAt    DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE TourOperationLog (
    LogID      INT IDENTITY(1,1) PRIMARY KEY,
    ScheduleID INT           NOT NULL REFERENCES TourSchedule(ScheduleID),
    Activity   NVARCHAR(500) NOT NULL,
    OperatedBy INT           NULL REFERENCES [User](UserID),
    CreatedAt  DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE TourInclusion (
    InclusionID   INT IDENTITY(1,1) PRIMARY KEY,
    TourID        INT           NOT NULL REFERENCES Tour(TourID) ON DELETE CASCADE,
    InclusionType NVARCHAR(20)  NOT NULL DEFAULT 'INCLUDED'
                  CHECK (InclusionType IN ('INCLUDED','EXCLUDED')),
    ServiceName   NVARCHAR(200) NOT NULL,
    IconName      NVARCHAR(50)  NULL DEFAULT 'sparkles',
    SortOrder     INT           NOT NULL DEFAULT 0,
    IsActive      BIT           NOT NULL DEFAULT 1,
    CreatedAt     DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE TourItinerary (
    ItineraryID      INT IDENTITY(1,1) PRIMARY KEY,
    TourID           INT           NOT NULL REFERENCES Tour(TourID) ON DELETE CASCADE,
    DayNumber        INT           NOT NULL,
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
GO

CREATE TABLE TourFAQ (
    FAQID     INT IDENTITY(1,1) PRIMARY KEY,
    TourID    INT           NOT NULL REFERENCES Tour(TourID) ON DELETE CASCADE,
    Question  NVARCHAR(500) NOT NULL,
    Answer    NVARCHAR(MAX) NOT NULL,
    SortOrder INT           NOT NULL DEFAULT 0,
    IsActive  BIT           NOT NULL DEFAULT 1,
    CreatedAt DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================================
-- 6. BOOKING & PARTICIPANTS
-- ============================================================

CREATE TABLE Coupon (
    CouponID       INT IDENTITY(1,1) PRIMARY KEY,
    CouponCode     NVARCHAR(50)  NOT NULL UNIQUE,
    DiscountType   NVARCHAR(20)  NOT NULL CHECK (DiscountType IN ('Percentage','FixedAmount')),
    DiscountValue  DECIMAL(18,2) NOT NULL CHECK (DiscountValue > 0),
    MinOrderAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    MaxUses        INT           NULL,
    UsedCount      INT           NOT NULL DEFAULT 0,
    StartDate      DATE          NOT NULL,
    EndDate        DATE          NOT NULL,
    IsActive       BIT           NOT NULL DEFAULT 1,
    CreatedBy      INT           NULL REFERENCES [User](UserID),
    CreatedAt      DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT CHK_CouponDates CHECK (EndDate >= StartDate)
);
GO

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
                                      'Rejected','Cancelled','Completed','Success')),
    Notes           NVARCHAR(500) NULL,
    CouponID        INT           NULL REFERENCES Coupon(CouponID),
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
    HistoryID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT           NOT NULL REFERENCES Booking(BookingID),
    OldStatus NVARCHAR(30)  NULL,
    NewStatus NVARCHAR(30)  NOT NULL,
    ChangedBy INT           NULL REFERENCES [User](UserID),
    Reason    NVARCHAR(500) NULL,
    ChangedAt DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE CancellationRequest (
    RequestID   INT IDENTITY(1,1) PRIMARY KEY,
    BookingID   INT           NOT NULL REFERENCES Booking(BookingID),
    RequestedBy INT           NOT NULL REFERENCES [User](UserID),
    Reason      NVARCHAR(500) NOT NULL,
    Status      NVARCHAR(20)  NOT NULL DEFAULT 'Pending'
                CHECK (Status IN ('Pending','Approved','Rejected')),
    ProcessedBy INT           NULL REFERENCES [User](UserID),
    ProcessedAt DATETIME2     NULL,
    Notes       NVARCHAR(500) NULL,
    CreatedAt   DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================================
-- 7. PAYMENT & FINANCIAL
-- ============================================================

CREATE TABLE Payment (
    PaymentID       INT IDENTITY(1,1) PRIMARY KEY,
    BookingID       INT           NOT NULL REFERENCES Booking(BookingID),
    PaymentMethod   NVARCHAR(50)  NOT NULL
                    CHECK (PaymentMethod IN ('CreditCard','BankTransfer','MoMo','VNPay')),
    TransactionRef  NVARCHAR(100) NULL UNIQUE,
    Amount          DECIMAL(18,2) NOT NULL,
    Currency        NVARCHAR(10)  NOT NULL DEFAULT 'VND',
    Status          NVARCHAR(20)  NOT NULL DEFAULT 'Pending'
                    CHECK (Status IN ('Pending','Success','Failed','Refunded')),
    PaidAt          DATETIME2     NULL,
    GatewayResponse NVARCHAR(MAX) NULL,
    CreatedAt       DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE Invoice (
    InvoiceID      INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceCode    NVARCHAR(30)  NOT NULL UNIQUE,
    BookingID      INT           NOT NULL REFERENCES Booking(BookingID),
    PaymentID      INT           NOT NULL REFERENCES Payment(PaymentID),
    SubTotal       DECIMAL(18,2) NOT NULL,
    VATRate        DECIMAL(5,2)  NOT NULL DEFAULT 8.00,
    VATAmount      DECIMAL(18,2) NOT NULL,
    DiscountAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    TotalAmount    DECIMAL(18,2) NOT NULL,
    IssuedAt       DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    IssuedBy       INT           NULL REFERENCES [User](UserID)
);
GO

CREATE TABLE Refund (
    RefundID       INT IDENTITY(1,1) PRIMARY KEY,
    PaymentID      INT           NOT NULL REFERENCES Payment(PaymentID),
    BookingID      INT           NOT NULL REFERENCES Booking(BookingID),
    Amount         DECIMAL(18,2) NOT NULL,
    Reason         NVARCHAR(500) NULL,
    Status         NVARCHAR(20)  NOT NULL DEFAULT 'Pending'
                   CHECK (Status IN ('Pending','Processing','Completed','Rejected')),
    ProcessedBy    INT           NULL REFERENCES [User](UserID),
    ProcessedAt    DATETIME2     NULL,
    TransactionRef NVARCHAR(100) NULL,
    CreatedAt      DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE CurrencyExchange (
    ExchangeID    INT IDENTITY(1,1) PRIMARY KEY,
    FromCurrency  NVARCHAR(10)  NOT NULL,
    ToCurrency    NVARCHAR(10)  NOT NULL,
    Rate          DECIMAL(18,6) NOT NULL,
    EffectiveDate DATE          NOT NULL,
    CreatedAt     DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_CurrencyRate UNIQUE (FromCurrency, ToCurrency, EffectiveDate)
);
GO

CREATE TABLE FinancialAuditLog (
    AuditID     INT IDENTITY(1,1) PRIMARY KEY,
    EntityType  NVARCHAR(50)  NOT NULL,
    EntityID    INT           NOT NULL,
    Action      NVARCHAR(100) NOT NULL,
    OldValues   NVARCHAR(MAX) NULL,
    NewValues   NVARCHAR(MAX) NULL,
    PerformedBy INT           NULL REFERENCES [User](UserID),
    CreatedAt   DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE FraudAlert (
    AlertID     INT IDENTITY(1,1) PRIMARY KEY,
    PaymentID   INT           NOT NULL REFERENCES Payment(PaymentID),
    AlertType   NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500) NULL,
    Severity    NVARCHAR(20)  NOT NULL DEFAULT 'Medium'
                CHECK (Severity IN ('Low','Medium','High','Critical')),
    Status      NVARCHAR(20)  NOT NULL DEFAULT 'Open'
                CHECK (Status IN ('Open','Investigating','Resolved','Dismissed')),
    ReviewedBy  INT           NULL REFERENCES [User](UserID),
    ReviewedAt  DATETIME2     NULL,
    CreatedAt   DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================================
-- 8. TOUR OPERATIONS
-- ============================================================

-- TourAssignment: history log of guide assignments (used by GuideDAO)
-- TourSchedule.GuideID is the CURRENT guide; TourAssignment tracks ALL assignments
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
    AttendanceID  INT IDENTITY(1,1) PRIMARY KEY,
    ScheduleID    INT           NOT NULL REFERENCES TourSchedule(ScheduleID),
    ParticipantID INT           NOT NULL REFERENCES BookingParticipant(ParticipantID),
    CheckedIn     BIT           NOT NULL DEFAULT 0,
    CheckInTime   DATETIME2     NULL,
    CheckedBy     INT           NULL REFERENCES [User](UserID),
    Notes         NVARCHAR(255) NULL,
    CONSTRAINT UQ_Attendance UNIQUE (ScheduleID, ParticipantID)
);
GO

CREATE TABLE IncidentReport (
    IncidentID  INT IDENTITY(1,1) PRIMARY KEY,
    ScheduleID  INT           NOT NULL REFERENCES TourSchedule(ScheduleID),
    ReportedBy  INT           NOT NULL REFERENCES [User](UserID),
    Title       NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NOT NULL,
    Severity    NVARCHAR(20)  NOT NULL DEFAULT 'Medium'
                CHECK (Severity IN ('Low','Medium','High','Critical')),
    Status      NVARCHAR(30)  NOT NULL DEFAULT 'Open'
                CHECK (Status IN ('Open','InProgress','Resolved','Closed')),
    ResolvedBy  INT           NULL REFERENCES [User](UserID),
    ResolvedAt  DATETIME2     NULL,
    CreatedAt   DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================================
-- 9. CUSTOMER EXPERIENCE
-- ============================================================

CREATE TABLE FavoriteTour (
    FavoriteID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT       NOT NULL REFERENCES [User](UserID),
    TourID     INT       NOT NULL REFERENCES Tour(TourID),
    AddedAt    DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_FavoriteTour UNIQUE (CustomerID, TourID)
);
GO

CREATE TABLE Review (
    ReviewID   INT IDENTITY(1,1) PRIMARY KEY,
    TourID     INT           NOT NULL REFERENCES Tour(TourID),
    BookingID  INT           NOT NULL REFERENCES Booking(BookingID),
    CustomerID INT           NOT NULL REFERENCES [User](UserID),
    Rating     TINYINT       NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Content    NVARCHAR(MAX) NULL,
    IsVisible  BIT           NOT NULL DEFAULT 1,
    CreatedAt  DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt  DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_Review UNIQUE (BookingID, CustomerID)
);
GO

CREATE TABLE ModerationRecord (
    ModerationID INT IDENTITY(1,1) PRIMARY KEY,
    EntityType   NVARCHAR(50)  NOT NULL,
    EntityID     INT           NOT NULL,
    Action       NVARCHAR(50)  NOT NULL,
    Reason       NVARCHAR(500) NULL,
    ModeratedBy  INT           NOT NULL REFERENCES [User](UserID),
    ModeratedAt  DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================================
-- 10. COMMUNITY
-- ============================================================

CREATE TABLE CommunityPost (
    PostID    INT IDENTITY(1,1) PRIMARY KEY,
    AuthorID  INT           NOT NULL REFERENCES [User](UserID),
    Title     NVARCHAR(255) NULL,
    Content   NVARCHAR(MAX) NOT NULL,
    ImageURL  NVARCHAR(500) NULL,
    IsVisible BIT           NOT NULL DEFAULT 1,
    LikeCount INT           NOT NULL DEFAULT 0,
    CreatedAt DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE Comment (
    CommentID INT IDENTITY(1,1) PRIMARY KEY,
    PostID    INT           NOT NULL REFERENCES CommunityPost(PostID),
    AuthorID  INT           NOT NULL REFERENCES [User](UserID),
    Content   NVARCHAR(MAX) NOT NULL,
    IsVisible BIT           NOT NULL DEFAULT 1,
    CreatedAt DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================================
-- 11. BUDDY MATCHING & CHAT
-- ============================================================

CREATE TABLE BuddyMatch (
    MatchID            INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID         INT           NOT NULL REFERENCES [User](UserID),
    MatchedUserID      INT           NOT NULL REFERENCES [User](UserID),
    CompatibilityScore DECIMAL(5,2)  NULL,
    MatchedAt          DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_BuddyMatch UNIQUE (CustomerID, MatchedUserID)
);
GO

-- BuddyRequest: matches BuddyRequest.java + BuddyRequestDAO.java
--   Java uses: SenderId, ReceiverId, Status (String: 'Pending','Accepted','Rejected','Cancelled'), RequestId
--   BuddyRequestDAO uses: MERGE INTO BuddyRequest ... UPDATE SET Status = 'Pending'
--                         UPDATE BuddyRequest SET Status = ?, UpdatedAt = SYSDATETIME() WHERE RequestId = ?
CREATE TABLE BuddyRequest (
    RequestId  INT IDENTITY(1,1) PRIMARY KEY,
    SenderId   INT           NOT NULL REFERENCES [User](UserID) ON DELETE NO ACTION,
    ReceiverId INT           NOT NULL REFERENCES [User](UserID) ON DELETE NO ACTION,
    Status     NVARCHAR(20)  NOT NULL DEFAULT 'Pending'
               CHECK (Status IN ('Pending','Accepted','Rejected','Cancelled')),
    Message    NVARCHAR(500) NULL,
    CreatedAt  DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt  DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_BuddyRequest UNIQUE (SenderId, ReceiverId),
    CONSTRAINT CHK_BuddyNotSelf CHECK (SenderId <> ReceiverId)
);
GO

CREATE TABLE ChatConversation (
    ConversationID   INT IDENTITY(1,1) PRIMARY KEY,
    ConversationType NVARCHAR(20)  NOT NULL DEFAULT 'Direct'
                     CHECK (ConversationType IN ('Direct','Group')),
    GroupName        NVARCHAR(100) NULL,
    CreatedBy        INT           NULL REFERENCES [User](UserID),
    CreatedAt        DATETIME2     NOT NULL DEFAULT SYSDATETIME()
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
-- 12. NOTIFICATIONS
--     Single table: Notifications (camelCase columns)
--     Matches NotificationDAO.java exclusively.
--
--     NOTE FOR DEVELOPERS:
--     UserDAO.java line 557 has "DELETE FROM Notification WHERE UserID = ?"
--     This is a BUG -- should be "DELETE FROM Notifications WHERE userId = ?"
--     Please fix UserDAO.java to use: "DELETE FROM Notifications WHERE userId = ?"
-- ============================================================

CREATE TABLE Notifications (
    notificationId INT IDENTITY(1,1) PRIMARY KEY,
    userId         INT           NOT NULL REFERENCES [User](UserID),
    senderId       INT           NULL REFERENCES [User](UserID),
    title          NVARCHAR(255) NOT NULL,
    content        NVARCHAR(MAX) NOT NULL,
    channel        VARCHAR(50)   NOT NULL,
    category       VARCHAR(50)   NOT NULL DEFAULT 'System Announcement',
    isRead         BIT           NOT NULL DEFAULT 0,
    createdAt      DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    scheduledAt    DATETIME2     NULL,
    status         VARCHAR(50)   NOT NULL DEFAULT 'SENT'
);
GO

-- ============================================================
-- 13. ANALYTICS
-- ============================================================

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
-- INDEXES
-- ============================================================

CREATE INDEX IX_User_Email             ON [User](Email);
CREATE INDEX IX_User_RoleID            ON [User](RoleID);
CREATE INDEX IX_Tour_Status            ON Tour(Status);
CREATE INDEX IX_Tour_IsDeleted         ON Tour(IsDeleted);
CREATE INDEX IX_Tour_CategoryID        ON Tour(CategoryID);
CREATE INDEX IX_TourSchedule_TourID    ON TourSchedule(TourID);
CREATE INDEX IX_TourSchedule_Departure ON TourSchedule(DepartureDate);
CREATE INDEX IX_Booking_CustomerID     ON Booking(CustomerID);
CREATE INDEX IX_Booking_ScheduleID     ON Booking(ScheduleID);
CREATE INDEX IX_Booking_Status         ON Booking(Status);
CREATE INDEX IX_Booking_BookingCode    ON Booking(BookingCode);
CREATE INDEX IX_Payment_BookingID      ON Payment(BookingID);
CREATE INDEX IX_Payment_Status         ON Payment(Status);
CREATE INDEX IX_Notifications_UserId   ON Notifications(userId);
CREATE INDEX IX_Notifications_IsRead   ON Notifications(isRead);
CREATE INDEX IX_ChatMessage_ConvID     ON ChatMessage(ConversationID);
CREATE INDEX IX_Review_TourID          ON Review(TourID);
CREATE INDEX IX_CommunityPost_Author   ON CommunityPost(AuthorID);
CREATE INDEX IX_GuideProfile_UserID    ON GuideProfile(UserID);
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
    s.Status,
    s.TourStatus,
    s.GuideID
FROM TourSchedule s
JOIN Tour t ON t.TourID = s.TourID
WHERE s.Status = 'Open' AND t.Status = 'Active' AND t.IsDeleted = 0;
GO

CREATE VIEW vw_BookingSummary AS
SELECT
    b.BookingID,
    b.BookingCode,
    b.Status       AS BookingStatus,
    u.FullName     AS CustomerName,
    u.Email        AS CustomerEmail,
    t.TourName,
    s.DepartureDate,
    b.NumParticipants,
    b.TotalAmount,
    p.Status       AS PaymentStatus,
    b.CreatedAt
FROM Booking b
JOIN [User] u       ON u.UserID    = b.CustomerID
JOIN TourSchedule s ON s.ScheduleID = b.ScheduleID
JOIN Tour t         ON t.TourID    = s.TourID
LEFT JOIN Payment p ON p.BookingID = b.BookingID;
GO

-- ============================================================
-- SEED DATA
-- ============================================================

-- Roles
INSERT INTO Role (RoleName, Description, IsSystemRole) VALUES
('Admin',      N'Quản trị viên hệ thống',   1),
('Staff',      N'Nhân viên xử lý booking',  0),
('Guide',      N'Hướng dẫn viên tour',       0),
('Customer',   N'Khách hàng',                1),
('Accountant', N'Kế toán',                   0);
GO

-- Permissions (ModuleName + Action schema)
INSERT INTO Permission (ModuleName, Action, Description, IsCritical) VALUES
('User Management',    'Read',    N'Xem danh sách người dùng',   0),
('User Management',    'Create',  N'Tạo người dùng mới',          0),
('User Management',    'Update',  N'Cập nhật người dùng',         0),
('User Management',    'Delete',  N'Xóa người dùng',              1),
('Tour Management',    'Read',    N'Xem danh sách tour',           0),
('Tour Management',    'Create',  N'Tạo tour mới',                 0),
('Tour Management',    'Update',  N'Cập nhật tour',                0),
('Tour Management',    'Delete',  N'Xóa tour',                     0),
('Booking Management', 'Read',    N'Xem danh sách booking',        0),
('Booking Management', 'Create',  N'Tạo booking mới',              0),
('Booking Management', 'Update',  N'Sửa trạng thái booking',       0),
('Booking Management', 'Delete',  N'Hủy booking',                  0),
('Booking Management', 'Approve', N'Duyệt booking',                0),
('Payment Management', 'Read',    N'Xem thanh toán',               0),
('Payment Management', 'Refund',  N'Xử lý hoàn tiền',              1),
('Payment Management', 'Fraud',   N'Quản lý gian lận',             1),
('Payment Management', 'Coupon',  N'Quản lý mã giảm giá',          0),
('System Settings',    'Read',    N'Xem cấu hình hệ thống',        1),
('System Settings',    'Update',  N'Cập nhật cấu hình hệ thống',   1),
('Role Management',    'Read',    N'Xem danh sách vai trò',        1),
('Role Management',    'Create',  N'Tạo vai trò',                  1),
('Role Management',    'Update',  N'Sửa vai trò',                  1),
('Role Management',    'Delete',  N'Xóa vai trò',                  1),
('Report',             'View',    N'Xem báo cáo',                  0),
('Report',             'Export',  N'Xuất báo cáo',                 0),
('Report',             'Analytics',N'Xem analytics',               0),
('Guide Management',   'Assign',  N'Phân công HDV',                0),
('Guide Management',   'Checkin', N'Quản lý điểm danh',            0),
('Community',          'Moderate',N'Kiểm duyệt nội dung',          0),
('Notification',       'Send',    N'Gửi thông báo',                0);
GO

-- Admin (RoleID=1) gets ALL permissions
INSERT INTO Role_Permission (RoleID, PermissionID)
SELECT 1, PermissionID FROM Permission;

-- Staff (RoleID=2)
INSERT INTO Role_Permission (RoleID, PermissionID)
SELECT 2, PermissionID FROM Permission
WHERE (ModuleName = 'Tour Management'    AND Action IN ('Read','Create','Update'))
   OR (ModuleName = 'Booking Management' AND Action IN ('Read','Update','Approve'))
   OR (ModuleName = 'Guide Management')
   OR (ModuleName = 'Notification'       AND Action = 'Send');

-- Guide (RoleID=3)
INSERT INTO Role_Permission (RoleID, PermissionID)
SELECT 3, PermissionID FROM Permission
WHERE ModuleName IN ('Tour Management','Booking Management') AND Action = 'Read';

-- Accountant (RoleID=5)
INSERT INTO Role_Permission (RoleID, PermissionID)
SELECT 5, PermissionID FROM Permission
WHERE ModuleName IN ('Payment Management','Report');
GO

-- Tour Categories
INSERT INTO TourCategory (CategoryName, Description) VALUES
(N'Biển & Đảo',       N'Các tour du lịch biển đảo'),
(N'Núi & Rừng',       N'Các tour trekking, leo núi'),
(N'Văn hóa & Di sản', N'Tham quan di tích lịch sử'),
(N'City Tour',         N'Khám phá thành phố'),
(N'MICE',              N'Tour hội nghị, sự kiện');
GO

-- Sample Tours
INSERT INTO Tour (CategoryID, TourName, Destination, DurationDays, BasePrice,
                  MaxParticipants, GroupSizeMin, GroupSizeMax, Status, IsFeatured, Description)
VALUES
(1, N'Khám Phá Vịnh Hạ Long 3N2Đ', N'Hạ Long, Quảng Ninh', 3, 3500000, 20, 2, 20, 'Active', 1,
   N'Hành trình khám phá kỳ quan thiên nhiên thế giới Vịnh Hạ Long với thuyền kayak, hang động.'),
(1, N'Đà Nẵng - Hội An - Bà Nà 4N3Đ', N'Đà Nẵng, Quảng Nam', 4, 4200000, 25, 2, 25, 'Active', 1,
   N'Trải nghiệm phố cổ Hội An, bãi biển Mỹ Khê, Bà Nà Hills và cầu vàng nổi tiếng.'),
(2, N'Chinh Phục Fansipan 2N1Đ', N'Sa Pa, Lào Cai', 2, 2800000, 15, 2, 15, 'Active', 0,
   N'Trekking leo núi Fansipan - nóc nhà Đông Dương với cáp treo và đường mòn.'),
(3, N'Huế - Cố Đô Ngàn Năm 3N2Đ', N'Huế, Thừa Thiên Huế', 3, 3100000, 20, 2, 20, 'Active', 0,
   N'Khám phá kinh thành Huế, lăng tẩm vua chúa triều Nguyễn và ẩm thực cung đình.'),
(4, N'Hà Nội City Tour 1N', N'Hà Nội', 1, 850000, 30, 1, 30, 'Active', 1,
   N'Tham quan Hồ Hoàn Kiếm, Văn Miếu, lăng Bác, phố cổ 36 phố phường.');
GO

-- Tour Media
INSERT INTO TourMedia (TourID, MediaURL, MediaType, Caption, SortOrder, IsVisible, UploadedBy) VALUES
(1,'assets/images/tour_halong.png', 'Image',N'Vịnh Hạ Long từ trên cao',     1,1,NULL),
(1,'assets/images/tour_phuquoc.png','Image',N'Resort bên bờ biển',            2,1,NULL),
(1,'assets/images/hero_beach.png',  'Image',N'Bình minh trên biển',           3,1,NULL),
(1,'assets/images/tour_dalat.png',  'Image',N'Rừng thông Đà Lạt',             4,1,NULL),
(1,'assets/images/tour_danang.png', 'Image',N'Cầu Rồng Đà Nẵng',             5,1,NULL),
(2,'assets/images/tour_danang.png', 'Image',N'Cầu Vàng Bà Nà Hills',          1,1,NULL),
(2,'assets/images/tour_hoian.png',  'Image',N'Phố cổ Hội An về đêm',         2,1,NULL),
(2,'assets/images/hero_beach.png',  'Image',N'Bãi biển Mỹ Khê',              3,1,NULL),
(2,'assets/images/tour_dalat.png',  'Image',N'Thung lũng tình yêu',           4,1,NULL),
(2,'assets/images/tour_halong.png', 'Image',N'Khám phá hang động',            5,1,NULL),
(3,'assets/images/tour_sapa.png',   'Image',N'Bản Cát Cát Sapa',              1,1,NULL),
(3,'assets/images/tour_dalat.png',  'Image',N'Trekking rừng thông',           2,1,NULL),
(3,'assets/images/tour_hagiang.png','Image',N'Ruộng bậc thang miền Bắc',      3,1,NULL),
(3,'assets/images/hero_beach.png',  'Image',N'Cảnh quan đồi núi',             4,1,NULL),
(3,'assets/images/tour_halong.png', 'Image',N'Đỉnh Fansipan',                 5,1,NULL),
(4,'assets/images/tour_hoian.png',  'Image',N'Đại nội Huế cổ kính',           1,1,NULL),
(4,'assets/images/tour_danang.png', 'Image',N'Lăng Khải Định',                2,1,NULL),
(4,'assets/images/tour_halong.png', 'Image',N'Chùa Thiên Mụ',                 3,1,NULL),
(4,'assets/images/tour_dalat.png',  'Image',N'Sông Hương thơ mộng',           4,1,NULL),
(4,'assets/images/hero_beach.png',  'Image',N'Ẩm thực cung đình Huế',         5,1,NULL),
(5,'assets/images/tour_sapa.png',   'Image',N'Hồ Hoàn Kiếm',                  1,1,NULL),
(5,'assets/images/tour_halong.png', 'Image',N'Lăng Chủ tịch Hồ Chí Minh',    2,1,NULL),
(5,'assets/images/tour_hagiang.png','Image',N'Phố cổ Hà Nội',                 3,1,NULL),
(5,'assets/images/tour_dalat.png',  'Image',N'Văn Miếu Quốc Tử Giám',         4,1,NULL),
(5,'assets/images/hero_beach.png',  'Image',N'Chùa Một Cột',                  5,1,NULL);
GO

-- ============================================================
-- SEED USERS
-- ============================================================
DECLARE @hp NVARCHAR(512) = 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f'; -- '12345678'

IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email='sonkbgnh@gmail.com')
    INSERT INTO [User](RoleID,Email,PasswordHash,FullName,PhoneNumber,IsActive,IsVerified,CreatedAt,UpdatedAt)
    VALUES(1,'sonkbgnh@gmail.com',@hp,N'Admin Son KB','0911111111',1,1,SYSDATETIME(),SYSDATETIME());
ELSE UPDATE [User] SET RoleID=1 WHERE Email='sonkbgnh@gmail.com';

IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email='admin.test@tourbuddy.com')
    INSERT INTO [User](RoleID,Email,PasswordHash,FullName,PhoneNumber,IsActive,IsVerified,CreatedAt,UpdatedAt)
    VALUES(1,'admin.test@tourbuddy.com',@hp,N'Super Admin Test','0901234567',1,1,SYSDATETIME(),SYSDATETIME());

IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email='staff.test@tourbuddy.com')
    INSERT INTO [User](RoleID,Email,PasswordHash,FullName,PhoneNumber,IsActive,IsVerified,CreatedAt,UpdatedAt)
    VALUES(2,'staff.test@tourbuddy.com',@hp,N'Nhân viên điều hành Test','0902345678',1,1,SYSDATETIME(),SYSDATETIME());

IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email='sondqhe186525@fpt.edu.vn')
    INSERT INTO [User](RoleID,Email,PasswordHash,FullName,PhoneNumber,IsActive,IsVerified,CreatedAt,UpdatedAt)
    VALUES(5,'sondqhe186525@fpt.edu.vn',@hp,N'Accountant Son DQ','0922222222',1,1,SYSDATETIME(),SYSDATETIME());
ELSE UPDATE [User] SET RoleID=5 WHERE Email='sondqhe186525@fpt.edu.vn';

IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email='sonkbgnh112@gmail.com')
    INSERT INTO [User](RoleID,Email,PasswordHash,FullName,PhoneNumber,IsActive,IsVerified,CreatedAt,UpdatedAt)
    VALUES(4,'sonkbgnh112@gmail.com',@hp,N'Customer Son KB 112','0933333333',1,1,SYSDATETIME(),SYSDATETIME());
ELSE UPDATE [User] SET RoleID=4 WHERE Email='sonkbgnh112@gmail.com';

IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email='guide.test@tourbuddy.com')
    INSERT INTO [User](RoleID,Email,PasswordHash,FullName,PhoneNumber,IsActive,IsVerified,CreatedAt,UpdatedAt)
    VALUES(3,'guide.test@tourbuddy.com',@hp,N'Hướng dẫn viên Test','0903456789',1,1,SYSDATETIME(),SYSDATETIME());

DECLARE @e NVARCHAR(512)='e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email='tuan.tran@gmail.com')
    INSERT INTO [User](RoleID,Email,PasswordHash,FullName,PhoneNumber,IsActive,IsVerified,CreatedAt,UpdatedAt)
    VALUES(4,'tuan.tran@gmail.com',@e,N'Trần Anh Tuấn','0901234567',1,1,SYSDATETIME(),SYSDATETIME());
IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email='thu.le@gmail.com')
    INSERT INTO [User](RoleID,Email,PasswordHash,FullName,PhoneNumber,IsActive,IsVerified,CreatedAt,UpdatedAt)
    VALUES(4,'thu.le@gmail.com',@e,N'Lê Minh Thư','0912345678',1,1,SYSDATETIME(),SYSDATETIME());
IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email='hoang.pham@gmail.com')
    INSERT INTO [User](RoleID,Email,PasswordHash,FullName,PhoneNumber,IsActive,IsVerified,CreatedAt,UpdatedAt)
    VALUES(4,'hoang.pham@gmail.com',@e,N'Phạm Minh Hoàng','0923456789',1,1,SYSDATETIME(),SYSDATETIME());
GO

-- ============================================================
-- SEED GUIDES WITH GUIDEPROFILE
-- ============================================================
DECLARE @hp NVARCHAR(512)='ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f';
DECLARE @G1 INT;
IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email='guide1@tourbuddy.com') BEGIN
    INSERT INTO [User](RoleID,Email,PasswordHash,FullName,PhoneNumber,IsActive,IsVerified,CreatedAt,UpdatedAt)
    VALUES(3,'guide1@tourbuddy.com',@hp,N'Nguyễn Văn Hướng Dẫn','0912345678',1,1,SYSDATETIME(),SYSDATETIME());
    SET @G1=SCOPE_IDENTITY();
    INSERT INTO UserProfile(UserID,AvatarURL,Biography,DateOfBirth,Gender,Address,TravelInterests,UpdatedAt)
    VALUES(@G1,'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    N'Kinh nghiệm 5 năm dẫn tour mạo hiểm.','1995-05-15','Male',N'Hà Nội',N'Trekking, Leo núi',SYSDATETIME());
    INSERT INTO GuideProfile(UserID,YearsOfExperience,TotalToursLed,Rating,Bio,Specialization,Languages,Certifications,EmergencyPhone,IsActive)
    VALUES(@G1,5,12,4.80,N'HDV chuyên nghiệp về trekking Sapa và Hà Giang.',
    N'Trekking, Khám phá rừng núi',N'Tiếng Việt, Tiếng Anh',N'Chứng chỉ HDV Quốc tế','0912345678',1);
END
GO

DECLARE @hp NVARCHAR(512)='ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f';
DECLARE @G2 INT;
IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email='guide2@tourbuddy.com') BEGIN
    INSERT INTO [User](RoleID,Email,PasswordHash,FullName,PhoneNumber,IsActive,IsVerified,CreatedAt,UpdatedAt)
    VALUES(3,'guide2@tourbuddy.com',@hp,N'Trần Thị Dẫn Đường','0987654321',1,1,SYSDATETIME(),SYSDATETIME());
    SET @G2=SCOPE_IDENTITY();
    INSERT INTO UserProfile(UserID,AvatarURL,Biography,DateOfBirth,Gender,Address,TravelInterests,UpdatedAt)
    VALUES(@G2,'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    N'Đam mê lịch sử và văn hóa cố đô.','1997-09-20','Female',N'Huế',N'Lịch sử, Ẩm thực',SYSDATETIME());
    INSERT INTO GuideProfile(UserID,YearsOfExperience,TotalToursLed,Rating,Bio,Specialization,Languages,Certifications,EmergencyPhone,IsActive)
    VALUES(@G2,3,8,4.70,N'HDV chuyên tuyến văn hóa Huế - Hội An.',
    N'Văn hóa, Lịch sử, Ẩm thực',N'Tiếng Việt, Tiếng Trung',N'Chứng chỉ HDV Nội địa','0987654321',1);
END
GO

DECLARE @hp NVARCHAR(512)='ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f';
DECLARE @G3 INT;
IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email='guide3@tourbuddy.com') BEGIN
    INSERT INTO [User](RoleID,Email,PasswordHash,FullName,PhoneNumber,IsActive,IsVerified,CreatedAt,UpdatedAt)
    VALUES(3,'guide3@tourbuddy.com',@hp,N'Lê Hoàng Phượt','0905123456',1,1,SYSDATETIME(),SYSDATETIME());
    SET @G3=SCOPE_IDENTITY();
    INSERT INTO UserProfile(UserID,AvatarURL,Biography,DateOfBirth,Gender,Address,TravelInterests,UpdatedAt)
    VALUES(@G3,'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    N'Thích khám phá đại dương và các hòn đảo hoang sơ.','1993-02-10','Male',N'Đà Nẵng',N'Lặn biển, Khám phá đảo',SYSDATETIME());
    INSERT INTO GuideProfile(UserID,YearsOfExperience,TotalToursLed,Rating,Bio,Specialization,Languages,Certifications,EmergencyPhone,IsActive)
    VALUES(@G3,7,25,4.90,N'HDV chuyên nghiệp tuyến biển đảo Nha Trang, Phú Quốc.',
    N'Lặn biển, Sinh tồn',N'Tiếng Việt, Tiếng Anh, Tiếng Nhật',N'Chứng chỉ HDV Quốc tế, Cứu hộ bờ biển','0905123456',1);
END
GO

-- ============================================================
-- SEED SCHEDULES & BOOKINGS
-- ============================================================

INSERT INTO TourSchedule(TourID,DepartureDate,ReturnDate,TotalSeats,AvailableSeats,
    PriceAdult,PriceChild,PriceInfant,Status,TourStatus)
VALUES
(1,'2026-07-10','2026-07-12',20,15,3900000,1950000,500000,'Open','Scheduled'),
(1,'2026-08-15','2026-08-17',20,20,3900000,1950000,500000,'Open','Scheduled'),
(2,'2026-07-20','2026-07-24',25,22,4800000,2400000,500000,'Open','Scheduled'),
(3,'2026-07-05','2026-07-07',15,13,2800000,1400000,500000,'Open','Scheduled'),
(4,'2026-07-12','2026-07-15',20,17,3100000,1550000,500000,'Open','Scheduled'),
(5,'2026-07-01','2026-07-01',30,26, 850000, 425000,200000,'Open','Scheduled');
GO

DECLARE @C1 INT, @C2 INT, @C3 INT;
DECLARE @S1 INT, @S2 INT, @S3 INT, @S4 INT, @S5 INT, @S6 INT;
SELECT @C1=UserID FROM [User] WHERE Email='tuan.tran@gmail.com';
SELECT @C2=UserID FROM [User] WHERE Email='thu.le@gmail.com';
SELECT @C3=UserID FROM [User] WHERE Email='hoang.pham@gmail.com';
SELECT @S1=ScheduleID FROM TourSchedule WHERE TourID=1 AND DepartureDate='2026-07-10';
SELECT @S2=ScheduleID FROM TourSchedule WHERE TourID=1 AND DepartureDate='2026-08-15';
SELECT @S3=ScheduleID FROM TourSchedule WHERE TourID=2 AND DepartureDate='2026-07-20';
SELECT @S4=ScheduleID FROM TourSchedule WHERE TourID=3 AND DepartureDate='2026-07-05';
SELECT @S5=ScheduleID FROM TourSchedule WHERE TourID=4 AND DepartureDate='2026-07-12';
SELECT @S6=ScheduleID FROM TourSchedule WHERE TourID=5 AND DepartureDate='2026-07-01';

INSERT INTO Booking(BookingCode,ScheduleID,CustomerID,NumParticipants,
    BaseAmount,VATAmount,DiscountAmount,TotalAmount,Status,Notes,CreatedAt,UpdatedAt)
VALUES
('BK001',@S1,@C1,2, 7560000,0,0, 7560000,'Completed','Seeded',SYSDATETIME(),SYSDATETIME()),
('BK002',@S1,@C2,1, 3780000,0,0, 3780000,'Completed','Seeded',SYSDATETIME(),SYSDATETIME()),
('BK003',@S2,@C2,2, 9072000,0,0, 9072000,'Completed','Seeded',SYSDATETIME(),SYSDATETIME()),
('BK004',@S3,@C3,1, 3024000,0,0, 3024000,'Completed','Seeded',SYSDATETIME(),SYSDATETIME()),
('BK005',@S4,@C1,2, 5600000,0,0, 5600000,'Completed','Seeded mountain',SYSDATETIME(),SYSDATETIME()),
('BK006',@S5,@C2,3, 9300000,0,0, 9300000,'Completed','Seeded cultural',SYSDATETIME(),SYSDATETIME()),
('BK007',@S6,@C3,4, 3400000,0,0, 3400000,'Completed','Seeded city',SYSDATETIME(),SYSDATETIME());
GO

-- ============================================================
-- RE-ENABLE ALL CONSTRAINTS
-- ============================================================
EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all';
GO

PRINT N'';
PRINT N'============================================================';
PRINT N' TourBuddyDB created successfully! (v2.0 Clean)';
PRINT N' 44 tables, all conflicts resolved.';
PRINT N'';
PRINT N' ACTION REQUIRED in Java code:';
PRINT N'   UserDAO.java line 557:';
PRINT N'   Change: DELETE FROM Notification WHERE UserID = ?';
PRINT N'   To:     DELETE FROM Notifications WHERE userId = ?';
PRINT N'============================================================';
GO
