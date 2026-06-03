package Controller;

import Entities.Tour;
import Entities.TourCategory;
import Entities.DestinationInfo;
import Entities.Review;
import Entities.Coupon;
import Model.TourDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "HomeController", urlPatterns = {"/home"})
public class HomeController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        TourDAO tourDAO = null;
        try {
            tourDAO = new TourDAO();
            List<TourCategory> categories = tourDAO.getAllCategories();
            List<Tour> featuredTours = tourDAO.getFeaturedTours();
            List<DestinationInfo> destinations = tourDAO.getTopDestinations();
            List<Review> topReviews = tourDAO.getTopReviews(5);
            List<Coupon> activeCoupons = tourDAO.getActiveCoupons(5);
            
            // Populate schedules for each featured tour to determine available seats dynamically
            if (featuredTours != null) {
                for (Tour tour : featuredTours) {
                    tour.setSchedules(tourDAO.getSchedulesByTourId(tour.getTourId()));
                }
            }
            
            request.setAttribute("categories", categories);
            request.setAttribute("featuredTours", featuredTours);
            request.setAttribute("destinations", destinations);
            request.setAttribute("topReviews", topReviews);
            request.setAttribute("activeCoupons", activeCoupons);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (tourDAO != null) {
                tourDAO.close();
            }
        }
        
        // Forward request to the HomePage view JSP
        request.getRequestDispatcher("views/HomePage.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
