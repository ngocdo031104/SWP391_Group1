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
