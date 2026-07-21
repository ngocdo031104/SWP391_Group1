package Controller.accountant;

// UC40: Xu ly hoan tien (Accountant).
// - Xem danh sach CancellationRequest (Pending hoac Approved/Rejected).
// - Duyet: cancel booking + tao Payment(Refunded) + gui Notification.
// - Tu choi: doi status Rejected + gui Notification.

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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (!isAuthorized(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String tab = request.getParameter("tab");
        if (tab == null || tab.isEmpty()) tab = "pending";

        CancellationRequestDAO cancelDAO = null;
        try {
            cancelDAO = new CancellationRequestDAO();
            if ("history".equals(tab)) {
                // Hien thi yeu cau da xu ly (Approved/Rejected)
                List<CancellationRequest> approved = cancelDAO.getRequestsByStatusForAccountant("Approved");
                List<CancellationRequest> rejected = cancelDAO.getRequestsByStatusForAccountant("Rejected");
                approved.addAll(rejected);
                // Sort by ProcessedAt descending can be done in Java or DB,
                // here we just pass the combined list. For simplicity in UI, we can pass them separately or together.
                request.setAttribute("requests", approved); 
            } else {
                // Pending
                List<CancellationRequest> pending = cancelDAO.getRequestsByStatusForAccountant("Pending");
                request.setAttribute("requests", pending);
            }
            request.setAttribute("activeTab", tab);

            // Flash messages
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

            request.getRequestDispatcher("/views/accountant/refund-management.jsp").forward(request, response);
        } finally {
            if (cancelDAO != null) cancelDAO.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

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
                String amountStr = request.getParameter("refundAmount");
                double refundAmount = parseDouble(amountStr, 0);
                String transactionRef = request.getParameter("transactionRef"); // Ma giao dich hoan tien tu ngan hang
                
                // 1. Cap nhat CancellationRequest -> Approved
                boolean ok1 = cancelDAO.processRequest(requestId, accountant.getUserId(), "Approved", notes);
                
                if (ok1) {
                    // 2. Cancel booking (neu chua cancel)
                    bookingDAO.cancelBookingAndReleaseSeats(bookingId, accountant.getUserId(), "Hoan tien thanh cong: " + notes);
                    
                    // 3. Tao record Payment (Refunded)
                    Payment refundPayment = new Payment();
                    refundPayment.setBookingId(bookingId);
                    refundPayment.setAmount(refundAmount);
                    refundPayment.setPaymentMethod("Bank Transfer"); // Thong thuong hoan tien qua chuyen khoan
                    refundPayment.setTransactionRef(transactionRef != null ? transactionRef : "REFUND-" + requestId);
                    refundPayment.setStatus("Refunded");
                    paymentDAO.createPayment(refundPayment);
                    
                    // Add to Financial Audit Log
                    AuditLogDAO auditLogDAO = new AuditLogDAO();
                    auditLogDAO.createFinancialAuditLog("Payment", refundPayment.getPaymentId(), "Refund", "", "Hoàn tiền cho khách hàng: " + String.format("%,.0f", refundAmount) + " VND", accountant.getUserId());
                    auditLogDAO.close();
                    
                    // 4. Gui thong bao cho khach hang
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
                // 1. Cap nhat CancellationRequest -> Rejected
                boolean ok = cancelDAO.processRequest(requestId, accountant.getUserId(), "Rejected", notes);
                if (ok) {
                    // 2. Gui thong bao tu choi
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

    private boolean isAuthorized(HttpSession session) {
        if (session == null) return false;
        User user = (User) session.getAttribute("sessionUser");
        if (user == null || user.getRole() == null) return false;
        String role = user.getRole().getRoleName();
        return "Accountant".equals(role) || "Admin".equals(role);
    }

    private int parseInt(String val, int defaultVal) {
        try { return val != null ? Integer.parseInt(val) : defaultVal; }
        catch (NumberFormatException e) { return defaultVal; }
    }

    private double parseDouble(String val, double defaultVal) {
        try { return val != null ? Double.parseDouble(val) : defaultVal; }
        catch (NumberFormatException e) { return defaultVal; }
    }
}
