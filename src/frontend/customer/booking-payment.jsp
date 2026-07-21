&#65279;<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="Entities.Tour" %>
<%@ page import="Entities.TourSchedule" %>
<%@ page import="Controller.customer.BookingFlowSupport.BookingDraft" %>
<%@ page import="Utils.SepayConfig" %>
<%--
    Người làm: Dương
    Thời gian tạo: 04/06/2026
    Chức năng: Màn Customer thanh toán booking.
    Ý nghĩa: Hiển thị VietQR theo số tiền booking, cho nhập coupon nếu có và chờ webhook SePay xác nhận chuyển khoản.
--%>
<%
    // N&#7841;p CSS v&#224; JS ri&#234;ng c&#7911;a payment &#273;&#7875; x&#7917; l&#253; coupon v&#224; polling tr&#7841;ng th&#225;i thanh to&#225;n SePay.
    request.setAttribute("extraCss", "css/customer-booking-payment.css");
    request.setAttribute("extraScript", "js/customer-booking-payment.js");
    request.setAttribute("bodyClass", "booking-page");

    // tour, selectedSchedule v&#224; draft &#273;&#432;&#7907;c l&#7845;y l&#7841;i t&#7915; session draft &#273;&#7875; hi&#7875;n th&#7883; th&#244;ng tin thanh to&#225;n cho booking v&#7915;a t&#7841;o.
    Tour tour = (Tour) request.getAttribute("tour");
    TourSchedule selectedSchedule = (TourSchedule) request.getAttribute("selectedSchedule");
    BookingDraft draft = (BookingDraft) request.getAttribute("draft");

    // errorMessage d&#249;ng &#273;&#7875; b&#225;o l&#7895;i coupon ho&#7863;c th&#244;ng b&#225;o kh&#225;ch c&#7847;n qu&#233;t QR v&#224; ch&#7901; SePay x&#225;c nh&#7853;n.
    String errorMessage = (String) request.getAttribute("errorMessage");

    // &#272;&#7883;nh d&#7841;ng ti&#7873;n v&#224; ng&#224;y kh&#7903;i h&#224;nh cho ph&#7847;n t&#243;m t&#7855;t &#273;&#417;n &#273;&#7863;t.
    NumberFormat money = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");

    // D&#432;&#417;ng l&#224;m &#273;o&#7841;n n&#224;y: chu&#7849;n b&#7883; d&#7919; li&#7879;u VietQR t&#7915; booking hi&#7879;n t&#7841;i.
    // qrAmount l&#224; s&#7889; ti&#7873;n ph&#7843;i chuy&#7875;n, qrContent l&#224; n&#7897;i dung chuy&#7875;n kho&#7843;n d&#249;ng &#273;&#7875; webhook SePay match v&#7873; &#273;&#250;ng BookingCode.
    long qrAmount = Math.round(draft != null ? draft.totalAmount : 0);
    String qrContent = draft != null ? draft.bookingCode : "";
    String encodedContent = URLEncoder.encode(qrContent, StandardCharsets.UTF_8.toString());
    String encodedAccountName = URLEncoder.encode(SepayConfig.ACCOUNT_NAME, StandardCharsets.UTF_8.toString());
    String qrImageUrl = "https://img.vietqr.io/image/" + SepayConfig.BANK_CODE + "-" + SepayConfig.ACCOUNT_NO
            + "-compact2.png?amount=" + qrAmount
            + "&addInfo=" + encodedContent
            + "&accountName=" + encodedAccountName;

    // D&#432;&#417;ng l&#224;m &#273;o&#7841;n n&#224;y: paymentExpiresAtMillis l&#224; m&#7889;c h&#7871;t h&#7841;n gi&#7919; slot 10 ph&#250;t &#273;&#7875; JavaScript &#273;&#7871;m ng&#432;&#7907;c tr&#234;n m&#224;n thanh to&#225;n.
    long paymentExpiresAtMillis = draft != null ? draft.paymentExpiresAtMillis : 0;
