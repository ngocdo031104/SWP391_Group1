package Entities;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.List;

public class Tour implements Serializable {
    private int tourId;
    private int categoryId;
    private String tourName;
    private String description;
    private String destination;
    private int durationDays;
    private String itinerary;
    private String difficultyLevel;
    private double basePrice;
    private int maxParticipants;
    private String status;
    private boolean isFeatured;
    private Integer createdBy;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Linked Entities
    private TourCategory category;
    private List<TourSchedule> schedules;
    private List<TourMedia> mediaList;

    public Tour() {
    }

    public Tour(int tourId, int categoryId, String tourName, String description, String destination, int durationDays, String itinerary, String difficultyLevel, double basePrice, int maxParticipants, String status, boolean isFeatured, Integer createdBy, Timestamp createdAt, Timestamp updatedAt) {
        this.tourId = tourId;
        this.categoryId = categoryId;
        this.tourName = tourName;
        this.description = description;
        this.destination = destination;
        this.durationDays = durationDays;
        this.itinerary = itinerary;
        this.difficultyLevel = difficultyLevel;
        this.basePrice = basePrice;
        this.maxParticipants = maxParticipants;
        this.status = status;
        this.isFeatured = isFeatured;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getTourId() {
        return tourId;
    }

    public void setTourId(int tourId) {
        this.tourId = tourId;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getTourName() {
        return tourName;
    }

    public void setTourName(String tourName) {
        this.tourName = tourName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getDestination() {
        return destination;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public int getDurationDays() {
        return durationDays;
    }

    public void setDurationDays(int durationDays) {
        this.durationDays = durationDays;
    }

    public String getItinerary() {
        return itinerary;
    }

    public void setItinerary(String itinerary) {
        this.itinerary = itinerary;
    }

    public String getDifficultyLevel() {
        return difficultyLevel;
    }

    public void setDifficultyLevel(String difficultyLevel) {
        this.difficultyLevel = difficultyLevel;
    }

    public double getBasePrice() {
        return basePrice;
    }

    public void setBasePrice(double basePrice) {
        this.basePrice = basePrice;
    }

    public int getMaxParticipants() {
        return maxParticipants;
    }

    public void setMaxParticipants(int maxParticipants) {
        this.maxParticipants = maxParticipants;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isIsFeatured() {
        return isFeatured;
    }

    public void setIsFeatured(boolean isFeatured) {
        this.isFeatured = isFeatured;
    }

    public Integer getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
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

    public TourCategory getCategory() {
        return category;
    }

    public void setCategory(TourCategory category) {
        this.category = category;
    }

    public List<TourSchedule> getSchedules() {
        return schedules;
    }

    public void setSchedules(List<TourSchedule> schedules) {
        this.schedules = schedules;
    }

    public List<TourMedia> getMediaList() {
        return mediaList;
    }

    public void setMediaList(List<TourMedia> mediaList) {
        this.mediaList = mediaList;
    }
}
