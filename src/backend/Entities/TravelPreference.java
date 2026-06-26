package Entities;

import java.sql.Date;
import java.sql.Timestamp;

public class TravelPreference {
    private int preferenceId;
    private int userId;
    private String destination;
    private Date startDate;
    private Date endDate;
    private String travelStyle;
    private double minBudget;
    private double maxBudget;
    private int targetAgeMin;
    private int targetAgeMax;
    private String targetGender;
    private String languages;
    private String tags;
    private String tripDuration;
    private String travelFrequency;
    private String activityPreferences;
    private String smokingPreference;
    private String drinkingPreference;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public TravelPreference() {
    }

    public TravelPreference(int preferenceId, int userId, String destination, Date startDate, Date endDate, String travelStyle, double minBudget, double maxBudget, int targetAgeMin, int targetAgeMax, String targetGender, String languages, String tags, String tripDuration, String travelFrequency, String activityPreferences, String smokingPreference, String drinkingPreference, Timestamp createdAt, Timestamp updatedAt) {
        this.preferenceId = preferenceId;
        this.userId = userId;
        this.destination = destination;
        this.startDate = startDate;
        this.endDate = endDate;
        this.travelStyle = travelStyle;
        this.minBudget = minBudget;
        this.maxBudget = maxBudget;
        this.targetAgeMin = targetAgeMin;
        this.targetAgeMax = targetAgeMax;
        this.targetGender = targetGender;
        this.languages = languages;
        this.tags = tags;
        this.tripDuration = tripDuration;
        this.travelFrequency = travelFrequency;
        this.activityPreferences = activityPreferences;
        this.smokingPreference = smokingPreference;
        this.drinkingPreference = drinkingPreference;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getPreferenceId() {
        return preferenceId;
    }

    public void setPreferenceId(int preferenceId) {
        this.preferenceId = preferenceId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getDestination() {
        return destination;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public String getTravelStyle() {
        return travelStyle;
    }

    public void setTravelStyle(String travelStyle) {
        this.travelStyle = travelStyle;
    }

    public double getMinBudget() {
        return minBudget;
    }

    public void setMinBudget(double minBudget) {
        this.minBudget = minBudget;
    }

    public double getMaxBudget() {
        return maxBudget;
    }

    public void setMaxBudget(double maxBudget) {
        this.maxBudget = maxBudget;
    }

    public int getTargetAgeMin() {
        return targetAgeMin;
    }

    public void setTargetAgeMin(int targetAgeMin) {
        this.targetAgeMin = targetAgeMin;
    }

    public int getTargetAgeMax() {
        return targetAgeMax;
    }

    public void setTargetAgeMax(int targetAgeMax) {
        this.targetAgeMax = targetAgeMax;
    }

    public String getTargetGender() {
        return targetGender;
    }

    public void setTargetGender(String targetGender) {
        this.targetGender = targetGender;
    }

    public String getLanguages() {
        return languages;
    }

    public void setLanguages(String languages) {
        this.languages = languages;
    }

    public String getTags() {
        return tags;
    }

    public void setTags(String tags) {
        this.tags = tags;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getTripDuration() {
        return tripDuration;
    }

    public void setTripDuration(String tripDuration) {
        this.tripDuration = tripDuration;
    }

    public String getTravelFrequency() {
        return travelFrequency;
    }

    public void setTravelFrequency(String travelFrequency) {
        this.travelFrequency = travelFrequency;
    }

    public String getActivityPreferences() {
        return activityPreferences;
    }

    public void setActivityPreferences(String activityPreferences) {
        this.activityPreferences = activityPreferences;
    }

    public String getSmokingPreference() {
        return smokingPreference;
    }

    public void setSmokingPreference(String smokingPreference) {
        this.smokingPreference = smokingPreference;
    }

    public String getDrinkingPreference() {
        return drinkingPreference;
    }

    public void setDrinkingPreference(String drinkingPreference) {
        this.drinkingPreference = drinkingPreference;
    }
}
