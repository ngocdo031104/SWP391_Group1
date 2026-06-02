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

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String dob = request.getParameter("dob");
        String gender = request.getParameter("gender");
        String role = request.getParameter("role");

        boolean hasError = false;

        // Validation logic
        if (email == null || email.trim().isEmpty() || !email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            request.setAttribute("emailError", "Email không hợp lệ");
            hasError = true;
        } else if (userDAO.checkEmailExists(email)) {
            request.setAttribute("emailError", "Email này đã được sử dụng");
            hasError = true;
        }

        if (password == null || password.length() < 8) {
            request.setAttribute("passwordError", "Mật khẩu phải từ 8 ký tự trở lên");
            hasError = true;
        } else if (!password.equals(confirmPassword)) {
            request.setAttribute("confirmError", "Mật khẩu xác nhận không khớp");
            hasError = true;
        }

        if (fullName == null || fullName.trim().isEmpty()) {
            request.setAttribute("nameError", "Họ và tên không được để trống");
            hasError = true;
        }

        if (phone != null && !phone.trim().isEmpty() && !phone.matches("^[0-9]{9,11}$")) {
            request.setAttribute("phoneError", "Số điện thoại phải từ 9 đến 11 số");
            hasError = true;
        }

        if (hasError) {
            request.setAttribute("errorMessage", "Vui lòng kiểm tra lại thông tin đăng ký");
            // Set params back to JSP so user doesn't lose inputs
            request.setAttribute("paramEmail", email);
            request.setAttribute("paramFullName", fullName);
            request.setAttribute("paramPhone", phone);
            request.setAttribute("paramDob", dob);
            request.setAttribute("paramGender", gender);
            request.setAttribute("paramRole", role);

            request.getRequestDispatcher("/views/register.jsp").forward(request, response);
            return;
        }

        try {
            // Hash password
            String passwordHash = PasswordUtil.hashPassword(password);

            // Create User entity
            User user = new User();
            user.setEmail(email);
            user.setPasswordHash(passwordHash);
            user.setFullName(fullName);
            user.setPhoneNumber(phone);
            
            // Resolve RoleID from database
            if (role == null || role.trim().isEmpty()) {
                role = "Customer";
            }
            int roleId = userDAO.getRoleIdByName(role);
            user.setRoleId(roleId);

            // Create UserProfile entity
            UserProfile profile = new UserProfile();
            profile.setGender(gender);
            if (dob != null && !dob.trim().isEmpty()) {
                try {
                    profile.setDateOfBirth(Date.valueOf(dob));
                } catch (IllegalArgumentException e) {
                    // Ignore
                }
            }
            // Set default avatar depending on gender or role
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
            request.setAttribute("errorMessage", "Lỗi hệ thống khi đăng ký");
            request.getRequestDispatcher("/views/register.jsp").forward(request, response);
        }
    }
}
