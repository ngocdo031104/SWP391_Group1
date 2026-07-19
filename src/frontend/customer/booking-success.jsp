&#65279;<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="Entities.Booking" %>

<%
    // Người làm: Dương
    // Thời gian tạo: 04/06/2026
    // Chức năng: Màn Customer hoàn tất booking.
    // Ý nghĩa: Hiển thị mã booking, tên tour, số tiền và ngày khởi hành sau khi SePay ghi nhận thanh toán.

    // Nạp CSS riêng cho màn success và giữ bodyClass booking-page để dùng chung layout booking.
    request.setAttribute("extraCss", "css/customer-booking-success.css");
    request.setAttribute("bodyClass", "booking-page");

    // bookingCode được BookingSuccessController lấy từ query string để khách lưu lại mã giao dịch.
    String bookingCode = (String) request.getAttribute("bookingCode");
    Booking booking = (Booking) request.getAttribute("booking");

    NumberFormat money = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");

    String tourName = "-";
    String destination = "-";
    int durationDays = 0;
    java.util.Date departureDate = null;
    java.util.Date returnDate = null;
    int numParticipants = 0;
    double baseAmount = 0;
    double vatAmount = 0;
    double discountAmount = 0;
    double totalAmount = 0;

    if (booking != null) {
        if (booking.getSchedule() != null && booking.getSchedule().getTour() != null) {
            tourName = booking.getSchedule().getTour().getTourName();
            destination = booking.getSchedule().getTour().getDestination();
            durationDays = booking.getSchedule().getTour().getDurationDays();
        }
        if (booking.getSchedule() != null) {
            departureDate = booking.getSchedule().getDepartureDate();
            returnDate = booking.getSchedule().getReturnDate();
        }
        numParticipants = booking.getNumParticipants();
        baseAmount = booking.getBaseAmount();
        vatAmount = booking.getVatAmount();
        discountAmount = booking.getDiscountAmount();
        totalAmount = booking.getTotalAmount();
    }
%>
<jsp:include page="/common/header.jsp"/>

<main class="booking-shell">
    <%-- Nút quay lại dùng chung cho các màn trong luồng booking để khách có thể trở về trang chủ. --%>
    <button type="button" class="booking-back-btn" onclick="window.location.href='${pageContext.request.contextPath}/home'" aria-label="Về trang chủ" title="Về trang chủ">
        <i data-lucide="arrow-left"></i>
    </button>
    <%-- Thanh tiến trình đánh dấu toàn bộ các bước đã hoàn tất. --%>
    <section class="booking-progress" aria-label="Tiến trình đặt tour">
        <div class="progress-step done"><span>1</span><strong>Đặt tour</strong><small>Booking creation</small></div>
        <div class="progress-line"></div>
        <div class="progress-step done"><span>2</span><strong>Chi tiết đơn</strong><small>Booking review</small></div>
        <div class="progress-line"></div>
        <div class="progress-step done"><span>3</span><strong>Thanh toán</strong><small>Payment processing</small></div>
        <div class="progress-line"></div>
        <div class="progress-step active done"><span>4</span><strong>Hoàn tất</strong><small>Success screen</small></div>
    </section>

    <div class="booking-layout">
        <%-- Khối thông báo thành công hiển thị mã booking để khách đối chiếu khi cần hỗ trợ. --%>
        <section class="booking-main-panel success-box">
            <i data-lucide="badge-check"></i>
            <h1>Đã ghi nhận thanh toán</h1>
            <p>Mã booking của bạn là <strong><%= bookingCode != null ? bookingCode : "" %></strong>. Đơn đã được ghi nhận thanh toán và chuyển sang trạng thái Success.</p>
        </section>

        <%-- Khối tóm tắt đơn đặt: tên tour, ngày khởi hành, số thành viên, chi tiết tiền. --%>
        <% if (booking != null) { %>
            <section class="payment-summary-card" style="margin-top: 1.5rem; max-width: 720px; margin-left: auto; margin-right: auto;">
                <h3>Chi tiết đơn đặt của bạn</h3>
                <p style="font-weight: 600; margin-bottom: 1rem;"><%= tourName %></p>
                <dl>
                    <div><dt>Điểm đến</dt><dd><%= destination %></dd></div>
                    <div><dt>Thời lượng</dt><dd><%= durationDays %> ngày</dd></div>
                    <div><dt>Số lượng thành viên</dt><dd><%= numParticipants %> khách</dd></div>
                    <div><dt>Ngày khởi hành</dt><dd><%= departureDate != null ? dateFormat.format(departureDate) : "-" %></dd></div>
                    <div><dt>Ngày về</dt><dd><%= returnDate != null ? dateFormat.format(returnDate) : "-" %></dd></div>
                    <div><dt>Tiền tour gốc</dt><dd><%= money.format(baseAmount) %> đ</dd></div>
                    <div><dt>VAT</dt><dd><%= money.format(vatAmount) %> đ</dd></div>
                    <div><dt>Giảm giá</dt><dd>-<%= money.format(discountAmount) %> đ</dd></div>
                </dl>
                <div class="summary-total light"><span>Tổng đã thanh toán</span><strong><%= money.format(totalAmount) %> đ</strong></div>
                <div style="display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap; margin-top: 1.25rem;">
                    <a class="booking-primary-btn inline-link" href="${pageContext.request.contextPath}/customer/booking/invoice?code=<%= bookingCode %>">
                        <i data-lucide="file-text" style="width:16px;height:16px;vertical-align:middle;margin-right:6px;"></i>Xem hóa đơn
                    </a>
                    <a class="booking-primary-btn inline-link" href="${pageContext.request.contextPath}/home">Về trang chủ</a>
                </div>
            </section>
        <% } else { %>
            <div style="display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap; margin-top: 1rem;">
                <a class="booking-primary-btn inline-link" href="${pageContext.request.contextPath}/customer/booking/invoice?code=<%= bookingCode %>">
                    <i data-lucide="file-text" style="width:16px;height:16px;vertical-align:middle;margin-right:6px;"></i>Xem hóa đơn
                </a>
                <a class="booking-primary-btn inline-link" href="${pageContext.request.contextPath}/home">Về trang chủ</a>
            </div>
        <% } %>
    </div>
</main>

<jsp:include page="/common/footer.jsp"/>