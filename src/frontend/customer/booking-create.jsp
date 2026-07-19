&#65279;<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
&#65279;
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="Entities.Tour" %>
<%@ page import="Entities.TourSchedule" %>
<%
    // Ng&#432;&#7901;i l&#224;m: D&#432;&#417;ng
    // Th&#7901;i gian t&#7841;o: 04/06/2026
    // Ch&#7913;c n&#259;ng: M&#224;n Customer t&#7841;o booking cho tour &#273;&#227; ch&#7885;n.
    // &#221; ngh&#297;a: Ch&#7881; hi&#7875;n th&#7883; l&#7883;ch kh&#7903;i h&#224;nh c&#7911;a tour hi&#7879;n t&#7841;i, nh&#7853;p s&#7889; ng&#432;&#7901;i v&#224; th&#244;ng tin ng&#432;&#7901;i tham gia; kh&#244;ng nh&#7853;p coupon &#7903; b&#432;&#7899;c n&#224;y.

    // Khai b&#225;o CSS/JS ri&#234;ng cho m&#224;n t&#7841;o booking &#273;&#7875; header.jsp t&#7921; nh&#250;ng &#273;&#250;ng t&#224;i nguy&#234;n c&#7911;a trang n&#224;y.
    request.setAttribute("extraCss", "css/customer-booking-create.css");
    request.setAttribute("extraScript", "js/customer-booking-create.js");
    request.setAttribute("bodyClass", "booking-page");

    // tour l&#224; tour &#273;&#227; &#273;&#432;&#7907;c ch&#7885;n t&#7915; trang detail th&#244;ng qua tourId, d&#249;ng &#273;&#7875; hi&#7875;n th&#7883; t&#234;n tour v&#224; gi&#225; tham kh&#7843;o.
    Tour tour = (Tour) request.getAttribute("tour");

    // schedules l&#224; danh s&#225;ch l&#7883;ch kh&#7903;i h&#224;nh thu&#7897;c tour hi&#7879;n t&#7841;i, d&#249;ng &#273;&#7875; kh&#225;ch ch&#7885;n ng&#224;y &#273;i c&#7909; th&#7875;.
    List<TourSchedule> schedules = (List<TourSchedule>) request.getAttribute("schedules");

    // errorMessage nh&#7853;n l&#7895;i validate t&#7915; controller, v&#237; d&#7909; ch&#432;a ch&#7885;n l&#7883;ch ho&#7863;c th&#244;ng tin ng&#432;&#7901;i &#273;i ch&#432;a h&#7907;p l&#7879;.
    String errorMessage = (String) request.getAttribute("errorMessage");

    // money &#273;&#7883;nh d&#7841;ng s&#7889; ti&#7873;n theo ki&#7875;u Vi&#7879;t Nam; dateFormat &#273;&#7883;nh d&#7841;ng ng&#224;y &#273;&#7875; ng&#432;&#7901;i d&#249;ng d&#7877; &#273;&#7885;c.
    NumberFormat money = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");

    // today l&#224; ng&#224;y hi&#7879;n t&#7841;i (00:00:00) &#273;&#7875; so s&#225;nh v&#7899;i DepartureDate &#7903; client.
    // BR-19 / BR-20: t&#7847;ng b&#7843;o v&#7879; cu&#7889;i c&#249;ng &#8212; n&#7871;u v&#236; l&#253; do g&#236; controller/DAO ch&#432;a filter,
    // JSP v&#7851;n disable radio c&#243; DepartureDate &#7903; qu&#225; kh&#7913;.
    java.util.Calendar todayCal = java.util.Calendar.getInstance();
    todayCal.set(java.util.Calendar.HOUR_OF_DAY, 0);
    todayCal.set(java.util.Calendar.MINUTE, 0);
    todayCal.set(java.util.Calendar.SECOND, 0);
    todayCal.set(java.util.Calendar.MILLISECOND, 0);
    long todayMillis = todayCal.getTimeInMillis();

    // hasSchedules quy&#7871;t &#273;&#7883;nh c&#243; cho submit form hay kh&#244;ng; sideBase l&#224; gi&#225; g&#7889;c hi&#7875;n th&#7883; &#7903; th&#7867; t&#7893;ng quan b&#234;n ph&#7843;i.
    boolean hasSchedules = schedules != null && !schedules.isEmpty();
    double sideBase = tour != null ? tour.getBasePrice() : 0;

    // D&#432;&#417;ng l&#224;m &#273;o&#7841;n n&#224;y: gi&#7919; l&#7841;i ghi ch&#250; kh&#225;ch &#273;&#227; nh&#7853;p n&#7871;u submit form b&#7883; l&#7895;i validate server-side.
    String customerNoteValue = request.getParameter("customerNote") != null ? request.getParameter("customerNote") : "";
    customerNoteValue = customerNoteValue.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
