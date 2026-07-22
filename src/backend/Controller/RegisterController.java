/*
 * Li\u00ean quan \u0111\u1ebfn UCs: Register Account
 * T\u00e1c gi\u1ea3: \u0110\u1ed7 V\u0169 Minh Ng\u1ecdc
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
        // X\u00e1c th\u1ef1c \u0111\u1ecbnh d\u1ea1ng Email
        // ==========================
        if (email == null || email.isEmpty()) {
            request.setAttribute("emailError", "Email kh\u00f4ng \u0111\u01b0\u1ee3c \u0111\u1ec3 tr\u1ed1ng");
            hasError = true;
        } else if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            request.setAttribute("emailError", "\u00c4\u0090\u00e1\u00bb\u2039nh d\u1ea1ng email kh\u00f4ng h\u1ee3p l\u1ec7");
            hasError = true;
        } else if (userDAO.checkEmailExists(email)) {
            request.setAttribute("emailError", "Email \u0111\u00e3 \u0111\u01b0\u1ee3c \u0111\u0103ng k\u00fd");
            hasError = true;
        }

        // ==========================
        // X\u00e1c th\u1ef1c M\u1eadt kh\u1ea9u (\u0111\u1ed9 d\u00e0i, k\u00fd t\u1ef1)
        // ==========================
        if (password == null || password.isEmpty()) {
            request.setAttribute("passwordError", "M\u1eadt kh\u1ea9u kh\u00f4ng \u0111\u01b0\u1ee3c \u0111\u1ec3 tr\u1ed1ng");
            hasError = true;
        } else if (password.length() < 8) {
            request.setAttribute("passwordError", "M\u1eadt kh\u1ea9u ph\u1ea3i c\u00f3 \u00edt nh\u1ea5t 8 k\u00fd t\u1ef1");
            hasError = true;
        } else if (!password.matches(".*[A-Za-z].*")
                || !password.matches(".*[0-9].*")) {
            request.setAttribute("passwordError",
                    "M\u1eadt kh\u1ea9u ph\u1ea3i ch\u1ee9a \u00edt nh\u1ea5t 1 ch\u1eef c\u00e1i v\u00e0 1 ch\u1eef s\u1ed1");
            hasError = true;
        }

        // ==========================
        // X\u00e1c nh\u1eadn l\u1ea1i m\u1eadt kh\u1ea9u
        // ==========================
        if (confirmPassword == null || confirmPassword.isEmpty()) {
            request.setAttribute("confirmError",
                    "Vui l\u00f2ng nh\u1eadp l\u1ea1i m\u1eadt kh\u1ea9u");
            hasError = true;
        } else if (password != null && !password.equals(confirmPassword)) {
            request.setAttribute("confirmError",
                    "M\u1eadt kh\u1ea9u x\u00e1c nh\u1eadn kh\u00f4ng kh\u1edbp");
            hasError = true;
        }

        // ==========================
        // Ki\u1ec3m tra \u0111\u1ed9 d\u00e0i v\u00e0 \u0111\u1ecbnh d\u1ea1ng H\u1ecd t\u00ean
        // ==========================
        if (fullName == null || fullName.isEmpty()) {
            request.setAttribute("nameError",
                    "H\u00e1\u00bb\u008d v\u00e0 t\u00ean kh\u00f4ng \u0111\u01b0\u1ee3c \u0111\u1ec3 tr\u1ed1ng");
            hasError = true;
        } else if (fullName.length() < 2 || fullName.length() > 100) {
            request.setAttribute("nameError",
                    "H\u00e1\u00bb\u008d v\u00e0 t\u00ean ph\u1ea3i t\u1eeb 2 \u0111\u1ebfn 100 k\u00fd t\u1ef1");
            hasError = true;
        } else if (!fullName.matches("^[\\p{L} .'-]+$")) {
            request.setAttribute("nameError",
                    "H\u00e1\u00bb\u008d v\u00e0 t\u00ean ch\u1ec9 \u0111\u01b0\u1ee3c ch\u1ee9a ch\u1eef c\u00e1i v\u00e0 kho\u1ea3ng tr\u1eafng");
            hasError = true;
        }

        // ==========================
        // Ki\u1ec3m tra \u0111\u1ecbnh d\u1ea1ng s\u1ed1 \u0111i\u1ec7n tho\u1ea1i
        // ==========================
        if (phone == null || phone.isEmpty()) {
            request.setAttribute("phoneError",
                    "S\u1ed1 \u0111i\u1ec7n tho\u1ea1i kh\u00f4ng \u0111\u01b0\u1ee3c \u0111\u1ec3 tr\u1ed1ng");
            hasError = true;
        } else if (!phone.matches("^0[0-9]{9}$")) {
            request.setAttribute("phoneError",
                    "S\u1ed1 \u0111i\u1ec7n tho\u1ea1i ph\u1ea3i g\u1ed3m 10 ch\u1eef s\u1ed1 v\u00e0 b\u1eaft \u0111\u1ea7u b\u1eb1ng 0");
            hasError = true;
        }

        // ==========================
        // Ki\u1ec3m tra ng\u00e0y sinh (tr\u00ean 13 tu\u1ed5i)
        // ==========================
        if (dob == null || dob.isEmpty()) {
            request.setAttribute("dobError",
                    "Ng\u00e0y sinh kh\u00f4ng \u0111\u01b0\u1ee3c \u0111\u1ec3 tr\u1ed1ng");
            hasError = true;
        } else {
            try {
                Date parsedDob = Date.valueOf(dob);
                Date today = new Date(System.currentTimeMillis());

                if (parsedDob.after(today)) {
                    request.setAttribute("dobError",
                            "Ng\u00e0y sinh kh\u00f4ng \u0111\u01b0\u1ee3c \u1edf t\u01b0\u01a1ng lai");
                    hasError = true;
                } else {
                    Calendar cal = Calendar.getInstance();
                    cal.add(Calendar.YEAR, -13);

                    if (parsedDob.after(new Date(cal.getTimeInMillis()))) {
                        request.setAttribute("dobError",
                                "B\u1ea1n ph\u1ea3i t\u1eeb 13 tu\u1ed5i tr\u1edf l\u00ean \u0111\u1ec3 \u0111\u0103ng k\u00fd");
                        hasError = true;
                    }
                }

            } catch (IllegalArgumentException e) {
                request.setAttribute("dobError",
                        "\u00c4\u0090\u00e1\u00bb\u2039nh d\u1ea1ng ng\u00e0y sinh kh\u00f4ng h\u1ee3p l\u1ec7");
                hasError = true;
            }
        }

        // ==========================
        // X\u00e1c th\u1ef1c gi\u1edbi t\u00ednh
        // ==========================
        if (gender == null || gender.isEmpty()) {
            request.setAttribute("genderError",
                    "Vui l\u00f2ng ch\u00e1\u00bb\u008dn gi\u1edbi t\u00ednh");
            hasError = true;
        } else if (!gender.equals("Male")
                && !gender.equals("Female")
                && !gender.equals("Other")) {

            request.setAttribute("genderError",
                    "Gi\u1edbi t\u00ednh kh\u00f4ng h\u1ee3p l\u1ec7");
            hasError = true;
        }

        // ==========================
        // X\u00e1c th\u1ef1c quy\u1ec1n (Customer / Guide)
        // ==========================
        if (role == null || role.isEmpty()) {
            request.setAttribute("roleError",
                    "Vui l\u00f2ng ch\u00e1\u00bb\u008dn vai tr\u00f2");
            hasError = true;
        } else if (!role.equals("Customer")
                && !role.equals("Guide")) {

            request.setAttribute("roleError",
                    "Vai tr\u00f2 kh\u00f4ng h\u1ee3p l\u1ec7");
            hasError = true;
        }

        // ==========================
        // N\u1ebfu c\u00f3 l\u1ed7i
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
                // Kh\u1edfi t\u1ea1o m\u00e3 OTP x\u00e1c th\u1ef1c 6 s\u1ed1
                String otp = String.format("%06d", new Random().nextInt(999999));
                
                // L\u01b0u t\u1ea1m email v\u00e0 OTP v\u00e0o session
                request.getSession().setAttribute("verify_email", email);
                request.getSession().setAttribute("verify_otp", otp);
                
                // G\u1eedi m\u00e3 OTP x\u00e1c th\u1ef1c qua Email
                try {
                    EmailUtil.sendOTP(email, otp);
                } catch (Exception e) {
                    e.printStackTrace();
                    Logger.getLogger(RegisterController.class.getName()).log(Level.SEVERE, "Failed to send email", e);
                    request.getSession().setAttribute("emailError", "L\u1ed7i g\u1eedi mail: " + e.getMessage() + " - " + e.getClass().getName());
                }
                
                response.sendRedirect(request.getContextPath() + "/verify");
            } else {

                request.setAttribute(
                        "errorMessage",
                        "\u00c4\u0090\u00c4\u0192ng k\u00fd kh\u00f4ng th\u00e0nh c\u00f4ng. Vui l\u00f2ng th\u1eed l\u1ea1i."
                );

                request.getRequestDispatcher("/views/register.jsp")
                        .forward(request, response);
            }

        } catch (Exception ex) {

            Logger.getLogger(RegisterController.class.getName())
                    .log(Level.SEVERE, null, ex);

            request.setAttribute(
                    "errorMessage",
                    "L\u1ed7i h\u1ec7 th\u1ed1ng khi \u0111\u0103ng k\u00fd. Vui l\u00f2ng th\u1eed l\u1ea1i sau."
            );

            request.getRequestDispatcher("/views/register.jsp")
                    .forward(request, response);
        }
    }

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }
}
