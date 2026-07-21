<%-- 
    Màn hình 44: Review Tour Operation Logs - Xem nhật ký vận hành tour (Guide)
    Tác giả: Dương Quang Sơn
    MSSV: HE186525
    Ngày tạo: 2026-07-21
--%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nh&#7853;t K&#253; V&#7853;n H&#224;nh Tour &#8212; TourBuddy</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/tourbuddy.css?v=1.4">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .dashboard-wrapper { max-width: 900px; margin: 100px auto 40px; padding: 0 20px; }
        .tour-info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; background: rgba(0,0,0,0.02); padding: 20px; border-radius: 8px; margin-bottom: 24px; border: 1px solid var(--clr-border); }
        .info-item { display: flex; flex-direction: column; }
        .info-label { font-size: 0.85rem; color: var(--clr-muted); margin-bottom: 4px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
        .info-value { font-size: 1.05rem; font-weight: 500; color: var(--clr-text); }

        /* Timeline Styles */
        .timeline-container { position: relative; padding-left: 32px; margin-top: 20px; font-family: 'Inter', sans-serif; }
        .timeline-container::before { content: ''; position: absolute; left: 15px; top: 0; bottom: 0; width: 2px; background-color: #cbd5e1; }
        
        .timeline-item { position: relative; margin-bottom: 28px; }
        .timeline-marker { position: absolute; left: -24px; top: 4px; width: 14px; height: 14px; border-radius: 50%; border: 3px solid #ffffff; background-color: #2563eb; box-shadow: 0 0 0 3px #bfdbfe; }
        .timeline-item:first-child .timeline-marker { background-color: #10b981; box-shadow: 0 0 0 3px #a7f3d0; }
        
        .timeline-content { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 16px; position: relative; }
        .timeline-time { font-size: 0.8rem; color: #64748b; font-weight: 600; margin-bottom: 6px; display: inline-flex; align-items: center; gap: 4px; }
        .timeline-activity { font-size: 0.95rem; font-weight: 500; color: #1e293b; margin-bottom: 6px; }
        .timeline-operator { font-size: 0.82rem; color: #475569; display: inline-flex; align-items: center; gap: 6px; }
        
        .role-badge { padding: 2px 6px; border-radius: 4px; font-size: 0.72rem; font-weight: 700; text-transform: uppercase; }
        .role-admin { background-color: #fee2e2; color: #dc2626; }
        .role-guide { background-color: #e0f2fe; color: #0369a1; }
        .role-staff { background-color: #fef3c7; color: #d97706; }
        .role-default { background-color: #f1f5f9; color: #64748b; }
        /* Guide Notification Bell */
        .guide-notif-bell {
            position: relative; color: var(--clr-muted); cursor: pointer;
            transition: color 0.2s; display: inline-flex; align-items: center;
            font-size: 1.1rem; text-decoration: none;
        }
        .guide-notif-bell:hover { color: var(--clr-primary); }
        .guide-notif-bell .notif-badge {
            position: absolute; top: -6px; right: -8px;
            background: #ef4444; color: white;
            font-size: 0.6rem; font-weight: 700;
            min-width: 16px; height: 16px; border-radius: 50%;
            display: none; align-items: center; justify-content: center;
            padding: 0 3px; border: 2px solid #fff;
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
    <div style="margin-bottom: 20px;">
        <a href="${pageContext.request.contextPath}/guide/dashboard" class="btn btn-outline btn-sm">
            <i class="fa fa-arrow-left"></i> Quay l&#7841;i
        </a>
    </div>

    <div class="card fade-up">
        <div class="card-header">
            <h3><i class="fa fa-clock-rotate-left" style="margin-right:8px;color:var(--clr-primary)"></i> Nh&#7853;t K&#253; V&#7853;n H&#224;nh &#272;o&#224;n</h3>
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
                <c:when test="${empty logs}">
                    <div class="empty-state" style="text-align:center; padding: 40px 20px;">
                        <i class="fa fa-timeline" style="font-size: 3rem; color: var(--clr-border); margin-bottom: 16px;"></i>
                        <p style="color: var(--clr-muted); font-size: 0.95rem;">Chuy&#7871;n &#273;i n&#224;y hi&#7879;n t&#7841;i ch&#432;a c&#243; ghi nh&#7853;n ho&#7841;t &#273;&#7897;ng n&#224;o.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="timeline-container">
                        <c:forEach var="log" items="${logs}">
                            <div class="timeline-item">
                                <div class="timeline-marker"></div>
                                <div class="timeline-content">
                                    <div class="timeline-time">
                                        <i class="fa-regular fa-clock"></i>
                                        <fmt:formatDate value="${log.createdAt}" pattern="HH:mm:ss - dd/MM/yyyy" />
                                    </div>
                                    <div class="timeline-activity">
                                        <c:out value="${log.activity}" />
                                    </div>
                                    <div class="timeline-operator">
                                        <i class="fa-regular fa-user"></i>
                                        <span>Ng&#432;&#7901;i th&#7921;c hi&#7879;n: <strong><c:out value="${empty log.operatorName ? 'H&#7879; th&#7889;ng t&#7921; &#273;&#7897;ng' : log.operatorName}" /></strong></span>
                                        <c:if test="${not empty log.operatorRole}">
                                            <c:choose>
                                                <c:when test="${log.operatorRole == 'Admin'}">
                                                    <span class="role-badge role-admin">Qu&#7843;n tr&#7883; vi&#234;n</span>
                                                </c:when>
                                                <c:when test="${log.operatorRole == 'Guide'}">
                                                    <span class="role-badge role-guide">HDV</span>
                                                </c:when>
                                                <c:when test="${log.operatorRole == 'Staff'}">
                                                    <span class="role-badge role-staff">Nh&#226;n vi&#234;n</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="role-badge role-default"><c:out value="${log.operatorRole}" /></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                    <!-- Ph&#226;n trang -->
                    <c:if test="${totalPages > 1}">
                        <div class="pagination" style="display: flex; gap: 8px; justify-content: center; margin-top: 24px; font-family: 'Inter', sans-serif;">
                            <c:if test="${currentPage > 1}">
                                <a href="?action=operationLogs&scheduleId=${assignment.schedule.scheduleId}&page=${currentPage - 1}" class="page-link" style="padding: 8px 14px; border: 1px solid #cbd5e1; border-radius: 6px; text-decoration: none; color: #475569; font-size: 0.9rem;">&laquo; Tr&#432;&#7899;c</a>
                            </c:if>
                            <c:forEach var="i" begin="1" end="${totalPages}">
                                <a href="?action=operationLogs&scheduleId=${assignment.schedule.scheduleId}&page=${i}" class="page-link ${i == currentPage ? 'active' : ''}" style="padding: 8px 14px; border: 1px solid #cbd5e1; border-radius: 6px; text-decoration: none; color: #475569; font-size: 0.9rem; ${i == currentPage ? 'background-color: #2563eb; color: #fff; font-weight: bold; border-color: #2563eb;' : ''}">${i}</a>
                            </c:forEach>
                            <c:if test="${currentPage < totalPages}">
                                <a href="?action=operationLogs&scheduleId=${assignment.schedule.scheduleId}&page=${currentPage + 1}" class="page-link" style="padding: 8px 14px; border: 1px solid #cbd5e1; border-radius: 6px; text-decoration: none; color: #475569; font-size: 0.9rem;">Sau &raquo;</a>
                            </c:if>
                        </div>
                    </c:if>
                </c:otherwise>
            </c:choose>

        </div>
    </div>
</div>

</body>

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

</html>
