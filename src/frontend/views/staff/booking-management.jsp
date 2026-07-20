<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<%-- Kiem tra quyen: chi Staff va Admin moi duoc vao trang nay --%>
<c:if test="${empty sessionScope.sessionUser
    || (sessionScope.sessionUser.role.roleName ne 'Staff'
    && sessionScope.sessionUser.role.roleName ne 'Admin')}">
    <c:redirect url="/login"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Qu&#7843;n L&#253; Booking &#8212; TourBuddy Staff</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=1.6">
    <style>
        :root {
            --primary: #2563EB; --primary-light: #EFF6FF;
            --success: #10B981; --success-light: #D1FAE5;
            --warning: #F59E0B; --warning-light: #FEF3C7;
            --danger: #EF4444;  --danger-light: #FEE2E2;
            --purple: #9333EA;  --purple-light: #F3E8FF;
            --gray-50: #F8FAFC; --gray-100: #F1F5F9; --gray-200: #E2E8F0;
            --gray-500: #64748B; --gray-700: #334155; --gray-900: #0F172A;
        }
        body.dashboard-body { background: var(--gray-50); font-family: 'Inter', sans-serif; }

        /* Stats */
        .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 24px; }
        .stat-card { background: #fff; border-radius: 16px; padding: 20px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); display: flex; align-items: center; gap: 16px; border: 1px solid var(--gray-100); transition: transform .2s; }
        .stat-card:hover { transform: translateY(-2px); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.08); }
        .stat-icon { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .stat-icon.primary { background: var(--primary-light); color: var(--primary); }
        .stat-icon.success { background: var(--success-light); color: var(--success); }
        .stat-icon.warning { background: var(--warning-light); color: var(--warning); }
        .stat-icon.danger  { background: var(--danger-light);  color: var(--danger); }
        .stat-info h4 { margin: 0; font-size: 13px; color: var(--gray-500); font-weight: 500; }
        .stat-info .stat-value { margin: 4px 0 0; font-size: 24px; font-weight: 700; color: #ffffff; }

        /* Filter bar */
        .filter-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; gap: 16px; flex-wrap: wrap; }
        .search-box { position: relative; flex: 1; max-width: 400px; }
        .search-box svg { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--gray-500); width: 18px; }
        .search-box input { width: 100%; box-sizing: border-box; height: 42px; padding: 10px 16px 10px 40px; border: 1px solid var(--gray-200); border-radius: 8px; font-family: inherit; outline: none; transition: all .2s; }
        .search-box input:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-light); }
        .filter-group { display: flex; gap: 12px; align-items: center; }
        .filter-select { padding: 10px 16px; height: 42px; border: 1px solid var(--gray-200); border-radius: 8px; font-family: inherit; outline: none; background: #fff; color: var(--gray-700); cursor: pointer; box-sizing: border-box; }
        .btn-modern { padding: 10px 16px; border-radius: 8px; font-weight: 600; display: inline-flex; align-items: center; gap: 8px; border: none; cursor: pointer; transition: all .2s; font-size: 14px; text-decoration: none; }
        .btn-primary { background: var(--primary); color: white; box-shadow: 0 2px 4px rgba(37,99,235,.2); }
        .btn-primary:hover { background: #1D4ED8; }
        .btn-outline { background: white; color: var(--gray-700); border: 1px solid var(--gray-200); }
        .btn-outline:hover { background: var(--gray-50); }

        /* Table */
        .modern-card { background: #fff; border-radius: 16px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); border: 1px solid var(--gray-100); overflow: hidden; }
        .modern-table { width: 100%; border-collapse: collapse; }
        .modern-table th { background: var(--gray-50); padding: 14px 20px; text-align: left; font-size: 12px; font-weight: 600; color: var(--gray-500); text-transform: uppercase; letter-spacing: .5px; border-bottom: 1px solid var(--gray-200); }
        .modern-table td { padding: 14px 20px; border-bottom: 1px solid var(--gray-100); color: var(--gray-700); vertical-align: middle; font-size: 14px; }
        .modern-table tr:last-child td { border-bottom: none; }
        .modern-table tr:hover { background: var(--gray-50); }

        /* Badges */
        .badge { padding: 4px 10px; border-radius: 999px; font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 4px; white-space: nowrap; }
        .badge-success  { background: var(--success-light);  color: var(--success); }
        .badge-warning  { background: var(--warning-light);  color: var(--warning); }
        .badge-danger   { background: var(--danger-light);   color: var(--danger); }
        .badge-secondary{ background: var(--gray-100);       color: var(--gray-500); }

        /* Action */
        .row-actions { display: flex; gap: 6px; }
        .action-btn { padding: 6px 10px; border-radius: 6px; font-size: 12px; font-weight: 600; border: none; cursor: pointer; display: inline-flex; align-items: center; gap: 4px; transition: all .2s; }
        .action-btn.note { background: var(--primary-light); color: var(--primary); }
        .action-btn.note:hover { background: var(--primary); color: #fff; }

        /* Pagination */
        .pagination { display: flex; justify-content: center; align-items: center; gap: 8px; padding: 20px; }
        .page-btn { width: 36px; height: 36px; border-radius: 8px; display: flex; align-items: center; justify-content: center; border: 1px solid var(--gray-200); background: #fff; color: var(--gray-700); cursor: pointer; font-size: 14px; font-weight: 500; text-decoration: none; transition: all .2s; }
        .page-btn:hover { border-color: var(--primary); color: var(--primary); }
        .page-btn.active { background: var(--primary); color: #fff; border-color: var(--primary); }
        .page-btn.disabled { opacity: .4; cursor: not-allowed; pointer-events: none; }

        /* Modal */
        .modal-overlay { position: fixed; inset: 0; background: rgba(15,23,42,.5); backdrop-filter: blur(4px); z-index: 1000; display: none; align-items: center; justify-content: center; }
        .modal-overlay.open { display: flex; }
        .modal-box { background: #fff; border-radius: 16px; width: 480px; max-width: 95vw; box-shadow: 0 25px 50px rgba(0,0,0,.15); animation: modalIn .25s ease; }
        @keyframes modalIn { from { transform: scale(.95); opacity: 0; } to { transform: scale(1); opacity: 1; } }
        .modal-header { padding: 20px 24px; border-bottom: 1px solid var(--gray-200); display: flex; justify-content: space-between; align-items: center; }
        .modal-header h3 { margin: 0; font-size: 16px; font-weight: 600; color: var(--gray-900); }
        .modal-close { background: none; border: none; cursor: pointer; color: var(--gray-500); padding: 4px; border-radius: 4px; }
        .modal-close:hover { background: var(--gray-100); }
        .modal-body { padding: 24px; }
        .modal-footer { padding: 16px 24px; border-top: 1px solid var(--gray-200); display: flex; justify-content: flex-end; gap: 10px; }
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; font-size: 13px; font-weight: 600; color: var(--gray-700); margin-bottom: 6px; }
        .form-control { width: 100%; box-sizing: border-box; padding: 10px 14px; border: 1px solid var(--gray-200); border-radius: 8px; font-family: inherit; font-size: 14px; outline: none; transition: all .2s; resize: vertical; }
        .form-control:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-light); }

        /* Toast */
        .toast { position: fixed; top: 20px; right: 20px; z-index: 9999; padding: 14px 20px; border-radius: 10px; font-weight: 600; font-size: 14px; display: flex; align-items: center; gap: 10px; box-shadow: 0 10px 25px rgba(0,0,0,.15); animation: slideInRight .3s ease; max-width: 380px; }
        .toast.success { background: var(--success); color: white; }
        .toast.error   { background: var(--danger);  color: white; }
        @keyframes slideInRight { from { transform: translateX(120%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }

        /* Empty state */
        .empty-state { text-align: center; padding: 60px 20px; }
        .empty-state svg { width: 64px; height: 64px; color: var(--gray-200); margin-bottom: 16px; }
        .empty-state h3 { color: var(--gray-500); margin: 0 0 8px; font-weight: 600; }
        .empty-state p { color: var(--gray-500); font-size: 14px; margin: 0; }

        .booking-code { font-family: monospace; font-weight: 700; color: var(--primary); font-size: 13px; }
        .customer-name { font-weight: 600; color: var(--gray-900); }
        .customer-email { font-size: 12px; color: var(--gray-500); }
        .tour-name { font-weight: 500; color: var(--gray-900); }
        .tour-dest { font-size: 12px; color: var(--gray-500); }
        .amount { font-weight: 700; color: var(--gray-900); }
        .notes-preview { max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-size: 12px; color: var(--gray-500); font-style: italic; }
    </style>
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <c:set var="activePage" value="staff-bookings" scope="request"/>
    <%@ include file="/admin/staff-sidebar.jsp" %>

    <main class="main-content">
        <div class="content-area">
            <div class="page-header" style="margin-bottom:24px;">
                <div>
                    <h1 style="margin:0;font-size:24px;font-weight:700;color:var(--gray-900);">Qu&#7843;n L&#253; Booking</h1>
                    <p style="margin:4px 0 0;color:var(--gray-500);font-size:14px;">Xem v&#224; qu&#7843;n l&#253; to&#224;n b&#7897; &#273;&#417;n &#273;&#7863;t tour c&#7911;a h&#7879; th&#7889;ng</p>
                </div>
            </div>

            <%-- Toast messages --%>
            <c:if test="${not empty successMessage}">
                <div class="toast success" id="toastMsg">
                    <i data-lucide="check-circle"></i> ${successMessage}
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="toast error" id="toastMsg">
                    <i data-lucide="x-circle"></i> ${errorMessage}
                </div>
            </c:if>

            <%-- Stats cards --%>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon primary"><i data-lucide="clipboard-list"></i></div>
                    <div class="stat-info">
                        <h4>T&#7893;ng Booking</h4>
                        <div class="stat-value">${totalRecords}</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon success"><i data-lucide="check-circle"></i></div>
                    <div class="stat-info">
                        <h4>&#272;ang hi&#7875;n th&#7883;</h4>
                        <div class="stat-value">${bookings.size()}</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon warning"><i data-lucide="clock"></i></div>
                    <div class="stat-info">
                        <h4>Trang hi&#7879;n t&#7841;i</h4>
                        <div class="stat-value">${currentPage} / ${totalPages > 0 ? totalPages : 1}</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon danger"><i data-lucide="filter"></i></div>
                    <div class="stat-info">
                        <h4>B&#7897; l&#7885;c</h4>
                        <div class="stat-value" style="font-size:16px;">${statusFilter}</div>
                    </div>
                </div>
            </div>

            <%-- Filter bar --%>
            <form method="get" action="${pageContext.request.contextPath}/staff/bookings" id="filterForm">
                <div class="filter-bar">
                    <div class="search-box">
                        <i data-lucide="search"></i>
                        <input type="text" name="keyword" value="${keyword}" placeholder="T&#236;m theo m&#227; booking ho&#7863;c t&#234;n kh&#225;ch h&#224;ng..." id="searchInput">
                    </div>
                    <div class="filter-group">
                        <select name="status" class="filter-select" onchange="this.form.submit()">
                            <option value="All"            ${statusFilter eq 'All'            ? 'selected' : ''}>T&#7845;t c&#7843; tr&#7841;ng th&#225;i</option>
                            <option value="Success"        ${statusFilter eq 'Success'        ? 'selected' : ''}>&#9989; Th&#224;nh c&#244;ng</option>
                            <option value="PendingPayment" ${statusFilter eq 'PendingPayment' ? 'selected' : ''}>&#9203; Ch&#7901; thanh to&#225;n</option>
                            <option value="Cancelled"      ${statusFilter eq 'Cancelled'      ? 'selected' : ''}>&#10060; &#272;&#227; h&#7911;y</option>
                        </select>
                    </div>
                </div>
            </form>

            <%-- Table --%>
            <div class="modern-card">
                <c:choose>
                    <c:when test="${empty bookings}">
                        <div class="empty-state">
                            <i data-lucide="inbox"></i>
                            <h3>Kh&#244;ng c&#243; booking n&#224;o</h3>
                            <p>Th&#7917; thay &#273;&#7893;i b&#7897; l&#7885;c ho&#7863;c t&#7915; kh&#243;a t&#236;m ki&#7871;m</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <table class="modern-table">
                            <thead>
                                <tr>
                                    <th>M&#227; Booking</th>
                                    <th>Kh&#225;ch H&#224;ng</th>
                                    <th>Tour</th>
                                    <th>Ng&#224;y KH</th>
                                    <th>T&#7893;ng Ti&#7873;n</th>
                                    <th>Tr&#7841;ng Th&#225;i</th>
                                    <th style="text-align:center;">Thao T&#225;c</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="b" items="${bookings}">
                                    <tr>
                                        <td><span class="booking-code">${b.bookingCode}</span></td>
                                        <td>
                                            <div class="customer-name">${b.customer.fullName}</div>
                                            <div class="customer-email">${b.customer.email}</div>
                                        </td>
                                        <td>
                                            <div class="tour-name">${b.schedule.tour.tourName}</div>
                                            <div class="tour-dest">
                                                <i data-lucide="map-pin" style="width:11px;height:11px;"></i>
                                                ${b.schedule.tour.destination}
                                            </div>
                                        </td>
                                        <td>
                                            <fmt:formatDate value="${b.schedule.departureDate}" pattern="dd/MM/yyyy"/>
                                        </td>
                                        <td class="amount">
                                            <fmt:formatNumber value="${b.totalAmount}" type="number" groupingUsed="true"/> &#273;
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${b.status eq 'Success'}">
                                                    <span class="badge badge-success"><i data-lucide="check" style="width:11px;height:11px;"></i> Th&#224;nh c&#244;ng</span>
                                                </c:when>
                                                <c:when test="${b.status eq 'PendingPayment'}">
                                                    <span class="badge badge-warning"><i data-lucide="clock" style="width:11px;height:11px;"></i> Ch&#7901; TT</span>
                                                </c:when>
                                                <c:when test="${b.status eq 'Cancelled'}">
                                                    <span class="badge badge-danger"><i data-lucide="x" style="width:11px;height:11px;"></i> &#272;&#227; h&#7911;y</span>
                                                </c:when>
                                                <c:when test="${b.status eq 'Completed'}">
                                                    <span class="badge badge-secondary" style="background:#EDE9FE;color:#7C3AED;"><i data-lucide="flag" style="width:11px;height:11px;"></i> &#272;&#227; ho&#224;n th&#224;nh</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-secondary">${b.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align:center;">
                                            <div class="row-actions" style="justify-content:center;">
                                                <a href="${pageContext.request.contextPath}/staff/guests?action=details&scheduleId=${b.scheduleId}&bookingId=${b.bookingId}" class="action-btn" style="background:var(--primary-light); color:var(--primary); text-decoration:none;" title="Xem danh s&#225;ch h&#224;nh kh&#225;ch">
                                                    <i data-lucide="users" style="width:12px;height:12px;"></i> Xem Kh&#225;ch
                                                </a>
                                                <button class="action-btn note" onclick="openNotifModal(${b.customer.userId}, '${fn:escapeXml(b.customer.fullName)}')" title="G&#7917;i th&#244;ng b&#225;o cho kh&#225;ch h&#224;ng n&#224;y">
                                                    <i data-lucide="bell" style="width:12px;height:12px;"></i> G&#7917;i TB
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>

                        <%-- Pagination --%>
                        <c:if test="${totalPages > 1}">
                            <div class="pagination">
                                <a href="?status=${statusFilter}&keyword=${keyword}&page=${currentPage - 1}"
                                   class="page-btn ${currentPage le 1 ? 'disabled' : ''}">
                                    <i data-lucide="chevron-left" style="width:16px;height:16px;"></i>
                                </a>
                                <c:forEach begin="1" end="${totalPages}" var="p">
                                    <a href="?status=${statusFilter}&keyword=${keyword}&page=${p}"
                                       class="page-btn ${p eq currentPage ? 'active' : ''}">${p}</a>
                                </c:forEach>
                                <a href="?status=${statusFilter}&keyword=${keyword}&page=${currentPage + 1}"
                                   class="page-btn ${currentPage ge totalPages ? 'disabled' : ''}">
                                    <i data-lucide="chevron-right" style="width:16px;height:16px;"></i>
                                </a>
                            </div>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
</div>

<%-- Modal Gui Thong Bao --%>
<div class="modal-overlay" id="notifModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3><i data-lucide="bell" style="width:16px;height:16px;vertical-align:middle;"></i> G&#7917;i Th&#244;ng B&#225;o</h3>
            <button class="modal-close" onclick="closeNotifModal()">
                <i data-lucide="x"></i>
            </button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/staff/bookings">
            <input type="hidden" name="action" value="sendNotification">
            <input type="hidden" name="customerId" id="modalCustomerId">
            <input type="hidden" name="statusFilter" value="${statusFilter}">
            <input type="hidden" name="keyword" value="${keyword}">
            <input type="hidden" name="page" value="${currentPage}">
            
            <div class="modal-body">
                <div class="form-group">
                    <label>Kh&#225;ch H&#224;ng</label>
                    <div id="modalCustomerName" style="font-weight:600;color:var(--primary);font-size:15px;padding:8px 12px;background:var(--primary-light);border-radius:8px;"></div>
                </div>
                
                <div class="form-group">
                    <label for="titleInput">Ti&#234;u &#272;&#7873; Th&#244;ng B&#225;o *</label>
                    <input type="text" id="titleInput" name="title" required class="form-control" placeholder="Nh&#7853;p ti&#234;u &#273;&#7873;...">
                </div>
                
                <div class="form-group">
                    <label for="contentInput">N&#7897;i Dung *</label>
                    <textarea id="contentInput" name="content" required class="form-control" rows="4" placeholder="Nh&#7853;p n&#7897;i dung..."></textarea>
                </div>
                
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
                    <div class="form-group">
                        <label for="categoryInput">Th&#7875; Lo&#7841;i</label>
                        <select id="categoryInput" name="category" required class="form-control">
                            <option value="Booking">&#272;&#7863;t ch&#7895;</option>
                            <option value="System Announcement">Th&#244;ng b&#225;o h&#7879; th&#7889;ng</option>
                            <option value="Payment">Thanh to&#225;n</option>
                            <option value="Tour Update">C&#7853;p nh&#7853;t Tour</option>
                            <option value="Promotion">Khuy&#7871;n m&#227;i</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="scheduledInput">L&#234;n L&#7883;ch <span style="font-weight:400;color:var(--gray-500);">(t&#249;y ch&#7885;n)</span></label>
                        <input type="datetime-local" id="scheduledInput" name="scheduledAt" class="form-control">
                    </div>
                </div>
                <div style="font-size:12px;color:var(--gray-500);font-style:italic;margin-top:5px;">
                    * Th&#244;ng b&#225;o s&#7869; ch&#7881; &#273;&#432;&#7907;c g&#7917;i qua h&#7879; th&#7889;ng (in-app).
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-modern btn-outline" onclick="closeNotifModal()">H&#7911;y</button>
                <button type="submit" class="btn-modern btn-primary">
                    <i data-lucide="send" style="width:14px;height:14px;"></i> G&#7917;i Th&#244;ng B&#225;o
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    lucide.createIcons();

    // Auto-dismiss toast sau 4 gi\u00e2y
    const toast = document.getElementById('toastMsg');
    if (toast) setTimeout(() => toast.style.display = 'none', 4000);

    // Search on Enter
    document.getElementById('searchInput')?.addEventListener('keydown', function(e) {
        if (e.key === 'Enter') document.getElementById('filterForm').submit();
    });

    // Modal gui thong bao
    function openNotifModal(customerId, customerName) {
        document.getElementById('modalCustomerId').value = customerId;
        document.getElementById('modalCustomerName').textContent = customerName;
        document.getElementById('titleInput').value = '';
        document.getElementById('contentInput').value = '';
        document.getElementById('scheduledInput').value = '';
        document.getElementById('notifModal').classList.add('open');
        document.getElementById('titleInput').focus();
    }

    function closeNotifModal() {
        document.getElementById('notifModal').classList.remove('open');
    }

    // Close modal khi click ra ngoai
    document.getElementById('notifModal')?.addEventListener('click', function(e) {
        if (e.target === this) closeNotifModal();
    });
</script>
</body>
</html>
