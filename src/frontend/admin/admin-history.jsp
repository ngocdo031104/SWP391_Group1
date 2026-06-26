<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:if test="${empty sessionScope.sessionUser || (sessionScope.sessionUser.roleId ne 1 && sessionScope.sessionUser.role.roleName ne 'Admin')}">
    <c:redirect url="/login" />
</c:if>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch Sử Quản Trị — TourBuddy Enterprise</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=1.6">
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <aside class="sidebar">
        <!-- Re-use sidebar code -->
        <div class="sidebar-brand">
            <div class="logo-icon">T</div><span>TourBuddy</span>
        </div>
        <ul class="sidebar-menu">
            <li>
                <a href="${pageContext.request.contextPath}/admin/dashboard">
                    <i data-lucide="layout-dashboard"></i>
                    <span>Tổng Quan</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/users">
                    <i data-lucide="users"></i>
                    <span>Quản Lý Người Dùng</span>
                </a>
            </li>
            <li class="active">
                <a href="${pageContext.request.contextPath}/admin/users?action=history">
                    <i data-lucide="history"></i>
                    <span>Lịch Sử Quản Trị</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/tours">
                    <i data-lucide="compass"></i>
                    <span>Quản Lý Tour</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i data-lucide="calendar"></i>
                    <span>Lịch Trình & Giá</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i data-lucide="image"></i>
                    <span>Thư Viện Media</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i data-lucide="bar-chart-3"></i>
                    <span>Thống Kê Chi Tiết</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i data-lucide="file-text"></i>
                    <span>Báo Cáo Doanh Thu</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i data-lucide="trending-up"></i>
                    <span>Dự Báo & Xu Hướng</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/roles">
                    <i data-lucide="shield-check"></i>
                    <span>Phân Quyền</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i data-lucide="settings"></i>
                    <span>Cấu Hình</span>
                </a>
            </li>
        </ul>
        <div class="sidebar-footer">
            <a href="${pageContext.request.contextPath}/home" style="color: var(--text-gray);"><i data-lucide="home"></i><span>Về Trang Chủ</span></a>
        </div>
    </aside>

    <main class="main-content">
        <header class="top-header">
            <h1>Lịch Sử Quản Trị Hệ Thống</h1>
        </header>

        <section class="view-panel active">
            <div class="content-card">
                <div class="card-header">
                    <h3 class="card-title">Nhật ký hoạt động</h3>
                </div>
                <div class="card-body table-responsive" style="padding: 0;">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>Thời Gian</th>
                                <th>Loại Hành Động</th>
                                <th>Chi Tiết</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="log" items="${logs}">
                                <tr>
                                    <td><fmt:formatDate value="${log.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/></td>
                                    <td>
                                        <span style="font-weight: 500; color: #1a73e8;">${log.actionType}</span>
                                    </td>
                                    <td>${log.details}</td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty logs}">
                                <tr>
                                    <td colspan="3" style="text-align: center; padding: 20px;">Không có dữ liệu lịch sử.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>
    </main>
</div>

<script>
    lucide.createIcons();
</script>
</body>
</html>
