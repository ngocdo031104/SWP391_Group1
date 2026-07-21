package Controller.accountant;

// Người làm: Dương
// Ngày tạo file: 14/07/2026
// Chức năng: Xử lý quản lý hoàn tiền (Refund Management) dành cho Kế toán.
// Ý nghĩa: Cho phép xem danh sách yêu cầu hủy tour (Cancellation Request),
// duyệt (Approve) và tạo giao dịch hoàn tiền, hoặc từ chối (Reject) yêu cầu.

import Entities.CancellationRequest;
import Entities.Notification;
import Entities.Payment;
import Entities.User;
import Model.AuditLogDAO;
import Model.BookingDAO;
import Model.CancellationRequestDAO;
import Model.NotificationDAO;
import Model.PaymentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "RefundManagementController", urlPatterns = {"/accountant/refunds"})
public class RefundManagementController extends HttpServlet {

    // Phương thức doGet xử lý việc lấy và hiển thị danh sách yêu cầu hủy tour.
    // Hỗ trợ hai tab: 'pending' (yêu cầu đang chờ xử lý) và 'history' (yêu cầu đã xử lý).
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // Kiểm tra quyền hạn của người dùng.
        HttpSession session = request.getSession(false);
        if (!isAuthorized(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Lấy tab hiện tại (mặc định là 'pending').
        String tab = request.getParameter("tab");
        if (tab == null || tab.isEmpty()) tab = "pending";

        CancellationRequestDAO cancelDAO = null;
        try {
            cancelDAO = new CancellationRequestDAO();
            if ("history".equals(tab)) {
                // Hiển thị lịch sử các yêu cầu đã xử lý (Bao gồm Approved và Rejected).
                List<CancellationRequest> approved = cancelDAO.getRequestsByStatusForAccountant("Approved");
                List<CancellationRequest> rejected = cancelDAO.getRequestsByStatusForAccountant("Rejected");
                approved.addAll(rejected);
                request.setAttribute("requests", approved); 
            } else {
                // Hiển thị các yêu cầu hủy đang chờ Kế toán duyệt (Pending).
                List<CancellationRequest> pending = cancelDAO.getRequestsByStatusForAccountant("Pending");
                request.setAttribute("requests", pending);
            }
            request.setAttribute("activeTab", tab);

            // Kiểm tra và hiển thị các thông báo từ session (ví dụ: thông báo duyệt thành công hoặc lỗi).
            String successMsg = (String) session.getAttribute("refundSuccess");
            String errorMsg   = (String) session.getAttribute("refundError");
            if (successMsg != null) {
                request.setAttribute("successMessage", successMsg);
                session.removeAttribute("refundSuccess");
            }
            if (errorMsg != null) {
                request.setAttribute("errorMessage", errorMsg);
                session.removeAttribute("refundError");
            }

            // Điều hướng sang trang hiển thị quản lý hoàn tiền.
            request.getRequestDispatcher("/views/accountant/refund-management.jsp").forward(request, response);
        } finally {
            if (cancelDAO != null) cancelDAO.close();
        }
    }

    // Phương thức doPost xử lý khi Kế toán thực hiện duyệt (Approve) hoặc từ chối (Reject) yêu cầu.
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // Kiểm tra quyền hạn của người dùng.
        HttpSession session = request.getSession(false);
        if (!isAuthorized(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User accountant = (User) session.getAttribute("sessionUser");
        String action = request.getParameter("action");
        String requestIdStr = request.getParameter("requestId");
        String bookingIdStr = request.getParameter("bookingId");
        String notes = request.getParameter("notes");
        String customerIdStr = request.getParameter("customerId");
        String bookingCode = request.getParameter("bookingCode");

        int requestId = parseInt(requestIdStr, 0);
        int bookingId = parseInt(bookingIdStr, 0);
        int customerId = parseInt(customerIdStr, 0);

        // Validate cơ bản id request và booking.
        if (requestId <= 0 || bookingId <= 0) {
            session.setAttribute("refundError", "Dữ liệu không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/accountant/refunds");
            return;
        }

        CancellationRequestDAO cancelDAO = new CancellationRequestDAO();
        BookingDAO bookingDAO = new BookingDAO();
        PaymentDAO paymentDAO = new PaymentDAO();
        NotificationDAO notifDAO = new NotificationDAO();

        try {
            if ("approve".equals(action)) {
                // Xử lý nhánh duyệt yêu cầu hoàn tiền.
                String amountStr = request.getParameter("refundAmount");
                double refundAmount = parseDouble(amountStr, 0);
                String transactionRef = request.getParameter("transactionRef"); // Mã giao dịch hoàn tiền từ ngân hàng
                
                // 1. Cập nhật trạng thái CancellationRequest thành Approved.
                boolean ok1 = cancelDAO.processRequest(requestId, accountant.getUserId(), "Approved", notes);
                
                if (ok1) {
                    // 2. Hủy booking tương ứng và nhả số lượng chỗ trống lại cho tour.
                    bookingDAO.cancelBookingAndReleaseSeats(bookingId, accountant.getUserId(), "Hoan tien thanh cong: " + notes);
                    
                    // 3. Tạo bản ghi giao dịch (Payment) với trạng thái Refunded.
                    Payment refundPayment = new Payment();
                    refundPayment.setBookingId(bookingId);
                    refundPayment.setAmount(refundAmount);
                    refundPayment.setPaymentMethod("Bank Transfer"); // Thông thường hoàn tiền qua chuyển khoản
                    refundPayment.setTransactionRef(transactionRef != null ? transactionRef : "REFUND-" + requestId);
                    refundPayment.setStatus("Refunded");
                    paymentDAO.createPayment(refundPayment);
                    
                    // Thêm bản ghi vào nhật ký tài chính (Financial Audit Log) để theo dõi kiểm toán.
                    AuditLogDAO auditLogDAO = new AuditLogDAO();
                    auditLogDAO.createFinancialAuditLog("Payment", refundPayment.getPaymentId(), "Refund", "", "Hoàn tiền cho khách hàng: " + String.format("%,.0f", refundAmount) + " VND", accountant.getUserId());
                    auditLogDAO.close();
                    
                    // 4. Gửi thông báo trong hệ thống cho Khách hàng biết tiền đã được hoàn.
                    Notification n = new Notification();
                    n.setUserId(customerId);
                    n.setTitle("Hoàn tiền thành công - " + bookingCode);
                    n.setContent("Yêu cầu hủy tour của bạn đã được duyệt. Số tiền " + String.format("%,.0f", refundAmount) + "đ đã được hoàn lại. Vui lòng kiểm tra tài khoản.");
                    n.setChannel("SYSTEM");
                    n.setCategory("Booking");
                    notifDAO.insertNotification(n);

                    session.setAttribute("refundSuccess", "Đã duyệt và hoàn tiền thành công cho mã " + bookingCode);
                } else {
                    session.setAttribute("refundError", "Lỗi xử lý yêu cầu hủy.");
                }

            } else if ("reject".equals(action)) {
                // Xử lý nhánh từ chối yêu cầu hoàn tiền.
                
                // 1. Cập nhật trạng thái CancellationRequest thành Rejected.
                boolean ok = cancelDAO.processRequest(requestId, accountant.getUserId(), "Rejected", notes);
                if (ok) {
                    // 2. Gửi thông báo từ chối cho Khách hàng kèm theo lý do từ chối.
                    Notification n = new Notification();
                    n.setUserId(customerId);
                    n.setTitle("Yêu cầu hủy tour bị từ chối - " + bookingCode);
                    n.setContent("Yêu cầu hủy tour của bạn không được chấp thuận. Lý do: " + notes);
                    n.setChannel("SYSTEM");
                    n.setCategory("Booking");
                    notifDAO.insertNotification(n);

                    session.setAttribute("refundSuccess", "Đã từ chối yêu cầu hủy của mã " + bookingCode);
                } else {
                    session.setAttribute("refundError", "Lỗi xử lý yêu cầu hủy.");
                }
            }
        } finally {
            cancelDAO.close();
            bookingDAO.close();
            paymentDAO.close();
            notifDAO.close();
        }

        response.sendRedirect(request.getContextPath() + "/accountant/refunds");
    }

    // Hàm kiểm tra quyền hạn của người dùng.
    private boolean isAuthorized(HttpSession session) {
        if (session == null) return false;
        User user = (User) session.getAttribute("sessionUser");
        if (user == null || user.getRole() == null) return false;
        String role = user.getRole().getRoleName();
        return "Accountant".equals(role) || "Admin".equals(role);
    }

    // Helper parser để xử lý lỗi ngoại lệ khi parse số nguyên
    private int parseInt(String val, int defaultVal) {
        try { return val != null ? Integer.parseInt(val) : defaultVal; }
        catch (NumberFormatException e) { return defaultVal; }
    }

    // Helper parser để xử lý lỗi ngoại lệ khi parse số thực
    private double parseDouble(String val, double defaultVal) {
        try { return val != null ? Double.parseDouble(val) : defaultVal; }
        catch (NumberFormatException e) { return defaultVal; }
    }
}
