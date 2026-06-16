package Entities;

import java.io.Serializable;

public class DestinationInfo implements Serializable {
    private String name;
    private int tourCount;
    private String imageUrl;

    public DestinationInfo() {
    }

    public DestinationInfo(String name, int tourCount, String imageUrl) {
        this.name = name;
        this.tourCount = tourCount;
        this.imageUrl = imageUrl;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getTourCount() {
        return tourCount;
    }

    public void setTourCount(int tourCount) {
        this.tourCount = tourCount;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
}
