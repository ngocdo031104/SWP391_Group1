<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guide Dashboard &#8212; TourBuddy</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/tourbuddy.css?v=1.4">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/tb-ui.css?v=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .dashboard-wrapper { max-width: 1200px; margin: 100px auto 40px; padding: 0 20px; }
        .table-custom { width: 100%; border-collapse: collapse; margin-top: 15px; }
        .table-custom th, .table-custom td { padding: 14px 16px; border-bottom: 1px solid var(--clr-border); text-align: left; font-size: 0.95rem; }
        .table-custom th { background-color: rgba(0,0,0,0.02); font-weight: 600; color: var(--clr-text); }
        .table-custom tr:hover { background-color: rgba(0,0,0,0.01); }
        .status-badge { padding: 6px 12px; border-radius: 99px; font-size: 0.85rem; font-weight: 600; display: inline-block; text-align: center; }
        
        /* CSS status styles */
        .status-preparing { background-color: rgba(243, 156, 18, 0.15); color: #d68910; }
        .status-scheduled { background-color: rgba(52, 152, 219, 0.15); color: #2980b9; }
        .status-inprogress { background-color: rgba(155, 89, 182, 0.15); color: #8e44ad; }
        .status-completed { background-color: rgba(39, 174, 96, 0.15); color: #229954; }
        .status-cancelled { background-color: rgba(231, 76, 60, 0.15); color: #c0392b; }
        .status-default { background-color: rgba(127, 140, 141, 0.15); color: #7f8c8d; }

        /* Operation Update Buttons */
        .btn-update-status {
            background-color: #f1f5f9;
            color: #475569;
            border: 1px solid #cbd5e1;
            padding: 6px 12px;
            border-radius: 6px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-family: 'Outfit', sans-serif;
            font-size: 0.85rem;
        }

        .btn-update-status:hover {
            background-color: #2563eb;
            color: #ffffff;
            border-color: #2563eb;
        }

        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.4);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }

        .modal.active {
            display: flex;
        }

        .modal-content {
            background: #ffffff;
            padding: 24px;
            border-radius: 12px;
            width: 100%;
            max-width: 480px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
            animation: slideDown 0.3s ease;
            position: relative;
        }

        @keyframes slideDown {
            from { transform: translateY(-20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 12px;
        }

        .modal-header h4 {
            margin: 0;
            font-size: 1.2rem;
            color: #1e293b;
            font-family: 'Outfit', sans-serif;
            font-weight: 700;
        }

        .modal-close {
            background: none;
            border: none;
            font-size: 1.5rem;
            color: #94a3b8;
            cursor: pointer;
            transition: color 0.2s;
        }

        .modal-close:hover {
            color: #475569;
        }

        .form-group {
            margin-bottom: 16px;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .form-group label {
            font-weight: 600;
            color: #475569;
            font-size: 0.9rem;
        }

        .form-select, .form-textarea {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            outline: none;
            font-family: 'Inter', sans-serif;
            font-size: 0.9rem;
            transition: border-color 0.2s;
        }

        .form-select:focus, .form-textarea:focus {
            border-color: #2563eb;
        }

        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            margin-top: 24px;
            border-top: 1px solid #e2e8f0;
            padding-top: 16px;
        }
        /* Guide Notification Bell */
        .guide-notif-bell {
            position: relative;
            color: var(--clr-muted);
            cursor: pointer;
            transition: color 0.2s;
            display: inline-flex;
            align-items: center;
            font-size: 1.1rem;
            text-decoration: none;
        }
        .guide-notif-bell:hover {
            color: var(--clr-primary);
        }
        .guide-notif-bell .notif-badge {
            position: absolute;
            top: -6px;
            right: -8px;
            background: #ef4444;
            color: white;
            font-size: 0.6rem;
            font-weight: 700;
            min-width: 16px;
            height: 16px;
            border-radius: 50%;
            display: none;
            align-items: center;
            justify-content: center;
            padding: 0 3px;
            border: 2px solid #fff;
            box-shadow: 0 1px 4px rgba(0,0,0,0.15);
            animation: tb-pulse 2s ease infinite;
        }

        /* ============ Premium UI Upgrades (Guide) ============ */

        /* Page-level fade-up */
        .dashboard-wrapper > * { animation: tb-fade-up 0.6s cubic-bezier(0.16, 1, 0.3, 1) both; }
        .dashboard-wrapper > *:nth-child(1) { animation-delay: 0.05s; }
        .dashboard-wrapper > *:nth-child(2) { animation-delay: 0.12s; }
        .dashboard-wrapper > *:nth-child(3) { animation-delay: 0.18s; }
        .dashboard-wrapper > *:nth-child(4) { animation-delay: 0.24s; }

        /* Profile header glass + animated gradient */
        .profile-header {
            background: linear-gradient(135deg, #ffffff 0%, #f1f5f9 100%) !important;
            border: 1px solid rgba(99, 102, 241, 0.18);
            border-radius: 18px !important;
            box-shadow: 0 4px 16px -4px rgba(15, 23, 42, 0.08);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        .profile-header::before {
            content: '';
            position: absolute;
            top: -50%; right: -10%;
            width: 240px; height: 240px;
            background: radial-gradient(circle, rgba(99, 102, 241, 0.12), transparent 70%);
            border-radius: 50%;
            animation: tb-float 6s ease-in-out infinite;
            pointer-events: none;
        }
        .profile-header:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 28px -8px rgba(99, 102, 241, 0.2);
        }

        /* Stats grid cards (guide) */
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 18px; margin-bottom: 28px; }
        .stats-grid > * {
            background: #fff;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            padding: 20px 22px;
            display: flex;
            align-items: center;
            gap: 14px;
            transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1),
                        box-shadow 0.3s ease,
                        border-color 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        .stats-grid > *::before {
            content: '';
            position: absolute;
            top: -50%; left: -50%;
            width: 60%; height: 200%;
            background: linear-gradient(90deg, transparent, rgba(99, 102, 241, 0.08), transparent);
            transform: rotate(20deg) translateX(-100%);
            transition: transform 0.9s ease;
            pointer-events: none;
        }
        .stats-grid > *:hover {
            transform: translateY(-4px);
            box-shadow: 0 16px 32px -10px rgba(99, 102, 241, 0.25);
            border-color: rgba(99, 102, 241, 0.35);
        }
        .stats-grid > *:hover::before { transform: rotate(20deg) translateX(200%); }

        /* Stat-icon square wrapper */
        .stats-grid .stat-icon,
        .stats-grid > div > div:first-child {
            width: 48px; height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            transition: transform 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        .stats-grid > *:hover .stat-icon,
        .stats-grid > *:hover > div:first-child { transform: rotate(-8deg) scale(1.1); }

        /* Tables premium */
        .table-custom {
            background: #fff;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            overflow: hidden;
            box-shadow: 0 2px 8px -2px rgba(15, 23, 42, 0.04);
        }
        .table-custom thead {
            background: linear-gradient(180deg, #f8fafc, #f1f5f9);
            position: relative;
        }
        .table-custom thead::after {
            content: '';
            position: absolute;
            left: 0; right: 0; bottom: 0;
            height: 1px;
            background: linear-gradient(90deg, transparent, rgba(99, 102, 241, 0.3), transparent);
        }
        .table-custom tbody tr {
            transition: background-color 0.25s ease, transform 0.2s ease, box-shadow 0.2s ease;
            border-bottom: 1px solid #f1f5f9;
        }
        .table-custom tbody tr:hover {
            background-color: rgba(99, 102, 241, 0.04);
            transform: translateX(4px);
            box-shadow: -4px 0 0 0 #5f3bf6;
        }
        .table-custom tbody tr:last-child { border-bottom: 0; }

        /* Status badges (guide) &#8212; pulse & color */
        .status-badge {
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            display: inline-flex; align-items: center; gap: 6px;
            font-weight: 600;
        }
        .status-badge::before {
            content: '';
            width: 6px; height: 6px;
            border-radius: 50%;
            background: currentColor;
            box-shadow: 0 0 0 2px rgba(255,255,255,0.6);
        }
        .status-badge:hover { transform: scale(1.06); }

        .status-preparing { animation: tb-pulse 3s ease infinite; }

        /* Modal upgrade */
        .modal {
            backdrop-filter: blur(6px);
            -webkit-backdrop-filter: blur(6px);
            background: rgba(15, 23, 42, 0.55) !important;
            animation: tb-fade-in 0.25s ease;
        }
        .modal-content {
            border: 1px solid rgba(99, 102, 241, 0.15);
            box-shadow: 0 30px 60px -12px rgba(15, 23, 42, 0.45) !important;
            animation: tb-modal-in 0.4s cubic-bezier(0.16, 1, 0.3, 1) both !important;
        }
        @keyframes tb-modal-in {
            from { opacity: 0; transform: translateY(20px) scale(0.96); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }
        .form-select, .form-textarea {
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }
        .form-select:focus, .form-textarea:focus {
            border-color: #5f3bf6 !important;
            box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.15);
        }

        /* Buttons (guide) */
        .btn { transition: transform 0.25s ease, box-shadow 0.25s ease, filter 0.2s ease; position: relative; overflow: hidden; }
        .btn:hover { transform: translateY(-2px); filter: brightness(1.05); }
        .btn:active { transform: translateY(0) scale(0.98); }
        .btn-primary:hover { box-shadow: 0 8px 20px -2px rgba(37, 99, 235, 0.4); }

        .btn-update-status {
            position: relative;
            overflow: hidden;
            transition: all 0.25s ease !important;
        }
        .btn-update-status:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 16px -2px rgba(37, 99, 235, 0.4);
        }

        /* Navbar entry animation */
        .navbar { animation: tb-fade-down 0.5s cubic-bezier(0.16, 1, 0.3, 1) both; }

        /* Logo icon glow */
        .navbar .logo-icon {
            transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1), box-shadow 0.3s ease;
        }
        .navbar .logo:hover .logo-icon {
            transform: rotate(-12deg) scale(1.1);
            box-shadow: 0 0 18px rgba(99, 102, 241, 0.45);
        }

        /* Filter card */
        .search-bar-group { animation: tb-fade-up 0.5s 0.2s cubic-bezier(0.16, 1, 0.3, 1) both; }
    </style>
</head>
<body>

<nav class="navbar">
  <a href="${pageContext.request.contextPath}/home" class="logo" id="nav-logo">
    <div class="logo-icon">T</div>
    <span>TourBuddy (Guide)</span>
  </a>
  <div class="navbar-nav" style="display:flex;align-items:center;gap:20px;">
    <a href="${pageContext.request.contextPath}/guide/dashboard" class="active">L&#7883;ch D&#7851;n &#272;o&#224;n</a>
    <a href="${pageContext.request.contextPath}/guide/profile">H&#7891; S&#417;</a>
    <a href="${pageContext.request.contextPath}/customer/notifications" class="guide-notif-bell" id="guide-notif-btn" title="Th&#244;ng b&#225;o">
      <i class="fa-regular fa-bell"></i>
      <span class="notif-badge" id="guide-notif-count"></span>
    </a>
    <a href="${pageContext.request.contextPath}/logout" style="color:var(--clr-error)">
      <i class="fa fa-right-from-bracket"></i> &#272;&#259;ng xu&#7845;t
    </a>
  </div>
</nav>

<div class="dashboard-wrapper">
    <div class="profile-header fade-up" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; padding: 20px 24px;">
        <div class="profile-info">
            <h2 style="font-size: 1.5rem; margin-bottom: 5px;">Xin ch&#224;o, ${sessionScope.sessionUser.fullName}</h2>
            <p style="color: var(--clr-muted); font-size: 0.9rem;">Ch&#224;o m&#7915;ng b&#7841;n quay l&#7841;i b&#7843;ng &#273;i&#7873;u khi&#7875;n H&#432;&#7899;ng d&#7851;n vi&#234;n.</p>
        </div>
        <div class="profile-actions">
             <a href="${pageContext.request.contextPath}/guide/profile" class="role-badge" style="background: var(--clr-primary-l); color: var(--clr-primary); padding: 8px 16px; border-radius: 20px; font-weight: bold; text-decoration: none; display: inline-block; transition: 0.2s;"><i class="fa fa-id-badge"></i> H&#432;&#7899;ng D&#7851;n Vi&#234;n</a>
        </div>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-error fade-up">
            <i class="fa fa-circle-exclamation"></i> ${errorMessage}
        </div>
    </c:if>

    <div class="card fade-up" style="animation-delay: 0.1s;">
        <div class="card-header">
            <h3><i class="fa fa-calendar-days" style="margin-right:8px;color:var(--clr-primary)"></i> Tour &#272;&#227; Ph&#226;n C&#244;ng</h3>
        </div>
        <div class="card-body" style="padding: 0;">
            <c:choose>
                <c:when test="${empty assignments}">
                    <div class="empty-state" style="text-align:center; padding: 40px 20px;">
                        <i class="fa fa-box-open" style="font-size: 3rem; color: var(--clr-border); margin-bottom: 16px;"></i>
                        <p style="color: var(--clr-muted); font-size: 0.95rem;">B&#7841;n ch&#432;a &#273;&#432;&#7907;c ph&#226;n c&#244;ng d&#7851;n tour n&#224;o.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="overflow-x: auto;">
                        <table class="table-custom">
                            <thead>
                                <tr>
                                    <th>T&#234;n Tour</th>
                                    <th>&#272;i&#7875;m &#272;&#7871;n</th>
                                    <th>Ng&#224;y Kh&#7903;i H&#224;nh</th>
                                    <th>Ng&#224;y V&#7873;</th>
                                    <th>Tr&#7841;ng Th&#225;i V&#7853;n H&#224;nh</th>
                                    <th style="text-align: center; width: 320px;">H&#224;nh &#272;&#7897;ng</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="assignment" items="${assignments}">
                                    <tr>
                                        <td style="font-weight: 500;"><c:out value="${assignment.schedule.tour.tourName}" /></td>
                                        <td><c:out value="${assignment.schedule.tour.destination}" /></td>
                                        <td><fmt:formatDate value="${assignment.schedule.departureDate}" pattern="dd/MM/yyyy" /></td>
                                        <td><fmt:formatDate value="${assignment.schedule.returnDate}" pattern="dd/MM/yyyy" /></td>
                                        <td>
                                            <c:set var="tourStatus" value="${assignment.schedule.status}" />
                                            <c:choose>
                                                <c:when test="${tourStatus == 'Preparing'}">
                                                    <span class="status-badge status-preparing">Chu&#7849;n b&#7883;</span>
                                                </c:when>
                                                <c:when test="${tourStatus == 'Scheduled'}">
                                                    <span class="status-badge status-scheduled">&#272;&#227; l&#234;n l&#7883;ch</span>
                                                </c:when>
                                                <c:when test="${tourStatus == 'InProgress'}">
                                                    <span class="status-badge status-inprogress">&#272;ang &#273;i</span>
                                                </c:when>
                                                <c:when test="${tourStatus == 'Completed'}">
                                                    <span class="status-badge status-completed">Ho&#224;n th&#224;nh</span>
                                                </c:when>
                                                <c:when test="${tourStatus == 'Cancelled'}">
                                                    <span class="status-badge status-cancelled">&#272;&#227; h&#7911;y</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge status-default"><c:out value="${empty tourStatus ? 'Chu&#7849;n b&#7883;' : tourStatus}" /></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: center; display: flex; gap: 8px; justify-content: center; align-items: center; height: 100%; padding-top: 12px; padding-bottom: 12px;">
                                            <a href="${pageContext.request.contextPath}/guide/dashboard?action=participants&scheduleId=${assignment.schedule.scheduleId}" class="btn btn-outline btn-sm" style="padding: 6px 12px; font-size: 0.85rem; font-weight: 600;">
                                                <i class="fa fa-users"></i> Danh s&#225;ch &#273;o&#224;n
                                            </a>
                                            <a href="${pageContext.request.contextPath}/guide/dashboard?action=incidents&scheduleId=${assignment.schedule.scheduleId}" class="btn btn-outline btn-sm" style="padding: 6px 12px; font-size: 0.85rem; font-weight: 600; border-color: #ef4444; color: #ef4444; background-color: transparent;">
                                                <i class="fa fa-triangle-exclamation"></i> S&#7921; c&#7889;
                                            </a>
                                            <a href="${pageContext.request.contextPath}/guide/dashboard?action=operationLogs&scheduleId=${assignment.schedule.scheduleId}" class="btn btn-outline btn-sm" style="padding: 6px 12px; font-size: 0.85rem; font-weight: 600; border-color: #64748b; color: #64748b; background-color: transparent;">
                                                <i class="fa fa-clock-rotate-left"></i> Nh&#7853;t k&#253;
                                            </a>
                                            <button class="btn-update-status" onclick="openStatusModal(${assignment.schedule.scheduleId}, '${tourStatus}')">
                                                <i class="fa fa-edit"></i> Tr&#7841;ng th&#225;i
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!-- Modal c&#7853;p nh&#7853;t tr&#7841;ng th&#225;i -->
<div class="modal" id="status-modal">
    <div class="modal-content">
        <div class="modal-header">
            <h4>C&#7853;p nh&#7853;t ti&#7871;n &#273;&#7897; Tour</h4>
            <button class="modal-close" onclick="closeStatusModal()">&times;</button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="modal-schedule-id">
            
            <div class="form-group">
                <label for="modal-status-select">Tr&#7841;ng th&#225;i v&#7853;n h&#224;nh *</label>
                <select id="modal-status-select" class="form-select">
                    <option value="Preparing">Preparing (Chu&#7849;n b&#7883;)</option>
                    <option value="Scheduled">Scheduled (&#272;&#227; l&#234;n l&#7883;ch)</option>
                    <option value="InProgress">InProgress (&#272;ang &#273;i)</option>
                    <option value="Completed">Completed (Ho&#224;n th&#224;nh)</option>
                    <option value="Cancelled">Cancelled (&#272;&#227; h&#7911;y)</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="modal-notes-textarea">Ghi ch&#250; v&#7853;n h&#224;nh / L&#253; do</label>
                <textarea id="modal-notes-textarea" class="form-textarea" rows="4" placeholder="Nh&#7853;p di&#7877;n bi&#7871;n s&#7921; c&#7889;, l&#253; do h&#7911;y &#273;o&#224;n ho&#7863;c ghi ch&#250; ho&#7841;t &#273;&#7897;ng..."></textarea>
            </div>
            
            <div class="form-actions">
                <button class="btn btn-outline btn-sm" onclick="closeStatusModal()" style="font-weight: 600;">H&#7911;y b&#7887;</button>
                <button class="btn btn-primary btn-sm" onclick="submitStatusUpdate()" style="font-weight: 600;">X&#225;c nh&#7853;n</button>
            </div>
        </div>
    </div>
</div>

<script>
    function openStatusModal(scheduleId, currentStatus) {
        document.getElementById('modal-schedule-id').value = scheduleId;
        document.getElementById('modal-status-select').value = currentStatus || 'Preparing';
        document.getElementById('modal-notes-textarea').value = '';
        document.getElementById('status-modal').classList.add('active');
    }

    function closeStatusModal() {
        document.getElementById('status-modal').classList.remove('active');
    }

    function submitStatusUpdate() {
        const scheduleId = document.getElementById('modal-schedule-id').value;
        const newStatus = document.getElementById('modal-status-select').value;
        const notes = document.getElementById('modal-notes-textarea').value;

        const params = new URLSearchParams();
        params.append("action", "updateStatus");
        params.append("scheduleId", scheduleId);
        params.append("newStatus", newStatus);
        params.append("notes", notes);

        fetch('${pageContext.request.contextPath}/guide/dashboard', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: params
        })
        .then(res => res.json())
        .then(data => {
            if (data.status === 'success') {
                alert(data.message);
                closeStatusModal();
                window.location.reload();
            } else {
                alert(data.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert('L\u1ed7i h\u1ec7 th\u1ed1ng khi c\u1eadp nh\u1eadt tr\u1ea1ng th\u00e1i!');
        });
    }
</script>

<script>
    // Fetch s\u1ed1 l\u01b0\u1ee3ng th\u00f4ng b\u00e1o ch\u01b0a \u0111\u1ecdc cho Guide
    (function() {
        var badge = document.getElementById('guide-notif-count');
        if (!badge) return;
        var ctx = '${pageContext.request.contextPath}';
        fetch(ctx + '/api/header-counts?t=' + Date.now())
            .then(function(r) { return r.json(); })
            .then(function(data) {
                var count = data.unreadNotifications || 0;
                if (count > 0) {
                    badge.textContent = count > 99 ? '99+' : count;
                    badge.style.display = 'flex';
                }
            })
            .catch(function(e) { console.error('Notification badge error', e); });
    })();
</script>
<script src="${pageContext.request.contextPath}/js/tb-ui.js?v=1.0"></script>

</body>
</html>