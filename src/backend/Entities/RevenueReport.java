package Entities;

import java.io.Serializable;
import java.sql.Timestamp;

public class RevenueReport implements Serializable {
    private int revenueReportId;
    private int reportId;
    private String exportFormat;
    private String fileUrl;
    private Integer exportedBy;
    private Timestamp exportedAt;
    
    // Additional field for UI display
    private String exportedByName;

    public RevenueReport() {
    }

    public RevenueReport(int revenueReportId, int reportId, String exportFormat, String fileUrl, Integer exportedBy, Timestamp exportedAt) {
        this.revenueReportId = revenueReportId;
        this.reportId = reportId;
        this.exportFormat = exportFormat;
        this.fileUrl = fileUrl;
        this.exportedBy = exportedBy;
        this.exportedAt = exportedAt;
    }

    public int getRevenueReportId() {
        return revenueReportId;
    }

    public void setRevenueReportId(int revenueReportId) {
        this.revenueReportId = revenueReportId;
    }

    public int getReportId() {
        return reportId;
    }

    public void setReportId(int reportId) {
        this.reportId = reportId;
    }

    public String getExportFormat() {
        return exportFormat;
    }

    public void setExportFormat(String exportFormat) {
        this.exportFormat = exportFormat;
    }

    public String getFileUrl() {
        return fileUrl;
    }

    public void setFileUrl(String fileUrl) {
        this.fileUrl = fileUrl;
    }

    public Integer getExportedBy() {
        return exportedBy;
    }

    public void setExportedBy(Integer exportedBy) {
        this.exportedBy = exportedBy;
    }

    public Timestamp getExportedAt() {
        return exportedAt;
    }

    public void setExportedAt(Timestamp exportedAt) {
        this.exportedAt = exportedAt;
    }

    public String getExportedByName() {
        return exportedByName;
    }

    public void setExportedByName(String exportedByName) {
        this.exportedByName = exportedByName;
    }
}
