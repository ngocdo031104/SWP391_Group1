<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt"  prefix="fmt" %>
<c:if test="${empty sessionUser || (sessionUser.roleId ne 1 && userRole ne 'Admin')}">
    <c:redirect url="/login" />
</c:if>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tổng Quan Hệ Thống — TourBuddy Enterprise</title>
    <!-- Outfit & Inter Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons & FontAwesome CDNs -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=1.6">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <!-- ── Left Sidebar ── -->
    <aside class="sidebar">
        <div class="sidebar-brand">
            <div class="logo-icon">T</div>
            <span>TourBuddy</span>
        </div>
        
        <ul class="sidebar-menu">
            <li class="active">
                <a href="${pageContext.request.contextPath}/admin/dashboard">
                    <i data-lucide="layout-dashboard"></i>
                    <span>Tổng Quan</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/tours">
                    <i data-lucide="compass"></i>
                    <span>Quản Lý Tour</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/schedules">
                    <i data-lucide="calendar"></i>
                    <span>Lịch Trình & Giá</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/media">
                    <i data-lucide="image"></i>
                    <span>Thư Viện Media</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/analytics">
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
                <a href="#">
                    <i data-lucide="settings"></i>
                    <span>Cấu Hình</span>
                </a>
            </li>
        </ul>
        
        <div class="sidebar-footer">
            <a href="${pageContext.request.contextPath}/home" style="color: var(--text-gray);">
                <i data-lucide="home"></i>
                <span>Về Trang Chủ</span>
            </a>
            <a href="${pageContext.request.contextPath}/logout" style="color: var(--error-red); margin-top: 5px;">
                <i data-lucide="log-out"></i>
                <span>Đăng Xuất</span>
            </a>
        </div>
    </aside>

    <!-- ── Main Content Area ── -->
    <main class="main-content">
        <!-- Top Header -->
        <header class="top-header">
            <h1>Tổng quan hệ thống</h1>
            <div class="header-right">
                <div class="header-search">
                    <i data-lucide="search"></i>
                    <input type="text" placeholder="Tìm kiếm nhanh hệ thống...">
                </div>
                
                <div class="notif-bell" aria-label="Thông báo">
                    <i data-lucide="bell"></i>
                    <span class="badge">3</span>
                </div>
                
                <div class="profile-user dropdown-trigger" style="cursor: pointer; position: relative;" id="admin-profile-trigger">
                    <div class="profile-meta" style="text-align: right; margin-right: 5px;">
                        <span class="name">${not empty sessionUser.fullName ? sessionUser.fullName : 'Sarah Jenkins'}</span>
                        <span class="role">${(sessionUser.roleId eq 1 || userRole eq 'Admin') ? 'Quản trị viên SWP' : 'Nhân viên'}</span>
                    </div>
                    <c:choose>
                        <c:when test="${not empty sessionUser.profile && not empty sessionUser.profile.avatarUrl}">
                            <img src="${sessionUser.profile.avatarUrl}" alt="Avatar">
                        </c:when>
                        <c:otherwise>
                            <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80" alt="Avatar">
                        </c:otherwise>
                    </c:choose>
                    
                    <!-- Premium Avatar Dropdown Menu -->
                    <div class="avatar-dropdown-menu" id="admin-avatar-menu" style="display: none;">
                        <div class="dropdown-header">
                            <span class="d-name">${not empty sessionUser.fullName ? sessionUser.fullName : 'Sarah Jenkins'}</span>
                            <span class="d-email">${not empty sessionUser.email ? sessionUser.email : 'admin@tourbuddy.com'}</span>
                        </div>
                        <div class="dropdown-divider"></div>
                        <a href="${pageContext.request.contextPath}/profile" class="dropdown-item">
                            <i data-lucide="user"></i>
                            <span>Hồ Sơ Của Tôi</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/home" class="dropdown-item">
                            <i data-lucide="home"></i>
                            <span>Về Trang Chủ</span>
                        </a>
                        <div class="dropdown-divider"></div>
                        <a href="${pageContext.request.contextPath}/logout" class="dropdown-item logout-btn">
                            <i data-lucide="log-out"></i>
                            <span>Đăng Xuất</span>
                        </a>
                    </div>
                </div>
            </div>
        </header>

        <!-- ── VIEW 1: OVERVIEW DASHBOARD (TỔNG QUAN) ── -->
        <section class="view-panel active" id="view-overview">
            
            <!-- Lưới 4 Thẻ KPI thống kê trên cùng -->
            <div class="stats-grid">
                <!-- 1. Ước tính doanh thu -->
                <div class="stat-card">
                    <div class="stat-header">
                        <span class="stat-title">Ước tính doanh thu</span>
                        <div class="stat-icon blue"><i data-lucide="dollar-sign"></i></div>
                    </div>
                    <span class="stat-value" id="stats-revenue">0 ₫</span>
                    <div class="stat-footer" id="stats-revenue-footer">
                        <span class="stat-trend up"><i data-lucide="trending-up"></i> +12%</span>
                        <span>so với tháng trước</span>
                    </div>
                </div>
                <!-- 2. Tổng số tour -->
                <div class="stat-card">
                    <div class="stat-header">
                        <span class="stat-title">Tổng số tour</span>
                        <div class="stat-icon green"><i data-lucide="compass"></i></div>
                    </div>
                    <span class="stat-value" id="stats-tours-count">0</span>
                    <div class="stat-footer" id="stats-tours-footer">
                        <span class="stat-trend up"><i data-lucide="trending-up"></i> +2 tour</span>
                        <span>mới thêm trong tháng</span>
                    </div>
                </div>
                <!-- 3. Chỗ trống còn lại -->
                <div class="stat-card">
                    <div class="stat-header">
                        <span class="stat-title">Chỗ trống còn lại</span>
                        <div class="stat-icon orange"><i data-lucide="users"></i></div>
                    </div>
                    <span class="stat-value" id="stats-seats-left">0</span>
                    <div class="stat-footer" id="stats-seats-footer">
                        <span class="stat-trend down"><i data-lucide="trending-down"></i> -4%</span>
                        <span>giảm chỗ trống (đang bán chạy)</span>
                    </div>
                </div>
                <!-- 4. Tỷ lệ lấp đầy -->
                <div class="stat-card">
                    <div class="stat-header">
                        <span class="stat-title">Tỷ lệ lấp đầy</span>
                        <div class="stat-icon purple"><i data-lucide="percent"></i></div>
                    </div>
                    <span class="stat-value" id="stats-fill-rate">0%</span>
                    <div class="stat-footer" id="stats-fill-footer">
                        <span class="stat-trend up"><i data-lucide="trending-up"></i> +8.5%</span>
                        <span>tăng trưởng đặt chỗ</span>
                    </div>
                </div>
            </div>

            <!-- Bố cục Biểu đồ doanh thu và Khởi hành gần nhất -->
            <div class="charts-row-grid" style="margin-top: 1.5rem;">
                <!-- Biểu đồ doanh thu tổng quan -->
                <div class="content-card">
                    <div class="card-header">
                        <h3 class="card-title">Biểu Đồ Doanh Thu Tổng Quan</h3>
                    </div>
                    <div class="card-body">
                        <div class="chart-container" style="height: 280px; position: relative;">
                            <canvas id="overview-revenue-chart"></canvas>
                        </div>
                    </div>
                </div>
                <!-- Lịch trình khởi hành gần nhất -->
                <div class="content-card">
                    <div class="card-header">
                        <h3 class="card-title">Lịch trình khởi hành gần nhất</h3>
                        <a href="${pageContext.request.contextPath}/admin/tours" class="btn btn-secondary btn-sm">Xem lịch trình</a>
                    </div>
                    <div class="card-body table-responsive" style="padding: 0;">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>Tour</th>
                                    <th>Khởi hành</th>
                                    <th>Trạng thái ghế</th>
                                </tr>
                            </thead>
                            <tbody id="overview-departures-body">
                                <!-- Loaded dynamically via JS -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Bảng dưới cùng: Tour bán chạy / Được đánh giá cao nhất -->
            <div class="content-card" style="margin-top: 1.5rem;">
                <div class="card-header">
                    <h3 class="card-title">Tour Bán Chạy / Được Đánh Giá Cao Nhất</h3>
                    <a href="${pageContext.request.contextPath}/admin/tours" class="btn btn-secondary btn-sm">Quản lý tất cả</a>
                </div>
                <div class="card-body table-responsive" style="padding: 0;">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>Tour</th>
                                <th>Loại Tour</th>
                                <th>Độ Khó</th>
                                <th>Đánh Giá</th>
                                <th>Chỗ trống</th>
                                <th>Giá</th>
                            </tr>
                        </thead>
                        <tbody id="dashboard-recent-tours">
                            <!-- Loaded dynamically via JS -->
                        </tbody>
                    </table>
                </div>
            </div>
        </section>
    </main>
</div>

<script src="${pageContext.request.contextPath}/js/admin-dashboard.js?v=1.1"></script>
</body>
</html>
