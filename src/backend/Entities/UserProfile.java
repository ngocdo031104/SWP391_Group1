package Entities;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;

public class UserProfile implements Serializable {
    private int profileId;
    private int userId;
    private String avatarUrl;
    private String biography;
    private Date dateOfBirth;
    private String gender;
    private String address;
    private String travelInterests;
    private Timestamp updatedAt;

    public UserProfile() {
    }

    public UserProfile(int profileId, int userId, String avatarUrl, String biography, Date dateOfBirth, String gender, String address, String travelInterests, Timestamp updatedAt) {
        this.profileId = profileId;
        this.userId = userId;
        this.avatarUrl = avatarUrl;
        this.biography = biography;
        this.dateOfBirth = dateOfBirth;
        this.gender = gender;
        this.address = address;
        this.travelInterests = travelInterests;
        this.updatedAt = updatedAt;
    }

    public int getProfileId() {
        return profileId;
    }

    public void setProfileId(int profileId) {
        this.profileId = profileId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public String getBiography() {
        return biography;
    }

    public void setBiography(String biography) {
        this.biography = biography;
    }

    public Date getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(Date dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getTravelInterests() {
        return travelInterests;
    }

    public void setTravelInterests(String travelInterests) {
        this.travelInterests = travelInterests;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}
