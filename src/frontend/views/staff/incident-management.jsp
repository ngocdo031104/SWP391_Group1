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
    <title>Qu&#7843;n L&#253; S&#7921; C&#7889; - Staff Dashboard</title>
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
        .stat-info .stat-value { margin: 4px 0 0; font-size: 24px; font-weight: 700; color: #ffffff; }

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
                    <h1>Qu&#7843;n L&#253; S&#7921; C&#7889;</h1>
                    <p>Xem v&#224; x&#7917; l&#253; c&#225;c s&#7921; c&#7889; trong qu&#225; tr&#236;nh v&#7853;n h&#224;nh tour</p>
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
                        <h4>M&#7899;i B&#225;o C&#225;o</h4>
                        <div class="stat-value">${openCount}</div>
                    </div>
                </a>
                <a href="?status=Investigating" class="stat-card ${statusFilter eq 'Investigating' ? 'active' : ''}">
                    <div class="stat-icon warning"><i data-lucide="search"></i></div>
                    <div class="stat-info">
                        <h4>&#272;ang X&#7917; L&#253;</h4>
                        <div class="stat-value">${investigatingCount}</div>
                    </div>
                </a>
                <a href="?status=Resolved" class="stat-card ${statusFilter eq 'Resolved' ? 'active' : ''}">
                    <div class="stat-icon success"><i data-lucide="check-circle-2"></i></div>
                    <div class="stat-info">
                        <h4>&#272;&#227; X&#7917; L&#253;</h4>
                        <div class="stat-value">${resolvedCount}</div>
                    </div>
                </a>
                <a href="?status=All" class="stat-card ${statusFilter eq 'All' ? 'active' : ''}">
                    <div class="stat-icon purple"><i data-lucide="layers"></i></div>
                    <div class="stat-info">
                        <h4>T&#7893;ng C&#7897;ng</h4>
                        <div class="stat-value">${openCount + investigatingCount + resolvedCount}</div>
                    </div>
                </a>
            </div>

            <!-- Filter -->
            <div class="filter-bar">
                <select class="filter-select" onchange="location.href='?status=' + this.value">
                    <option value="All" ${statusFilter eq 'All' ? 'selected' : ''}>T&#7845;t c&#7843; tr&#7841;ng th&#225;i</option>
                    <option value="Open" ${statusFilter eq 'Open' ? 'selected' : ''}>M&#7899;i b&#225;o c&#225;o</option>
                    <option value="Investigating" ${statusFilter eq 'Investigating' ? 'selected' : ''}>&#272;ang x&#7917; l&#253;</option>
                    <option value="Resolved" ${statusFilter eq 'Resolved' ? 'selected' : ''}>&#272;&#227; x&#7917; l&#253;</option>
                    <option value="Dismissed" ${statusFilter eq 'Dismissed' ? 'selected' : ''}>&#272;&#227; b&#7887; qua</option>
                </select>
            </div>

            <!-- Table -->
            <div class="card">
                <div class="card-header">
                    <h3><i data-lucide="alert-triangle" style="color:var(--warning);"></i> Danh S&#225;ch S&#7921; C&#7889;</h3>
                </div>
                <div class="card-body" style="padding:0;">
                    <c:choose>
                        <c:when test="${empty incidents}">
                            <div class="empty-state">
                                <i data-lucide="check-circle-2"></i>
                                <p>Kh&#244;ng c&#243; s&#7921; c&#7889; n&#224;o &#273;&#432;&#7907;c b&#225;o c&#225;o.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <table class="table-modern">
                                <thead>
                                    <tr>
                                        <th>Tour</th>
                                        <th>Ti&#234;u &#272;&#7873;</th>
                                        <th>Ng&#432;&#7901;i B&#225;o C&#225;o</th>
                                        <th>M&#7913;c &#272;&#7897;</th>
                                        <th>Tr&#7841;ng Th&#225;i</th>
                                        <th>Ng&#224;y B&#225;o C&#225;o</th>
                                        <th style="text-align:center;">H&#224;nh &#272;&#7897;ng</th>
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
                                                        <span class="badge badge-danger">M&#7899;i b&#225;o c&#225;o</span>
                                                    </c:when>
                                                    <c:when test="${incident.status eq 'Investigating'}">
                                                        <span class="badge badge-warning">&#272;ang x&#7917; l&#253;</span>
                                                    </c:when>
                                                    <c:when test="${incident.status eq 'Resolved'}">
                                                        <span class="badge badge-success">&#272;&#227; x&#7917; l&#253;</span>
                                                    </c:when>
                                                    <c:when test="${incident.status eq 'Dismissed'}">
                                                        <span class="badge badge-secondary">&#272;&#227; b&#7887; qua</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-secondary">${incident.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td><fmt:formatDate value="${incident.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                            <td style="text-align:center;">
                                                <button class="btn btn-primary btn-sm" onclick="viewIncident(${incident.incidentId})">
                                                    <i data-lucide="eye" style="width:14px;height:14px;"></i> Chi ti&#7871;t
                                                </button>
                                                <c:if test="${incident.status eq 'Open' || incident.status eq 'Investigating'}">
                                                    <button class="btn btn-outline btn-sm" onclick="openStatusModal(${incident.incidentId}, '${incident.status}')">
                                                        <i data-lucide="edit" style="width:14px;height:14px;"></i> C&#7853;p nh&#7853;t
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

<!-- Modal Chi Ti&#7871;t -->
<div class="modal-overlay" id="detailModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3><i data-lucide="info" style="vertical-align:middle;margin-right:8px;"></i>Chi Ti&#7871;t S&#7921; C&#7889;</h3>
            <button class="modal-close" onclick="closeDetailModal()"><i data-lucide="x"></i></button>
        </div>
        <div class="modal-body" id="incident-detail-content">
            <!-- N&#7897;i dung &#273;&#7897;ng -->
        </div>
        <div class="modal-footer">
            <button class="btn btn-outline" onclick="closeDetailModal()">&#272;&#243;ng</button>
        </div>
    </div>
</div>

<!-- Modal C&#7853;p nh&#7853;t tr&#7841;ng th&#225;i -->
<div class="modal-overlay" id="statusModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3><i data-lucide="edit" style="vertical-align:middle;margin-right:8px;"></i>C&#7853;p Nh&#7853;t Tr&#7841;ng Th&#225;i S&#7921; C&#7889;</h3>
            <button class="modal-close" onclick="closeStatusModal()"><i data-lucide="x"></i></button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="modal-incident-id">
            <div class="form-group">
                <label for="modal-status-select">Tr&#7841;ng Th&#225;i M&#7899;i</label>
                <select id="modal-status-select" class="form-control">
                    <option value="Open">M&#7899;i b&#225;o c&#225;o</option>
                    <option value="Investigating">&#272;ang x&#7917; l&#253;</option>
                    <option value="Resolved">&#272;&#227; x&#7917; l&#253;</option>
                    <option value="Dismissed">&#272;&#227; b&#7887; qua</option>
                </select>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-outline" onclick="closeStatusModal()">H&#7911;y</button>
            <button class="btn btn-primary" onclick="submitStatusUpdate()">
                <i data-lucide="check" style="width:14px;height:14px;"></i> C&#7853;p Nh&#7853;t
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
                    <div style="font-size:12px;color:var(--gray-500);">Ng\u00e0y kh\u1edfi h\u00e0nh</div>
                    <div style="font-weight:600;">\${incident.departureDate ? new Date(incident.departureDate).toLocaleDateString('vi-VN') : 'N/A'}</div>
                </div>
                <div>
                    <div style="font-size:12px;color:var(--gray-500);">Ng\u01b0\u1eddi b\u00e1o c\u00e1o</div>
                    <div style="font-weight:600;">\${incident.reportedByName}</div>
                </div>
                <div>
                    <div style="font-size:12px;color:var(--gray-500);">Guide ph\u1ee5 tr\u00e1ch</div>
                    <div style="font-weight:600;">\${incident.guideName || 'Ch\u01b0a c\u00f3'}</div>
                </div>
                <div>
                    <div style="font-size:12px;color:var(--gray-500);">Ng\u00e0y b\u00e1o c\u00e1o</div>
                    <div style="font-weight:600;">\${incident.createdAt ? new Date(incident.createdAt).toLocaleString('vi-VN') : 'N/A'}</div>
                </div>
                <div>
                    <div style="font-size:12px;color:var(--gray-500);">Tr\u1ea1ng th\u00e1i</div>
                    <div style="font-weight:600;">
                        \${incident.status === 'Open' ? '<span style="color:var(--danger);">M\u1edbi b\u00e1o c\u00e1o</span>' : ''}
                        \${incident.status === 'Investigating' ? '<span style="color:var(--warning);">\u0110ang x\u1eed l\u00fd</span>' : ''}
                        \${incident.status === 'Resolved' ? '<span style="color:var(--success);">\u0110\u00e3 x\u1eed l\u00fd</span>' : ''}
                        \${incident.status === 'Dismissed' ? '<span style="color:var(--gray-500);">\u0110\u00e3 b\u1ecf qua</span>' : ''}
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
            alert('\u0110\u00e3 x\u1ea3y ra l\u1ed7i!');
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
