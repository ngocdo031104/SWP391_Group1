<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%--
    Người làm: Dương
    Thời gian tạo: 04/06/2026
    Chức năng: Màn hình xem chi tiết một đơn đặt tour.
    Ý nghĩa: Hiển thị toàn bộ thông tin của một booking cụ thể gồm:
             - Thông tin hành trình (tên tour, ngày đi, ngày về, phương tiện)
             - Danh sách hành khách tham gia
             - Ghi chú của khách hàng
             - Tóm tắt thanh toán (tiền gốc, giảm giá, VAT, tổng cộng)
             - Thông tin giao dịch thanh toán
             - Lịch sử yêu cầu hủy và trạng thái hoàn tiền (UC41)
             - Modal form gửi yêu cầu hủy tour (UC26)
--%>
<%-- Nhúng header dùng chung --%>
<jsp:include page="/common/header.jsp"/>

<%-- ===================== CSS ===================== --%>
<style>
    body {
        padding-top: 80px;
    }
    .header {
        background: linear-gradient(135deg, #4f46e5, #3b82f6) !important;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1) !important;
    }

    /* Vùng chứa toàn bộ nội dung chi tiết booking */
    .detail-container {
        max-width: 1000px;
        margin: 40px auto;
        padding: 0 20px;
    }
    
    /* Phần tiêu đề trang chứa mã đơn, ngày đặt, trạng thái và các nút hành động */
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
    
    /* Badge hiển thị trạng thái booking */
    .status-badge {
        padding: 6px 12px;
        border-radius: 20px;
        font-size: 0.85rem;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        display: inline-block;
    }
    /* Màu sắc tương ứng với từng trạng thái */
    .status-pendingpayment { background: #fef3c7; color: #d97706; }
    .status-paid { background: #d1fae5; color: #059669; }
    .status-cancelled { background: #fee2e2; color: #dc2626; }
    .status-completed { background: #dbeafe; color: #2563eb; }
    
    /* Khu vực các nút hành động ở góc phải tiêu đề */
    .header-actions {
        display: flex;
        gap: 10px;
    }
    
    /* Style chung cho các nút hành động */
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
    
    /* Nút nguy hiểm (màu đỏ) dùng cho hành động hủy tour */
    .btn-danger {
        background: #fee2e2;
        color: #dc2626;
        border-color: #fca5a5;
    }
    .btn-danger:hover {
        background: #fecaca;
        color: #b91c1c;
    }

    /* Nút viền (outline) dùng cho quay lại */
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
    
    /* Nút chính (màu xanh) dùng cho xem hóa đơn và tiếp tục thanh toán */
    .btn-primary {
        background: #3b82f6;
        color: white;
    }
    .btn-primary:hover {
        background: #2563eb;
        color: white;
    }

    /* Layout 2 cột: cột trái (thông tin tour & hành khách) và cột phải (thanh toán) */
    .detail-grid {
        display: grid;
        grid-template-columns: 2fr 1fr;
        gap: 25px;
    }

    /* Card chứa từng nhóm thông tin */
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

    /* Style danh sách thông tin (label - value) */
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

    /* Bảng danh sách hành khách tham gia */
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

    /* Danh sách tóm tắt thanh toán (tiền gốc, giảm giá, VAT, tổng) */
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
    /* Dòng giảm giá hiển thị màu xanh lá */
    .payment-summary li.discount {
        color: #059669;
    }
    /* Dòng tổng tiền nổi bật hơn */
    .payment-summary li.total {
        border-top: 2px dashed #e2e8f0;
        padding-top: 15px;
        margin-top: 5px;
        margin-bottom: 0;
        font-size: 1.25rem;
        font-weight: 700;
        color: #0f172a;
    }
    
    /* Hộp hiển thị thông tin giao dịch thanh toán */
    .payment-status-box {
        margin-top: 20px;
        padding: 15px;
        border-radius: 8px;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
    }

    /* Khi giao dịch thành công, nền xanh lá nhạt */
    .payment-status-box.success {
        background: #ecfdf5;
        border-color: #a7f3d0;
    }

    /* Responsive: trên màn hình nhỏ chuyển sang layout 1 cột */
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
        /* Bảng hành khách cuộn ngang khi màn hình nhỏ */
        .participant-table { display: block; overflow-x: auto; white-space: nowrap; }
    }
</style>

<%-- ===================== NỘI DUNG CHÍNH ===================== --%>
<main class="detail-container">

    <%-- Phần tiêu đề: hiển thị mã đơn, ngày đặt, trạng thái và các nút hành động --%>
    <div class="detail-header">
        <div class="detail-title">
            <h1>Chi Tiết Đơn Đặt: #${booking.bookingCode}</h1>
            <p>
                <i data-lucide="clock" style="width: 16px; height: 16px;"></i>
                Ngày đặt: <fmt:formatDate value="${booking.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                <span style="margin: 0 10px;">|</span>
                <%-- Badge trạng thái booking --%>
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

        <%-- Khu vực nút hành động --%>
        <div class="header-actions">

            <%-- Nút quay lại trang lịch sử đặt tour --%>
            <a href="${pageContext.request.contextPath}/customer/booking/history" class="btn-action btn-outline">
                <i data-lucide="arrow-left" style="width: 18px; height: 18px;"></i> Quay lại
            </a>
            
            <%-- Nút yêu cầu hủy: chỉ hiển thị khi booking đang ở trạng thái Success --%>
            <c:if test="${booking.status eq 'Success'}">
                <c:choose>
                    <%-- Nếu đã có yêu cầu hủy đang chờ xử lý, hiển thị nút bị vô hiệu hóa --%>
                    <c:when test="${not empty pendingCancel}">
                        <span class="btn-action btn-outline" style="cursor: default; background: #f8fafc; color: #94a3b8; border-color: #e2e8f0;">
                            <i data-lucide="clock" style="width: 18px; height: 18px;"></i> Đang xử lý yêu cầu hủy
                        </span>
                    </c:when>
                    <c:otherwise>
                        <%-- Tính số ngày còn lại trước ngày khởi hành để kiểm tra điều kiện hủy --%>
                        <jsp:useBean id="now" class="java.util.Date" />
                        <c:set var="diffInMillies" value="${booking.schedule.departureDate.time - now.time}" />
                        <c:set var="diffInDays" value="${diffInMillies / (1000 * 60 * 60 * 24)}" />
                        
                        <%-- Chỉ hiển thị nút hủy nếu còn hơn 7 ngày trước ngày khởi hành (theo policy UC26) --%>
                        <c:if test="${diffInDays > 7}">
                            <button type="button" class="btn-action btn-danger" onclick="openCancelModal()">
                                <i data-lucide="x-circle" style="width: 18px; height: 18px;"></i> Yêu cầu hủy
                            </button>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </c:if>

            <%-- Nút xem hóa đơn: ẩn đi nếu booking đã bị hủy --%>
            <c:if test="${booking.status ne 'Cancelled'}">
                <a href="${pageContext.request.contextPath}/customer/booking/invoice?code=${booking.bookingCode}" class="btn-action btn-primary">
                    <i data-lucide="receipt" style="width: 18px; height: 18px;"></i> Xem hóa đơn
                </a>
            </c:if>
        </div>
    </div>

    <%-- Thông báo phản hồi sau khi gửi yêu cầu hủy --%>
    <c:if test="${not empty sessionScope.cancelSuccess}">
        <div style="background: #ecfdf5; border: 1px solid #a7f3d0; color: #059669; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
            <i data-lucide="check-circle" style="vertical-align: middle; margin-right: 8px;"></i>
            ${sessionScope.cancelSuccess}
        </div>
        <c:remove var="cancelSuccess" scope="session" />
    </c:if>
    <%-- Thông báo lỗi khi gửi yêu cầu hủy thất bại --%>
    <c:if test="${not empty sessionScope.cancelError}">
        <div style="background: #fee2e2; border: 1px solid #fca5a5; color: #dc2626; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
            <i data-lucide="alert-circle" style="vertical-align: middle; margin-right: 8px;"></i>
            ${sessionScope.cancelError}
        </div>
        <c:remove var="cancelError" scope="session" />
    </c:if>

    <%-- Layout 2 cột --%>
    <div class="detail-grid">

        <%-- ===== CỘT TRÁI: Thông tin tour & Danh sách hành khách ===== --%>
        <div class="main-details">

            <%-- Card 1: Thông tin hành trình (tên tour, điểm đến, ngày đi/về, phương tiện, số khách) --%>
            <div class="card">
                <div class="card-header"><i data-lucide="map"></i> Thông tin Hành trình</div>
                <div class="card-body">
                    <div class="tour-brief">
                        <%-- Tên tour là liên kết dẫn sang trang chi tiết tour --%>
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

            <%-- Card 2: Danh sách hành khách tham gia cùng booking --%>
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
                            <%-- Lặp qua từng hành khách trong danh sách --%>
                            <c:forEach var="p" items="${booking.participants}">
                                <tr>
                                    <td style="font-weight: 500;">${p.fullName}</td>
                                    <%-- Hiển thị nhóm tuổi bằng tiếng Việt --%>
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.ageType eq 'Adult'}">Người lớn</c:when>
                                            <c:when test="${p.ageType eq 'Child'}">Trẻ em</c:when>
                                            <c:when test="${p.ageType eq 'Infant'}">Em bé</c:when>
                                            <c:otherwise>${p.ageType}</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <%-- Đánh dấu Trưởng đoàn (isLeader = true) --%>
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
            
            <%-- Card 3: Ghi chú của khách hàng (chỉ hiển thị nếu có nội dung) --%>
            <c:if test="${not empty booking.notes}">
                <div class="card">
                    <div class="card-header"><i data-lucide="message-square-text"></i> Ghi chú của bạn</div>
                    <div class="card-body">
                        <p style="margin:0; color:#475569; line-height: 1.6;">${booking.notes}</p>
                    </div>
                </div>
            </c:if>
        </div>

        <%-- ===== CỘT PHẢI: Tóm tắt thanh toán & Lịch sử yêu cầu hủy ===== --%>
        <div class="side-details">

            <%-- Card thanh toán: tóm tắt các khoản tiền --%>
            <div class="card">
                <div class="card-header"><i data-lucide="credit-card"></i> Tóm tắt Thanh toán</div>
                <div class="card-body">
                    <ul class="payment-summary">
                        <%-- Tiền tour gốc trước giảm giá và VAT --%>
                        <li><span>Tiền tour cơ bản:</span> <span><fmt:formatNumber value="${booking.baseAmount}" pattern="#,###" /> ₫</span></li>
                        <%-- Dòng giảm giá: chỉ hiển thị nếu có áp dụng coupon --%>
                        <c:if test="${booking.discountAmount > 0}">
                            <li class="discount"><span>Giảm giá:</span> <span>-<fmt:formatNumber value="${booking.discountAmount}" pattern="#,###" /> ₫</span></li>
                        </c:if>
                        <%-- Tiền VAT --%>
                        <li><span>Thuế VAT:</span> <span><fmt:formatNumber value="${booking.vatAmount}" pattern="#,###" /> ₫</span></li>
                        <%-- Tổng tiền khách cần thanh toán --%>
                        <li class="total"><span>Tổng thanh toán:</span> <span><fmt:formatNumber value="${booking.totalAmount}" pattern="#,###" /> ₫</span></li>
                    </ul>

                    <%-- Thông tin giao dịch: chỉ hiển thị nếu đã có bản ghi Payment trong DB --%>
                    <c:if test="${not empty payment}">
                        <div class="payment-status-box ${payment.status eq 'Success' ? 'success' : ''}">
                            <div style="font-weight:600; margin-bottom:10px; color:#1e293b;">Thông tin giao dịch</div>
                            <ul class="info-list" style="font-size: 0.9rem;">
                                <li><span class="label" style="width:110px;">Phương thức:</span> <span class="value">${payment.paymentMethod}</span></li>
                                <%-- Mã giao dịch có nút copy nhanh --%>
                                <li><span class="label" style="width:110px;">Mã GD:</span> 
                                    <span class="value" style="display:flex;align-items:center;gap:6px;">
                                        ${payment.transactionRef}
                                        <button onclick="navigator.clipboard.writeText('${payment.transactionRef}').then(()=>alert('Đã copy mã GD!'))" style="background:none;border:none;cursor:pointer;color:var(--primary);padding:0;" title="Copy mã GD">
                                            <i data-lucide="copy" style="width:14px;height:14px;"></i>
                                        </button>
                                    </span>
                                </li>
                                <li><span class="label" style="width:110px;">Thời gian:</span> <span class="value"><fmt:formatDate value="${payment.paidAt}" pattern="dd/MM/yyyy HH:mm" /></span></li>
                                <li><span class="label" style="width:110px;">Trạng thái:</span> <span class="value" style="${payment.status eq 'Success' ? 'color:#059669;' : 'color:#dc2626;'}">${payment.status}</span></li>
                            </ul>
                        </div>
                    </c:if>
                    
                    <%-- Nút tiếp tục thanh toán: hiển thị khi booking chờ thanh toán và chưa có bản ghi Payment --%>
                    <c:if test="${empty payment && booking.status eq 'PendingPayment'}">
                        <div style="margin-top: 20px;">
                            <a href="${pageContext.request.contextPath}/customer/booking/payment?code=${booking.bookingCode}" class="btn-primary" style="display:block; text-align:center; padding:12px; border-radius:6px; text-decoration:none; font-weight:600;">
                                Tiếp tục thanh toán
                            </a>
                        </div>
                    </c:if>
                </div>
            </div>

            <%-- Card lịch sử yêu cầu hủy & hoàn tiền (UC41): chỉ hiển thị nếu có yêu cầu hủy --%>
            <c:if test="${not empty cancelHistory}">
                <div class="card" style="margin-top: 24px; border-color: #fca5a5;">
                    <div class="card-header" style="background: #fef2f2; color: #b91c1c; border-bottom-color: #fecaca;">
                        <i data-lucide="refresh-cw"></i> Yêu cầu hủy & Hoàn tiền
                    </div>
                    <div class="card-body">
                        <%-- Lặp qua từng yêu cầu hủy đã gửi (có thể có nhiều lần) --%>
                        <c:forEach var="req" items="${cancelHistory}" varStatus="status">
                            <div style="margin-bottom: ${status.last ? '0' : '20px'}; padding-bottom: ${status.last ? '0' : '20px'}; border-bottom: ${status.last ? 'none' : '1px dashed #e2e8f0'};">
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                    <%-- Thời gian gửi yêu cầu hủy --%>
                                    <span style="font-size: 13px; color: #64748b;"><fmt:formatDate value="${req.createdAt}" pattern="dd/MM/yyyy HH:mm" /></span>
                                    
                                    <%-- Badge trạng thái yêu cầu hủy --%>
                                    <c:choose>
                                        <c:when test="${req.status eq 'Pending'}">
                                            <span style="background:#fef3c7; color:#d97706; padding:4px 10px; border-radius:99px; font-size:12px; font-weight:600;"><i data-lucide="clock" style="width:12px;height:12px;vertical-align:middle;margin-right:4px;"></i>Đang chờ xử lý</span>
                                        </c:when>
                                        <c:when test="${req.status eq 'Approved'}">
                                            <span style="background:#d1fae5; color:#059669; padding:4px 10px; border-radius:99px; font-size:12px; font-weight:600;"><i data-lucide="check-circle" style="width:12px;height:12px;vertical-align:middle;margin-right:4px;"></i>Đã hoàn tiền</span>
                                        </c:when>
                                        <c:when test="${req.status eq 'Rejected'}">
                                            <span style="background:#fee2e2; color:#dc2626; padding:4px 10px; border-radius:99px; font-size:12px; font-weight:600;"><i data-lucide="x-circle" style="width:12px;height:12px;vertical-align:middle;margin-right:4px;"></i>Bị từ chối</span>
                                        </c:when>
                                    </c:choose>
                                </div>
                                <%-- Lý do hủy do khách nhập --%>
                                <div style="font-size: 14px; color: #334155; margin-bottom: 8px;">
                                    <strong>Lý do hủy:</strong> ${req.reason}
                                </div>
                                
                                <%-- Ghi chú từ kế toán sau khi duyệt hoặc từ chối --%>
                                <c:if test="${not empty req.notes}">
                                    <div style="background: #f8fafc; border-left: 3px solid ${req.status eq 'Approved' ? '#10b981' : '#ef4444'}; padding: 10px 12px; font-size: 13px; color: #475569;">
                                        <strong>Ghi chú từ kế toán:</strong> ${req.notes}
                                    </div>
                                </c:if>
                                
                                <%-- Nếu yêu cầu đã được duyệt, hiển thị thời điểm hoàn tiền --%>
                                <c:if test="${req.status eq 'Approved'}">
                                    <div style="margin-top: 10px; font-size: 13px; color: #059669; font-weight: 500;">
                                        <i data-lucide="check" style="width:14px;height:14px;vertical-align:middle;margin-right:4px;"></i> Tiền đã được xử lý hoàn vào <fmt:formatDate value="${req.processedAt}" pattern="dd/MM/yyyy HH:mm" />
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

<%-- ===================== MODAL YÊU CẦU HỦY TOUR (UC26) ===================== --%>
<style>
    /* Lớp phủ mờ nền khi modal mở */
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
    /* Hộp nội dung chính của modal */
    .modal-content {
        background: #fff;
        width: 100%;
        max-width: 550px;
        border-radius: 12px;
        box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        padding: 30px;
        position: relative;
    }
    /* Nút X đóng modal ở góc trên phải */
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
    /* Hộp thông tin điều kiện hoàn tiền */
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

<%-- Nội dung modal form gửi yêu cầu hủy tour --%>
<div class="modal-overlay" id="cancelModal">
    <div class="modal-content">
        <%-- Nút đóng modal --%>
        <button class="modal-close" onclick="closeCancelModal()"><i data-lucide="x"></i></button>
        <h3 class="modal-title">Yêu cầu hủy & hoàn tiền</h3>
        
        <%-- Thông báo điều kiện policy hoàn tiền 7 ngày --%>
        <div class="terms-box">
            <strong>Điều kiện hoàn tiền:</strong><br/>
            Bạn đang yêu cầu hủy trước ngày khởi hành <b>hơn 7 ngày</b>, đủ điều kiện xem xét hoàn tiền theo chính sách của TourBuddy. Xin lưu ý hệ thống sẽ tiếp nhận và phản hồi trong 2-3 ngày làm việc.
        </div>

        <%-- Lấy thông tin trưởng đoàn để điền sẵn vào form --%>
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

        <%-- Form gửi yêu cầu hủy đến CustomerBookingCancelController --%>
        <form action="${pageContext.request.contextPath}/customer/booking/cancel" method="post" id="cancelForm">
            <%-- Truyền bookingCode để controller xác định đơn cần hủy --%>
            <input type="hidden" name="bookingCode" value="${booking.bookingCode}">
            
            <%-- Thông tin trưởng đoàn (chỉ đọc, lấy từ danh sách hành khách) --%>
            <div class="form-group">
                <label>Trưởng đoàn đại diện</label>
                <input type="text" class="form-control" value="${leaderName}" readonly>
            </div>
            
            <%-- Số điện thoại và email trưởng đoàn để liên lạc hoàn tiền --%>
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

            <%-- Trường bắt buộc: lý do hủy tour --%>
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

<%-- ===================== JAVASCRIPT ===================== --%>
<script>
    // Mở modal yêu cầu hủy tour
    function openCancelModal() {
        document.getElementById('cancelModal').style.display = 'flex';
        document.body.style.overflow = 'hidden'; // Khóa cuộn trang khi modal mở
    }

    // Đóng modal yêu cầu hủy tour
    function closeCancelModal() {
        document.getElementById('cancelModal').style.display = 'none';
        document.body.style.overflow = ''; // Cho phép cuộn trang lại
    }

    // Đóng modal khi người dùng click vào vùng nền bên ngoài hộp modal
    document.getElementById('cancelModal').addEventListener('click', function(e) {
        if(e.target === this) {
            closeCancelModal();
        }
    });
</script>

<script>
    lucide.createIcons();
</script>

<%-- Nhúng footer dùng chung --%>
<jsp:include page="/common/footer.jsp"/>
