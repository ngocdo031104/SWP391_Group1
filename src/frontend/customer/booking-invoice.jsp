&#65279;<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%--
    Người làm: Dương
    Thời gian tạo: 25/06/2026
    Chức năng: Giao diện hiển thị hóa đơn thanh toán của khách hàng sau khi đặt tour thành công.
    Ý nghĩa: Trang này nhận dữ liệu từ CustomerInvoiceController (booking + invoice),
            hiển thị 3 phần: thông tin tour, danh sách hành khách, và chi tiết số tiền.
            Hỗ trợ in hóa đơn qua nút "In hóa đơn" sử dụng CSS @media print.
--%>
<%
    request.setAttribute("extraCss", "css/customer-booking-invoice.css");
    request.setAttribute("bodyClass", "booking-page");
%>
<jsp:include page="/common/header.jsp"/>

<main class="booking-shell">
    <%-- N&#250;t quay l&#7841;i d&#249;ng window.history.back() &#273;&#7875; tr&#7903; v&#7873; trang tr&#432;&#7899;c trong l&#7883;ch s&#7917; tr&#236;nh duy&#7879;t --%>
    <button type="button" class="booking-back-btn" onclick="window.history.back()" aria-label="Quay l&#7841;i" title="Quay l&#7841;i">
        <i data-lucide="arrow-left"></i>
    </button>

    <div class="invoice-container">
        <c:choose>
            <%-- Hi&#7875;n th&#7883; th&#244;ng b&#225;o l&#7895;i n&#7871;u controller truy&#7873;n attribute "error" (v&#237; d&#7909;: kh&#244;ng t&#236;m th&#7845;y booking) --%>
            <c:when test="${not empty error}">
                <div class="error-message"><p>${error}</p></div>
            </c:when>
            <%-- Hi&#7875;n th&#7883; th&#244;ng b&#225;o n&#7871;u h&#243;a &#273;&#417;n ch&#432;a &#273;&#432;&#7907;c t&#7841;o (webhook ch&#432;a k&#7883;p x&#7917; l&#253; ho&#7863;c payment th&#7845;t b&#7841;i) --%>
            <c:when test="${empty invoice}">
                <div class="error-message"><p>H&#243;a &#273;&#417;n ch&#432;a &#273;&#432;&#7907;c t&#7841;o ho&#7863;c kh&#244;ng t&#7891;n t&#7841;i cho &#273;&#417;n h&#224;ng n&#224;y.</p></div>
            </c:when>
            <c:otherwise>

                <%-- ===== PH&#7846;N 1: HEADER H&#211;A &#272;&#416;N ===== --%>
                <%-- Hi&#7875;n th&#7883; m&#227; h&#243;a &#273;&#417;n, ng&#224;y l&#7853;p v&#224; th&#244;ng tin li&#234;n h&#7879; th&#432;&#417;ng hi&#7879;u --%>
                <div class="invoice-header">
                    <div>
                        <h1><i data-lucide="file-text"></i> H&#211;A &#272;&#416;N THANH TO&#193;N</h1>
                        <p><strong>M&#227; h&#243;a &#273;&#417;n:</strong> ${invoice.invoiceCode}</p>
                        <p><strong>Ng&#224;y l&#7853;p:</strong>
                            <fmt:formatDate value="${invoice.issuedAt}" pattern="dd/MM/yyyy HH:mm"/>
                        </p>
                    </div>
                    <div class="invoice-brand">
                        <p class="brand-name">TourBuddy</p>
                        <p>support@tourbuddy.com</p>
                        <p><strong>M&#227; booking:</strong> ${booking.bookingCode}</p>
                    </div>
                </div>

                <%-- ===== PH&#7846;N 2: TH&#212;NG TIN TOUR ===== --%>
                <%-- Ch&#7881; hi&#7875;n th&#7883; n&#7871;u booking.schedule kh&#244;ng null (t&#7913;c l&#224; controller d&#249;ng getBookingWithTourByCode) --%>
                <c:if test="${not empty booking.schedule}">
                    <div class="invoice-section">
                        <h2 class="invoice-section-title"><i data-lucide="map-pin"></i> Th&#244;ng tin tour</h2>
                        <div class="invoice-tour-grid">
                            <div class="invoice-tour-item">
                                <span class="label">T&#234;n tour</span>
                                <span class="value">${booking.schedule.tour.tourName}</span>
                            </div>
                            <div class="invoice-tour-item">
                                <span class="label">&#272;i&#7875;m &#273;&#7871;n</span>
                                <span class="value">${booking.schedule.tour.destination}</span>
                            </div>
                            <div class="invoice-tour-item">
                                <span class="label">Ng&#224;y kh&#7903;i h&#224;nh</span>
                                <span class="value">
                                    <fmt:formatDate value="${booking.schedule.departureDate}" pattern="dd/MM/yyyy"/>
                                </span>
                            </div>
                            <div class="invoice-tour-item">
                                <span class="label">Ng&#224;y v&#7873;</span>
                                <span class="value">
                                    <fmt:formatDate value="${booking.schedule.returnDate}" pattern="dd/MM/yyyy"/>
                                </span>
                            </div>
                            <div class="invoice-tour-item">
                                <span class="label">Th&#7901;i gian</span>
                                <span class="value">${booking.schedule.tour.durationDays} ng&#224;y</span>
                            </div>
                            <%-- Ch&#7881; hi&#7879;n ph&#432;&#417;ng ti&#7879;n n&#7871;u d&#7919; li&#7879;u t&#7891;n t&#7841;i, tr&#225;nh &#244; tr&#7889;ng tr&#234;n h&#243;a &#273;&#417;n --%>
                            <c:if test="${not empty booking.schedule.transportation}">
                                <div class="invoice-tour-item">
                                    <span class="label">Ph&#432;&#417;ng ti&#7879;n</span>
                                    <span class="value">${booking.schedule.transportation}</span>
                                </div>
                            </c:if>
                            <div class="invoice-tour-item">
                                <span class="label">S&#7889; ng&#432;&#7901;i</span>
                                <span class="value">${booking.numParticipants} ng&#432;&#7901;i</span>
                            </div>
                        </div>
                    </div>
                </c:if>

                <%-- ===== PH&#7846;N 3: DANH S&#193;CH H&#192;NH KH&#193;CH ===== --%>
                <%-- L&#7863;p qua booking.participants, hi&#7875;n th&#7883; lo&#7841;i v&#233; v&#224; &#273;&#225;nh d&#7845;u tr&#432;&#7903;ng &#273;o&#224;n --%>
                <c:if test="${not empty booking.participants}">
                    <div class="invoice-section">
                        <h2 class="invoice-section-title"><i data-lucide="users"></i> Danh s&#225;ch h&#224;nh kh&#225;ch</h2>
                        <table class="invoice-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>H&#7885; t&#234;n</th>
                                    <th>Lo&#7841;i</th>
                                    <th>Li&#234;n h&#7879;</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="p" items="${booking.participants}" varStatus="s">
                                    <tr>
                                        <td>${s.index + 1}</td>
                                        <td>
                                            ${p.fullName}
                                            <%-- Badge "Tr&#432;&#7903;ng &#273;o&#224;n" ch&#7881; hi&#7879;n cho ng&#432;&#7901;i c&#243; isLeader = true --%>
                                            <c:if test="${p.isLeader}">
                                                <span class="badge-leader">Tr&#432;&#7903;ng &#273;o&#224;n</span>
                                            </c:if>
                                        </td>
                                        <td>
                                            <%-- Chuy&#7875;n AgeType t&#7915; ti&#7871;ng Anh sang ti&#7871;ng Vi&#7879;t --%>
                                            <c:choose>
                                                <c:when test="${p.ageType == 'Adult'}">Ng&#432;&#7901;i l&#7899;n</c:when>
                                                <c:when test="${p.ageType == 'Child'}">Tr&#7867; em</c:when>
                                                <c:otherwise>Em b&#233;</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <%-- &#431;u ti&#234;n hi&#7875;n th&#7883; s&#7889; &#273;i&#7879;n tho&#7841;i, n&#7871;u kh&#244;ng c&#243; th&#236; d&#249;ng email --%>
                                        <td>${not empty p.phoneNumber ? p.phoneNumber : p.email}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:if>

                <%-- ===== PH&#7846;N 4: B&#7842;NG CHI TI&#7870;T THANH TO&#193;N ===== --%>
                <%-- Hi&#7875;n th&#7883; ti&#7873;n g&#7889;c, VAT, gi&#7843;m gi&#225; (n&#7871;u c&#243;) v&#224; t&#7893;ng c&#7897;ng --%>
                <div class="invoice-section">
                    <h2 class="invoice-section-title"><i data-lucide="receipt"></i> Chi ti&#7871;t thanh to&#225;n</h2>
                    <table class="invoice-table">
                        <thead>
                            <tr>
                                <th>Kho&#7843;n m&#7909;c</th>
                                <th style="text-align: right;">S&#7889; ti&#7873;n</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Ti&#7873;n tour g&#7889;c</td>
                                <td style="text-align: right;">
                                    <fmt:formatNumber value="${invoice.subTotal}" type="number" groupingUsed="true"/> &#8363;
                                </td>
                            </tr>
                            <tr>
                                <td>Thu&#7871; VAT (${invoice.vatRate}%)</td>
                                <td style="text-align: right;">
                                    <fmt:formatNumber value="${invoice.vatAmount}" type="number" groupingUsed="true"/> &#8363;
                                </td>
                            </tr>
                            <%-- D&#242;ng gi&#7843;m gi&#225; ch&#7881; hi&#7879;n khi kh&#225;ch d&#249;ng coupon (discountAmount > 0) --%>
                            <c:if test="${invoice.discountAmount > 0}">
                                <tr class="discount-row">
                                    <td>Gi&#7843;m gi&#225; (coupon)</td>
                                    <td style="text-align: right;">
                                        - <fmt:formatNumber value="${invoice.discountAmount}" type="number" groupingUsed="true"/> &#8363;
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                        <tfoot>
                            <tr class="total-row">
                                <td><strong>T&#7893;ng c&#7897;ng</strong></td>
                                <td style="text-align: right;">
                                    <strong><fmt:formatNumber value="${invoice.totalAmount}" type="number" groupingUsed="true"/> &#8363;</strong>
                                </td>
                            </tr>
                        </tfoot>
                    </table>
                </div>

                <%-- ===== ACTIONS ===== --%>
                <%-- N&#250;t in s&#7917; d&#7909;ng window.print(), CSS @media print s&#7869; &#7849;n c&#225;c th&#224;nh ph&#7847;n kh&#244;ng c&#7847;n thi&#7871;t --%>
                <div class="invoice-actions">
                    <button class="btn-print" onclick="window.print()">
                        <i data-lucide="printer"></i> In h&#243;a &#273;&#417;n
                    </button>
                    <a class="booking-primary-btn" href="${pageContext.request.contextPath}/home">V&#7873; trang ch&#7911;</a>
                </div>

            </c:otherwise>
        </c:choose>
    </div>
</main>

<jsp:include page="/common/footer.jsp"/>
