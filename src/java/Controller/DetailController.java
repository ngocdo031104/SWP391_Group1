package Controller;

import Entities.Tour;
import Model.TourDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "DetailController", urlPatterns = {"/detail"})
public class DetailController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        int id = 1; // Default
        if (idStr != null && !idStr.trim().isEmpty()) {
            try {
                id = Integer.parseInt(idStr);
            } catch (NumberFormatException e) {
                // Ignore
            }
        }
        
        TourDAO tourDAO = null;
        try {
            tourDAO = new TourDAO();
            Tour tour = tourDAO.getTourById(id);
            if (tour != null) {
                request.setAttribute("tour", tour);
                // Fetch all tours for the related tours recommendations grid
                List<Tour> tours = tourDAO.searchTours(null, null, null, null);
                if (tours != null) {
                    for (Tour t : tours) {
                        t.setSchedules(tourDAO.getSchedulesByTourId(t.getTourId()));
                    }
                }
                request.setAttribute("tours", tours);
            } else {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (tourDAO != null) {
                tourDAO.close();
            }
        }
        
        request.getRequestDispatcher("JSP/detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
