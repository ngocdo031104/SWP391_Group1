/*
 * Li\u00ean quan \u0111\u1ebfn UCs: Manage User Profile
 * T\u00e1c gi\u1ea3: \u0110\u1ed7 V\u0169 Minh Ng\u1ecdc
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
        
        // N\u1ebfu kh\u00f4ng c\u00f3 d\u1eef li\u1ec7u nh\u1eadp l\u1ed7i \u0111\u01b0\u1ee3c gi\u1eef l\u1ea1i, l\u1ea5y d\u1eef li\u1ec7u g\u1ed1c t\u1eeb DB
        if (request.getAttribute("user") == null) {
            request.setAttribute("user", user);
        }
        
        List<ActivityLog> activityLogs = userDAO.getActivityLogs(user.getUserId());
        request.setAttribute("activityLogs", activityLogs);
        
        // L\u1ea5y th\u00f4ng tin s\u1edf th\u00edch du l\u1ecbch t\u1eeb CSDL
        Model.MatchingDAO matchingDAO = new Model.MatchingDAO();
        Entities.TravelPreference myPref = matchingDAO.getPreference(user.getUserId());
        if (myPref == null) {
            myPref = new Entities.TravelPreference();
        }
        request.setAttribute("myPref", myPref);
        
        // L\u1ea5y s\u1ed1 l\u01b0\u1ee3ng tour trong danh s\u00e1ch y\u00eau th\u00edch
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

    // \u2500\u2500\u2500 updateProfile \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
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

                // T\u1ea1o m\u1ed9t b\u1ea3n sao t\u1ea1m \u0111\u1ec3 l\u01b0u tr\u1eef d\u1eef li\u1ec7u l\u1ed7i g\u1eedi ng\u01b0\u1ee3c v\u1ec1 JSP n\u1ebfu validate th\u1ea5t b\u1ea1i
                User invalidUser = new User();
                invalidUser.setUserId(user.getUserId());
                invalidUser.setFullName(fullName);
                invalidUser.setPhoneNumber(phone);
                UserProfile invalidProfile = new UserProfile();
                invalidProfile.setBiography(biography);
                invalidProfile.setGender(gender);
                invalidProfile.setAddress(address);

                // --- Validate fullName ------------------------------
                if (fullName.isEmpty()) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "H\u1ecd v\u00e0 t\u00ean kh\u00f4ng \u0111\u01b0\u1ee3c \u0111\u1ec3 tr\u1ed1ng");
                    return;
                }
                if (fullName.length() < 2 || fullName.length() > 100) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "H\u1ecd v\u00e0 t\u00ean ph\u1ea3i t\u1eeb 2 \u0111\u1ebfn 100 k\u00fd t\u1ef1");
                    return;
                }
                if (!fullName.matches("^[\\p{L} ]+$")) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "H\u1ecd v\u00e0 t\u00ean ch\u1ec9 \u0111\u01b0\u1ee3c ch\u1ee9a ch\u1eef c\u00e1i v\u00e0 kho\u1ea3ng tr\u1eafng");
                    return;
                }

                // --- Validate phone (t\u00f9y ch\u1ecdn) ----------------------
                if (!phone.isEmpty() && !phone.matches("^(03|05|07|08|09)[0-9]{8}$")) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "S\u1ed1 \u0111i\u1ec7n tho\u1ea1i kh\u00f4ng h\u1ee3p l\u1ec7");
                    return;
                }

                // --- Validate gender --------------------------------
                List<String> validGenders = Arrays.asList("Male", "Female", "Other");
                if (!gender.isEmpty() && !validGenders.contains(gender)) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "Gi\u1edbi t\u00ednh kh\u00f4ng h\u1ee3p l\u1ec7");
                    return;
                }

                // --- Validate dob (t\u00f9y ch\u1ecdn) ------------------------
                Date parsedDob = null;
                if (!dob.isEmpty()) {
                    try {
                        parsedDob = Date.valueOf(dob);
                        if (parsedDob.after(new Date(System.currentTimeMillis()))) {
                            sendErrorBack(request, response, invalidUser, invalidProfile, "Ng\u00e0y sinh kh\u00f4ng \u0111\u01b0\u1ee3c \u1edf t\u01b0\u01a1ng lai");
                            return;
                        }
                        java.util.Calendar cal = java.util.Calendar.getInstance();
                        cal.add(java.util.Calendar.YEAR, -13);
                        if (parsedDob.after(new Date(cal.getTimeInMillis()))) {
                            sendErrorBack(request, response, invalidUser, invalidProfile, "B\u1ea1n ph\u1ea3i t\u1eeb 13 tu\u1ed5i tr\u1edf l\u00ean");
                            return;
                        }
                    } catch (IllegalArgumentException e) {
                        sendErrorBack(request, response, invalidUser, invalidProfile, "\u0110\u1ecbnh d\u1ea1ng ng\u00e0y sinh kh\u00f4ng h\u1ee3p l\u1ec7");
                        return;
                    }
                }
                invalidProfile.setDateOfBirth(parsedDob);

                // --- Validate chi\u1ec1u d\u00e0i & ph\u00f2ng ch\u1ed1ng XSS -----------
                if (address.length() > 255 || biography.length() > 1000) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "\u0110\u1ed9 d\u00e0i \u0111\u1ecba ch\u1ec9 ho\u1eb7c ti\u1ec3u s\u1eed v\u01b0\u1ee3t qu\u00e1 gi\u1edbi h\u1ea1n");
                    return;
                }
                if (containsXss(address) || containsXss(biography)) {
                    sendErrorBack(request, response, invalidUser, invalidProfile, "N\u1ed9i dung ch\u1ee9a k\u00fd t\u1ef1 kh\u00f4ng h\u1ee3p l\u1ec7 (XSS)");
                    return;
                }

                // C\u1eadp nh\u1eadt d\u1eef li\u1ec7u th\u1eadt n\u1ebfu pass t\u1ea5t c\u1ea3 t\u1ea7ng ki\u1ec3m tra
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
                     sendErrorBack(request, response, user, profile, "Kh\u00f4ng th\u1ec3 l\u01b0u s\u1edf th\u00edch du l\u1ecbch");
                     return;
                }
                request.setAttribute("successMessage", "C\u1eadp nh\u1eadt s\u1edf th\u00edch du l\u1ecbch th\u00e0nh c\u00f4ng");
                request.setAttribute("activeTab", "preferences");
                doGet(request, response);
                return;
            }

            // Ti\u1ebfn h\u00e0nh c\u1eadp nh\u1eadt Database
            boolean success = userDAO.updateProfile(user, profile);
            request.setAttribute(success ? "successMessage" : "errorMessage",
                    success ? "C\u1eadp nh\u1eadt th\u00f4ng tin th\u00e0nh c\u00f4ng" : "Kh\u00f4ng th\u1ec3 c\u1eadp nh\u1eadt th\u00f4ng tin");
            request.setAttribute("activeTab", "info");

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("errorMessage", "C\u00f3 l\u1ed7i x\u1ea3y ra: " + ex.getMessage());
        }
        doGet(request, response);
    }

    // Helper \u0111\u00f3ng g\u00f3i vi\u1ec7c g\u1eedi tr\u1ea3 data l\u1ed7i v\u1ec1 Form
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

    private void updateAvatar(HttpServletRequest request, HttpServletResponse response, User sessionUser)
            throws ServletException, IOException {
        try {
            Part part = request.getPart("avatar");

            if (part == null || part.getSize() == 0) {
                request.setAttribute("errorMessage", "Vui l\u00f2ng ch\u1ecdn file \u1ea3nh");
                doGet(request, response);
                return;
            }

            String contentType = part.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                request.setAttribute("errorMessage", "Ch\u1ec9 ch\u1ea5p nh\u1eadn file \u1ea3nh (JPG, PNG, GIF, WebP)");
                doGet(request, response);
                return;
            }

            if (part.getSize() > 2 * 1024 * 1024) {
                request.setAttribute("errorMessage", "K\u00edch th\u01b0\u1edbc \u1ea3nh kh\u00f4ng \u0111\u01b0\u1ee3c v\u01b0\u1ee3t qu\u00e1 2 MB");
                doGet(request, response);
                return;
            }

            String originalFileName = getFileName(part);
            if (originalFileName == null || originalFileName.trim().isEmpty() || !originalFileName.contains(".")) {
                request.setAttribute("errorMessage", "T\u00ean file kh\u00f4ng h\u1ee3p l\u1ec7");
                doGet(request, response);
                return;
            }
            
            String extension = originalFileName.substring(originalFileName.lastIndexOf('.')).toLowerCase();
            List<String> validExtensions = Arrays.asList(".jpg", ".jpeg", ".png", ".gif", ".webp");

            if (!validExtensions.contains(extension)) {
                request.setAttribute("errorMessage", "Ch\u1ec9 ch\u1ea5p nh\u1eadn JPG, PNG, GIF ho\u1eb7c WebP");
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
                    success ? "C\u1eadp nh\u1eadt \u1ea3nh \u0111\u1ea1i di\u1ec7n th\u00e0nh c\u00f4ng" : "Kh\u00f4ng th\u1ec3 l\u01b0u \u1ea3nh");

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("errorMessage", "L\u1ed7i t\u1ea3i \u1ea3nh: " + ex.getMessage());
        }
        doGet(request, response);
    }

    private void changePassword(HttpServletRequest request, HttpServletResponse response, User sessionUser)
            throws ServletException, IOException {
        try {
            String currentPassword = trim(request.getParameter("currentPassword"));
            String newPassword = trim(request.getParameter("newPassword"));
            String confirmPassword = trim(request.getParameter("confirmNewPassword"));

            if (currentPassword.isEmpty() || newPassword.isEmpty() || confirmPassword.isEmpty()) {
                request.setAttribute("errorMessage", "Vui l\u00f2ng nh\u1eadp \u0111\u1ea7y \u0111\u1ee7 c\u00e1c tr\u01b0\u1eddng m\u1eadt kh\u1ea9u");
                doGet(request, response);
                return;
            }

            if (newPassword.length() < 8) {
                request.setAttribute("errorMessage", "M\u1eadt kh\u1ea9u m\u1edbi ph\u1ea3i c\u00f3 \u00edt nh\u1ea5t 8 k\u00fd t\u1ef1");
                doGet(request, response);
                return;
            }
            if (!newPassword.matches(".*[A-Za-z].*") || !newPassword.matches(".*[0-9].*")) {
                request.setAttribute("errorMessage", "M\u1eadt kh\u1ea9u m\u1edbi ph\u1ea3i ch\u1ee9a \u00edt nh\u1ea5t 1 ch\u1eef c\u00e1i v\u00e0 1 ch\u1eef s\u1ed1");
                doGet(request, response);
                return;
            }
            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("errorMessage", "M\u1eadt kh\u1ea9u x\u00e1c nh\u1eadn kh\u00f4ng kh\u1edbp");
                doGet(request, response);
                return;
            }
            if (newPassword.equals(currentPassword)) {
                request.setAttribute("errorMessage", "M\u1eadt kh\u1ea9u m\u1edbi kh\u00f4ng \u0111\u01b0\u1ee3c tr\u00f9ng m\u1eadt kh\u1ea9u hi\u1ec7n t\u1ea1i");
                doGet(request, response);
                return;
            }

            UserDAO userDAO = new UserDAO();
            User dbUser = userDAO.getUserById(sessionUser.getUserId());

            if (!PasswordUtil.verifyPassword(currentPassword, dbUser.getPasswordHash())) {
                request.setAttribute("errorMessage", "M\u1eadt kh\u1ea9u hi\u1ec7n t\u1ea1i kh\u00f4ng \u0111\u00fang");
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
                    success ? "\u0110\u1ed5i m\u1eadt kh\u1ea9u th\u00e0nh c\u00f4ng" : "Kh\u00f4ng th\u1ec3 \u0111\u1ed5i m\u1eadt kh\u1ea9u");
            request.setAttribute("activeTab", "security");

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("errorMessage", "C\u00f3 l\u1ed7i x\u1ea3y ra: " + ex.getMessage());
        }
        doGet(request, response);
    }

    private void updateNotifications(HttpServletRequest request, HttpServletResponse response, User sessionUser)
            throws ServletException, IOException {
        request.setAttribute("successMessage", "C\u1eadp nh\u1eadt c\u00e0i \u0111\u1eb7t th\u00f4ng b\u00e1o th\u00e0nh c\u00f4ng");
        request.setAttribute("activeTab", "notifications");
        doGet(request, response);
    }

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
        return s == null ? "" : s.trim(); // TR\u1ea2 V\u1ec0 R\u1ed6NG \u0110\u1ec2 TR\u00c1NH NULL POINTER EXCEPTION
    }
}
