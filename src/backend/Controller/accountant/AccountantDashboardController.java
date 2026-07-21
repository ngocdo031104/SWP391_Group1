package Controller.accountant;

// Người làm: Dương
// Ngày tạo file: 14/07/2026
// Chức năng: Dashboard dành cho Kế toán (Accountant).
// Ý nghĩa: Controller này hiển thị trang tổng quan sau khi Kế toán đăng nhập,
// cung cấp các số liệu thống kê cơ bản như số lượng yêu cầu hoàn tiền (Refund) đang chờ xử lý.

import Entities.User;
import Model.CancellationRequestDAO;
import Model.PaymentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "AccountantDashboardController", urlPatterns = {"/accountant/dashboard"})
public class AccountantDashboardController extends HttpServlet {

    // Phương thức doGet xử lý request khi Kế toán truy cập trang Dashboard.
    // Thực hiện kiểm tra quyền truy cập (chỉ Kế toán hoặc Admin mới được phép),
    // sau đó lấy số lượng yêu cầu hoàn tiền đang chờ (Pending) và chuyển tiếp tới view Dashboard.
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // Kiểm tra xem người dùng đã đăng nhập chưa.
        // Nếu chưa đăng nhập hoặc session đã hết hạn, chuyển hướng về trang đăng nhập.
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Lấy thông tin user hiện tại từ session và kiểm tra quyền.
        // Nếu không phải là Accountant hoặc Admin thì từ chối truy cập và chuyển về trang chủ.
        User user = (User) session.getAttribute("sessionUser");
        String role = user.getRole() != null ? user.getRole().getRoleName() : "";
        if (!"Accountant".equals(role) && !"Admin".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        CancellationRequestDAO cancelDAO = null;
        try {
            cancelDAO = new CancellationRequestDAO();
            // Lấy số lượng yêu cầu hủy tour (hoàn tiền) đang ở trạng thái 'Pending'.
            // Kế toán cần xử lý các yêu cầu này để hoàn tiền lại cho khách hàng.
            int pendingRefunds = cancelDAO.getRequestsByStatusForAccountant("Pending").size();
            
            // Truyền dữ liệu số lượng pending refunds sang JSP để hiển thị trên Dashboard.
            request.setAttribute("pendingRefunds", pendingRefunds);
            request.getRequestDispatcher("/views/accountant/dashboard.jsp").forward(request, response);
        } finally {
            if (cancelDAO != null) cancelDAO.close();
        }
    }
}
