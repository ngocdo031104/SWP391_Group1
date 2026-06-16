package Entities;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * LỚP THỰC THỂ TOURASSIGNMENT (LỊCH SỬ/PHÂN CÔNG DẪN ĐOÀN)
 * - Quản lý việc phân công hướng dẫn viên phụ trách một đợt khởi hành cụ thể.
 * - Ánh xạ trực tiếp với bảng `TourAssignment` trong cơ sở dữ liệu.
 */
public class TourAssignment implements Serializable {
    private int assignmentId;
    private int scheduleId;
    private int guideId;
    private Integer assignedBy;
    private Timestamp assignedAt;
    private String notes;

    // Các đối tượng liên kết
    private TourSchedule schedule; // Lịch khởi hành của tour tương ứng
    private User guide; // Đối tượng HDV phụ trách chuyến đi

    public TourAssignment() {
    }

    public int getAssignmentId() {
        return assignmentId;
    }

    public void setAssignmentId(int assignmentId) {
        this.assignmentId = assignmentId;
    }

    public int getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(int scheduleId) {
        this.scheduleId = scheduleId;
    }

    public int getGuideId() {
        return guideId;
    }

    public void setGuideId(int guideId) {
        this.guideId = guideId;
    }

    public Integer getAssignedBy() {
        return assignedBy;
    }

    public void setAssignedBy(Integer assignedBy) {
        this.assignedBy = assignedBy;
    }

    public Timestamp getAssignedAt() {
        return assignedAt;
    }

    public void setAssignedAt(Timestamp assignedAt) {
        this.assignedAt = assignedAt;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public TourSchedule getSchedule() {
        return schedule;
    }

    public void setSchedule(TourSchedule schedule) {
        this.schedule = schedule;
    }

    public User getGuide() {
        return guide;
    }

    public void setGuide(User guide) {
        this.guide = guide;
    }
}
