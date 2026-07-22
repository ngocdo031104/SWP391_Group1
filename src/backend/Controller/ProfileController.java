/*
 * Liên quan đến UCs: Manage User Profile
 * Tác giả: Đỗ Vũ Minh Ngọc
 * MSSV: HE182479
 */
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
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

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
        
        // Náº¿u khĂ´ng cĂ³ dá»¯ liá»‡u nháº­p lá»—i Ä‘Æ°á»£c giá»¯ láº¡i, láº¥y dá»¯ liá»‡u gá»‘c tá»« DB
        if (request.getAttribute("user") == null) {
            request.setAttribute("user", user);
        }
        
        List<ActivityLog> activityLogs = userDAO.getActivityLogs(user.getUserId());
        request.setAttribute("activityLogs", activityLogs);
        
        // Lấy thông tin sở thích du lịch từ CSDL
        Model.MatchingDAO matchingDAO = new Model.MatchingDAO();
        Entities.TravelPreference myPref = matchingDAO.getPreference(user.getUserId());
        if (myPref == null) {
            myPref = new Entities.TravelPreference();
        }
        request.setAttribute("myPref", myPref);
        
        // Lấy số lượng tour trong danh sách yêu thích
        Model.WishlistDAO wishlistDAO = new Model.WishlistDAO();
        int totalFavorites = wishlistDAO.countWishlistTours(user.getUserId());
        request.setAttribute("totalFavorites", totalFavorites);
        wishlistDAO.close();
        
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

    // â”€â”€â”€ updateProfile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

                // Táº¡o má»™t báº£n sao táº¡m Ä‘á»ƒ lÆ°u trá»¯ dá»¯ liá»‡u lá»—i gá»­i ngÆ°á»£c vá» JSP náº¿u validate tháº¥t báº¡i
                User invalidUser = new User();
                invalidUser.setUserId(user.getUserId());
                invalidUser.setFullName(fullName);
                invalidUser.setPhoneNumber(phone);
                UserProfile invalidProfile = new UserProfile();
                invalidProfile.setBiography(biography);
                invalidProfile.setGender(gender);
                invalidProfile.setAddress(address);

                // â”€â”€ Validate fullName â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                if (fullName.isEmpty()) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "Há» vĂ  tĂªn khĂ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng");
                    return;
                }
                if (fullName.length() < 2 || fullName.length() > 100) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "Há» vĂ  tĂªn pháº£i tá»« 2 Ä‘áº¿n 100 kĂ½ tá»±");
                    return;
                }
                if (!fullName.matches("^[\\p{L} ]+$")) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "Há» vĂ  tĂªn chá»‰ Ä‘Æ°á»£c chá»©a chá»¯ cĂ¡i vĂ  khoáº£ng tráº¯ng");
                    return;
                }

                // â”€â”€ Validate phone (tĂ¹y chá»n) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                if (!phone.isEmpty() && !phone.matches("^(03|05|07|08|09)[0-9]{8}$")) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "Sá»‘ Ä‘iá»‡n thoáº¡i khĂ´ng há»£p lá»‡");
                    return;
                }

                // â”€â”€ Validate gender â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                List<String> validGenders = Arrays.asList("Male", "Female", "Other");
                if (!gender.isEmpty() && !validGenders.contains(gender)) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "Giá»›i tĂ­nh khĂ´ng há»£p lá»‡");
                    return;
                }

                // â”€â”€ Validate dob (tĂ¹y chá»n) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Date parsedDob = null;
                if (!dob.isEmpty()) {
                    try {
                        parsedDob = Date.valueOf(dob);
                        if (parsedDob.after(new Date(System.currentTimeMillis()))) {
                            sendErrorBack(request, response, invalidUser, invalidProfile, "NgĂ y sinh khĂ´ng Ä‘Æ°á»£c á»Ÿ tÆ°Æ¡ng lai");
                            return;
                        }
                        java.util.Calendar cal = java.util.Calendar.getInstance();
                        cal.add(java.util.Calendar.YEAR, -13);
                        if (parsedDob.after(new Date(cal.getTimeInMillis()))) {
                            sendErrorBack(request, response, invalidUser, invalidProfile, "Báº¡n pháº£i tá»« 13 tuá»•i trá»Ÿ lĂªn");
                            return;
                        }
                    } catch (IllegalArgumentException e) {
                        sendErrorBack(request, response, invalidUser, invalidProfile, "Äá»‹nh dáº¡ng ngĂ y sinh khĂ´ng há»£p lá»‡");
                        return;
                    }
                }
                invalidProfile.setDateOfBirth(parsedDob);

                // â”€â”€ Validate chiá»u dĂ i & phĂ²ng chá»‘ng XSS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                if (address.length() > 255 || biography.length() > 1000) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "Äá»™ dĂ i Ä‘á»‹a chá»‰ hoáº·c tiá»ƒu sá»­ vÆ°á»£t quĂ¡ giá»›i háº¡n");
                    return;
                }
                if (containsXss(address) || containsXss(biography)) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "Ná»™i dung chá»©a kĂ½ tá»± khĂ´ng há»£p lá»‡ (XSS)");
                    return;
                }

                // Cáº­p nháº­t dá»¯ liá»‡u tháº­t náº¿u pass táº¥t cáº£ táº§ng kiá»ƒm tra
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
                     sendErrorBack(request, response, user, profile, "KhĂ´ng thá»ƒ lÆ°u sá»Ÿ thĂ­ch du lá»‹ch");
                     return;
                }
                request.setAttribute("successMessage", "Cáº­p nháº­t sá»Ÿ thĂ­ch du lá»‹ch thĂ nh cĂ´ng");
                request.setAttribute("activeTab", "preferences");
                doGet(request, response);
                return;
            }

            // Tiáº¿n hĂ nh cáº­p nháº­t Database
            boolean success = userDAO.updateProfile(user, profile);
            request.setAttribute(success ? "successMessage" : "errorMessage",
                    success ? "Cáº­p nháº­t thĂ´ng tin thĂ nh cĂ´ng" : "KhĂ´ng thá»ƒ cáº­p nháº­t thĂ´ng tin");
            request.setAttribute("activeTab", "info");

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("errorMessage", "CĂ³ lá»—i xáº£y ra: " + ex.getMessage());
        }
        doGet(request, response);
    }

    // Helper Ä‘Ă³ng gĂ³i viá»‡c gá»­i tráº£ data lá»—i vá» Form
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

    // â”€â”€â”€ updateAvatar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    private void updateAvatar(HttpServletRequest request, HttpServletResponse response, User sessionUser)
            throws ServletException, IOException {
        try {
            Part part = request.getPart("avatar");

            if (part == null || part.getSize() == 0) {
                request.setAttribute("errorMessage", "Vui lĂ²ng chá»n file áº£nh");
                doGet(request, response);
                return;
            }

            String contentType = part.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                request.setAttribute("errorMessage", "Chá»‰ cháº¥p nháº­n file áº£nh (JPG, PNG, GIF, WebP)");
                doGet(request, response);
                return;
            }

            if (part.getSize() > 2 * 1024 * 1024) {
                request.setAttribute("errorMessage", "KĂ­ch thÆ°á»›c áº£nh khĂ´ng Ä‘Æ°á»£c vÆ°á»£t quĂ¡ 2 MB");
                doGet(request, response);
                return;
            }

            String originalFileName = getFileName(part);
            if (originalFileName == null || originalFileName.trim().isEmpty() || !originalFileName.contains(".")) {
                request.setAttribute("errorMessage", "TĂªn file khĂ´ng há»£p lá»‡");
                doGet(request, response);
                return;
            }
            
            String extension = originalFileName.substring(originalFileName.lastIndexOf('.')).toLowerCase();
            List<String> validExtensions = Arrays.asList(".jpg", ".jpeg", ".png", ".gif", ".webp");

            if (!validExtensions.contains(extension)) {
                request.setAttribute("errorMessage", "Chá»‰ cháº¥p nháº­n JPG, PNG, GIF hoáº·c WebP");
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
                    success ? "Cáº­p nháº­t áº£nh Ä‘áº¡i diá»‡n thĂ nh cĂ´ng" : "KhĂ´ng thá»ƒ lÆ°u áº£nh");

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("errorMessage", "Lá»—i táº£i áº£nh: " + ex.getMessage());
        }
        doGet(request, response);
    }

    // â”€â”€â”€ changePassword â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    private void changePassword(HttpServletRequest request, HttpServletResponse response, User sessionUser)
            throws ServletException, IOException {
        try {
            String currentPassword = trim(request.getParameter("currentPassword"));
            String newPassword = trim(request.getParameter("newPassword"));
            String confirmPassword = trim(request.getParameter("confirmNewPassword"));

            if (currentPassword.isEmpty() || newPassword.isEmpty() || confirmPassword.isEmpty()) {
                request.setAttribute("errorMessage", "Vui lĂ²ng nháº­p Ä‘áº§y Ä‘á»§ cĂ¡c trÆ°á»ng máº­t kháº©u");
                doGet(request, response);
                return;
            }

            if (newPassword.length() < 8) {
                request.setAttribute("errorMessage", "Máº­t kháº©u má»›i pháº£i cĂ³ Ă­t nháº¥t 8 kĂ½ tá»±");
                doGet(request, response);
                return;
            }
            if (!newPassword.matches(".*[A-Za-z].*") || !newPassword.matches(".*[0-9].*")) {
                request.setAttribute("errorMessage", "Máº­t kháº©u má»›i pháº£i chá»©a Ă­t nháº¥t 1 chá»¯ cĂ¡i vĂ  1 chá»¯ sá»‘");
                doGet(request, response);
                return;
            }
            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("errorMessage", "Máº­t kháº©u xĂ¡c nháº­n khĂ´ng khá»›p");
                doGet(request, response);
                return;
            }
            if (newPassword.equals(currentPassword)) {
                request.setAttribute("errorMessage", "Máº­t kháº©u má»›i khĂ´ng Ä‘Æ°á»£c trĂ¹ng máº­t kháº©u hiá»‡n táº¡i");
                doGet(request, response);
                return;
            }

            UserDAO userDAO = new UserDAO();
            User dbUser = userDAO.getUserById(sessionUser.getUserId());

            if (!PasswordUtil.verifyPassword(currentPassword, dbUser.getPasswordHash())) {
                request.setAttribute("errorMessage", "Máº­t kháº©u hiá»‡n táº¡i khĂ´ng Ä‘Ăºng");
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
                    success ? "Äá»•i máº­t kháº©u thĂ nh cĂ´ng" : "KhĂ´ng thá»ƒ Ä‘á»•i máº­t kháº©u");
            request.setAttribute("activeTab", "security");

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("errorMessage", "CĂ³ lá»—i xáº£y ra: " + ex.getMessage());
        }
        doGet(request, response);
    }

    // â”€â”€â”€ updateNotifications â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    private void updateNotifications(HttpServletRequest request, HttpServletResponse response, User sessionUser)
            throws ServletException, IOException {
        request.setAttribute("successMessage", "Cáº­p nháº­t cĂ i Ä‘áº·t thĂ´ng bĂ¡o thĂ nh cĂ´ng");
        request.setAttribute("activeTab", "notifications");
        doGet(request, response);
    }

    // â”€â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
        return s == null ? "" : s.trim(); // TRáº¢ Vá»€ Rá»–NG Äá»‚ TRĂNH NULL POINTER EXCEPTION
    }
}