%>
<jsp:include page="/common/header.jsp"/>

<main class="booking-shell">
    <%-- D&#432;&#417;ng l&#224;m &#273;o&#7841;n n&#224;y: n&#250;t quay l&#7841;i d&#249;ng chung cho c&#225;c m&#224;n trong lu&#7891;ng booking &#273;&#7875; kh&#225;ch c&#243; th&#7875; tr&#7903; v&#7873; b&#432;&#7899;c tr&#432;&#7899;c. --%>
    <button type="button" class="booking-back-btn" onclick="window.location.href='${pageContext.request.contextPath}<%= tour != null ? "/detail?id=" + tour.getTourId() : "/tourdiscovery" %>'" aria-label="Quay l&#7841;i b&#432;&#7899;c tr&#432;&#7899;c" title="Quay l&#7841;i b&#432;&#7899;c tr&#432;&#7899;c">
        <i data-lucide="arrow-left"></i>
    </button>
    <%-- Thanh ti&#7871;n tr&#236;nh cho bi&#7871;t kh&#225;ch &#273;ang &#7903; b&#432;&#7899;c t&#7841;o booking trong lu&#7891;ng 4 b&#432;&#7899;c. --%>
    <section class="booking-progress" aria-label="Ti&#7871;n tr&#236;nh &#273;&#7863;t tour">
        <div class="progress-step active"><span>1</span><strong>&#272;&#7863;t tour</strong><small>Booking creation</small></div>
        <div class="progress-line"></div>
        <div class="progress-step"><span>2</span><strong>Chi ti&#7871;t &#273;&#417;n</strong><small>Booking review</small></div>
        <div class="progress-line"></div>
        <div class="progress-step"><span>3</span><strong>Thanh to&#225;n</strong><small>Payment processing</small></div>
        <div class="progress-line"></div>
        <div class="progress-step"><span>4</span><strong>Ho&#224;n t&#7845;t</strong><small>Success screen</small></div>
    </section>

    <div class="booking-layout">
        <section class="booking-main-panel">
            <%-- N&#7871;u controller tr&#7843; l&#7895;i, in l&#7895;i ngay ph&#237;a tr&#234;n form &#273;&#7875; kh&#225;ch bi&#7871;t c&#7847;n s&#7917;a g&#236;. --%>
            <% if (errorMessage != null) { %>
                <div class="booking-alert"><i data-lucide="triangle-alert"></i><span><%= errorMessage %></span></div>
            <% } %>

            <%-- Ph&#7847;n heading x&#225;c nh&#7853;n tour &#273;&#227; &#273;&#432;&#7907;c l&#7845;y t&#7915; trang detail, kh&#244;ng cho ch&#7885;n l&#7841;i &#273;i&#7875;m &#273;&#7871;n. --%>
            <div class="booking-heading">
                <p>Thi&#7871;t l&#7853;p &#273;&#417;n &#273;&#7863;t tour</p>
                <h1><%= tour != null ? tour.getTourName() : "TourBuddy" %></h1>
                <span>Tour &#273;&#227; &#273;&#432;&#7907;c ch&#7885;n t&#7915; trang chi ti&#7871;t. B&#7841;n ch&#7881; c&#7847;n ch&#7885;n l&#7883;ch kh&#7903;i h&#224;nh v&#224; nh&#7853;p th&#244;ng tin &#273;o&#224;n.</span>
            </div>

            <%-- Form g&#7917;i v&#7873; BookingCreateController &#273;&#7875; validate r&#7891;i l&#432;u booking draft v&#224;o session. --%>
            <form method="post" action="${pageContext.request.contextPath}/customer/booking/create" id="booking-create-form" data-base-price="<%= sideBase %>" novalidate>
                <input type="hidden" name="action" value="review">
                <input type="hidden" name="tourId" value="<%= tour != null ? tour.getTourId() : 0 %>">

                <div class="booking-section" id="schedule-section">
                    <div class="section-title"><span>1</span><strong>L&#7883;ch kh&#7903;i h&#224;nh mong mu&#7889;n</strong></div>
                    <%-- Kh&#7889;i l&#7883;ch kh&#7903;i h&#224;nh: m&#7895;i schedule &#273;&#432;&#7907;c render th&#224;nh radio &#273;&#7875; kh&#225;ch ch&#7885;n &#273;&#250;ng ng&#224;y &#273;i. --%>
                    <div class="schedule-grid">
                        <% if (hasSchedules) { %>
                            <% for (int i = 0; i < schedules.size(); i++) { TourSchedule schedule = schedules.get(i);
                                boolean isPast = schedule.getDepartureDate() != null && schedule.getDepartureDate().getTime() < todayMillis;
                            %>
                                <label class="schedule-card <%= isPast ? "schedule-card-past" : "" %>">
                                    <input type="radio" name="scheduleId" value="<%= schedule.getScheduleId() %>" data-price-adult="<%= schedule.getPriceAdult() %>" data-price-child="<%= schedule.getPriceChild() %>" data-price-infant="<%= schedule.getPriceInfant() %>" data-departure-ms="<%= schedule.getDepartureDate() != null ? schedule.getDepartureDate().getTime() : 0 %>" <%= isPast ? "disabled" : (i == 0 ? "checked" : "") %>>
                                    <strong><%= dateFormat.format(schedule.getDepartureDate()) %></strong>
                                    <span><%= dateFormat.format(schedule.getDepartureDate()) %> - <%= dateFormat.format(schedule.getReturnDate()) %></span>
                                    <small><%= schedule.getAvailableSeats() %> ch&#7895; tr&#7889;ng<%= isPast ? " (&#273;&#227; qua)" : "" %></small>
                                </label>
                            <% } %>
                        <% } else { %>
                            <div class="empty-state">Tour n&#224;y ch&#432;a c&#243; l&#7883;ch kh&#7903;i h&#224;nh &#273;ang m&#7903;. Vui l&#242;ng ch&#7885;n tour kh&#225;c ho&#7863;c li&#234;n h&#7879; nh&#226;n vi&#234;n h&#7895; tr&#7907;.</div>
                        <% } %>
                    </div>
                    <div class="field-error" id="schedule-error"></div>
                </div>

                <%-- Kh&#7889;i s&#7889; l&#432;&#7907;ng ng&#432;&#7901;i &#273;i: JS s&#7869; t&#259;ng/gi&#7843;m s&#7889; form ng&#432;&#7901;i tham gia theo participantCount. --%>
                <div class="booking-section">
                    <div class="section-title"><span>2</span><strong>S&#7889; l&#432;&#7907;ng ng&#432;&#7901;i tham gia</strong></div>
                    <div class="participant-counter">
                        <button type="button" id="minus-participant" aria-label="Gi&#7843;m s&#7889; ng&#432;&#7901;i">-</button>
                        <input type="number" name="participantCount" id="participant-count" min="1" max="<%= tour != null && tour.getMaxParticipants() > 0 ? tour.getMaxParticipants() : 10 %>" value="1" readonly>
                        <button type="button" id="plus-participant" aria-label="T&#259;ng s&#7889; ng&#432;&#7901;i">+</button>
                    </div>
                    <p class="booking-note">Tour gi&#7899;i h&#7841;n t&#7889;i &#273;a <%= tour != null && tour.getMaxParticipants() > 0 ? tour.getMaxParticipants() : 10 %> ng&#432;&#7901;i cho m&#7895;i &#273;&#417;n &#273;&#7875; &#273;&#7843;m b&#7843;o ch&#7845;t l&#432;&#7907;ng ph&#7909;c v&#7909;.</p>
                    <%-- participant-list l&#224; v&#249;ng JS customer-booking-create.js sinh form ng&#432;&#7901;i tham gia theo participantCount. --%>
                    <div id="participant-list" class="participant-list"></div>
                </div>


                <%-- D&#432;&#417;ng l&#224;m &#273;o&#7841;n n&#224;y: ghi ch&#250; ri&#234;ng c&#7911;a kh&#225;ch &#273;&#432;&#7907;c l&#432;u v&#224;o Booking.Notes sau khi &#273;&#417;n &#273;&#432;&#7907;c t&#7841;o &#7903; b&#432;&#7899;c review. --%>
                <div class="booking-section">
                    <div class="section-title"><span>3</span><strong>Ghi ch&#250; cho &#273;&#417;n &#273;&#7863;t tour</strong></div>
                    <div class="booking-note-field">
                        <textarea name="customerNote" id="customer-note" maxlength="500" rows="2" aria-label="Ghi ch&#250; cho &#273;&#417;n &#273;&#7863;t tour" wrap="soft" style="display:block;width:100%;max-width:none;box-sizing:border-box;resize:none;overflow:hidden;white-space:pre-wrap;word-break:break-word;" placeholder="V&#237; d&#7909;: c&#7847;n h&#7895; tr&#7907; xe &#273;&#432;a &#273;&#243;n, &#259;n chay, &#273;i c&#249;ng ng&#432;&#7901;i l&#7899;n tu&#7893;i..."><%= customerNoteValue %></textarea>
                    </div>
                </div>
                <button type="submit" class="booking-primary-btn" <%= hasSchedules ? "" : "disabled" %>>
                    X&#225;c nh&#7853;n th&#244;ng tin &#273;&#7863;t tour
                    <i data-lucide="arrow-right"></i>
                </button>
            </form>
        </section>

        <%-- Th&#7867; t&#7893;ng quan gi&#250;p kh&#225;ch ki&#7875;m tra nhanh tour v&#224; gi&#225; tham kh&#7843;o tr&#432;&#7899;c khi nh&#7853;p th&#244;ng tin. --%>
        <aside class="booking-summary">
            <div class="summary-card">
                <small>T&#7893;ng quan &#273;&#417;n &#273;&#7863;t</small>
                <h2><%= tour != null ? tour.getTourName() : "TourBuddy" %></h2>
                <dl>
                    <div><dt>&#272;i&#7875;m &#273;&#7871;n</dt><dd><%= tour != null ? tour.getDestination() : "-" %></dd></div>
                    <div><dt>Th&#7901;i gian</dt><dd><%= tour != null ? tour.getDurationDays() : 0 %> ng&#224;y</dd></div>
                    <div><dt>Ng&#432;&#7901;i l&#7899;n</dt><dd><span id="summary-adult-count">1</span> x <span id="summary-adult-price"><%= money.format(sideBase) %></span> &#273;</dd></div>
                    <div><dt>Tr&#7867; em</dt><dd><span id="summary-child-count">0</span> x <span id="summary-child-price">0</span> &#273;</dd></div>
                    <div><dt>Tr&#7867; s&#417; sinh</dt><dd><span id="summary-infant-count">0</span> x <span id="summary-infant-price">0</span> &#273;</dd></div>
                </dl>
                <div class="summary-total"><span>T&#7841;m t&#237;nh ti&#7873;n tour</span><strong id="summary-base-amount"><%= money.format(sideBase) %> &#273;</strong></div>
            </div>
        </aside>
    </div>
</main>

<jsp:include page="/common/footer.jsp"/>
