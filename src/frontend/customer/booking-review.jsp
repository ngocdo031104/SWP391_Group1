&#65279;<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="Entities.Tour" %>
<%@ page import="Entities.TourSchedule" %>
<%@ page import="Entities.BookingParticipant" %>
<%@ page import="Controller.customer.BookingFlowSupport.BookingDraft" %>
<%--
    Người làm: Dương
    Thời gian tạo: 04/06/2026
    Chức năng: Màn Customer xác nhận chi tiết đơn đặt tour.
    Ý nghĩa: Hiển thị tour, lịch khởi hành, danh sách người đi và tổng tiền trước khi hệ thống tạo booking trong DB.
--%>
<%
    // Chỉ nạp CSS của màn review vì màn này không cần xử lý JavaScript riêng.
    request.setAttribute("extraCss", "css/customer-booking-review.css");
    request.setAttribute("bodyClass", "booking-page");

    // tour và selectedSchedule được controller đọc lại từ draft trong session để đảm bảo dữ liệu review đúng với lựa chọn trước đó.
    Tour tour = (Tour) request.getAttribute("tour");
    TourSchedule selectedSchedule = (TourSchedule) request.getAttribute("selectedSchedule");

    // draft ch&#7913;a to&#224;n b&#7897; d&#7919; li&#7879;u t&#7841;m c&#7911;a &#273;&#417;n &#273;&#7863;t tr&#432;&#7899;c khi ghi xu&#7889;ng DB: tourId, scheduleId, s&#7889; ng&#432;&#7901;i, danh s&#225;ch ng&#432;&#7901;i &#273;i v&#224; ti&#7873;n.
    BookingDraft draft = (BookingDraft) request.getAttribute("draft");

    // errorMessage hi&#7875;n th&#7883; l&#7895;i n&#7871;u draft b&#7883; thi&#7871;u, tour/l&#7883;ch kh&#244;ng c&#242;n h&#7907;p l&#7879; ho&#7863;c t&#7841;o booking th&#7845;t b&#7841;i.
    String errorMessage = (String) request.getAttribute("errorMessage");

    // money v&#224; dateFormat d&#249;ng &#273;&#7875; format s&#7889; ti&#7873;n/ng&#224;y th&#225;ng nh&#7845;t qu&#225;n tr&#234;n m&#224;n review.
    NumberFormat money = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");

    // D&#432;&#417;ng l&#224;m &#273;o&#7841;n n&#224;y: escape ghi ch&#250; tr&#432;&#7899;c khi hi&#7875;n th&#7883; &#273;&#7875; n&#7897;i dung kh&#225;ch nh&#7853;p kh&#244;ng ph&#225; v&#7905; HTML c&#7911;a m&#224;n review.
    String customerNoteDisplay = draft != null && draft.customerNote != null ? draft.customerNote : "";
    customerNoteDisplay = customerNoteDisplay.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
%>
<jsp:include page="/common/header.jsp"/>

