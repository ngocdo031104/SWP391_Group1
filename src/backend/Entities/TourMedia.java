package Entities;

import java.io.Serializable;
import java.sql.Timestamp;

public class TourMedia implements Serializable {
    private int mediaId;
    private int tourId;
    private String mediaUrl;
    private String mediaType;
    private String caption;
    private int sortOrder;
    private boolean isVisible;
    private Integer uploadedBy;
    private Timestamp uploadedAt;
    private String uploaderName; // Thuộc tính bổ sung để hiển thị tên người tải lên

    public TourMedia() {
    }

    public TourMedia(int mediaId, int tourId, String mediaUrl, String mediaType, String caption, int sortOrder, boolean isVisible, Integer uploadedBy, Timestamp uploadedAt) {
        this.mediaId = mediaId;
        this.tourId = tourId;
        this.mediaUrl = mediaUrl;
        this.mediaType = mediaType;
        this.caption = caption;
        this.sortOrder = sortOrder;
        this.isVisible = isVisible;
        this.uploadedBy = uploadedBy;
        this.uploadedAt = uploadedAt;
    }

    public TourMedia(int mediaId, int tourId, String mediaUrl, String mediaType, String caption, int sortOrder, boolean isVisible, Integer uploadedBy, Timestamp uploadedAt, String uploaderName) {
        this(mediaId, tourId, mediaUrl, mediaType, caption, sortOrder, isVisible, uploadedBy, uploadedAt);
        this.uploaderName = uploaderName;
    }

    public int getMediaId() {
        return mediaId;
    }

    public void setMediaId(int mediaId) {
        this.mediaId = mediaId;
    }

    public int getTourId() {
        return tourId;
    }

    public void setTourId(int tourId) {
        this.tourId = tourId;
    }

    public String getMediaUrl() {
        return mediaUrl;
    }

    public void setMediaUrl(String mediaUrl) {
        this.mediaUrl = mediaUrl;
    }

    public String getMediaType() {
        return mediaType;
    }

    public void setMediaType(String mediaType) {
        this.mediaType = mediaType;
    }

    public String getCaption() {
        return caption;
    }

    public void setCaption(String caption) {
        this.caption = caption;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }

    public boolean isIsVisible() {
        return isVisible;
    }

    public void setIsVisible(boolean isVisible) {
        this.isVisible = isVisible;
    }

    public Integer getUploadedBy() {
        return uploadedBy;
    }

    public void setUploadedBy(Integer uploadedBy) {
        this.uploadedBy = uploadedBy;
    }

    public Timestamp getUploadedAt() {
        return uploadedAt;
    }

    public void setUploadedAt(Timestamp uploadedAt) {
        this.uploadedAt = uploadedAt;
    }

    public String getUploaderName() {
        return uploaderName;
    }

    public void setUploaderName(String uploaderName) {
        this.uploaderName = uploaderName;
    }
}
