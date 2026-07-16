package Controller.admin;

// Dương làm đoạn này
// Thời gian tạo: 25/06/2026
// Chức năng: Controller quản lý Coupon cho Admin.
// Ý nghĩa: Xử lý hiển thị danh sách coupon (GET) và thêm mới/cập nhật coupon (POST).

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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User sessionUser = (User) session.getAttribute("sessionUser");
        String userRole = (String) session.getAttribute("userRole");

        // Kiểm tra quyền Admin
        if (sessionUser == null || (sessionUser.getRoleId() != 1 && !"Admin".equals(userRole))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // AJAX endpoint: kiểm tra trùng mã coupon — trả về JSON {"exists": true/false}
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

        CouponDAO couponDAO = new CouponDAO();
        List<Coupon> coupons = couponDAO.getAllCoupons();
        request.setAttribute("coupons", coupons);
        request.getRequestDispatcher("/admin/coupon-management.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User sessionUser = (User) session.getAttribute("sessionUser");
        String userRole = (String) session.getAttribute("userRole");

        // Kiểm tra quyền Admin
        if (sessionUser == null || (sessionUser.getRoleId() != 1 && !"Admin".equals(userRole))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            String couponIdStr = request.getParameter("couponId");
            String couponCode = request.getParameter("couponCode");
            String discountType = request.getParameter("discountType");
            double discountValue = Double.parseDouble(request.getParameter("discountValue"));
            double minOrderAmount = Double.parseDouble(request.getParameter("minOrderAmount"));
            String maxDiscountStr = request.getParameter("maxDiscountAmount");
            Double maxDiscountAmount = (maxDiscountStr != null && !maxDiscountStr.trim().isEmpty()) ? Double.parseDouble(maxDiscountStr) : null;
            
            // Validate: Nếu là Percentage thì bắt buộc phải nhập số tiền giảm tối đa
            if ("Percentage".equals(discountType)) {
                if (maxDiscountAmount == null) {
                    session.setAttribute("errorMessage", "Vui lòng nhập số tiền Giảm Tối Đa khi tạo mã giảm giá theo Phần Trăm.");
                    response.sendRedirect(request.getContextPath() + "/admin/coupons");
                    return;
                }
                // BR: Percentage coupon không được vượt quá 100% để tránh discount âm / total > 100%.
                if (discountValue > 100) {
                    session.setAttribute("errorMessage", "Giá trị giảm theo phần trăm không được vượt quá 100%.");
                    response.sendRedirect(request.getContextPath() + "/admin/coupons");
                    return;
                }
            }

            String maxUsesStr = request.getParameter("maxUses");
            Integer maxUses = (maxUsesStr != null && !maxUsesStr.trim().isEmpty()) ? Integer.parseInt(maxUsesStr) : null;
            Date startDate = Date.valueOf(request.getParameter("startDate"));
            Date endDate = Date.valueOf(request.getParameter("endDate"));
            boolean isActive = "on".equals(request.getParameter("isActive")) || "true".equals(request.getParameter("isActive"));

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
                if (couponIdStr == null || couponIdStr.trim().isEmpty()) {
                // Create — kiểm tra trùng mã, excludeId = -1 (không loại trừ ai)
                if (couponDAO.isCouponCodeExists(couponCode, -1)) {
                    session.setAttribute("errorMessage", "Mã coupon \"" + couponCode + "\" đã tồn tại. Vui lòng dùng mã khác.");
                    response.sendRedirect(request.getContextPath() + "/admin/coupons");
                    return;
                }
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
                // Update — kiểm tra trùng mã, bỏ qua chính coupon đang chỉnh sửa
                int couponId = Integer.parseInt(couponIdStr);
                if (couponDAO.isCouponCodeExists(couponCode, couponId)) {
                    session.setAttribute("errorMessage", "Mã coupon \"" + couponCode + "\" đã tồn tại. Vui lòng dùng mã khác.");
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

        response.sendRedirect(request.getContextPath() + "/admin/coupons");
    }
}
