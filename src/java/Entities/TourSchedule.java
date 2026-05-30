package Entities;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;

public class TourSchedule implements Serializable {
    private int scheduleId;
    private int tourId;
    private Date departureDate;
    private Date returnDate;
    private int totalSeats;
    private int availableSeats;
    private double priceAdult;
    private double priceChild;
    private double priceInfant;
    private String transportation;
    private String status;
    private Timestamp createdAt;

    public TourSchedule() {
    }

    public TourSchedule(int scheduleId, int tourId, Date departureDate, Date returnDate, int totalSeats, int availableSeats, double priceAdult, double priceChild, double priceInfant, String transportation, String status, Timestamp createdAt) {
        this.scheduleId = scheduleId;
        this.tourId = tourId;
        this.departureDate = departureDate;
        this.returnDate = returnDate;
        this.totalSeats = totalSeats;
        this.availableSeats = availableSeats;
        this.priceAdult = priceAdult;
        this.priceChild = priceChild;
        this.priceInfant = priceInfant;
        this.transportation = transportation;
        this.status = status;
        this.createdAt = createdAt;
    }

    public int getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(int scheduleId) {
        this.scheduleId = scheduleId;
    }

    public int getTourId() {
        return tourId;
    }

    public void setTourId(int tourId) {
        this.tourId = tourId;
    }

    public Date getDepartureDate() {
        return departureDate;
    }

    public void setDepartureDate(Date departureDate) {
        this.departureDate = departureDate;
    }

    public Date getReturnDate() {
        return returnDate;
    }

    public void setReturnDate(Date returnDate) {
        this.returnDate = returnDate;
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

    public double getPriceAdult() {
        return priceAdult;
    }

    public void setPriceAdult(double priceAdult) {
        this.priceAdult = priceAdult;
    }

    public double getPriceChild() {
        return priceChild;
    }

    public void setPriceChild(double priceChild) {
        this.priceChild = priceChild;
    }

    public double getPriceInfant() {
        return priceInfant;
    }

    public void setPriceInfant(double priceInfant) {
        this.priceInfant = priceInfant;
    }

    public String getTransportation() {
        return transportation;
    }

    public void setTransportation(String transportation) {
        this.transportation = transportation;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
