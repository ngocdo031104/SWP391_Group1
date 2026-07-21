<%-- 
    Màn hình 23: View Analytics Dashboard - Dashboard thống kê doanh thu, booking, hiệu suất
    Tác giả: Dương Quang Sơn
    MSSV: HE186525
    Ngày tạo: 2026-07-21
--%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

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
    <title>H&#7879; Th&#7889;ng B&#225;o C&#225;o & Th&#7889;ng K&#234; &#8212; TourBuddy Admin</title>
    <!-- Outfit & Inter Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons & FontAwesome CDNs -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.3">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-analytics.css?v=1.0">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-space-overrides.css?v=1.0">
</head>
<body class="analytics-body tb-cosmic">

<div class="dashboard-wrapper">
    <!-- &#9472;&#9472; Left Sidebar &#9472;&#9472; -->
    <c:set var="activePage" value="analytics" scope="request" />
    <jsp:include page="sidebar.jsp" />

    <!-- &#9472;&#9472; Main Content Area &#9472;&#9472; -->
    <main class="main-content">
        <!-- Top Header -->
        <header class="top-header">
            <h1>Th&#7889;ng k&#234; & Ph&#226;n t&#237;ch chuy&#234;n s&#226;u</h1>
            <div class="header-right" style="display: flex; align-items: center; gap: 15px;">
                <!-- Snapshot Control Panel -->
                <div style="background: rgba(30, 41, 59, 0.6); padding: 8px 16px; border-radius: 8px; border: 1px solid rgba(255,255,255,0.08); display: flex; align-items: center; gap: 10px;">
                    <label for="snapshot-type" style="font-size: 0.85rem; color: var(--text-gray);">Ch&#7909;p b&#225;o c&#225;o:</label>
                    <select id="snapshot-type" class="chart-select">
                        <option value="Revenue">Th&#7889;ng k&#234; Doanh Thu</option>
                        <option value="Booking">L&#432;&#7907;ng &#272;&#7863;t Ch&#7895;</option>
                        <option value="TourPerformance">Hi&#7879;u Su&#7845;t Tour</option>
                        <option value="GuideActivity">Ho&#7841;t &#272;&#7897;ng HDV</option>
                    </select>
                    <c:choose>
                        <c:when test="${isAccountant}">
                            <button id="btn-save-snapshot" class="btn-action btn-primary">Ch&#7909;p Snapshot</button>
                        </c:when>
                        <c:otherwise>
                            <button class="btn-action btn-primary" style="opacity: 0.5; cursor: not-allowed; display: flex; align-items: center; gap: 4px;" disabled title="Ch&#7881; d&#224;nh cho K&#7871; to&#225;n vi&#234;n">
                                <i data-lucide="lock" style="width:14px; height:14px;"></i> Ch&#7909;p Snapshot
                            </button>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="profile-user" style="display: flex; align-items: center; gap: 10px;">
                    <div class="profile-meta" style="text-align: right;">
                        <span class="name" style="display: block; color: var(--text-main); font-weight: 600;">${not empty sessionUser.fullName ? sessionUser.fullName : 'Sarah Jenkins'}</span>
                        <span class="role" style="display: block; font-size: 0.75rem; color: var(--text-gray);">${sessionUser.roleId eq 1 ? 'Qu&#7843;n tr&#7883; vi&#234;n' : 'K&#7871; to&#225;n vi&#234;n'}</span>
                    </div>
                </div>
            </div>
        </header>

        <!-- &#9472;&#9472; Navigation Tab Bar &#9472;&#9472; -->
        <div class="analytics-tabs">
            <button class="tab-btn active" data-tab="tab-revenue">
                <i data-lucide="dollar-sign"></i> Ph&#226;n T&#237;ch Doanh Thu
            </button>
            <button class="tab-btn" data-tab="tab-bookings">
                <i data-lucide="shopping-cart"></i> L&#432;&#7907;ng &#272;&#7863;t Ch&#7895;
            </button>
            <button class="tab-btn" data-tab="tab-performance">
                <i data-lucide="activity"></i> Hi&#7879;u Su&#7845;t Tour
            </button>
            <button class="tab-btn" data-tab="tab-guides">
                <i data-lucide="users"></i> Ho&#7841;t &#272;&#7897;ng H&#432;&#7899;ng D&#7851;n Vi&#234;n
            </button>
            <button class="tab-btn" data-tab="tab-reports">
                <i data-lucide="archive"></i> L&#7883;ch S&#7917; B&#225;o C&#225;o L&#432;u Tr&#7919;
            </button>
        </div>

        <!-- &#9472;&#9472; Tab 1: Doanh Thu &#9472;&#9472; -->
        <div class="tab-pane active" id="tab-revenue">
            <div class="kpi-grid">
                <div class="kpi-card">
                    <div class="kpi-icon"><i data-lucide="trending-up"></i></div>
                    <div class="kpi-label">T&#7893;ng doanh thu g&#7847;n &#273;&#226;y</div>
                    <div class="kpi-value" id="kpi-total-revenue">0 &#273;</div>
                    <div class="kpi-trend" id="kpi-revenue-trend"><i data-lucide="arrow-up-right"></i> <span id="kpi-revenue-trend-text">--</span></div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-icon"><i data-lucide="pie-chart"></i></div>
                    <div class="kpi-label">Doanh thu trung b&#236;nh th&#225;ng</div>
                    <div class="kpi-value" id="kpi-avg-revenue">0 &#273;</div>
                    <div class="kpi-trend" id="kpi-avg-trend"><span id="kpi-avg-trend-text">--</span></div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-icon"><i data-lucide="star"></i></div>
                    <div class="kpi-label">Danh m&#7909;c d&#7851;n &#273;&#7847;u</div>
                    <div class="kpi-value" id="kpi-top-category" style="font-size: 1.4rem;">N/A</div>
                    <div class="kpi-trend" id="kpi-category-trend"><span id="kpi-category-trend-text">--</span></div>
                </div>
            </div>

            <div class="charts-grid">
                <div class="chart-card">
                    <div class="chart-header">
                        <h3 class="chart-title">Bi&#7875;u &#273;&#7891; doanh thu h&#224;ng th&#225;ng</h3>
                    </div>
                    <div class="chart-container">
                        <canvas id="chart-monthly-revenue"></canvas>
                    </div>
                </div>
                <div class="chart-card">
                    <div class="chart-header">
                        <h3 class="chart-title">C&#417; c&#7845;u doanh thu theo Danh m&#7909;c Tour</h3>
                    </div>
                    <div class="chart-container">
                        <canvas id="chart-category-revenue"></canvas>
                    </div>
                </div>
            </div>

            <div class="chart-card" style="margin-bottom: 24px;">
                <div class="chart-header">
                    <h3 class="chart-title">Top 10 Tour mang l&#7841;i doanh thu cao nh&#7845;t</h3>
                </div>
                <div class="chart-container" style="height: 350px;">
                    <canvas id="chart-tour-revenue"></canvas>
                </div>
            </div>
        </div>

        <!-- &#9472;&#9472; Tab 2: L&#432;&#7907;ng &#272;&#7863;t Ch&#7895; &#9472;&#9472; -->
        <div class="tab-pane" id="tab-bookings">
            <div class="kpi-grid">
                <div class="kpi-card">
                    <div class="kpi-icon"><i data-lucide="users"></i></div>
                    <div class="kpi-label">T&#7893;ng s&#7889; &#273;&#7863;t ch&#7895; (30 ng&#224;y qua)</div>
                    <div class="kpi-value" id="kpi-total-bookings">0</div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-icon"><i data-lucide="check-circle-2"></i></div>
                    <div class="kpi-label">&#272;&#7863;t ch&#7895; ho&#224;n t&#7845;t</div>
                    <div class="kpi-value" id="kpi-completed-bookings">0</div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-icon"><i data-lucide="help-circle"></i></div>
                    <div class="kpi-label">&#272;ang ch&#7901; thanh to&#225;n/ph&#234; duy&#7879;t</div>
                    <div class="kpi-value" id="kpi-pending-bookings">0</div>
                </div>
            </div>

            <div class="charts-grid">
                <div class="chart-card">
                    <div class="chart-header">
                        <h3 class="chart-title">Xu h&#432;&#7899;ng &#273;&#7863;t ch&#7895; h&#224;ng ng&#224;y (30 ng&#224;y g&#7847;n &#273;&#226;y)</h3>
                    </div>
                    <div class="chart-container">
                        <canvas id="chart-booking-trends"></canvas>
                    </div>
                </div>
                <div class="chart-card">
                    <div class="chart-header">
                        <h3 class="chart-title">Ph&#226;n ph&#7889;i tr&#7841;ng th&#225;i &#272;&#7863;t ch&#7895;</h3>
                    </div>
                    <div class="chart-container">
                        <canvas id="chart-booking-status"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <!-- &#9472;&#9472; Tab 3: Hi&#7879;u Su&#7845;t Tour &#9472;&#9472; -->
        <div class="tab-pane" id="tab-performance">
            <div class="table-card">
                <div class="table-header">
                    <h3 class="table-title">Hi&#7879;u su&#7845;t v&#224; T&#7881; l&#7879; l&#7845;p &#273;&#7847;y c&#7911;a Tour</h3>
                    <c:choose>
                        <c:when test="${isAccountant}">
                            <button class="btn-action btn-primary" onclick="confirmExport('tour-performance-table', 'tour_performance.csv')">
                                <i data-lucide="download"></i> Xu&#7845;t CSV d&#7919; li&#7879;u b&#7843;ng
                            </button>
                        </c:when>
                        <c:otherwise>
                            <span class="badge-status pending" style="border-radius: 4px; padding: 6px 12px;"><i data-lucide="lock" style="width:14px;height:14px;display:inline-block;vertical-align:middle;"></i> Ch&#7881; d&#224;nh cho K&#7871; to&#225;n vi&#234;n</span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <table class="custom-table" id="tour-performance-table">
                    <thead>
                        <tr>
                            <th>M&#227; Tour</th>
                            <th>T&#234;n Tour</th>
                            <th>L&#432;&#7907;t &#273;&#7863;t ch&#7895;</th>
                            <th>Doanh thu</th>
                            <th>&#272;i&#7875;m &#273;&#225;nh gi&#225;</th>
                            <th>T&#7881; l&#7879; l&#7845;p &#273;&#7847;y TB</th>
                        </tr>
                    </thead>
                    <tbody id="tour-performance-tbody">
                        <!-- Filled dynamically -->
                    </tbody>
                </table>
            </div>
        </div>

        <!-- &#9472;&#9472; Tab 4: H&#432;&#7899;ng D&#7851;n Vi&#234;n &#9472;&#9472; -->
        <div class="tab-pane" id="tab-guides">
            <div class="table-card">
                <div class="table-header">
                    <h3 class="table-title">B&#225;o c&#225;o ho&#7841;t &#273;&#7897;ng c&#7911;a H&#432;&#7899;ng d&#7851;n vi&#234;n</h3>
                    <c:choose>
                        <c:when test="${isAccountant}">
                            <button class="btn-action btn-primary" onclick="confirmExport('guide-activity-table', 'guide_activity.csv')">
                                <i data-lucide="download"></i> Xu&#7845;t CSV d&#7919; li&#7879;u b&#7843;ng
                            </button>
                        </c:when>
                        <c:otherwise>
                            <span class="badge-status pending" style="border-radius: 4px; padding: 6px 12px;"><i data-lucide="lock" style="width:14px;height:14px;display:inline-block;vertical-align:middle;"></i> Ch&#7881; d&#224;nh cho K&#7871; to&#225;n vi&#234;n</span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <table class="custom-table" id="guide-activity-table">
                    <thead>
                        <tr>
                            <th>ID HDV</th>
                            <th>H&#7885; v&#224; T&#234;n</th>
                            <th>Kinh nghi&#7879;m</th>
                            <th>&#272;&#225;nh gi&#225; trung b&#236;nh</th>
                            <th>S&#7889; Tour (&#272;&#227; d&#7851;n / Ph&#226;n c&#244;ng)</th>
                            <th>Chuy&#234;n m&#244;n</th>
                            <th>Tr&#7841;ng th&#225;i</th>
                        </tr>
                    </thead>
                    <tbody id="guide-activity-tbody">
                        <!-- Filled dynamically -->
                    </tbody>
                </table>
            </div>
        </div>

        <!-- &#9472;&#9472; Tab 5: L&#432;u Tr&#7919; B&#225;o C&#225;o Snapshot &#9472;&#9472; -->
        <div class="tab-pane" id="tab-reports">
            <div class="table-card">
                <div class="table-header">
                    <h3 class="table-title">L&#7883;ch s&#7917; Snapshot b&#225;o c&#225;o &#273;&#227; l&#432;u tr&#7919;</h3>
                </div>
                <table class="custom-table" id="reports-snapshot-table">
                    <thead>
                        <tr>
                            <th>ID B&#225;o C&#225;o</th>
                            <th>Lo&#7841;i B&#225;o C&#225;o</th>
                            <th>Kho&#7843;ng Th&#7901;i Gian</th>
                            <th>Ng&#432;&#7901;i T&#7841;o</th>
                            <th>Ng&#224;y T&#7841;o</th>
                            <th>H&#224;nh &#272;&#7897;ng</th>
                        </tr>
                    </thead>
                    <tbody id="reports-snapshot-tbody">
                        <!-- Filled dynamically -->
                    </tbody>
                </table>
            </div>
        </div>
        <!-- &#9472;&#9472; K&#7871; To&#225;n: C&#244;ng C&#7909; Nghi&#7879;p V&#7909; Ri&#234;ng &#9472;&#9472; -->
        <c:if test="${isAccountant}">
            <div class="accountant-dashboard-section" style="margin-top: 40px; padding-top: 20px; border-top: 2px dashed rgba(255,255,255,0.1);">
                <h2 style="font-size: 1.25rem; font-weight: 600; margin-bottom: 20px; color: var(--text-main); display: flex; align-items: center; gap: 8px;">
                    <i data-lucide="briefcase" style="color: var(--primary);"></i> B&#7843;ng &#272;i&#7873;u Khi&#7875;n Nghi&#7879;p V&#7909; K&#7871; To&#225;n
                </h2>

                <style>
                    .acc-quick-actions-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 28px; }
                    .acc-quick-card { background: var(--card-bg); border-radius: 12px; padding: 20px; border: 1px solid var(--card-border); text-decoration: none; display: flex; flex-direction: column; align-items: flex-start; gap: 12px; transition: all .2s; }
                    .acc-quick-card:hover { transform: translateY(-3px); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); border-color: var(--primary); background: rgba(30, 41, 59, 0.8); }
                    .acc-quick-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; }
                    .acc-quick-card h3 { margin: 0; font-size: 15px; font-weight: 600; color: var(--text-main); }
                    .acc-quick-card p  { margin: 0; font-size: 13px; color: var(--text-gray); line-height: 1.5; }
                    .alert-pending { background: rgba(245, 158, 11, 0.1); border: 1px solid rgba(245, 158, 11, 0.3); border-radius: 8px; padding: 16px 20px; margin-bottom: 24px; display: flex; align-items: center; gap: 12px; color: #FCD34D; font-weight: 500; }
                </style>

                <c:if test="${pendingRefunds > 0}">
                    <div class="alert-pending">
                        <i data-lucide="alert-triangle" style="width:20px;height:20px;color:#F59E0B;"></i>
                        C&#243; <strong>${pendingRefunds}</strong> y&#234;u c&#7847;u ho&#224;n ti&#7873;n &#273;ang ch&#7901; b&#7841;n x&#7917; l&#253;.
                        <a href="${pageContext.request.contextPath}/accountant/refunds" style="margin-left:auto;color:#F59E0B;font-weight:600;text-decoration:underline;">
                            X&#7917; l&#253; ngay &#8594;
                        </a>
                    </div>
                </c:if>

                <div class="acc-quick-actions-grid">
                    <a href="${pageContext.request.contextPath}/accountant/payments?tab=in" class="acc-quick-card">
                        <div class="acc-quick-icon" style="background: rgba(16, 185, 129, 0.15); color: #10B981;">
                            <i data-lucide="trending-up"></i>
                        </div>
                        <h3>D&#242;ng Ti&#7873;n V&#224;o</h3>
                        <p>Theo d&#245;i c&#225;c kho&#7843;n ti&#7873;n kh&#225;ch h&#224;ng &#273;&#227; thanh to&#225;n th&#224;nh c&#244;ng (Success).</p>
                    </a>

                    <a href="${pageContext.request.contextPath}/accountant/payments?tab=out" class="acc-quick-card">
                        <div class="acc-quick-icon" style="background: rgba(239, 68, 68, 0.15); color: #EF4444;">
                            <i data-lucide="trending-down"></i>
                        </div>
                        <h3>D&#242;ng Ti&#7873;n Ra</h3>
                        <p>Danh s&#225;ch c&#225;c giao d&#7883;ch ho&#224;n ti&#7873;n &#273;&#227; th&#7921;c hi&#7879;n cho kh&#225;ch h&#224;ng (Refunded).</p>
                    </a>

                    <a href="${pageContext.request.contextPath}/accountant/refunds" class="acc-quick-card">
                        <div class="acc-quick-icon" style="background: rgba(245, 158, 11, 0.15); color: #F59E0B;">
                            <i data-lucide="refresh-cw"></i>
                        </div>
                        <h3>Duy&#7879;t Ho&#224;n Ti&#7873;n</h3>
                        <p>X&#7917; l&#253;, duy&#7879;t ho&#7863;c t&#7915; ch&#7889;i c&#225;c y&#234;u c&#7847;u h&#7911;y tour v&#224; th&#7921;c hi&#7879;n ho&#224;n ti&#7873;n.</p>
                    </a>
                </div>
            </div>
        </c:if>
    </main>
</div>

<!-- &#9472;&#9472; Report JSON Viewer Modal &#9472;&#9472; -->
<div class="modal-overlay" id="report-modal">
    <div class="modal-content" style="position: relative;">
        <button class="modal-close" id="modal-close-btn">&times;</button>
        <h3 class="modal-title">Xem chi ti&#7871;t d&#7919; li&#7879;u snapshot</h3>
        <div id="modal-body-content">
            <!-- Dynamically populated -->
        </div>
    </div>
</div>
<!-- &#9472;&#9472; Confirmation Modal &#9472;&#9472; -->
<div class="modal-overlay" id="confirm-modal">
    <div class="modal-content" style="position: relative; max-width: 450px;">
        <button class="modal-close" id="confirm-close-btn">&times;</button>
        <h3 class="modal-title" id="confirm-title" style="display: flex; align-items: center; gap: 8px; color: var(--warning-yellow); margin-bottom: 10px;">
            <i data-lucide="alert-triangle" style="stroke: var(--warning-yellow);"></i> X&#225;c nh&#7853;n y&#234;u c&#7847;u
        </h3>
        <div id="confirm-body-content" style="margin: 15px 0; font-size: 0.95rem; line-height: 1.5; color: var(--text-main);">
            B&#7841;n c&#243; ch&#7855;c ch&#7855;n mu&#7889;n th&#7921;c hi&#7879;n h&#224;nh &#273;&#7897;ng n&#224;y?
        </div>
        <div style="display: flex; justify-content: flex-end; gap: 10px; padding-top: 15px; border-top: 1px solid var(--card-border);">
            <button type="button" class="btn-action" id="confirm-cancel-btn">H&#7911;y b&#7887;</button>
            <button type="button" class="btn-action btn-primary" id="confirm-ok-btn">X&#225;c nh&#7853;n</button>
        </div>
    </div>
</div>
<!-- Standard Script Files -->
<script src="${pageContext.request.contextPath}/js/admin-analytics.js?v=1.0"></script>
</body>
</html>
