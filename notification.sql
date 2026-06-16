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
