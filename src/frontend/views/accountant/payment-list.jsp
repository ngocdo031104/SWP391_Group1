<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

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
    <title>Theo D&#245;i D&#242;ng Ti&#7873;n &#8212; TourBuddy</title>
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

        /* Stats cards */
        .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 24px; }
        .stat-card { background: #fff; border-radius: 16px; padding: 24px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); display: flex; align-items: center; gap: 16px; border: 1px solid var(--gray-100); }
        .stat-icon { width: 56px; height: 56px; border-radius: 16px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .stat-icon.success { background: var(--success-light); color: var(--success); }
        .stat-icon.danger  { background: var(--danger-light); color: var(--danger); }
        .stat-icon.primary { background: var(--primary-light); color: var(--primary); }
        .stat-info h4 { margin: 0; font-size: 14px; color: var(--gray-500); font-weight: 500; text-transform: uppercase; letter-spacing: 0.5px; }
        .stat-info .stat-value { margin: 6px 0 0; font-size: 26px; font-weight: 700; color: #ffffff; }

        /* Filter bar */
        .filter-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; gap: 16px; flex-wrap: wrap; background: #fff; padding: 16px 20px; border-radius: 12px; border: 1px solid var(--gray-100); box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
        .search-box { position: relative; flex: 1; max-width: 350px; }
        .search-box svg { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--gray-500); width: 18px; }
        .search-box input { width: 100%; box-sizing: border-box; height: 42px; padding: 10px 16px 10px 40px; border: 1px solid var(--gray-200); border-radius: 8px; font-family: inherit; outline: none; transition: all .2s; }
        .search-box input:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-light); }
        .filter-group { display: flex; gap: 12px; align-items: center; }
        .date-input { height: 42px; padding: 0 12px; border: 1px solid var(--gray-200); border-radius: 8px; font-family: inherit; color: var(--gray-700); box-sizing: border-box; outline: none; }
        
        .btn-modern { padding: 10px 16px; border-radius: 8px; font-weight: 600; display: inline-flex; align-items: center; gap: 8px; border: none; cursor: pointer; transition: all .2s; font-size: 14px; text-decoration: none; }
        .btn-primary { background: var(--primary); color: white; box-shadow: 0 2px 4px rgba(37,99,235,.2); }
        .btn-primary:hover { background: #1D4ED8; }
        .btn-outline { background: white; color: var(--gray-700); border: 1px solid var(--gray-200); }
        .btn-outline:hover { background: var(--gray-50); }

        /* Tabs */
        .tabs { display: flex; gap: 8px; margin-bottom: 20px; }
        .tab-btn { padding: 12px 24px; font-weight: 600; font-size: 15px; border-radius: 10px; border: 1px solid transparent; cursor: pointer; text-decoration: none; display: flex; align-items: center; gap: 10px; transition: all .2s; background: #fff; color: var(--gray-500); box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
        .tab-btn:hover { background: var(--gray-50); }
        .tab-btn.in.active { background: #ECFDF5; color: #059669; border-color: #A7F3D0; }
        .tab-btn.out.active { background: #FEF2F2; color: #DC2626; border-color: #FECACA; }

        /* Table */
        .modern-card { background: #fff; border-radius: 16px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); border: 1px solid var(--gray-100); overflow: hidden; }
        .modern-table { width: 100%; border-collapse: collapse; }
        .modern-table th { background: var(--gray-50); padding: 14px 20px; text-align: left; font-size: 12px; font-weight: 600; color: var(--gray-500); text-transform: uppercase; letter-spacing: .5px; border-bottom: 1px solid var(--gray-200); }
        .modern-table td { padding: 14px 20px; border-bottom: 1px solid var(--gray-100); color: var(--gray-700); vertical-align: middle; font-size: 14px; }
        .modern-table tr:hover { background: var(--gray-50); }

        .trans-code { font-family: monospace; font-weight: 700; color: var(--gray-900); font-size: 13px; background: var(--gray-100); padding: 4px 8px; border-radius: 4px; }
        .booking-code { font-weight: 600; color: var(--primary); text-decoration: none; }
        .booking-code:hover { text-decoration: underline; }
        .customer-name { font-size: 13px; color: var(--gray-500); margin-top: 4px; }
        .amount.in { font-weight: 700; color: var(--success); }
        .amount.out { font-weight: 700; color: var(--danger); }
        
        .badge { padding: 4px 10px; border-radius: 999px; font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 4px; white-space: nowrap; }
        .badge-success { background: var(--success-light); color: var(--success); }
        .badge-danger { background: var(--danger-light); color: var(--danger); }
        .badge-method { background: var(--primary-light); color: var(--primary); font-size: 11px; }

        /* Pagination */
        .pagination { display: flex; justify-content: center; align-items: center; gap: 8px; padding: 20px; }
        .page-btn { width: 36px; height: 36px; border-radius: 8px; display: flex; align-items: center; justify-content: center; border: 1px solid var(--gray-200); background: #fff; color: var(--gray-700); cursor: pointer; font-size: 14px; font-weight: 500; text-decoration: none; transition: all .2s; }
        .page-btn:hover { border-color: var(--primary); color: var(--primary); }
        .page-btn.active { background: var(--primary); color: #fff; border-color: var(--primary); }
        .page-btn.disabled { opacity: .4; cursor: not-allowed; pointer-events: none; }
        
        .empty-state { text-align: center; padding: 60px 20px; }
        .empty-state svg { width: 64px; height: 64px; color: var(--gray-200); margin-bottom: 16px; }
        .empty-state h3 { color: var(--gray-500); margin: 0 0 8px; font-weight: 600; }
    </style>
</head>
<body class="dashboard-body">

<div class="dashboard-layout">
    <c:set var="isAccountant" value="true" scope="request"/>
    <%@ include file="/admin/sidebar.jsp" %>

    <main class="main-content">
        <%@ include file="/admin/admin-header-right.jsp" %>

        <div class="content-area">
            <div class="page-header" style="margin-bottom:24px;">
                <div>
                    <h1 style="margin:0;font-size:24px;font-weight:700;color:var(--gray-900);">Theo D&#245;i D&#242;ng Ti&#7873;n</h1>
                    <p style="margin:4px 0 0;color:var(--gray-500);font-size:14px;">Qu&#7843;n l&#253; to&#224;n b&#7897; giao d&#7883;ch Thu - Chi c&#7911;a h&#7879; th&#7889;ng</p>
                </div>
            </div>

            <%-- Stats --%>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon success"><i data-lucide="arrow-down-left"></i></div>
                    <div class="stat-info">
                        <h4>T&#7893;ng Thu (Kh&#225;ch thanh to&#225;n)</h4>
                        <div class="stat-value" style="color:var(--success);">+ <fmt:formatNumber value="${totalIn}" type="number"/> &#273;</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon danger"><i data-lucide="arrow-up-right"></i></div>
                    <div class="stat-info">
                        <h4>T&#7893;ng Chi (Ho&#224;n ti&#7873;n)</h4>
                        <div class="stat-value" style="color:var(--danger);">- <fmt:formatNumber value="${totalOut}" type="number"/> &#273;</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon primary"><i data-lucide="wallet"></i></div>
                    <div class="stat-info">
                        <h4>Doanh Thu R&#242;ng</h4>
                        <div class="stat-value"><fmt:formatNumber value="${netRevenue}" type="number"/> &#273;</div>
                    </div>
                </div>
            </div>

            <%-- Filter --%>
            <form method="get" action="${pageContext.request.contextPath}/accountant/payments" id="filterForm">
                <input type="hidden" name="tab" value="${activeTab}">
                <div class="filter-bar">
                    <div class="search-box">
                        <i data-lucide="search"></i>
                        <input type="text" name="keyword" value="${keyword}" placeholder="T&#236;m m&#227; GD, m&#227; booking, t&#234;n kh&#225;ch...">
                    </div>
                    <div class="filter-group">
                        <span style="font-size:14px;color:var(--gray-500);font-weight:500;">T&#7915;:</span>
                        <input type="date" name="dateFrom" value="${dateFrom}" class="date-input">
                        <span style="font-size:14px;color:var(--gray-500);font-weight:500;">&#272;&#7871;n:</span>
                        <input type="date" name="dateTo" value="${dateTo}" class="date-input">
                        <button type="submit" class="btn-modern btn-primary">
                            <i data-lucide="filter" style="width:16px;height:16px;"></i> L&#7885;c
                        </button>
                        <c:if test="${not empty keyword || not empty dateFrom || not empty dateTo}">
                            <a href="${pageContext.request.contextPath}/accountant/payments?tab=${activeTab}" class="btn-modern btn-outline">X&#243;a l&#7885;c</a>
                        </c:if>
                    </div>
                </div>
            </form>

            <%-- Tabs --%>
            <div class="tabs">
                <a href="${pageContext.request.contextPath}/accountant/payments?tab=in" class="tab-btn in ${activeTab eq 'in' ? 'active' : ''}">
                    <i data-lucide="trending-up"></i> Ti&#7873;n V&#224;o (&#272;&#227; Thu)
                </a>
                <a href="${pageContext.request.contextPath}/accountant/payments?tab=out" class="tab-btn out ${activeTab eq 'out' ? 'active' : ''}">
                    <i data-lucide="trending-down"></i> Ti&#7873;n Ra (&#272;&#227; Ho&#224;n)
                </a>
            </div>

            <%-- Table --%>
            <div class="modern-card">
                <c:choose>
                    <c:when test="${empty payments}">
                        <div class="empty-state">
                            <i data-lucide="search-x"></i>
                            <h3>Kh&#244;ng t&#236;m th&#7845;y giao d&#7883;ch n&#224;o</h3>
                            <p>H&#227;y th&#7917; thay &#273;&#7893;i b&#7897; l&#7885;c ho&#7863;c t&#7915; kh&#243;a t&#236;m ki&#7871;m.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <table class="modern-table">
                            <thead>
                                <tr>
                                    <th>M&#227; Giao D&#7883;ch</th>
                                    <th>Booking / Kh&#225;ch H&#224;ng</th>
                                    <th>S&#7889; Ti&#7873;n (VN&#272;)</th>
                                    <th>Ph&#432;&#417;ng Th&#7913;c</th>
                                    <th>Tr&#7841;ng Th&#225;i</th>
                                    <th>Th&#7901;i Gian</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="p" items="${payments}">
                                    <tr>
                                        <td>
                                            <span class="trans-code">${p.transactionRef}</span>
                                        </td>
                                        <td>
                                            <div>
                                                <a href="${pageContext.request.contextPath}/admin/bookingDetail?id=${p.bookingId}" target="_blank" class="booking-code">
                                                    #${p.bookingCode}
                                                </a>
                                            </div>
                                            <div class="customer-name">${p.customerName}</div>
                                        </td>
                                        <td>
                                            <c:if test="${activeTab eq 'in'}">
                                                <span class="amount in">+ <fmt:formatNumber value="${p.amount}" type="number"/> &#273;</span>
                                            </c:if>
                                            <c:if test="${activeTab eq 'out'}">
                                                <span class="amount out">- <fmt:formatNumber value="${p.amount}" type="number"/> &#273;</span>
                                            </c:if>
                                        </td>
                                        <td>
                                            <span class="badge badge-method">${p.paymentMethod}</span>
                                        </td>
                                        <td>
                                            <c:if test="${p.status eq 'Success'}">
                                                <span class="badge badge-success"><i data-lucide="check" style="width:12px;height:12px;"></i> Th&#224;nh c&#244;ng</span>
                                            </c:if>
                                            <c:if test="${p.status eq 'Refunded'}">
                                                <span class="badge badge-danger"><i data-lucide="corner-down-left" style="width:12px;height:12px;"></i> &#272;&#227; ho&#224;n tr&#7843;</span>
                                            </c:if>
                                        </td>
                                        <td>
                                            <fmt:formatDate value="${p.paidAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>

                        <%-- Pagination --%>
                        <c:if test="${totalPages > 1}">
                            <div class="pagination">
                                <a href="?tab=${activeTab}&dateFrom=${dateFrom}&dateTo=${dateTo}&keyword=${keyword}&page=${currentPage - 1}"
                                   class="page-btn ${currentPage le 1 ? 'disabled' : ''}">
                                    <i data-lucide="chevron-left" style="width:16px;height:16px;"></i>
                                </a>
                                <c:forEach begin="1" end="${totalPages}" var="p">
                                    <a href="?tab=${activeTab}&dateFrom=${dateFrom}&dateTo=${dateTo}&keyword=${keyword}&page=${p}"
                                       class="page-btn ${p eq currentPage ? 'active' : ''}">${p}</a>
                                </c:forEach>
                                <a href="?tab=${activeTab}&dateFrom=${dateFrom}&dateTo=${dateTo}&keyword=${keyword}&page=${currentPage + 1}"
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

<script>lucide.createIcons();</script>
</body>
</html>
