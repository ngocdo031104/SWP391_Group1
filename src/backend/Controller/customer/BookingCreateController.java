package Controller.customer;

// Người làm: Dương
// Thời gian tạo: 04/06/2026
// Chức năng: Controller màn Customer tạo booking.
// Ý nghĩa: Nhận tourId từ trang chi tiết tour, nạp lịch khởi hành, validate form nhập người tham gia và tạo BookingDraft trong session.

import Controller.customer.BookingFlowSupport.BookingDraft;
import Entities.BookingParticipant;
import Entities.Tour;
import Entities.TourSchedule;
import Model.InvoiceDAO;
import Model.TourDAO;
import Model.TourScheduleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "CustomerBookingCreateController", urlPatterns = {"/customer/booking/create"})
public class BookingCreateController extends HttpServlet {

    // doGet mở màn tạo booking.
    // Request phải có tourId vì khách đã bấm đặt tour từ detail.jsp.
    // Controller nạp tour và lịch khởi hành từ bảng TourSchedule theo đúng TourID để JSP chỉ hiển thị lịch của tour này.
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!BookingFlowSupport.requireLogin(request, response)) {
            return;
        }

        int tourId = BookingFlowSupport.parseInt(request.getParameter("tourId"), 0);
        if (tourId <= 0) {
            response.sendRedirect(request.getContextPath() + "/tourdiscovery");
            return;
        }

        TourDAO tourDAO = null;

        TourScheduleDAO tourScheduleDAO = null;

        try {
            tourDAO = new TourDAO();
            tourScheduleDAO = new TourScheduleDAO();
            Tour tour = tourDAO.getTourById(tourId);
            if (tour == null) {
                response.sendRedirect(request.getContextPath() + "/tourdiscovery");
                return;
            }

            // Dương làm đoạn này: màn booking dùng TourScheduleDAO để lấy trực tiếp các dòng TourSchedule theo TourID.
            // Mục đích là lấy DepartureDate từ đúng bảng lịch khởi hành, không phụ thuộc vào danh sách schedule nạp kèm trong TourDAO.
            List<TourSchedule> bookingSchedules = tourScheduleDAO.getSchedulesByTourId(tourId);
            tour.setSchedules(bookingSchedules);

            // tour dùng để hiển thị tên tour, điểm đến và thông tin tổng quan.
            Object expiredMessage = request.getSession().getAttribute("bookingExpiredMessage");
            if (expiredMessage != null) {
                request.getSession().removeAttribute("bookingExpiredMessage");
                request.setAttribute("errorMessage", expiredMessage.toString());
            }

            request.setAttribute("tour", tour);
            // schedules dùng để render các radio lịch khởi hành trong booking-create.jsp.
            request.setAttribute("schedules", bookingSchedules);
            request.getRequestDispatcher("/customer/booking-create.jsp").forward(request, response);
        } finally {
            if (tourScheduleDAO != null) {
                tourScheduleDAO.close();
            }
            if (tourDAO != null) {
                tourDAO.close();
            }
        }
    }

    // doPost nhận form tạo booking.
    // Logic chính: kiểm tra tour/schedule, kiểm tra số chỗ, đọc participant, lấy VATRate từ DB, tính tiền tạm và chuyển sang review.
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!BookingFlowSupport.requireLogin(request, response)) {
            return;
        }

        // tourId xác định tour đang đặt; scheduleId xác định ngày khởi hành; participantCount là số khách đi.
        int tourId = BookingFlowSupport.parseInt(request.getParameter("tourId"), 0);
        int scheduleId = BookingFlowSupport.parseInt(request.getParameter("scheduleId"), 0);
        int participantCount = BookingFlowSupport.parseInt(request.getParameter("participantCount"), 1);
        // Dương làm đoạn này: customerNote là ghi chú tự do của khách ở màn tạo booking.
        // Ghi chú không bắt buộc, được cắt độ dài để tránh lưu nội dung quá dài vào Booking.Notes.
        String customerNote = BookingFlowSupport.safeTrim(request.getParameter("customerNote"));
        if (customerNote.length() > 500) {
            customerNote = customerNote.substring(0, 500);
        }

        TourDAO tourDAO = null;
        TourScheduleDAO tourScheduleDAO = null;
        InvoiceDAO invoiceDAO = null;
        try {
            tourDAO = new TourDAO();
            tourScheduleDAO = new TourScheduleDAO();
            Tour tour = tourDAO.getTourById(tourId);
            if (tour != null) {
                // Dương làm đoạn này: đồng bộ danh sách lịch khi submit với danh sách đã hiển thị ở GET.
                // Nhờ vậy khi form lỗi, JSP vẫn render lại đúng các lịch của tour đang đặt.
                tour.setSchedules(tourScheduleDAO.getSchedulesByTourId(tourId));
            }
            // selectedSchedule được lấy bằng ScheduleID + TourID để chắc chắn lịch khách chọn thuộc đúng tour hiện tại.
            TourSchedule selectedSchedule = tourScheduleDAO.getScheduleByIdForTour(scheduleId, tourId);

            // Không cho tạo draft nếu schedule không tồn tại hoặc không thuộc tour hiện tại.
            if (tour == null || selectedSchedule == null) {
                forwardCreateError(request, response, tour, "Vui lòng chọn lịch khởi hành hợp lệ.");
                return;
            }
            // Giới hạn 1-10 khách theo constraint NumParticipants trong bảng Booking.
            if (participantCount < 1 || participantCount > 10) {
                forwardCreateError(request, response, tour, "Số người tham gia phải từ 1 đến 10.");
                return;
            }
            // Kiểm tra AvailableSeats để tránh khách đặt nhiều hơn số chỗ còn lại.
            if (selectedSchedule.getAvailableSeats() < participantCount) {
                forwardCreateError(request, response, tour, "Lịch này không còn đủ chỗ cho số lượng khách đã chọn.");
                return;
            }

            // participants là danh sách entity tạm để sau này BookingDAO insert vào BookingParticipant.
            List<BookingParticipant> participants = BookingFlowSupport.readParticipants(request, participantCount);
            if (participants.size() != participantCount) {
                forwardCreateError(request, response, tour, "Vui lòng nhập đầy đủ thông tin bắt buộc của tất cả người tham gia.");
                return;
            }

            // baseAmount tính theo nhóm tuổi của từng participant: Adult/Child/Infant lấy giá từ TourSchedule.
            double baseAmount = BookingFlowSupport.calculateParticipantBaseAmount(participants, selectedSchedule);
            // vatRatePercent được đọc từ database qua default Invoice.VATRate, nên khi DB đổi VAT thì booking dùng rate mới.
            invoiceDAO = new InvoiceDAO();
            Double vatRatePercent = invoiceDAO.getDefaultVatRatePercent();
            if (vatRatePercent == null) {
                forwardCreateError(request, response, tour, "Chưa cấu hình VATRate hợp lệ trong bảng Invoice. Vui lòng kiểm tra database.");
                return;
            }

            BookingDraft draft = new BookingDraft();
            draft.tourId = tourId;
            draft.scheduleId = scheduleId;
            draft.participantCount = participantCount;
            draft.baseAmount = baseAmount;
            draft.discountAmount = 0;
            draft.vatRatePercent = vatRatePercent;
            draft.vatAmount = BookingFlowSupport.calculateVatAmount(baseAmount, vatRatePercent);
            draft.totalAmount = baseAmount + draft.vatAmount;
            draft.couponId = null;
            draft.couponCode = "";
            draft.customerNote = customerNote;
            draft.participants = participants;

            // Lưu draft vào session để BookingReviewController đọc và hiển thị màn xác nhận.
            request.getSession(true).setAttribute("bookingDraft", draft);
            response.sendRedirect(request.getContextPath() + "/customer/booking/review");
        } finally {
            if (tourScheduleDAO != null) {
                tourScheduleDAO.close();
            }
            if (tourDAO != null) {
                tourDAO.close();
            }
            if (invoiceDAO != null) {
                invoiceDAO.close();
            }
        }
    }

    // Hàm này trả về lại booking-create.jsp khi validate server-side thất bại.
    // tour và schedules được set lại để người dùng vẫn thấy form và có thể sửa dữ liệu.
    private void forwardCreateError(HttpServletRequest request, HttpServletResponse response, Tour tour, String message)
            throws ServletException, IOException {
        request.setAttribute("tour", tour);
        request.setAttribute("schedules", tour != null ? tour.getSchedules() : null);
        request.setAttribute("errorMessage", message);
        request.getRequestDispatcher("/customer/booking-create.jsp").forward(request, response);
    }
}
