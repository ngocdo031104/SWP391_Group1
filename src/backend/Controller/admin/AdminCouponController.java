package Controller.admin;

// Người làm: Dương
// Thời gian tạo: 25/06/2026
// Chức năng: Controller quản lý mã giảm giá (Coupon) dành cho Admin (UC24 - Manage Coupon).
// Ý nghĩa: Xử lý ba luồng chính:
//   1. GET danh sách toàn bộ coupon để hiển thị lên trang quản lý.
//   2. GET (AJAX) để kiểm tra trùng mã coupon và lấy chi tiết coupon cho form sửa.
//   3. POST để tạo mới hoặc cập nhật thông tin một coupon.

import Entities.Coupon;
import Entities.User;
import Model.CouponDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.util.List;

@WebServlet(name = "AdminCouponController", urlPatterns = {"/admin/coupons"})
public class AdminCouponController extends HttpServlet {

    // doGet xử lý ba loại request khác nhau dựa vào query parameter "action":
    // - Không có action: Tải tất cả coupon từ DB và hiển thị trang quản lý
    // - action=checkCode: AJAX kiểm tra trùng mã coupon (trả về JSON)
    // - action=getCoupon: AJAX lấy chi tiết một coupon cho form sửa (trả về JSON)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User sessionUser = (User) session.getAttribute("sessionUser");
        String userRole = (String) session.getAttribute("userRole");

        // 1. Kiểm tra quyền truy cập: chỉ Admin mới được vào trang quản lý coupon
        if (sessionUser == null || (sessionUser.getRoleId() != 1 && !"Admin".equals(userRole))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. AJAX: Kiểm tra mã coupon có bị trùng không
        //    excludeId dùng để bỏ qua chính coupon đang sửa, tránh báo lỗi trùng với chính nó
        //    Trả về JSON: {"exists": true} nếu trùng, {"exists": false} nếu không trùng
        if ("checkCode".equals(request.getParameter("action"))) {
            String code = request.getParameter("code");
            String excludeIdStr = request.getParameter("excludeId");
            int excludeId = -1;
            try {
                if (excludeIdStr != null && !excludeIdStr.trim().isEmpty()) {
                    excludeId = Integer.parseInt(excludeIdStr);
                }
            } catch (NumberFormatException ignored) {}
            CouponDAO couponDAO = new CouponDAO();
            boolean exists = code != null && !code.trim().isEmpty()
                    && couponDAO.isCouponCodeExists(code.trim(), excludeId);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"exists\":" + exists + "}");
            return;
        }

