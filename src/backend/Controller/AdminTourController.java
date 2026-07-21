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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
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

        // Kiểm tra xem request này có phải là AJAX fetch không.
        // Phía JS client (admin-tour.js) sẽ truyền parameter ?ajax=true khi cần lấy dữ liệu JSON.
        String ajax = request.getParameter("ajax");
        
        if ("true".equalsIgnoreCase(ajax)) {
            String action = request.getParameter("action");
            
            // TH1: AJAX lấy danh sách dịch vụ đi kèm (Inclusions) của 1 tour để đổ vào modal Form Edit
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

            // TH2: AJAX lấy lịch trình (Itinerary) dưới dạng văn bản thô để đưa vào Textarea trong Form Edit
            if ("getItinerary".equalsIgnoreCase(action)) {
                response.setContentType("application/json;charset=UTF-8");
                TourDAO tourDAO = null;
                try {
                    tourDAO = new TourDAO();
                    int tourId = parseInt(request.getParameter("tourId"), 0);
                    List<Entities.TourItinerary> itineraries = tourDAO.getItineraryByTourId(tourId);
                    
                    // Nối các ngày thành chuỗi text có dạng: "Ngày 1: Tiêu đề - Mô tả\nNgày 2: ..."
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
                    try (PrintWriter out = response.getWriter()) { // Trả về JSON có cấu trúc: { "text": "Ngày 1: ...\nNgày 2: ..." }
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

            // TH3: Mặc định khi gọi AJAX true không truyền action.
            // Phân nhánh theo servlet path để tách endpoint dữ liệu:
            //   - /admin/dashboard?ajax=true -> chỉ trả {monthlyRevenue} (tiết kiệm payload, tránh over-fetch)
            //   - /admin/tours?ajax=true     -> trả {tours, monthlyRevenue} (admin-tour.js dùng để render bảng)
            String path = request.getServletPath();
            response.setContentType("application/json;charset=UTF-8");
            TourDAO tourDAO = null;
            try {
                tourDAO = new TourDAO();
                double[] monthlyRevenue = tourDAO.getMonthlyRevenueLast6Months();
                long[] revenueLongs = new long[monthlyRevenue.length];// Chuyển đổi từ double sang long để tránh lỗi JSON khi gửi về client (vì JS sẽ đọc số quá lớn có thể bị mất độ chính xác)
                for (int i = 0; i < monthlyRevenue.length; i++) {
                    revenueLongs[i] = (long) monthlyRevenue[i];
                }

                JsonObject root = new JsonObject();
                root.add("monthlyRevenue", new Gson().toJsonTree(revenueLongs));
                root.addProperty("totalRevenue", tourDAO.getTotalRevenue());

                if ("/admin/dashboard".equals(path)) {
                    // Endpoint dashboard: chỉ trả doanh thu, không gửi kèm danh sách tour.
                } else {
                    // Endpoint tours: trả thêm danh sách tour để render bảng quản lý.
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
            } catch (Exception e) {// Nếu có lỗi xảy ra trong quá trình lấy dữ liệu từ DB hoặc xử lý, trả về lỗi 500 và log lỗi chi tiết để dễ dàng debug.
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                try (PrintWriter out = response.getWriter()) {
                    out.print("{\"status\":\"error\",\"message\":\"" + e.getMessage() + "\"}");// Trả về JSON lỗi để client có thể hiển thị thông báo lỗi phù hợp.
                }
            } finally {
                if (tourDAO != null) {
                    tourDAO.close();
                }
            }
        } else {
            // Trường hợp truy cập trực tiếp bằng trình duyệt (không phải AJAX) -> Render trang JSP
            TourDAO tourDAO = null;
            try {
                tourDAO = new TourDAO();
                // Load danh sách category để đổ vào thẻ <select> trong Form Modal thêm/sửa
                List<TourCategory> categories = tourDAO.getAllCategories();
                request.setAttribute("categories", categories);
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (tourDAO != null) {
                    tourDAO.close();
                }
            }
            
            // Servlet này ánh xạ 2 URL, check xem đang vào URL nào để forward đúng file JSP
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
        
        User sessionUser = (User) request.getSession().getAttribute("sessionUser");
        String userRole = (String) request.getSession().getAttribute("userRole");
        if (sessionUser == null || (sessionUser.getRoleId() != 1 && !"Admin".equals(userRole))) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"status\":\"error\",\"message\":\"Access Denied\"}");
            }
            return;
        }

        // Thiết lập bộ mã UTF-8 để đảm bảo khi đọc form tiếng Việt không bị lỗi hiển thị
        response.setContentType("application/json;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        TourDAO tourDAO = null;
        
        try {
            tourDAO = new TourDAO();
            
            // Xử lý Thêm mới (action = add) hoặc Chỉnh sửa (action = edit) tour
            if ("add".equalsIgnoreCase(action) || "edit".equalsIgnoreCase(action)) {// Cả 2 hành động thêm mới và chỉnh sửa đều gửi lên tất cả thông tin tour giống nhau, chỉ khác ở chỗ nếu là edit sẽ có thêm tourId để xác định tour nào cần cập nhật
                Tour tour = new Tour();
                if ("edit".equalsIgnoreCase(action)) {
                    tour.setTourId(parseInt(request.getParameter("tourId"), 0));
                }
                
                // Thu thập tất cả các tham số từ form gửi lên
                int categoryId = parseInt(request.getParameter("categoryId"), 1);
                String tourName = request.getParameter("tourName");
                String description = request.getParameter("description");
                String destination = request.getParameter("destination");
                int durationDays = parseInt(request.getParameter("durationDays"), 1);
                String itinerary = request.getParameter("itinerary");
                String difficultyLevel = request.getParameter("difficultyLevel");
                double basePrice = parseDouble(request.getParameter("basePrice"), 0.0);
                int maxParticipants = parseInt(request.getParameter("maxParticipants"), 20);
                String status = request.getParameter("status"); // Trạng thái: Active, Draft, Disabled
                boolean isFeatured = "true".equalsIgnoreCase(request.getParameter("isFeatured"));
                String languages = request.getParameter("languages");
                int groupSizeMin = parseInt(request.getParameter("groupSizeMin"), 1);
                int groupSizeMax = parseInt(request.getParameter("groupSizeMax"), 20);
                String departureCity = request.getParameter("departureCity");
                
                // ── SERVER-SIDE VALIDATION RULES ──
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
                
                // Kinh độ và vĩ độ phục vụ hiển thị định vị bản đồ (Mapbox/SVG)
                String latStr = request.getParameter("latitude");
                if (latStr != null && !latStr.trim().isEmpty()) {
                    tour.setLatitude(parseDouble(latStr, 0.0));
                } else {
                    tour.setLatitude(null); // Để null nếu admin không điền
                }
                String lngStr = request.getParameter("longitude");
                if (lngStr != null && !lngStr.trim().isEmpty()) {
                    tour.setLongitude(parseDouble(lngStr, 0.0));
                } else {
                    tour.setLongitude(null); // Để null nếu admin không điền
                }
                
                tour.setVideoUrl(request.getParameter("videoUrl"));
                
                boolean success;
                if ("add".equalsIgnoreCase(action)) {
                    // Thêm mới tour và lấy ra ID tự động tăng được sinh từ SQL
                    int generatedId = tourDAO.insertTour(tour);
                    success = generatedId > 0;
                    tour.setTourId(generatedId);
                } else {
                    // Cập nhật thông tin tour đã có
                    success = tourDAO.updateTour(tour);
                }
                
                // Nếu thêm/sửa tour thành công -> Tiến hành cập nhật tiếp các bảng liên quan (Inclusions và Itinerary)
                if (success) {
                    // 1. Lưu danh sách dịch vụ bao gồm & loại trừ (lấy từ các dòng động của form)
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
                    // Hàm saveTourInclusions sẽ DELETE đống dịch vụ cũ của tour này rồi INSERT lại đống mới
                    tourDAO.saveTourInclusions(tour.getTourId(), inclusions);// Cách làm này đơn giản và hiệu quả hơn là phải so sánh từng item cũ - mới để UPDATE hoặc DELETE riêng lẻ, vì số lượng dịch vụ đi kèm thường không nhiều nên việc xóa rồi
                    
                    // 2. Tách lịch trình từ ô Textarea (phân tách dòng bằng regex) nạp vào bảng TourItinerary trong DB
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
                
            } else if ("delete".equalsIgnoreCase(action)) {// Xử lý xóa tour (action = delete)
                // Xử lý xóa tour (action = delete)
                int tourId = parseInt(request.getParameter("tourId"), 0);
                // Thực hiện hard delete: xóa từ các bảng con (Media, Inclusion, FAQ, Booking...) trước khi xóa tour ở bảng chính.
                // Việc xóa này dùng SQL Transaction (commit/rollback) trong DAO để đảm bảo an toàn dữ liệu.
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
                
            } else if ("toggle-status".equalsIgnoreCase(action)) {
                // Xử lý đổi trạng thái nhanh (action = toggle-status) bằng cách click vào Status badge trên bảng
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

    // Helper ép kiểu chuỗi sang int an toàn, nếu null hoặc lỗi format thì lấy giá trị default
    private int parseInt(String value, int defaultVal) {
        try {
            if (value != null && !value.trim().isEmpty()) {
                return Integer.parseInt(value.trim());
            }
        } catch (NumberFormatException e) {}
        return defaultVal;
    }

    // Helper ép kiểu chuỗi sang double an toàn
    private double parseDouble(String value, double defaultVal) {
        try {
            if (value != null && !value.trim().isEmpty()) {
                return Double.parseDouble(value.trim());
            }
        } catch (NumberFormatException e) {}
        return defaultVal;
    }
}
