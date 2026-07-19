<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nh&#7853;t K&#253; S&#7921; C&#7889; &#8212; TourBuddy</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/tourbuddy.css?v=1.4">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .dashboard-wrapper { max-width: 1200px; margin: 100px auto 40px; padding: 0 20px; }
        .tour-info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; background: rgba(0,0,0,0.02); padding: 20px; border-radius: 8px; margin-bottom: 20px; border: 1px solid var(--clr-border); }
        .info-item { display: flex; flex-direction: column; }
        .info-label { font-size: 0.85rem; color: var(--clr-muted); margin-bottom: 4px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
        .info-value { font-size: 1.05rem; font-weight: 500; color: var(--clr-text); }
        .table-custom { width: 100%; border-collapse: collapse; }
        .table-custom th, .table-custom td { padding: 14px 16px; border-bottom: 1px solid var(--clr-border); text-align: left; font-size: 0.95rem; }
        .table-custom th { background-color: rgba(0,0,0,0.02); font-weight: 600; color: var(--clr-text); }
        .table-custom tr:hover { background-color: rgba(0,0,0,0.01); }

        /* Severity styling */
        .badge-severity { padding: 4px 8px; border-radius: 6px; font-size: 0.8rem; font-weight: bold; display: inline-flex; align-items: center; gap: 4px; }
        .severity-low { background: #e2e8f0; color: #475569; }
        .severity-medium { background: #fef3c7; color: #d97706; }
        .severity-high { background: #ffedd5; color: #ea580c; }
        .severity-critical { background: #fee2e2; color: #dc2626; }

        /* Status styling */
        .badge-status { padding: 4px 8px; border-radius: 6px; font-size: 0.8rem; font-weight: bold; display: inline-flex; align-items: center; gap: 4px; }
        .status-open { background: #fee2e2; color: #dc2626; }
        .status-inprogress { background: #e0f2fe; color: #0284c7; }
        .status-resolved { background: #d1fae5; color: #059669; }
        .status-closed { background: #f1f5f9; color: #64748b; }

        /* Incident Modal Styles */
        .incident-modal {
            display: none;
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.4);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }

        .incident-modal.active {
            display: flex;
        }

        .incident-modal-content {
            background: #ffffff;
            padding: 24px;
            border-radius: 12px;
            width: 100%;
            max-width: 500px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
            animation: slideDown 0.3s ease;
        }

        @keyframes slideDown {
            from { transform: translateY(-20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        .incident-modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 12px;
        }

        .incident-modal-header h4 {
            margin: 0;
            font-size: 1.2rem;
            color: #1e293b;
            font-family: 'Outfit', sans-serif;
            font-weight: 700;
        }

        .incident-modal-close {
            background: none;
            border: none;
            font-size: 1.5rem;
            color: #94a3b8;
            cursor: pointer;
        }

        .incident-modal-close:hover {
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

        .form-input, .form-select, .form-textarea {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            outline: none;
            font-family: 'Inter', sans-serif;
            font-size: 0.9rem;
        }

        .form-input:focus, .form-select:focus, .form-textarea:focus {
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
        .guide-notif-bell:hover { color: var(--clr-primary); }
        .guide-notif-bell .notif-badge {
            position: absolute;
            top: -6px; right: -8px;
            background: #ef4444; color: white;
            font-size: 0.6rem; font-weight: 700;
            min-width: 16px; height: 16px;
            border-radius: 50%;
            display: none; align-items: center; justify-content: center;
            padding: 0 3px;
            border: 2px solid #fff;
            box-shadow: 0 1px 4px rgba(0,0,0,0.15);
        }
    </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar">
  <a href="#" class="logo" id="nav-logo">
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
    <div style="margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center;">
        <a href="${pageContext.request.contextPath}/guide/dashboard" class="btn btn-outline btn-sm">
            <i class="fa fa-arrow-left"></i> Quay l&#7841;i
        </a>
        <button class="btn btn-primary btn-sm" onclick="openIncidentModal()" style="font-weight: 600;">
            <i class="fa fa-plus"></i> B&#225;o C&#225;o S&#7921; C&#7889; M&#7899;i
        </button>
    </div>

    <div class="card fade-up">
        <div class="card-header">
            <h3><i class="fa fa-triangle-exclamation" style="margin-right:8px;color:var(--clr-primary)"></i> Nh&#7853;t K&#253; S&#7921; C&#7889; Tour</h3>
        </div>
        <div class="card-body">
            
            <c:if test="${not empty assignment}">
                <div class="tour-info-grid">
                    <div class="info-item">
                        <span class="info-label">T&#234;n Tour</span>
                        <span class="info-value"><c:out value="${assignment.schedule.tour.tourName}" /></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">&#272;i&#7875;m &#272;&#7871;n</span>
                        <span class="info-value"><c:out value="${assignment.schedule.tour.destination}" /></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Ng&#224;y Kh&#7903;i H&#224;nh</span>
                        <span class="info-value"><fmt:formatDate value="${assignment.schedule.departureDate}" pattern="dd/MM/yyyy" /></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Tr&#7841;ng Th&#225;i Tour</span>
                        <span class="info-value" style="font-weight:bold; color:var(--clr-primary)"><c:out value="${assignment.schedule.status}" /></span>
                    </div>
                </div>
            </c:if>

            <c:choose>
                <c:when test="${empty incidents}">
                    <div class="empty-state" style="text-align:center; padding: 40px 20px;">
                        <i class="fa fa-shield" style="font-size: 3rem; color: var(--clr-border); margin-bottom: 16px;"></i>
                        <p style="color: var(--clr-muted); font-size: 0.95rem;">Chuy&#7871;n &#273;i n&#224;y hi&#7879;n t&#7841;i ch&#432;a ghi nh&#7853;n s&#7921; c&#7889; n&#224;o ph&#225;t sinh.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="overflow-x: auto; border: 1px solid var(--clr-border); border-radius: 8px;">
                        <table class="table-custom">
                            <thead>
                                <tr>
                                    <th style="width: 80px; text-align: center;">M&#227; s&#7921; c&#7889;</th>
                                    <th>Ti&#234;u &#272;&#7873;</th>
                                    <th>Th&#7901;i Gian B&#225;o C&#225;o</th>
                                    <th style="width: 140px;">M&#7913;c &#272;&#7897;</th>
                                    <th style="width: 140px;">Tr&#7841;ng Th&#225;i</th>
                                    <th>M&#244; T&#7843; Chi Ti&#7871;t</th>
                                    <th style="width: 140px; text-align: center;">H&#224;nh &#272;&#7897;ng</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="inc" items="${incidents}">
                                    <tr>
                                        <td style="text-align: center; color: var(--clr-muted); font-weight: bold;">#<c:out value="${inc.incidentId}" /></td>
                                        <td style="font-weight: 600; color: #1e293b;"><c:out value="${inc.title}" /></td>
                                        <td><fmt:formatDate value="${inc.createdAt}" pattern="HH:mm dd/MM/yyyy" /></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${inc.severity == 'Low'}">
                                                    <span class="badge-severity severity-low">Th&#7845;p</span>
                                                </c:when>
                                                <c:when test="${inc.severity == 'Medium'}">
                                                    <span class="badge-severity severity-medium">Trung b&#236;nh</span>
                                                </c:when>
                                                <c:when test="${inc.severity == 'High'}">
                                                    <span class="badge-severity severity-high">Cao</span>
                                                </c:when>
                                                <c:when test="${inc.severity == 'Critical'}">
                                                    <span class="badge-severity severity-critical"><i class="fa fa-triangle-exclamation"></i> Nghi&#234;m tr&#7885;ng</span>
                                                </c:when>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${inc.status == 'Open'}">
                                                    <span class="badge-status status-open">&#272;ang m&#7903;</span>
                                                </c:when>
                                                <c:when test="${inc.status == 'InProgress'}">
                                                    <span class="badge-status status-inprogress">&#272;ang x&#7917; l&#253;</span>
                                                </c:when>
                                                <c:when test="${inc.status == 'Resolved'}">
                                                    <span class="badge-status status-resolved">&#272;&#227; gi&#7843;i quy&#7871;t</span>
                                                </c:when>
                                                <c:when test="${inc.status == 'Closed'}">
                                                    <span class="badge-status status-closed">&#272;&#227; &#273;&#243;ng</span>
                                                </c:when>
                                            </c:choose>
                                        </td>
                                        <td style="color: #475569; font-size: 0.9rem;"><c:out value="${inc.description}" /></td>
                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${inc.status == 'Open' || inc.status == 'InProgress'}">
                                                    <button class="btn btn-outline btn-sm" onclick="resolveIncident(${inc.incidentId})" style="padding: 6px 12px; font-size: 0.8rem; border-color: #10b981; color: #10b981; font-weight: bold; background: transparent; cursor: pointer;">
                                                        <i class="fa fa-check"></i> Gi&#7843;i quy&#7871;t
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: #94a3b8; font-size: 0.85rem;"><i class="fa fa-circle-check"></i> Ho&#224;n t&#7845;t</span>
                                                </c:otherwise>
                                            </c:choose>
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

<!-- Modal b&#225;o c&#225;o s&#7921; c&#7889; m&#7899;i -->
<div class="incident-modal" id="incident-modal">
    <div class="incident-modal-content">
        <div class="incident-modal-header">
            <h4>B&#225;o c&#225;o s&#7921; c&#7889; m&#7899;i</h4>
            <button class="incident-modal-close" onclick="closeIncidentModal()">&times;</button>
        </div>
        <div class="incident-modal-body">
            <div class="form-group">
                <label for="incident-title">Ti&#234;u &#273;&#7873; s&#7921; c&#7889; *</label>
                <input type="text" id="incident-title" class="form-input" placeholder="V&#237; d&#7909;: H&#7887;ng xe di chuy&#7875;n, Kh&#225;ch &#273;i l&#7841;c...">
            </div>

            <div class="form-group">
                <label for="incident-severity">M&#7913;c &#273;&#7897; &#7843;nh h&#432;&#7903;ng *</label>
                <select id="incident-severity" class="form-select">
                    <option value="Low">Low (Th&#7845;p - Kh&#244;ng &#7843;nh h&#432;&#7903;ng nhi&#7873;u)</option>
                    <option value="Medium" selected>Medium (Trung b&#236;nh - &#7842;nh h&#432;&#7903;ng l&#7883;ch tr&#236;nh nh&#7865;)</option>
                    <option value="High">High (Cao - C&#7847;n can thi&#7879;p g&#7845;p)</option>
                    <option value="Critical">Critical (Nghi&#234;m tr&#7885;ng - Nguy hi&#7875;m t&#237;nh m&#7841;ng/t&#224;i s&#7843;n)</option>
                </select>
            </div>

            <div class="form-group">
                <label for="incident-desc">M&#244; t&#7843; chi ti&#7871;t s&#7921; c&#7889; *</label>
                <textarea id="incident-desc" class="form-textarea" rows="4" placeholder="M&#244; t&#7843; di&#7877;n bi&#7871;n c&#7909; th&#7875;, v&#7883; tr&#237; x&#7843;y ra, s&#7889; ng&#432;&#7901;i &#7843;nh h&#432;&#7903;ng..."></textarea>
            </div>

            <div class="form-actions">
                <button class="btn btn-outline btn-sm" onclick="closeIncidentModal()" style="font-weight: 600;">H&#7911;y b&#7887;</button>
                <button class="btn btn-primary btn-sm" onclick="submitIncident()" style="font-weight: 600;">G&#7917;i b&#225;o c&#225;o</button>
            </div>
        </div>
    </div>
</div>

<script>
    function openIncidentModal() {
        document.getElementById('incident-title').value = '';
        document.getElementById('incident-severity').value = 'Medium';
        document.getElementById('incident-desc').value = '';
        document.getElementById('incident-modal').classList.add('active');
    }

    function closeIncidentModal() {
        document.getElementById('incident-modal').classList.remove('active');
    }

    function submitIncident() {
        const title = document.getElementById('incident-title').value;
        const severity = document.getElementById('incident-severity').value;
        const description = document.getElementById('incident-desc').value;
        const scheduleId = ${assignment.scheduleId};

        if (!title.trim() || !description.trim()) {
            alert('Vui l\u00f2ng \u0111i\u1ec1n \u0111\u1ea7y \u0111\u1ee7 ti\u00eau \u0111\u1ec1 v\u00e0 m\u00f4 t\u1ea3 s\u1ef1 c\u1ed1!');
            return;
        }

        const params = new URLSearchParams();
        params.append("action", "reportIncident");
        params.append("scheduleId", scheduleId);
        params.append("title", title);
        params.append("severity", severity);
        params.append("description", description);

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
                closeIncidentModal();
                window.location.reload();
            } else {
                alert(data.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert('L\u1ed7i h\u1ec7 th\u1ed1ng khi b\u00e1o c\u00e1o s\u1ef1 c\u1ed1!');
        });
    }

    function resolveIncident(incidentId) {
        if (!confirm('B\u1ea1n c\u00f3 ch\u1eafc ch\u1eafn mu\u1ed1n \u0111\u00e1nh d\u1ea5u s\u1ef1 c\u1ed1 n\u00e0y \u0111\u00e3 \u0111\u01b0\u1ee3c gi\u1ea3i quy\u1ebft?')) {
            return;
        }

        const params = new URLSearchParams();
        params.append("action", "updateIncidentStatus");
        params.append("incidentId", incidentId);
        params.append("status", "Resolved");

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
                window.location.reload();
            } else {
                alert(data.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert('L\u1ed7i h\u1ec7 th\u1ed1ng khi c\u1eadp nh\u1eadt tr\u1ea1ng th\u00e1i s\u1ef1 c\u1ed1!');
        });
    }
</script>

<script>
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

</body>
</html>
