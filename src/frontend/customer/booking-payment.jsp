<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="Entities.Tour" %>
<%@ page import="Entities.TourSchedule" %>
<%@ page import="Controller.customer.BookingFlowSupport.BookingDraft" %>
<%@ page import="Utils.SepayConfig" %>
<%
    // Người làm: Dương
    // Thời gian tạo: 04/06/2026
    // Chức năng: Màn Customer thanh toán booking.
    // Ý nghĩa: Hiển thị VietQR theo số tiền booking, cho nhập coupon nếu có và chờ webhook SePay xác nhận chuyển khoản.

    // Nạp CSS và JS riêng của payment để xử lý coupon và polling trạng thái thanh toán SePay.
    request.setAttribute("extraCss", "css/customer-booking-payment.css");
    request.setAttribute("extraScript", "js/customer-booking-payment.js");
    request.setAttribute("bodyClass", "booking-page");

    // tour, selectedSchedule và draft được lấy lại từ session draft để hiển thị thông tin thanh toán cho booking vừa tạo.
    Tour tour = (Tour) request.getAttribute("tour");
    TourSchedule selectedSchedule = (TourSchedule) request.getAttribute("selectedSchedule");
    BookingDraft draft = (BookingDraft) request.getAttribute("draft");

    // errorMessage dùng để báo lỗi coupon hoặc thông báo khách cần quét QR và chờ SePay xác nhận.
    String errorMessage = (String) request.getAttribute("errorMessage");

    // Định dạng tiền và ngày khởi hành cho phần tóm tắt đơn đặt.
    NumberFormat money = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");

    // Dương làm đoạn này: chuẩn bị dữ liệu VietQR từ booking hiện tại.
    // qrAmount là số tiền phải chuyển, qrContent là nội dung chuyển khoản dùng để webhook SePay match về đúng BookingCode.
    long qrAmount = Math.round(draft != null ? draft.totalAmount : 0);
    String qrContent = draft != null ? draft.bookingCode : "";
    String encodedContent = URLEncoder.encode(qrContent, StandardCharsets.UTF_8.toString());
    String encodedAccountName = URLEncoder.encode(SepayConfig.ACCOUNT_NAME, StandardCharsets.UTF_8.toString());
    String qrImageUrl = "https://img.vietqr.io/image/" + SepayConfig.BANK_CODE + "-" + SepayConfig.ACCOUNT_NO
            + "-compact2.png?amount=" + qrAmount
            + "&addInfo=" + encodedContent
            + "&accountName=" + encodedAccountName;

    // Dương làm đoạn này: paymentExpiresAtMillis là mốc hết hạn giữ slot 10 phút để JavaScript đếm ngược trên màn thanh toán.
    long paymentExpiresAtMillis = draft != null ? draft.paymentExpiresAtMillis : 0;
%>
<jsp:include page="/common/header.jsp"/>

