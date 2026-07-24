<%-- 
    Màn hình 36: View Guest List and Check-in - Quản lý danh sách hành khách và Check-in (Staff)
    Tác giả: Dương Quang Sơn
    MSSV: HE186525
    Ngày tạo: 2026-07-21
--%>
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
    <script src="https://unpkg.com/lucide@latest" defer></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=1.6">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff-guest-list.css?v=1.2">
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
                        <a href="${pageContext.request.contextPath}/staff/bookings">
                            <i data-lucide="arrow-left" style="width:16px;height:16px;vertical-align:middle;margin-right:4px;"></i> Quay l&#7841;i Qu&#7843;n l&#253; Booking
                        </a>
                    </div>

                    <div class="page-header">
                        <div>
                            <h1 style="color: #0F172A;">Danh S&#225;ch Kh&#225;ch</h1>
                            <p style="color: #64748B;">${schedule.tour.tourName} - <fmt:formatDate value="${schedule.departureDate}" pattern="dd/MM/yyyy"/></p>
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

                    <div class="guest-filter-bar">
                        <div class="search-box">
                            <i data-lucide="search"></i>
                            <input type="text" id="guestSearchInput" placeholder="T&#236;m theo t&#234;n h&#224;nh kh&#225;ch...">
                        </div>
                        <select id="guestCheckinFilter">
                            <option value="all">T&#7845;t c&#7843; check-in</option>
                            <option value="true">&#10004; &#272;&#227; check-in</option>
                            <option value="false">&#9203; Ch&#432;a check-in</option>
                        </select>
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
                                        <div class="guest-item" data-name="${fn:toLowerCase(p.fullName)}" data-status="${p.bookingStatus}" data-checkin="${p.checkedIn}">
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
                                             <div style="display: flex; gap: 8px; align-items: center;">
                                                 <c:choose>
                                                     <c:when test="${p.bookingStatus == 'Cancelled'}">
                                                         <span class="badge badge-danger">
                                                             <i data-lucide="x" style="width:12px;height:12px;"></i>
                                                             Đã hủy đơn
                                                         </span>
                                                     </c:when>
                                                     <c:when test="${p.bookingStatus == 'PendingPayment'}">
                                                         <span class="badge badge-warning" style="background: var(--warning-light); color: var(--warning);">
                                                             <i data-lucide="clock" style="width:12px;height:12px;"></i>
                                                             Chờ TT
                                                         </span>
                                                     </c:when>
                                                 </c:choose>
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
                                    <c:if test="${not empty participants[0].bookingNotes}">
                                        <div style="padding:16px 24px; background: linear-gradient(to right, #f8fafc, #ffffff); border-top:1px solid var(--gray-100); display:flex; align-items:flex-start; gap:12px; font-size:14px; color:#334155; border-left:4px solid ${participants[0].bookingStatus == 'Cancelled' ? 'var(--danger)' : 'var(--primary)'}; margin:0;">
                                            <i data-lucide="message-square" style="width:20px;height:20px; flex-shrink:0; margin-top:2px; color: ${participants[0].bookingStatus == 'Cancelled' ? 'var(--danger)' : 'var(--primary)'};"></i>
                                            <div style="font-size:15px; line-height:1.6;"><strong>Ghi chú đơn:</strong> ${participants[0].bookingNotes}</div>
                                        </div>
                                    </c:if>
                                    <div id="noResultsMsg" class="no-results-msg">
                                        <i data-lucide="search-x" style="width:48px;height:48px;margin-bottom:12px;color:var(--gray-300);"></i>
                                        <p style="font-size: 15px; font-weight: 500;">Kh&#244;ng t&#236;m th&#7845;y h&#224;nh kh&#225;ch ph&#249; h&#7907;p.</p>
                                    </div>
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
    document.addEventListener("DOMContentLoaded", () => {
        if(window.lucide) {
            lucide.createIcons();
        }
    });

    // Real-time filter for guest list
    (function() {
        var searchInput = document.getElementById('guestSearchInput');
        var checkinFilter = document.getElementById('guestCheckinFilter');
        if (!searchInput || !checkinFilter) return;

        function filterGuests() {
            var keyword = searchInput.value.toLowerCase().trim();
            var checkin = checkinFilter.value;
            var items = document.querySelectorAll('.guest-item[data-name]');
            var visibleCount = 0;

            items.forEach(function(item) {
                var name = item.getAttribute('data-name') || '';
                var itemCheckin = item.getAttribute('data-checkin') || '';
                var matchName = !keyword || name.indexOf(keyword) !== -1;
                var matchCheckin = checkin === 'all' || itemCheckin === checkin;

                if (matchName && matchCheckin) {
                    item.classList.remove('hidden-by-filter');
                    visibleCount++;
                } else {
                    item.classList.add('hidden-by-filter');
                }
            });

            var noResults = document.getElementById('noResultsMsg');
            if (noResults) {
                noResults.style.display = visibleCount === 0 && items.length > 0 ? 'block' : 'none';
            }
        }

        searchInput.addEventListener('input', filterGuests);
        checkinFilter.addEventListener('change', filterGuests);
    })();
</script>
</body>
</html>
