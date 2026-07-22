<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%--
    Người làm: Dương
    Ngày tạo file: 2026-07-21
    Ý nghĩa: Giao diện quản lý yêu cầu hoàn tiền (Refund Management).
    Hiển thị danh sách các yêu cầu hủy tour cần hoàn tiền, cho phép Kế toán thực hiện Duyệt (kèm ghi chú/mã giao dịch) hoặc Từ chối (kèm lý do).
--%>

<c:if test="${empty sessionScope.sessionUser
    || (sessionScope.sessionUser.role.roleName ne 'Accountant'
    && sessionScope.sessionUser.role.roleName ne 'Admin')}">
    <c:redirect url="/login"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>X&#7917; L&#253; Ho&#224;n Ti&#7873;n &#8212; TourBuddy</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=1.6">
    <style>
        :root {
            --primary: #2563EB; --primary-light: #EFF6FF;
            --success: #10B981; --success-light: #D1FAE5;
            --warning: #F59E0B; --warning-light: #FEF3C7;
            --danger: #EF4444;  --danger-light: #FEE2E2;
            --gray-50: #F8FAFC; --gray-100: #F1F5F9; --gray-200: #E2E8F0;
            --gray-500: #64748B; --gray-700: #334155; --gray-900: #0F172A;
        }
        body.dashboard-body { background: var(--gray-50); font-family: 'Inter', sans-serif; }
        /* Filter & Tabs */
        .filter-container { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; border-bottom: 1px solid var(--gray-200); padding-bottom: 12px; gap: 20px; flex-wrap: wrap; }
        .tabs { display: flex; gap: 8px; }
        .tab-btn { padding: 10px 20px; font-weight: 600; font-size: 14px; border-radius: 8px; border: none; cursor: pointer; text-decoration: none; display: flex; align-items: center; gap: 8px; color: var(--gray-500); background: transparent; transition: all .2s; }
        .tab-btn:hover { background: var(--gray-100); color: var(--gray-900); }
        .tab-btn.active { background: #FEE2E2; color: #EF4444; }

        /* Table */
        .modern-card { background: #fff; border-radius: 16px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); border: 1px solid var(--gray-100); overflow: hidden; }
        .modern-table { width: 100%; border-collapse: collapse; }
        .modern-table th { background: var(--gray-50); padding: 14px 20px; text-align: left; font-size: 12px; font-weight: 600; color: var(--gray-500); text-transform: uppercase; letter-spacing: .5px; border-bottom: 1px solid var(--gray-200); }
        .modern-table td { padding: 14px 20px; border-bottom: 1px solid var(--gray-100); color: var(--gray-700); vertical-align: middle; font-size: 14px; }
        .modern-table tr:last-child td { border-bottom: none; }
        .modern-table tr:hover { background: var(--gray-50); }

        .booking-code { font-family: monospace; font-weight: 700; color: var(--primary); font-size: 13px; }
        .customer-name { font-weight: 600; color: var(--gray-900); }
        .customer-email { font-size: 12px; color: var(--gray-500); }
        .amount { font-weight: 700; color: #EF4444; }
        
        .badge { padding: 4px 10px; border-radius: 999px; font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 4px; white-space: nowrap; }
        .badge-pending { background: var(--warning-light); color: var(--warning); }
        .badge-approved { background: var(--success-light); color: var(--success); }
        .badge-rejected { background: var(--danger-light); color: var(--danger); }

        .btn-modern { padding: 8px 16px; border-radius: 8px; font-weight: 600; font-size: 13px; display: inline-flex; align-items: center; gap: 6px; border: none; cursor: pointer; transition: all .2s; }
        .btn-success { background: var(--success); color: white; }
        .btn-success:hover { background: #059669; }
        .btn-danger { background: var(--danger); color: white; }
        .btn-danger:hover { background: #DC2626; }
        .btn-outline { background: white; color: var(--gray-700); border: 1px solid var(--gray-200); }
        .btn-outline:hover { background: var(--gray-50); }

        /* Modal */
        .modal-overlay { position: fixed; inset: 0; background: rgba(15,23,42,.5); backdrop-filter: blur(4px); z-index: 1000; display: none; align-items: center; justify-content: center; }
        .modal-overlay.open { display: flex; }
        .modal-box { background: #fff; border-radius: 16px; width: 650px; max-width: 95vw; box-shadow: 0 25px 50px rgba(0,0,0,.15); }
        .modal-header { padding: 20px 24px; border-bottom: 1px solid var(--gray-200); display: flex; justify-content: space-between; align-items: center; }
        .modal-header.success h3 { color: var(--success); }
        .modal-header.danger h3 { color: var(--danger); }
        .modal-body { padding: 24px; }
        .modal-footer { padding: 16px 24px; border-top: 1px solid var(--gray-200); display: flex; justify-content: flex-end; gap: 10px; }
        
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; font-size: 13px; font-weight: 600; color: var(--gray-700); margin-bottom: 6px; }
        .form-control { width: 100%; box-sizing: border-box; padding: 10px 14px; border: 1px solid var(--gray-200); border-radius: 8px; font-family: inherit; font-size: 14px; outline: none; }
        textarea.form-control { resize: none; }
        .form-control:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-light); }
        .readonly-value { font-weight: 600; color: var(--gray-900); font-size: 16px; }
        
        .empty-state { text-align: center; padding: 60px 20px; }
        .empty-state svg { width: 64px; height: 64px; color: var(--gray-200); margin-bottom: 16px; }
        .empty-state h3 { color: var(--gray-500); margin: 0 0 8px; font-weight: 600; }

        /* Toast */
        .toast { position: fixed; top: 20px; right: 20px; z-index: 9999; padding: 14px 20px; border-radius: 10px; font-weight: 600; font-size: 14px; display: flex; align-items: center; gap: 10px; box-shadow: 0 10px 25px rgba(0,0,0,.15); }
        .toast.success { background: var(--success); color: white; }
        .toast.error   { background: var(--danger);  color: white; }
    </style>
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <c:set var="isAccountant" value="true" scope="request"/>
    <%@ include file="/admin/sidebar.jsp" %>

    <main class="main-content">
        <div class="content-area" style="padding: 28px 36px;">
            <div class="page-header" style="margin-bottom:24px;">
                <div>
                    <h1 style="margin:0;font-size:24px;font-weight:700;color:var(--gray-900);">X&#7917; L&#253; Ho&#224;n Ti&#7873;n</h1>
                    <p style="margin:4px 0 0;color:var(--gray-500);font-size:14px;">Duy&#7879;t ho&#7863;c t&#7915; ch&#7889;i c&#225;c y&#234;u c&#7847;u h&#7911;y tour t&#7915; kh&#225;ch h&#224;ng</p>
                </div>
            </div>

            <c:if test="${not empty successMessage}">
                <div class="toast success" id="toastMsg"><i data-lucide="check-circle"></i> ${successMessage}</div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="toast error" id="toastMsg"><i data-lucide="x-circle"></i> ${errorMessage}</div>
            </c:if>

            <div class="filter-container">
                <div class="tabs">
                    <a href="${pageContext.request.contextPath}/accountant/refunds?tab=pending" class="tab-btn ${activeTab eq 'pending' ? 'active' : ''}">
                        <i data-lucide="clock"></i> Ch&#7901; X&#7917; L&#253;
                    </a>
                    <a href="${pageContext.request.contextPath}/accountant/refunds?tab=history" class="tab-btn ${activeTab eq 'history' ? 'active' : ''}">
                        <i data-lucide="archive"></i> &#272;&#227; X&#7917; L&#253;
                    </a>
                </div>

                <form method="get" action="${pageContext.request.contextPath}/accountant/refunds" style="display: flex; gap: 12px; align-items: center;">
                    <input type="hidden" name="tab" value="${activeTab}">
                    
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <label style="font-size: 13px; font-weight: 500; color: var(--gray-700);">T&#234;n KH:</label>
                        <input type="text" name="customerName" value="${param.customerName}" class="form-control" placeholder="T&#236;m theo t&#234;n kh&#225;ch h&#224;ng..." style="padding: 8px 12px; width: 200px; font-size: 13px;">
                    </div>

                    <div style="display: flex; align-items: center; gap: 8px;">
                        <label style="font-size: 13px; font-weight: 500; color: var(--gray-700);">T&#7915; ng&#224;y:</label>
                        <input type="date" name="startDate" value="${param.startDate}" class="form-control" style="padding: 8px 12px; width: auto; font-size: 13px;">
                    </div>
                    
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <label style="font-size: 13px; font-weight: 500; color: var(--gray-700);">&#272;&#7871;n ng&#224;y:</label>
                        <input type="date" name="endDate" value="${param.endDate}" class="form-control" style="padding: 8px 12px; width: auto; font-size: 13px;">
                    </div>
                    
                    <button type="submit" class="btn-modern btn-outline" style="padding: 8px 16px; background: white;"><i data-lucide="filter" style="width: 15px; height: 15px;"></i> L&#7885;c</button>
                    
                    <c:if test="${not empty param.startDate or not empty param.endDate}">
                        <a href="${pageContext.request.contextPath}/accountant/refunds?tab=${activeTab}" class="btn-modern btn-outline" style="padding: 8px 12px; color: var(--danger); border-color: var(--danger-light); background: var(--danger-light);" title="X&#243;a b&#7897; l&#7885;c">
                            <i data-lucide="x" style="width: 15px; height: 15px;"></i>
                        </a>
                    </c:if>
                </form>
            </div>

            <div class="modern-card">
                <c:choose>
                    <c:when test="${empty requests}">
                        <div class="empty-state">
                            <i data-lucide="check-circle-2"></i>
                            <h3>Kh&#244;ng c&#243; d&#7919; li&#7879;u</h3>
                            <p>Kh&#244;ng c&#243; y&#234;u c&#7847;u ho&#224;n ti&#7873;n n&#224;o trong m&#7909;c n&#224;y.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <table class="modern-table">
                            <thead>
                                <tr>
                                    <th>M&#227; Booking</th>
                                    <th>Kh&#225;ch H&#224;ng</th>
                                    <th>Tour / Ng&#224;y KH</th>
                                    <th>Ng&#224;y Y&#234;u C&#7847;u</th>
                                    <th>S&#7889; Ti&#7873;n (VN&#272;)</th>
                                    <th>L&#253; Do H&#7911;y</th>
                                    <c:if test="${activeTab eq 'history'}">
                                        <th>Tr&#7841;ng Th&#225;i</th>
                                        <th>Ghi Ch&#250; KT</th>
                                    </c:if>
                                    <c:if test="${activeTab eq 'pending'}">
                                        <th style="text-align:right;">Thao T&#225;c</th>
                                    </c:if>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="r" items="${requests}">
                                    <tr>
                                        <td><span class="booking-code">${r.bookingCode}</span></td>
                                        <td>
                                            <div class="customer-name">${r.customerName}</div>
                                            <div class="customer-email">${r.customerEmail}</div>
                                        </td>
                                        <td>
                                            <div style="font-weight:500;">${r.tourName}</div>
                                            <div style="font-size:12px;color:var(--gray-500);">
                                                <fmt:formatDate value="${r.departureDate}" pattern="dd/MM/yyyy"/>
                                            </div>
                                        </td>
                                        <td><fmt:formatDate value="${r.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                        <td class="amount"><fmt:formatNumber value="${r.totalAmount}" type="number"/> &#273;</td>
                                        <td><span style="font-size:13px;" title="${r.reason}">${r.reason}</span></td>
                                        
                                        <c:if test="${activeTab eq 'history'}">
                                            <td>
                                                <c:if test="${r.status eq 'Approved'}"><span class="badge badge-approved">&#272;&#227; Duy&#7879;t</span></c:if>
                                                <c:if test="${r.status eq 'Rejected'}"><span class="badge badge-rejected">T&#7915; Ch&#7889;i</span></c:if>
                                            </td>
                                            <td style="font-size:12px; color:var(--gray-500); max-width:150px;">${r.notes}</td>
                                        </c:if>

                                        <c:if test="${activeTab eq 'pending'}">
                                            <td style="text-align:right;">
                                                <button type="button" class="btn-modern btn-success" 
                                                    onclick="openApproveModal(${r.requestId}, ${r.bookingId}, '${r.bookingCode}', ${r.requestedBy}, ${r.totalAmount})">
                                                    <i data-lucide="check" style="width:14px;height:14px;"></i> Duy&#7879;t
                                                </button>
                                                <button type="button" class="btn-modern btn-danger"
                                                    onclick="openRejectModal(${r.requestId}, ${r.bookingId}, '${r.bookingCode}', ${r.requestedBy})">
                                                    <i data-lucide="x" style="width:14px;height:14px;"></i> T&#7915; ch&#7889;i
                                                </button>
                                            </td>
                                        </c:if>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
</div>

<%-- Approve Modal --%>
<div class="modal-overlay" id="approveModal">
    <div class="modal-box">
        <div class="modal-header success">
            <h3 style="margin:0;"><i data-lucide="check-circle" style="vertical-align:middle;margin-right:6px;"></i> Duy&#7879;t Ho&#224;n Ti&#7873;n</h3>
            <button class="btn-outline" style="border:none;padding:4px;cursor:pointer;" onclick="closeModal('approveModal')"><i data-lucide="x"></i></button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/accountant/refunds">
            <input type="hidden" name="action" value="approve">
            <input type="hidden" name="requestId" id="appRequestId">
            <input type="hidden" name="bookingId" id="appBookingId">
            <input type="hidden" name="customerId" id="appCustomerId">
            <input type="hidden" name="bookingCode" id="appBookingCode">
            <input type="hidden" name="refundAmount" id="appRefundAmountVal">
            
            <div class="modal-body">
                <div class="form-group">
                    <label>S&#7889; Ti&#7873;n C&#7847;n Ho&#224;n Tr&#7843;</label>
                    <div class="readonly-value" id="appRefundAmountText" style="color:var(--danger);"></div>
                </div>
                <div class="form-group">
                    <label>M&#227; Giao D&#7883;ch Ho&#224;n Ti&#7873;n (Transaction Ref) *</label>
                    <input type="text" name="transactionRef" class="form-control" placeholder="V&#237; d&#7909;: MB-123456789" required>
                </div>
                <div class="form-group">
                    <label>Ghi Ch&#250; K&#7871; To&#225;n</label>
                    <textarea name="notes" class="form-control" rows="3" placeholder="Ghi ch&#250; n&#7897;i b&#7897; cho giao d&#7883;ch ho&#224;n ti&#7873;n n&#224;y..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-modern btn-outline" onclick="closeModal('approveModal')">H&#7911;y</button>
                <button type="submit" class="btn-modern btn-success">X&#225;c Nh&#7853;n &#272;&#227; Ho&#224;n Ti&#7873;n</button>
            </div>
        </form>
    </div>
</div>

<%-- Reject Modal --%>
<div class="modal-overlay" id="rejectModal">
    <div class="modal-box">
        <div class="modal-header danger">
            <h3 style="margin:0;"><i data-lucide="x-circle" style="vertical-align:middle;margin-right:6px;"></i> T&#7915; Ch&#7889;i Ho&#224;n Ti&#7873;n</h3>
            <button class="btn-outline" style="border:none;padding:4px;cursor:pointer;" onclick="closeModal('rejectModal')"><i data-lucide="x"></i></button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/accountant/refunds">
            <input type="hidden" name="action" value="reject">
            <input type="hidden" name="requestId" id="rejRequestId">
            <input type="hidden" name="bookingId" id="rejBookingId">
            <input type="hidden" name="customerId" id="rejCustomerId">
            <input type="hidden" name="bookingCode" id="rejBookingCode">
            
            <div class="modal-body">
                <p style="font-size:14px;color:var(--gray-700);margin-top:0;">H&#224;nh &#273;&#7897;ng n&#224;y s&#7869; h&#7911;y y&#234;u c&#7847;u ho&#224;n ti&#7873;n v&#224; gi&#7919; nguy&#234;n tr&#7841;ng th&#225;i Booking. Kh&#225;ch h&#224;ng s&#7869; nh&#7853;n &#273;&#432;&#7907;c th&#244;ng b&#225;o.</p>
                <div class="form-group">
                    <label>L&#253; Do T&#7915; Ch&#7889;i (S&#7869; g&#7917;i cho kh&#225;ch h&#224;ng) *</label>
                    <textarea name="notes" class="form-control" rows="4" placeholder="V&#237; d&#7909;: &#272;&#227; qu&#225; h&#7841;n h&#7911;y tour theo ch&#237;nh s&#225;ch..." required></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-modern btn-outline" onclick="closeModal('rejectModal')">H&#7911;y</button>
                <button type="submit" class="btn-modern btn-danger">X&#225;c Nh&#7853;n T&#7915; Ch&#7889;i</button>
            </div>
        </form>
    </div>
</div>

<script>
    lucide.createIcons();
    const toast = document.getElementById('toastMsg');
    if (toast) setTimeout(() => toast.style.display = 'none', 4000);

    function openApproveModal(reqId, bId, bCode, cId, amount) {
        document.getElementById('appRequestId').value = reqId;
        document.getElementById('appBookingId').value = bId;
        document.getElementById('appBookingCode').value = bCode;
        document.getElementById('appCustomerId').value = cId;
        document.getElementById('appRefundAmountVal').value = amount;
        document.getElementById('appRefundAmountText').textContent = new Intl.NumberFormat('vi-VN').format(amount) + ' \u0111';
        document.getElementById('approveModal').classList.add('open');
    }

    function openRejectModal(reqId, bId, bCode, cId) {
        document.getElementById('rejRequestId').value = reqId;
        document.getElementById('rejBookingId').value = bId;
        document.getElementById('rejBookingCode').value = bCode;
        document.getElementById('rejCustomerId').value = cId;
        document.getElementById('rejectModal').classList.add('open');
    }

    function closeModal(id) {
        document.getElementById(id).classList.remove('open');
    }
</script>
</body>
</html>