<main class="booking-shell">
    <%-- Dương làm đoạn này: nút quay lại dùng chung cho các màn trong luồng booking để khách có thể trở về bước trước. --%>
    <button type="button" class="booking-back-btn" onclick="window.location.href='${pageContext.request.contextPath}/customer/booking/review'" aria-label="Quay lại bước trước" title="Quay lại bước trước">
        <i data-lucide="arrow-left"></i>
    </button>
    <%-- Thanh tiến trình đánh dấu bước payment là bước đang active. --%>
    <section class="booking-progress" aria-label="Tiến trình đặt tour">
        <div class="progress-step done"><span>1</span><strong>Đặt tour</strong><small>Booking creation</small></div>
        <div class="progress-line"></div>
        <div class="progress-step done"><span>2</span><strong>Chi tiết đơn</strong><small>Booking review</small></div>
        <div class="progress-line"></div>
        <div class="progress-step active"><span>3</span><strong>Thanh toán</strong><small>Payment processing</small></div>
        <div class="progress-line"></div>
        <div class="progress-step"><span>4</span><strong>Hoàn tất</strong><small>Success screen</small></div>
    </section>

    <div class="booking-layout">
        <section class="booking-main-panel">
            <%-- Lỗi/thông báo payment được in tại đầu màn để khách biết cần chuyển khoản hoặc coupon đã được cập nhật. --%>
            <% if (errorMessage != null) { %>
                <div class="booking-alert"><i data-lucide="triangle-alert"></i><span><%= errorMessage %></span></div>
            <% } %>

            <div class="booking-heading">
                <p>Process Payment</p>
                <h1>Thanh toán đơn <%= draft != null ? draft.bookingCode : "" %></h1>
                <span>Quét VietQR, chuyển khoản đúng số tiền và nội dung để SePay xác nhận tự động.</span>
            </div>


            <%-- Dương làm đoạn này: bộ đếm ngược cho thời gian giữ slot 10 phút ở trạng thái PendingPayment. --%>
            <div class="payment-expiry-card" id="payment-expiry-card" data-expires-at="<%= paymentExpiresAtMillis %>">
                <span>Thanh toán sẽ hết hạn sau: <strong id="payment-countdown-inline">10:00</strong></span>
            </div>
            <%-- Layout payment gồm VietQR bên trái và coupon/tóm tắt đơn bên phải. --%>
            <div class="payment-layout">
                <%-- Form này chỉ dùng để cập nhật coupon/số tiền QR, không xác nhận thanh toán giả lập. --%>
                <form method="post" action="${pageContext.request.contextPath}/customer/booking/payment" class="payment-methods" id="payment-form" novalidate>
                    <input type="hidden" name="action" value="refreshQr">
                    <input type="hidden" name="paymentMethod" value="BankTransfer">
                    <h3>Thanh toán qua VietQR</h3>

                    <%-- Dương làm đoạn này: QR được tạo từ tài khoản TPBank của bạn, số tiền booking và nội dung BookingCode. --%>
                    <div class="vietqr-panel">
                        <img src="<%= qrImageUrl %>" alt="VietQR thanh toán đơn <%= qrContent %>">                        <div id="sepay-status-box"
                             class="sepay-status-box hidden-status"
                             data-booking-code="<%= qrContent %>"
                             data-status-url="${pageContext.request.contextPath}/customer/booking/payment-status"
                             data-success-url="${pageContext.request.contextPath}/customer/booking/success?code=<%= qrContent %>"
                             aria-hidden="true">
                            <strong></strong>
                            <span></span>
                        </div>
                    </div>

                    <div class="bank-info-box">
                        <h4>Thông tin tài khoản thụ hưởng</h4>
                        <p>Ngân hàng: <strong>Tiền Phong Bank (TPBank)</strong></p>
                        <p>Số tài khoản: <strong><%= SepayConfig.ACCOUNT_NO %></strong></p>
                        <p>Chủ tài khoản: <strong><%= SepayConfig.ACCOUNT_NAME %></strong></p>
                        <p>Số tiền: <strong><%= money.format(qrAmount) %> đ</strong></p>
                        <p>Nội dung chuyển khoản: <strong><%= qrContent %></strong></p>
                    </div>
                </form>

                <aside class="payment-side">
                    <%-- Tóm tắt số tiền hiện tại của đơn --%>
                    <div class="payment-summary-card">
                        <h3>Tóm tắt thanh toán đơn đặt</h3>
                        <p><strong><%= tour != null ? tour.getTourName() : "TourBuddy" %></strong></p>
                        <dl>
                            <div><dt>Số lượng thành viên</dt><dd><%= draft != null ? draft.participantCount : 0 %> khách</dd></div>
                            <div><dt>Ngày khởi hành</dt><dd><%= selectedSchedule != null ? dateFormat.format(selectedSchedule.getDepartureDate()) : "-" %></dd></div>
                            <div><dt>Tiền tour gốc</dt><dd><%= money.format(draft != null ? draft.baseAmount : 0) %> đ</dd></div>
                            <div><dt>VAT (<%= draft != null ? money.format(draft.vatRatePercent) : "0" %>%)</dt><dd><%= money.format(draft != null ? draft.vatAmount : 0) %> đ</dd></div>
                            <div><dt>Giảm giá</dt><dd>-<%= money.format(draft != null ? draft.discountAmount : 0) %> đ</dd></div>
                        </dl>
                        <div class="summary-total light"><span>Số tiền cần chuyển</span><strong><%= money.format(draft != null ? draft.totalAmount : 0) %> đ</strong></div>
                    </div>
                </aside>
            </div>
        </section>
    </div>
</main>

<jsp:include page="/common/footer.jsp"/>