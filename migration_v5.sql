USE TourBuddyDB;
GO

-- Add new columns to TravelPreference
ALTER TABLE TravelPreference
ADD TripDuration NVARCHAR(50) NULL;

ALTER TABLE TravelPreference
ADD TravelFrequency NVARCHAR(50) NULL;

ALTER TABLE TravelPreference
ADD ActivityPreferences NVARCHAR(500) NULL;

ALTER TABLE TravelPreference
ADD SmokingPreference NVARCHAR(50) NULL;

ALTER TABLE TravelPreference
ADD DrinkingPreference NVARCHAR(50) NULL;
GO
