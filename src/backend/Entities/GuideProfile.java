package Entities;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * LỚP THỰC THỂ GUIDEPROFILE (HỒ SƠ HƯỚNG DẪN VIÊN)
 * - Liên kết 1-1 với bảng [User] (chỉ dành cho User có RoleID = 3 tức là Guide).
 * - Lưu trữ các thông tin chuyên môn, kinh nghiệm, xếp hạng và tiểu sử của HDV.
 * - Ánh xạ trực tiếp với bảng `GuideProfile` trong cơ sở dữ liệu.
 */
public class GuideProfile implements Serializable {
    private int guideProfileId;
    private int userId;
    private int yearsOfExperience;
    private int totalToursLed;
    private double rating;
    private String bio;
    private String specialization;
    private String languages; // Lưu trữ danh sách ngôn ngữ (dạng chuỗi JSON hoặc text ví dụ: ["vi","en"])
    private String certifications;
    private String emergencyPhone;
    private boolean isActive;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Đối tượng liên kết
    private User user; // Thông tin tài khoản chung (họ tên, email, avatar...) của HDV

    public GuideProfile() {
    }

    public int getGuideProfileId() {
        return guideProfileId;
    }

    public void setGuideProfileId(int guideProfileId) {
        this.guideProfileId = guideProfileId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getYearsOfExperience() {
        return yearsOfExperience;
    }

    public void setYearsOfExperience(int yearsOfExperience) {
        this.yearsOfExperience = yearsOfExperience;
    }

    public int getTotalToursLed() {
        return totalToursLed;
    }

    public void setTotalToursLed(int totalToursLed) {
        this.totalToursLed = totalToursLed;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public String getBio() {
        return bio;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }

    public String getSpecialization() {
        return specialization;
    }

    public void setSpecialization(String specialization) {
        this.specialization = specialization;
    }

    public String getLanguages() {
        return languages;
    }

    public void setLanguages(String languages) {
        this.languages = languages;
    }

    public String getCertifications() {
        return certifications;
    }

    public void setCertifications(String certifications) {
        this.certifications = certifications;
    }

    public String getEmergencyPhone() {
        return emergencyPhone;
    }

    public void setEmergencyPhone(String emergencyPhone) {
        this.emergencyPhone = emergencyPhone;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
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

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}
