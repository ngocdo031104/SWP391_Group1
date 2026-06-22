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
    
    // New fields matching the updated DB schema
    private String languages;
    private int groupSizeMin;
    private int groupSizeMax;
    private String departureCity;
    private Double latitude;
    private Double longitude;
    private String videoUrl;
    
    // Derived fields
    private double rating = 0.0;
    private int reviewsCount = 0;
    private int totalSeats;
    private int availableSeats;
    private String nextDeparture;

    private Integer createdBy;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // --- CÁC THỰC THỂ LIÊN KẾT (RELATIONAL ENTITIES) ---
    private TourCategory category;
    private List<TourSchedule> schedules;
    private List<TourMedia> mediaList;
    private List<TourItinerary> itineraries;
    private List<TourInclusion> inclusions;
    private List<TourFAQ> faqs;
    private List<Review> reviews;

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

    public String getLanguages() {
        return languages;
    }

    public void setLanguages(String languages) {
        this.languages = languages;
    }

    public int getGroupSizeMin() {
        return groupSizeMin;
    }

    public void setGroupSizeMin(int groupSizeMin) {
        this.groupSizeMin = groupSizeMin;
    }

    public int getGroupSizeMax() {
        return groupSizeMax;
    }

    public void setGroupSizeMax(int groupSizeMax) {
        this.groupSizeMax = groupSizeMax;
    }

    public String getDepartureCity() {
        return departureCity;
    }

    public void setDepartureCity(String departureCity) {
        this.departureCity = departureCity;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public String getVideoUrl() {
        return videoUrl;
    }

    public void setVideoUrl(String videoUrl) {
        this.videoUrl = videoUrl;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public int getReviewsCount() {
        return reviewsCount;
    }

    public void setReviewsCount(int reviewsCount) {
        this.reviewsCount = reviewsCount;
    }

    public int getTotalSeats() {
        return totalSeats;
    }

    public void setTotalSeats(int totalSeats) {
        this.totalSeats = totalSeats;
    }

    public int getAvailableSeats() {
        return availableSeats;
    }

    public void setAvailableSeats(int availableSeats) {
        this.availableSeats = availableSeats;
    }

    public String getNextDeparture() {
        return nextDeparture;
    }

    public void setNextDeparture(String nextDeparture) {
        this.nextDeparture = nextDeparture;
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

    public List<TourItinerary> getItineraries() {
        return itineraries;
    }

    public void setItineraries(List<TourItinerary> itineraries) {
        this.itineraries = itineraries;
    }

    public List<TourInclusion> getInclusions() {
        return inclusions;
    }

    public void setInclusions(List<TourInclusion> inclusions) {
        this.inclusions = inclusions;
    }

    public List<TourFAQ> getFaqs() {
        return faqs;
    }

    public void setFaqs(List<TourFAQ> faqs) {
        this.faqs = faqs;
    }

    public List<Review> getReviews() {
        return reviews;
    }

    public void setReviews(List<Review> reviews) {
        this.reviews = reviews;
    }
}
