&#65279;<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%
    // D&#432;&#417;ng l&#224;m &#273;o&#7841;n n&#224;y
    // Ch&#7913;c n&#259;ng: M&#224;n h&#236;nh hi&#7875;n th&#7883; chi ti&#7871;t &#273;&#417;n &#273;&#7863;t tour cho kh&#225;ch h&#224;ng.
%>
<jsp:include page="/common/header.jsp"/>

<style>
    .detail-container {
        max-width: 1000px;
        margin: 40px auto;
        padding: 0 20px;
    }
    
    .detail-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 30px;
        padding-bottom: 15px;
        border-bottom: 2px solid #f1f5f9;
        flex-wrap: wrap;
        gap: 15px;
    }
    
    .detail-title h1 {
        font-family: 'Outfit', sans-serif;
        font-size: 1.8rem;
        color: #1e293b;
        margin: 0 0 5px 0;
    }
    
    .detail-title p {
        color: #64748b;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .status-badge {
        padding: 6px 12px;
        border-radius: 20px;
        font-size: 0.85rem;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        display: inline-block;
    }
    .status-pendingpayment { background: #fef3c7; color: #d97706; }
    .status-paid { background: #d1fae5; color: #059669; }
    .status-cancelled { background: #fee2e2; color: #dc2626; }
    .status-completed { background: #dbeafe; color: #2563eb; }
    
    .header-actions {
        display: flex;
        gap: 10px;
    }
    
    .btn-action {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 8px 16px;
        border-radius: 6px;
        font-weight: 500;
        text-decoration: none;
        transition: all 0.2s;
        border: 1px solid transparent;
        cursor: pointer;
        font-size: 0.95rem;
    }
    
    .btn-danger {
        background: #fee2e2;
        color: #dc2626;
        border-color: #fca5a5;
    }
    .btn-danger:hover {
        background: #fecaca;
        color: #b91c1c;
    }

    .btn-outline {
        background: transparent;
        border-color: #cbd5e1;
        color: #475569;
    }
    .btn-outline:hover {
        background: #f8fafc;
        border-color: #94a3b8;
        color: #1e293b;
    }
    
    .btn-primary {
        background: #3b82f6;
        color: white;
    }
    .btn-primary:hover {
        background: #2563eb;
        color: white;
    }

    .detail-grid {
        display: grid;
        grid-template-columns: 2fr 1fr;
        gap: 25px;
    }

    .card {
        background: #fff;
        border-radius: 12px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        margin-bottom: 25px;
        overflow: hidden;
    }

    .card-header {
        background: #f8fafc;
        padding: 15px 20px;
        border-bottom: 1px solid #e2e8f0;
        font-family: 'Outfit', sans-serif;
        font-weight: 600;
        color: #1e293b;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .card-header i {
        color: #64748b;
    }

    .card-body {
        padding: 20px;
    }

    /* Tour Info Styles */
    .tour-brief {
        margin-bottom: 20px;
    }
    .tour-brief h2 {
        font-size: 1.3rem;
        margin: 0 0 10px 0;
        color: #0f172a;
    }
    .info-list {
        list-style: none;
        padding: 0;
        margin: 0;
    }
    .info-list li {
        display: flex;
        margin-bottom: 12px;
    }
    .info-list span.label {
        width: 140px;
        color: #64748b;
        flex-shrink: 0;
    }
    .info-list span.value {
        color: #1e293b;
        font-weight: 500;
    }

    /* Participants Styles */
    .participant-table {
        width: 100%;
        border-collapse: collapse;
    }
    .participant-table th {
        background: #f8fafc;
        color: #64748b;
        font-weight: 500;
        text-align: left;
        padding: 10px;
        font-size: 0.9rem;
        border-bottom: 2px solid #e2e8f0;
    }
    .participant-table td {
        padding: 12px 10px;
        border-bottom: 1px solid #e2e8f0;
        color: #1e293b;
    }
    .participant-table tr:last-child td {
        border-bottom: none;
    }

    /* Payment Summary Styles */
    .payment-summary {
        margin: 0;
        padding: 0;
        list-style: none;
    }
    .payment-summary li {
        display: flex;
        justify-content: space-between;
        margin-bottom: 12px;
        color: #475569;
    }
    .payment-summary li.discount {
        color: #059669;
    }
    .payment-summary li.total {
        border-top: 2px dashed #e2e8f0;
        padding-top: 15px;
        margin-top: 5px;
        margin-bottom: 0;
        font-size: 1.25rem;
        font-weight: 700;
        color: #0f172a;
    }
    
    .payment-status-box {
        margin-top: 20px;
        padding: 15px;
        border-radius: 8px;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
    }

    .payment-status-box.success {
        background: #ecfdf5;
        border-color: #a7f3d0;
    }

    @media (max-width: 768px) {
        .detail-grid {
            grid-template-columns: 1fr;
        }
        .header-actions {
            width: 100%;
            justify-content: space-between;
        }
        .info-list span.label {
            width: 120px;
        }
        /* Responsive table */
        .participant-table { display: block; overflow-x: auto; white-space: nowrap; }
    }
</style>

<main class="detail-container">
    <div class="detail-header">
        <div class="detail-title">
            <h1>Chi Ti&#7871;t &#272;&#417;n &#272;&#7863;t: #${booking.bookingCode}</h1>
            <p>
                <i data-lucide="clock" style="width: 16px; height: 16px;"></i>
                Ng&#224;y &#273;&#7863;t: <fmt:formatDate value="${booking.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                <span style="margin: 0 10px;">|</span>
                <span class="status-badge status-${booking.status.toLowerCase()}">
                    <c:choose>
                        <c:when test="${booking.status eq 'PendingPayment'}">Ch&#7901; thanh to&#225;n</c:when>
                        <c:when test="${booking.status eq 'Success'}">Thanh to&#225;n th&#224;nh c&#244;ng</c:when>
                        <c:when test="${booking.status eq 'Cancelled'}">&#272;&#227; h&#7911;y</c:when>
                        <c:when test="${booking.status eq 'Completed'}">&#272;&#227; ho&#224;n th&#224;nh</c:when>
                        <c:otherwise>${booking.status}</c:otherwise>
                    </c:choose>
                </span>
            </p>
        </div>
        <div class="header-actions">
            <a href="${pageContext.request.contextPath}/customer/booking/history" class="btn-action btn-outline">
                <i data-lucide="arrow-left" style="width: 18px; height: 18px;"></i> Quay l&#7841;i
            </a>
            
            <%-- N&#250;t Y&#234;u c&#7847;u H&#7911;y --%>
            <c:if test="${booking.status eq 'Success'}">
                <c:choose>
                    <c:when test="${not empty pendingCancel}">
                        <span class="btn-action btn-outline" style="cursor: default; background: #f8fafc; color: #94a3b8; border-color: #e2e8f0;">
                            <i data-lucide="clock" style="width: 18px; height: 18px;"></i> &#272;ang x&#7917; l&#253; y&#234;u c&#7847;u h&#7911;y
                        </span>
                    </c:when>
                    <c:otherwise>
                        <%-- Check days before departure (server-side via jsp tags or JS) --%>
                        <jsp:useBean id="now" class="java.util.Date" />
                        <c:set var="diffInMillies" value="${booking.schedule.departureDate.time - now.time}" />
                        <c:set var="diffInDays" value="${diffInMillies / (1000 * 60 * 60 * 24)}" />
                        
                        <c:if test="${diffInDays > 7}">
                            <button type="button" class="btn-action btn-danger" onclick="openCancelModal()">
                                <i data-lucide="x-circle" style="width: 18px; height: 18px;"></i> Y&#234;u c&#7847;u h&#7911;y
                            </button>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </c:if>

            <%-- Li&#234;n k&#7871;t sang h&#243;a &#273;&#417;n: d&#7921;a v&#224;o CustomerInvoiceController --%>
            <c:if test="${booking.status ne 'Cancelled'}">
                <a href="${pageContext.request.contextPath}/customer/booking/invoice?code=${booking.bookingCode}" class="btn-action btn-primary">
                    <i data-lucide="receipt" style="width: 18px; height: 18px;"></i> Xem h&#243;a &#273;&#417;n
                </a>
            </c:if>
        </div>
    </div>

    <%-- Th&#244;ng b&#225;o k&#7871;t qu&#7843; H&#7911;y --%>
    <c:if test="${not empty sessionScope.cancelSuccess}">
        <div style="background: #ecfdf5; border: 1px solid #a7f3d0; color: #059669; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
            <i data-lucide="check-circle" style="vertical-align: middle; margin-right: 8px;"></i>
            ${sessionScope.cancelSuccess}
        </div>
        <c:remove var="cancelSuccess" scope="session" />
    </c:if>
    <c:if test="${not empty sessionScope.cancelError}">
        <div style="background: #fee2e2; border: 1px solid #fca5a5; color: #dc2626; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
            <i data-lucide="alert-circle" style="vertical-align: middle; margin-right: 8px;"></i>
            ${sessionScope.cancelError}
        </div>
        <c:remove var="cancelError" scope="session" />
    </c:if>

    <div class="detail-grid">
        <!-- C&#7897;t Tr&#225;i: Th&#244;ng tin Tour & Danh s&#225;ch kh&#225;ch -->
        <div class="main-details">
            <!-- Th&#244;ng tin Tour -->
            <div class="card">
                <div class="card-header"><i data-lucide="map"></i> Th&#244;ng tin H&#224;nh tr&#236;nh</div>
                <div class="card-body">
                    <div class="tour-brief">
                        <a href="${pageContext.request.contextPath}/customer/tourdetail?id=${booking.schedule.tour.tourId}" style="text-decoration:none;">
                            <h2>${booking.schedule.tour.tourName}</h2>
                        </a>
                    </div>
                    <ul class="info-list">
                        <li><span class="label">&#272;i&#7875;m &#273;&#7871;n:</span> <span class="value">${booking.schedule.tour.destination}</span></li>
                        <li><span class="label">Ng&#224;y &#273;i:</span> <span class="value"><fmt:formatDate value="${booking.schedule.departureDate}" pattern="dd/MM/yyyy" /></span></li>
                        <li><span class="label">Ng&#224;y v&#7873;:</span> <span class="value"><fmt:formatDate value="${booking.schedule.returnDate}" pattern="dd/MM/yyyy" /></span></li>
                        <li><span class="label">Ph&#432;&#417;ng ti&#7879;n:</span> <span class="value">${booking.schedule.transportation}</span></li>
                        <li><span class="label">S&#7889; l&#432;&#7907;ng kh&#225;ch:</span> <span class="value">${booking.numParticipants} kh&#225;ch</span></li>
                    </ul>
                </div>
            </div>

            <!-- Danh s&#225;ch h&#224;nh kh&#225;ch -->
            <div class="card">
                <div class="card-header"><i data-lucide="users"></i> Danh s&#225;ch Kh&#225;ch h&#224;ng</div>
                <div class="card-body" style="padding: 0;">
                    <table class="participant-table">
                        <thead>
                            <tr>
                                <th>H&#7885; T&#234;n</th>
                                <th>Lo&#7841;i Kh&#225;ch</th>
                                <th>Vai tr&#242;</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${booking.participants}">
                                <tr>
                                    <td style="font-weight: 500;">${p.fullName}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.ageType eq 'Adult'}">Ng&#432;&#7901;i l&#7899;n</c:when>
                                            <c:when test="${p.ageType eq 'Child'}">Tr&#7867; em</c:when>
                                            <c:when test="${p.ageType eq 'Infant'}">Em b&#233;</c:when>
                                            <c:otherwise>${p.ageType}</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.isLeader}"><span style="color:#2563eb; font-weight: 600;"><i data-lucide="user-check" style="width:14px;height:14px;"></i> Tr&#432;&#7903;ng &#273;o&#224;n</span></c:when>
                                            <c:otherwise><span style="color:#64748b;">Th&#224;nh vi&#234;n</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- Ghi ch&#250; -->
            <c:if test="${not empty booking.notes}">
                <div class="card">
                    <div class="card-header"><i data-lucide="message-square-text"></i> Ghi ch&#250; c&#7911;a b&#7841;n</div>
                    <div class="card-body">
                        <p style="margin:0; color:#475569; line-height: 1.6;">${booking.notes}</p>
                    </div>
                </div>
            </c:if>
        </div>

        <!-- C&#7897;t Ph&#7843;i: Thanh to&#225;n & T&#7893;ng ti&#7873;n -->
        <div class="side-details">
            <div class="card">
                <div class="card-header"><i data-lucide="credit-card"></i> T&#243;m t&#7855;t Thanh to&#225;n</div>
                <div class="card-body">
                    <ul class="payment-summary">
                        <li><span>Ti&#7873;n tour c&#417; b&#7843;n:</span> <span><fmt:formatNumber value="${booking.baseAmount}" pattern="#,###" /> &#8363;</span></li>
                        <c:if test="${booking.discountAmount > 0}">
                            <li class="discount"><span>Gi&#7843;m gi&#225;:</span> <span>-<fmt:formatNumber value="${booking.discountAmount}" pattern="#,###" /> &#8363;</span></li>
                        </c:if>
                        <li><span>Thu&#7871; VAT:</span> <span><fmt:formatNumber value="${booking.vatAmount}" pattern="#,###" /> &#8363;</span></li>
                        <li class="total"><span>T&#7893;ng thanh to&#225;n:</span> <span><fmt:formatNumber value="${booking.totalAmount}" pattern="#,###" /> &#8363;</span></li>
                    </ul>

                    <c:if test="${not empty payment}">
                        <div class="payment-status-box ${payment.status eq 'Success' ? 'success' : ''}">
                            <div style="font-weight:600; margin-bottom:10px; color:#1e293b;">Th&#244;ng tin giao d&#7883;ch</div>
                            <ul class="info-list" style="font-size: 0.9rem;">
                                <li><span class="label" style="width:110px;">Ph&#432;&#417;ng th&#7913;c:</span> <span class="value">${payment.paymentMethod}</span></li>
                                <li><span class="label" style="width:110px;">M&#227; GD:</span> 
                                    <span class="value" style="display:flex;align-items:center;gap:6px;">
                                        ${payment.transactionRef}
                                        <button onclick="navigator.clipboard.writeText('${payment.transactionRef}').then(()=>alert('&#272;&#227; copy m&#227; GD!'))" style="background:none;border:none;cursor:pointer;color:var(--primary);padding:0;" title="Copy m&#227; GD">
                                            <i data-lucide="copy" style="width:14px;height:14px;"></i>
                                        </button>
                                    </span>
                                </li>
                                <li><span class="label" style="width:110px;">Th&#7901;i gian:</span> <span class="value"><fmt:formatDate value="${payment.paidAt}" pattern="dd/MM/yyyy HH:mm" /></span></li>
                                <li><span class="label" style="width:110px;">Tr&#7841;ng th&#225;i:</span> <span class="value" style="${payment.status eq 'Success' ? 'color:#059669;' : 'color:#dc2626;'}">${payment.status}</span></li>
                            </ul>
                        </div>
                    </c:if>
                    
                    <c:if test="${empty payment && booking.status eq 'PendingPayment'}">
                        <div style="margin-top: 20px;">
                            <a href="${pageContext.request.contextPath}/customer/booking/payment?code=${booking.bookingCode}" class="btn-primary" style="display:block; text-align:center; padding:12px; border-radius:6px; text-decoration:none; font-weight:600;">
                                Ti&#7871;p t&#7909;c thanh to&#225;n
                            </a>
                        </div>
                    </c:if>
                </div>
            </div>

            <!-- Y&#234;u c&#7847;u h&#7911;y & Ho&#224;n ti&#7873;n (UC41) -->
            <c:if test="${not empty cancelHistory}">
                <div class="card" style="margin-top: 24px; border-color: #fca5a5;">
                    <div class="card-header" style="background: #fef2f2; color: #b91c1c; border-bottom-color: #fecaca;">
                        <i data-lucide="refresh-cw"></i> Y&#234;u c&#7847;u h&#7911;y & Ho&#224;n ti&#7873;n
                    </div>
                    <div class="card-body">
                        <c:forEach var="req" items="${cancelHistory}" varStatus="status">
                            <div style="margin-bottom: ${status.last ? '0' : '20px'}; padding-bottom: ${status.last ? '0' : '20px'}; border-bottom: ${status.last ? 'none' : '1px dashed #e2e8f0'};">
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                    <span style="font-size: 13px; color: #64748b;"><fmt:formatDate value="${req.createdAt}" pattern="dd/MM/yyyy HH:mm" /></span>
                                    
                                    <c:choose>
                                        <c:when test="${req.status eq 'Pending'}">
                                            <span style="background:#fef3c7; color:#d97706; padding:4px 10px; border-radius:99px; font-size:12px; font-weight:600;"><i data-lucide="clock" style="width:12px;height:12px;vertical-align:middle;margin-right:4px;"></i>&#272;ang ch&#7901; x&#7917; l&#253;</span>
                                        </c:when>
                                        <c:when test="${req.status eq 'Approved'}">
                                            <span style="background:#d1fae5; color:#059669; padding:4px 10px; border-radius:99px; font-size:12px; font-weight:600;"><i data-lucide="check-circle" style="width:12px;height:12px;vertical-align:middle;margin-right:4px;"></i>&#272;&#227; ho&#224;n ti&#7873;n</span>
                                        </c:when>
                                        <c:when test="${req.status eq 'Rejected'}">
                                            <span style="background:#fee2e2; color:#dc2626; padding:4px 10px; border-radius:99px; font-size:12px; font-weight:600;"><i data-lucide="x-circle" style="width:12px;height:12px;vertical-align:middle;margin-right:4px;"></i>B&#7883; t&#7915; ch&#7889;i</span>
                                        </c:when>
                                    </c:choose>
                                </div>
                                <div style="font-size: 14px; color: #334155; margin-bottom: 8px;">
                                    <strong>L&#253; do h&#7911;y:</strong> ${req.reason}
                                </div>
                                
                                <c:if test="${not empty req.notes}">
                                    <div style="background: #f8fafc; border-left: 3px solid ${req.status eq 'Approved' ? '#10b981' : '#ef4444'}; padding: 10px 12px; font-size: 13px; color: #475569;">
                                        <strong>Ghi ch&#250; t&#7915; k&#7871; to&#225;n:</strong> ${req.notes}
                                    </div>
                                </c:if>
                                
                                <c:if test="${req.status eq 'Approved'}">
                                    <div style="margin-top: 10px; font-size: 13px; color: #059669; font-weight: 500;">
                                        <i data-lucide="check" style="width:14px;height:14px;vertical-align:middle;margin-right:4px;"></i> Ti&#7873;n &#273;&#227; &#273;&#432;&#7907;c x&#7917; l&#253; ho&#224;n v&#224;o <fmt:formatDate value="${req.processedAt}" pattern="dd/MM/yyyy HH:mm" />
                                    </div>
                                </c:if>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:if>

        </div>
    </div>
</main>

<%-- Modal Y&#234;u c&#7847;u H&#7911;y --%>
<style>
    .modal-overlay {
        display: none;
        position: fixed;
        top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(15, 23, 42, 0.6);
        z-index: 1000;
        align-items: center;
        justify-content: center;
        backdrop-filter: blur(4px);
    }
    .modal-content {
        background: #fff;
        width: 100%;
        max-width: 550px;
        border-radius: 12px;
        box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        padding: 30px;
        position: relative;
    }
    .modal-close {
        position: absolute;
        top: 20px; right: 20px;
        background: none; border: none;
        color: #94a3b8; cursor: pointer;
        transition: color 0.2s;
    }
    .modal-close:hover { color: #1e293b; }
    .modal-title {
        font-family: 'Outfit', sans-serif;
        font-size: 1.5rem; color: #1e293b;
        margin: 0 0 15px 0;
    }
    .terms-box {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        padding: 15px; border-radius: 8px;
        font-size: 0.95rem; color: #475569;
        margin-bottom: 20px;
    }
    .form-group {
        margin-bottom: 15px;
    }
    .form-group label {
        display: block; margin-bottom: 6px;
        font-weight: 500; color: #334155; font-size: 0.95rem;
    }
    .form-control {
        width: 100%; padding: 10px 12px;
        border: 1px solid #cbd5e1;
        border-radius: 6px;
        font-family: inherit; font-size: 1rem;
        background: #f8fafc;
        color: #475569;
    }
    .form-control:focus { outline: none; border-color: #3b82f6; }
    textarea.form-control { resize: vertical; background: #fff; color: #1e293b; }
    .modal-actions {
        display: flex; justify-content: flex-end; gap: 10px;
        margin-top: 25px;
    }
</style>

<div class="modal-overlay" id="cancelModal">
    <div class="modal-content">
        <button class="modal-close" onclick="closeCancelModal()"><i data-lucide="x"></i></button>
        <h3 class="modal-title">Y&#234;u c&#7847;u h&#7911;y & ho&#224;n ti&#7873;n</h3>
        
        <div class="terms-box">
            <strong>&#272;i&#7873;u ki&#7879;n ho&#224;n ti&#7873;n:</strong><br/>
            B&#7841;n &#273;ang y&#234;u c&#7847;u h&#7911;y tr&#432;&#7899;c ng&#224;y kh&#7903;i h&#224;nh <b>h&#417;n 7 ng&#224;y</b>, &#273;&#7911; &#273;i&#7873;u ki&#7879;n xem x&#233;t ho&#224;n ti&#7873;n theo ch&#237;nh s&#225;ch c&#7911;a TourBuddy. Xin l&#432;u &#253; h&#7879; th&#7889;ng s&#7869; ti&#7871;p nh&#7853;n v&#224; ph&#7843;n h&#7891;i trong 2-3 ng&#224;y l&#224;m vi&#7879;c.
        </div>

        <c:set var="leaderName" value=""/>
        <c:set var="leaderPhone" value=""/>
        <c:set var="leaderEmail" value=""/>
        <c:forEach var="p" items="${booking.participants}">
            <c:if test="${p.isLeader}">
                <c:set var="leaderName" value="${p.fullName}"/>
                <c:set var="leaderPhone" value="${p.phoneNumber}"/>
                <c:set var="leaderEmail" value="${p.email}"/>
            </c:if>
        </c:forEach>

        <form action="${pageContext.request.contextPath}/customer/booking/cancel" method="post" id="cancelForm">
            <input type="hidden" name="bookingCode" value="${booking.bookingCode}">
            
            <div class="form-group">
                <label>Tr&#432;&#7903;ng &#273;o&#224;n &#273;&#7841;i di&#7879;n</label>
                <input type="text" class="form-control" value="${leaderName}" readonly>
            </div>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                <div class="form-group">
                    <label>S&#7889; &#273;i&#7879;n tho&#7841;i</label>
                    <input type="text" class="form-control" value="${leaderPhone}" readonly>
                </div>
                <div class="form-group">
                    <label>Email li&#234;n h&#7879;</label>
                    <input type="text" class="form-control" value="${leaderEmail}" readonly>
                </div>
            </div>

            <div class="form-group">
                <label>L&#253; do h&#7911;y / Ghi ch&#250; b&#7893; sung <span style="color:#dc2626;">*</span></label>
                <textarea class="form-control" name="reason" rows="3" required placeholder="Vui l&#242;ng cho ch&#250;ng t&#244;i bi&#7871;t l&#253; do b&#7841;n mu&#7889;n h&#7911;y &#273;&#417;n n&#224;y..."></textarea>
            </div>

            <div class="modal-actions">
                <button type="button" class="btn-action btn-outline" onclick="closeCancelModal()">Kh&#244;ng, quay l&#7841;i</button>
                <button type="submit" class="btn-action btn-danger" style="color: white; background: #dc2626;">X&#225;c nh&#7853;n G&#7917;i y&#234;u c&#7847;u</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openCancelModal() {
        document.getElementById('cancelModal').style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }
    function closeCancelModal() {
        document.getElementById('cancelModal').style.display = 'none';
        document.body.style.overflow = '';
    }
    // \u0110\u00f3ng modal khi click ra ngo\u00e0i
    document.getElementById('cancelModal').addEventListener('click', function(e) {
        if(e.target === this) {
            closeCancelModal();
        }
    });
</script>

<script>
    lucide.createIcons();
</script>

<jsp:include page="/common/footer.jsp"/>
