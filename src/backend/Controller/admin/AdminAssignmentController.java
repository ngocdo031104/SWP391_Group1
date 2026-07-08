package Controller.admin;

import Entities.User;
import Entities.TourAssignment;
import Model.GuideDAO;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminAssignmentController", urlPatterns = {"/admin/assignments"})
public class AdminAssignmentController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AdminAssignmentController.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User sessionUser = (User) request.getSession().getAttribute("sessionUser");
        String userRole = (String) request.getSession().getAttribute("userRole");

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        boolean hasPermission = false;
        if (sessionUser.getRoleId() == 1) {
            hasPermission = true;
        } else if (sessionUser.getRole() != null && sessionUser.getRole().getPermissions() != null) {
            for (Entities.Permission p : sessionUser.getRole().getPermissions()) {
                if (p.getPermissionId() == 32) {
                    hasPermission = true;
                    break;
                }
            }
        }

        if (!hasPermission) {
            response.sendRedirect(request.getContextPath() + "/403-forbidden.jsp");
            return;
        }

        GuideDAO guideDAO = new GuideDAO();
        try {
            List<TourAssignment> assignments = guideDAO.getAllAssignments();
            request.setAttribute("assignments", assignments);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading guide assignments history log", e);
        } finally {
            guideDAO.close();
        }

        request.getRequestDispatcher("/admin/assignments.jsp").forward(request, response);
    }
}
