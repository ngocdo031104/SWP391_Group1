package Controller;

import Entities.User;
import Entities.UserProfile;
import Model.UserDAO;
import Utils.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Date;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "RegisterController", urlPatterns = {"/register"})
public class RegisterController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        UserDAO userDAO = new UserDAO();

        String email           = trim(request.getParameter("email"));
        String password        = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String fullName        = trim(request.getParameter("fullName"));
        String phone           = trim(request.getParameter("phone"));
        String dob             = trim(request.getParameter("dob"));
        String gender          = request.getParameter("gender");
        String role            = trim(request.getParameter("role"));

        boolean hasError = false;

        // ── Validate Email ──────────────────────────────────────────
        if (email == null || email.isEmpty()) {
            request.setAttribute("emailError", "Email không được để trống");
            hasError = true;
        } else if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            request.setAttribute("emailError", "Định dạng email không hợp lệ (vd: abc@email.com)");
            hasError = true;
        } else if (userDAO.checkEmailExists(email)) {
            request.setAttribute("emailError", "Email này đã được đăng ký, vui lòng dùng email khác");
            hasError = true;
        }

        // ── Validate Password ───────────────────────────────────────
        if (password == null || password.isEmpty()) {
            request.setAttribute("passwordError", "Mật khẩu không được để trống");
            hasError = true;
        } else if (password.length() < 8) {
            request.setAttribute("passwordError", "Mật khẩu phải có ít nhất 8 ký tự");
            hasError = true;
        } else if (!password.matches(".*[A-Za-z].*") || !password.matches(".*[0-9].*")) {
            request.setAttribute("passwordError", "Mật khẩu phải chứa ít nhất 1 chữ cái và 1 chữ số");
            hasError = true;
        } else if (!password.equals(confirmPassword)) {
            request.setAttribute("confirmError", "Mật khẩu xác nhận không khớp");
            hasError = true;
        }

        // ── Validate Họ và tên ──────────────────────────────────────
        if (fullName == null || fullName.isEmpty()) {
            request.setAttribute("nameError", "Họ và tên không được để trống");
            hasError = true;
        } else if (fullName.length() < 2 || fullName.length() > 100) {
            request.setAttribute("nameError", "Họ và tên phải từ 2 đến 100 ký tự");
            hasError = true;
        } else if (!fullName.matches("^[\\p{L} .'-]+$")) {
            request.setAttribute("nameError", "Họ và tên chỉ được chứa chữ cái và khoảng trắng");
            hasError = true;
        }

        // ── Validate Số điện thoại (tùy chọn) ─────────────────────
        if (phone != null && !phone.isEmpty()) {
            if (!phone.matches("^0[0-9]{9}$")) {
                request.setAttribute("phoneError", "Số điện thoại phải gồm 10 chữ số và bắt đầu bằng 0 (vd: 0912345678)");
                hasError = true;
            }
        }

        // ── Validate Ngày sinh (tùy chọn) ──────────────────────────
        if (dob != null && !dob.isEmpty()) {
            try {
                Date parsedDob = Date.valueOf(dob);
                Date today     = new Date(System.currentTimeMillis());
                if (parsedDob.after(today)) {
                    request.setAttribute("dobError", "Ngày sinh không được ở tương lai");
                    hasError = true;
                } else {
                    // Kiểm tra tuổi tối thiểu 13
                    java.util.Calendar cal = java.util.Calendar.getInstance();
                    cal.add(java.util.Calendar.YEAR, -13);
                    if (parsedDob.after(new Date(cal.getTimeInMillis()))) {
                        request.setAttribute("dobError", "Bạn phải từ 13 tuổi trở lên để đăng ký");
                        hasError = true;
                    }
                }
            } catch (IllegalArgumentException e) {
                request.setAttribute("dobError", "Định dạng ngày sinh không hợp lệ");
                hasError = true;
            }
        }

        // ── Validate Role ───────────────────────────────────────────
        if (role == null || role.isEmpty()) {
            role = "Customer";
        } else if (!role.equals("Customer") && !role.equals("Guide")) {
            role = "Customer"; // Fallback an toàn
        }

        if (hasError) {
            // Giữ lại dữ liệu người dùng đã nhập để không mất khi reload
            request.setAttribute("paramEmail",    email);
            request.setAttribute("paramFullName", fullName);
            request.setAttribute("paramPhone",    phone);
            request.setAttribute("paramDob",      dob);
            request.setAttribute("paramGender",   gender);
            request.setAttribute("paramRole",     role);
            request.getRequestDispatcher("/views/register.jsp").forward(request, response);
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
            if (dob != null && !dob.isEmpty()) {
                try { profile.setDateOfBirth(Date.valueOf(dob)); } catch (Exception ignored) {}
            }
            profile.setAvatarUrl("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80");

            boolean success = userDAO.register(user, profile);
            if (success) {
                request.setAttribute("successMessage", "Đăng ký tài khoản thành công! Vui lòng đăng nhập.");
                request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", "Đăng ký không thành công. Vui lòng thử lại.");
                request.getRequestDispatcher("/views/register.jsp").forward(request, response);
            }

        } catch (Exception ex) {
            Logger.getLogger(RegisterController.class.getName()).log(Level.SEVERE, null, ex);
            request.setAttribute("errorMessage", "Lỗi hệ thống khi đăng ký. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/views/register.jsp").forward(request, response);
        }
    }

    private String trim(String s) { return s == null ? null : s.trim(); }
}