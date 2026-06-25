<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt"  prefix="fmt" %>
<c:if test="${empty sessionUser || (sessionUser.roleId ne 1 && sessionUser.roleId ne 5 && userRole ne 'Admin' && userRole ne 'Accountant')}">
    <c:redirect url="/login" />
</c:if>
<c:set var="isAccountant" value="${sessionUser.roleId eq 5 || userRole eq 'Accountant'}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hệ Thống Báo Cáo & Thống Kê — TourBuddy Admin</title>
    <!-- Outfit & Inter Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons & FontAwesome CDNs -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=1.6">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-analytics.css?v=1.0">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="analytics-body">

<div class="dashboard-wrapper">
    <!-- ── Left Sidebar ── -->
    <aside class="sidebar">
        <div class="sidebar-brand">
            <div class="logo-icon">T</div>
            <span>TourBuddy</span>
        </div>
        
        <ul class="sidebar-menu">
            <c:if test="${!isAccountant}">
            <li>
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
            </c:if>
            <li class="active">
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
            <h1>Thống kê & Phân tích chuyên sâu</h1>
            <div class="header-right" style="display: flex; align-items: center; gap: 15px;">
                <!-- Snapshot Control Panel -->
                <div style="background: rgba(30, 41, 59, 0.6); padding: 8px 16px; border-radius: 8px; border: 1px solid rgba(255,255,255,0.08); display: flex; align-items: center; gap: 10px;">
                    <label for="snapshot-type" style="font-size: 0.85rem; color: var(--text-gray);">Chụp báo cáo:</label>
                    <select id="snapshot-type" class="chart-select">
                        <option value="Revenue">Thống kê Doanh Thu</option>
                        <option value="Booking">Lượng Đặt Chỗ</option>
                        <option value="TourPerformance">Hiệu Suất Tour</option>
                        <option value="GuideActivity">Hoạt Động HDV</option>
                    </select>
                    <button id="btn-save-snapshot" class="btn-action btn-primary">Chụp Snapshot</button>
                </div>

                <div class="profile-user" style="display: flex; align-items: center; gap: 10px;">
                    <div class="profile-meta" style="text-align: right;">
                        <span class="name" style="display: block; color: var(--text-main); font-weight: 600;">${not empty sessionUser.fullName ? sessionUser.fullName : 'Sarah Jenkins'}</span>
                        <span class="role" style="display: block; font-size: 0.75rem; color: var(--text-gray);">${sessionUser.roleId eq 1 ? 'Quản trị viên' : 'Kế toán viên'}</span>
                    </div>
                </div>
            </div>
        </header>

        <!-- ── Navigation Tab Bar ── -->
        <div class="analytics-tabs">
            <button class="tab-btn active" data-tab="tab-revenue">
                <i data-lucide="dollar-sign"></i> Phân Tích Doanh Thu
            </button>
            <button class="tab-btn" data-tab="tab-bookings">
                <i data-lucide="shopping-cart"></i> Lượng Đặt Chỗ
            </button>
            <button class="tab-btn" data-tab="tab-performance">
                <i data-lucide="activity"></i> Hiệu Suất Tour
            </button>
            <button class="tab-btn" data-tab="tab-guides">
                <i data-lucide="users"></i> Hoạt Động Hướng Dẫn Viên
            </button>
            <button class="tab-btn" data-tab="tab-reports">
                <i data-lucide="archive"></i> Lịch Sử Báo Cáo Lưu Trữ
            </button>
        </div>

        <!-- ── Tab 1: Doanh Thu ── -->
        <div class="tab-pane active" id="tab-revenue">
            <div class="kpi-grid">
                <div class="kpi-card">
                    <div class="kpi-icon"><i data-lucide="trending-up"></i></div>
                    <div class="kpi-label">Tổng doanh thu gần đây</div>
                    <div class="kpi-value" id="kpi-total-revenue">0 đ</div>
                    <div class="kpi-trend up"><i data-lucide="arrow-up-right"></i> +12.5% so với tháng trước</div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-icon"><i data-lucide="pie-chart"></i></div>
                    <div class="kpi-label">Doanh thu trung bình tháng</div>
                    <div class="kpi-value" id="kpi-avg-revenue">0 đ</div>
                    <div class="kpi-trend up"><i data-lucide="arrow-up-right"></i> Ổn định</div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-icon"><i data-lucide="star"></i></div>
                    <div class="kpi-label">Danh mục dẫn đầu</div>
                    <div class="kpi-value" id="kpi-top-category" style="font-size: 1.4rem;">N/A</div>
                    <div class="kpi-trend up">Hiệu suất cao nhất</div>
                </div>
            </div>

            <div class="charts-grid">
                <div class="chart-card">
                    <div class="chart-header">
                        <h3 class="chart-title">Biểu đồ doanh thu hàng tháng</h3>
                    </div>
                    <div class="chart-container">
                        <canvas id="chart-monthly-revenue"></canvas>
                    </div>
                </div>
                <div class="chart-card">
                    <div class="chart-header">
                        <h3 class="chart-title">Cơ cấu doanh thu theo Danh mục Tour</h3>
                    </div>
                    <div class="chart-container">
                        <canvas id="chart-category-revenue"></canvas>
                    </div>
                </div>
            </div>

            <div class="chart-card" style="margin-bottom: 24px;">
                <div class="chart-header">
                    <h3 class="chart-title">Top 10 Tour mang lại doanh thu cao nhất</h3>
                </div>
                <div class="chart-container" style="height: 350px;">
                    <canvas id="chart-tour-revenue"></canvas>
                </div>
            </div>
        </div>

        <!-- ── Tab 2: Lượng Đặt Chỗ ── -->
        <div class="tab-pane" id="tab-bookings">
            <div class="kpi-grid">
                <div class="kpi-card">
                    <div class="kpi-icon"><i data-lucide="users"></i></div>
                    <div class="kpi-label">Tổng số đặt chỗ (30 ngày qua)</div>
                    <div class="kpi-value" id="kpi-total-bookings">0</div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-icon"><i data-lucide="check-circle-2"></i></div>
                    <div class="kpi-label">Đặt chỗ hoàn tất</div>
                    <div class="kpi-value" id="kpi-completed-bookings">0</div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-icon"><i data-lucide="help-circle"></i></div>
                    <div class="kpi-label">Đang chờ thanh toán/phê duyệt</div>
                    <div class="kpi-value" id="kpi-pending-bookings">0</div>
                </div>
            </div>

            <div class="charts-grid">
                <div class="chart-card">
                    <div class="chart-header">
                        <h3 class="chart-title">Xu hướng đặt chỗ hàng ngày (30 ngày gần đây)</h3>
                    </div>
                    <div class="chart-container">
                        <canvas id="chart-booking-trends"></canvas>
                    </div>
                </div>
                <div class="chart-card">
                    <div class="chart-header">
                        <h3 class="chart-title">Phân phối trạng thái Đặt chỗ</h3>
                    </div>
                    <div class="chart-container">
                        <canvas id="chart-booking-status"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <!-- ── Tab 3: Hiệu Suất Tour ── -->
        <div class="tab-pane" id="tab-performance">
            <div class="table-card">
                <div class="table-header">
                    <h3 class="table-title">Hiệu suất và Tỉ lệ lấp đầy của Tour</h3>
                    <c:choose>
                        <c:when test="${isAccountant}">
                            <button class="btn-action btn-primary" onclick="confirmExport('tour-performance-table', 'tour_performance.csv')">
                                <i data-lucide="download"></i> Xuất CSV dữ liệu bảng
                            </button>
                        </c:when>
                        <c:otherwise>
                            <span class="badge-status pending" style="border-radius: 4px; padding: 6px 12px;"><i data-lucide="lock" style="width:14px;height:14px;display:inline-block;vertical-align:middle;"></i> Chỉ dành cho Kế toán viên</span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <table class="custom-table" id="tour-performance-table">
                    <thead>
                        <tr>
                            <th>Mã Tour</th>
                            <th>Tên Tour</th>
                            <th>Lượt đặt chỗ</th>
                            <th>Doanh thu</th>
                            <th>Điểm đánh giá</th>
                            <th>Tỉ lệ lấp đầy TB</th>
                        </tr>
                    </thead>
                    <tbody id="tour-performance-tbody">
                        <!-- Filled dynamically -->
                    </tbody>
                </table>
            </div>
        </div>

        <!-- ── Tab 4: Hướng Dẫn Viên ── -->
        <div class="tab-pane" id="tab-guides">
            <div class="table-card">
                <div class="table-header">
                    <h3 class="table-title">Báo cáo hoạt động của Hướng dẫn viên</h3>
                    <c:choose>
                        <c:when test="${isAccountant}">
                            <button class="btn-action btn-primary" onclick="confirmExport('guide-activity-table', 'guide_activity.csv')">
                                <i data-lucide="download"></i> Xuất CSV dữ liệu bảng
                            </button>
                        </c:when>
                        <c:otherwise>
                            <span class="badge-status pending" style="border-radius: 4px; padding: 6px 12px;"><i data-lucide="lock" style="width:14px;height:14px;display:inline-block;vertical-align:middle;"></i> Chỉ dành cho Kế toán viên</span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <table class="custom-table" id="guide-activity-table">
                    <thead>
                        <tr>
                            <th>ID HDV</th>
                            <th>Họ và Tên</th>
                            <th>Kinh nghiệm</th>
                            <th>Đánh giá trung bình</th>
                            <th>Số Tour (Đã dẫn / Phân công)</th>
                            <th>Chuyên môn</th>
                            <th>Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody id="guide-activity-tbody">
                        <!-- Filled dynamically -->
                    </tbody>
                </table>
            </div>
        </div>

        <!-- ── Tab 5: Lưu Trữ Báo Cáo Snapshot ── -->
        <div class="tab-pane" id="tab-reports">
            <div class="table-card">
                <div class="table-header">
                    <h3 class="table-title">Lịch sử Snapshot báo cáo đã lưu trữ</h3>
                </div>
                <table class="custom-table" id="reports-snapshot-table">
                    <thead>
                        <tr>
                            <th>ID Báo Cáo</th>
                            <th>Loại Báo Cáo</th>
                            <th>Khoảng Thời Gian</th>
                            <th>Người Tạo</th>
                            <th>Ngày Tạo</th>
                            <th>Hành Động</th>
                        </tr>
                    </thead>
                    <tbody id="reports-snapshot-tbody">
                        <!-- Filled dynamically -->
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>

