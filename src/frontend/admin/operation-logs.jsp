<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<c:if test="${empty sessionScope.sessionUser || (sessionScope.sessionUser.roleId ne 1 && sessionScope.userRole ne 'Admin')}">
    <c:redirect url="${pageContext.request.contextPath}/login"/>
</c:if>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nh&#7853;t K&#253; V&#7853;n H&#224;nh Tour &#8212; TourBuddy Admin</title>
    <!-- Outfit & Inter Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons & FontAwesome CDNs -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.3">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/tb-ui.css?v=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-space-overrides.css?v=1.0">
    <style>
        .search-bar-group { display: flex; gap: 12px; margin-bottom: 20px; max-width: 600px; }
        .search-input { flex: 1; padding: 10px 14px; border: 1px solid var(--border-color, #e2e8f0); border-radius: 8px; font-family: 'Inter', sans-serif; font-size: 0.9rem; outline: none; background-color: #ffffff; color: #334155; }
        .search-input:focus { border-color: var(--primary-color, #2563eb); }
        .btn-search { background-color: #2563eb; color: #ffffff; padding: 10px 20px; border-radius: 8px; font-weight: bold; border: none; cursor: pointer; transition: background 0.2s; font-family: 'Outfit', sans-serif; }
        .btn-search:hover { background-color: #1d4ed8; }

        .table-logs { width: 100%; border-collapse: collapse; background: #ffffff; border-radius: 8px; overflow: hidden; border: 1px solid #cbd5e1; }
        .table-logs th, .table-logs td { padding: 14px 16px; border-bottom: 1px solid #e2e8f0; text-align: left; font-size: 0.9rem; }
        .table-logs th { background-color: #f8fafc; font-weight: 600; color: #334155; }
        .table-logs tr:hover { background-color: #f1f5f9; }

        .role-badge { padding: 4px 8px; border-radius: 6px; font-size: 0.75rem; font-weight: bold; display: inline-block; }
        .role-admin { background-color: #fee2e2; color: #dc2626; }
        .role-guide { background-color: #e0f2fe; color: #0369a1; }
        .role-staff { background-color: #fef3c7; color: #d97706; }
        .role-default { background-color: #f1f5f9; color: #64748b; }

        .pagination { display: flex; gap: 8px; justify-content: center; margin-top: 24px; font-family: 'Inter', sans-serif; }
        .page-link { padding: 8px 14px; border: 1px solid #cbd5e1; border-radius: 6px; text-decoration: none; color: #475569; font-size: 0.9rem; transition: all 0.2s; }
        .page-link:hover, .page-link.active { background-color: #2563eb; color: #ffffff; border-color: #2563eb; font-weight: bold; }
    </style>
</head>
<body class="dashboard-body tb-cosmic">

<div class="dashboard-wrapper">
    <!-- &#9472;&#9472; Left Sidebar &#9472;&#9472; -->
    <c:set var="activePage" value="oplogs" scope="request" />
    <jsp:include page="sidebar.jsp" />

    <!-- &#9472;&#9472; Main Content Area &#9472;&#9472; -->
    <main class="main-content theme-light">
        <!-- Top Header -->
        <header class="top-header" style="margin-bottom: 24px;">
            <div>
                <h1 style="font-size: 24px; color: #f8fafc; margin: 0 0 8px 0;">Nh&#7853;t K&#253; V&#7853;n H&#224;nh Tour</h1>
                <p style="color: #9fa9cb; margin: 0; font-size: 14px;">Gi&#225;m s&#225;t l&#7883;ch s&#7917; ho&#7841;t &#273;&#7897;ng, tr&#7841;ng th&#225;i chuy&#7875;n &#273;&#7893;i v&#224; thay &#273;&#7893;i v&#7853;n h&#224;nh c&#7911;a c&#225;c l&#7883;ch tr&#236;nh kh&#7903;i h&#224;nh.</p>
            </div>
            <jsp:include page="admin-header-right.jsp" />
        </header>

        <!-- Search group -->
        <form method="GET" action="${pageContext.request.contextPath}/admin/operation-logs" class="search-bar-group">
            <input type="text" name="search" class="search-input" value="<c:out value="${search}"/>" placeholder="T&#236;m theo t&#234;n tour, ho&#7841;t &#273;&#7897;ng, t&#234;n ng&#432;&#7901;i v&#7853;n h&#224;nh...">
            <button type="submit" class="btn-search"><i class="fa fa-search"></i> T&#236;m ki&#7871;m</button>
        </form>

        <!-- Log List Card -->
        <div class="card" style="background: #ffffff; padding: 20px; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid var(--gray-200);">
            <c:choose>
                <c:when test="${empty logs}">
                    <div class="empty-state" style="text-align: center; padding: 40px 20px; color: #94a3b8;">
                        <i class="fa fa-history" style="font-size: 3rem; margin-bottom: 16px;"></i>
                        <p>Kh&#244;ng t&#236;m th&#7845;y nh&#7853;t k&#253; v&#7853;n h&#224;nh n&#224;o kh&#7899;p v&#7899;i &#273;i&#7873;u ki&#7879;n l&#7885;c.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="overflow-x: auto;">
                        <table class="table-logs">
                            <thead>
                                <tr>
                                    <th style="width: 60px; text-align: center;">M&#227; Log</th>
                                    <th>Tour &amp; L&#7883;ch Kh&#7903;i H&#224;nh</th>
                                    <th>Ho&#7841;t &#272;&#7897;ng / Thay &#272;&#7893;i</th>
                                    <th>Ng&#432;&#7901;i Th&#7921;c Hi&#7879;n</th>
                                    <th>Vai Tr&#242;</th>
                                    <th>Th&#7901;i Gian Th&#7921;c Hi&#7879;n</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="log" items="${logs}">
                                    <tr>
                                        <td style="text-align: center; font-weight: bold; color: #64748b;">#<c:out value="${log.logId}" /></td>
                                        <td>
                                            <div style="font-weight: 600; color: #1e293b;"><c:out value="${log.tourName}" /></div>
                                            <div style="font-size: 0.8rem; color: #64748b; margin-top: 2px;">
                                                Ng&#224;y kh&#7903;i h&#224;nh: <fmt:formatDate value="${log.departureDate}" pattern="dd/MM/yyyy" />
                                            </div>
                                        </td>
                                        <td style="font-weight: 500; color: #334155;"><c:out value="${log.activity}" /></td>
                                        <td style="font-weight: 600;"><c:out value="${empty log.operatorName ? 'H&#7879; th&#7889;ng t&#7921; &#273;&#7897;ng' : log.operatorName}" /></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${log.operatorRole == 'Admin'}">
                                                    <span class="role-badge role-admin">Qu&#7843;n tr&#7883; vi&#234;n</span>
                                                </c:when>
                                                <c:when test="${log.operatorRole == 'Guide'}">
                                                    <span class="role-badge role-guide">H&#432;&#7899;ng d&#7851;n vi&#234;n</span>
                                                </c:when>
                                                <c:when test="${log.operatorRole == 'Staff'}">
                                                    <span class="role-badge role-staff">Nh&#226;n vi&#234;n</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="role-badge role-default"><c:out value="${empty log.operatorRole ? 'System' : log.operatorRole}" /></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><fmt:formatDate value="${log.createdAt}" pattern="HH:mm:ss dd/MM/yyyy" /></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <c:if test="${totalPages > 1}">
                        <c:url var="searchQs" value="">
                            <c:param name="search" value="${search}" />
                        </c:url>
                        <div class="pagination">
                            <c:if test="${currentPage > 1}">
                                <a href="?page=${currentPage - 1}&search=<c:out value='${search}'/>" class="page-link">&laquo; Tr&#432;&#7899;c</a>
                            </c:if>
                            <c:forEach var="i" begin="1" end="${totalPages}">
                                <a href="?page=${i}&search=<c:out value='${search}'/>" class="page-link ${i == currentPage ? 'active' : ''}">${i}</a>
                            </c:forEach>
                            <c:if test="${currentPage < totalPages}">
                                <a href="?page=${currentPage + 1}&search=<c:out value='${search}'/>" class="page-link">Sau &raquo;</a>
                            </c:if>
                        </div>
                    </c:if>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>

<!-- Icons loading helper -->
<script src="https://unpkg.com/lucide@latest"></script>
<script src="${pageContext.request.contextPath}/js/tb-ui.js?v=1.0"></script>
<script>
    if (window.lucide) {
        lucide.createIcons();
    }
</script>
<script src="${pageContext.request.contextPath}/js/admin-dashboard.js?v=<%= System.currentTimeMillis() %>" charset="UTF-8"></script>
</body>
</html>
