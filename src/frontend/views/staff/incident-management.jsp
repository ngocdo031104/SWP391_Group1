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
    <title>Quản Lý Sự Cố - Staff Dashboard</title>
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

        .severity-low { background: var(--success-light); color: var(--success); }
        .severity-medium { background: var(--warning-light); color: var(--warning); }
        .severity-high { background: var(--danger-light); color: var(--danger); }
        .severity-critical { background: #7f1d1d; color: white; }

        .stat-card { background: #fff; border-radius: 16px; padding: 20px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); border: 1px solid var(--gray-100); display: flex; align-items: center; gap: 16px; transition: transform .2s; cursor: pointer; }
        .stat-card:hover { transform: translateY(-2px); }
        .stat-card.active { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-light); }
        .stat-icon { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .stat-icon.danger { background: var(--danger-light); color: var(--danger); }
        .stat-icon.warning { background: var(--warning-light); color: var(--warning); }
        .stat-icon.success { background: var(--success-light); color: var(--success); }
        .stat-icon.purple { background: var(--purple-light); color: var(--purple); }
        .stat-info h4 { margin: 0; font-size: 13px; color: var(--gray-500); font-weight: 500; }
        .stat-info .stat-value { margin: 4px 0 0; font-size: 24px; font-weight: 700; color: var(--gray-900); }

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

        .filter-bar { display: flex; gap: 12px; margin-bottom: 20px; }
        .filter-select { padding: 10px 16px; border: 1px solid var(--gray-200); border-radius: 8px; font-family: inherit; outline: none; background: #fff; cursor: pointer; }

        .modal-overlay { position: fixed; inset: 0; background: rgba(15,23,42,.5); backdrop-filter: blur(4px); z-index: 1000; display: none; align-items: center; justify-content: center; }
        .modal-overlay.open { display: flex; }
        .modal-box { background: #fff; border-radius: 16px; width: 600px; max-width: 95vw; box-shadow: 0 25px 50px rgba(0,0,0,.15); animation: modalIn .25s ease; }
        @keyframes modalIn { from { transform: scale(.95); opacity: 0; } to { transform: scale(1); opacity: 1; } }
        .modal-header { padding: 20px 24px; border-bottom: 1px solid var(--gray-200); display: flex; justify-content: space-between; align-items: center; }
        .modal-header h3 { margin: 0; font-size: 16px; font-weight: 600; }
        .modal-close { background: none; border: none; cursor: pointer; color: var(--gray-500); padding: 4px; border-radius: 4px; }
        .modal-close:hover { background: var(--gray-100); }
        .modal-body { padding: 24px; max-height: 500px; overflow-y: auto; }
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
    </style>
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <c:set var="activePage" value="staff-incidents" scope="request"/>
    <%@ include file="/admin/staff-sidebar.jsp" %>

    <main class="main-content">
        <div class="content-area">

            <div class="page-header">
                <div>
                    <h1>Quản Lý Sự Cố</h1>
                    <p>Xem và xử lý các sự cố trong quá trình vận hành tour</p>
                </div>
            </div>

            <c:if test="${not empty successMessage}">
                <div class="toast success" id="toastMsg">
                    <i data-lucide="check-circle"></i> ${successMessage}
                </div>
            </c:if>

            <!-- Stats -->
            <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:20px;margin-bottom:24px;">
                <a href="?status=Open" class="stat-card ${statusFilter eq 'Open' ? 'active' : ''}">
                    <div class="stat-icon danger"><i data-lucide="alert-circle"></i></div>
                    <div class="stat-info">
                        <h4>Mới Báo Cáo</h4>
                        <div class="stat-value">${openCount}</div>
                    </div>
                </a>
                <a href="?status=Investigating" class="stat-card ${statusFilter eq 'Investigating' ? 'active' : ''}">
                    <div class="stat-icon warning"><i data-lucide="search"></i></div>
                    <div class="stat-info">
                        <h4>Đang Xử Lý</h4>
                        <div class="stat-value">${investigatingCount}</div>
                    </div>
                </a>
                <a href="?status=Resolved" class="stat-card ${statusFilter eq 'Resolved' ? 'active' : ''}">
                    <div class="stat-icon success"><i data-lucide="check-circle-2"></i></div>
                    <div class="stat-info">
                        <h4>Đã Xử Lý</h4>
                        <div class="stat-value">${resolvedCount}</div>
                    </div>
                </a>
                <a href="?status=All" class="stat-card ${statusFilter eq 'All' ? 'active' : ''}">
                    <div class="stat-icon purple"><i data-lucide="layers"></i></div>
                    <div class="stat-info">
                        <h4>Tổng Cộng</h4>
                        <div class="stat-value">${openCount + investigatingCount + resolvedCount}</div>
                    </div>
                </a>
            </div>

            <!-- Filter -->
            <div class="filter-bar">
                <select class="filter-select" onchange="location.href='?status=' + this.value">
                    <option value="All" ${statusFilter eq 'All' ? 'selected' : ''}>Tất cả trạng thái</option>
                    <option value="Open" ${statusFilter eq 'Open' ? 'selected' : ''}>Mới báo cáo</option>
                    <option value="Investigating" ${statusFilter eq 'Investigating' ? 'selected' : ''}>Đang xử lý</option>
                    <option value="Resolved" ${statusFilter eq 'Resolved' ? 'selected' : ''}>Đã xử lý</option>
                    <option value="Dismissed" ${statusFilter eq 'Dismissed' ? 'selected' : ''}>Đã bỏ qua</option>
                </select>
            </div>

            <!-- Table -->
            <div class="card">
                <div class="card-header">
                    <h3><i data-lucide="alert-triangle" style="color:var(--warning);"></i> Danh Sách Sự Cố</h3>
                </div>
                <div class="card-body" style="padding:0;">
                    <c:choose>
                        <c:when test="${empty incidents}">
                            <div class="empty-state">
                                <i data-lucide="check-circle-2"></i>
                                <p>Không có sự cố nào được báo cáo.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <table class="table-modern">
                                <thead>
                                    <tr>
                                        <th>Tour</th>
                                        <th>Tiêu Đề</th>
                                        <th>Người Báo Cáo</th>
                                        <th>Mức Độ</th>
                                        <th>Trạng Thái</th>
                                        <th>Ngày Báo Cáo</th>
                                        <th style="text-align:center;">Hành Động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="incident" items="${incidents}">
                                        <tr>
                                            <td>
                                                <div style="font-weight:600;">${incident.tourName}</div>
                                                <div style="font-size:12px;color:var(--gray-500);">
                                                    <fmt:formatDate value="${incident.departureDate}" pattern="dd/MM/yyyy"/>
                                                    <c:if test="${not empty incident.guideName}">
                                                        - Guide: ${incident.guideName}
                                                    </c:if>
                                                </div>
                                            </td>
                                            <td>
                                                <div style="font-weight:500;">${incident.title}</div>
                                                <div style="font-size:12px;color:var(--gray-500);max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                                                    ${incident.description}
                                                </div>
                                            </td>
                                            <td>${incident.reportedByName}</td>
                                            <td>
                                                <span class="badge severity-${incident.severity}">${incident.severity}</span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${incident.status eq 'Open'}">
                                                        <span class="badge badge-danger">Mới báo cáo</span>
                                                    </c:when>
                                                    <c:when test="${incident.status eq 'Investigating'}">
                                                        <span class="badge badge-warning">Đang xử lý</span>
                                                    </c:when>
                                                    <c:when test="${incident.status eq 'Resolved'}">
                                                        <span class="badge badge-success">Đã xử lý</span>
                                                    </c:when>
                                                    <c:when test="${incident.status eq 'Dismissed'}">
                                                        <span class="badge badge-secondary">Đã bỏ qua</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-secondary">${incident.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td><fmt:formatDate value="${incident.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                            <td style="text-align:center;">
                                                <button class="btn btn-primary btn-sm" onclick="viewIncident(${incident.incidentId})">
                                                    <i data-lucide="eye" style="width:14px;height:14px;"></i> Chi tiết
                                                </button>
                                                <c:if test="${incident.status eq 'Open' || incident.status eq 'Investigating'}">
                                                    <button class="btn btn-outline btn-sm" onclick="openStatusModal(${incident.incidentId}, '${incident.status}')">
                                                        <i data-lucide="edit" style="width:14px;height:14px;"></i> Cập nhật
                                                    </button>
                                                </c:if>
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
    </main>
</div>

<!-- Modal Chi Tiết -->
<div class="modal-overlay" id="detailModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3><i data-lucide="info" style="vertical-align:middle;margin-right:8px;"></i>Chi Tiết Sự Cố</h3>
            <button class="modal-close" onclick="closeDetailModal()"><i data-lucide="x"></i></button>
        </div>
        <div class="modal-body" id="incident-detail-content">
            <!-- Nội dung động -->
        </div>
        <div class="modal-footer">
            <button class="btn btn-outline" onclick="closeDetailModal()">Đóng</button>
        </div>
    </div>
</div>

<!-- Modal Cập nhật trạng thái -->
<div class="modal-overlay" id="statusModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3><i data-lucide="edit" style="vertical-align:middle;margin-right:8px;"></i>Cập Nhật Trạng Thái Sự Cố</h3>
            <button class="modal-close" onclick="closeStatusModal()"><i data-lucide="x"></i></button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="modal-incident-id">
            <div class="form-group">
                <label for="modal-status-select">Trạng Thái Mới</label>
                <select id="modal-status-select" class="form-control">
                    <option value="Open">Mới báo cáo</option>
                    <option value="Investigating">Đang xử lý</option>
                    <option value="Resolved">Đã xử lý</option>
                    <option value="Dismissed">Đã bỏ qua</option>
                </select>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-outline" onclick="closeStatusModal()">Hủy</button>
            <button class="btn btn-primary" onclick="submitStatusUpdate()">
                <i data-lucide="check" style="width:14px;height:14px;"></i> Cập Nhật
            </button>
        </div>
    </div>
</div>

<script>
    lucide.createIcons();

    // Toast auto dismiss
    const toast = document.getElementById('toastMsg');
    if (toast) setTimeout(() => toast.style.display = 'none', 4000);

    function viewIncident(incidentId) {
        const incidents = <%= new com.google.gson.Gson().toJson(request.getAttribute("incidents")) %>;
        const incident = incidents.find(i => i.incidentId == incidentId);
        if (!incident) return;

        const content = document.getElementById('incident-detail-content');
        content.innerHTML = `
            <div style="margin-bottom:20px;">
                <h4 style="margin:0 0 8px;font-size:16px;color:var(--gray-900);">\${incident.title}</h4>
                <span class="badge severity-\${incident.severity}" style="margin-bottom:12px;display:inline-flex;">\${incident.severity}</span>
                <p style="color:var(--gray-700);line-height:1.6;">\${incident.description}</p>
            </div>

            <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;background:var(--gray-50);padding:16px;border-radius:10px;">
                <div>
                    <div style="font-size:12px;color:var(--gray-500);">Tour</div>
                    <div style="font-weight:600;">\${incident.tourName}</div>
                </div>
                <div>
                    <div style="font-size:12px;color:var(--gray-500);">Ngày khởi hành</div>
                    <div style="font-weight:600;">\${incident.departureDate ? new Date(incident.departureDate).toLocaleDateString('vi-VN') : 'N/A'}</div>
                </div>
                <div>
                    <div style="font-size:12px;color:var(--gray-500);">Người báo cáo</div>
                    <div style="font-weight:600;">\${incident.reportedByName}</div>
                </div>
                <div>
                    <div style="font-size:12px;color:var(--gray-500);">Guide phụ trách</div>
                    <div style="font-weight:600;">\${incident.guideName || 'Chưa có'}</div>
                </div>
                <div>
                    <div style="font-size:12px;color:var(--gray-500);">Ngày báo cáo</div>
                    <div style="font-weight:600;">\${incident.createdAt ? new Date(incident.createdAt).toLocaleString('vi-VN') : 'N/A'}</div>
                </div>
                <div>
                    <div style="font-size:12px;color:var(--gray-500);">Trạng thái</div>
                    <div style="font-weight:600;">
                        \${incident.status === 'Open' ? '<span style="color:var(--danger);">Mới báo cáo</span>' : ''}
                        \${incident.status === 'Investigating' ? '<span style="color:var(--warning);">Đang xử lý</span>' : ''}
                        \${incident.status === 'Resolved' ? '<span style="color:var(--success);">Đã xử lý</span>' : ''}
                        \${incident.status === 'Dismissed' ? '<span style="color:var(--gray-500);">Đã bỏ qua</span>' : ''}
                    </div>
                </div>
            </div>
        `;

        document.getElementById('detailModal').classList.add('open');
    }

    function closeDetailModal() {
        document.getElementById('detailModal').classList.remove('open');
    }

    function openStatusModal(incidentId, currentStatus) {
        document.getElementById('modal-incident-id').value = incidentId;
        document.getElementById('modal-status-select').value = currentStatus;
        document.getElementById('statusModal').classList.add('open');
    }

    function closeStatusModal() {
        document.getElementById('statusModal').classList.remove('open');
    }

    function submitStatusUpdate() {
        const incidentId = document.getElementById('modal-incident-id').value;
        const newStatus = document.getElementById('modal-status-select').value;

        const params = new URLSearchParams();
        params.append('action', 'updateStatus');
        params.append('incidentId', incidentId);
        params.append('status', newStatus);

        fetch('${pageContext.request.contextPath}/staff/incidents', {
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
            alert('Đã xảy ra lỗi!');
        });
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
