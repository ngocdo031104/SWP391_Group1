-- ============================================================
-- TourBuddy Chat Module Schema
-- ============================================================

-- Table for tracking chat threads (1-to-1 or Group)
CREATE TABLE Conversation (
    ConversationID  INT IDENTITY(1,1) PRIMARY KEY,
    Type            NVARCHAR(20) NOT NULL CHECK (Type IN ('Direct', 'Group')),
    Title           NVARCHAR(255) NULL, -- Null for Direct chats
    CreatedAt       DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt       DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

-- Table mapping users to conversations
CREATE TABLE ConversationParticipant (
    ParticipantID   INT IDENTITY(1,1) PRIMARY KEY,
    ConversationID  INT NOT NULL REFERENCES Conversation(ConversationID) ON DELETE CASCADE,
    UserID          INT NOT NULL REFERENCES [User](UserID),
    Role            NVARCHAR(20) NOT NULL DEFAULT 'Member' CHECK (Role IN ('Member', 'Admin')),
    JoinedAt        DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    LastReadMessageID INT NULL,
    CONSTRAINT UQ_Participant UNIQUE (ConversationID, UserID)
);
GO

-- Table for actual messages
CREATE TABLE Message (
    MessageID       INT IDENTITY(1,1) PRIMARY KEY,
    ConversationID  INT NOT NULL REFERENCES Conversation(ConversationID) ON DELETE CASCADE,
    SenderID        INT NOT NULL REFERENCES [User](UserID),
    Content         NVARCHAR(MAX) NOT NULL,
    MessageType     NVARCHAR(20) NOT NULL DEFAULT 'Text' CHECK (MessageType IN ('Text', 'Image', 'File', 'System')),
    CreatedAt       DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    IsDeleted       BIT NOT NULL DEFAULT 0
);
GO

-- Table for blocked users
CREATE TABLE BlockList (
    BlockID         INT IDENTITY(1,1) PRIMARY KEY,
    BlockerID       INT NOT NULL REFERENCES [User](UserID),
    BlockedID       INT NOT NULL REFERENCES [User](UserID),
    CreatedAt       DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_BlockList UNIQUE (BlockerID, BlockedID)
);
GO