<!-- ── Report JSON Viewer Modal ── -->
<div class="modal-overlay" id="report-modal">
    <div class="modal-content" style="position: relative;">
        <button class="modal-close" id="modal-close-btn">&times;</button>
        <h3 class="modal-title">Xem chi tiết dữ liệu snapshot</h3>
        <div id="modal-body-content">
            <!-- Dynamically populated -->
        </div>
    </div>
</div>
<!-- ── Confirmation Modal ── -->
<div class="modal-overlay" id="confirm-modal">
    <div class="modal-content" style="position: relative; max-width: 450px;">
        <button class="modal-close" id="confirm-close-btn">&times;</button>
        <h3 class="modal-title" id="confirm-title" style="display: flex; align-items: center; gap: 8px; color: var(--warning-yellow); margin-bottom: 10px;">
            <i data-lucide="alert-triangle" style="stroke: var(--warning-yellow);"></i> Xác nhận yêu cầu
        </h3>
        <div id="confirm-body-content" style="margin: 15px 0; font-size: 0.95rem; line-height: 1.5; color: var(--text-main);">
            Bạn có chắc chắn muốn thực hiện hành động này?
        </div>
        <div style="display: flex; justify-content: flex-end; gap: 10px; padding-top: 15px; border-top: 1px solid var(--card-border);">
            <button type="button" class="btn-action" id="confirm-cancel-btn">Hủy bỏ</button>
            <button type="button" class="btn-action btn-primary" id="confirm-ok-btn">Xác nhận</button>
        </div>
    </div>
</div>
<!-- Standard Script Files -->
<script src="${pageContext.request.contextPath}/js/admin-analytics.js?v=1.0"></script>
</body>
</html>
