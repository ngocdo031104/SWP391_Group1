package Controller;

/**
 * Controller class for managing user profiles.
 * Allows users to view and update their personal information,
 * change their avatar, modify travel preferences, and update passwords.
 */

import Entities.ActivityLog;
import Entities.User;
import Entities.UserProfile;
import Model.UserDAO;
import Utils.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Date;
import java.util.Arrays;
import java.util.List;

@WebServlet({"/profile", "/profile/update"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 10 * 1024 * 1024
)
public class ProfileController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User sessionUser = (User) session.getAttribute("sessionUser");
        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserById(sessionUser.getUserId());

        if (user == null) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        session.setAttribute("sessionUser", user);
        
        // Nếu không có dữ liệu nhập lỗi được giữ lại, lấy dữ liệu gốc từ DB
        if (request.getAttribute("user") == null) {
            request.setAttribute("user", user);
        }
        
        List<ActivityLog> activityLogs = userDAO.getActivityLogs(user.getUserId());
        request.setAttribute("activityLogs", activityLogs);
        
        // Fetch travel preferences
        Model.MatchingDAO matchingDAO = new Model.MatchingDAO();
        Entities.TravelPreference myPref = matchingDAO.getPreference(user.getUserId());
        if (myPref == null) {
            myPref = new Entities.TravelPreference();
        }
        request.setAttribute("myPref", myPref);
        
        request.getRequestDispatcher("/views/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User sessionUser = (User) session.getAttribute("sessionUser");
        String action = request.getParameter("action");

        switch (action == null ? "" : action) {
            case "updateInfo":
            case "updatePreferences":
                updateProfile(request, response, sessionUser);
                break;
            case "updateAvatar":
                updateAvatar(request, response, sessionUser);
                break;
            case "changePassword":
                changePassword(request, response, sessionUser);
                break;
            case "updateNotifications":
                updateNotifications(request, response, sessionUser);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/profile");
        }
    }

    // ─── updateProfile ────────────────────────────────────────────────────────
    private void updateProfile(HttpServletRequest request, HttpServletResponse response, User sessionUser)
            throws ServletException, IOException {
        try {
            UserDAO userDAO = new UserDAO();
            User user = userDAO.getUserById(sessionUser.getUserId());
            UserProfile profile = (user.getProfile() != null) ? user.getProfile() : new UserProfile();
            profile.setUserId(user.getUserId());

            String action = request.getParameter("action");

            if ("updateInfo".equals(action)) {
                String fullName = trim(request.getParameter("fullName"));
                String phone = trim(request.getParameter("phone"));
                String biography = trim(request.getParameter("biography"));
                String dob = trim(request.getParameter("dob"));
                String gender = trim(request.getParameter("gender"));
                String address = trim(request.getParameter("address"));

                // Tạo một bản sao tạm để lưu trữ dữ liệu lỗi gửi ngược về JSP nếu validate thất bại
                User invalidUser = new User();
                invalidUser.setUserId(user.getUserId());
                invalidUser.setFullName(fullName);
                invalidUser.setPhoneNumber(phone);
                UserProfile invalidProfile = new UserProfile();
                invalidProfile.setBiography(biography);
                invalidProfile.setGender(gender);
                invalidProfile.setAddress(address);

                // ── Validate fullName ──────────────────────────────
                if (fullName.isEmpty()) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "Họ và tên không được để trống");
                    return;
                }
                if (fullName.length() < 2 || fullName.length() > 100) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "Họ và tên phải từ 2 đến 100 ký tự");
                    return;
                }
                if (!fullName.matches("^[\\p{L} ]+$")) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "Họ và tên chỉ được chứa chữ cái và khoảng trắng");
                    return;
                }

                // ── Validate phone (tùy chọn) ──────────────────────
                if (!phone.isEmpty() && !phone.matches("^(03|05|07|08|09)[0-9]{8}$")) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "Số điện thoại không hợp lệ");
                    return;
                }

                // ── Validate gender ────────────────────────────────
                List<String> validGenders = Arrays.asList("Male", "Female", "Other");
                if (!gender.isEmpty() && !validGenders.contains(gender)) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "Giới tính không hợp lệ");
                    return;
                }

                // ── Validate dob (tùy chọn) ────────────────────────
                Date parsedDob = null;
                if (!dob.isEmpty()) {
                    try {
                        parsedDob = Date.valueOf(dob);
                        if (parsedDob.after(new Date(System.currentTimeMillis()))) {
                            sendErrorBack(request, response, invalidUser, invalidProfile, "Ngày sinh không được ở tương lai");
                            return;
                        }
                        java.util.Calendar cal = java.util.Calendar.getInstance();
                        cal.add(java.util.Calendar.YEAR, -13);
                        if (parsedDob.after(new Date(cal.getTimeInMillis()))) {
                            sendErrorBack(request, response, invalidUser, invalidProfile, "Bạn phải từ 13 tuổi trở lên");
                            return;
                        }
                    } catch (IllegalArgumentException e) {
                        sendErrorBack(request, response, invalidUser, invalidProfile, "Định dạng ngày sinh không hợp lệ");
                        return;
                    }
                }
                invalidProfile.setDateOfBirth(parsedDob);

                // ── Validate chiều dài & phòng chống XSS ────────────
                if (address.length() > 255 || biography.length() > 1000) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "Độ dài địa chỉ hoặc tiểu sử vượt quá giới hạn");
                    return;
                }
                if (containsXss(address) || containsXss(biography)) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "Nội dung chứa ký tự không hợp lệ (XSS)");
                    return;
                }

                // Cập nhật dữ liệu thật nếu pass tất cả tầng kiểm tra
                user.setFullName(fullName);
                user.setPhoneNumber(phone);
                profile.setBiography(biography);
                profile.setGender(gender);
                profile.setAddress(address);
                profile.setDateOfBirth(parsedDob);

            } else if ("updatePreferences".equals(action)) {
                Model.MatchingDAO matchingDAO = new Model.MatchingDAO();
                Entities.TravelPreference pref = new Entities.TravelPreference();
                pref.setUserId(user.getUserId());
                pref.setDestination(trim(request.getParameter("destination")));
                pref.setTravelStyle(trim(request.getParameter("travelStyle")));
                
                String startDateStr = trim(request.getParameter("startDate"));
                String endDateStr = trim(request.getParameter("endDate"));
                if (!startDateStr.isEmpty()) {
                    pref.setStartDate(java.sql.Date.valueOf(startDateStr));
                }
                if (!endDateStr.isEmpty()) {
                    pref.setEndDate(java.sql.Date.valueOf(endDateStr));
                }
                
                String minB = trim(request.getParameter("minBudget"));
                String maxB = trim(request.getParameter("maxBudget"));
                pref.setMinBudget(!minB.isEmpty() ? Double.parseDouble(minB) : 0);
                pref.setMaxBudget(!maxB.isEmpty() ? Double.parseDouble(maxB) : 0);
                
                String ageMaxStr = trim(request.getParameter("targetAgeMax"));
                pref.setTargetAgeMax(!ageMaxStr.isEmpty() ? Integer.parseInt(ageMaxStr) : 0);
                
                pref.setTargetGender(trim(request.getParameter("gender")));
                pref.setLanguages(trim(request.getParameter("languages")));
                
                String[] tagsArr = request.getParameterValues("tags");
                pref.setTags(tagsArr != null ? String.join(", ", tagsArr) : trim(request.getParameter("tags")));
                
                String[] activityArr = request.getParameterValues("activityPreferences");
                pref.setActivityPreferences(activityArr != null ? String.join(", ", activityArr) : trim(request.getParameter("activityPreferences")));
                
                pref.setTripDuration(trim(request.getParameter("tripDuration")));
                pref.setTravelFrequency(trim(request.getParameter("travelFrequency")));
                pref.setSmokingPreference(trim(request.getParameter("smokingPreference")));
                pref.setDrinkingPreference(trim(request.getParameter("drinkingPreference")));
                
                boolean savedPref = matchingDAO.savePreference(pref);
                if (!savedPref) {
                     sendErrorBack(request, response, user, profile, "Không thể lưu sở thích du lịch");
                     return;
                }
                request.setAttribute("successMessage", "Cập nhật sở thích du lịch thành công");
                doGet(request, response);
                return;
            }

            // Tiến hành cập nhật Database
            boolean success = userDAO.updateProfile(user, profile);
            request.setAttribute(success ? "successMessage" : "errorMessage",
                    success ? "Cập nhật thông tin thành công" : "Không thể cập nhật thông tin");

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + ex.getMessage());
        }
        doGet(request, response);
    }

    // Helper đóng gói việc gửi trả data lỗi về Form
    private void sendErrorBack(HttpServletRequest req, HttpServletResponse res, User invUser, UserProfile invProfile, String errMsg) 
            throws ServletException, IOException {
        invUser.setProfile(invProfile);
        req.setAttribute("user", invUser);
        req.setAttribute("errorMessage", errMsg);
        doGet(req, res);
    }

    private boolean containsXss(String value) {
        if (value == null) return false;
        String lower = value.toLowerCase();
        return lower.contains("<script") || lower.contains("javascript:") || lower.contains("onerror=");
    }

    // ─── updateAvatar ─────────────────────────────────────────────────────────
    private void updateAvatar(HttpServletRequest request, HttpServletResponse response, User sessionUser)
            throws ServletException, IOException {
        try {
            Part part = request.getPart("avatar");

            if (part == null || part.getSize() == 0) {
                request.setAttribute("errorMessage", "Vui lòng chọn file ảnh");
                doGet(request, response);
                return;
            }

            String contentType = part.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                request.setAttribute("errorMessage", "Chỉ chấp nhận file ảnh (JPG, PNG, GIF, WebP)");
                doGet(request, response);
                return;
            }

            if (part.getSize() > 2 * 1024 * 1024) {
                request.setAttribute("errorMessage", "Kích thước ảnh không được vượt quá 2 MB");
                doGet(request, response);
                return;
            }

            String originalFileName = getFileName(part);
            if (originalFileName == null || originalFileName.trim().isEmpty() || !originalFileName.contains(".")) {
                request.setAttribute("errorMessage", "Tên file không hợp lệ");
                doGet(request, response);
                return;
            }
            
            String extension = originalFileName.substring(originalFileName.lastIndexOf('.')).toLowerCase();
            List<String> validExtensions = Arrays.asList(".jpg", ".jpeg", ".png", ".gif", ".webp");

            if (!validExtensions.contains(extension)) {
                request.setAttribute("errorMessage", "Chỉ chấp nhận JPG, PNG, GIF hoặc WebP");
                doGet(request, response);
                return;
            }

            String fileName = "avatar_" + sessionUser.getUserId() + "_" + System.currentTimeMillis() + extension;
            String uploadPath = request.getServletContext().getRealPath("/assets/images");
            java.io.File uploadDir = new java.io.File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            part.write(uploadPath + java.io.File.separator + fileName);

            String avatarUrl = request.getContextPath() + "/assets/images/" + fileName;

            UserDAO userDAO = new UserDAO();
            User user = userDAO.getUserById(sessionUser.getUserId());
            UserProfile profile = (user.getProfile() != null) ? user.getProfile() : new UserProfile();
            profile.setUserId(user.getUserId());
            profile.setAvatarUrl(avatarUrl);

            boolean success = userDAO.updateProfile(user, profile);
            request.setAttribute(success ? "successMessage" : "errorMessage",
                    success ? "Cập nhật ảnh đại diện thành công" : "Không thể lưu ảnh");

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi tải ảnh: " + ex.getMessage());
        }
        doGet(request, response);
    }

    // ─── changePassword ───────────────────────────────────────────────────────
    private void changePassword(HttpServletRequest request, HttpServletResponse response, User sessionUser)
            throws ServletException, IOException {
        try {
            String currentPassword = trim(request.getParameter("currentPassword"));
            String newPassword = trim(request.getParameter("newPassword"));
            String confirmPassword = trim(request.getParameter("confirmNewPassword"));

            if (currentPassword.isEmpty() || newPassword.isEmpty() || confirmPassword.isEmpty()) {
                request.setAttribute("errorMessage", "Vui lòng nhập đầy đủ các trường mật khẩu");
                doGet(request, response);
                return;
            }

            if (newPassword.length() < 8) {
                request.setAttribute("errorMessage", "Mật khẩu mới phải có ít nhất 8 ký tự");
                doGet(request, response);
                return;
            }
            if (!newPassword.matches(".*[A-Za-z].*") || !newPassword.matches(".*[0-9].*")) {
                request.setAttribute("errorMessage", "Mật khẩu mới phải chứa ít nhất 1 chữ cái và 1 chữ số");
                doGet(request, response);
                return;
            }
            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("errorMessage", "Mật khẩu xác nhận không khớp");
                doGet(request, response);
                return;
            }
            if (newPassword.equals(currentPassword)) {
                request.setAttribute("errorMessage", "Mật khẩu mới không được trùng mật khẩu hiện tại");
                doGet(request, response);
                return;
            }

            UserDAO userDAO = new UserDAO();
            User dbUser = userDAO.getUserById(sessionUser.getUserId());

            if (!PasswordUtil.verifyPassword(currentPassword, dbUser.getPasswordHash())) {
                request.setAttribute("errorMessage", "Mật khẩu hiện tại không đúng");
                doGet(request, response);
                return;
            }

            String newHash = PasswordUtil.hashPassword(newPassword);
            boolean success = userDAO.changePassword(sessionUser.getUserId(), newHash);

            if (success) {
                dbUser.setPasswordHash(newHash);
                request.getSession().setAttribute("sessionUser", dbUser);
            }

            request.setAttribute(success ? "successMessage" : "errorMessage",
                    success ? "Đổi mật khẩu thành công" : "Không thể đổi mật khẩu");

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + ex.getMessage());
        }
        doGet(request, response);
    }

    // ─── updateNotifications ──────────────────────────────────────────────────
    private void updateNotifications(HttpServletRequest request, HttpServletResponse response, User sessionUser)
            throws ServletException, IOException {
        request.setAttribute("successMessage", "Cập nhật cài đặt thông báo thành công");
        doGet(request, response);
    }

    // ─── Helpers ─────────────────────────────────────────────────────────────
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null) {
            return "avatar.jpg";
        }
        for (String token : contentDisp.split(";")) {
            if (token.trim().startsWith("filename")) {
                String name = token.substring(token.indexOf("=") + 2, token.length() - 1).trim();
                int slash = Math.max(name.lastIndexOf('/'), name.lastIndexOf('\\'));
                return slash >= 0 ? name.substring(slash + 1) : name;
            }
        }
        return "avatar.jpg";
    }

    private String trim(String s) {
        return s == null ? "" : s.trim(); // TRẢ VỀ RỖNG ĐỂ TRÁNH NULL POINTER EXCEPTION
    }
}