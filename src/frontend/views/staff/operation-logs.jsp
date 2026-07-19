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
    <title>Nh&#7853;t K&#253; V&#7853;n H&#224;nh - Staff Dashboard</title>
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
        .badge-primary { background: var(--primary-light); color: var(--primary); }
        .badge-success { background: var(--success-light); color: var(--success); }
        .badge-warning { background: var(--warning-light); color: var(--warning); }
        .badge-secondary { background: var(--gray-100); color: var(--gray-500); }

        .table-modern { width: 100%; border-collapse: collapse; }
        .table-modern th { background: var(--gray-50); padding: 12px 16px; text-align: left; font-size: 12px; font-weight: 600; color: var(--gray-500); text-transform: uppercase; letter-spacing: .5px; border-bottom: 1px solid var(--gray-200); }
        .table-modern td { padding: 14px 16px; border-bottom: 1px solid var(--gray-100); color: var(--gray-700); vertical-align: middle; }
        .table-modern tr:last-child td { border-bottom: none; }
        .table-modern tr:hover { background: var(--gray-50); }

        .stat-card { background: #fff; border-radius: 16px; padding: 20px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); border: 1px solid var(--gray-100); display: flex; align-items: center; gap: 16px; }
        .stat-icon { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .stat-icon.primary { background: var(--primary-light); color: var(--primary); }
        .stat-info h4 { margin: 0; font-size: 13px; color: var(--gray-500); font-weight: 500; }
        .stat-info .stat-value { margin: 4px 0 0; font-size: 24px; font-weight: 700; color: #ffffff; }

        .pagination { display: flex; justify-content: center; align-items: center; gap: 8px; padding: 20px; }
        .page-btn { width: 36px; height: 36px; border-radius: 8px; display: flex; align-items: center; justify-content: center; border: 1px solid var(--gray-200); background: #fff; color: var(--gray-700); cursor: pointer; font-size: 14px; font-weight: 500; text-decoration: none; transition: all .2s; }
        .page-btn:hover { border-color: var(--primary); color: var(--primary); }
        .page-btn.active { background: var(--primary); color: #fff; border-color: var(--primary); }
        .page-btn.disabled { opacity: .4; cursor: not-allowed; pointer-events: none; }

        .empty-state { text-align: center; padding: 60px 20px; color: var(--gray-500); }
        .empty-state i { width: 64px; height: 64px; color: var(--gray-200); margin-bottom: 16px; }
    </style>
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <c:set var="activePage" value="staff-logs" scope="request"/>
    <%@ include file="/admin/staff-sidebar.jsp" %>

    <main class="main-content">
        <div class="content-area">

            <div class="page-header">
                <div>
                    <h1>Nh&#7853;t K&#253; V&#7853;n H&#224;nh</h1>
                    <p>Xem to&#224;n b&#7897; nh&#7853;t k&#253; ho&#7841;t &#273;&#7897;ng c&#7911;a h&#7879; th&#7889;ng tour</p>
                </div>
            </div>

            <!-- Stats -->
            <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:20px;margin-bottom:24px;max-width:400px;">
                <div class="stat-card">
                    <div class="stat-icon primary"><i data-lucide="file-text"></i></div>
                    <div class="stat-info">
                        <h4>T&#7893;ng Ho&#7841;t &#272;&#7897;ng</h4>
                        <div class="stat-value">${totalLogs}</div>
                    </div>
                </div>
            </div>

            <!-- Table -->
            <div class="card">
                <div class="card-header">
                    <h3><i data-lucide="clock-rotate-left" style="color:var(--primary);"></i> Nh&#7853;t K&#253; Ho&#7841;t &#272;&#7897;ng</h3>
                </div>
                <div class="card-body" style="padding:0;">
                    <c:choose>
                        <c:when test="${empty logs}">
                            <div class="empty-state">
                                <i data-lucide="file-text"></i>
                                <p>Ch&#432;a c&#243; nh&#7853;t k&#253; ho&#7841;t &#273;&#7897;ng n&#224;o.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <table class="table-modern">
                                <thead>
                                    <tr>
                                        <th>Th&#7901;i Gian</th>
                                        <th>Tour</th>
                                        <th>Ho&#7841;t &#272;&#7897;ng</th>
                                        <th>Ng&#432;&#7901;i Th&#7921;c Hi&#7879;n</th>
                                        <th>Vai Tr&#242;</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="log" items="${logs}">
                                        <tr>
                                            <td>
                                                <div style="font-weight:600;"><fmt:formatDate value="${log.createdAt}" pattern="HH:mm"/></div>
                                                <div style="font-size:12px;color:var(--gray-500);"><fmt:formatDate value="${log.createdAt}" pattern="dd/MM/yyyy"/></div>
                                            </td>
                                            <td>
                                                <div style="font-weight:500;">${log.tourName}</div>
                                                <c:if test="${not empty log.departureDate}">
                                                    <div style="font-size:12px;color:var(--gray-500);">
                                                        <fmt:formatDate value="${log.departureDate}" pattern="dd/MM/yyyy"/>
                                                    </div>
                                                </c:if>
                                            </td>
                                            <td>
                                                <div style="max-width:350px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="${log.activity}">
                                                    ${log.activity}
                                                </div>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty log.operatorName}">
                                                        ${log.operatorName}
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color:var(--gray-500);font-style:italic;">H&#7879; th&#7889;ng</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${log.operatorRole eq 'Admin'}">
                                                        <span class="badge badge-primary">Admin</span>
                                                    </c:when>
                                                    <c:when test="${log.operatorRole eq 'Staff'}">
                                                        <span class="badge badge-warning">Staff</span>
                                                    </c:when>
                                                    <c:when test="${log.operatorRole eq 'Guide'}">
                                                        <span class="badge badge-success">Guide</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-secondary">${log.operatorRole}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>

                            <!-- Pagination -->
                            <c:if test="${totalPages > 1}">
                                <div class="pagination">
                                    <a href="?page=${currentPage - 1}" class="page-btn ${currentPage le 1 ? 'disabled' : ''}">
                                        <i data-lucide="chevron-left" style="width:16px;height:16px;"></i>
                                    </a>
                                    <c:forEach begin="1" end="${totalPages}" var="p">
                                        <a href="?page=${p}" class="page-btn ${p eq currentPage ? 'active' : ''}">${p}</a>
                                    </c:forEach>
                                    <a href="?page=${currentPage + 1}" class="page-btn ${currentPage ge totalPages ? 'disabled' : ''}">
                                        <i data-lucide="chevron-right" style="width:16px;height:16px;"></i>
                                    </a>
                                </div>
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

        </div>
    </main>
</div>

<script>
    lucide.createIcons();
</script>
</body>
</html>
