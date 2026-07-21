<%-- 
    Màn hình 38: Export Revenue Reports - Xuất báo cáo doanh thu & dữ liệu vận hành
    Tác giả: Dương Quang Sơn
    MSSV: HE186525
    Ngày tạo: 2026-07-21
--%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<c:if test="${empty sessionScope.sessionUser
    || (sessionScope.sessionUser.role.roleName ne 'Accountant'
    && sessionScope.sessionUser.role.roleName ne 'Admin')}">
    <c:redirect url="/login"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Accountant Dashboard &#8212; TourBuddy</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=1.6">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/tb-ui.css?v=1.0">
    <style>
        :root {
            --primary: #2563EB; --primary-light: #EFF6FF;
            --success: #10B981; --success-light: #D1FAE5;
            --warning: #F59E0B; --warning-light: #FEF3C7;
            --danger: #EF4444;  --danger-light: #FEE2E2;
            --gray-50: #F8FAFC; --gray-100: #F1F5F9; --gray-200: #E2E8F0;
            --gray-500: #64748B; --gray-700: #334155; --gray-900: #0F172A;
        }
        body.dashboard-body { background: var(--gray-50); font-family: 'Inter', sans-serif; }

        .welcome-banner {
            background: linear-gradient(135deg, #059669 0%, #047857 50%, #065f46 100%);
            border-radius: 20px; padding: 36px 40px; margin-bottom: 28px;
            display: flex; align-items: center; justify-content: space-between;
            color: white; position: relative; overflow: hidden;
        }
        .welcome-banner::before {
            content: ''; position: absolute; top: -40px; right: -40px;
            width: 200px; height: 200px; border-radius: 50%;
            background: rgba(255,255,255,.08);
        }
        .welcome-text h2 { margin: 0 0 6px; font-size: 26px; font-weight: 700; font-family: 'Outfit', sans-serif; }
        .welcome-text p  { margin: 0; opacity: .85; font-size: 15px; }
        .welcome-badge { background: rgba(255,255,255,.2); border: 1px solid rgba(255,255,255,.3);
            padding: 10px 20px; border-radius: 99px; font-weight: 600; font-size: 14px;
            display: flex; align-items: center; gap: 8px; }

        .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 28px; }
        .stat-card { background: #fff; border-radius: 16px; padding: 24px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            display: flex; align-items: center; gap: 16px; border: 1px solid var(--gray-100);
            transition: all .2s; cursor: pointer; text-decoration: none; }
        .stat-card:hover { transform: translateY(-3px); box-shadow: 0 12px 20px -3px rgba(0,0,0,0.1); }
        .stat-icon { width: 52px; height: 52px; border-radius: 14px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .stat-icon.success { background: var(--success-light); color: var(--success); }
        .stat-icon.warning { background: var(--warning-light); color: var(--warning); }
        .stat-icon.danger  { background: var(--danger-light);  color: var(--danger); }
        .stat-info h4 { margin: 0; font-size: 13px; color: var(--gray-500); font-weight: 500; }
        .stat-info .stat-value { margin: 6px 0 0; font-size: 28px; font-weight: 700; color: #ffffff; }

        .quick-actions-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
        .quick-card { background: #fff; border-radius: 16px; padding: 24px; border: 1px solid var(--gray-100);
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); text-decoration: none; color: var(--gray-900);
            display: flex; flex-direction: column; align-items: flex-start; gap: 12px; transition: all .2s; }
        .quick-card:hover { transform: translateY(-3px); box-shadow: 0 12px 20px -3px rgba(0,0,0,0.1); border-color: #059669; }
        .quick-card-icon { width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; }
        .quick-card h3 { margin: 0; font-size: 15px; font-weight: 600; }
        .quick-card p  { margin: 0; font-size: 13px; color: var(--gray-500); line-height: 1.5; }
        .quick-card .arrow { margin-top: auto; color: var(--gray-500); transition: all .2s; display: flex; align-items: center; gap: 4px; font-size: 13px; font-weight: 500; }
        .quick-card:hover .arrow { color: #059669; transform: translateX(4px); }

        .alert-pending { background: var(--warning-light); border: 1px solid #FCD34D; border-radius: 12px;
            padding: 16px 20px; margin-bottom: 24px; display: flex; align-items: center; gap: 12px;
            color: #92400E; font-weight: 500; }

        /* ============ Premium UI Upgrades (Accountant) ============ */

        /* Page-level fade */
        .content-area > * { animation: tb-fade-up 0.6s cubic-bezier(0.16, 1, 0.3, 1) both; }
        .content-area > *:nth-child(1) { animation-delay: 0.05s; }
        .content-area > *:nth-child(2) { animation-delay: 0.12s; }
        .content-area > *:nth-child(3) { animation-delay: 0.18s; }
        .content-area > *:nth-child(4) { animation-delay: 0.24s; }

        /* Welcome banner upgrade */
        .welcome-banner {
            background: linear-gradient(135deg, #059669 0%, #047857 35%, #065f46 70%, #064e3b 100%) !important;
            background-size: 200% 200%;
            animation: tb-bg-gradient-shift 12s ease infinite;
            box-shadow: 0 12px 28px -8px rgba(5, 150, 105, 0.45);
            transition: transform 0.4s ease, box-shadow 0.4s ease;
        }
        .welcome-banner::before {
            width: 280px !important; height: 280px !important;
            background: radial-gradient(circle, rgba(255,255,255,0.18), transparent 65%) !important;
            animation: tb-float 8s ease-in-out infinite;
        }
        .welcome-banner::after {
            content: '';
            position: absolute;
            bottom: -60px; left: 30%;
            width: 180px; height: 180px;
            background: radial-gradient(circle, rgba(255,255,255,0.12), transparent 70%);
            border-radius: 50%;
            animation: tb-float 6s ease-in-out infinite reverse;
        }
        .welcome-banner:hover {
            transform: translateY(-3px);
            box-shadow: 0 20px 40px -8px rgba(5, 150, 105, 0.55);
        }
        .welcome-text h2 { animation: tb-fade-left 0.6s 0.1s cubic-bezier(0.16, 1, 0.3, 1) both; }
        .welcome-text p  { animation: tb-fade-left 0.6s 0.18s cubic-bezier(0.16, 1, 0.3, 1) both; }
        .welcome-badge  { animation: tb-fade-right 0.6s 0.18s cubic-bezier(0.16, 1, 0.3, 1) both;
            transition: transform 0.3s ease, background-color 0.3s ease; }
        .welcome-badge:hover { transform: scale(1.05); background: rgba(255,255,255,0.28) !important; }

        /* Stats grid premium */
        .stats-grid { animation: tb-fade-up 0.6s 0.2s cubic-bezier(0.16, 1, 0.3, 1) both; }
        .stat-card {
            background: #fff !important;
            border-radius: 16px !important;
            padding: 24px !important;
            border: 1px solid var(--gray-100) !important;
            position: relative;
            overflow: hidden;
        }
        .stat-card::before {
            content: '';
            position: absolute;
            top: -50%; left: -50%;
            width: 60%; height: 200%;
            background: linear-gradient(90deg, transparent, rgba(16, 185, 129, 0.1), transparent);
            transform: rotate(20deg) translateX(-100%);
            transition: transform 0.9s ease;
            pointer-events: none;
        }
        .stat-card:hover {
            transform: translateY(-6px) !important;
            box-shadow: 0 20px 36px -10px rgba(5, 150, 105, 0.3) !important;
            border-color: rgba(5, 150, 105, 0.35) !important;
        }
        .stat-card:hover::before { transform: rotate(20deg) translateX(200%); }

        .stat-icon {
            transition: transform 0.4s cubic-bezier(0.34, 1.56, 0.64, 1), box-shadow 0.3s ease !important;
        }
        .stat-card:hover .stat-icon {
            transform: rotate(-10deg) scale(1.12);
            box-shadow: 0 6px 16px -4px rgba(5, 150, 105, 0.4);
        }

        /* Quick cards upgrade */
        .quick-card {
            transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1) !important;
            position: relative;
            overflow: hidden;
        }
        .quick-card::after {
            content: '';
            position: absolute;
            top: 0; right: 0;
            width: 80px; height: 80px;
            background: radial-gradient(circle, rgba(16, 185, 129, 0.08), transparent 70%);
            border-radius: 50%;
            opacity: 0;
            transition: opacity 0.3s ease;
        }
        .quick-card:hover {
            transform: translateY(-6px) !important;
            box-shadow: 0 20px 36px -10px rgba(5, 150, 105, 0.3) !important;
            border-color: #059669 !important;
        }
        .quick-card:hover::after { opacity: 1; }
        .quick-card-icon { transition: transform 0.4s cubic-bezier(0.34, 1.56, 0.64, 1); }
        .quick-card:hover .quick-card-icon { transform: rotate(-8deg) scale(1.1); }
        .quick-card .arrow { transition: transform 0.3s ease, color 0.2s ease; }
        .quick-card:hover .arrow { transform: translateX(6px) !important; color: #059669 !important; }

        /* Alert upgrade */
        .alert-pending {
            animation: tb-pulse 3s ease infinite, tb-fade-up 0.5s cubic-bezier(0.16, 1, 0.3, 1) both;
            position: relative;
            overflow: hidden;
        }
        .alert-pending::before {
            content: '';
            position: absolute;
            top: 0; left: -100%;
            width: 50%; height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.5), transparent);
            animation: tb-shimmer 2.4s linear infinite;
        }

        /* Stagger quick-cards */
        .quick-actions-grid > * { animation: tb-fade-up 0.5s cubic-bezier(0.16, 1, 0.3, 1) both; }
        .quick-actions-grid > *:nth-child(1) { animation-delay: 0.30s; }
        .quick-actions-grid > *:nth-child(2) { animation-delay: 0.36s; }
        .quick-actions-grid > *:nth-child(3) { animation-delay: 0.42s; }
    </style>
</head>
<body class="dashboard-body">

<div class="dashboard-layout">
    <c:set var="isAccountant" value="true" scope="request"/>
    <%@ include file="/admin/sidebar.jsp" %>

    <main class="main-content">
        <%@ include file="/admin/admin-header-right.jsp" %>

        <div class="content-area">

            <%-- Welcome banner --%>
            <div class="welcome-banner">
                <div class="welcome-text">
                    <h2>Xin ch&#224;o, ${sessionScope.sessionUser.fullName}! &#128188;</h2>
                    <p>Qu&#7843;n l&#253; d&#242;ng ti&#7873;n v&#224; x&#7917; l&#253; c&#225;c y&#234;u c&#7847;u ho&#224;n ti&#7873;n c&#7911;a h&#7879; th&#7889;ng.</p>
                </div>
                <div class="welcome-badge">
                    <i data-lucide="calculator" style="width:16px;height:16px;"></i>
                    K&#7871; To&#225;n &#8212; Accountant
                </div>
            </div>

            <%-- Alert n&#7871;u c&#243; refund ch&#7901; x&#7917; l&#253; --%>
            <c:if test="${pendingRefunds > 0}">
                <div class="alert-pending">
                    <i data-lucide="alert-triangle" style="width:20px;height:20px;color:#D97706;"></i>
                    C&#243; <strong>${pendingRefunds}</strong> y&#234;u c&#7847;u ho&#224;n ti&#7873;n &#273;ang ch&#7901; b&#7841;n x&#7917; l&#253;.
                    <a href="${pageContext.request.contextPath}/accountant/refunds" style="margin-left:auto;color:#D97706;font-weight:600;text-decoration:underline;">
                        X&#7917; l&#253; ngay &#8594;
                    </a>
                </div>
            </c:if>

            <%-- Stats --%>
            <div class="stats-grid">
                <a href="${pageContext.request.contextPath}/accountant/payments?tab=in" class="stat-card">
                    <div class="stat-icon success"><i data-lucide="trending-up"></i></div>
                    <div class="stat-info">
                        <h4>Giao D&#7883;ch Thu</h4>
                        <div class="stat-value" style="color:var(--success);">Ti&#7873;n V&#224;o</div>
                    </div>
                </a>
                <a href="${pageContext.request.contextPath}/accountant/payments?tab=out" class="stat-card">
                    <div class="stat-icon danger"><i data-lucide="trending-down"></i></div>
                    <div class="stat-info">
                        <h4>Giao D&#7883;ch Chi</h4>
                        <div class="stat-value" style="color:var(--danger);">Ti&#7873;n Ra</div>
                    </div>
                </a>
                <a href="${pageContext.request.contextPath}/accountant/refunds" class="stat-card">
                    <div class="stat-icon warning"><i data-lucide="refresh-cw"></i></div>
                    <div class="stat-info">
                        <h4>Ho&#224;n Ti&#7873;n Ch&#7901; Duy&#7879;t</h4>
                        <div class="stat-value">${pendingRefunds}</div>
                    </div>
                </a>
            </div>

            <%-- Quick actions --%>
            <h2 style="margin:0 0 16px;font-size:18px;font-weight:600;color:var(--gray-900);">Ch&#7913;c n&#259;ng ch&#237;nh</h2>
            <div class="quick-actions-grid">
                <a href="${pageContext.request.contextPath}/accountant/payments" class="quick-card">
                    <div class="quick-card-icon" style="background:var(--success-light);color:var(--success);">
                        <i data-lucide="credit-card"></i>
                    </div>
                    <h3>Theo D&#245;i Thanh To&#225;n</h3>
                    <p>Xem to&#224;n b&#7897; giao d&#7883;ch ti&#7873;n v&#224;o (Success) v&#224; ti&#7873;n ra (Refunded) c&#7911;a h&#7879; th&#7889;ng.</p>
                    <span class="arrow">Xem giao d&#7883;ch <i data-lucide="arrow-right" style="width:14px;height:14px;"></i></span>
                </a>

                <a href="${pageContext.request.contextPath}/accountant/refunds" class="quick-card">
                    <div class="quick-card-icon" style="background:var(--danger-light);color:var(--danger);">
                        <i data-lucide="rotate-ccw"></i>
                    </div>
                    <h3>X&#7917; L&#253; Ho&#224;n Ti&#7873;n</h3>
                    <p>Duy&#7879;t ho&#7863;c t&#7915; ch&#7889;i c&#225;c y&#234;u c&#7847;u h&#7911;y tour v&#224; th&#7921;c hi&#7879;n ho&#224;n ti&#7873;n cho kh&#225;ch.</p>
                    <span class="arrow">X&#7917; l&#253; ngay <i data-lucide="arrow-right" style="width:14px;height:14px;"></i></span>
                </a>

                <a href="${pageContext.request.contextPath}/admin/analytics" class="quick-card">
                    <div class="quick-card-icon" style="background:var(--warning-light);color:var(--warning);">
                        <i data-lucide="bar-chart-2"></i>
                    </div>
                    <h3>Th&#7889;ng K&#234; Doanh Thu</h3>
                    <p>Xem b&#225;o c&#225;o doanh thu, xu h&#432;&#7899;ng t&#224;i ch&#237;nh v&#224; c&#225;c ch&#7881; s&#7889; kinh doanh.</p>
                    <span class="arrow">Xem b&#225;o c&#225;o <i data-lucide="arrow-right" style="width:14px;height:14px;"></i></span>
                </a>
            </div>

        </div>
    </main>
</div>

<script src="${pageContext.request.contextPath}/js/tb-ui.js?v=1.0"></script>
<script>lucide.createIcons();</script>
</body>
</html>
