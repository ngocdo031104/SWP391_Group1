USE TourBuddyDB;
GO

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
