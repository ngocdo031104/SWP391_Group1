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
    <title>T&#7893;ng Quan H&#7879; Th&#7889;ng &#8212; TourBuddy Enterprise</title>
    <!-- Outfit & Inter Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons & FontAwesome CDNs -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.3">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/tb-ui.css?v=1.0">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-space-overrides.css?v=1.1">
</head>
<body class="dashboard-body tb-cosmic">

<div class="dashboard-wrapper">
    <!-- &#9472;&#9472; Left Sidebar &#9472;&#9472; -->
    <c:set var="activePage" value="dashboard" scope="request" />
    <jsp:include page="sidebar.jsp" />

    <!-- &#9472;&#9472; Main Content Area &#9472;&#9472; -->
    <main class="main-content">
        <!-- Top Header -->
        <header class="top-header">
            <h1>T&#7893;ng quan h&#7879; th&#7889;ng</h1>
            <jsp:include page="admin-header-right.jsp" />
        </header>

        <!-- &#9472;&#9472; VIEW 1: OVERVIEW DASHBOARD (T&#7892;NG QUAN) &#9472;&#9472; -->
        <section class="view-panel active" id="view-overview">
            
            <!-- L&#432;&#7899;i 4 Th&#7867; KPI th&#7889;ng k&#234; tr&#234;n c&#249;ng -->
            <div class="stats-grid">
                <!-- 1. &#431;&#7899;c t&#237;nh doanh thu -->
                <div class="stat-card">
                    <div class="stat-header">
                        <span class="stat-title">&#431;&#7899;c t&#237;nh doanh thu</span>
                        <div class="stat-icon blue"><i data-lucide="dollar-sign"></i></div>
                    </div>
                    <span class="stat-value" id="stats-revenue">0 &#8363;</span>
                    <div class="stat-footer" id="stats-revenue-footer">
                        <span class="stat-trend up"><i data-lucide="trending-up"></i> +12%</span>
                        <span>so v&#7899;i th&#225;ng tr&#432;&#7899;c</span>
                    </div>
                </div>
                <!-- 2. T&#7893;ng s&#7889; tour -->
                <div class="stat-card">
                    <div class="stat-header">
                        <span class="stat-title">T&#7893;ng s&#7889; tour</span>
                        <div class="stat-icon green"><i data-lucide="compass"></i></div>
                    </div>
                    <span class="stat-value" id="stats-tours-count">0</span>
                    <div class="stat-footer" id="stats-tours-footer">
                        <span class="stat-trend up"><i data-lucide="trending-up"></i> +2 tour</span>
                        <span>m&#7899;i th&#234;m trong th&#225;ng</span>
                    </div>
                </div>
                <!-- 3. Ch&#7895; tr&#7889;ng c&#242;n l&#7841;i -->
                <div class="stat-card">
                    <div class="stat-header">
                        <span class="stat-title">Ch&#7895; tr&#7889;ng c&#242;n l&#7841;i</span>
                        <div class="stat-icon orange"><i data-lucide="users"></i></div>
                    </div>
                    <span class="stat-value" id="stats-seats-left">0</span>
                    <div class="stat-footer" id="stats-seats-footer">
                        <span class="stat-trend down"><i data-lucide="trending-down"></i> -4%</span>
                        <span>gi&#7843;m ch&#7895; tr&#7889;ng (&#273;ang b&#225;n ch&#7841;y)</span>
                    </div>
                </div>
                <!-- 4. T&#7927; l&#7879; l&#7845;p &#273;&#7847;y -->
                <div class="stat-card">
                    <div class="stat-header">
                        <span class="stat-title">T&#7927; l&#7879; l&#7845;p &#273;&#7847;y</span>
                        <div class="stat-icon purple"><i data-lucide="percent"></i></div>
                    </div>
                    <span class="stat-value" id="stats-fill-rate">0%</span>
                    <div class="stat-footer" id="stats-fill-footer">
                        <span class="stat-trend up"><i data-lucide="trending-up"></i> +8.5%</span>
                        <span>t&#259;ng tr&#432;&#7903;ng &#273;&#7863;t ch&#7895;</span>
                    </div>
                </div>
            </div>

            <!-- B&#7889; c&#7909;c Bi&#7875;u &#273;&#7891; doanh thu v&#224; Kh&#7903;i h&#224;nh g&#7847;n nh&#7845;t -->
            <div class="charts-row-grid" style="margin-top: 1.5rem;">
                <!-- Bi&#7875;u &#273;&#7891; doanh thu t&#7893;ng quan -->
                <div class="content-card">
                    <div class="card-header">
                        <h3 class="card-title">Bi&#7875;u &#272;&#7891; Doanh Thu T&#7893;ng Quan</h3>
                    </div>
                    <div class="card-body">
                        <div class="chart-container" style="height: 280px; position: relative;">
                            <canvas id="overview-revenue-chart"></canvas>
                        </div>
                    </div>
                </div>
                <!-- L&#7883;ch tr&#236;nh kh&#7903;i h&#224;nh g&#7847;n nh&#7845;t -->
                <div class="content-card">
                    <div class="card-header">
                        <h3 class="card-title">L&#7883;ch tr&#236;nh kh&#7903;i h&#224;nh g&#7847;n nh&#7845;t</h3>
                        <a href="${pageContext.request.contextPath}/admin/tours" class="btn btn-secondary btn-sm">Xem l&#7883;ch tr&#236;nh</a>
                    </div>
                    <div class="card-body table-responsive" style="padding: 0;">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>Tour</th>
                                    <th>Kh&#7903;i h&#224;nh</th>
                                    <th>Tr&#7841;ng th&#225;i gh&#7871;</th>
                                </tr>
                            </thead>
                            <tbody id="overview-departures-body">
                                <!-- Loaded dynamically via JS -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- B&#7843;ng d&#432;&#7899;i c&#249;ng: Tour b&#225;n ch&#7841;y / &#272;&#432;&#7907;c &#273;&#225;nh gi&#225; cao nh&#7845;t -->
            <div class="content-card" style="margin-top: 1.5rem;">
                <div class="card-header">
                    <h3 class="card-title">Tour B&#225;n Ch&#7841;y / &#272;&#432;&#7907;c &#272;&#225;nh Gi&#225; Cao Nh&#7845;t</h3>
                    <a href="${pageContext.request.contextPath}/admin/tours" class="btn btn-secondary btn-sm">Qu&#7843;n l&#253; t&#7845;t c&#7843;</a>
                </div>
                <div class="card-body table-responsive" style="padding: 0;">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>Tour</th>
                                <th>Lo&#7841;i Tour</th>
                                <th>&#272;&#7897; Kh&#243;</th>
                                <th>&#272;&#225;nh Gi&#225;</th>
                                <th>Ch&#7895; tr&#7889;ng</th>
                                <th>Gi&#225;</th>
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

<script src="${pageContext.request.contextPath}/js/tb-ui.js?v=1.0"></script>
<script src="${pageContext.request.contextPath}/js/admin-dashboard.js?v=<%= System.currentTimeMillis() %>" charset="UTF-8"></script>
</body>
</html>
