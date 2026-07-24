/*
 * Màn hình 7: Manage Tours - Quản lý tour (tạo, sửa, vô hiệu hóa)
 * Tác giả: Dương Quang Sơn
 * MSSV: HE186525
 * Ngày tạo: 2026-07-21
 */
package Controller;

import Entities.Tour;
import Entities.TourCategory;
import Entities.User;
import Model.TourDAO;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
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

    /**
     * Xử lý yêu cầu HTTP GET.
     * 1. Kiểm tra quyền truy cập của người dùng (chỉ Admin/Super Admin được phép).
     * 2. Xử lý yêu cầu AJAX (?ajax=true):
     *    - action = "getInclusions": Lấy danh sách các dịch vụ bao gồm/loại trừ của một tour cụ thể dưới dạng JSON.
     *    - action = "getItinerary": Lấy lịch trình chi tiết của một tour cụ thể, nối thành chuỗi text định dạng dòng gửi về client.
     *    - Không có action (mặc định): Trả về JSON tổng doanh thu, doanh thu 6 tháng gần nhất và danh sách tour (nếu truy cập từ /admin/tours).
     * 3. Xử lý yêu cầu GET thông thường (tải trang):
     *    - Lấy danh sách phân mục Tour (TourCategory) để đổ vào form.
     *    - Điều hướng sang trang Dashboard hoặc Tour Management tương ứng theo URL truy cập.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // 1. Kiểm tra quyền hạn Admin từ Session
        User sessionUser = (User) request.getSession().getAttribute("sessionUser");
        String userRole = (String) request.getSession().getAttribute("userRole");
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (sessionUser.getRoleId() != 1 && !"Admin".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/admin/analytics");
            return;
        }

        // 2. Xử lý yêu cầu AJAX lấy dữ liệu JSON
        String ajax = request.getParameter("ajax");
        if ("true".equalsIgnoreCase(ajax)) {
            String action = request.getParameter("action");
            
            // Lấy danh sách dịch vụ đi kèm (Inclusions) để hiển thị trong form sửa
            if ("getInclusions".equalsIgnoreCase(action)) {
                response.setContentType("application/json;charset=UTF-8");
                TourDAO tourDAO = null;
                try {
                    tourDAO = new TourDAO();
                    int tourId = parseInt(request.getParameter("tourId"), 0);
                    List<Entities.TourInclusion> inclusions = tourDAO.getInclusionsByTourId(tourId);
                    
                    String json = new Gson().toJson(inclusions);
                    try (PrintWriter out = response.getWriter()) {
                        out.print(json);
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

            // Lấy lịch trình dạng text gộp để chỉnh sửa dễ dàng
            if ("getItinerary".equalsIgnoreCase(action)) {
                response.setContentType("application/json;charset=UTF-8");
                TourDAO tourDAO = null;
                try {
                    tourDAO = new TourDAO();
                    int tourId = parseInt(request.getParameter("tourId"), 0);
                    List<Entities.TourItinerary> itineraries = tourDAO.getItineraryByTourId(tourId);
                    
                    // Nối các ngày thành chuỗi để hiển thị trên textarea
                    StringBuilder text = new StringBuilder();
                    for (Entities.TourItinerary it : itineraries) {
                        text.append("Ngày ").append(it.getDayNumber()).append(": ").append(it.getTitle());
                        if (it.getDescription() != null && !it.getDescription().trim().isEmpty()) {
                            text.append(" - ").append(it.getDescription().trim());
                        }
                        text.append("\n");
                    }
                    
                    Gson gson = new Gson();
                    JsonObject result = new JsonObject();
                    result.addProperty("text", text.toString().trim());
                    try (PrintWriter out = response.getWriter()) {
                        out.print(gson.toJson(result));
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    try (PrintWriter out = response.getWriter()) {
                        out.print("{\"text\":\"\"}");
                    }
                } finally {
                    if (tourDAO != null) {
                        tourDAO.close();
                    }
                }
                return;
            }

            // Xử lý mặc định lấy thống kê doanh thu và thông tin tour phục vụ biểu đồ & bảng
            String path = request.getServletPath();
            response.setContentType("application/json;charset=UTF-8");
            TourDAO tourDAO = null;
            try {
                tourDAO = new TourDAO();
                double[] monthlyRevenue = tourDAO.getMonthlyRevenueLast6Months();
                long[] revenueLongs = new long[monthlyRevenue.length];
                for (int i = 0; i < monthlyRevenue.length; i++) {
                    revenueLongs[i] = (long) monthlyRevenue[i];
                }

                JsonObject root = new JsonObject();
                root.add("monthlyRevenue", new Gson().toJsonTree(revenueLongs));
                root.addProperty("totalRevenue", tourDAO.getTotalRevenue());

                if ("/admin/dashboard".equals(path)) {
                    // Nếu là trang Dashboard, chỉ cần lấy dữ liệu doanh thu
                } else {
                    // Nếu là trang Quản lý tour, lấy thêm danh sách toàn bộ các tour
                    List<Tour> tours = tourDAO.getAllToursAdmin();
                    JsonArray toursArray = new JsonArray();
                    for (Tour t : tours) {
                        JsonObject tourJson = new Gson().toJsonTree(t).getAsJsonObject();
                        tourJson.addProperty("categoryName", t.getCategory() != null ? t.getCategory().getCategoryName() : "Khác");
                        if (t.getCreatedAt() != null) {
                            tourJson.addProperty("createdAt", t.getCreatedAt().toString().split(" ")[0]);
                        } else {
                            tourJson.addProperty("createdAt", "2026-05-20");
                        }
                        toursArray.add(tourJson);
                    }
                    root.add("tours", toursArray);
                }

                try (PrintWriter out = response.getWriter()) {
                    out.print(new Gson().toJson(root));
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
            // 3. Tải giao diện trang HTML/JSP thông thường
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
            
            // Kiểm tra đường dẫn URL để forward tới trang Dashboard hoặc trang quản lý Tour
            String path = request.getServletPath();
            if ("/admin/dashboard".equals(path)) {
                request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("/admin/tourmanagement.jsp").forward(request, response);
            }
        }
    }

    /**
     * Xử lý yêu cầu HTTP POST để cập nhật thông tin dữ liệu Tour.
     * Hỗ trợ các chức năng:
     * - "add" / "edit": Thêm hoặc sửa thông tin chi tiết một Tour (bao gồm thông tin cơ bản, vị trí GPS, dịch vụ đi kèm inclusions, lịch trình hành trình itineraries).
     * - "delete": Thực hiện xóa một Tour khỏi hệ thống (đồng bộ xóa các dữ liệu ràng buộc liên quan).
     * - "toggle-status": Thay đổi trạng thái hiển thị nhanh (Bật/Tắt) của Tour.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Kiểm tra quyền hạn Admin
        User sessionUser = (User) request.getSession().getAttribute("sessionUser");
        String userRole = (String) request.getSession().getAttribute("userRole");
        if (sessionUser == null || (sessionUser.getRoleId() != 1 && !"Admin".equals(userRole))) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"status\":\"error\",\"message\":\"Access Denied\"}");
            }
            return;
        }

        response.setContentType("application/json;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        TourDAO tourDAO = null;
        
        try {
            tourDAO = new TourDAO();
            
            // 2. Thêm mới hoặc Cập nhật thông tin Tour
            if ("add".equalsIgnoreCase(action) || "edit".equalsIgnoreCase(action)) {
                Tour tour = new Tour();
                if ("edit".equalsIgnoreCase(action)) {
                    tour.setTourId(parseInt(request.getParameter("tourId"), 0));
                }
                
                int categoryId = parseInt(request.getParameter("categoryId"), 1);
                String tourName = request.getParameter("tourName");
                String description = request.getParameter("description");
                String destination = request.getParameter("destination");
                int durationDays = parseInt(request.getParameter("durationDays"), 1);
                String itinerary = request.getParameter("itinerary");
                String difficultyLevel = request.getParameter("difficultyLevel");
                double basePrice = parseDouble(request.getParameter("basePrice"), 0.0);
                int maxParticipants = parseInt(request.getParameter("maxParticipants"), 20);
                String status = request.getParameter("status"); // Active, Draft, Disabled
                boolean isFeatured = "true".equalsIgnoreCase(request.getParameter("isFeatured"));
                String languages = request.getParameter("languages");
                int groupSizeMin = parseInt(request.getParameter("groupSizeMin"), 1);
                int groupSizeMax = parseInt(request.getParameter("groupSizeMax"), 20);
                String departureCity = request.getParameter("departureCity");
                
                // Kiểm tra ràng buộc dữ liệu tại Server (Server-side validation)
                String errMsg = null;
                if (basePrice < 0) {
                    errMsg = "Giá cơ bản không được âm!";
                } else if (durationDays < 1) {
                    errMsg = "Thời lượng tour phải tối thiểu là 1 ngày!";
                } else if (maxParticipants < 1) {
                    errMsg = "Số khách tối đa phải lớn hơn hoặc bằng 1!";
                } else if (groupSizeMin < 1) {
                    errMsg = "Số người tối thiểu mỗi đoàn phải lớn hơn hoặc bằng 1!";
                } else if (groupSizeMax < 1) {
                    errMsg = "Số người tối đa mỗi đoàn phải lớn hơn hoặc bằng 1!";
                } else if (groupSizeMin > groupSizeMax) {
                    errMsg = "Số người tối thiểu mỗi đoàn không được vượt quá số người tối đa!";
                } else if (groupSizeMax > maxParticipants) {
                    errMsg = "Số người tối đa mỗi đoàn không được vượt quá số khách tối đa của tour!";
                }

                if (errMsg != null) {
                    Gson gson = new Gson();
                    try (PrintWriter out = response.getWriter()) {
                        JsonObject resp = new JsonObject();
                        resp.addProperty("status", "error");
                        resp.addProperty("message", errMsg);
                        out.print(gson.toJson(resp));
                    }
                    return;
                }

                tour.setCategoryId(categoryId);
                tour.setTourName(tourName);
                tour.setDescription(description);
                tour.setDestination(destination);
                tour.setDurationDays(durationDays);
                tour.setItinerary(itinerary);
                tour.setDifficultyLevel(difficultyLevel);
                tour.setBasePrice(basePrice);
                tour.setMaxParticipants(maxParticipants);
                tour.setStatus(status);
                tour.setIsFeatured(isFeatured);
                tour.setLanguages(languages);
                tour.setGroupSizeMin(groupSizeMin);
                tour.setGroupSizeMax(groupSizeMax);
                tour.setDepartureCity(departureCity);
                
                // Thiết lập toạ độ bản đồ nếu có điền
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
                
                // Đồng bộ hóa các bảng chi tiết liên quan nếu lưu thông tin Tour thành công
                if (success) {
                    // Cập nhật bảng dịch vụ kèm theo (Inclusions) bằng cách xóa đi thêm lại
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
                    
                    // Cập nhật bảng lịch trình chi tiết (Itinerary) bằng cách tách dòng từ text
                    tourDAO.syncTourItineraryFromText(tour.getTourId(), tour.getItinerary());
                }
                
                Gson gson = new Gson();
                try (PrintWriter out = response.getWriter()) {
                    JsonObject resp = new JsonObject();
                    if (success) {
                        resp.addProperty("status", "success");
                        resp.addProperty("message", "Lưu thông tin tour thành công!");
                        resp.addProperty("tourId", tour.getTourId());
                    } else {
                        resp.addProperty("status", "error");
                        resp.addProperty("message", "Không thể lưu thông tin tour.");
                    }
                    out.print(gson.toJson(resp));
                }
                
            } 
            // 3. Xử lý yêu cầu Xóa Tour
            else if ("delete".equalsIgnoreCase(action)) {
                int tourId = parseInt(request.getParameter("tourId"), 0);
                boolean success = tourDAO.deleteTour(tourId);
                Gson gson = new Gson();
                try (PrintWriter out = response.getWriter()) {
                    JsonObject resp = new JsonObject();
                    if (success) {
                        resp.addProperty("status", "success");
                        resp.addProperty("message", "Xóa tour thành công!");
                    } else {
                        resp.addProperty("status", "error");
                        resp.addProperty("message", "Không thể xóa tour (tour này có thể đang có lịch trình hoặc đơn đặt).");
                    }
                    out.print(gson.toJson(resp));
                }
                
            } 
            // 4. Thay đổi trạng thái hiển thị nhanh
            else if ("toggle-status".equalsIgnoreCase(action)) {
                int tourId = parseInt(request.getParameter("tourId"), 0);
                String status = request.getParameter("status");
                boolean success = tourDAO.updateTourStatus(tourId, status);
                Gson gson = new Gson();
                try (PrintWriter out = response.getWriter()) {
                    JsonObject resp = new JsonObject();
                    if (success) {
                        resp.addProperty("status", "success");
                        resp.addProperty("message", "Cập nhật trạng thái thành công!");
                    } else {
                        resp.addProperty("status", "error");
                        resp.addProperty("message", "Không thể cập nhật trạng thái tour.");
                    }
                    out.print(gson.toJson(resp));
                }
            } else {
                Gson gson = new Gson();
                try (PrintWriter out = response.getWriter()) {
                    JsonObject resp = new JsonObject();
                    resp.addProperty("status", "error");
                    resp.addProperty("message", "Hành động không xác định.");
                    out.print(gson.toJson(resp));
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            Gson gson = new Gson();
            try (PrintWriter out = response.getWriter()) {
                JsonObject resp = new JsonObject();
                resp.addProperty("status", "error");
                resp.addProperty("message", "Lỗi hệ thống: " + e.getMessage());
                out.print(gson.toJson(resp));
            }
        } finally {
            if (tourDAO != null) {
                tourDAO.close();
            }
        }
    }

    /**
     * Helper ép kiểu chuỗi sang int an toàn, nếu null hoặc lỗi format thì lấy giá trị default
     */
    private int parseInt(String value, int defaultVal) {
        try {
            if (value != null && !value.trim().isEmpty()) {
                return Integer.parseInt(value.trim());
            }
        } catch (NumberFormatException e) {}
        return defaultVal;
    }

    /**
     * Helper ép kiểu chuỗi sang double an toàn
     */
    private double parseDouble(String value, double defaultVal) {
        try {
            if (value != null && !value.trim().isEmpty()) {
                return Double.parseDouble(value.trim());
            }
        } catch (NumberFormatException e) {}
        return defaultVal;
    }
}