%>
<jsp:include page="/common/header.jsp"/>

<main class="booking-shell">
    <%-- D&#432;&#417;ng l&#224;m &#273;o&#7841;n n&#224;y: n&#250;t quay l&#7841;i d&#249;ng chung cho c&#225;c m&#224;n trong lu&#7891;ng booking &#273;&#7875; kh&#225;ch c&#243; th&#7875; tr&#7903; v&#7873; b&#432;&#7899;c tr&#432;&#7899;c. --%>
    <button type="button" class="booking-back-btn" onclick="window.location.href='${pageContext.request.contextPath}/customer/booking/review'" aria-label="Quay l&#7841;i b&#432;&#7899;c tr&#432;&#7899;c" title="Quay l&#7841;i b&#432;&#7899;c tr&#432;&#7899;c">
        <i data-lucide="arrow-left"></i>
    </button>
    <%-- Thanh ti&#7871;n tr&#236;nh &#273;&#225;nh d&#7845;u b&#432;&#7899;c payment l&#224; b&#432;&#7899;c &#273;ang active. --%>
    <section class="booking-progress" aria-label="Ti&#7871;n tr&#236;nh &#273;&#7863;t tour">
        <div class="progress-step done"><span>1</span><strong>&#272;&#7863;t tour</strong><small>Booking creation</small></div>
        <div class="progress-line"></div>
        <div class="progress-step done"><span>2</span><strong>Chi ti&#7871;t &#273;&#417;n</strong><small>Booking review</small></div>
        <div class="progress-line"></div>
        <div class="progress-step active"><span>3</span><strong>Thanh to&#225;n</strong><small>Payment processing</small></div>
        <div class="progress-line"></div>
        <div class="progress-step"><span>4</span><strong>Ho&#224;n t&#7845;t</strong><small>Success screen</small></div>
    </section>

    <div class="booking-layout">
        <section class="booking-main-panel">
            <%-- L&#7895;i/th&#244;ng b&#225;o payment &#273;&#432;&#7907;c in t&#7841;i &#273;&#7847;u m&#224;n &#273;&#7875; kh&#225;ch bi&#7871;t c&#7847;n chuy&#7875;n kho&#7843;n ho&#7863;c coupon &#273;&#227; &#273;&#432;&#7907;c c&#7853;p nh&#7853;t. --%>
            <% if (errorMessage != null) { %>
                <div class="booking-alert"><i data-lucide="triangle-alert"></i><span><%= errorMessage %></span></div>
            <% } %>

            <div class="booking-heading">
                <p>Process Payment</p>
                <h1>Thanh to&#225;n &#273;&#417;n <%= draft != null ? draft.bookingCode : "" %></h1>
                <span>Qu&#233;t VietQR, chuy&#7875;n kho&#7843;n &#273;&#250;ng s&#7889; ti&#7873;n v&#224; n&#7897;i dung &#273;&#7875; SePay x&#225;c nh&#7853;n t&#7921; &#273;&#7897;ng.</span>
            </div>


            <%-- D&#432;&#417;ng l&#224;m &#273;o&#7841;n n&#224;y: b&#7897; &#273;&#7871;m ng&#432;&#7907;c cho th&#7901;i gian gi&#7919; slot 10 ph&#250;t &#7903; tr&#7841;ng th&#225;i PendingPayment. --%>
            <div class="payment-expiry-card" id="payment-expiry-card" data-expires-at="<%= paymentExpiresAtMillis %>">
                <span>Thanh to&#225;n s&#7869; h&#7871;t h&#7841;n sau: <strong id="payment-countdown-inline">10:00</strong></span>
            </div>
            <%-- Layout payment g&#7891;m VietQR b&#234;n tr&#225;i v&#224; coupon/t&#243;m t&#7855;t &#273;&#417;n b&#234;n ph&#7843;i. --%>
            <div class="payment-layout">
                <%-- Form n&#224;y ch&#7881; d&#249;ng &#273;&#7875; c&#7853;p nh&#7853;t coupon/s&#7889; ti&#7873;n QR, kh&#244;ng x&#225;c nh&#7853;n thanh to&#225;n gi&#7843; l&#7853;p. --%>
                <form method="post" action="${pageContext.request.contextPath}/customer/booking/payment" class="payment-methods" id="payment-form" novalidate>
                    <input type="hidden" name="action" value="refreshQr">
                    <input type="hidden" name="paymentMethod" value="BankTransfer">
                    <h3>Thanh to&#225;n qua VietQR</h3>

                    <%-- D&#432;&#417;ng l&#224;m &#273;o&#7841;n n&#224;y: QR &#273;&#432;&#7907;c t&#7841;o t&#7915; t&#224;i kho&#7843;n TPBank c&#7911;a b&#7841;n, s&#7889; ti&#7873;n booking v&#224; n&#7897;i dung BookingCode. --%>
                    <div class="vietqr-panel">
                        <img src="<%= qrImageUrl %>" alt="VietQR thanh to&#225;n &#273;&#417;n <%= qrContent %>">                        <div id="sepay-status-box"
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
                        <h4>Th&#244;ng tin t&#224;i kho&#7843;n th&#7909; h&#432;&#7903;ng</h4>
                        <p>Ng&#226;n h&#224;ng: <strong>Ti&#7873;n Phong Bank (TPBank)</strong></p>
                        <p>S&#7889; t&#224;i kho&#7843;n: <strong><%= SepayConfig.ACCOUNT_NO %></strong></p>
                        <p>Ch&#7911; t&#224;i kho&#7843;n: <strong><%= SepayConfig.ACCOUNT_NAME %></strong></p>

                        <p>S&#7889; ti&#7873;n: <strong><%= money.format(qrAmount) %> &#273;</strong></p>
                        <p>N&#7897;i dung chuy&#7875;n kho&#7843;n: <strong><%= qrContent %></strong></p>
                    </div>
                </form>

                <aside class="payment-side">
                    <%-- T&#243;m t&#7855;t s&#7889; ti&#7873;n hi&#7879;n t&#7841;i c&#7911;a &#273;&#417;n --%>
                    <div class="payment-summary-card">
                        <h3>T&#243;m t&#7855;t thanh to&#225;n &#273;&#417;n &#273;&#7863;t</h3>
                        <p><strong><%= tour != null ? tour.getTourName() : "TourBuddy" %></strong></p>
                        <dl>
                            <div><dt>S&#7889; l&#432;&#7907;ng th&#224;nh vi&#234;n</dt><dd><%= draft != null ? draft.participantCount : 0 %> kh&#225;ch</dd></div>
                            <div><dt>Ng&#224;y kh&#7903;i h&#224;nh</dt><dd><%= selectedSchedule != null ? dateFormat.format(selectedSchedule.getDepartureDate()) : "-" %></dd></div>
                            <div><dt>Ti&#7873;n tour g&#7889;c</dt><dd><%= money.format(draft != null ? draft.baseAmount : 0) %> &#273;</dd></div>
                            <div><dt>VAT (<%= draft != null ? money.format(draft.vatRatePercent) : "0" %>%)</dt><dd><%= money.format(draft != null ? draft.vatAmount : 0) %> &#273;</dd></div>
                            <div><dt>Gi&#7843;m gi&#225;</dt><dd>-<%= money.format(draft != null ? draft.discountAmount : 0) %> &#273;</dd></div>
                        </dl>
                        <div class="summary-total light"><span>S&#7889; ti&#7873;n c&#7847;n chuy&#7875;n</span><strong><%= money.format(draft != null ? draft.totalAmount : 0) %> &#273;</strong></div>
                    </div>
                </aside>
            </div>
        </section>
    </div>
</main>

<jsp:include page="/common/footer.jsp"/>