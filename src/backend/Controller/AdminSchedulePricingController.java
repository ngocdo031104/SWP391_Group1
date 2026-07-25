/*
 * Màn hình 21: Manage Tour Schedule and Pricing - Quản lý lịch khởi hành & giá
 * Tác giả: Dương Quang Sơn
 * MSSV: HE186525
 * Ngày tạo: 2026-07-21
 */
package Controller;

import Entities.Coupon;
import Entities.Tour;
import Entities.TourSchedule;
import Entities.User;
import Entities.GuideProfile;
import Model.CouponDAO;
import Model.TourDAO;
import Model.TourScheduleDAO;
import Model.GuideDAO;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminSchedulePricingController", urlPatterns = {"/admin/schedules"})
public class AdminSchedulePricingController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminSchedulePricingController.class.getName());

    /**
     * Xử lý yêu cầu HTTP GET.
     * 1. Kiểm tra quyền hạn Admin/Super Admin.
     * 2. Phục vụ yêu cầu AJAX:
     *    - action = "getSchedules": Trả về JSON danh sách lịch trình của một tour xác định.
     *    - action = "getCoupons": Trả về JSON toàn bộ danh sách mã giảm giá.
     * 3. Phục vụ yêu cầu GET thông thường:
     *    - Đọc dữ liệu từ DB (Tours, Guides, Coupons) đưa vào request attribute.
     *    - Chuyển tiếp (forward) yêu cầu hiển thị trang JSP quản lý lịch trình & giá.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Kiểm tra quyền Admin
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

        // 2. Xử lý các yêu cầu AJAX lấy dữ liệu
        String ajax = request.getParameter("ajax");
        if ("true".equalsIgnoreCase(ajax)) {
            response.setContentType("application/json;charset=UTF-8");
            String action = request.getParameter("action");

            // Lấy danh sách lịch trình của Tour
            if ("getSchedules".equalsIgnoreCase(action)) {
                int tourId = parseInt(request.getParameter("tourId"), 0);
                TourScheduleDAO scheduleDAO = null;
                try {
                    scheduleDAO = new TourScheduleDAO();
                    List<TourSchedule> schedules = scheduleDAO.getSchedulesByTourIdForAdmin(tourId);
                    
                    Gson gson = new Gson();
                    JsonArray jsonArray = new JsonArray();
                    for (TourSchedule s : schedules) {
                        JsonObject sJson = gson.toJsonTree(s).getAsJsonObject();
                        // Trả về thêm tên HDV để hiển thị trực quan
                        sJson.addProperty("guideName", s.getGuide() != null ? s.getGuide().getFullName() : "Chưa phân công");
                        sJson.addProperty("departureStr", s.getDepartureDate().toString());
                        sJson.addProperty("returnStr", s.getReturnDate().toString());
                        jsonArray.add(sJson);
                    }
                    
                    try (PrintWriter out = response.getWriter()) {
                        out.print(gson.toJson(jsonArray));
                    }
                } catch (Exception e) {
                    LOGGER.log(Level.SEVERE, "getSchedules AJAX error", e);
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    try (PrintWriter out = response.getWriter()) {
                        out.print("[]");
                    }
                } finally {
                    if (scheduleDAO != null) scheduleDAO.close();
                }
                return;
            }

            // Lấy danh sách mã giảm giá
            if ("getCoupons".equalsIgnoreCase(action)) {
                CouponDAO couponDAO = null;
                try {
                    couponDAO = new CouponDAO();
                    List<Coupon> coupons = couponDAO.getAllCoupons();
                    String json = new Gson().toJson(coupons);
                    try (PrintWriter out = response.getWriter()) {
                        out.print(json);
                    }
                } catch (Exception e) {
                    LOGGER.log(Level.SEVERE, "getCoupons AJAX error", e);
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    try (PrintWriter out = response.getWriter()) {
                        out.print("[]");
                    }
                } finally {
                    if (couponDAO != null) couponDAO.close();
                }
                return;
            }
        }

        // 3. Tải trang thông thường: Truy vấn danh sách tour, hướng dẫn viên và coupon để hiển thị lên Form
        TourDAO tourDAO = null;
        GuideDAO guideDAO = null;
        CouponDAO couponDAO = null;
        try {
            tourDAO = new TourDAO();
            guideDAO = new GuideDAO();
            couponDAO = new CouponDAO();

            List<Tour> tours = tourDAO.getAllToursAdmin();
            List<GuideProfile> guides = guideDAO.getAllGuides();
            List<Coupon> coupons = couponDAO.getAllCoupons();

            request.setAttribute("tours", tours);
            request.setAttribute("guides", guides);
            request.setAttribute("coupons", coupons);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Loading schedules admin page error", e);
        } finally {
            if (tourDAO != null) tourDAO.close();
            if (guideDAO != null) guideDAO.close();
            if (couponDAO != null) couponDAO.close();
        }

        request.getRequestDispatcher("/admin/schedules-pricing.jsp").forward(request, response);
    }

    /**
     * Xử lý các yêu cầu HTTP POST để cập nhật cơ sở dữ liệu.
     * Hỗ trợ các chức năng:
     * - Quản lý Lịch trình (Schedule): Thêm (addSchedule), Sửa (editSchedule), Xóa (deleteSchedule).
     * - Quản lý Mã giảm giá (Coupon): Thêm (addCoupon), Sửa (editCoupon), Bật/Tắt (toggleCouponStatus), Xóa (deleteCoupon).
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        // 1. Kiểm tra quyền hạn Admin
        User sessionUser = (User) request.getSession().getAttribute("sessionUser");
        String userRole = (String) request.getSession().getAttribute("userRole");
        if (sessionUser == null || (sessionUser.getRoleId() != 1 && !"Admin".equals(userRole))) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"status\":\"error\",\"message\":\"Không có quyền thực hiện hành động này.\"}");
            }
            return;
        }

        String action = request.getParameter("action");
        JsonObject result = new JsonObject();
        Gson gson = new Gson();

        // 2. Thêm hoặc cập nhật một Lịch trình Tour (Schedule)
        if ("addSchedule".equalsIgnoreCase(action) || "editSchedule".equalsIgnoreCase(action)) {
            TourScheduleDAO scheduleDAO = null;
            try {
                scheduleDAO = new TourScheduleDAO();
                
                int tourId = parseInt(request.getParameter("tourId"), 0);
                String depStr = request.getParameter("departureDate");
                String retStr = request.getParameter("returnDate");
                int totalSeats = parseInt(request.getParameter("totalSeats"), 0);
                String priceAdultParam = request.getParameter("priceAdult");
                String priceChildParam = request.getParameter("priceChild");
                String priceInfantParam = request.getParameter("priceInfant");

                double priceAdult = parseDouble(priceAdultParam, 0.0);
                double priceChild = (priceChildParam != null && !priceChildParam.trim().isEmpty()) ? parseDouble(priceChildParam, 0.0) : 0.0;
                double priceInfant = (priceInfantParam != null && !priceInfantParam.trim().isEmpty()) ? parseDouble(priceInfantParam, 0.0) : 0.0;
                String transportation = request.getParameter("transportation");
                String status = request.getParameter("status"); // Booking status: Open, Full, Closed, Cancelled
                int guideId = parseInt(request.getParameter("guideId"), 0);
                String tourStatus = request.getParameter("tourStatus"); // Tour trip status: Scheduled, InProgress, Completed, Cancelled

                // Kiểm định tính hợp lệ của dữ liệu đầu vào
                if (tourId <= 0 || depStr == null || retStr == null || totalSeats <= 0 || priceAdult <= 0 || priceChild < 0 || priceInfant < 0) {
                    result.addProperty("status", "error");
                    result.addProperty("message", "Vui lòng nhập đầy đủ thông tin hợp lệ (Số chỗ > 0, giá người lớn phải > 0 và các giá không được âm).");
                } else {
                    Date departureDate = Date.valueOf(depStr);
                    Date returnDate = Date.valueOf(retStr);

                    if (returnDate.before(departureDate)) {
                        result.addProperty("status", "error");
                        result.addProperty("message", "Ngày về không được trước ngày khởi hành.");
                    } else {
                        TourSchedule sched = new TourSchedule();
                        sched.setTourId(tourId);
                        sched.setDepartureDate(departureDate);
                        sched.setReturnDate(returnDate);
                        sched.setTotalSeats(totalSeats);
                        sched.setPriceAdult(priceAdult);
                        sched.setPriceChild(priceChild);
                        sched.setPriceInfant(priceInfant);
                        sched.setTransportation(transportation);
                        sched.setStatus(status);
                        sched.setTourStatus(tourStatus != null ? tourStatus : "Scheduled");
                        if (guideId > 0) {
                            sched.setGuideId(guideId);
                        } else {
                            sched.setGuideId(null);
                        }

                        boolean success = false;
                        if ("addSchedule".equalsIgnoreCase(action)) {
                            sched.setAvailableSeats(totalSeats); // Mặc định số chỗ trống ban đầu bằng tổng số chỗ
                            int newId = scheduleDAO.insertSchedule(sched);
                            success = newId > 0;
                        } else {
                            int scheduleId = parseInt(request.getParameter("scheduleId"), 0);
                            sched.setScheduleId(scheduleId);
                            // Lấy số chỗ còn trống được gửi từ client hoặc tự cập nhật
                            int availableSeats = parseInt(request.getParameter("availableSeats"), totalSeats);
                            if (availableSeats > totalSeats) {
                                availableSeats = totalSeats;
                            }
                            sched.setAvailableSeats(availableSeats);
                            success = scheduleDAO.updateSchedule(sched);
                        }

                        if (success) {
                            result.addProperty("status", "success");
                            result.addProperty("message", "Lưu thông tin lịch trình thành công!");
                        } else {
                            result.addProperty("status", "error");
                            result.addProperty("message", "Lưu thông tin lịch trình thất bại.");
                        }
                    }
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Save schedule error", e);
                result.addProperty("status", "error");
                result.addProperty("message", "Lỗi xử lý dữ liệu: " + e.getMessage());
            } finally {
                if (scheduleDAO != null) scheduleDAO.close();
            }
        } 
        // 3. Xử lý yêu cầu Xóa một Lịch trình
        else if ("deleteSchedule".equalsIgnoreCase(action)) {
            TourScheduleDAO scheduleDAO = null;
            try {
                scheduleDAO = new TourScheduleDAO();
                int scheduleId = parseInt(request.getParameter("scheduleId"), 0);
                TourSchedule schedule = scheduleDAO.getScheduleById(scheduleId);
                if (schedule == null) {
                    result.addProperty("status", "error");
                    result.addProperty("message", "Lịch trình không tồn tại.");
                } else {
                    String tourStatus = schedule.getTourStatus();
                    // Chỉ cho phép xóa lịch trình nếu chuyến đi chưa diễn ra hoặc đã hoàn tất/hủy bỏ
                    if (tourStatus != null && !tourStatus.equalsIgnoreCase("Preparing") 
                            && !tourStatus.equalsIgnoreCase("Completed") 
                            && !tourStatus.equalsIgnoreCase("Cancelled")) {
                        
                        String statusName = tourStatus;
                        if ("Scheduled".equalsIgnoreCase(tourStatus)) statusName = "Scheduled (Lên lịch khởi hành)";
                        else if ("InProgress".equalsIgnoreCase(tourStatus)) statusName = "InProgress (Đang đi)";
                        
                        result.addProperty("status", "error");
                        result.addProperty("message", "Không thể xóa lịch khởi hành đang ở trạng thái '" + statusName + "'. Chỉ có thể xóa lịch khởi hành ở trạng thái Chuẩn bị, Hoàn thành hoặc Hủy đoàn.");
                    } else {
                        boolean success = scheduleDAO.deleteSchedule(scheduleId);
                        if (success) {
                            result.addProperty("status", "success");
                            result.addProperty("message", "Xóa lịch trình thành công!");
                        } else {
                            result.addProperty("status", "error");
                            result.addProperty("message", "Không thể xóa lịch trình này (đang có đơn hàng hoặc liên kết dữ liệu).");
                        }
                    }
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Delete schedule error", e);
                result.addProperty("status", "error");
                result.addProperty("message", "Lỗi khi xóa lịch trình: " + e.getMessage());
            } finally {
                if (scheduleDAO != null) scheduleDAO.close();
            }
        } 
        // 4. Thêm hoặc Sửa thông tin mã giảm giá (Coupon)
        else if ("addCoupon".equalsIgnoreCase(action) || "editCoupon".equalsIgnoreCase(action)) {
            CouponDAO couponDAO = null;
            try {
                couponDAO = new CouponDAO();
                String code = request.getParameter("couponCode");
                String discType = request.getParameter("discountType"); // Percentage (Phần trăm) hoặc Fixed (Số tiền cố định)
                double discVal = parseDouble(request.getParameter("discountValue"), 0.0);
                double minOrder = parseDouble(request.getParameter("minOrderAmount"), 0.0); // Giá trị đơn hàng tối thiểu
                String maxUsesStr = request.getParameter("maxUses"); // Số lượt sử dụng tối đa
                Integer maxUses = (maxUsesStr == null || maxUsesStr.trim().isEmpty()) ? null : parseInt(maxUsesStr, 0);
                String startStr = request.getParameter("startDate");
                String endStr = request.getParameter("endDate");
                boolean isActive = "true".equalsIgnoreCase(request.getParameter("isActive"));

                if (code == null || code.trim().isEmpty() || discType == null || discVal <= 0 || startStr == null || endStr == null) {
                    result.addProperty("status", "error");
                    result.addProperty("message", "Vui lòng nhập đầy đủ thông tin hợp lệ.");
                } else {
                    Date startDate = Date.valueOf(startStr);
                    Date endDate = Date.valueOf(endStr);

                    if (endDate.before(startDate)) {
                        result.addProperty("status", "error");
                        result.addProperty("message", "Ngày kết thúc không được trước ngày bắt đầu.");
                    } else if ("Percentage".equalsIgnoreCase(discType) && discVal > 100) {
                        result.addProperty("status", "error");
                        result.addProperty("message", "Giá trị giảm theo phần trăm không được vượt quá 100%.");
                    } else {
                        Coupon coupon = new Coupon();
                        coupon.setCouponCode(code.trim().toUpperCase());
                        coupon.setDiscountType(discType);
                        coupon.setDiscountValue(discVal);
                        coupon.setMinOrderAmount(minOrder);
                        coupon.setMaxUses(maxUses);
                        coupon.setStartDate(startDate);
                        coupon.setEndDate(endDate);
                        coupon.setIsActive(isActive);
                        coupon.setCreatedBy(sessionUser.getUserId());

                        boolean success = false;
                        if ("addCoupon".equalsIgnoreCase(action)) {
                            success = couponDAO.createCoupon(coupon);
                        } else {
                            int couponId = parseInt(request.getParameter("couponId"), 0);
                            coupon.setCouponId(couponId);
                            success = couponDAO.updateCoupon(coupon);
                        }

                        if (success) {
                            result.addProperty("status", "success");
                            result.addProperty("message", "Lưu thông tin mã giảm giá thành công!");
                        } else {
                            result.addProperty("status", "error");
                            result.addProperty("message", "Lưu thông tin mã giảm giá thất bại (Mã có thể đã tồn tại).");
                        }
                    }
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Save coupon error", e);
                result.addProperty("status", "error");
                result.addProperty("message", "Lỗi xử lý dữ liệu: " + e.getMessage());
            } finally {
                if (couponDAO != null) couponDAO.close();
            }
        } 
        // 5. Bật/Tắt kích hoạt trạng thái sử dụng của Mã giảm giá
        else if ("toggleCouponStatus".equalsIgnoreCase(action)) {
            CouponDAO couponDAO = null;
            try {
                couponDAO = new CouponDAO();
                int couponId = parseInt(request.getParameter("couponId"), 0);
                boolean isActive = "true".equalsIgnoreCase(request.getParameter("isActive"));
                boolean success = couponDAO.toggleStatus(couponId, isActive);
                if (success) {
                    result.addProperty("status", "success");
                    result.addProperty("message", "Cập nhật trạng thái thành công!");
                } else {
                    result.addProperty("status", "error");
                    result.addProperty("message", "Không thể cập nhật trạng thái mã giảm giá.");
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Toggle coupon status error", e);
                result.addProperty("status", "error");
                result.addProperty("message", "Lỗi hệ thống: " + e.getMessage());
            } finally {
                if (couponDAO != null) couponDAO.close();
            }
        } 
        // 6. Xóa mã giảm giá
        else if ("deleteCoupon".equalsIgnoreCase(action)) {
            CouponDAO couponDAO = null;
            try {
                couponDAO = new CouponDAO();
                int couponId = parseInt(request.getParameter("couponId"), 0);
                boolean success = couponDAO.deleteCoupon(couponId);
                if (success) {
                    result.addProperty("status", "success");
                    result.addProperty("message", "Xóa mã giảm giá thành công!");
                } else {
                    result.addProperty("status", "error");
                    result.addProperty("message", "Không thể xóa mã giảm giá này (đang được áp dụng trong đơn hàng).");
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Delete coupon error", e);
                result.addProperty("status", "error");
                result.addProperty("message", "Lỗi khi xóa mã giảm giá: " + e.getMessage());
            } finally {
                if (couponDAO != null) couponDAO.close();
            }
        } else {
            result.addProperty("status", "error");
            result.addProperty("message", "Hành động không hợp lệ.");
        }

        try (PrintWriter out = response.getWriter()) {
            out.print(gson.toJson(result));
        }
    }

    /**
     * Chuyển chuỗi dạng String thành số nguyên int một cách an toàn.
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
     * Chuyển chuỗi dạng String thành số thực double một cách an toàn.
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
