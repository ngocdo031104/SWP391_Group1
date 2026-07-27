/*
 * Màn hình 22: Manage Tour Media - Quản lý hình ảnh & media tour
 * Tác giả: Dương Quang Sơn
 * MSSV: HE186525
 * Ngày tạo: 2026-07-21
 */
package Controller;

import Entities.Tour;
import Entities.TourMedia;
import Entities.User;
import Model.TourDAO;
import Model.TourMediaDAO;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;

@WebServlet(name = "AdminMediaController", urlPatterns = {"/admin/media"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2 MB
    maxFileSize = 1024 * 1024 * 10,      // Giới hạn 10 MB cho mỗi file tải lên
    maxRequestSize = 1024 * 1024 * 50    // Giới hạn 50 MB cho tổng dung lượng request
)
public class AdminMediaController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminMediaController.class.getName());

    /**
     * Xử lý yêu cầu HTTP GET.
     * 1. Kiểm tra quyền của người dùng (chỉ cho phép Admin hoặc Super Admin).
     * 2. Nếu là yêu cầu AJAX lấy danh sách media của Tour (action = getMedia), trả về JSON chứa danh sách TourMedia.
     * 3. Nếu là tải trang thông thường, lấy danh sách tất cả các tour để đổ vào dropdown và chuyển hướng đến trang JSP quản lý media.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // 1. Kiểm tra quyền Admin từ session
        User sessionUser = (User) request.getSession().getAttribute("sessionUser");
        String userRole = (String) request.getSession().getAttribute("userRole");
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (sessionUser.getRoleId() != 1 && !"Admin".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/admin/analytics");
            return;
        }

        // 2. Xử lý yêu cầu AJAX lấy danh sách phương tiện (hình ảnh/video) của tour cụ thể
        String ajax = request.getParameter("ajax");
        if ("true".equalsIgnoreCase(ajax)) {
            response.setContentType("application/json;charset=UTF-8");
            String action = request.getParameter("action");

            if ("getMedia".equalsIgnoreCase(action)) {
                int tourId = parseInt(request.getParameter("tourId"), 0);
                TourMediaDAO mediaDAO = null;
                try {
                    mediaDAO = new TourMediaDAO();
                    List<TourMedia> mediaList = mediaDAO.getMediaByTourIdForAdmin(tourId);
                    
                    Gson gson = new Gson();
                    JsonArray jsonArray = new JsonArray();
                    for (TourMedia m : mediaList) {
                        JsonObject mJson = gson.toJsonTree(m).getAsJsonObject();
                        // Định dạng lại ngày đăng dạng chuỗi YYYY-MM-DD
                        mJson.addProperty("uploadedStr", m.getUploadedAt().toString().split(" ")[0]);
                        mJson.addProperty("uploaderName", m.getUploaderName() != null ? m.getUploaderName() : "Hệ thống");
                        jsonArray.add(mJson);
                    }
                    
                    try (PrintWriter out = response.getWriter()) {
                        out.print(gson.toJson(jsonArray));
                    }
                } catch (Exception e) {
                    LOGGER.log(Level.SEVERE, "getMedia AJAX error", e);
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    try (PrintWriter out = response.getWriter()) {
                        out.print("[]");
                    }
                } finally {
                    if (mediaDAO != null) mediaDAO.close();
                }
                return;
            }
        }

        // 3. Tải trang bình thường: Lấy danh sách tất cả các Tour để hiển thị trên bộ lọc trang quản trị media
        TourDAO tourDAO = null;
        try {
            tourDAO = new TourDAO();
            List<Tour> tours = tourDAO.getAllToursAdmin();
            request.setAttribute("tours", tours);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Loading tours for media admin failed", e);
        } finally {
            if (tourDAO != null) tourDAO.close();
        }

        request.getRequestDispatcher("/admin/media.jsp").forward(request, response);
    }

    /**
     * Xử lý yêu cầu HTTP POST để chỉnh sửa dữ liệu phương tiện (Thêm, Sửa, Xóa, Bật/Tắt hiển thị, Đổi thứ tự).
     * Phản hồi luôn trả về ở định dạng JSON chứa trạng thái (success/error) và thông điệp kết quả.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        // 1. Kiểm tra quyền Admin trước khi thực hiện các thay đổi
        User sessionUser = (User) request.getSession().getAttribute("sessionUser");
        String userRole = (String) request.getSession().getAttribute("userRole");
        if (sessionUser == null || (sessionUser.getRoleId() != 1 && !"Admin".equals(userRole))) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"status\":\"error\",\"message\":\"Không có quyền thực hiện hành động này.\"}");
            }
            return;
        }

        String action = request.getParameter("action");
        JsonObject result = new JsonObject();
        Gson gson = new Gson();

        // 2. Xử lý Thêm hoặc Sửa thông tin Media (Hỗ trợ cả tải ảnh từ máy tính hoặc dùng URL có sẵn)
        if ("addMedia".equalsIgnoreCase(action) || "editMedia".equalsIgnoreCase(action)) {
            TourMediaDAO mediaDAO = null;
            try {
                mediaDAO = new TourMediaDAO();
                
                int tourId = parseInt(request.getParameter("tourId"), 0);
                String mediaSource = request.getParameter("mediaSource"); // Nguồn file: "url" (đường dẫn web) hoặc "local" (tải tệp)
                String mediaUrl = request.getParameter("mediaUrl");
                String mediaType = request.getParameter("mediaType"); // Loại tệp: Image hoặc Video
                String caption = request.getParameter("caption"); // Chú thích cho ảnh
                int sortOrder = parseInt(request.getParameter("sortOrder"), 0); // Thứ tự hiển thị
                boolean isVisible = "true".equalsIgnoreCase(request.getParameter("isVisible")); // Trạng thái hiển thị công khai

                // Xử lý lưu trữ tệp tin tải lên từ máy tính (local upload)
                if ("local".equalsIgnoreCase(mediaSource)) {
                    Part filePart = request.getPart("mediaFile");
                    if (filePart != null && filePart.getSize() > 0) {
                        String submittedName = filePart.getSubmittedFileName();
                        String ext = ".jpg";
                        if (submittedName != null && submittedName.contains(".")) {
                            ext = submittedName.substring(submittedName.lastIndexOf("."));
                        }
                        // Tạo tên file độc nhất để tránh trùng lặp
                        String uniqueName = "tour_" + tourId + "_" + System.currentTimeMillis() + ext;
                        // Thư mục lưu trữ vật lý trong máy chủ: assets/images
                        String uploadDir = request.getServletContext().getRealPath("") + File.separator + "assets" + File.separator + "images";
                        File dir = new File(uploadDir);
                        if (!dir.exists()) {
                            dir.mkdirs();
                        }
                        String filePath = uploadDir + File.separator + uniqueName;
                        filePart.write(filePath);
                        mediaUrl = "assets/images/" + uniqueName; // Đường dẫn tương đối lưu vào DB
                    }
                }

                // Kiểm tra dữ liệu đầu vào bắt buộc
                if (tourId <= 0 || mediaUrl == null || mediaUrl.trim().isEmpty() || mediaType == null) {
                    result.addProperty("status", "error");
                    result.addProperty("message", "Vui lòng nhập đầy đủ thông tin hợp lệ (Đường dẫn Media URL hoặc Tệp tải lên không được để trống).");
                } else {
                    TourMedia media = new TourMedia();
                    media.setTourId(tourId);
                    media.setMediaUrl(mediaUrl.trim());
                    media.setMediaType(mediaType);
                    media.setCaption(caption != null ? caption.trim() : "");
                    media.setSortOrder(sortOrder);
                    media.setIsVisible(isVisible);
                    media.setUploadedBy(sessionUser.getUserId());

                    boolean success = false;
                    if ("addMedia".equalsIgnoreCase(action)) {
                        // Gọi DAO thêm mới một phương tiện vào tour
                        int newId = mediaDAO.insertMedia(media);
                        success = newId > 0;
                    } else {
                        // Gọi DAO cập nhật một phương tiện đã tồn tại
                        int mediaId = parseInt(request.getParameter("mediaId"), 0);
                        media.setMediaId(mediaId);
                        success = mediaDAO.updateMedia(media);
                    }

                    if (success) {
                        result.addProperty("status", "success");
                        result.addProperty("message", "Lưu thông tin phương tiện thành công!");
                    } else {
                        result.addProperty("status", "error");
                        result.addProperty("message", "Không thể lưu thông tin phương tiện.");
                    }
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Save media error", e);
                result.addProperty("status", "error");
                result.addProperty("message", "Lỗi xử lý dữ liệu: " + e.getMessage());
            } finally {
                if (mediaDAO != null) mediaDAO.close();
            }
        } 
        // 3. Xử lý yêu cầu Xóa phương tiện
        else if ("deleteMedia".equalsIgnoreCase(action)) {
            TourMediaDAO mediaDAO = null;
            try {
                mediaDAO = new TourMediaDAO();
                int mediaId = parseInt(request.getParameter("mediaId"), 0);
                boolean success = mediaDAO.deleteMedia(mediaId);
                if (success) {
                    result.addProperty("status", "success");
                    result.addProperty("message", "Xóa phương tiện thành công!");
                } else {
                    result.addProperty("status", "error");
                    result.addProperty("message", "Không thể xóa phương tiện.");
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Delete media error", e);
                result.addProperty("status", "error");
                result.addProperty("message", "Lỗi khi xóa: " + e.getMessage());
            } finally {
                if (mediaDAO != null) mediaDAO.close();
            }
        } 
        // 4. Xử lý yêu cầu bật/tắt hiển thị ẩn danh của hình ảnh/video đối với khách hàng
        else if ("toggleVisibility".equalsIgnoreCase(action)) {
            TourMediaDAO mediaDAO = null;
            try {
                mediaDAO = new TourMediaDAO();
                int mediaId = parseInt(request.getParameter("mediaId"), 0);
                boolean isVisible = "true".equalsIgnoreCase(request.getParameter("isVisible"));
                boolean success = mediaDAO.toggleVisibility(mediaId, isVisible);
                if (success) {
                    result.addProperty("status", "success");
                    result.addProperty("message", "Cập nhật hiển thị thành công!");
                } else {
                    result.addProperty("status", "error");
                    result.addProperty("message", "Không thể cập nhật hiển thị.");
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Toggle visibility error", e);
                result.addProperty("status", "error");
                result.addProperty("message", "Lỗi hệ thống: " + e.getMessage());
            } finally {
                if (mediaDAO != null) mediaDAO.close();
            }
        } 
        // 5. Cập nhật thứ tự sắp xếp của phương tiện để hiển thị đẹp hơn trên slide ảnh ở trang chi tiết tour
        else if ("updateSortOrder".equalsIgnoreCase(action)) {
            TourMediaDAO mediaDAO = null;
            try {
                mediaDAO = new TourMediaDAO();
                int mediaId = parseInt(request.getParameter("mediaId"), 0);
                int sortOrder = parseInt(request.getParameter("sortOrder"), 0);
                boolean success = mediaDAO.updateSortOrder(mediaId, sortOrder);
                if (success) {
                    result.addProperty("status", "success");
                    result.addProperty("message", "Cập nhật vị trí thành công!");
                } else {
                    result.addProperty("status", "error");
                    result.addProperty("message", "Không thể cập nhật vị trí.");
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Update sort order error", e);
                result.addProperty("status", "error");
                result.addProperty("message", "Lỗi hệ thống: " + e.getMessage());
            } finally {
                if (mediaDAO != null) mediaDAO.close();
            }
        } else {
            result.addProperty("status", "error");
            result.addProperty("message", "Hành động không hợp lệ.");
        }

        try (PrintWriter out = response.getWriter()) {
            out.print(gson.toJson(result));
        }
    }

    /**
     * Phương thức bổ trợ (Helper method) chuyển chuỗi dạng String thành số nguyên int một cách an toàn.
     */
    private int parseInt(String value, int defaultVal) {
        try {
            if (value != null && !value.trim().isEmpty()) {
                return Integer.parseInt(value.trim());
            }
        } catch (NumberFormatException e) {}
        return defaultVal;
    }
}
