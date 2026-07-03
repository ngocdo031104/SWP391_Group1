package Entities;

public class MatchedUser {
    private User user;
    private UserProfile profile;
    private TravelPreference preference;
    private int matchPercentage;

    public MatchedUser(User user, UserProfile profile, TravelPreference preference, int matchPercentage) {
        this.user = user;
        this.profile = profile;
        this.preference = preference;
        this.matchPercentage = matchPercentage;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public UserProfile getProfile() {
        return profile;
    }

    public void setProfile(UserProfile profile) {
        this.profile = profile;
    }

    public TravelPreference getPreference() {
        return preference;
    }

    public void setPreference(TravelPreference preference) {
        this.preference = preference;
    }

    public int getMatchPercentage() {
        return matchPercentage;
    }

    public void setMatchPercentage(int matchPercentage) {
        this.matchPercentage = matchPercentage;
    }
}
