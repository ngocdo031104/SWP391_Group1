<%-- 
    Màn hình 42: Update Tour Status - Cập nhật trạng thái vận hành tour
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
    <title>C&#7853;p Nh&#7853;t Tr&#7841;ng Th&#225;i Tour - Staff Dashboard</title>
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
        .badge-purple { background: var(--purple-light); color: var(--purple); }

        .status-badge { padding: 6px 12px; border-radius: 99px; font-size: 0.85rem; font-weight: 600; display: inline-block; text-align: center; }
        .status-preparing { background-color: rgba(243, 156, 18, 0.15); color: #d68910; }
        .status-scheduled { background-color: rgba(52, 152, 219, 0.15); color: #2980b9; }
        .status-inprogress { background-color: rgba(155, 89, 182, 0.15); color: #8e44ad; }
        .status-completed { background-color: rgba(39, 174, 96, 0.15); color: #229954; }
        .status-cancelled { background-color: rgba(231, 76, 60, 0.15); color: #c0392b; }

        .table-modern { width: 100%; border-collapse: collapse; }
        .table-modern th { background: var(--gray-50); padding: 12px 16px; text-align: left; font-size: 12px; font-weight: 600; color: var(--gray-500); text-transform: uppercase; letter-spacing: .5px; border-bottom: 1px solid var(--gray-200); }
        .table-modern td { padding: 16px; border-bottom: 1px solid var(--gray-100); color: var(--gray-700); vertical-align: middle; }
        .table-modern tr:last-child td { border-bottom: none; }
        .table-modern tr:hover { background: var(--gray-50); }

        .btn { padding: 8px 16px; border-radius: 8px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; border: none; cursor: pointer; transition: all .2s; font-size: 14px; text-decoration: none; }
        .btn-primary { background: var(--primary); color: white; }
        .btn-primary:hover { background: #1D4ED8; }
        .btn-outline { background: white; color: var(--gray-700); border: 1px solid var(--gray-200); }
        .btn-outline:hover { background: var(--gray-50); }
        .btn-sm { padding: 6px 12px; font-size: 13px; }

        .modal-overlay { position: fixed; inset: 0; background: rgba(15,23,42,.5); backdrop-filter: blur(4px); z-index: 1000; display: none; align-items: center; justify-content: center; }
        .modal-overlay.open { display: flex; }
        .modal-box { background: #fff; border-radius: 16px; width: 500px; max-width: 95vw; box-shadow: 0 25px 50px rgba(0,0,0,.15); animation: modalIn .25s ease; }
        @keyframes modalIn { from { transform: scale(.95); opacity: 0; } to { transform: scale(1); opacity: 1; } }
        .modal-header { padding: 20px 24px; border-bottom: 1px solid var(--gray-200); display: flex; justify-content: space-between; align-items: center; }
        .modal-header h3 { margin: 0; font-size: 16px; font-weight: 600; }
        .modal-close { background: none; border: none; cursor: pointer; color: var(--gray-500); padding: 4px; border-radius: 4px; }
        .modal-close:hover { background: var(--gray-100); }
        .modal-body { padding: 24px; }
        .modal-footer { padding: 16px 24px; border-top: 1px solid var(--gray-200); display: flex; justify-content: flex-end; gap: 10px; }
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; font-size: 13px; font-weight: 600; color: var(--gray-700); margin-bottom: 6px; }
        .form-control { width: 100%; box-sizing: border-box; padding: 10px 14px; border: 1px solid var(--gray-200); border-radius: 8px; font-family: inherit; font-size: 14px; outline: none; transition: all .2s; }
        .form-control:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-light); }
        select.form-control { cursor: pointer; }

        .toast { position: fixed; top: 20px; right: 20px; z-index: 9999; padding: 14px 20px; border-radius: 10px; font-weight: 600; font-size: 14px; display: flex; align-items: center; gap: 10px; box-shadow: 0 10px 25px rgba(0,0,0,.15); animation: slideInRight .3s ease; }
        .toast.success { background: var(--success); color: white; }
        .toast.error { background: var(--danger); color: white; }
        @keyframes slideInRight { from { transform: translateX(120%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }

        .empty-state { text-align: center; padding: 60px 20px; color: var(--gray-500); }
        .empty-state i { width: 64px; height: 64px; color: var(--gray-200); margin-bottom: 16px; }

        .breadcrumb { display: flex; align-items: center; gap: 8px; margin-bottom: 20px; font-size: 14px; }
        .breadcrumb a { color: var(--gray-500); text-decoration: none; }
        .breadcrumb a:hover { color: var(--primary); }

        .timeline { position: relative; padding-left: 30px; }
        .timeline::before { content: ''; position: absolute; left: 10px; top: 0; bottom: 0; width: 2px; background: var(--gray-200); }
        .timeline-item { position: relative; padding-bottom: 20px; }
        .timeline-item::before { content: ''; position: absolute; left: -24px; top: 4px; width: 12px; height: 12px; border-radius: 50%; background: var(--primary); border: 2px solid white; }
        .timeline-item:last-child { padding-bottom: 0; }
    </style>
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <c:set var="activePage" value="staff-tour-status" scope="request"/>
    <%@ include file="/admin/staff-sidebar.jsp" %>

    <main class="main-content">
        <div class="content-area">

            <c:choose>
                <c:when test="${not empty logs}">
                    <%-- Chi ti&#7871;t logs c&#7911;a m&#7897;t schedule --%>
                    <div class="breadcrumb">
                        <a href="${pageContext.request.contextPath}/staff/tour-status">
                            <i data-lucide="arrow-left" style="width:16px;height:16px;vertical-align:middle;margin-right:4px;"></i> Quay l&#7841;i danh s&#225;ch
                        </a>
                    </div>

                    <div class="page-header">
                        <div>
                            <h1>Nh&#7853;t K&#253; V&#7853;n H&#224;nh</h1>
                            <p>${schedule.tour.tourName} - <fmt:formatDate value="${schedule.departureDate}" pattern="dd/MM/yyyy"/></p>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-header">
                            <h3><i data-lucide="clock-rotate-left" style="color:var(--primary);"></i> Timeline Ho&#7841;t &#272;&#7897;ng</h3>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${empty logs}">
                                    <div class="empty-state">
                                        <i data-lucide="clock"></i>
                                        <p>Ch&#432;a c&#243; ho&#7841;t &#273;&#7897;ng n&#224;o &#273;&#432;&#7907;c ghi nh&#7853;n.</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="timeline">
                                        <c:forEach var="log" items="${logs}">
                                            <div class="timeline-item">
                                                <div style="font-weight:600;color:var(--gray-900);">${log.activity}</div>
                                                <div style="font-size:13px;color:var(--gray-500);">
                                                    <fmt:formatDate value="${log.createdAt}" pattern="HH:mm dd/MM/yyyy"/>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                </c:when>
                <c:otherwise>
                    <%-- Danh s&#225;ch tours c&#243; guide --%>
                    <div class="page-header">
                        <div>
                            <h1>C&#7853;p Nh&#7853;t Tr&#7841;ng Th&#225;i Tour</h1>
                            <p>Xem v&#224; c&#7853;p nh&#7853;t tr&#7841;ng th&#225;i v&#7853;n h&#224;nh c&#7911;a c&#225;c tour</p>
                        </div>
                    </div>

                    <c:if test="${not empty successMessage}">
                        <div class="toast success" id="toastMsg">
                            <i data-lucide="check-circle"></i> ${successMessage}
                        </div>
                    </c:if>

                    <div class="card">
                        <div class="card-header">
                            <h3><i data-lucide="activity" style="color:var(--primary);"></i> Danh S&#225;ch Tour &#272;ang Ho&#7841;t &#272;&#7897;ng</h3>
                        </div>
                        <div class="card-body" style="padding:0;">
                            <c:choose>
                                <c:when test="${empty schedules}">
                                    <div class="empty-state">
                                        <i data-lucide="package"></i>
                                        <p>Ch&#432;a c&#243; tour n&#224;o c&#243; h&#432;&#7899;ng d&#7851;n vi&#234;n.</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <table class="table-modern">
                                        <thead>
                                            <tr>
                                                <th>Tour</th>
                                                <th>Ng&#224;y Kh&#7903;i H&#224;nh</th>
                                                <th>Ng&#224;y V&#7873;</th>
                                                <th>H&#432;&#7899;ng D&#7851;n Vi&#234;n</th>
                                                <th>Tr&#7841;ng Th&#225;i</th>
                                                <th style="text-align:center;">H&#224;nh &#272;&#7897;ng</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="schedule" items="${schedules}">
                                                <tr>
                                                    <td>
                                                        <div style="font-weight:600;">${schedule.tour.tourName}</div>
                                                        <div style="font-size:12px;color:var(--gray-500);">${schedule.tour.destination}</div>
                                                    </td>
                                                    <td><fmt:formatDate value="${schedule.departureDate}" pattern="dd/MM/yyyy"/></td>
                                                    <td><fmt:formatDate value="${schedule.returnDate}" pattern="dd/MM/yyyy"/></td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty schedule.guide}">
                                                                <div style="display:flex;align-items:center;gap:8px;">
                                                                    <div style="width:32px;height:32px;border-radius:50%;background:var(--primary-light);color:var(--primary);display:flex;align-items:center;justify-content:center;font-weight:700;font-size:12px;">
                                                                        ${fn:substring(schedule.guide.fullName, 0, 1)}
                                                                    </div>
                                                                    <span style="font-weight:500;">${schedule.guide.fullName}</span>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span style="color:var(--gray-500);font-style:italic;">Ch&#432;a c&#243;</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:set var="ts" value="${schedule.tourStatus}" />
                                                        <c:choose>
                                                            <c:when test="${ts == 'Preparing'}">
                                                                <span class="status-badge status-preparing">Chu&#7849;n b&#7883;</span>
                                                            </c:when>
                                                            <c:when test="${ts == 'Scheduled'}">
                                                                <span class="status-badge status-scheduled">&#272;&#227; l&#234;n l&#7883;ch</span>
                                                            </c:when>
                                                            <c:when test="${ts == 'InProgress'}">
                                                                <span class="status-badge status-inprogress">&#272;ang &#273;i</span>
                                                            </c:when>
                                                            <c:when test="${ts == 'Completed'}">
                                                                <span class="status-badge status-completed">Ho&#224;n th&#224;nh</span>
                                                            </c:when>
                                                            <c:when test="${ts == 'Cancelled'}">
                                                                <span class="status-badge status-cancelled">&#272;&#227; h&#7911;y</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="status-badge status-preparing">Chu&#7849;n b&#7883;</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="text-align:center;">
                                                        <button class="btn btn-outline btn-sm" onclick="openLogsModal(${schedule.scheduleId}, '${schedule.tour.tourName}')">
                                                            <i data-lucide="clock-rotate-left" style="width:14px;height:14px;"></i> Logs
                                                        </button>
                                                        <button class="btn btn-primary btn-sm" onclick="openStatusModal(${schedule.scheduleId}, '${schedule.tourStatus}', '${schedule.tour.tourName}')">
                                                            <i data-lucide="edit" style="width:14px;height:14px;"></i> C&#7853;p nh&#7853;t
                                                        </button>
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

<!-- Modal C&#7853;p nh&#7853;t tr&#7841;ng th&#225;i -->
<div class="modal-overlay" id="statusModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3><i data-lucide="edit" style="vertical-align:middle;margin-right:8px;"></i>C&#7853;p Nh&#7853;t Tr&#7841;ng Th&#225;i Tour</h3>
            <button class="modal-close" onclick="closeStatusModal()"><i data-lucide="x"></i></button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="modal-schedule-id">
            <div style="background:var(--gray-50);padding:12px 16px;border-radius:10px;margin-bottom:20px;">
                <div style="font-weight:600;color:var(--gray-900);" id="modal-tour-name"></div>
            </div>

            <div class="form-group">
                <label for="modal-status-select">Tr&#7841;ng Th&#225;i M&#7899;i *</label>
                <select id="modal-status-select" class="form-control">
                    <option value="Preparing">Chu&#7849;n b&#7883; (Preparing)</option>
                    <option value="Scheduled">&#272;&#227; l&#234;n l&#7883;ch (Scheduled)</option>
                    <option value="InProgress">&#272;ang di&#7877;n ra (InProgress)</option>
                    <option value="Completed">Ho&#224;n th&#224;nh (Completed)</option>
                    <option value="Cancelled">&#272;&#227; h&#7911;y (Cancelled)</option>
                </select>
            </div>

            <div class="form-group">
                <label for="modal-notes">Ghi Ch&#250;</label>
                <textarea id="modal-notes" class="form-control" rows="3" placeholder="Nh&#7853;p ghi ch&#250; v&#7853;n h&#224;nh..."></textarea>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-outline" onclick="closeStatusModal()">H&#7911;y</button>
            <button class="btn btn-primary" onclick="submitStatusUpdate()">
                <i data-lucide="check" style="width:14px;height:14px;"></i> X&#225;c Nh&#7853;n
            </button>
        </div>
    </div>
</div>

<!-- Modal Xem Logs -->
<div class="modal-overlay" id="logsModal">
    <div class="modal-box" style="width:600px;">
        <div class="modal-header">
            <h3><i data-lucide="clock-rotate-left" style="vertical-align:middle;margin-right:8px;"></i>Nh&#7853;t K&#253; V&#7853;n H&#224;nh</h3>
            <button class="modal-close" onclick="closeLogsModal()"><i data-lucide="x"></i></button>
        </div>
        <div class="modal-body" id="logs-content">
            <div style="text-align:center;padding:40px;color:var(--gray-500);">
                <i data-lucide="loader-2" style="animation:spin 1s linear infinite;width:24px;height:24px;"></i>
                <p style="margin-top:10px;">&#272;ang t&#7843;i...</p>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-outline" onclick="closeLogsModal()">&#272;&#243;ng</button>
        </div>
    </div>
</div>

<style>
    @keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
</style>

<script>
    lucide.createIcons();

    // Toast auto dismiss
    const toast = document.getElementById('toastMsg');
    if (toast) setTimeout(() => toast.style.display = 'none', 4000);

    function openStatusModal(scheduleId, currentStatus, tourName) {
        document.getElementById('modal-schedule-id').value = scheduleId;
        document.getElementById('modal-tour-name').textContent = tourName;
        document.getElementById('modal-status-select').value = currentStatus || 'Preparing';
        document.getElementById('modal-notes').value = '';
        document.getElementById('statusModal').classList.add('open');
    }

    function closeStatusModal() {
        document.getElementById('statusModal').classList.remove('open');
    }

    function submitStatusUpdate() {
        const scheduleId = document.getElementById('modal-schedule-id').value;
        const newStatus = document.getElementById('modal-status-select').value;
        const notes = document.getElementById('modal-notes').value;

        const params = new URLSearchParams();
        params.append('action', 'updateStatus');
        params.append('scheduleId', scheduleId);
        params.append('newStatus', newStatus);
        params.append('notes', notes);

        fetch('${pageContext.request.contextPath}/staff/tour-status', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params
        })
        .then(res => res.json())
        .then(data => {
            if (data.status === 'success') {
                alert(data.message);
                closeStatusModal();
                location.reload();
            } else {
                alert(data.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert('\u0110\u00e3 x\u1ea3y ra l\u1ed7i!');
        });
    }

    function openLogsModal(scheduleId, tourName) {
        document.getElementById('logs-content').innerHTML = '<div style="text-align:center;padding:40px;color:var(--gray-500);"><i data-lucide="loader-2" style="animation:spin 1s linear infinite;width:24px;height:24px;"></i><p style="margin-top:10px;">\u0110ang t\u1ea3i...</p></div>';
        lucide.createIcons();
        document.getElementById('logsModal').classList.add('open');

        // Load logs via AJAX
        fetch('${pageContext.request.contextPath}/staff/tour-status?action=logs&scheduleId=' + scheduleId)
            .then(res => res.text())
            .then(html => {
                // Re-fetch as JSON
                return fetch('${pageContext.request.contextPath}/staff/tour-status?action=logs&scheduleId=' + scheduleId);
            })
            .catch(err => {
                document.getElementById('logs-content').innerHTML = '<div style="text-align:center;padding:40px;color:var(--danger);"><i data-lucide="alert-circle"></i><p style="margin-top:10px;">L\u1ed7i khi t\u1ea3i nh\u1eadt k\u00fd</p></div>';
                lucide.createIcons();
            });
    }

    function closeLogsModal() {
        document.getElementById('logsModal').classList.remove('open');
    }

    // Close modal on outside click
    document.querySelectorAll('.modal-overlay').forEach(modal => {
        modal.addEventListener('click', function(e) {
            if (e.target === this) {
                this.classList.remove('open');
            }
        });
    });
</script>
</body>
</html>
