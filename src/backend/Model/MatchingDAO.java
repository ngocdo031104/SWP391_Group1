package Model;

import Entities.MatchedUser;
import Entities.TravelPreference;
import Entities.User;
import Entities.UserProfile;
import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class MatchingDAO extends DBContext {

    public TravelPreference getPreference(int userId) {
        String sql = "SELECT * FROM TravelPreference WHERE UserId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new TravelPreference(
                    rs.getInt("PreferenceId"),
                    rs.getInt("UserId"),
                    rs.getString("Destination"),
                    rs.getDate("StartDate"),
                    rs.getDate("EndDate"),
                    rs.getString("TravelStyle"),
                    rs.getDouble("MinBudget"),
                    rs.getDouble("MaxBudget"),
                    rs.getInt("TargetAgeMin"),
                    rs.getInt("TargetAgeMax"),
                    rs.getString("TargetGender"),
                    rs.getString("Languages"),
                    rs.getString("Tags"),
                    rs.getString("TripDuration"),
                    rs.getString("TravelFrequency"),
                    rs.getString("ActivityPreferences"),
                    rs.getString("SmokingPreference"),
                    rs.getString("DrinkingPreference"),
                    rs.getTimestamp("CreatedAt"),
                    rs.getTimestamp("UpdatedAt")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean savePreference(TravelPreference pref) {
        TravelPreference exist = getPreference(pref.getUserId());
        String sql;
        if (exist == null) {
            sql = "INSERT INTO TravelPreference (UserId, Destination, StartDate, EndDate, TravelStyle, MinBudget, MaxBudget, TargetAgeMin, TargetAgeMax, TargetGender, Languages, Tags, TripDuration, TravelFrequency, ActivityPreferences, SmokingPreference, DrinkingPreference, CreatedAt, UpdatedAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATETIME(), SYSDATETIME())";
        } else {
            sql = "UPDATE TravelPreference SET Destination=?, StartDate=?, EndDate=?, TravelStyle=?, MinBudget=?, MaxBudget=?, TargetAgeMin=?, TargetAgeMax=?, TargetGender=?, Languages=?, Tags=?, TripDuration=?, TravelFrequency=?, ActivityPreferences=?, SmokingPreference=?, DrinkingPreference=?, UpdatedAt=SYSDATETIME() WHERE UserId=?";
        }

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (exist == null) {
                ps.setInt(1, pref.getUserId());
                ps.setString(2, pref.getDestination());
                ps.setDate(3, pref.getStartDate());
                ps.setDate(4, pref.getEndDate());
                ps.setString(5, pref.getTravelStyle());
                ps.setDouble(6, pref.getMinBudget());
                ps.setDouble(7, pref.getMaxBudget());
                ps.setInt(8, pref.getTargetAgeMin());
                ps.setInt(9, pref.getTargetAgeMax());
                ps.setString(10, pref.getTargetGender());
                ps.setString(11, pref.getLanguages());
                ps.setString(12, pref.getTags());
                ps.setString(13, pref.getTripDuration());
                ps.setString(14, pref.getTravelFrequency());
                ps.setString(15, pref.getActivityPreferences());
                ps.setString(16, pref.getSmokingPreference());
                ps.setString(17, pref.getDrinkingPreference());
            } else {
                ps.setString(1, pref.getDestination());
                ps.setDate(2, pref.getStartDate());
                ps.setDate(3, pref.getEndDate());
                ps.setString(4, pref.getTravelStyle());
                ps.setDouble(5, pref.getMinBudget());
                ps.setDouble(6, pref.getMaxBudget());
                ps.setInt(7, pref.getTargetAgeMin());
                ps.setInt(8, pref.getTargetAgeMax());
                ps.setString(9, pref.getTargetGender());
                ps.setString(10, pref.getLanguages());
                ps.setString(11, pref.getTags());
                ps.setString(12, pref.getTripDuration());
                ps.setString(13, pref.getTravelFrequency());
                ps.setString(14, pref.getActivityPreferences());
                ps.setString(15, pref.getSmokingPreference());
                ps.setString(16, pref.getDrinkingPreference());
                ps.setInt(17, pref.getUserId());
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<MatchedUser> getTopMatches(int currentUserId) {
        TravelPreference myPref = getPreference(currentUserId);
        List<MatchedUser> matches = new ArrayList<>();
        
        // If current user has no preferences, use default flexible preference
        if (myPref == null) {
            myPref = new TravelPreference();
            myPref.setDestination("Any Destination");
            myPref.setTravelStyle("Any Style");
            myPref.setLanguages("Tiếng Việt");
            myPref.setMinBudget(0);
            myPref.setMaxBudget(999999999);
            myPref.setTags("Du lịch");
        }

        String sql = "SELECT u.UserID, u.FullName, u.Email, u.IsActive, u.CreatedAt as UserCreatedAt, "
                   + "p.AvatarURL, p.Biography, p.Address, "
                   + "t.Destination, t.StartDate, t.EndDate, t.TravelStyle, t.MinBudget, t.MaxBudget, t.TargetAgeMin, t.TargetAgeMax, t.TargetGender, t.Languages, t.Tags, "
                   + "t.TripDuration, t.TravelFrequency, t.ActivityPreferences, t.SmokingPreference, t.DrinkingPreference "
                   + "FROM [User] u "
                   + "LEFT JOIN UserProfile p ON u.UserID = p.UserID "
                   + "LEFT JOIN TravelPreference t ON u.UserID = t.UserId "
                   + "WHERE u.UserID != ? AND u.RoleID = 4 AND u.IsActive = 1 "
                   + "AND u.UserID NOT IN ("
                   + "  SELECT ReceiverId FROM BuddyRequest WHERE SenderId = ? AND Status IN ('Pending', 'Accepted') "
                   + "  UNION "
                   + "  SELECT SenderId FROM BuddyRequest WHERE ReceiverId = ? AND Status IN ('Pending', 'Accepted')"
                   + ")";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, currentUserId);
            ps.setInt(2, currentUserId);
            ps.setInt(3, currentUserId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("UserID"));
                u.setFullName(rs.getString("FullName"));
                u.setEmail(rs.getString("Email"));
                
                UserProfile p = new UserProfile();
                p.setAvatarUrl(rs.getString("AvatarURL"));
                p.setBiography(rs.getString("Biography"));
                p.setAddress(rs.getString("Address"));
                
                TravelPreference t = new TravelPreference();
                // Handle nulls gracefully when TravelPreference doesn't exist yet
                String dest = rs.getString("Destination");
                t.setDestination(dest != null ? dest : "Vietnam");
                t.setStartDate(rs.getDate("StartDate"));
                t.setEndDate(rs.getDate("EndDate"));
                String style = rs.getString("TravelStyle");
                t.setTravelStyle(style != null ? style : "Explorer");
                t.setMinBudget(rs.getDouble("MinBudget"));
                t.setMaxBudget(rs.getDouble("MaxBudget"));
                String tags = rs.getString("Tags");
                t.setTags(tags != null ? tags : "Culture, Foodie");
                String lang = rs.getString("Languages");
                t.setLanguages(lang != null ? lang : "Tiếng Việt");
                t.setTripDuration(rs.getString("TripDuration"));
                t.setTravelFrequency(rs.getString("TravelFrequency"));
                t.setActivityPreferences(rs.getString("ActivityPreferences"));
                t.setSmokingPreference(rs.getString("SmokingPreference"));
                t.setDrinkingPreference(rs.getString("DrinkingPreference"));
                
                int score = calculateMatchScore(myPref, t);
                if (score > 10) { // Lowered threshold so even empty users might show up
                    matches.add(new MatchedUser(u, p, t, score));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Sort descending by match percentage
        matches.sort((a, b) -> b.getMatchPercentage() - a.getMatchPercentage());
        return matches;
    }

    private int calculateMatchScore(TravelPreference myPref, TravelPreference theirPref) {
        int score = 0;
        
        // 1. Destination (30%)
        if (myPref.getDestination() != null && theirPref.getDestination() != null) {
            if (myPref.getDestination().equalsIgnoreCase(theirPref.getDestination())) {
                score += 30;
            } else if (myPref.getDestination().toLowerCase().contains("any") || theirPref.getDestination().toLowerCase().contains("any")) {
                score += 15; // Partial match if someone is flexible
            }
        }

        // 2. Travel Style (20%)
        if (myPref.getTravelStyle() != null && theirPref.getTravelStyle() != null) {
            if (myPref.getTravelStyle().equalsIgnoreCase(theirPref.getTravelStyle())) {
                score += 20;
            } else if (myPref.getTravelStyle().toLowerCase().contains("any")) {
                score += 10;
            }
        }

        // 3. Date Overlap (20%)
        if (myPref.getStartDate() != null && myPref.getEndDate() != null && 
            theirPref.getStartDate() != null && theirPref.getEndDate() != null) {
            long myStart = myPref.getStartDate().getTime();
            long myEnd = myPref.getEndDate().getTime();
            long theirStart = theirPref.getStartDate().getTime();
            long theirEnd = theirPref.getEndDate().getTime();
            
            // Check overlap
            if (myStart <= theirEnd && myEnd >= theirStart) {
                score += 20;
            }
        } else {
            // Flexible dates
            score += 10;
        }

        // 4. Budget Overlap (15%)
        if (myPref.getMaxBudget() >= theirPref.getMinBudget() && myPref.getMinBudget() <= theirPref.getMaxBudget()) {
            score += 15;
        }

        // 5. Tags / Interests (15%)
        if (myPref.getTags() != null && theirPref.getTags() != null) {
            String[] myTags = myPref.getTags().split(",");
            String theirTagsLower = theirPref.getTags().toLowerCase();
            int matchCount = 0;
            for (String tag : myTags) {
                if (theirTagsLower.contains(tag.trim().toLowerCase())) {
                    matchCount++;
                }
            }
            if (matchCount > 0) {
                score += Math.min(15, matchCount * 5);
            }
        }
        
        // 6. Activity Preferences (15%)
        if (myPref.getActivityPreferences() != null && theirPref.getActivityPreferences() != null) {
            String[] myActs = myPref.getActivityPreferences().split(",");
            String theirActsLower = theirPref.getActivityPreferences().toLowerCase();
            int matchCount = 0;
            for (String act : myActs) {
                if (theirActsLower.contains(act.trim().toLowerCase())) {
                    matchCount++;
                }
            }
            if (matchCount > 0) {
                score += Math.min(15, matchCount * 5);
            }
        }

        // 7. Smoking/Drinking (10%)
        if (myPref.getSmokingPreference() != null && theirPref.getSmokingPreference() != null) {
            if (myPref.getSmokingPreference().equalsIgnoreCase(theirPref.getSmokingPreference()) || 
                myPref.getSmokingPreference().contains("Don't care")) {
                score += 5;
            }
        }
        if (myPref.getDrinkingPreference() != null && theirPref.getDrinkingPreference() != null) {
            if (myPref.getDrinkingPreference().equalsIgnoreCase(theirPref.getDrinkingPreference()) || 
                myPref.getDrinkingPreference().contains("Don't care")) {
                score += 5;
            }
        }
        
        // Ensure not > 100
        return Math.min(score, 100);
    }
}
