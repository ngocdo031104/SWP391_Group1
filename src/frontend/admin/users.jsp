<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:if test="${empty sessionScope.sessionUser || (sessionScope.sessionUser.roleId ne 1 && sessionScope.sessionUser.role.roleName ne 'Admin')}">
    <c:redirect url="/login" />
</c:if>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Người Dùng — TourBuddy Enterprise</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=1.6">
    <style>
        .badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 500;
        }
        .badge-active { background-color: #e6f4ea; color: #1e8e3e; }
        .badge-locked { background-color: #fce8e6; color: #d93025; }
        .action-btn { background: none; border: none; cursor: pointer; color: #1a73e8; margin-right: 10px; }
        .action-btn.lock { color: #d93025; }
        .action-btn.unlock { color: #1e8e3e; }
    </style>
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <!-- Left Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-brand">
            <div class="logo-icon">T</div>
            <span>TourBuddy</span>
        </div>
        
        <ul class="sidebar-menu">
            <li>
                <a href="${pageContext.request.contextPath}/admin/dashboard">
                    <i data-lucide="layout-dashboard"></i>
                    <span>Tổng Quan</span>
                </a>
            </li>
            <li class="active">
                <a href="${pageContext.request.contextPath}/admin/users">
                    <i data-lucide="users"></i>
                    <span>Quản Lý Người Dùng</span>
                </a>
            </li>
            <li>
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
            <a href="${pageContext.request.contextPath}/home" style="color: var(--text-gray);">
                <i data-lucide="home"></i><span>Về Trang Chủ</span>
            </a>
            <a href="${pageContext.request.contextPath}/logout" style="color: var(--error-red); margin-top: 5px;">
                <i data-lucide="log-out"></i><span>Đăng Xuất</span>
            </a>
        </div>
    </aside>

    <!-- Main Content Area -->
    <main class="main-content">
        <!-- Top Header -->
        <header class="top-header">
            <h1>Danh Sách Người Dùng</h1>
            <div class="header-right">
                <div class="header-search">
                    <i data-lucide="search"></i>
                    <input type="text" id="searchInput" placeholder="Tìm kiếm người dùng...">
                </div>
            </div>
        </header>

        <section class="view-panel active">
            <c:if test="${not empty sessionScope.successMsg}">
                <div style="background-color: #e6f4ea; color: #1e8e3e; padding: 10px; margin-bottom: 15px; border-radius: 4px;">
                    ${sessionScope.successMsg}
                </div>
                <c:remove var="successMsg" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.errorMsg}">
                <div style="background-color: #fce8e6; color: #d93025; padding: 10px; margin-bottom: 15px; border-radius: 4px;">
                    ${sessionScope.errorMsg}
                </div>
                <c:remove var="errorMsg" scope="session"/>
            </c:if>

            <div class="content-card">
                <div class="card-header">
                    <h3 class="card-title">Tất cả người dùng</h3>
                </div>
                <div class="card-body table-responsive" style="padding: 0;">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Họ Tên</th>
                                <th>Email</th>
                                <th>Vai Trò</th>
                                <th>Trạng Thái</th>
                                <th>Hành Động</th>
                            </tr>
                        </thead>
                        <tbody id="usersTableBody">
                            <c:forEach var="user" items="${users}">
                                <tr>
                                    <td>${user.userId}</td>
                                    <td>${user.fullName}</td>
                                    <td>${user.email}</td>
                                    <td>${user.role.roleName}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${user.isActive}">
                                                <span class="badge badge-active">Hoạt động</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-locked">Đã khóa</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <a href="?action=view&id=${user.userId}" class="action-btn" title="Xem chi tiết">
                                            <i data-lucide="eye"></i>
                                        </a>
                                        <c:if test="${user.userId ne sessionScope.sessionUser.userId}">
                                            <form action="?action=toggleStatus" method="POST" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn thay đổi trạng thái tài khoản này?');">
                                                <input type="hidden" name="userId" value="${user.userId}">
                                                <input type="hidden" name="status" value="${!user.isActive}">
                                                <button type="submit" class="action-btn ${user.isActive ? 'lock' : 'unlock'}" title="${user.isActive ? 'Khóa tài khoản' : 'Mở khóa'}">
                                                    <i data-lucide="${user.isActive ? 'lock' : 'unlock'}"></i>
                                                </button>
                                            </form>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>
    </main>
</div>

<script>
    lucide.createIcons();

    // Table filtering logic
    document.getElementById('searchInput').addEventListener('keyup', function() {
        var searchValue = this.value.toLowerCase();
        var tableBody = document.getElementById('usersTableBody');
        var rows = tableBody.getElementsByTagName('tr');

        for (var i = 0; i < rows.length; i++) {
            var rowText = rows[i].textContent.toLowerCase();
            if (rowText.includes(searchValue)) {
                rows[i].style.display = '';
            } else {
                rows[i].style.display = 'none';
            }
        }
    });
</script>
</body>
</html>
