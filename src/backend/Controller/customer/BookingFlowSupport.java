package Controller.customer;

// Người làm: Dương
// Thời gian tạo: 04/06/2026
// Chức năng: Chứa các hàm dùng chung cho 4 controller booking của Customer.
// Ý nghĩa: Gom phần kiểm tra đăng nhập, đọc participant, tìm lịch khởi hành, tính coupon/VAT và lưu BookingDraft để các controller nhỏ không lặp code.

import Entities.BookingParticipant;
import Entities.Coupon;
import Entities.Tour;
import Entities.TourSchedule;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class BookingFlowSupport {

    // Thời gian giữ slot sau khi khách chuyển từ review sang payment; quá thời gian này booking PendingPayment sẽ bị hủy và nhả ghế.
    public static final int PAYMENT_HOLD_MINUTES = 10;

    // Hàm requireLogin dùng để bảo vệ toàn bộ luồng booking Customer.
    // Nếu chưa có sessionUser, hệ thống chuyển về /login và trả false để controller dừng xử lý.
    // Nếu đã đăng nhập, trả true để controller tiếp tục xử lý request hiện tại.
    public static boolean requireLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (request.getSession(false) == null || request.getSession(false).getAttribute("sessionUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        return true;
    }

    // Hàm parseInt chuyển chuỗi từ query/form sang số nguyên.
    // value là dữ liệu người dùng gửi lên; fallback là giá trị thay thế khi value rỗng hoặc sai định dạng.
    // Mục đích là tránh NumberFormatException làm vỡ luồng servlet.
    public static int parseInt(String value, int fallback) {
        try {
            return value != null && !value.trim().isEmpty() ? Integer.parseInt(value.trim()) : fallback;
        } catch (NumberFormatException ex) {
            return fallback;
        }
    }

    // Hàm safeTrim chuẩn hóa chuỗi nhập từ form.
    // Nếu value là null thì trả về chuỗi rỗng, nếu có dữ liệu thì cắt khoảng trắng hai đầu.
    // Mục đích là tránh NullPointerException và giúp validate dữ liệu nhất quán.
    public static String safeTrim(String value) {
        return value == null ? "" : value.trim();
    }

    // Hàm findSchedule kiểm tra lịch khởi hành được chọn có thuộc tour hiện tại không.
    // tour là tour đang đặt, scheduleId là id lịch khách chọn từ form.
    // Logic này ngăn người dùng sửa request để gửi scheduleId của tour khác.
    public static TourSchedule findSchedule(Tour tour, int scheduleId) {
        if (tour == null || tour.getSchedules() == null) {
            return null;
        }
        for (TourSchedule schedule : tour.getSchedules()) {
            if (schedule.getScheduleId() == scheduleId) {
                return schedule;
            }
        }
        return null;
    }

    // Hàm readParticipants đọc danh sách người tham gia từ các input động ở màn create.
    // count là số người khách đã chọn; các mảng name/age/phone/email đến từ request parameter cùng tên.
    // Người đầu tiên là trưởng đoàn nên bắt buộc có phone/email để liên hệ và luôn được tính là người lớn.
    // Nếu một dòng thiếu dữ liệu bắt buộc, dòng đó không được đưa vào danh sách kết quả.
    public static List<BookingParticipant> readParticipants(HttpServletRequest request, int count) {
        List<BookingParticipant> participants = new ArrayList<>();
        String[] names = request.getParameterValues("participantName");
        String[] ageTypes = request.getParameterValues("participantAgeType");
        String[] phones = request.getParameterValues("participantPhone");
        String[] emails = request.getParameterValues("participantEmail");

        for (int i = 0; i < count; i++) {
            String name = names != null && i < names.length ? safeTrim(names[i]) : "";
            String phone = phones != null && i < phones.length ? safeTrim(phones[i]) : "";
            String email = emails != null && i < emails.length ? safeTrim(emails[i]) : "";

            // Bỏ qua participant không hợp lệ để controller so sánh lại số lượng và trả lỗi validate server-side.
            if (name.isEmpty() || (i == 0 && (phone.isEmpty() || email.isEmpty()))) {
                continue;
            }

            // ageType xác định nhóm giá của khách; trưởng đoàn luôn là Adult để bảo đảm người đại diện là người lớn.
            String ageType = i == 0 ? "Adult" : normalizeAgeType(ageTypes != null && i < ageTypes.length ? ageTypes[i] : "Adult");

            // Tạo entity BookingParticipant để BookingDAO insert batch vào bảng BookingParticipant.
            BookingParticipant participant = new BookingParticipant();
            participant.setFullName(name);
            participant.setAgeType(ageType);
            participant.setPhoneNumber(phone);
            participant.setEmail(email);
            participant.setIsLeader(i == 0);
            participants.add(participant);
        }
        return participants;
    }


    // normalizeAgeType chuẩn hóa nhóm tuổi người tham gia về đúng các giá trị constraint của BookingParticipant.
    // Nếu request bị sửa thủ công thành giá trị lạ, hệ thống tự đưa về Adult để tránh lỗi DB và tính tiền sai.
    public static String normalizeAgeType(String ageType) {
        String value = safeTrim(ageType);
        if ("Child".equalsIgnoreCase(value)) {
            return "Child";
        }
        if ("Infant".equalsIgnoreCase(value)) {
            return "Infant";
        }
        return "Adult";
    }

    // calculateParticipantBaseAmount tính tiền tour theo nhóm tuổi của từng người tham gia.
    // Adult dùng PriceAdult, Child dùng PriceChild, Infant dùng PriceInfant từ lịch khởi hành đã chọn trong bảng TourSchedule.
    public static double calculateParticipantBaseAmount(List<BookingParticipant> participants, TourSchedule schedule) {
        if (participants == null || schedule == null) {
            return 0;
        }

        double amount = 0;
        for (BookingParticipant participant : participants) {
            String ageType = normalizeAgeType(participant.getAgeType());
            if ("Child".equals(ageType)) {
                amount += schedule.getPriceChild();
            } else if ("Infant".equals(ageType)) {
                amount += schedule.getPriceInfant();
            } else {
                amount += schedule.getPriceAdult();
            }
        }
        return amount;
    }
    // Hàm calculateDiscount tính số tiền giảm từ coupon.
    // Nếu coupon là Percentage thì giảm theo phần trăm của baseAmount.
    // Nếu coupon là FixedAmount thì giảm số tiền cố định nhưng không vượt quá baseAmount.
    public static double calculateDiscount(double baseAmount, Coupon coupon) {
        if ("Percentage".equalsIgnoreCase(coupon.getDiscountType())) {
            double discount = baseAmount * coupon.getDiscountValue() / 100.0;
            if (coupon.getMaxDiscountAmount() != null && discount > coupon.getMaxDiscountAmount()) {
                return coupon.getMaxDiscountAmount();
            }
            return discount;
        }
        return Math.min(baseAmount, coupon.getDiscountValue());
    }

    // Hàm calculateVatAmount tính VATAmount theo VATRate lấy từ database.
    // taxableAmount là số tiền chịu thuế sau khi trừ coupon; vatRatePercent là phần trăm VAT đọc từ DB.
    // Không fix cứng mức thuế trong code để khi DB đổi VATRate thì luồng booking dùng đúng rate mới.
    public static double calculateVatAmount(double taxableAmount, double vatRatePercent) {
        return Math.max(0, taxableAmount) * vatRatePercent / 100.0;
    }

    // Hàm generateBookingCode tạo mã booking demo theo timestamp hiện tại.
    // Mã này dùng để hiển thị cho khách và lưu vào cột BookingCode.
    public static String generateBookingCode() {
        return "TB-" + System.currentTimeMillis();
    }

    // BookingDraft là object tạm lưu trong session giữa các bước create -> review -> payment.
    // Không dùng trực tiếp Booking entity vì draft cần giữ thêm tourId, couponCode, VATRate và danh sách participant trước khi tạo booking thật.
    public static class BookingDraft implements Serializable {
        // tourId xác định tour mà khách đã chọn từ trang detail.
        public int tourId;
        // scheduleId xác định lịch khởi hành khách chọn trong bảng TourSchedule.
        public int scheduleId;
        // participantCount là số người đi tour, dùng để kiểm tra chỗ trống và tính tiền.
        public int participantCount;
        // bookingId chỉ có sau khi màn review tạo booking thật trong database.
        public int bookingId;
        // bookingCode là mã đơn hiển thị cho khách và dùng trong nội dung chuyển khoản.
        public String bookingCode;
        // couponId lưu id coupon hợp lệ sau khi khách nhập ở màn payment.
        public Integer couponId;
        // couponCode lưu mã coupon đã áp dụng để có thể hiển thị lại nếu cần.
        public String couponCode;
        // customerNote lưu ghi chú riêng của khách nhập ở màn create để BookingReviewController ghi vào Booking.Notes.
        public String customerNote;
        // paymentHoldStartedAtMillis lưu thời điểm booking thật được tạo và slot bắt đầu bị giữ cho thanh toán.
        public long paymentHoldStartedAtMillis;
        // paymentExpiresAtMillis lưu mốc hết hạn giữ slot 10 phút để màn payment hiển thị bộ đếm ngược.
        public long paymentExpiresAtMillis;
        // baseAmount là tiền tour gốc trước VAT và giảm giá.
        public double baseAmount;
        // discountAmount là số tiền giảm sau khi áp dụng coupon.
        public double discountAmount;
        // vatRatePercent là phần trăm VAT đọc từ database trong Invoice.VATRate.
        public double vatRatePercent;
        // vatAmount là tiền VAT tính trên số tiền sau giảm giá.
        public double vatAmount;
        // totalAmount là tổng khách phải thanh toán.
        public double totalAmount;
        // participants là danh sách người tham gia được nhập ở màn create.
        public List<BookingParticipant> participants;
    }
}
