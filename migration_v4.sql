-- Migration v4: Create TravelPreference table for Match Travel Companions UC

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
