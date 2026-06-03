package Controller;

import Entities.Tour;
import Entities.TourCategory;
import Model.TourDAO;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminTourController", urlPatterns = {"/admin/tours", "/admin/dashboard"})
public class AdminTourController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String ajax = request.getParameter("ajax");
        
        if ("true".equalsIgnoreCase(ajax)) {
            String action = request.getParameter("action");
            if ("getInclusions".equalsIgnoreCase(action)) {
                response.setContentType("application/json;charset=UTF-8");
                TourDAO tourDAO = null;
                try {
                    tourDAO = new TourDAO();
                    int tourId = parseInt(request.getParameter("tourId"), 0);
                    List<Entities.TourInclusion> inclusions = tourDAO.getInclusionsByTourId(tourId);
                    
                    StringBuilder json = new StringBuilder("[");
                    for (int i = 0; i < inclusions.size(); i++) {
                        Entities.TourInclusion inc = inclusions.get(i);
                        json.append("{")
                            .append("\"inclusionId\":").append(inc.getInclusionId()).append(",")
                            .append("\"tourId\":").append(inc.getTourId()).append(",")
                            .append("\"inclusionType\":\"").append(escapeJson(inc.getInclusionType())).append("\",")
                            .append("\"serviceName\":\"").append(escapeJson(inc.getServiceName())).append("\",")
                            .append("\"iconName\":\"").append(escapeJson(inc.getIconName())).append("\"")
                            .append("}");
                        if (i < inclusions.size() - 1) {
                            json.append(",");
                        }
                    }
                    json.append("]");
                    try (PrintWriter out = response.getWriter()) {
                        out.print(json.toString());
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    try (PrintWriter out = response.getWriter()) {
                        out.print("[]");
                    }
                } finally {
                    if (tourDAO != null) {
                        tourDAO.close();
                    }
                }
                return;
            }

            response.setContentType("application/json;charset=UTF-8");
            TourDAO tourDAO = null;
            try {
                tourDAO = new TourDAO();
                List<Tour> tours = tourDAO.getAllToursAdmin();
                
                double[] monthlyRevenue = tourDAO.getMonthlyRevenueLast6Months();
                
                StringBuilder json = new StringBuilder("{");
                json.append("\"tours\":[");
                for (int i = 0; i < tours.size(); i++) {
                    Tour t = tours.get(i);
                    json.append("{")
                        .append("\"tourId\":").append(t.getTourId()).append(",")
                        .append("\"categoryId\":").append(t.getCategoryId()).append(",")
                        .append("\"categoryName\":\"").append(escapeJson(t.getCategory() != null ? t.getCategory().getCategoryName() : "Khác")).append("\",")
                        .append("\"tourName\":\"").append(escapeJson(t.getTourName())).append("\",")
                        .append("\"description\":\"").append(escapeJson(t.getDescription())).append("\",")
                        .append("\"destination\":\"").append(escapeJson(t.getDestination())).append("\",")
                        .append("\"durationDays\":").append(t.getDurationDays()).append(",")
                        .append("\"itinerary\":\"").append(escapeJson(t.getItinerary())).append("\",")
                        .append("\"difficultyLevel\":\"").append(escapeJson(t.getDifficultyLevel())).append("\",")
                        .append("\"basePrice\":").append(t.getBasePrice()).append(",")
                        .append("\"maxParticipants\":").append(t.getMaxParticipants()).append(",")
                        .append("\"status\":\"").append(escapeJson(t.getStatus())).append("\",")
                        .append("\"isFeatured\":").append(t.isIsFeatured()).append(",")
                        .append("\"languages\":\"").append(escapeJson(t.getLanguages())).append("\",")
                        .append("\"groupSizeMin\":").append(t.getGroupSizeMin()).append(",")
                        .append("\"groupSizeMax\":").append(t.getGroupSizeMax()).append(",")
                        .append("\"departureCity\":\"").append(escapeJson(t.getDepartureCity())).append("\",")
                        .append("\"videoUrl\":\"").append(escapeJson(t.getVideoUrl())).append("\",")
                        .append("\"rating\":").append(t.getRating()).append(",")
                        .append("\"reviewsCount\":").append(t.getReviewsCount()).append(",")
                        .append("\"totalSeats\":").append(t.getTotalSeats()).append(",")
                        .append("\"availableSeats\":").append(t.getAvailableSeats()).append(",")
                        .append("\"nextDeparture\":\"").append(escapeJson(t.getNextDeparture() != null ? t.getNextDeparture() : "")).append("\",")
                        .append("\"createdAt\":\"").append(t.getCreatedAt() != null ? t.getCreatedAt().toString().split(" ")[0] : "2026-05-20").append("\"")
                        .append("}");
                    if (i < tours.size() - 1) {
                        json.append(",");
                    }
                }
                json.append("],");
                
                json.append("\"monthlyRevenue\":[");
                for (int i = 0; i < monthlyRevenue.length; i++) {
                    json.append((long)monthlyRevenue[i]); // cast to long to avoid decimal formatting issues in JS chart
                    if (i < monthlyRevenue.length - 1) {
                        json.append(",");
                    }
                }
                json.append("]");
                json.append("}");
                
                try (PrintWriter out = response.getWriter()) {
                    out.print(json.toString());
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                try (PrintWriter out = response.getWriter()) {
                    out.print("{\"status\":\"error\",\"message\":\"" + e.getMessage() + "\"}");
                }
            } finally {
                if (tourDAO != null) {
                    tourDAO.close();
                }
            }
        } else {
            // Forward to the JSP page
            TourDAO tourDAO = null;
            try {
                tourDAO = new TourDAO();
                List<TourCategory> categories = tourDAO.getAllCategories();
                request.setAttribute("categories", categories);
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (tourDAO != null) {
                    tourDAO.close();
                }
            }
            String path = request.getServletPath();
            if ("/admin/dashboard".equals(path)) {
                request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("/admin/tourmanagement.jsp").forward(request, response);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        TourDAO tourDAO = null;
        
        try {
            tourDAO = new TourDAO();
            
            if ("add".equalsIgnoreCase(action) || "edit".equalsIgnoreCase(action)) {
                Tour tour = new Tour();
                if ("edit".equalsIgnoreCase(action)) {
                    tour.setTourId(parseInt(request.getParameter("tourId"), 0));
                }
                
                tour.setCategoryId(parseInt(request.getParameter("categoryId"), 1));
                tour.setTourName(request.getParameter("tourName"));
                tour.setDescription(request.getParameter("description"));
                tour.setDestination(request.getParameter("destination"));
                tour.setDurationDays(parseInt(request.getParameter("durationDays"), 1));
                tour.setItinerary(request.getParameter("itinerary"));
                tour.setDifficultyLevel(request.getParameter("difficultyLevel"));
                tour.setBasePrice(parseDouble(request.getParameter("basePrice"), 0.0));
                tour.setMaxParticipants(parseInt(request.getParameter("maxParticipants"), 20));
                tour.setStatus(request.getParameter("status"));
                tour.setIsFeatured("true".equalsIgnoreCase(request.getParameter("isFeatured")));
                tour.setLanguages(request.getParameter("languages"));
                tour.setGroupSizeMin(parseInt(request.getParameter("groupSizeMin"), 1));
                tour.setGroupSizeMax(parseInt(request.getParameter("groupSizeMax"), 20));
                tour.setDepartureCity(request.getParameter("departureCity"));
                
                String latStr = request.getParameter("latitude");
                if (latStr != null && !latStr.trim().isEmpty()) {
                    tour.setLatitude(parseDouble(latStr, 0.0));
                } else {
                    tour.setLatitude(null);
                }
                String lngStr = request.getParameter("longitude");
                if (lngStr != null && !lngStr.trim().isEmpty()) {
                    tour.setLongitude(parseDouble(lngStr, 0.0));
                } else {
                    tour.setLongitude(null);
                }
                
                tour.setVideoUrl(request.getParameter("videoUrl"));
                
                boolean success;
                if ("add".equalsIgnoreCase(action)) {
                    int generatedId = tourDAO.insertTour(tour);
                    success = generatedId > 0;
                    tour.setTourId(generatedId);
                } else {
                    success = tourDAO.updateTour(tour);
                }
                
                if (success) {
                    String[] incTypes = request.getParameterValues("incType");
                    String[] incIcons = request.getParameterValues("incIcon");
                    String[] incServices = request.getParameterValues("incService");
                    
                    List<Entities.TourInclusion> inclusions = new java.util.ArrayList<>();
                    if (incServices != null) {
                        for (int i = 0; i < incServices.length; i++) {
                            if (incServices[i] != null && !incServices[i].trim().isEmpty()) {
                                Entities.TourInclusion item = new Entities.TourInclusion();
                                item.setTourId(tour.getTourId());
                                item.setInclusionType(incTypes != null && i < incTypes.length ? incTypes[i] : "INCLUDED");
                                item.setIconName(incIcons != null && i < incIcons.length ? incIcons[i] : "sparkles");
                                item.setServiceName(incServices[i].trim());
                                item.setSortOrder(i);
                                inclusions.add(item);
                            }
                        }
                    }
                    tourDAO.saveTourInclusions(tour.getTourId(), inclusions);
                }
                
                try (PrintWriter out = response.getWriter()) {
                    if (success) {
                        out.print("{\"status\":\"success\",\"message\":\"Lưu thông tin tour thành công!\",\"tourId\":" + tour.getTourId() + "}");
                    } else {
                        out.print("{\"status\":\"error\",\"message\":\"Không thể lưu thông tin tour.\"}");
                    }
                }
                
            } else if ("delete".equalsIgnoreCase(action)) {
                int tourId = parseInt(request.getParameter("tourId"), 0);
                boolean success = tourDAO.deleteTour(tourId);
                try (PrintWriter out = response.getWriter()) {
                    if (success) {
                        out.print("{\"status\":\"success\",\"message\":\"Xóa tour thành công!\"}");
                    } else {
                        out.print("{\"status\":\"error\",\"message\":\"Không thể xóa tour (tour này có thể đang có lịch trình hoặc đơn đặt).\"}");
                    }
                }
                
            } else if ("toggle-status".equalsIgnoreCase(action)) {
                int tourId = parseInt(request.getParameter("tourId"), 0);
                String status = request.getParameter("status");
                boolean success = tourDAO.updateTourStatus(tourId, status);
                try (PrintWriter out = response.getWriter()) {
                    if (success) {
                        out.print("{\"status\":\"success\",\"message\":\"Cập nhật trạng thái thành công!\"}");
                    } else {
                        out.print("{\"status\":\"error\",\"message\":\"Không thể cập nhật trạng thái tour.\"}");
                    }
                }
            } else {
                try (PrintWriter out = response.getWriter()) {
                    out.print("{\"status\":\"error\",\"message\":\"Hành động không xác định.\"}");
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"status\":\"error\",\"message\":\"Lỗi hệ thống: " + e.getMessage() + "\"}");
            }
        } finally {
            if (tourDAO != null) {
                tourDAO.close();
            }
        }
    }

    private int parseInt(String value, int defaultVal) {
        try {
            if (value != null && !value.trim().isEmpty()) {
                return Integer.parseInt(value.trim());
            }
        } catch (NumberFormatException e) {}
        return defaultVal;
    }

    private double parseDouble(String value, double defaultVal) {
        try {
            if (value != null && !value.trim().isEmpty()) {
                return Double.parseDouble(value.trim());
            }
        } catch (NumberFormatException e) {}
        return defaultVal;
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\b", "\\b")
                    .replace("\f", "\\f")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }
}
