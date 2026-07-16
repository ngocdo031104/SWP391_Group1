package Controller.admin;

// Nguoi lam: Duong
// UC11: Staff xem va quan ly danh sach toan bo booking cua he thong.
// Chuc nang: Lay danh sach booking co filter + phan trang, cho phep Staff them ghi chu van hanh.

import Entities.Booking;
import Entities.User;
import Entities.Notification;
import Model.BookingDAO;
import Model.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "StaffBookingManagementController", urlPatterns = {"/staff/bookings"})
public class StaffBookingManagementController extends HttpServlet {

    private static final int PAGE_SIZE = 15;

    // doGet: Hien thi danh sach booking co filter va phan trang.
    // Chi cho phep Staff va Admin truy cap.
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (!isAuthorized(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Doc cac tham so filter tu URL query string
        String statusFilter = request.getParameter("status");
        String keyword      = request.getParameter("keyword");
        String pageStr      = request.getParameter("page");

        if (statusFilter == null || statusFilter.trim().isEmpty()) statusFilter = "All";
        if (keyword == null) keyword = "";
        int page = 1;
        try {
            page = Integer.parseInt(pageStr);
            if (page < 1) page = 1;
        } catch (NumberFormatException ignored) {}

        int offset = (page - 1) * PAGE_SIZE;

        BookingDAO bookingDAO = null;
        try {
            bookingDAO = new BookingDAO();
            List<Booking> bookings = bookingDAO.getAllBookingsForStaff(statusFilter, keyword, offset, PAGE_SIZE);
            int totalRecords = bookingDAO.countAllBookingsForStaff(statusFilter, keyword);
            int totalPages   = (int) Math.ceil((double) totalRecords / PAGE_SIZE);

            request.setAttribute("bookings",     bookings);
            request.setAttribute("totalRecords", totalRecords);
            request.setAttribute("currentPage",  page);
            request.setAttribute("totalPages",   totalPages);
            request.setAttribute("statusFilter", statusFilter);
            request.setAttribute("keyword",      keyword);

            // Doc flash message tu session (sau redirect tu POST)
            String successMsg = (String) session.getAttribute("staffBookingSuccess");
            String errorMsg   = (String) session.getAttribute("staffBookingError");
            if (successMsg != null) {
                request.setAttribute("successMessage", successMsg);
                session.removeAttribute("staffBookingSuccess");
            }
            if (errorMsg != null) {
                request.setAttribute("errorMessage", errorMsg);
                session.removeAttribute("staffBookingError");
            }

            request.getRequestDispatcher("/views/staff/booking-management.jsp").forward(request, response);
        } finally {
            if (bookingDAO != null) bookingDAO.close();
        }
    }

    // doPost: Xu ly action=addNote — Staff cap nhat ghi chu van hanh noi bo cho 1 booking.
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (!isAuthorized(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User currentUser = (User) session.getAttribute("sessionUser");

        String action = request.getParameter("action");

        if ("addNote".equals(action)) {
            String bookingIdStr = request.getParameter("bookingId");
            String notes        = request.getParameter("notes");
            // Giu lai filter/page de redirect ve dung trang dang xem
            String statusFilter = request.getParameter("statusFilter");
            String keyword      = request.getParameter("keyword");
            String page         = request.getParameter("page");

            int bookingId = 0;
            try {
                bookingId = Integer.parseInt(bookingIdStr);
            } catch (NumberFormatException ignored) {}

            if (bookingId <= 0) {
                session.setAttribute("staffBookingError", "Booking khong hop le.");
            } else {
                BookingDAO bookingDAO = null;
                try {
                    bookingDAO = new BookingDAO();
                    boolean ok = bookingDAO.updateOperationalNotes(bookingId, notes);
                    if (ok) {
                        session.setAttribute("staffBookingSuccess", "Da cap nhat ghi chu van hanh thanh cong.");
                    } else {
                        session.setAttribute("staffBookingError", "Khong the cap nhat ghi chu. Vui long thu lai.");
                    }
                } finally {
                    if (bookingDAO != null) bookingDAO.close();
                }
            }

            // Redirect ve trang danh sach, giu nguyen filter + page
            String redirectUrl = request.getContextPath() + "/staff/bookings?status=" +
                (statusFilter != null ? statusFilter : "All") +
                "&keyword=" + (keyword != null ? keyword : "") +
                "&page=" + (page != null ? page : "1");
            response.sendRedirect(redirectUrl);
        } else if ("sendNotification".equals(action)) {
            String customerIdStr = request.getParameter("customerId");
            String title = request.getParameter("title");
            String content = request.getParameter("content");
            String category = request.getParameter("category");
            String scheduledAtStr = request.getParameter("scheduledAt");

            String statusFilter = request.getParameter("statusFilter");
            String keyword      = request.getParameter("keyword");
            String page         = request.getParameter("page");

            if (customerIdStr != null && title != null && content != null && category != null) {
                try {
                    int customerId = Integer.parseInt(customerIdStr);
                    Notification notification = new Notification();
                    notification.setUserId(customerId);
                    notification.setSenderId(currentUser.getUserId());
                    notification.setTitle(title);
                    notification.setContent(content);
                    notification.setChannel("SYSTEM");
                    notification.setCategory(category);

                    java.sql.Timestamp scheduledAt = null;
                    if (scheduledAtStr != null && !scheduledAtStr.trim().isEmpty()) {
                        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
                        java.util.Date date = sdf.parse(scheduledAtStr);
                        scheduledAt = new java.sql.Timestamp(date.getTime());
                    }
                    notification.setScheduledAt(scheduledAt);

                    if (scheduledAt != null) {
                        notification.setStatus("SCHEDULED");
                    } else {
                        notification.setStatus("SENT");
                    }

                    NotificationDAO notifDAO = new NotificationDAO();
                    notifDAO.insertNotification(notification);

                    session.setAttribute("staffBookingSuccess", "Gửi thông báo thành công.");
                } catch (Exception e) {
                    session.setAttribute("staffBookingError", "Có lỗi xảy ra khi gửi thông báo.");
                    e.printStackTrace();
                }
            } else {
                session.setAttribute("staffBookingError", "Thiếu thông tin bắt buộc.");
            }

            String redirectUrl = request.getContextPath() + "/staff/bookings?status=" +
                (statusFilter != null ? statusFilter : "All") +
                "&keyword=" + (keyword != null ? keyword : "") +
                "&page=" + (page != null ? page : "1");
            response.sendRedirect(redirectUrl);
        } else {
            response.sendRedirect(request.getContextPath() + "/staff/bookings");
        }
    }

    // Kiem tra quyen truy cap: chi Staff va Admin duoc phep.
    private boolean isAuthorized(HttpSession session) {
        if (session == null) return false;
        User user = (User) session.getAttribute("sessionUser");
        if (user == null || user.getRole() == null) return false;
        String role = user.getRole().getRoleName();
        return "Staff".equals(role) || "Admin".equals(role);
    }
}
