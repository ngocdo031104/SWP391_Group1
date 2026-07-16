<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.0">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <!-- ── Left Sidebar ── -->
    <c:set var="activePage" value="dashboard" scope="request" />
    <jsp:include page="sidebar.jsp" />

    <!-- ── Main Content Area ── -->
    <main class="main-content">
        <!-- Top Header -->
        <header class="top-header">
            <h1>Tổng quan hệ thống</h1>
            <jsp:include page="admin-header-right.jsp" />
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

<script src="${pageContext.request.contextPath}/js/admin-dashboard.js?v=1.2" charset="UTF-8"></script>
</body>
</html>
