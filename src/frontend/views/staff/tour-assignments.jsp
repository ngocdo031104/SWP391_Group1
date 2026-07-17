<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

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
    <title>Phân Công Guide - Staff Dashboard</title>
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
        .card-body { padding: 24px; }

        .badge { padding: 4px 10px; border-radius: 999px; font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 4px; white-space: nowrap; }
        .badge-primary { background: var(--primary-light); color: var(--primary); }
        .badge-success { background: var(--success-light); color: var(--success); }
        .badge-warning { background: var(--warning-light); color: var(--warning); }
        .badge-danger { background: var(--danger-light); color: var(--danger); }
        .badge-secondary { background: var(--gray-100); color: var(--gray-500); }

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

        .tabs { display: flex; gap: 4px; border-bottom: 2px solid var(--gray-200); margin-bottom: 24px; }
        .tab { padding: 12px 20px; font-weight: 600; color: var(--gray-500); cursor: pointer; border-bottom: 2px solid transparent; margin-bottom: -2px; transition: all .2s; }
        .tab:hover { color: var(--gray-700); }
        .tab.active { color: var(--primary); border-bottom-color: var(--primary); }

        .guide-card { display: flex; align-items: center; gap: 12px; padding: 12px; border: 1px solid var(--gray-200); border-radius: 10px; cursor: pointer; transition: all .2s; }
        .guide-card:hover { border-color: var(--primary); background: var(--primary-light); }
        .guide-card.selected { border-color: var(--primary); background: var(--primary-light); }
        .guide-avatar { width: 40px; height: 40px; border-radius: 50%; background: var(--primary-light); color: var(--primary); display: flex; align-items: center; justify-content: center; font-weight: 700; }
        .guide-info { flex: 1; }
        .guide-name { font-weight: 600; color: var(--gray-900); font-size: 14px; }
        .guide-meta { font-size: 12px; color: var(--gray-500); }

        .modal-overlay { position: fixed; inset: 0; background: rgba(15,23,42,.5); backdrop-filter: blur(4px); z-index: 1000; display: none; align-items: center; justify-content: center; }
        .modal-overlay.open { display: flex; }
        .modal-box { background: #fff; border-radius: 16px; width: 500px; max-width: 95vw; box-shadow: 0 25px 50px rgba(0,0,0,.15); animation: modalIn .25s ease; }
        @keyframes modalIn { from { transform: scale(.95); opacity: 0; } to { transform: scale(1); opacity: 1; } }
        .modal-header { padding: 20px 24px; border-bottom: 1px solid var(--gray-200); display: flex; justify-content: space-between; align-items: center; }
        .modal-header h3 { margin: 0; font-size: 16px; font-weight: 600; }
        .modal-close { background: none; border: none; cursor: pointer; color: var(--gray-500); padding: 4px; border-radius: 4px; }
        .modal-close:hover { background: var(--gray-100); }
        .modal-body { padding: 24px; max-height: 400px; overflow-y: auto; }
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

        .empty-state { text-align: center; padding: 40px 20px; color: var(--gray-500); }
        .empty-state i { width: 48px; height: 48px; color: var(--gray-300); margin-bottom: 12px; }
    </style>
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <c:set var="activePage" value="staff-assignments" scope="request"/>
    <%@ include file="/admin/staff-sidebar.jsp" %>

    <main class="main-content">
        <div class="content-area">

            <div class="page-header">
                <div>
                    <h1>Phân Công Guide</h1>
                    <p>Quản lý phân công hướng dẫn viên cho các tour</p>
                </div>
            </div>

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

            <div class="tabs">
                <div class="tab active" onclick="showTab('unassigned')">
                    <i data-lucide="user-plus" style="width:16px;height:16px;vertical-align:middle;margin-right:4px;"></i>
                    Tour Chưa Có Guide (${unassignedSchedules.size()})
                </div>
                <div class="tab" onclick="showTab('assignments')">
                    <i data-lucide="list-checks" style="width:16px;height:16px;vertical-align:middle;margin-right:4px;"></i>
                    Lịch Sử Phân Công (${assignments.size()})
                </div>
            </div>

            <!-- Tab: Tour chưa có guide -->
            <div id="tab-unassigned" class="tab-content">
                <div class="card">
                    <div class="card-header">
                        <h3><i data-lucide="calendar-x" style="color:var(--warning);"></i> Danh Sách Tour Chưa Có Guide</h3>
                    </div>
                    <div class="card-body" style="padding:0;">
                        <c:choose>
                            <c:when test="${empty unassignedSchedules}">
                                <div class="empty-state">
                                    <i data-lucide="check-circle-2"></i>
                                    <p>Tất cả tour đã có hướng dẫn viên!</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <table class="table-modern">
                                    <thead>
                                        <tr>
                                            <th>Tour</th>
                                            <th>Ngày Khởi Hành</th>
                                            <th>Ngày Về</th>
                                            <th>Giá</th>
                                            <th>Trạng Thái</th>
                                            <th style="text-align:center;">Hành Động</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="schedule" items="${unassignedSchedules}">
                                            <tr>
                                                <td>
                                                    <div style="font-weight:600;color:var(--gray-900);">${schedule.tour.tourName}</div>
                                                    <div style="font-size:12px;color:var(--gray-500);">${schedule.tour.destination}</div>
                                                </td>
                                                <td><fmt:formatDate value="${schedule.departureDate}" pattern="dd/MM/yyyy"/></td>
                                                <td><fmt:formatDate value="${schedule.returnDate}" pattern="dd/MM/yyyy"/></td>
                                                <td><fmt:formatNumber value="${schedule.priceAdult}" type="number"/> đ</td>
                                                <td>
                                                    <span class="badge ${schedule.tourStatus == 'Preparing' ? 'badge-warning' : schedule.tourStatus == 'Scheduled' ? 'badge-primary' : 'badge-secondary'}">
                                                        ${schedule.tourStatus}
                                                    </span>
                                                </td>
                                                <td style="text-align:center;">
                                                    <button class="btn btn-primary btn-sm" onclick="openAssignModal(${schedule.scheduleId}, '${schedule.tour.tourName}', '${schedule.departureDate}')">
                                                        <i data-lucide="user-plus" style="width:14px;height:14px;"></i> Gán Guide
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
            </div>

            <!-- Tab: Lịch sử phân công -->
            <div id="tab-assignments" class="tab-content" style="display:none;">
                <div class="card">
                    <div class="card-header">
                        <h3><i data-lucide="history" style="color:var(--primary);"></i> Lịch Sử Phân Công Guide</h3>
                    </div>
                    <div class="card-body" style="padding:0;">
                        <c:choose>
                            <c:when test="${empty assignments}">
                                <div class="empty-state">
                                    <i data-lucide="inbox"></i>
                                    <p>Chưa có lịch sử phân công nào.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <table class="table-modern">
                                    <thead>
                                        <tr>
                                            <th>Tour</th>
                                            <th>Hướng Dẫn Viên</th>
                                            <th>Ngày Khởi Hành</th>
                                            <th>Người Phân Công</th>
                                            <th>Ngày Phân Công</th>
                                            <th style="text-align:center;">Hành Động</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="assignment" items="${assignments}">
                                            <tr>
                                                <td>
                                                    <div style="font-weight:600;color:var(--gray-900);">${assignment.schedule.tour.tourName}</div>
                                                    <div style="font-size:12px;color:var(--gray-500);">
                                                        <fmt:formatDate value="${assignment.schedule.departureDate}" pattern="dd/MM/yyyy"/>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div style="display:flex;align-items:center;gap:8px;">
                                                        <div class="guide-avatar" style="width:32px;height:32px;font-size:12px;">
                                                            ${fn:substring(assignment.guide.fullName, 0, 1)}
                                                        </div>
                                                        <div>
                                                            <div style="font-weight:600;font-size:14px;">${assignment.guide.fullName}</div>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td><fmt:formatDate value="${assignment.schedule.departureDate}" pattern="dd/MM/yyyy"/></td>
                                                <td>${assignment.assignedByName != null ? assignment.assignedByName : 'Hệ thống'}</td>
                                                <td><fmt:formatDate value="${assignment.assignedAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                                <td style="text-align:center;">
                                                    <button class="btn btn-outline btn-sm" onclick="viewDetails(${assignment.scheduleId})">
                                                        <i data-lucide="eye" style="width:14px;height:14px;"></i> Chi tiết
                                                    </button>
                                                    <button class="btn btn-outline btn-sm" style="color:var(--danger);border-color:var(--danger-light);" onclick="unassignGuide(${assignment.scheduleId}, ${assignment.guideId})">
                                                        <i data-lucide="user-minus" style="width:14px;height:14px;"></i> Hủy
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
            </div>

        </div>
    </main>
</div>

<!-- Modal Gán Guide -->
<div class="modal-overlay" id="assignModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3><i data-lucide="user-plus" style="vertical-align:middle;margin-right:8px;"></i>Phân Công Hướng Dẫn Viên</h3>
            <button class="modal-close" onclick="closeAssignModal()"><i data-lucide="x"></i></button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="modal-schedule-id">
            <div style="background:var(--gray-50);padding:12px 16px;border-radius:10px;margin-bottom:20px;">
                <div style="font-weight:600;color:var(--gray-900);" id="modal-tour-name"></div>
                <div style="font-size:13px;color:var(--gray-500);" id="modal-departure-date"></div>
            </div>

            <div class="form-group">
                <label>Chọn Hướng Dẫn Viên *</label>
                <select id="modal-guide-select" class="form-control" required>
                    <option value="">-- Chọn Guide --</option>
                    <c:forEach var="guide" items="${guides}">
                        <option value="${guide.user.userId}">${guide.user.fullName} (${guide.yearsOfExperience} năm kinh nghiệm, ⭐${guide.rating})</option>
                    </c:forEach>
                </select>
            </div>

            <div class="form-group">
                <label>Ghi Chú</label>
                <textarea id="modal-notes" class="form-control" rows="3" placeholder="Nhập ghi chú phân công (tùy chọn)..."></textarea>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-outline" onclick="closeAssignModal()">Hủy</button>
            <button class="btn btn-primary" onclick="submitAssignment()">
                <i data-lucide="check" style="width:14px;height:14px;"></i> Xác Nhận Phân Công
            </button>
        </div>
    </div>
</div>

<!-- Modal Chi Tiết -->
<div class="modal-overlay" id="detailModal">
    <div class="modal-box" style="width:600px;">
        <div class="modal-header">
            <h3><i data-lucide="info" style="vertical-align:middle;margin-right:8px;"></i>Chi Tiết Phân Công</h3>
            <button class="modal-close" onclick="closeDetailModal()"><i data-lucide="x"></i></button>
        </div>
        <div class="modal-body" id="detail-content">
            <!-- Nội dung sẽ được load động -->
        </div>
        <div class="modal-footer">
            <button class="btn btn-outline" onclick="closeDetailModal()">Đóng</button>
        </div>
    </div>
</div>

<script>
    lucide.createIcons();

    // Toast auto dismiss
    const toast = document.getElementById('toastMsg');
    if (toast) setTimeout(() => toast.style.display = 'none', 4000);

    function showTab(tabName) {
        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        document.querySelectorAll('.tab-content').forEach(c => c.style.display = 'none');

        if (tabName === 'unassigned') {
            document.querySelector('.tab:nth-child(1)').classList.add('active');
            document.getElementById('tab-unassigned').style.display = 'block';
        } else {
            document.querySelector('.tab:nth-child(2)').classList.add('active');
            document.getElementById('tab-assignments').style.display = 'block';
        }
    }

    function openAssignModal(scheduleId, tourName, departureDate) {
        document.getElementById('modal-schedule-id').value = scheduleId;
        document.getElementById('modal-tour-name').textContent = tourName;
        document.getElementById('modal-departure-date').textContent = 'Ngày khởi hành: ' + formatDate(departureDate);
        document.getElementById('modal-guide-select').value = '';
        document.getElementById('modal-notes').value = '';
        document.getElementById('assignModal').classList.add('open');
    }

    function closeAssignModal() {
        document.getElementById('assignModal').classList.remove('open');
    }

    function submitAssignment() {
        const scheduleId = document.getElementById('modal-schedule-id').value;
        const guideId = document.getElementById('modal-guide-select').value;
        const notes = document.getElementById('modal-notes').value;

        if (!guideId) {
            alert('Vui lòng chọn hướng dẫn viên!');
            return;
        }

        const params = new URLSearchParams();
        params.append('action', 'assign');
        params.append('scheduleId', scheduleId);
        params.append('guideId', guideId);
        params.append('notes', notes);

        fetch('${pageContext.request.contextPath}/staff/tour-assignments', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params
        })
        .then(res => res.json())
        .then(data => {
            if (data.status === 'success') {
                alert(data.message);
                closeAssignModal();
                location.reload();
            } else {
                alert(data.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert('Đã xảy ra lỗi khi phân công!');
        });
    }

    function viewDetails(scheduleId) {
        const content = document.getElementById('detail-content');
        content.innerHTML = '<div style="text-align:center;padding:40px;"><i data-lucide="loader-2" class="animate-spin" style="width:32px;height:32px;color:var(--primary);"></i></div>';
        document.getElementById('detailModal').classList.add('open');
        lucide.createIcons();

        fetch('${pageContext.request.contextPath}/staff/tour-assignments?action=details&scheduleId=' + scheduleId)
            .then(res => res.text())
            .then(html => {
                content.innerHTML = '<div style="padding:20px;text-align:center;color:var(--gray-500);">Đang tải...</div>';
            })
            .catch(err => {
                content.innerHTML = '<div style="padding:20px;color:var(--danger);">Lỗi khi tải chi tiết</div>';
            });
    }

    function closeDetailModal() {
        document.getElementById('detailModal').classList.remove('open');
    }

    function unassignGuide(scheduleId, guideId) {
        if (!confirm('Bạn có chắc muốn hủy phân công guide này?')) return;

        const params = new URLSearchParams();
        params.append('action', 'unassign');
        params.append('scheduleId', scheduleId);
        params.append('guideId', guideId);

        fetch('${pageContext.request.contextPath}/staff/tour-assignments', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params
        })
        .then(res => res.json())
        .then(data => {
            if (data.status === 'success') {
                alert(data.message);
                location.reload();
            } else {
                alert(data.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert('Đã xảy ra lỗi!');
        });
    }

    function formatDate(dateStr) {
        if (!dateStr) return '';
        const date = new Date(dateStr);
        return date.toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric' });
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
