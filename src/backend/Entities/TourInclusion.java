package Entities;

import java.io.Serializable;
import java.sql.Timestamp;

public class TourInclusion implements Serializable {
    private int inclusionId;
    private int tourId;
    private String inclusionType; // INCLUDED or EXCLUDED
    private String serviceName;
    private String description;
    private String iconName;
    private int sortOrder;
    private boolean isActive;
    private Timestamp createdAt;

    public TourInclusion() {
    }

    public int getInclusionId() {
        return inclusionId;
    }

    public void setInclusionId(int inclusionId) {
        this.inclusionId = inclusionId;
    }

    public int getTourId() {
        return tourId;
    }

    public void setTourId(int tourId) {
        this.tourId = tourId;
    }

    public String getInclusionType() {
        return inclusionType;
    }

    public void setInclusionType(String inclusionType) {
        this.inclusionType = inclusionType;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getIconName() {
        return iconName;
    }

    public void setIconName(String iconName) {
        this.iconName = iconName;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
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
}
