<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<c:if test="${empty sessionScope.sessionUser
    || (sessionScope.sessionUser.role.roleName ne 'Staff'
    && sessionScope.sessionUser.role.roleName ne 'Admin')}">
    <c:redirect url="/login"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Dashboard &#8212; TourBuddy</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=1.6">
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
            background: linear-gradient(135deg, #2563EB 0%, #1D4ED8 50%, #1e40af 100%);
            border-radius: 20px; padding: 36px 40px; margin-bottom: 28px;
            display: flex; align-items: center; justify-content: space-between;
            color: white; position: relative; overflow: hidden;
        }
        .welcome-banner::before {
            content: ''; position: absolute; top: -40px; right: -40px;
            width: 200px; height: 200px; border-radius: 50%;
            background: rgba(255,255,255,.08);
        }
        .welcome-banner::after {
            content: ''; position: absolute; bottom: -60px; right: 80px;
            width: 150px; height: 150px; border-radius: 50%;
            background: rgba(255,255,255,.05);
        }
        .welcome-text h2 { margin: 0 0 6px; font-size: 26px; font-weight: 700; font-family: 'Outfit', sans-serif; }
        .welcome-text p  { margin: 0; opacity: .85; font-size: 15px; }
        .welcome-badge { background: rgba(255,255,255,.2); border: 1px solid rgba(255,255,255,.3);
            padding: 10px 20px; border-radius: 99px; font-weight: 600; font-size: 14px;
            display: flex; align-items: center; gap: 8px; }

        .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 28px; }
        .stat-card { background: #fff; border-radius: 16px; padding: 24px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            display: flex; align-items: center; gap: 16px; border: 1px solid var(--gray-100);
            transition: all .2s; cursor: pointer; text-decoration: none; }
        .stat-card:hover { transform: translateY(-3px); box-shadow: 0 12px 20px -3px rgba(0,0,0,0.1); }
        .stat-icon { width: 52px; height: 52px; border-radius: 14px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .stat-icon.primary { background: var(--primary-light); color: var(--primary); }
        .stat-icon.success { background: var(--success-light); color: var(--success); }
        .stat-icon.warning { background: var(--warning-light); color: var(--warning); }
        .stat-icon.danger  { background: var(--danger-light);  color: var(--danger); }
        .stat-info h4 { margin: 0; font-size: 13px; color: var(--gray-500); font-weight: 500; }
        .stat-info .stat-value { margin: 6px 0 0; font-size: 28px; font-weight: 700; color: #ffffff; }

        .quick-actions-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; margin-bottom: 28px; }
        .quick-card { background: #fff; border-radius: 16px; padding: 24px; border: 1px solid var(--gray-100);
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); text-decoration: none; color: var(--gray-900);
            display: flex; flex-direction: column; align-items: flex-start; gap: 12px;
            transition: all .2s; }
        .quick-card:hover { transform: translateY(-3px); box-shadow: 0 12px 20px -3px rgba(0,0,0,0.1); border-color: var(--primary); }
        .quick-card-icon { width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; }
        .quick-card h3 { margin: 0; font-size: 15px; font-weight: 600; }
        .quick-card p  { margin: 0; font-size: 13px; color: var(--gray-500); line-height: 1.5; }
        .quick-card .arrow { margin-top: auto; color: var(--gray-500); transition: all .2s; display: flex; align-items: center; gap: 4px; font-size: 13px; font-weight: 500; }
        .quick-card:hover .arrow { color: var(--primary); transform: translateX(4px); }
    </style>
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <c:set var="activePage" value="staff-dashboard" scope="request"/>
    <%@ include file="/admin/staff-sidebar.jsp" %>

    <main class="main-content">
        <div class="content-area">

            <%-- Welcome banner --%>
            <div class="welcome-banner">
                <div class="welcome-text">
                    <h2>Xin ch&#224;o, ${sessionScope.sessionUser.fullName}! &#128075;</h2>
                    <p>Ch&#224;o m&#7915;ng b&#7841;n quay l&#7841;i. H&#244;m nay c&#243; <strong>${totalPending}</strong> booking &#273;ang ch&#7901; x&#7917; l&#253;.</p>
                </div>
                <div class="welcome-badge">
                    <i data-lucide="shield-check" style="width:16px;height:16px;"></i>
                    Nh&#226;n Vi&#234;n &#8212; Staff
                </div>
            </div>

            <%-- Stats --%>
            <div class="stats-grid">
                <a href="${pageContext.request.contextPath}/staff/bookings?status=All" class="stat-card">
                    <div class="stat-icon primary"><i data-lucide="clipboard-list"></i></div>
                    <div class="stat-info">
                        <h4>T&#7893;ng Booking</h4>
                        <div class="stat-value">${totalAll}</div>
                    </div>
                </a>
                <a href="${pageContext.request.contextPath}/staff/bookings?status=Success" class="stat-card">
                    <div class="stat-icon success"><i data-lucide="check-circle"></i></div>
                    <div class="stat-info">
                        <h4>Th&#224;nh C&#244;ng</h4>
                        <div class="stat-value">${totalSuccess}</div>
                    </div>
                </a>
                <a href="${pageContext.request.contextPath}/staff/bookings?status=PendingPayment" class="stat-card">
                    <div class="stat-icon warning"><i data-lucide="clock"></i></div>
                    <div class="stat-info">
                        <h4>Ch&#7901; Thanh To&#225;n</h4>
                        <div class="stat-value">${totalPending}</div>
                    </div>
                </a>
                <a href="${pageContext.request.contextPath}/staff/bookings?status=Cancelled" class="stat-card">
                    <div class="stat-icon danger"><i data-lucide="x-circle"></i></div>
                    <div class="stat-info">
                        <h4>&#272;&#227; H&#7911;y</h4>
                        <div class="stat-value">${totalCancelled}</div>
                    </div>
                </a>
            </div>

            <%-- Quick actions --%>
            <h2 style="margin:0 0 16px;font-size:18px;font-weight:600;color:var(--gray-900);">Truy c&#7853;p nhanh</h2>
            <div class="quick-actions-grid">
                <a href="${pageContext.request.contextPath}/staff/bookings" class="quick-card">
                    <div class="quick-card-icon" style="background:var(--primary-light);color:var(--primary);">
                        <i data-lucide="list-checks"></i>
                    </div>
                    <h3>Qu&#7843;n L&#253; Booking</h3>
                    <p>Xem to&#224;n b&#7897; danh s&#225;ch &#273;&#7863;t tour, l&#7885;c theo tr&#7841;ng th&#225;i v&#224; th&#234;m ghi ch&#250; v&#7853;n h&#224;nh.</p>
                    <span class="arrow">Xem t&#7845;t c&#7843; <i data-lucide="arrow-right" style="width:14px;height:14px;"></i></span>
                </a>

                <a href="${pageContext.request.contextPath}/admin/analytics" class="quick-card">
                    <div class="quick-card-icon" style="background:var(--warning-light);color:var(--warning);">
                        <i data-lucide="bar-chart-3"></i>
                    </div>
                    <h3>Th&#7889;ng K&#234;</h3>
                    <p>Xem t&#7893;ng quan doanh thu, l&#432;&#7907;t &#273;&#7863;t tour v&#224; hi&#7879;u su&#7845;t v&#7853;n h&#224;nh c&#7911;a h&#7879; th&#7889;ng.</p>
                    <span class="arrow">Xem b&#225;o c&#225;o <i data-lucide="arrow-right" style="width:14px;height:14px;"></i></span>
                </a>
            </div>

        </div>
    </main>
</div>

<script>lucide.createIcons();</script>
</body>
</html>
