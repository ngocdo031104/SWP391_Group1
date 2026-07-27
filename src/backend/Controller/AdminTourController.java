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
     * HÀM: doGet
     * - Tác dụng: Xử lý yêu cầu HTTP GET cho 2 URL "/admin/tours" và "/admin/dashboard".
     * - Chức năng chính:
     *   1. Kiểm tra quyền Admin (chỉ roleId=1 hoặc userRole="Admin").
     *   2. Nếu là AJAX (?ajax=true):
     *      - action=getInclusions: Trả về JSON danh sách dịch vụ kèm theo của 1 tour.
     *      - action=getItinerary: Trả về lịch trình tour dưới dạng chuỗi text gộp các ngày.
     *      - Mặc định: Trả JSON doanh thu 6 tháng + tổng doanh thu (và danh sách tour nếu là /admin/tours).
     *   3. Nếu là GET thường: Load danh sách category rồi forward sang dashboard.jsp hoặc tourmanagement.jsp.
     * - Nối đi đâu: Forward sang "/admin/dashboard.jsp" hoặc "/admin/tourmanagement.jsp" tùy URL truy cập.
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
        // Nếu chưa đăng nhập -> đẩy về trang login
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        // Nếu không phải Admin -> đẩy về trang analytics (chỉ xem không sửa được)
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
                    // DAO lấy list TourInclusion theo tourId (1 row = 1 dịch vụ INCLUDED/EXCLUDED)
                    List<Entities.TourInclusion> inclusions = tourDAO.getInclusionsByTourId(tourId);
                    
                    // Serialize List -> JSON để JS phía client nhận và đổ ngược vào form edit
                    String json = new Gson().toJson(inclusions);
                    try (PrintWriter out = response.getWriter()) {
                        out.print(json);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    // Trả mảng rỗng nếu lỗi để JS không crash
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
                    // DB lưu itinerary theo từng dòng (1 ngày = 1 row) -> nạp về List
                    List<Entities.TourItinerary> itineraries = tourDAO.getItineraryByTourId(tourId);
                    
                    // Nối các ngày thành chuỗi text để hiển thị gọn trong 1 textarea
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
                    // Đóng gói vào key "text" để JS đọc: response.text -> gán vào textarea
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
                // Lấy doanh thu 6 tháng gần nhất để vẽ biểu đồ line chart
                double[] monthlyRevenue = tourDAO.getMonthlyRevenueLast6Months();
                long[] revenueLongs = new long[monthlyRevenue.length];
                // Ép double -> long để Gson serialize số nguyên (không có .0)
                for (int i = 0; i < monthlyRevenue.length; i++) {
                    revenueLongs[i] = (long) monthlyRevenue[i];
                }

                JsonObject root = new JsonObject();
                root.add("monthlyRevenue", new Gson().toJsonTree(revenueLongs));
                root.addProperty("totalRevenue", tourDAO.getTotalRevenue());

                if ("/admin/dashboard".equals(path)) {
                    // Trang Dashboard chỉ cần dữ liệu doanh thu -> KHÔNG query thêm tour
                } else {
                    // Trang Quản lý tour -> lấy thêm toàn bộ danh sách tour để hiển thị bảng
                    List<Tour> tours = tourDAO.getAllToursAdmin();
                    JsonArray toursArray = new JsonArray();
                    for (Tour t : tours) {
                        // Convert từng Tour object -> JSON Object
                        JsonObject tourJson = new Gson().toJsonTree(t).getAsJsonObject();
                        // Bổ sung tên category (giải quyết vấn đề lazy load khi client chỉ cần tên)
                        tourJson.addProperty("categoryName", t.getCategory() != null ? t.getCategory().getCategoryName() : "Khác");
                        // Chỉ lấy phần ngày (YYYY-MM-DD), bỏ phần giờ cho gọn
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
                // Trả JSON lỗi để JS biết và hiển thị toast lỗi
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
                // Load danh sách category để đổ vào dropdown "Chọn danh mục" trong form tạo/sửa tour
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
                // Forward sang trang Dashboard (biểu đồ doanh thu)
                request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
            } else {
                // Forward sang trang quản lý tour (bảng CRUD)
                request.getRequestDispatcher("/admin/tourmanagement.jsp").forward(request, response);
            }
        }
    }

    /**
     * HÀM: doPost
     * - Tác dụng: Xử lý yêu cầu HTTP POST để thay đổi dữ liệu Tour (ghi/xóa/cập nhật).
     * - Hỗ trợ 4 action:
     *   1. action="add":    Thêm mới 1 Tour + đồng bộ bảng TourInclusion, TourItinerary.
     *   2. action="edit":   Cập nhật 1 Tour đã có + đồng bộ 2 bảng phụ.
     *   3. action="delete": Xóa Tour (cascade các bảng liên quan).
     *   4. action="toggle-status": Bật/Tắt nhanh trạng thái hiển thị (Active/Inactive).
     * - Nối đi đâu: Trả JSON về client (status + message + tourId). Không forward JSP.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Kiểm tra quyền hạn Admin - nếu không có quyền trả về 403 Forbidden
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
        
        // action quyết định sẽ làm gì: add / edit / delete / toggle-status
        String action = request.getParameter("action");
        TourDAO tourDAO = null;
        
        try {
            tourDAO = new TourDAO();
            
            // 2. Thêm mới hoặc Cập nhật thông tin Tour
            if ("add".equalsIgnoreCase(action) || "edit".equalsIgnoreCase(action)) {
                Tour tour = new Tour();
                // Nếu là edit -> set tourId để biết update bản ghi nào
                if ("edit".equalsIgnoreCase(action)) {
                    tour.setTourId(parseInt(request.getParameter("tourId"), 0));
                }
                
                // Đọc toàn bộ tham số từ form gửi lên
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
                
                // Thiết lập toạ độ bản đồ (latitude/longitude)
                // Nếu admin không nhập -> set NULL để tránh hiển thị (0,0) sai trên map
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
                
                // Phân nhánh add/edit:
                // - add: insertTour() trả về ID mới sinh từ DB (identity)
                // - edit: updateTour() trả về boolean thành công/thất bại
                boolean success;
                if ("add".equalsIgnoreCase(action)) {
                    int generatedId = tourDAO.insertTour(tour);
                    success = generatedId > 0;
                    tour.setTourId(generatedId);
                } else {
                    success = tourDAO.updateTour(tour);
                }
                
                // Đồng bộ hóa 2 bảng chi tiết liên quan (chỉ khi lưu Tour thành công)
                if (success) {
                    // Bước A: Cập nhật bảng dịch vụ kèm theo (Inclusions)
                    // Form gửi mảng incType[]/incIcon[]/incService[] tương ứng các dòng
                    String[] incTypes = request.getParameterValues("incType");
                    String[] incIcons = request.getParameterValues("incIcon");
                    String[] incServices = request.getParameterValues("incService");
                    
                    // Build List<TourInclusion> từ mảng form gửi lên
                    List<Entities.TourInclusion> inclusions = new java.util.ArrayList<>();
                    if (incServices != null) {
                        for (int i = 0; i < incServices.length; i++) {
                            // Bỏ qua dòng trống
                            if (incServices[i] != null && !incServices[i].trim().isEmpty()) {
                                Entities.TourInclusion item = new Entities.TourInclusion();
                                item.setTourId(tour.getTourId());
                                // Default "INCLUDED" nếu form thiếu trường incType
                                item.setInclusionType(incTypes != null && i < incTypes.length ? incTypes[i] : "INCLUDED");
                                // Default "sparkles" nếu form thiếu trường incIcon
                                item.setIconName(incIcons != null && i < incIcons.length ? incIcons[i] : "sparkles");
                                item.setServiceName(incServices[i].trim());
                                item.setSortOrder(i); // thứ tự hiển thị
                                inclusions.add(item);
                            }
                        }
                    }
                    // DAO sẽ xóa hết inclusions cũ của tour này rồi insert lại (delete-then-insert)
                    tourDAO.saveTourInclusions(tour.getTourId(), inclusions);
                    
                    // Bước B: Cập nhật bảng lịch trình chi tiết (Itinerary)
                    // Tách chuỗi "Ngày 1: ...\nNgày 2: ..." thành từng row
                    tourDAO.syncTourItineraryFromText(tour.getTourId(), tour.getItinerary());
                }
                
                // Trả JSON kết quả về client để JS hiển thị toast
                Gson gson = new Gson();
                try (PrintWriter out = response.getWriter()) {
                    JsonObject resp = new JsonObject();
                    if (success) {
                        resp.addProperty("status", "success");
                        resp.addProperty("message", "Lưu thông tin tour thành công!");
                        resp.addProperty("tourId", tour.getTourId()); // ID mới (cho trường hợp add)
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
                // DAO thực hiện transaction xóa + cascade các bảng liên quan (inclusion, itinerary, ...)
                // Trả false nếu có ràng buộc FK (booking, schedule đang tham chiếu)
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
            // 4. Thay đổi trạng thái hiển thị nhanh (Bật/Tắt) không cần reload trang
            else if ("toggle-status".equalsIgnoreCase(action)) {
                int tourId = parseInt(request.getParameter("tourId"), 0);
                String status = request.getParameter("status");
                // DAO chỉ update 1 field Status của Tour
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
                // Action không hợp lệ -> trả lỗi
                Gson gson = new Gson();
                try (PrintWriter out = response.getWriter()) {
                    JsonObject resp = new JsonObject();
                    resp.addProperty("status", "error");
                    resp.addProperty("message", "Hành động không xác định.");
                    out.print(gson.toJson(resp));
                }
            }
            
        } catch (Exception e) {
            // Bắt mọi Exception phát sinh trong quá trình xử lý (VD: SQL exception, NullPointer, ...)
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
            // Khối finally LUÔN LUÔN chạy dù thành công hay lỗi
            // -> Đóng connection DB để giải phóng tài nguyên, tránh leak connection pool
            if (tourDAO != null) {
                tourDAO.close();
            }
        }
    }

    /**
     * HÀM: parseInt
     * - Tác dụng: Ép kiểu chuỗi sang int một cách an toàn, tránh NumberFormatException.
     * - Tham số:
     *   + value: chuỗi cần ép (VD: "123").
     *   + defaultVal: giá trị trả về nếu value null/rỗng/lỗi format.
     * - Nối đi đâu: Được gọi nhiều lần trong doPost() để parse các tham số số từ form.
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
     * HÀM: parseDouble
     * - Tác dụng: Ép kiểu chuỗi sang double an toàn (dùng cho price, lat, lng).
     * - Tham số:
     *   + value: chuỗi cần ép (VD: "1500000.5").
     *   + defaultVal: giá trị trả về nếu value null/rỗng/lỗi format.
     * - Nối đi đâu: Được gọi trong doPost() để parse basePrice, latitude, longitude.
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
