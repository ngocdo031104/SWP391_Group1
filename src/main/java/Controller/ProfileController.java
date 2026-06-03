package Controller;

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

@WebServlet({"/profile", "/profile/update"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize       = 5  * 1024 * 1024,
    maxRequestSize    = 10 * 1024 * 1024
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
        UserDAO userDAO  = new UserDAO();
        User user        = userDAO.getUserById(sessionUser.getUserId());

        if (user == null) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        session.setAttribute("sessionUser", user);
        request.setAttribute("user", user);
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
        String action    = request.getParameter("action");

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
    private void updateProfile(HttpServletRequest request, HttpServletResponse response,
                               User sessionUser)
            throws ServletException, IOException {
        try {
            UserDAO userDAO  = new UserDAO();
            User user        = userDAO.getUserById(sessionUser.getUserId());
            UserProfile profile = (user.getProfile() != null) ? user.getProfile() : new UserProfile();
            profile.setUserId(user.getUserId());

            String action = request.getParameter("action");

            if ("updateInfo".equals(action)) {

                String fullName  = trim(request.getParameter("fullName"));
                String phone     = trim(request.getParameter("phone"));
                String biography = trim(request.getParameter("biography"));
                String dob       = trim(request.getParameter("dob"));
                String gender    = request.getParameter("gender");
                String address   = trim(request.getParameter("address"));

                // ── Validate fullName ──────────────────────────────
                if (fullName == null || fullName.isEmpty()) {
                    request.setAttribute("errorMessage", "Họ và tên không được để trống");
                    doGet(request, response); return;
                }
                if (fullName.length() < 2 || fullName.length() > 100) {
                    request.setAttribute("errorMessage", "Họ và tên phải từ 2 đến 100 ký tự");
                    doGet(request, response); return;
                }
                if (!fullName.matches("^[\\p{L} .'-]+$")) {
                    request.setAttribute("errorMessage", "Họ và tên chỉ được chứa chữ cái và khoảng trắng");
                    doGet(request, response); return;
                }

                // ── Validate phone (tùy chọn) ──────────────────────
                if (phone != null && !phone.isEmpty() && !phone.matches("^0[0-9]{9}$")) {
                    request.setAttribute("errorMessage", "Số điện thoại phải gồm 10 chữ số và bắt đầu bằng 0");
                    doGet(request, response); return;
                }

                // ── Validate dob (tùy chọn) ────────────────────────
                Date parsedDob = null;
                if (dob != null && !dob.isEmpty()) {
                    try {
                        parsedDob = Date.valueOf(dob);
                        if (parsedDob.after(new Date(System.currentTimeMillis()))) {
                            request.setAttribute("errorMessage", "Ngày sinh không được ở tương lai");
                            doGet(request, response); return;
                        }
                        // Tuổi tối thiểu 13
                        java.util.Calendar cal = java.util.Calendar.getInstance();
                        cal.add(java.util.Calendar.YEAR, -13);
                        if (parsedDob.after(new Date(cal.getTimeInMillis()))) {
                            request.setAttribute("errorMessage", "Bạn phải từ 13 tuổi trở lên");
                            doGet(request, response); return;
                        }
                    } catch (IllegalArgumentException e) {
                        request.setAttribute("errorMessage", "Định dạng ngày sinh không hợp lệ");
                        doGet(request, response); return;
                    }
                }

                // ── Validate address (tùy chọn) ────────────────────
                if (address != null && address.length() > 255) {
                    request.setAttribute("errorMessage", "Địa chỉ không được vượt quá 255 ký tự");
                    doGet(request, response); return;
                }

                // ── Validate biography (tùy chọn) ──────────────────
                if (biography != null && biography.length() > 1000) {
                    request.setAttribute("errorMessage", "Tiểu sử không được vượt quá 1000 ký tự");
                    doGet(request, response); return;
                }

                user.setFullName(fullName);
                user.setPhoneNumber(phone);
                profile.setBiography(biography);
                profile.setGender(gender);
                profile.setAddress(address);
                profile.setDateOfBirth(parsedDob);

            } else if ("updatePreferences".equals(action)) {
                String interests = request.getParameter("travelInterests");
                profile.setTravelInterests(interests);
            }

            boolean success = userDAO.updateProfile(user, profile);
            request.setAttribute(success ? "successMessage" : "errorMessage",
                                  success ? "Cập nhật thông tin thành công" : "Không thể cập nhật thông tin");

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + ex.getMessage());
        }
        doGet(request, response);
    }

    // ─── updateAvatar ─────────────────────────────────────────────────────────
    private void updateAvatar(HttpServletRequest request, HttpServletResponse response,
                              User sessionUser)
            throws ServletException, IOException {
        try {
            Part part = request.getPart("avatar");

            if (part == null || part.getSize() == 0) {
                request.setAttribute("errorMessage", "Vui lòng chọn file ảnh");
                doGet(request, response); return;
            }

            // ── Validate loại file ──────────────────────────────────
            String contentType = part.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                request.setAttribute("errorMessage", "Chỉ chấp nhận file ảnh (JPG, PNG, GIF, WebP)");
                doGet(request, response); return;
            }

            // ── Validate kích thước (tối đa 2 MB) ──────────────────
            if (part.getSize() > 2 * 1024 * 1024) {
                request.setAttribute("errorMessage", "Kích thước ảnh không được vượt quá 2 MB");
                doGet(request, response); return;
            }

            String originalFileName = getFileName(part);
            String extension = "";
            int dotIndex = originalFileName.lastIndexOf('.');
            if (dotIndex > 0) extension = originalFileName.substring(dotIndex).toLowerCase();

            // ── Validate extension ──────────────────────────────────
            if (!extension.matches("\\.(jpg|jpeg|png|gif|webp)")) {
                request.setAttribute("errorMessage", "Chỉ chấp nhận định dạng JPG, PNG, GIF, WebP");
                doGet(request, response); return;
            }

            String fileName   = "avatar_" + sessionUser.getUserId() + "_" + System.currentTimeMillis() + extension;
            String uploadPath = request.getServletContext().getRealPath("/assets/images");
            java.io.File uploadDir = new java.io.File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();
            part.write(uploadPath + java.io.File.separator + fileName);

            String avatarUrl  = request.getContextPath() + "/assets/images/" + fileName;

            UserDAO userDAO   = new UserDAO();
            User user         = userDAO.getUserById(sessionUser.getUserId());
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
    private void changePassword(HttpServletRequest request, HttpServletResponse response,
                                User sessionUser)
            throws ServletException, IOException {
        try {
            String currentPassword = request.getParameter("currentPassword");
            String newPassword     = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmNewPassword");

            // ── Validate current password ───────────────────────────
            if (currentPassword == null || currentPassword.isEmpty()) {
                request.setAttribute("errorMessage", "Vui lòng nhập mật khẩu hiện tại");
                doGet(request, response); return;
            }

            // ── Validate new password ───────────────────────────────
            if (newPassword == null || newPassword.isEmpty()) {
                request.setAttribute("errorMessage", "Mật khẩu mới không được để trống");
                doGet(request, response); return;
            }
            if (newPassword.length() < 8) {
                request.setAttribute("errorMessage", "Mật khẩu mới phải có ít nhất 8 ký tự");
                doGet(request, response); return;
            }
            if (!newPassword.matches(".*[A-Za-z].*") || !newPassword.matches(".*[0-9].*")) {
                request.setAttribute("errorMessage", "Mật khẩu mới phải chứa ít nhất 1 chữ cái và 1 chữ số");
                doGet(request, response); return;
            }
            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("errorMessage", "Mật khẩu xác nhận không khớp");
                doGet(request, response); return;
            }
            if (newPassword.equals(currentPassword)) {
                request.setAttribute("errorMessage", "Mật khẩu mới không được trùng mật khẩu hiện tại");
                doGet(request, response); return;
            }

            // ── FIX: Dùng verifyPassword() thay vì hashPassword() ──
            UserDAO userDAO = new UserDAO();
            User dbUser     = userDAO.getUserById(sessionUser.getUserId());

            if (!PasswordUtil.verifyPassword(currentPassword, dbUser.getPasswordHash())) {
                request.setAttribute("errorMessage", "Mật khẩu hiện tại không đúng");
                doGet(request, response); return;
            }

            String newHash  = PasswordUtil.hashPassword(newPassword);
            boolean success = userDAO.changePassword(sessionUser.getUserId(), newHash);

            // Cập nhật lại session nếu thành công
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
    private void updateNotifications(HttpServletRequest request, HttpServletResponse response,
                                     User sessionUser)
            throws ServletException, IOException {
        // TODO: Lưu cài đặt thông báo vào DB khi có bảng NotificationSetting
        request.setAttribute("successMessage", "Cập nhật cài đặt thông báo thành công");
        doGet(request, response);
    }

    // ─── Helpers ─────────────────────────────────────────────────────────────
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null) return "avatar.jpg";
        for (String token : contentDisp.split(";")) {
            if (token.trim().startsWith("filename")) {
                String name = token.substring(token.indexOf("=") + 2, token.length() - 1).trim();
                // Chỉ lấy tên file, bỏ path (IE gửi full path)
                int slash = Math.max(name.lastIndexOf('/'), name.lastIndexOf('\\'));
                return slash >= 0 ? name.substring(slash + 1) : name;
            }
        }
        return "avatar.jpg";
    }

    private String trim(String s) { return s == null ? null : s.trim(); }
}