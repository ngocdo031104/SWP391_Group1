package Controller;

import Entities.GuideProfile;
import Entities.TourAssignment;
import Entities.User;
import Entities.UserProfile;
import Model.GuideDAO;
import Model.UserDAO;
import Utils.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.sql.Date;
import java.util.Arrays;
import java.util.List;

@WebServlet({"/guide/profile", "/guide/profile/update"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 10 * 1024 * 1024
)
public class GuideProfileController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User sessionUser = (User) session.getAttribute("sessionUser");
        if (!"Guide".equals(sessionUser.getRole().getRoleName())) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        UserDAO userDAO = new UserDAO();
        GuideDAO guideDAO = new GuideDAO();

        User user = userDAO.getUserById(sessionUser.getUserId());
        GuideProfile guideProfile = guideDAO.getGuideProfileByUserId(user.getUserId());

        if (guideProfile == null) {
            // If GuideProfile doesn't exist, initialize an empty one to avoid null pointers
            guideProfile = new GuideProfile();
            guideProfile.setUserId(user.getUserId());
        }

        // Calculate Performance Summary
        List<TourAssignment> assignments = guideDAO.getAssignmentsByGuideId(user.getUserId());
        int totalAssigned = assignments.size();
        int totalCompleted = 0;
        int totalUpcoming = 0;

        for (TourAssignment assignment : assignments) {
            if ("Completed".equalsIgnoreCase(assignment.getSchedule().getTourStatus())) {
                totalCompleted++;
            } else if ("Scheduled".equalsIgnoreCase(assignment.getSchedule().getTourStatus())) {
                totalUpcoming++;
            }
        }

        // Set attributes
        request.setAttribute("user", user);
        request.setAttribute("guideProfile", guideProfile);
        request.setAttribute("totalAssigned", totalAssigned);
        request.setAttribute("totalCompleted", totalCompleted);
        request.setAttribute("totalUpcoming", totalUpcoming);
        
        // Employee Code formatting
        String employeeCode = String.format("GUIDE-%04d", user.getUserId());
        request.setAttribute("employeeCode", employeeCode);

        request.getRequestDispatcher("/views/guide/profile.jsp").forward(request, response);
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
        if (!"Guide".equals(sessionUser.getRole().getRoleName())) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String action = request.getParameter("action");

        switch (action == null ? "" : action) {
            case "updatePersonalInfo":
                updatePersonalInfo(request, response, sessionUser);
                break;
            case "updateProfessionalInfo":
                updateProfessionalInfo(request, response, sessionUser);
                break;
            case "updateAvatar":
                updateAvatar(request, response, sessionUser);
                break;
            case "changePassword":
                changePassword(request, response, sessionUser);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/guide/profile");
        }
    }

    private void updatePersonalInfo(HttpServletRequest request, HttpServletResponse response, User sessionUser)
            throws ServletException, IOException {
        try {
            UserDAO userDAO = new UserDAO();
            User user = userDAO.getUserById(sessionUser.getUserId());
            UserProfile profile = (user.getProfile() != null) ? user.getProfile() : new UserProfile();
            profile.setUserId(user.getUserId());

            String fullName = trim(request.getParameter("fullName"));
            String phone = trim(request.getParameter("phone"));
            String dobStr = trim(request.getParameter("dob"));
            String gender = trim(request.getParameter("gender"));
            String address = trim(request.getParameter("address"));

            // Validations
            if (fullName.isEmpty() || fullName.length() < 2 || fullName.length() > 100 || !fullName.matches("^[\\p{L} ]+$")) {
                request.setAttribute("errorMessage", "Họ và tên không hợp lệ (từ 2-100 ký tự, chỉ chứa chữ cái).");
                doGet(request, response);
                return;
            }

            if (!phone.isEmpty() && !phone.matches("^(03|05|07|08|09)[0-9]{8}$")) {
                request.setAttribute("errorMessage", "Số điện thoại không hợp lệ.");
                doGet(request, response);
                return;
            }

            Date parsedDob = null;
            if (!dobStr.isEmpty()) {
                try {
                    parsedDob = Date.valueOf(dobStr);
                } catch (IllegalArgumentException e) {
                    request.setAttribute("errorMessage", "Định dạng ngày sinh không hợp lệ.");
                    doGet(request, response);
                    return;
                }
            }

            // Update objects
            user.setFullName(fullName);
            user.setPhoneNumber(phone);
            profile.setDateOfBirth(parsedDob);
            profile.setGender(gender);
            profile.setAddress(address);

            boolean success = userDAO.updateProfile(user, profile);
            if (success) {
                // Update session user name
                sessionUser.setFullName(fullName);
            }
            request.setAttribute(success ? "successMessage" : "errorMessage",
                    success ? "Cập nhật thông tin cá nhân thành công." : "Không thể cập nhật thông tin.");

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + ex.getMessage());
        }
        doGet(request, response);
    }

    private void updateProfessionalInfo(HttpServletRequest request, HttpServletResponse response, User sessionUser)
            throws ServletException, IOException {
        try {
            GuideDAO guideDAO = new GuideDAO();
            GuideProfile guideProfile = guideDAO.getGuideProfileByUserId(sessionUser.getUserId());

            if (guideProfile == null) {
                // Create a new guide profile if they didn't have one
                guideProfile = new GuideProfile();
                guideProfile.setUserId(sessionUser.getUserId());
                guideProfile.setRating(5.0); // Default rating
                guideProfile.setIsActive(true);
                guideDAO.insertGuideProfile(guideProfile);
                // Fetch the newly inserted one to get the ID
                guideProfile = guideDAO.getGuideProfileByUserId(sessionUser.getUserId());
            }

            String expStr = trim(request.getParameter("yearsOfExperience"));
            String languages = trim(request.getParameter("languages"));
            String certifications = trim(request.getParameter("certifications"));
            String biography = trim(request.getParameter("biography"));

            if (biography.length() > 1000) {
                request.setAttribute("errorMessage", "Tiểu sử không được vượt quá 1000 ký tự.");
                doGet(request, response);
                return;
            }

            int expYears = 0;
            if (!expStr.isEmpty()) {
                try {
                    expYears = Integer.parseInt(expStr);
                    if (expYears < 0) expYears = 0;
                } catch (NumberFormatException e) {
                    expYears = 0;
                }
            }

            guideProfile.setYearsOfExperience(expYears);
            guideProfile.setLanguages(languages);
            guideProfile.setCertifications(certifications);
            guideProfile.setBio(biography);

            boolean success = guideDAO.updateGuideProfile(guideProfile);
            request.setAttribute(success ? "successMessage" : "errorMessage",
                    success ? "Cập nhật thông tin nghề nghiệp thành công." : "Không thể cập nhật thông tin nghề nghiệp.");

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + ex.getMessage());
        }
        doGet(request, response);
    }

    private void updateAvatar(HttpServletRequest request, HttpServletResponse response, User sessionUser)
            throws ServletException, IOException {
        try {
            Part part = request.getPart("avatar");

            if (part == null || part.getSize() == 0) {
                request.setAttribute("errorMessage", "Vui lòng chọn file ảnh.");
                doGet(request, response);
                return;
            }

            String contentType = part.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                request.setAttribute("errorMessage", "Chỉ chấp nhận file ảnh (JPG, PNG, GIF, WebP).");
                doGet(request, response);
                return;
            }

            String originalFileName = getFileName(part);
            String extension = originalFileName.substring(originalFileName.lastIndexOf('.')).toLowerCase();
            String fileName = "avatar_" + sessionUser.getUserId() + "_" + System.currentTimeMillis() + extension;
            
            String uploadPath = request.getServletContext().getRealPath("/assets/images");
            java.io.File uploadDir = new java.io.File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();
            
            part.write(uploadPath + java.io.File.separator + fileName);

            String avatarUrl = request.getContextPath() + "/assets/images/" + fileName;

            UserDAO userDAO = new UserDAO();
            User user = userDAO.getUserById(sessionUser.getUserId());
            UserProfile profile = (user.getProfile() != null) ? user.getProfile() : new UserProfile();
            profile.setUserId(user.getUserId());
            profile.setAvatarUrl(avatarUrl);

            boolean success = userDAO.updateProfile(user, profile);
            if (success) {
                sessionUser.getProfile().setAvatarUrl(avatarUrl);
            }
            request.setAttribute(success ? "successMessage" : "errorMessage",
                    success ? "Cập nhật ảnh đại diện thành công." : "Không thể lưu ảnh.");

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi tải ảnh: " + ex.getMessage());
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
                request.setAttribute("errorMessage", "Vui lòng nhập đầy đủ các trường mật khẩu.");
                doGet(request, response);
                return;
            }

            if (newPassword.length() < 8 || !newPassword.matches(".*[A-Za-z].*") || !newPassword.matches(".*[0-9].*")) {
                request.setAttribute("errorMessage", "Mật khẩu mới phải có ít nhất 8 ký tự, chứa cả chữ cái và chữ số.");
                doGet(request, response);
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("errorMessage", "Mật khẩu xác nhận không khớp.");
                doGet(request, response);
                return;
            }

            UserDAO userDAO = new UserDAO();
            User dbUser = userDAO.getUserById(sessionUser.getUserId());

            if (!PasswordUtil.verifyPassword(currentPassword, dbUser.getPasswordHash())) {
                request.setAttribute("errorMessage", "Mật khẩu hiện tại không đúng.");
                doGet(request, response);
                return;
            }

            String newHash = PasswordUtil.hashPassword(newPassword);
            boolean success = userDAO.changePassword(sessionUser.getUserId(), newHash);

            request.setAttribute(success ? "successMessage" : "errorMessage",
                    success ? "Đổi mật khẩu thành công." : "Không thể đổi mật khẩu.");

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + ex.getMessage());
        }
        doGet(request, response);
    }

    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null) return "avatar.jpg";
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
        return s == null ? "" : s.trim();
    }
}
