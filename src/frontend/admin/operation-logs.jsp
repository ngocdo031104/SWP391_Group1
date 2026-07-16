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
    <title>Nhật Ký Vận Hành Tour — TourBuddy Admin</title>
    <!-- Outfit & Inter Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons & FontAwesome CDNs -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.1">
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
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <!-- ── Left Sidebar ── -->
    <c:set var="activePage" value="oplogs" scope="request" />
    <jsp:include page="sidebar.jsp" />

    <!-- ── Main Content Area ── -->
    <main class="main-content">
        <!-- Top Header -->
        <header class="top-header" style="margin-bottom: 24px;">
            <div>
                <h1 style="font-size: 24px; color: var(--gray-900); margin: 0 0 8px 0;">Nhật Ký Vận Hành Tour</h1>
                <p style="color: var(--gray-500); margin: 0; font-size: 14px;">Giám sát lịch sử hoạt động, trạng thái chuyển đổi và thay đổi vận hành của các lịch trình khởi hành.</p>
            </div>
            <jsp:include page="admin-header-right.jsp" />
        </header>

        <!-- Search group -->
        <form method="GET" action="${pageContext.request.contextPath}/admin/operation-logs" class="search-bar-group">
            <input type="text" name="search" class="search-input" value="<c:out value="${search}"/>" placeholder="Tìm theo tên tour, hoạt động, tên người vận hành...">
            <button type="submit" class="btn-search"><i class="fa fa-search"></i> Tìm kiếm</button>
        </form>

        <!-- Log List Card -->
        <div class="card" style="background: #ffffff; padding: 20px; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid var(--gray-200);">
            <c:choose>
                <c:when test="${empty logs}">
                    <div class="empty-state" style="text-align: center; padding: 40px 20px; color: #94a3b8;">
                        <i class="fa fa-history" style="font-size: 3rem; margin-bottom: 16px;"></i>
                        <p>Không tìm thấy nhật ký vận hành nào khớp với điều kiện lọc.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="overflow-x: auto;">
                        <table class="table-logs">
                            <thead>
                                <tr>
                                    <th style="width: 60px; text-align: center;">Mã Log</th>
                                    <th>Tour &amp; Lịch Khởi Hành</th>
                                    <th>Hoạt Động / Thay Đổi</th>
                                    <th>Người Thực Hiện</th>
                                    <th>Vai Trò</th>
                                    <th>Thời Gian Thực Hiện</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="log" items="${logs}">
                                    <tr>
                                        <td style="text-align: center; font-weight: bold; color: #64748b;">#<c:out value="${log.logId}" /></td>
                                        <td>
                                            <div style="font-weight: 600; color: #1e293b;"><c:out value="${log.tourName}" /></div>
                                            <div style="font-size: 0.8rem; color: #64748b; margin-top: 2px;">
                                                Ngày khởi hành: <fmt:formatDate value="${log.departureDate}" pattern="dd/MM/yyyy" />
                                            </div>
                                        </td>
                                        <td style="font-weight: 500; color: #334155;"><c:out value="${log.activity}" /></td>
                                        <td style="font-weight: 600;"><c:out value="${empty log.operatorName ? 'Hệ thống tự động' : log.operatorName}" /></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${log.operatorRole == 'Admin'}">
                                                    <span class="role-badge role-admin">Quản trị viên</span>
                                                </c:when>
                                                <c:when test="${log.operatorRole == 'Guide'}">
                                                    <span class="role-badge role-guide">Hướng dẫn viên</span>
                                                </c:when>
                                                <c:when test="${log.operatorRole == 'Staff'}">
                                                    <span class="role-badge role-staff">Nhân viên</span>
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
                                <a href="?page=${currentPage - 1}&search=<c:out value='${search}'/>" class="page-link">&laquo; Trước</a>
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
<script>
    if (window.lucide) {
        lucide.createIcons();
    }
</script>
<script src="${pageContext.request.contextPath}/js/admin-dashboard.js"></script>
</body>
</html>
