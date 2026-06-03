<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="Entities.Tour" %>
<%@ page import="Entities.TourSchedule" %>
<%@ page import="Controller.customer.BookingFlowSupport.BookingDraft" %>
<%
    // Người làm: Dương
    // Thời gian tạo: 04/06/2026
    // Chức năng: Màn Customer thanh toán booking.
    // Ý nghĩa: Chọn phương thức thanh toán, nhập coupon nếu có, sau đó tạo payment và xác nhận booking.

    // Nạp CSS và JS riêng của payment để xử lý coupon ở đúng màn thanh toán.
    request.setAttribute("extraCss", "css/customer-booking-payment.css");
    request.setAttribute("extraScript", "js/customer-booking-payment.js");
    request.setAttribute("bodyClass", "booking-page");

    // tour, selectedSchedule và draft được lấy lại từ session draft để hiển thị thông tin thanh toán cho booking vừa tạo.
    Tour tour = (Tour) request.getAttribute("tour");
    TourSchedule selectedSchedule = (TourSchedule) request.getAttribute("selectedSchedule");
    BookingDraft draft = (BookingDraft) request.getAttribute("draft");

    // errorMessage dùng để báo lỗi coupon, lỗi phương thức thanh toán hoặc lỗi tạo payment.
    String errorMessage = (String) request.getAttribute("errorMessage");

    // Định dạng tiền và ngày khởi hành cho phần tóm tắt đơn đặt.
    NumberFormat money = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
%>
<jsp:include page="/common/header.jsp"/>

<main class="booking-shell">
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
            <%-- Lỗi payment được in tại đầu màn để khách biết cần sửa coupon hoặc phương thức thanh toán. --%>
            <% if (errorMessage != null) { %>
                <div class="booking-alert"><i data-lucide="triangle-alert"></i><span><%= errorMessage %></span></div>
            <% } %>

            <div class="booking-heading">
                <p>Process Payment</p>
                <h1>Thanh toán đơn <%= draft != null ? draft.bookingCode : "" %></h1>
                <span>Chọn phương thức thanh toán và nhập coupon nếu có.</span>
            </div>

            <%-- Layout payment gồm form phương thức thanh toán bên trái và coupon/tóm tắt đơn bên phải. --%>
            <div class="payment-layout">
                <%-- Form payment gửi về BookingPaymentController để tạo bản ghi Payment và cập nhật trạng thái Booking. --%>
                <form method="post" action="${pageContext.request.contextPath}/customer/booking/payment" class="payment-methods" id="payment-form" novalidate>
                    <input type="hidden" name="action" value="pay">
                    <h3>Chọn phương thức thanh toán</h3>
                    <div class="payment-option-grid">
                        <label><input type="radio" name="paymentMethod" value="CreditCard"> Thẻ tín dụng</label>
                        <label><input type="radio" name="paymentMethod" value="BankTransfer" checked> Chuyển khoản</label>
                        <label><input type="radio" name="paymentMethod" value="MoMo"> MoMo Wallet</label>
                        <label><input type="radio" name="paymentMethod" value="VNPay"> Cổng VNPay</label>
                    </div>
                    <div class="bank-info-box">
                        <h4>Thông tin tài khoản thụ hưởng</h4>
                        <p>Ngân hàng: <strong>Vietcombank (VCB)</strong></p>
                        <p>Số tài khoản: <strong>1023456789</strong></p>
                        <p>Chủ tài khoản: <strong>CONG TY CO PHAN TOURBUDDY</strong></p>
                        <p>Nội dung chuyển khoản: <strong><%= draft != null ? draft.bookingCode : "" %></strong></p>
                    </div>
                </form>

                <aside class="payment-side">
                    <%-- Coupon chỉ xuất hiện ở màn payment theo yêu cầu, không nằm ở màn tạo booking. --%>
                    <div class="coupon-card">
                        <h3>Sử dụng mã khuyến mãi</h3>
                        <div class="coupon-row">
                            <input class="booking-input" type="text" name="couponCode" id="payment-coupon-code" form="payment-form" placeholder="Nhập mã ví dụ: WELCOME10">
                            <button type="button" id="coupon-preview-btn">Áp dụng</button>
                        </div>
                        <div class="field-error" id="coupon-error"></div>
                    </div>

                    <%-- Tóm tắt số tiền hiện tại của đơn; khi submit, controller sẽ tính lại coupon lần cuối ở server. --%>
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
                        <div class="summary-total light"><span>Thành tiền chung</span><strong><%= money.format(draft != null ? draft.totalAmount : 0) %> đ</strong></div>
                        <button type="submit" form="payment-form" class="booking-primary-btn full-width">Thực hiện thanh toán ngay</button>
                    </div>
                </aside>
            </div>
        </section>
    </div>
</main>

<jsp:include page="/common/footer.jsp"/>
