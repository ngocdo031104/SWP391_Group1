package Controller.accountant;

// Người làm: Dương
// Ngày tạo file: 14/07/2026
// Chức năng: Quản lý và theo dõi danh sách giao dịch thanh toán (Payment).
// Ý nghĩa: Cho phép Kế toán xem toàn bộ lịch sử thanh toán (tiền vào/tiền ra),
// hỗ trợ phân trang, tìm kiếm theo từ khóa và lọc theo khoảng thời gian (từ ngày - đến ngày).

import Entities.Payment;
import Entities.User;
import Model.PaymentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AccountantPaymentController", urlPatterns = {"/accountant/payments"})
public class AccountantPaymentController extends HttpServlet {

    // Kích thước trang mặc định cho tính năng phân trang (20 giao dịch mỗi trang).
    private static final int PAGE_SIZE = 20;

    // Phương thức doGet lấy các tham số lọc từ request, truy vấn danh sách Payment từ CSDL
    // và tính toán các tổng doanh thu để hiển thị ra màn hình quản lý thanh toán.
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // Xác thực quyền truy cập: chỉ người dùng có quyền Accountant hoặc Admin mới được phép sử dụng.
        HttpSession session = request.getSession(false);
        if (!isAuthorized(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Lấy các tham số filter từ request (tab: in/out, ngày bắt đầu, ngày kết thúc, từ khóa tìm kiếm, trang hiện tại).
        String tab      = request.getParameter("tab"); // 'in' or 'out'
        String dateFrom = request.getParameter("dateFrom");
        String dateTo   = request.getParameter("dateTo");
        String keyword  = request.getParameter("keyword");
        String pageStr  = request.getParameter("page");

        // Mặc định tab hiển thị là 'in' (tiền vào - Success).
        // Nếu chọn tab 'out', hiển thị tiền ra (Refunded).
        if (tab == null || tab.isEmpty()) tab = "in"; // default to In
        String statusFilter = "in".equals(tab) ? "Success" : "Refunded";

        // Xử lý phân trang.
        int page = 1;
        try {
            if (pageStr != null) page = Integer.parseInt(pageStr);
            if (page < 1) page = 1;
        } catch (NumberFormatException ignored) {}

        // Tính vị trí bắt đầu (offset) cho truy vấn phân trang SQL.
        int offset = (page - 1) * PAGE_SIZE;

        PaymentDAO paymentDAO = null;
        try {
            paymentDAO = new PaymentDAO();
            
            // Lấy danh sách giao dịch dựa trên tab (Success/Refunded), khoảng thời gian và từ khóa.
            List<Payment> payments = paymentDAO.getPaymentsByStatusForAccountant(statusFilter, dateFrom, dateTo, keyword, offset, PAGE_SIZE);
            
            // Lấy tổng số lượng bản ghi thỏa mãn điều kiện lọc để tính tổng số trang.
            int totalRecords = paymentDAO.countPaymentsByStatus(statusFilter, dateFrom, dateTo, keyword);
            int totalPages = (int) Math.ceil((double) totalRecords / PAGE_SIZE);

            // Tính tổng tiền cho thẻ thống kê (Tổng tiền vào, Tổng tiền ra, và Doanh thu ròng).
            double totalIn = paymentDAO.sumPaymentsByStatus("Success", dateFrom, dateTo);
            double totalOut = paymentDAO.sumPaymentsByStatus("Refunded", dateFrom, dateTo);
            double netRevenue = totalIn - totalOut;

            // Truyền dữ liệu vào request attributes để JSP hiển thị.
            request.setAttribute("payments", payments);
            request.setAttribute("totalRecords", totalRecords);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            
            request.setAttribute("totalIn", totalIn);
            request.setAttribute("totalOut", totalOut);
            request.setAttribute("netRevenue", netRevenue);
            
            request.setAttribute("activeTab", tab);
            request.setAttribute("dateFrom", dateFrom != null ? dateFrom : "");
            request.setAttribute("dateTo", dateTo != null ? dateTo : "");
            request.setAttribute("keyword", keyword != null ? keyword : "");

            // Điều hướng sang trang hiển thị danh sách thanh toán.
            request.getRequestDispatcher("/views/accountant/payment-list.jsp").forward(request, response);
        } finally {
            if (paymentDAO != null) paymentDAO.close();
        }
    }

    // Hàm kiểm tra quyền hạn của người dùng.
    // Trả về true nếu là Kế toán (Accountant) hoặc Quản trị viên (Admin), ngược lại trả về false.
    private boolean isAuthorized(HttpSession session) {
        if (session == null) return false;
        User user = (User) session.getAttribute("sessionUser");
        if (user == null || user.getRole() == null) return false;
        String role = user.getRole().getRoleName();
        return "Accountant".equals(role) || "Admin".equals(role);
    }
}
