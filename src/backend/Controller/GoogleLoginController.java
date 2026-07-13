package Controller;

import Entities.User;
import Entities.UserProfile;
import Model.UserDAO;
import Utils.GoogleLoginUtil;
import Utils.PasswordUtil;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.UUID;

@WebServlet("/google-callback")
public class GoogleLoginController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String code = request.getParameter("code");
        if (code == null || code.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            String accessToken = GoogleLoginUtil.getToken(code);
            JsonObject userInfo = GoogleLoginUtil.getUserInfo(accessToken);

            String email = userInfo.get("email").getAsString();
            String name = userInfo.has("name") ? userInfo.get("name").getAsString() : email.split("@")[0];
            String picture = userInfo.has("picture") ? userInfo.get("picture").getAsString() : null;

            UserDAO userDAO = new UserDAO();
            User user = userDAO.getUserByEmail(email);

            if (user == null) {
                // Đăng ký user mới tự động
                user = new User();
                user.setEmail(email);
                user.setFullName(name);
                user.setPasswordHash(PasswordUtil.hashPassword(UUID.randomUUID().toString())); // Random password
                user.setRoleId(userDAO.getRoleIdByName("Customer"));
                
                UserProfile profile = new UserProfile();
                profile.setAvatarUrl(picture);

                userDAO.register(user, profile);
                userDAO.verifyUser(email); // Xác thực luôn vì email từ Google là chính xác
                
                user = userDAO.getUserByEmail(email); // Get back the inserted user with ID
            }

            if (!user.isIsActive()) {
                request.setAttribute("errorMessage", "Tài khoản của bạn đã bị khóa.");
                request.getRequestDispatcher("/views/login.jsp").forward(request, response);
                return;
            }

            // Đăng nhập
            HttpSession session = request.getSession(true);
            session.setAttribute("sessionUser", user);
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("userRole", user.getRole().getRoleName());

            String role = user.getRole().getRoleName();
            switch (role) {
                case "Admin":
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                    break;
                case "Staff":
                    response.sendRedirect(request.getContextPath() + "/staff/dashboard");
                    break;
                case "Guide":
                    response.sendRedirect(request.getContextPath() + "/guide/dashboard");
                    break;
                case "Accountant":
                    response.sendRedirect(request.getContextPath() + "/admin/analytics");
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/home");
                    break;
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Đăng nhập bằng Google thất bại. Lỗi: " + e.getMessage());
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
        }
    }
}
