package Model;

import Entities.TourMedia;
import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class TourMediaDAO extends DBContext {

    /**
     * Lấy toàn bộ danh sách hình ảnh/video của 1 tour dành cho Admin quản lý.
     * Có liên kết JOIN để hiển thị tên của người đã đăng tải (Uploader).
     */
    public List<TourMedia> getMediaByTourIdForAdmin(int tourId) {
        List<TourMedia> list = new ArrayList<>();
        String sql = "SELECT tm.MediaID, tm.TourID, tm.MediaURL, tm.MediaType, tm.Caption, tm.SortOrder, tm.IsVisible, tm.UploadedBy, tm.UploadedAt, "
                   + "u.FullName AS UploaderName "
                   + "FROM TourMedia tm "
                   + "LEFT JOIN [User] u ON tm.UploadedBy = u.UserID "
                   + "WHERE tm.TourID = ? "
                   + "ORDER BY tm.SortOrder ASC, tm.UploadedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, tourId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TourMedia media = new TourMedia(
                        rs.getInt("MediaID"),
                        rs.getInt("TourID"),
                        rs.getString("MediaURL"),
                        rs.getString("MediaType"),
                        rs.getString("Caption"),
                        rs.getInt("SortOrder"),
                        rs.getBoolean("IsVisible"),
                        rs.getObject("UploadedBy") != null ? rs.getInt("UploadedBy") : null,
                        rs.getTimestamp("UploadedAt"),
                        rs.getString("UploaderName")
                    );
                    list.add(media);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourMediaDAO.class.getName()).log(Level.SEVERE, "getMediaByTourIdForAdmin failed", ex);
        }
        return list;
    }

    /**
     * Thêm phương tiện truyền thông mới.
     */
    public int insertMedia(TourMedia media) {
        String sql = "INSERT INTO TourMedia (TourID, MediaURL, MediaType, Caption, SortOrder, IsVisible, UploadedBy, UploadedAt) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, SYSDATETIME())";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, media.getTourId());
            ps.setString(2, media.getMediaUrl().trim());
            ps.setString(3, media.getMediaType());
            ps.setString(4, media.getCaption());
            ps.setInt(5, media.getSortOrder());
            ps.setBoolean(6, media.isIsVisible());
            if (media.getUploadedBy() != null && media.getUploadedBy() > 0) {
                ps.setInt(7, media.getUploadedBy());
            } else {
                ps.setNull(7, java.sql.Types.INTEGER);
            }
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        return keys.getInt(1);
                    }
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TourMediaDAO.class.getName()).log(Level.SEVERE, "insertMedia failed", ex);
        }
        return -1;
    }

    /**
     * Cập nhật thông tin phương tiện.
     */
    public boolean updateMedia(TourMedia media) {
        String sql = "UPDATE TourMedia SET MediaURL = ?, MediaType = ?, Caption = ?, SortOrder = ?, IsVisible = ? WHERE MediaID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, media.getMediaUrl().trim());
            ps.setString(2, media.getMediaType());
            ps.setString(3, media.getCaption());
            ps.setInt(4, media.getSortOrder());
            ps.setBoolean(5, media.isIsVisible());
            ps.setInt(6, media.getMediaId());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(TourMediaDAO.class.getName()).log(Level.SEVERE, "updateMedia failed", ex);
        }
        return false;
    }

    /**
     * Xóa phương tiện.
     */
    public boolean deleteMedia(int mediaId) {
        String sql = "DELETE FROM TourMedia WHERE MediaID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, mediaId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(TourMediaDAO.class.getName()).log(Level.SEVERE, "deleteMedia failed", ex);
        }
        return false;
    }

    /**
     * Bật/Tắt chế độ hiển thị của hình ảnh/video.
     */
    public boolean toggleVisibility(int mediaId, boolean isVisible) {
        String sql = "UPDATE TourMedia SET IsVisible = ? WHERE MediaID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setBoolean(1, isVisible);
            ps.setInt(2, mediaId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(TourMediaDAO.class.getName()).log(Level.SEVERE, "toggleVisibility failed", ex);
        }
        return false;
    }

    /**
     * Cập nhật thứ tự sắp xếp của hình ảnh/video.
     */
    public boolean updateSortOrder(int mediaId, int sortOrder) {
        String sql = "UPDATE TourMedia SET SortOrder = ? WHERE MediaID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, sortOrder);
            ps.setInt(2, mediaId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(TourMediaDAO.class.getName()).log(Level.SEVERE, "updateSortOrder failed", ex);
        }
        return false;
    }
}
