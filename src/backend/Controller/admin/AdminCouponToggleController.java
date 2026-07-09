package Controller.admin;

// Dương làm đoạn này
// Thời gian tạo: 25/06/2026
// Chức năng: Controller thay đổi trạng thái (Bật/Tắt) của Coupon.
// Ý nghĩa: Nhận ID và trạng thái mới từ client, gọi DAO để cập nhật, sau đó redirect về trang quản lý.

import Entities.User;
import Model.CouponDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "AdminCouponToggleController", urlPatterns = {"/admin/coupons/toggle"})
public class AdminCouponToggleController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User sessionUser = (User) session.getAttribute("sessionUser");
        String userRole = (String) session.getAttribute("userRole");

        // Kiểm tra quyền Admin
        if (sessionUser == null || (sessionUser.getRoleId() != 1 && !"Admin".equals(userRole))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            int couponId = Integer.parseInt(request.getParameter("couponId"));
            boolean newStatus = Boolean.parseBoolean(request.getParameter("status"));

            CouponDAO couponDAO = new CouponDAO();
            boolean success = couponDAO.toggleStatus(couponId, newStatus);
            
            if (success) {
                session.setAttribute("successMessage", "Cập nhật trạng thái coupon thành công!");
            } else {
                session.setAttribute("errorMessage", "Không thể cập nhật trạng thái coupon.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/coupons");
    }
}
