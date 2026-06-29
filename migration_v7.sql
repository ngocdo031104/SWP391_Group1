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
