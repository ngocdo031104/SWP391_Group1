package Entities;

import java.sql.Timestamp;

public class TourOperationLog {
    private int logId;
    private int scheduleId;
    private String tourName;
    private Timestamp departureDate;
    private String activity;
    private Integer operatedBy;
    private Timestamp createdAt;
    private String operatorName;
    private String operatorRole;

    public TourOperationLog() {}

    public TourOperationLog(int logId, int scheduleId, String tourName, Timestamp departureDate, String activity, Integer operatedBy, Timestamp createdAt, String operatorName, String operatorRole) {
        this.logId = logId;
        this.scheduleId = scheduleId;
        this.tourName = tourName;
        this.departureDate = departureDate;
        this.activity = activity;
        this.operatedBy = operatedBy;
        this.createdAt = createdAt;
        this.operatorName = operatorName;
        this.operatorRole = operatorRole;
    }

    public int getLogId() {
        return logId;
    }

    public void setLogId(int logId) {
        this.logId = logId;
    }

    public int getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(int scheduleId) {
        this.scheduleId = scheduleId;
    }

    public String getTourName() {
        return tourName;
    }

    public void setTourName(String tourName) {
        this.tourName = tourName;
    }

    public Timestamp getDepartureDate() {
        return departureDate;
    }

    public void setDepartureDate(Timestamp departureDate) {
        this.departureDate = departureDate;
    }

    public String getActivity() {
        return activity;
    }

    public void setActivity(String activity) {
        this.activity = activity;
    }

    public Integer getOperatedBy() {
        return operatedBy;
    }

    public void setOperatedBy(Integer operatedBy) {
        this.operatedBy = operatedBy;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getOperatorName() {
        return operatorName;
    }

    public void setOperatorName(String operatorName) {
        this.operatorName = operatorName;
    }

    public String getOperatorRole() {
        return operatorRole;
    }

    public void setOperatorRole(String operatorRole) {
        this.operatorRole = operatorRole;
    }
}
