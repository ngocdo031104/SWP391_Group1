/*
 * Liên quan đến UCs: Register Account
 * Tác giả: Đỗ Vũ Minh Ngọc
 * MSSV: HE182479
 */
package Controller;

/**
 * Controller class for handling user registration.
 * Processes user input, validates data (email format, password strength, etc.),
 * and interacts with the DAO to create new user accounts and profiles.
 */

import Entities.User;
import Entities.UserProfile;
import Model.UserDAO;
import Utils.EmailUtil;
import Utils.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Date;
import java.util.Calendar;
import java.util.Random;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "RegisterController", urlPatterns = {"/register"})
public class RegisterController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        request.getRequestDispatcher("/views/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        UserDAO userDAO = new UserDAO();

        String email = trim(request.getParameter("email"));
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String fullName = trim(request.getParameter("fullName"));
        String phone = trim(request.getParameter("phone"));
        String dob = trim(request.getParameter("dob"));
        String gender = trim(request.getParameter("gender"));
        String role = trim(request.getParameter("role"));

        boolean hasError = false;

        // ==========================
        // Xác thực định dạng Email
        // ==========================
        if (email == null || email.isEmpty()) {
            request.setAttribute("emailError", "Email không được để trống");
            hasError = true;
        } else if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            request.setAttribute("emailError", "Äá»‹nh dạng email không hợp lệ");
            hasError = true;
        } else if (userDAO.checkEmailExists(email)) {
            request.setAttribute("emailError", "Email đã được đăng ký");
            hasError = true;
        }

        // ==========================
        // Xác thực Mật khẩu (độ dài, ký tự)
        // ==========================
        if (password == null || password.isEmpty()) {
            request.setAttribute("passwordError", "Mật khẩu không được để trống");
            hasError = true;
        } else if (password.length() < 8) {
            request.setAttribute("passwordError", "Mật khẩu phải có ít nhất 8 ký tự");
            hasError = true;
        } else if (!password.matches(".*[A-Za-z].*")
                || !password.matches(".*[0-9].*")) {
            request.setAttribute("passwordError",
                    "Mật khẩu phải chứa ít nhất 1 chữ cái và 1 chữ số");
            hasError = true;
        }

        // ==========================
        // Xác nhận lại mật khẩu
        // ==========================
        if (confirmPassword == null || confirmPassword.isEmpty()) {
            request.setAttribute("confirmError",
                    "Vui lòng nhập lại mật khẩu");
            hasError = true;
        } else if (password != null && !password.equals(confirmPassword)) {
            request.setAttribute("confirmError",
                    "Mật khẩu xác nhận không khớp");
            hasError = true;
        }

        // ==========================
        // Kiểm tra độ dài và định dạng Họ tên
        // ==========================
        if (fullName == null || fullName.isEmpty()) {
            request.setAttribute("nameError",
                    "Há» và tên không được để trống");
            hasError = true;
        } else if (fullName.length() < 2 || fullName.length() > 100) {
            request.setAttribute("nameError",
                    "Há» và tên phải từ 2 đến 100 ký tự");
            hasError = true;
        } else if (!fullName.matches("^[\\p{L} .'-]+$")) {
            request.setAttribute("nameError",
                    "Há» và tên chỉ được chứa chữ cái và khoảng trắng");
            hasError = true;
        }

        // ==========================
        // Kiểm tra định dạng số điện thoại
        // ==========================
        if (phone == null || phone.isEmpty()) {
            request.setAttribute("phoneError",
                    "Số điện thoại không được để trống");
            hasError = true;
        } else if (!phone.matches("^0[0-9]{9}$")) {
            request.setAttribute("phoneError",
                    "Số điện thoại phải gồm 10 chữ số và bắt đầu bằng 0");
            hasError = true;
        }

        // ==========================
        // Kiểm tra ngày sinh (trên 13 tuổi)
        // ==========================
        if (dob == null || dob.isEmpty()) {
            request.setAttribute("dobError",
                    "Ngày sinh không được để trống");
            hasError = true;
        } else {
            try {
                Date parsedDob = Date.valueOf(dob);
                Date today = new Date(System.currentTimeMillis());

                if (parsedDob.after(today)) {
                    request.setAttribute("dobError",
                            "Ngày sinh không được ở tương lai");
                    hasError = true;
                } else {
                    Calendar cal = Calendar.getInstance();
                    cal.add(Calendar.YEAR, -13);

                    if (parsedDob.after(new Date(cal.getTimeInMillis()))) {
                        request.setAttribute("dobError",
                                "Bạn phải từ 13 tuổi trở lên để đăng ký");
                        hasError = true;
                    }
                }

            } catch (IllegalArgumentException e) {
                request.setAttribute("dobError",
                        "Äá»‹nh dạng ngày sinh không hợp lệ");
                hasError = true;
            }
        }

        // ==========================
        // Xác thực giới tính
        // ==========================
        if (gender == null || gender.isEmpty()) {
            request.setAttribute("genderError",
                    "Vui lòng chá»n giới tính");
            hasError = true;
        } else if (!gender.equals("Male")
                && !gender.equals("Female")
                && !gender.equals("Other")) {

            request.setAttribute("genderError",
                    "Giới tính không hợp lệ");
            hasError = true;
        }

        // ==========================
        // Xác thực quyền (Customer / Guide)
        // ==========================
        if (role == null || role.isEmpty()) {
            request.setAttribute("roleError",
                    "Vui lòng chá»n vai trò");
            hasError = true;
        } else if (!role.equals("Customer")
                && !role.equals("Guide")) {

            request.setAttribute("roleError",
                    "Vai trò không hợp lệ");
            hasError = true;
        }

        // ==========================
        // Nếu có lỗi
        // ==========================
        if (hasError) {

            request.setAttribute("paramEmail", email);
            request.setAttribute("paramFullName", fullName);
            request.setAttribute("paramPhone", phone);
            request.setAttribute("paramDob", dob);
            request.setAttribute("paramGender", gender);
            request.setAttribute("paramRole", role);

            request.getRequestDispatcher("/views/register.jsp")
                    .forward(request, response);
            return;
        }

        try {

            String passwordHash = PasswordUtil.hashPassword(password);

            User user = new User();
            user.setEmail(email);
            user.setPasswordHash(passwordHash);
            user.setFullName(fullName);
            user.setPhoneNumber(phone);

            int roleId = userDAO.getRoleIdByName(role);
            user.setRoleId(roleId);

            UserProfile profile = new UserProfile();
            profile.setGender(gender);
            profile.setDateOfBirth(Date.valueOf(dob));

            profile.setAvatarUrl(
                    "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80"
            );

            boolean success = userDAO.register(user, profile);

            if (success) {
                // Khởi tạo mã OTP xác thực 6 số
                String otp = String.format("%06d", new Random().nextInt(999999));
                
                // Lưu tạm email và OTP vào session
                request.getSession().setAttribute("verify_email", email);
                request.getSession().setAttribute("verify_otp", otp);
                
                // Gửi mã OTP xác thực qua Email
                try {
                    EmailUtil.sendOTP(email, otp);
                } catch (Exception e) {
                    e.printStackTrace();
                    Logger.getLogger(RegisterController.class.getName()).log(Level.SEVERE, "Failed to send email", e);
                    request.getSession().setAttribute("emailError", "Lỗi gửi mail: " + e.getMessage() + " - " + e.getClass().getName());
                }
                
                response.sendRedirect(request.getContextPath() + "/verify");
            } else {

                request.setAttribute(
                        "errorMessage",
                        "ÄÄƒng ký không thành công. Vui lòng thử lại."
                );

                request.getRequestDispatcher("/views/register.jsp")
                        .forward(request, response);
            }

        } catch (Exception ex) {

            Logger.getLogger(RegisterController.class.getName())
                    .log(Level.SEVERE, null, ex);

            request.setAttribute(
                    "errorMessage",
                    "Lỗi hệ thống khi đăng ký. Vui lòng thử lại sau."
            );

            request.getRequestDispatcher("/views/register.jsp")
                    .forward(request, response);
        }
    }

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }
}
