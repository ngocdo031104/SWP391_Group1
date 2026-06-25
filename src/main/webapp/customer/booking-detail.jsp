<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%
    // Dương làm đoạn này
    // Chức năng: Màn hình hiển thị chi tiết đơn đặt tour cho khách hàng.
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
            <h1>Chi Tiết Đơn Đặt: #${booking.bookingCode}</h1>
            <p>
                <i data-lucide="clock" style="width: 16px; height: 16px;"></i>
                Ngày đặt: <fmt:formatDate value="${booking.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                <span style="margin: 0 10px;">|</span>
                <span class="status-badge status-${booking.status.toLowerCase()}">
                    <c:choose>
                        <c:when test="${booking.status eq 'PendingPayment'}">Chờ thanh toán</c:when>
                        <c:when test="${booking.status eq 'Success'}">Thanh toán thành công</c:when>
                        <c:when test="${booking.status eq 'Cancelled'}">Đã hủy</c:when>
                        <c:when test="${booking.status eq 'Completed'}">Đã hoàn thành</c:when>
                        <c:otherwise>${booking.status}</c:otherwise>
                    </c:choose>
                </span>
            </p>
        </div>
        <div class="header-actions">
            <a href="${pageContext.request.contextPath}/customer/booking/history" class="btn-action btn-outline">
                <i data-lucide="arrow-left" style="width: 18px; height: 18px;"></i> Quay lại
            </a>
            <%-- Liên kết sang hóa đơn: dựa vào CustomerInvoiceController --%>
            <c:if test="${booking.status ne 'Cancelled'}">
                <a href="${pageContext.request.contextPath}/customer/booking/invoice?code=${booking.bookingCode}" class="btn-action btn-primary">
                    <i data-lucide="receipt" style="width: 18px; height: 18px;"></i> Xem hóa đơn
                </a>
            </c:if>
        </div>
    </div>

    <div class="detail-grid">
        <!-- Cột Trái: Thông tin Tour & Danh sách khách -->
        <div class="main-details">
            <!-- Thông tin Tour -->
            <div class="card">
                <div class="card-header"><i data-lucide="map"></i> Thông tin Hành trình</div>
                <div class="card-body">
                    <div class="tour-brief">
                        <a href="${pageContext.request.contextPath}/customer/tourdetail?id=${booking.schedule.tour.tourId}" style="text-decoration:none;">
                            <h2>${booking.schedule.tour.tourName}</h2>
                        </a>
                    </div>
                    <ul class="info-list">
                        <li><span class="label">Điểm đến:</span> <span class="value">${booking.schedule.tour.destination}</span></li>
                        <li><span class="label">Ngày đi:</span> <span class="value"><fmt:formatDate value="${booking.schedule.departureDate}" pattern="dd/MM/yyyy" /></span></li>
                        <li><span class="label">Ngày về:</span> <span class="value"><fmt:formatDate value="${booking.schedule.returnDate}" pattern="dd/MM/yyyy" /></span></li>
                        <li><span class="label">Phương tiện:</span> <span class="value">${booking.schedule.transportation}</span></li>
                        <li><span class="label">Số lượng khách:</span> <span class="value">${booking.numParticipants} khách</span></li>
                    </ul>
                </div>
            </div>

            <!-- Danh sách hành khách -->
            <div class="card">
                <div class="card-header"><i data-lucide="users"></i> Danh sách Khách hàng</div>
                <div class="card-body" style="padding: 0;">
                    <table class="participant-table">
                        <thead>
                            <tr>
                                <th>Họ Tên</th>
                                <th>Loại Khách</th>
                                <th>Vai trò</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${booking.participants}">
                                <tr>
                                    <td style="font-weight: 500;">${p.fullName}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.ageType eq 'Adult'}">Người lớn</c:when>
                                            <c:when test="${p.ageType eq 'Child'}">Trẻ em</c:when>
                                            <c:when test="${p.ageType eq 'Infant'}">Em bé</c:when>
                                            <c:otherwise>${p.ageType}</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.isLeader}"><span style="color:#2563eb; font-weight: 600;"><i data-lucide="user-check" style="width:14px;height:14px;"></i> Trưởng đoàn</span></c:when>
                                            <c:otherwise><span style="color:#64748b;">Thành viên</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- Ghi chú -->
            <c:if test="${not empty booking.notes}">
                <div class="card">
                    <div class="card-header"><i data-lucide="message-square-text"></i> Ghi chú của bạn</div>
                    <div class="card-body">
                        <p style="margin:0; color:#475569; line-height: 1.6;">${booking.notes}</p>
                    </div>
                </div>
            </c:if>
        </div>

        <!-- Cột Phải: Thanh toán & Tổng tiền -->
        <div class="side-details">
            <div class="card">
                <div class="card-header"><i data-lucide="credit-card"></i> Tóm tắt Thanh toán</div>
                <div class="card-body">
                    <ul class="payment-summary">
                        <li><span>Tiền tour cơ bản:</span> <span><fmt:formatNumber value="${booking.baseAmount}" pattern="#,###" /> ₫</span></li>
                        <c:if test="${booking.discountAmount > 0}">
                            <li class="discount"><span>Giảm giá:</span> <span>-<fmt:formatNumber value="${booking.discountAmount}" pattern="#,###" /> ₫</span></li>
                        </c:if>
                        <li><span>Thuế VAT:</span> <span><fmt:formatNumber value="${booking.vatAmount}" pattern="#,###" /> ₫</span></li>
                        <li class="total"><span>Tổng thanh toán:</span> <span><fmt:formatNumber value="${booking.totalAmount}" pattern="#,###" /> ₫</span></li>
                    </ul>

                    <c:if test="${not empty payment}">
                        <div class="payment-status-box ${payment.status eq 'Success' ? 'success' : ''}">
                            <div style="font-weight:600; margin-bottom:10px; color:#1e293b;">Thông tin giao dịch</div>
                            <ul class="info-list" style="font-size: 0.9rem;">
                                <li><span class="label" style="width:110px;">Phương thức:</span> <span class="value">${payment.paymentMethod}</span></li>
                                <li><span class="label" style="width:110px;">Mã GD:</span> <span class="value">${payment.transactionRef}</span></li>
                                <li><span class="label" style="width:110px;">Thời gian:</span> <span class="value"><fmt:formatDate value="${payment.paidAt}" pattern="dd/MM/yyyy HH:mm" /></span></li>
                                <li><span class="label" style="width:110px;">Trạng thái:</span> <span class="value" style="${payment.status eq 'Success' ? 'color:#059669;' : 'color:#dc2626;'}">${payment.status}</span></li>
                            </ul>
                        </div>
                    </c:if>
                    
                    <c:if test="${empty payment && booking.status eq 'PendingPayment'}">
                        <div style="margin-top: 20px;">
                            <a href="${pageContext.request.contextPath}/customer/booking/payment?code=${booking.bookingCode}" class="btn-primary" style="display:block; text-align:center; padding:12px; border-radius:6px; text-decoration:none; font-weight:600;">
                                Tiếp tục thanh toán
                            </a>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
    lucide.createIcons();
</script>

<jsp:include page="/common/footer.jsp"/>
