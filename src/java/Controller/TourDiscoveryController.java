package Controller;

import Entities.Tour;
import Entities.TourCategory;
import Model.TourDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "TourDiscoveryController", urlPatterns = {"/tourdiscovery"})
public class TourDiscoveryController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        TourDAO tourDAO = null;
        try {
            tourDAO = new TourDAO();
            List<TourCategory> categories = tourDAO.getAllCategories();
            
            // Get search filters from query string parameters
            String dest = request.getParameter("dest");
            String departureDate = request.getParameter("date");
            String budgetStr = request.getParameter("budget");
            
            Double maxPrice = null;
            if (budgetStr != null && !budgetStr.trim().isEmpty()) {
                try {
                    maxPrice = Double.parseDouble(budgetStr);
                } catch (NumberFormatException e) {
                    // Ignore
                }
            }
            
            // Query matched tours from database
            List<Tour> tours = tourDAO.searchTours(dest, null, maxPrice, departureDate);
            
            // Load schedules for each tour to dynamically calculate availability
            if (tours != null) {
                for (Tour tour : tours) {
                    tour.setSchedules(tourDAO.getSchedulesByTourId(tour.getTourId()));
                }
            }
            
            request.setAttribute("categories", categories);
            request.setAttribute("tours", tours);
            request.setAttribute("searchDest", dest != null ? dest : "");
            request.setAttribute("searchDate", departureDate != null ? departureDate : "");
            request.setAttribute("searchBudget", budgetStr != null ? budgetStr : "");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (tourDAO != null) {
                tourDAO.close();
            }
        }
        
        request.getRequestDispatcher("JSP/tourdiscovery.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
