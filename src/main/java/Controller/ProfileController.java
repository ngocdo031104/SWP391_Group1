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
@MultipartConfig
public class ProfileController extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("sessionUser") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        User sessionUser = (User) session.getAttribute("sessionUser");

        User user = userDAO.getUserById(sessionUser.getUserId());

        if (user == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        // Sync session user with database
        session.setAttribute("sessionUser", user);
        request.setAttribute("user", user);

        request.getRequestDispatcher("/views/profile.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                           HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("sessionUser") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        User sessionUser = (User) session.getAttribute("sessionUser");
        String action = request.getParameter("action");

        if ("updateInfo".equals(action) || "updatePreferences".equals(action)) {
            updateProfile(request, response, sessionUser);
        } else if ("updateAvatar".equals(action)) {
            updateAvatar(request, response, sessionUser);
        } else if ("changePassword".equals(action)) {
            changePassword(request, response, sessionUser);
        } else if ("updateNotifications".equals(action)) {
            updateNotifications(request, response, sessionUser);
        } else {
            response.sendRedirect(request.getContextPath() + "/profile");
        }
    }

    private void updateProfile(HttpServletRequest request,
                               HttpServletResponse response,
                               User sessionUser)
            throws ServletException, IOException {

        try {
            User user = userDAO.getUserById(sessionUser.getUserId());
            UserProfile profile = user.getProfile();

            if (profile == null) {
                profile = new UserProfile();
                profile.setUserId(user.getUserId());
            }

            String action = request.getParameter("action");
            if ("updateInfo".equals(action)) {
                String fullName = request.getParameter("fullName");
                String phone = request.getParameter("phone");
                String biography = request.getParameter("biography");
                String dob = request.getParameter("dob");
                String gender = request.getParameter("gender");
                String address = request.getParameter("address");

                user.setFullName(fullName);
                user.setPhoneNumber(phone);
                profile.setBiography(biography);
                profile.setGender(gender);
                profile.setAddress(address);

                if (dob != null && !dob.trim().isEmpty()) {
                    try {
                        profile.setDateOfBirth(Date.valueOf(dob));
                    } catch (Exception ignored) {
                    }
                } else {
                    profile.setDateOfBirth(null);
                }
            } else if ("updatePreferences".equals(action)) {
                String interests = request.getParameter("travelInterests");
                profile.setTravelInterests(interests);
            }

            boolean success = userDAO.updateProfile(user, profile);

            if (success) {
                request.setAttribute("successMessage", "Cập nhật thông tin thành công");
            } else {
                request.setAttribute("errorMessage", "Không thể cập nhật thông tin");
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + ex.getMessage());
        }

        doGet(request, response);
    }

    private void updateAvatar(HttpServletRequest request,
                              HttpServletResponse response,
                              User sessionUser)
            throws ServletException, IOException {
        try {
            Part part = request.getPart("avatar");
            if (part != null && part.getSize() > 0) {
                String originalFileName = getFileName(part);
                String extension = "";
                int dotIndex = originalFileName.lastIndexOf('.');
                if (dotIndex > 0) {
                    extension = originalFileName.substring(dotIndex);
                }
                String fileName = "avatar_" + sessionUser.getUserId() + "_" + System.currentTimeMillis() + extension;
                String uploadPath = request.getServletContext().getRealPath("/assets/images");
                java.io.File uploadDir = new java.io.File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }
                part.write(uploadPath + java.io.File.separator + fileName);
                
                String avatarUrl = request.getContextPath() + "/assets/images/" + fileName;
                
                User user = userDAO.getUserById(sessionUser.getUserId());
                UserProfile profile = user.getProfile();
                if (profile == null) {
                    profile = new UserProfile();
                    profile.setUserId(user.getUserId());
                }
                profile.setAvatarUrl(avatarUrl);
                
                boolean success = userDAO.updateProfile(user, profile);
                if (success) {
                    request.setAttribute("successMessage", "Cập nhật ảnh đại diện thành công");
                } else {
                    request.setAttribute("errorMessage", "Không thể lưu ảnh đại diện vào cơ sở dữ liệu");
                }
            } else {
                request.setAttribute("errorMessage", "Tải lên ảnh thất bại: File trống");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi tải ảnh đại diện: " + ex.getMessage());
        }
        doGet(request, response);
    }

    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "avatar.png";
    }

    private void updateNotifications(HttpServletRequest request,
                                     HttpServletResponse response,
                                     User sessionUser)
            throws ServletException, IOException {
        request.setAttribute("successMessage", "Cập nhật cài đặt thông báo thành công");
        doGet(request, response);
    }

    private void changePassword(HttpServletRequest request,
                                 HttpServletResponse response,
                                 User sessionUser)
            throws ServletException, IOException {

        try {
            String currentPassword = request.getParameter("currentPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmNewPassword"); // Adjusted to match JSP name

            if (newPassword == null || newPassword.length() < 6) {
                request.setAttribute("errorMessage", "Mật khẩu mới phải từ 6 ký tự");
                doGet(request, response);
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("errorMessage", "Mật khẩu xác nhận không khớp");
                doGet(request, response);
                return;
            }

            User dbUser = userDAO.getUserById(sessionUser.getUserId());
            String currentHash = PasswordUtil.hashPassword(currentPassword);
            User loginCheck = userDAO.login(dbUser.getEmail(), currentHash);

            if (loginCheck == null) {
                request.setAttribute("errorMessage", "Mật khẩu hiện tại không đúng");
                doGet(request, response);
                return;
            }

            String newHash = PasswordUtil.hashPassword(newPassword);
            boolean success = userDAO.changePassword(sessionUser.getUserId(), newHash);

            if (success) {
                request.setAttribute("successMessage", "Đổi mật khẩu thành công");
            } else {
                request.setAttribute("errorMessage", "Không thể đổi mật khẩu");
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + ex.getMessage());
        }

        doGet(request, response);
    }
}
