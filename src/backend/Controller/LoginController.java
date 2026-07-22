/*
 * Li\u00ean quan \u0111\u1ebfn UCs: Authenticate User
 * T\u00e1c gi\u1ea3: \u0110\u1ed7 V\u0169 Minh Ng\u1ecdc
 * MSSV: HE182479
 */
package Controller;

/**
 * Controller class for managing user authentication.
 * Handles the login and logout operations, session management,
 * and remembering user sessions via cookies.
 */

import Entities.User;
import Model.UserDAO;
import Utils.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(urlPatterns = {"/login", "/logout"})
public class LoginController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String path = request.getServletPath();
        if ("/logout".equals(path)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            // Clear TB cookie if any
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("tb_email".equals(cookie.getName())) {
                        cookie.setMaxAge(0);
                        String cpath = request.getContextPath();
                        cookie.setPath(cpath != null && !cpath.isEmpty() ? cpath : "/");
                        response.addCookie(cookie);
                    }
                }
            }
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        HttpSession session = request.getSession(false);

        if (session != null
                && session.getAttribute("sessionUser") != null) {

            response.sendRedirect(
                    request.getContextPath() + "/home"
            );
            return;
        }

        request.getRequestDispatcher("/views/login.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        UserDAO userDAO = new UserDAO();

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String rememberMe = request.getParameter("rememberMe");

        // Validate Email
        if (email == null || email.trim().isEmpty()) {

            request.setAttribute(
                    "errorMessage",
                    "Email kh\u00f4ng \u0111\u01b0\u1ee3c \u0111\u1ec3 tr\u1ed1ng"
            );

            request.getRequestDispatcher("/views/login.jsp")
                    .forward(request, response);
            return;
        }

        // Validate Password
        if (password == null || password.trim().isEmpty()) {

            request.setAttribute(
                    "errorMessage",
                    "M\u1eadt kh\u1ea9u kh\u00f4ng \u0111\u01b0\u1ee3c \u0111\u1ec3 tr\u1ed1ng"
            );

            request.getRequestDispatcher("/views/login.jsp")
                    .forward(request, response);
            return;
        }

        try {

            // Hash password tr\u01b0\u1edbc khi so s\u00e1nh DB
            String passwordHash =
                    PasswordUtil.hashPassword(password);

            User user =
                    userDAO.login(email, passwordHash);

            if (user == null) {

                request.setAttribute(
                        "errorMessage",
                        "Email ho\u1eb7c m\u1eadt kh\u1ea9u kh\u00f4ng \u0111\u00fang"
                );

                request.getRequestDispatcher("/views/login.jsp")
                        .forward(request, response);
                return;
            }

            if (!user.isIsVerified()) {
                request.setAttribute(
                        "errorMessage",
                        "T\u00e0i kho\u1ea3n ch\u01b0a \u0111\u01b0\u1ee3c x\u00e1c th\u1ef1c. Vui l\u00f2ng ki\u1ec3m tra email c\u1ee7a b\u1ea1n \u0111\u1ec3 l\u1ea5y m\u00e3 x\u00e1c nh\u1eadn."
                );

                request.getRequestDispatcher("/views/login.jsp")
                        .forward(request, response);
                return;
            }

            // T\u1ea1o Session
            HttpSession session =
                    request.getSession(true);

            session.setAttribute("sessionUser", user);
            session.setAttribute("userId",
                    user.getUserId());

            session.setAttribute("userRole",
                    user.getRole().getRoleName());

            // Remember Me
            if ("on".equals(rememberMe)) {

                Cookie cookie =
                        new Cookie("tb_email", email);

                cookie.setMaxAge(
                        60 * 60 * 24 * 30
                );

                cookie.setPath(
                        request.getContextPath()
                );

                response.addCookie(cookie);
            }

            String role =
                    user.getRole().getRoleName();

            switch (role) {

                case "Admin":
                    response.sendRedirect(
                            request.getContextPath()
                                    + "/admin/dashboard"
                    );
                    break;

                case "Staff":
                    response.sendRedirect(
                            request.getContextPath()
                                    + "/staff/dashboard"
                    );
                    break;

                case "Guide":
                    response.sendRedirect(
                            request.getContextPath()
                                    + "/guide/dashboard"
                    );
                    break;

                case "Accountant":
                    response.sendRedirect(
                            request.getContextPath()
                                    + "/admin/analytics"
                    );
                    break;

                default:
                    response.sendRedirect(
                            request.getContextPath()
                                    + "/home"
                    );
                    break;
            }

        } catch (Exception ex) {

            ex.printStackTrace();

            request.setAttribute(
                    "errorMessage",
                    "C\u00f3 l\u1ed7i x\u1ea3y ra khi \u0111\u0103ng nh\u1eadp"
            );

            request.getRequestDispatcher("/views/login.jsp")
                    .forward(request, response);
        }
    }
}
