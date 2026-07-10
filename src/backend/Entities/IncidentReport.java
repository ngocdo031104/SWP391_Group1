package Entities;

import java.sql.Timestamp;

public class IncidentReport {
    private int incidentId;
    private int scheduleId;
    private int reportedBy;
    private String reportedByName;
    private String title;
    private String description;
    private String severity;
    private String status;
    private Integer resolvedBy;
    private Timestamp resolvedAt;
    private Timestamp createdAt;

    public IncidentReport() {}

    public IncidentReport(int incidentId, int scheduleId, int reportedBy, String reportedByName, String title, String description, String severity, String status, Integer resolvedBy, Timestamp resolvedAt, Timestamp createdAt) {
        this.incidentId = incidentId;
        this.scheduleId = scheduleId;
        this.reportedBy = reportedBy;
        this.reportedByName = reportedByName;
        this.title = title;
        this.description = description;
        this.severity = severity;
        this.status = status;
        this.resolvedBy = resolvedBy;
        this.resolvedAt = resolvedAt;
        this.createdAt = createdAt;
    }

    public int getIncidentId() {
        return incidentId;
    }

    public void setIncidentId(int incidentId) {
        this.incidentId = incidentId;
    }

    public int getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(int scheduleId) {
        this.scheduleId = scheduleId;
    }

    public int getReportedBy() {
        return reportedBy;
    }

    public void setReportedBy(int reportedBy) {
        this.reportedBy = reportedBy;
    }

    public String getReportedByName() {
        return reportedByName;
    }

    public void setReportedByName(String reportedByName) {
        this.reportedByName = reportedByName;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getSeverity() {
        return severity;
    }

    public void setSeverity(String severity) {
        this.severity = severity;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getResolvedBy() {
        return resolvedBy;
    }

    public void setResolvedBy(Integer resolvedBy) {
        this.resolvedBy = resolvedBy;
    }

    public Timestamp getResolvedAt() {
        return resolvedAt;
    }

    public void setResolvedAt(Timestamp resolvedAt) {
        this.resolvedAt = resolvedAt;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
