package Entities;

import java.sql.Timestamp;

public class Attendance {
    private int attendanceId;
    private int scheduleId;
    private int participantId;
    private boolean checkedIn;
    private Timestamp checkInTime;
    private Integer checkedBy;
    private String notes;

    public Attendance() {}

    public Attendance(int attendanceId, int scheduleId, int participantId, boolean checkedIn, Timestamp checkInTime, Integer checkedBy, String notes) {
        this.attendanceId = attendanceId;
        this.scheduleId = scheduleId;
        this.participantId = participantId;
        this.checkedIn = checkedIn;
        this.checkInTime = checkInTime;
        this.checkedBy = checkedBy;
        this.notes = notes;
    }

    public int getAttendanceId() {
        return attendanceId;
    }

    public void setAttendanceId(int attendanceId) {
        this.attendanceId = attendanceId;
    }

    public int getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(int scheduleId) {
        this.scheduleId = scheduleId;
    }

    public int getParticipantId() {
        return participantId;
    }

    public void setParticipantId(int participantId) {
        this.participantId = participantId;
    }

    public boolean isCheckedIn() {
        return checkedIn;
    }

    public void setCheckedIn(boolean checkedIn) {
        this.checkedIn = checkedIn;
    }

    public Timestamp getCheckInTime() {
        return checkInTime;
    }

    public void setCheckInTime(Timestamp checkInTime) {
        this.checkInTime = checkInTime;
    }

    public Integer getCheckedBy() {
        return checkedBy;
    }

    public void setCheckedBy(Integer checkedBy) {
        this.checkedBy = checkedBy;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}