        // 3. AJAX: Lấy toàn bộ thông tin chi tiết của một coupon theo ID để điền vào form sửa
        //    Dữ liệu trả về qua buildCouponJson() để đảm bảo JSON hợp lệ, không bị injection
        if ("getCoupon".equals(request.getParameter("action"))) {
            response.setContentType("application/json;charset=UTF-8");
            String idStr = request.getParameter("id");
            try {
                int couponId = Integer.parseInt(idStr);
                CouponDAO couponDAO = new CouponDAO();
                Coupon coupon = couponDAO.getCouponById(couponId);
                if (coupon == null) {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Không tìm thấy coupon.\"}");
                    return;
                }
                response.getWriter().write(buildCouponJson(coupon));
            } catch (NumberFormatException ex) {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"ID không hợp lệ.\"}");
            }
            return;
        }

        // 4. Request thông thường: Tải toàn bộ danh sách coupon và chuyển sang trang quản lý
        CouponDAO couponDAO = new CouponDAO();
        List<Coupon> coupons = couponDAO.getAllCoupons();
        request.setAttribute("coupons", coupons);
        request.getRequestDispatcher("/admin/coupon-management.jsp").forward(request, response);
    }

    // doPost xử lý tạo mới hoặc cập nhật coupon từ form trong modal
    // Phân biệt tạo mới / cập nhật qua tham số couponId: rỗng = tạo mới, có giá trị = cập nhật
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User sessionUser = (User) session.getAttribute("sessionUser");
        String userRole = (String) session.getAttribute("userRole");

        // 1. Kiểm tra quyền truy cập: chỉ Admin mới được tạo/sửa coupon
        if (sessionUser == null || (sessionUser.getRoleId() != 1 && !"Admin".equals(userRole))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // 2. Đọc toàn bộ dữ liệu từ form
            String couponIdStr = request.getParameter("couponId");
            String couponCode = request.getParameter("couponCode");
            String discountType = request.getParameter("discountType");
            double discountValue = Double.parseDouble(request.getParameter("discountValue"));
            double minOrderAmount = Double.parseDouble(request.getParameter("minOrderAmount"));
            String maxDiscountStr = request.getParameter("maxDiscountAmount");
            // maxDiscountAmount là optional: để trống = null (không giới hạn số tiền giảm tối đa)
            Double maxDiscountAmount = (maxDiscountStr != null && !maxDiscountStr.trim().isEmpty()) ? Double.parseDouble(maxDiscountStr) : null;
            
            // 3. Validate nghiệp vụ cho coupon loại Percentage:
            //    - Bắt buộc nhập giảm tối đa để tránh khách được giảm vô giới hạn
            //    - Phần trăm giảm không được vượt quá 100%
            if ("Percentage".equals(discountType)) {
                if (maxDiscountAmount == null) {
                    session.setAttribute("errorMessage", "Vui lòng nhập số tiền Giảm Tối Đa khi tạo mã giảm giá theo Phần Trăm.");
                    response.sendRedirect(request.getContextPath() + "/admin/coupons");
                    return;
                }
                if (discountValue > 100) {
                    session.setAttribute("errorMessage", "Giá trị giảm theo phần trăm không được vượt quá 100%.");
                    response.sendRedirect(request.getContextPath() + "/admin/coupons");
                    return;
                }
            }

            // maxUses là optional: để trống = null (không giới hạn số lần sử dụng)
            String maxUsesStr = request.getParameter("maxUses");
            Integer maxUses = (maxUsesStr != null && !maxUsesStr.trim().isEmpty()) ? Integer.parseInt(maxUsesStr) : null;
            Date startDate = Date.valueOf(request.getParameter("startDate"));
            Date endDate = Date.valueOf(request.getParameter("endDate"));
            // isActive: checkbox trong form gửi "on" khi tick, "true" khi được gửi qua AJAX
            boolean isActive = "on".equals(request.getParameter("isActive")) || "true".equals(request.getParameter("isActive"));

            // 4. Khởi tạo entity Coupon với dữ liệu đã đọc
            Coupon coupon = new Coupon();
            coupon.setCouponCode(couponCode);
            coupon.setDiscountType(discountType);
            coupon.setDiscountValue(discountValue);
            coupon.setMinOrderAmount(minOrderAmount);
            coupon.setMaxDiscountAmount(maxDiscountAmount);
            coupon.setMaxUses(maxUses);
            coupon.setStartDate(startDate);
            coupon.setEndDate(endDate);
            coupon.setIsActive(isActive);

            CouponDAO couponDAO = new CouponDAO();

            // 5a. Nhánh TẠO MỚI: couponId rỗng nghĩa là form không có ID được điền vào
            if (couponIdStr == null || couponIdStr.trim().isEmpty()) {
                // Kiểm tra trùng mã trước khi insert (excludeId = -1: không loại trừ coupon nào)
                if (couponDAO.isCouponCodeExists(couponCode, -1)) {
                    session.setAttribute("errorMessage", "Mã coupon \"" + sanitize(couponCode) + "\" đã tồn tại. Vui lòng dùng mã khác.");
                    response.sendRedirect(request.getContextPath() + "/admin/coupons");
                    return;
                }
                // Ghi lại người tạo coupon để theo dõi lịch sử
                User admin = (User) session.getAttribute("sessionUser");
                if (admin != null) {
                    coupon.setCreatedBy(admin.getUserId());
                }
                boolean created = couponDAO.createCoupon(coupon);
                if (created) {
                    session.setAttribute("successMessage", "Thêm mới coupon thành công!");
                } else {
                    session.setAttribute("errorMessage", "Thêm mới coupon thất bại. Vui lòng kiểm tra lại Cơ Sở Dữ Liệu (có thể thiếu cột MaxDiscountAmount).");
                }
            } else {
                // 5b. Nhánh CẬP NHẬT: couponId có giá trị nghĩa là đang sửa coupon đã có
                //     excludeId = couponId để tránh báo lỗi trùng chính nó
                int couponId = Integer.parseInt(couponIdStr);
                if (couponDAO.isCouponCodeExists(couponCode, couponId)) {
                    session.setAttribute("errorMessage", "Mã coupon \"" + sanitize(couponCode) + "\" đã tồn tại. Vui lòng dùng mã khác.");
                    response.sendRedirect(request.getContextPath() + "/admin/coupons");
                    return;
                }
                coupon.setCouponId(couponId);
                boolean updated = couponDAO.updateCoupon(coupon);
                if (updated) {
                    session.setAttribute("successMessage", "Cập nhật coupon thành công!");
                } else {
                    session.setAttribute("errorMessage", "Cập nhật coupon thất bại. Vui lòng kiểm tra lại Cơ Sở Dữ Liệu.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Đã xảy ra lỗi khi lưu coupon. Vui lòng kiểm tra lại thông tin.");
        }

        // 6. Luôn redirect về danh sách sau khi xử lý để tránh submit trùng khi F5
        response.sendRedirect(request.getContextPath() + "/admin/coupons");
    }

    // Xây dựng chuỗi JSON đầy đủ của một Coupon để trả về cho AJAX request từ frontend.
    // Dùng jsonString() để escape ký tự đặc biệt, tránh lỗi JSON parse và tấn công XSS.
    private String buildCouponJson(Coupon c) {
        StringBuilder sb = new StringBuilder(256);
        sb.append("{\"status\":\"success\",\"coupon\":{");
        sb.append("\"couponId\":").append(c.getCouponId()).append(',');
        sb.append("\"couponCode\":").append(jsonString(c.getCouponCode())).append(',');
        sb.append("\"discountType\":").append(jsonString(c.getDiscountType())).append(',');
        sb.append("\"discountValue\":").append(c.getDiscountValue()).append(',');
        sb.append("\"minOrderAmount\":").append(c.getMinOrderAmount()).append(',');
        sb.append("\"maxDiscountAmount\":")
          .append(c.getMaxDiscountAmount() == null ? "null" : String.valueOf(c.getMaxDiscountAmount())).append(',');
        sb.append("\"maxUses\":")
          .append(c.getMaxUses() == null ? "null" : String.valueOf(c.getMaxUses())).append(',');
        sb.append("\"startDate\":\"")
          .append(c.getStartDate() == null ? "" : c.getStartDate().toString()).append("\",");
        sb.append("\"endDate\":\"")
          .append(c.getEndDate() == null ? "" : c.getEndDate().toString()).append("\",");
        sb.append("\"isActive\":").append(c.isIsActive());
        sb.append("}}");
        return sb.toString();
    }

    // Escape toàn bộ ký tự đặc biệt của chuỗi Java thành ký tự hợp lệ trong JSON.
    // Xử lý: dấu nháy kép, gạch chéo ngược, và các ký tự điều khiển (control characters).
    private String jsonString(String s) {
        if (s == null) return "null";
        StringBuilder sb = new StringBuilder(s.length() + 2);
        sb.append('"');
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            switch (ch) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\b': sb.append("\\b"); break;
                case '\f': sb.append("\\f"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default:
                    if (ch < 0x20) {
                        sb.append(String.format("\\u%04x", (int) ch));
                    } else {
                        sb.append(ch);
                    }
            }
        }
        sb.append('"');
        return sb.toString();
    }

    // Làm sạch chuỗi trước khi nối vào thông báo lỗi để tránh XSS.
    // Thay thế các ký tự nguy hiểm (<, >, ", ', &) và ký tự điều khiển bằng dấu '?'.
    // Đây là lớp bảo vệ thứ 2; lớp 1 là dùng <c:out> khi render ở JSP.
    private String sanitize(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder(s.length());
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            if (ch == '<' || ch == '>' || ch == '"' || ch == '\'' || ch == '&' || ch < 0x20) {
                sb.append('?');
            } else {
                sb.append(ch);
            }
        }
        return sb.toString();
    }
}