<main class="booking-shell">
    <%-- D&#432;&#417;ng l&#224;m &#273;o&#7841;n n&#224;y: n&#250;t quay l&#7841;i d&#249;ng chung cho c&#225;c m&#224;n trong lu&#7891;ng booking &#273;&#7875; kh&#225;ch c&#243; th&#7875; tr&#7903; v&#7873; b&#432;&#7899;c tr&#432;&#7899;c. --%>
    <button type="button" class="booking-back-btn" onclick="window.location.href='${pageContext.request.contextPath}/customer/booking/create?tourId=<%= draft != null ? draft.tourId : 0 %>'" aria-label="Quay l&#7841;i b&#432;&#7899;c tr&#432;&#7899;c" title="Quay l&#7841;i b&#432;&#7899;c tr&#432;&#7899;c">
        <i data-lucide="arrow-left"></i>
    </button>
    <%-- Thanh ti&#7871;n tr&#236;nh &#273;&#225;nh d&#7845;u b&#432;&#7899;c review l&#224; b&#432;&#7899;c &#273;ang active. --%>
    <section class="booking-progress" aria-label="Ti&#7871;n tr&#236;nh &#273;&#7863;t tour">
        <div class="progress-step done"><span>1</span><strong>&#272;&#7863;t tour</strong><small>Booking creation</small></div>
        <div class="progress-line"></div>
        <div class="progress-step active"><span>2</span><strong>Chi ti&#7871;t &#273;&#417;n</strong><small>Booking review</small></div>
        <div class="progress-line"></div>
        <div class="progress-step"><span>3</span><strong>Thanh to&#225;n</strong><small>Payment processing</small></div>
        <div class="progress-line"></div>
        <div class="progress-step"><span>4</span><strong>Ho&#224;n t&#7845;t</strong><small>Success screen</small></div>
    </section>

    <div class="booking-layout">
        <section class="booking-main-panel">
            <%-- N&#7871;u BookingReviewController ph&#225;t hi&#7879;n l&#7895;i, in th&#244;ng b&#225;o &#273;&#7875; kh&#225;ch quay l&#7841;i s&#7917;a ho&#7863;c th&#7917; l&#7841;i. --%>
            <% if (errorMessage != null) { %>
                <div class="booking-alert"><i data-lucide="triangle-alert"></i><span><%= errorMessage %></span></div>
            <% } %>

            <div class="booking-heading">
                <p>M&#227; giao d&#7883;ch (Booking ID)</p>
                <h1>Chi ti&#7871;t &#273;&#417;n &#273;&#7863;t tour</h1>
                <span>Tr&#7841;ng th&#225;i &#273;&#7863;t: Ch&#7901; thanh to&#225;n &#183; Thanh to&#225;n: Ch&#432;a thanh to&#225;n</span>
            </div>

            <%-- Layout review chia th&#224;nh ph&#7847;n th&#244;ng tin tour/ng&#432;&#7901;i &#273;i b&#234;n tr&#225;i v&#224; t&#7893;ng k&#7871;t thanh to&#225;n b&#234;n ph&#7843;i. --%>
            <div class="booking-review-layout">
                <div>
                    <%-- Card tour hi&#7875;n th&#7883; l&#7883;ch tr&#236;nh &#273;&#227; ch&#7885;n &#273;&#7875; kh&#225;ch ki&#7875;m tra l&#7847;n cu&#7889;i tr&#432;&#7899;c khi t&#7841;o booking th&#7853;t. --%>
                    <div class="review-tour-card">
                        <div class="review-tour-cover">
                            <span>&#272;i&#7875;m &#273;&#7871;n n&#7893;i b&#7853;t</span>
                            <h2><%= tour != null ? tour.getTourName() : "TourBuddy" %></h2>
                            <p><%= tour != null ? tour.getDestination() : "-" %> &#183; <%= tour != null ? tour.getDurationDays() : 0 %> ng&#224;y</p>
                        </div>
                        <div class="review-info-grid">
                            <div><small>Ng&#224;y kh&#7903;i h&#224;nh</small><strong><%= selectedSchedule != null ? dateFormat.format(selectedSchedule.getDepartureDate()) : "-" %></strong></div>
                            <div><small>Ph&#432;&#417;ng th&#7913;c di chuy&#7875;n</small><strong><%= selectedSchedule != null ? selectedSchedule.getTransportation() : "-" %></strong></div>
                        </div>
                    </div>

                    <%-- Danh s&#225;ch ng&#432;&#7901;i &#273;i l&#7845;y t&#7915; draft.participants, kh&#244;ng nh&#7853;p l&#7841;i &#7903; m&#224;n n&#224;y. --%>
                    <div class="booking-section">
                        <div class="section-title"><span><i data-lucide="users"></i></span><strong>Danh s&#225;ch ng&#432;&#7901;i &#273;i (<%= draft != null ? draft.participantCount : 0 %> kh&#225;ch)</strong></div>
                        <div class="participant-review-list">
                            <% if (draft != null && draft.participants != null) { for (int i = 0; i < draft.participants.size(); i++) { BookingParticipant p = draft.participants.get(i); %>
                                <div class="participant-review-item">
                                    <strong><%= i + 1 %>. <%= p.getFullName() %></strong>
                                    <span><%= i == 0 ? "Ng&#432;&#7901;i &#273;&#7841;i di&#7879;n" : "Kh&#225;ch &#273;i c&#249;ng" %></span>
                                    <small>S&#272;T: <%= p.getPhoneNumber() %> &#183; Email: <%= p.getEmail() %></small>
                                </div>
                            <% }} %>
                        </div>
                    </div>
                </div>

                <%-- C&#7897;t b&#234;n ph&#7843;i: Coupon v&#224; T&#7893;ng k&#7871;t ti&#7873;n --%>
                <div>
                    <%-- D&#432;&#417;ng l&#224;m ph&#7847;n n&#224;y: Chuy&#7875;n form nh&#7853;p coupon sang m&#224;n h&#236;nh review --%>
                    <div class="coupon-card" style="margin-bottom: 20px; padding: 20px; background: #fff; border-radius: 8px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                        <h3 style="font-size: 1.1rem; margin-bottom: 15px; color: #1a202c;">S&#7917; d&#7909;ng m&#227; khuy&#7871;n m&#227;i</h3>
                        <form method="post" action="${pageContext.request.contextPath}/customer/booking/review" style="display: flex; gap: 10px;">
                            <input type="hidden" name="action" value="applyCoupon">
                            <input class="booking-input" type="text" name="couponCode" value="<%= draft != null && draft.couponCode != null ? draft.couponCode : "" %>" placeholder="Nh&#7853;p m&#227; v&#237; d&#7909;: WELCOME10" style="flex: 1; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px;">
                            <button type="submit" class="booking-primary-btn" style="padding: 10px 20px; background: #10b981; color: white; border: none; border-radius: 6px; cursor: pointer;">&#193;p d&#7909;ng</button>
                        </form>
                        <% if (request.getAttribute("errorMessage") != null) { %>
                            <div class="field-error" style="color: #ef4444; margin-top: 8px; font-size: 0.9rem;"><%= request.getAttribute("errorMessage") %></div>
                        <% } %>
                        <% if (request.getAttribute("successMessage") != null) { %>
                            <div style="color: #10b981; margin-top: 8px; font-size: 0.9rem;"><%= request.getAttribute("successMessage") %></div>
                        <% } %>
                    </div>

                    <%-- Th&#7867; t&#7893;ng k&#7871;t ti&#7873;n: &#7903; b&#432;&#7899;c n&#224;y coupon ch&#432;a nh&#7853;p n&#234;n gi&#7843;m gi&#225; th&#432;&#7901;ng l&#224; 0. --%>
                    <div class="review-payment-card">
                        <h3>T&#7893;ng k&#7871;t thanh to&#225;n &#273;&#417;n &#273;&#7863;t</h3>
                        <dl>
                            <div><dt>Ti&#7873;n tour c&#417; b&#7843;n</dt><dd><%= money.format(draft != null ? draft.baseAmount : 0) %> &#273;</dd></div>
                            <div><dt>Thu&#7871; VAT du l&#7883;ch (<%= draft != null ? money.format(draft.vatRatePercent) : "0" %>%)</dt><dd><%= money.format(draft != null ? draft.vatAmount : 0) %> &#273;</dd></div>
                            <div><dt>Gi&#7843;m gi&#225;</dt><dd>-<%= money.format(draft != null ? draft.discountAmount : 0) %> &#273;</dd></div>
                        </dl>
                        <div class="summary-total light"><span>T&#7893;ng thanh to&#225;n</span><strong><%= money.format(draft != null ? draft.totalAmount : 0) %> &#273;</strong></div>
                        <%-- Submit form n&#224;y m&#7899;i t&#7841;o booking trong DB r&#7891;i chuy&#7875;n sang m&#224;n payment. --%>
                        <form method="post" action="${pageContext.request.contextPath}/customer/booking/review">
                            <input type="hidden" name="action" value="confirm">
                            <button type="submit" class="booking-primary-btn full-width">Chuy&#7875;n sang thanh to&#225;n <i data-lucide="arrow-right"></i></button>
                        </form>
                    </div>
                </div>

                <%-- D&#432;&#417;ng l&#224;m &#273;o&#7841;n n&#224;y: ghi ch&#250; kh&#225;ch &#273;&#432;&#7907;c &#273;&#432;a xu&#7889;ng d&#432;&#7899;i v&#224; tr&#7843;i r&#7897;ng to&#224;n b&#7897; v&#249;ng review &#273;&#7875; kh&#244;ng b&#7883; l&#7879;ch sang c&#7897;t ph&#7843;i. --%>
                <% if (draft != null && draft.customerNote != null && !draft.customerNote.trim().isEmpty()) { %>
                    <div class="booking-section review-note-section">
                        <div class="section-title"><span><i data-lucide="message-square-text"></i></span><strong>Ghi ch&#250; c&#7911;a kh&#225;ch</strong></div>
                        <div class="participant-review-item">
                            <small><%= customerNoteDisplay %></small>
                        </div>
                    </div>
                <% } %>
            </div>
        </section>
    </div>
</main>

<jsp:include page="/common/footer.jsp"/>
