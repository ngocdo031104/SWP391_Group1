<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

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
            
            <%-- Nút Yêu cầu Hủy --%>
            <c:if test="${booking.status eq 'Success'}">
                <c:choose>
                    <c:when test="${not empty pendingCancel}">
                        <span class="btn-action btn-outline" style="cursor: default; background: #f8fafc; color: #94a3b8; border-color: #e2e8f0;">
                            <i data-lucide="clock" style="width: 18px; height: 18px;"></i> Đang xử lý yêu cầu hủy
                        </span>
                    </c:when>
                    <c:otherwise>
                        <%-- Check days before departure (server-side via jsp tags or JS) --%>
                        <jsp:useBean id="now" class="java.util.Date" />
                        <c:set var="diffInMillies" value="${booking.schedule.departureDate.time - now.time}" />
                        <c:set var="diffInDays" value="${diffInMillies / (1000 * 60 * 60 * 24)}" />
                        
                        <c:if test="${diffInDays > 7}">
                            <button type="button" class="btn-action btn-danger" onclick="openCancelModal()">
                                <i data-lucide="x-circle" style="width: 18px; height: 18px;"></i> Yêu cầu hủy
                            </button>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </c:if>

            <%-- Liên kết sang hóa đơn: dựa vào CustomerInvoiceController --%>
            <c:if test="${booking.status ne 'Cancelled'}">
                <a href="${pageContext.request.contextPath}/customer/booking/invoice?code=${booking.bookingCode}" class="btn-action btn-primary">
                    <i data-lucide="receipt" style="width: 18px; height: 18px;"></i> Xem hóa đơn
                </a>
            </c:if>
        </div>
    </div>

    <%-- Thông báo kết quả Hủy --%>
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

<%-- Modal Yêu cầu Hủy --%>
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
        <h3 class="modal-title">Yêu cầu hủy & hoàn tiền</h3>
        
        <div class="terms-box">
            <strong>Điều kiện hoàn tiền:</strong><br/>
            Bạn đang yêu cầu hủy trước ngày khởi hành <b>hơn 7 ngày</b>, đủ điều kiện xem xét hoàn tiền theo chính sách của TourBuddy. Xin lưu ý hệ thống sẽ tiếp nhận và phản hồi trong 2-3 ngày làm việc.
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
                <label>Trưởng đoàn đại diện</label>
                <input type="text" class="form-control" value="${leaderName}" readonly>
            </div>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                <div class="form-group">
                    <label>Số điện thoại</label>
                    <input type="text" class="form-control" value="${leaderPhone}" readonly>
                </div>
                <div class="form-group">
                    <label>Email liên hệ</label>
                    <input type="text" class="form-control" value="${leaderEmail}" readonly>
                </div>
            </div>

            <div class="form-group">
                <label>Lý do hủy / Ghi chú bổ sung <span style="color:#dc2626;">*</span></label>
                <textarea class="form-control" name="reason" rows="3" required placeholder="Vui lòng cho chúng tôi biết lý do bạn muốn hủy đơn này..."></textarea>
            </div>

            <div class="modal-actions">
                <button type="button" class="btn-action btn-outline" onclick="closeCancelModal()">Không, quay lại</button>
                <button type="submit" class="btn-action btn-danger" style="color: white; background: #dc2626;">Xác nhận Gửi yêu cầu</button>
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
    // Đóng modal khi click ra ngoài
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
