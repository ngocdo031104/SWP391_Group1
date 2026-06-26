package Entities;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;

public class AnalyticsReport implements Serializable {
    private int reportId;
    private String reportType;
    private Date periodStart;
    private Date periodEnd;
    private String data;
    private Integer generatedBy;
    private Timestamp generatedAt;
    
    // Additional field for display
    private String generatedByName;

    public AnalyticsReport() {
    }

    public AnalyticsReport(int reportId, String reportType, Date periodStart, Date periodEnd, String data, Integer generatedBy, Timestamp generatedAt) {
        this.reportId = reportId;
        this.reportType = reportType;
        this.periodStart = periodStart;
        this.periodEnd = periodEnd;
        this.data = data;
        this.generatedBy = generatedBy;
        this.generatedAt = generatedAt;
    }

    public AnalyticsReport(int reportId, String reportType, Date periodStart, Date periodEnd, String data, Integer generatedBy, Timestamp generatedAt, String generatedByName) {
        this.reportId = reportId;
        this.reportType = reportType;
        this.periodStart = periodStart;
        this.periodEnd = periodEnd;
        this.data = data;
        this.generatedBy = generatedBy;
        this.generatedAt = generatedAt;
        this.generatedByName = generatedByName;
    }

    public int getReportId() {
        return reportId;
    }

    public void setReportId(int reportId) {
        this.reportId = reportId;
    }

    public String getReportType() {
        return reportType;
    }

    public void setReportType(String reportType) {
        this.reportType = reportType;
    }

    public Date getPeriodStart() {
        return periodStart;
    }

    public void setPeriodStart(Date periodStart) {
        this.periodStart = periodStart;
    }

    public Date getPeriodEnd() {
        return periodEnd;
    }

    public void setPeriodEnd(Date periodEnd) {
        this.periodEnd = periodEnd;
    }

    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
    }

    public Integer getGeneratedBy() {
        return generatedBy;
    }

    public void setGeneratedBy(Integer generatedBy) {
        this.generatedBy = generatedBy;
    }

    public Timestamp getGeneratedAt() {
        return generatedAt;
    }

    public void setGeneratedAt(Timestamp generatedAt) {
        this.generatedAt = generatedAt;
    }

    public String getGeneratedByName() {
        return generatedByName;
    }

    public void setGeneratedByName(String generatedByName) {
        this.generatedByName = generatedByName;
    }
}
