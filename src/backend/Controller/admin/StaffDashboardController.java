/*
 * Màn hình hiển thị tổng quan Dashboard của Nhân viên (Staff)
 * Tác giả: Dương Quang Sơn
 * MSSV: HE186525
 * Ngày tạo: 2026-07-21
 */
package Controller.admin;

import Entities.User;
import Model.BookingDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "StaffDashboardController", urlPatterns = {"/staff/dashboard"})
public class StaffDashboardController extends HttpServlet {

    /**
     * Xử lý yêu cầu HTTP GET.
     * 1. Xác thực thông tin người dùng từ session, đảm bảo chỉ Staff hoặc Admin mới được phép truy cập.
     * 2. Sử dụng BookingDAO để lấy thông tin tổng quan các đơn đặt tour theo các trạng thái (Tất cả, Thành công, Đang xử lý, Đã hủy).
     * 3. Thiết lập các thông số thống kê vào request attribute để truyền sang trang JSP hiển thị.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // 1. Kiểm tra trạng thái đăng nhập & phân quyền Staff/Admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("sessionUser");
        String role = user.getRole() != null ? user.getRole().getRoleName() : "";
        if (!"Staff".equals(role) && !"Admin".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // 2. Load thống kê tổng quan booking để hiển thị trên dashboard
        BookingDAO bookingDAO = null;
        try {
            bookingDAO = new BookingDAO();
            int totalAll       = bookingDAO.countAllBookingsForStaff("All", "");
            int totalSuccess   = bookingDAO.countAllBookingsForStaff("Success", "");
            int totalPending   = bookingDAO.countAllBookingsForStaff("PendingPayment", "");
            int totalCancelled = bookingDAO.countAllBookingsForStaff("Cancelled", "");

            request.setAttribute("totalAll",       totalAll);
            request.setAttribute("totalSuccess",   totalSuccess);
            request.setAttribute("totalPending",   totalPending);
            request.setAttribute("totalCancelled", totalCancelled);

            // 3. Điều hướng sang trang Dashboard của nhân viên
            request.getRequestDispatcher("/views/staff/dashboard.jsp").forward(request, response);
        } finally {
            if (bookingDAO != null) bookingDAO.close();
        }
    }
}
