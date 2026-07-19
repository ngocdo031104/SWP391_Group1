<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

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
    <title>Danh S&#225;ch Kh&#225;ch - Staff Dashboard</title>
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

        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
        .page-header h1 { margin: 0; font-size: 24px; font-weight: 700; color: var(--gray-900); }
        .page-header p { margin: 4px 0 0; color: var(--gray-500); font-size: 14px; }

        .card { background: #fff; border-radius: 16px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); border: 1px solid var(--gray-100); overflow: hidden; margin-bottom: 24px; }
        .card-header { padding: 16px 24px; border-bottom: 1px solid var(--gray-100); display: flex; justify-content: space-between; align-items: center; }
        .card-header h3 { margin: 0; font-size: 16px; font-weight: 600; color: var(--gray-900); display: flex; align-items: center; gap: 8px; }

        .badge { padding: 4px 10px; border-radius: 999px; font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 4px; white-space: nowrap; }
        .badge-success { background: var(--success-light); color: var(--success); }
        .badge-warning { background: var(--warning-light); color: var(--warning); }
        .badge-danger { background: var(--danger-light); color: var(--danger); }
        .badge-secondary { background: var(--gray-100); color: var(--gray-500); }
        .badge-primary { background: var(--primary-light); color: var(--primary); }

        .table-modern { width: 100%; border-collapse: collapse; }
        .table-modern th { background: var(--gray-50); padding: 12px 16px; text-align: left; font-size: 12px; font-weight: 600; color: var(--gray-500); text-transform: uppercase; letter-spacing: .5px; border-bottom: 1px solid var(--gray-200); }
        .table-modern td { padding: 14px 16px; border-bottom: 1px solid var(--gray-100); color: var(--gray-700); vertical-align: middle; }
        .table-modern tr:last-child td { border-bottom: none; }
        .table-modern tr:hover { background: var(--gray-50); }

        .btn { padding: 8px 16px; border-radius: 8px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; border: none; cursor: pointer; transition: all .2s; font-size: 14px; text-decoration: none; }
        .btn-primary { background: var(--primary); color: white; }
        .btn-primary:hover { background: #1D4ED8; }
        .btn-outline { background: white; color: var(--gray-700); border: 1px solid var(--gray-200); }
        .btn-outline:hover { background: var(--gray-50); }
        .btn-sm { padding: 6px 12px; font-size: 13px; }

        .stat-card { background: #fff; border-radius: 16px; padding: 20px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); border: 1px solid var(--gray-100); display: flex; align-items: center; gap: 16px; }
        .stat-icon { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .stat-icon.success { background: var(--success-light); color: var(--success); }
        .stat-icon.primary { background: var(--primary-light); color: var(--primary); }
        .stat-icon.warning { background: var(--warning-light); color: var(--warning); }
        .stat-info h4 { margin: 0; font-size: 13px; color: var(--gray-500); font-weight: 500; }
        .stat-info .stat-value { margin: 4px 0 0; font-size: 24px; font-weight: 700; color: #ffffff; }

        .empty-state { text-align: center; padding: 40px 20px; color: var(--gray-500); }
        .empty-state i { width: 48px; height: 48px; color: var(--gray-300); margin-bottom: 12px; }

        .breadcrumb { display: flex; align-items: center; gap: 8px; margin-bottom: 20px; font-size: 14px; }
        .breadcrumb a { color: var(--gray-500); text-decoration: none; }
        .breadcrumb a:hover { color: var(--primary); }
        .breadcrumb span { color: var(--gray-500); }

        .guest-item { display: flex; align-items: center; gap: 16px; padding: 12px 16px; border-bottom: 1px solid var(--gray-100); }
        .guest-item:last-child { border-bottom: none; }
        .guest-avatar { width: 40px; height: 40px; border-radius: 50%; background: var(--primary-light); color: var(--primary); display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px; }
        .guest-info { flex: 1; }
        .guest-name { font-weight: 600; color: var(--gray-900); }
        .guest-email { font-size: 13px; color: var(--gray-500); }
        .guest-meta { display: flex; gap: 12px; font-size: 13px; color: var(--gray-500); }
    </style>
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <c:set var="activePage" value="staff-guests" scope="request"/>
    <%@ include file="/admin/staff-sidebar.jsp" %>

    <main class="main-content">
        <div class="content-area">

            <c:choose>
                <c:when test="${not empty schedule}">
                    <%-- Chi ti&#7871;t guest list c&#7911;a m&#7897;t schedule --%>
                    <div class="breadcrumb">
                        <a href="${pageContext.request.contextPath}/staff/guests">
                            <i data-lucide="arrow-left" style="width:16px;height:16px;vertical-align:middle;margin-right:4px;"></i> Quay l&#7841;i danh s&#225;ch
                        </a>
                    </div>

                    <div class="page-header">
                        <div>
                            <h1>Danh S&#225;ch Kh&#225;ch</h1>
                            <p>${schedule.tour.tourName} - <fmt:formatDate value="${schedule.departureDate}" pattern="dd/MM/yyyy"/></p>
                        </div>
                    </div>

                    <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:20px;margin-bottom:24px;">
                        <div class="stat-card">
                            <div class="stat-icon primary"><i data-lucide="users"></i></div>
                            <div class="stat-info">
                                <h4>T&#7893;ng Kh&#225;ch</h4>
                                <div class="stat-value">${totalCount}</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon success"><i data-lucide="check-circle"></i></div>
                            <div class="stat-info">
                                <h4>&#272;&#227; Check-in</h4>
                                <div class="stat-value">${checkedInCount}</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon warning"><i data-lucide="user-x"></i></div>
                            <div class="stat-info">
                                <h4>Ch&#432;a Check-in</h4>
                                <div class="stat-value">${totalCount - checkedInCount}</div>
                            </div>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-header">
                            <h3><i data-lucide="list" style="color:var(--primary);"></i> Danh S&#225;ch H&#224;nh Kh&#225;ch</h3>
                        </div>
                        <div class="card-body" style="padding:0;">
                            <c:choose>
                                <c:when test="${empty participants}">
                                    <div class="empty-state">
                                        <i data-lucide="users"></i>
                                        <p>Ch&#432;a c&#243; h&#224;nh kh&#225;ch n&#224;o trong tour n&#224;y.</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="p" items="${participants}">
                                        <div class="guest-item">
                                            <div class="guest-avatar">
                                                ${fn:substring(p.fullName, 0, 1)}
                                            </div>
                                            <div class="guest-info">
                                                <div class="guest-name">${p.fullName}</div>
                                                <div class="guest-email">${p.email}</div>
                                                <div class="guest-meta">
                                                    <span><i data-lucide="phone" style="width:12px;height:12px;"></i> ${p.phoneNumber}</span>
                                                    <span><i data-lucide="calendar" style="width:12px;height:12px;"></i> ${p.bookingCode}</span>
                                                </div>
                                            </div>
                                            <div>
                                                <c:choose>
                                                    <c:when test="${p.checkedIn}">
                                                        <span class="badge badge-success">
                                                            <i data-lucide="check" style="width:12px;height:12px;"></i>
                                                            &#272;&#227; check-in
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-warning">
                                                            <i data-lucide="clock" style="width:12px;height:12px;"></i>
                                                            Ch&#432;a check-in
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                </c:when>
                <c:otherwise>
                    <%-- Danh s&#225;ch bookings &#273;&#7875; ch&#7885;n --%>
                    <div class="page-header">
                        <div>
                            <h1>Danh S&#225;ch Kh&#225;ch</h1>
                            <p>Xem danh s&#225;ch h&#224;nh kh&#225;ch theo t&#7915;ng tour</p>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-header">
                            <h3><i data-lucide="clipboard-list" style="color:var(--primary);"></i> Danh S&#225;ch Booking</h3>
                        </div>
                        <div class="card-body" style="padding:0;">
                            <c:choose>
                                <c:when test="${empty bookings}">
                                    <div class="empty-state">
                                        <i data-lucide="inbox"></i>
                                        <p>Ch&#432;a c&#243; booking n&#224;o.</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <table class="table-modern">
                                        <thead>
                                            <tr>
                                                <th>M&#227; Booking</th>
                                                <th>Kh&#225;ch H&#224;ng</th>
                                                <th>Tour</th>
                                                <th>Ng&#224;y Kh&#7903;i H&#224;nh</th>
                                                <th>S&#7889; Kh&#225;ch</th>
                                                <th>Tr&#7841;ng Th&#225;i</th>
                                                <th style="text-align:center;">H&#224;nh &#272;&#7897;ng</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="b" items="${bookings}">
                                                <tr>
                                                    <td>
                                                        <span style="font-family:monospace;font-weight:700;color:var(--primary);">${b.bookingCode}</span>
                                                    </td>
                                                    <td>
                                                        <div style="font-weight:600;">${b.customer.fullName}</div>
                                                        <div style="font-size:12px;color:var(--gray-500);">${b.customer.email}</div>
                                                    </td>
                                                    <td>
                                                        <div style="font-weight:500;">${b.schedule.tour.tourName}</div>
                                                        <div style="font-size:12px;color:var(--gray-500);">${b.schedule.tour.destination}</div>
                                                    </td>
                                                    <td><fmt:formatDate value="${b.schedule.departureDate}" pattern="dd/MM/yyyy"/></td>
                                                    <td style="text-align:center;">
                                                        <span class="badge badge-primary">${b.numParticipants} ng&#432;&#7901;i</span>
                                                    </td>
                                                    <td>
                                                        <span class="badge badge-success">Th&#224;nh c&#244;ng</span>
                                                    </td>
                                                    <td style="text-align:center;">
                                                        <a href="${pageContext.request.contextPath}/staff/guests?action=details&scheduleId=${b.schedule.scheduleId}"
                                                           class="btn btn-primary btn-sm">
                                                            <i data-lucide="users" style="width:14px;height:14px;"></i> Xem Kh&#225;ch
                                                        </a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>

        </div>
    </main>
</div>

<script>
    lucide.createIcons();
</script>
</body>
</html>
