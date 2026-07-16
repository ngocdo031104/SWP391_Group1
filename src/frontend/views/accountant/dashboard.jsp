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
    <title>Accountant Dashboard — TourBuddy</title>
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
        .stat-info .stat-value { margin: 6px 0 0; font-size: 28px; font-weight: 700; color: var(--gray-900); }

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
                    <h2>Xin chào, ${sessionScope.sessionUser.fullName}! 💼</h2>
                    <p>Quản lý dòng tiền và xử lý các yêu cầu hoàn tiền của hệ thống.</p>
                </div>
                <div class="welcome-badge">
                    <i data-lucide="calculator" style="width:16px;height:16px;"></i>
                    Kế Toán — Accountant
                </div>
            </div>

            <%-- Alert nếu có refund chờ xử lý --%>
            <c:if test="${pendingRefunds > 0}">
                <div class="alert-pending">
                    <i data-lucide="alert-triangle" style="width:20px;height:20px;color:#D97706;"></i>
                    Có <strong>${pendingRefunds}</strong> yêu cầu hoàn tiền đang chờ bạn xử lý.
                    <a href="${pageContext.request.contextPath}/accountant/refunds" style="margin-left:auto;color:#D97706;font-weight:600;text-decoration:underline;">
                        Xử lý ngay →
                    </a>
                </div>
            </c:if>

            <%-- Stats --%>
            <div class="stats-grid">
                <a href="${pageContext.request.contextPath}/accountant/payments?tab=in" class="stat-card">
                    <div class="stat-icon success"><i data-lucide="trending-up"></i></div>
                    <div class="stat-info">
                        <h4>Giao Dịch Thu</h4>
                        <div class="stat-value" style="color:var(--success);">Tiền Vào</div>
                    </div>
                </a>
                <a href="${pageContext.request.contextPath}/accountant/payments?tab=out" class="stat-card">
                    <div class="stat-icon danger"><i data-lucide="trending-down"></i></div>
                    <div class="stat-info">
                        <h4>Giao Dịch Chi</h4>
                        <div class="stat-value" style="color:var(--danger);">Tiền Ra</div>
                    </div>
                </a>
                <a href="${pageContext.request.contextPath}/accountant/refunds" class="stat-card">
                    <div class="stat-icon warning"><i data-lucide="refresh-cw"></i></div>
                    <div class="stat-info">
                        <h4>Hoàn Tiền Chờ Duyệt</h4>
                        <div class="stat-value">${pendingRefunds}</div>
                    </div>
                </a>
            </div>

            <%-- Quick actions --%>
            <h2 style="margin:0 0 16px;font-size:18px;font-weight:600;color:var(--gray-900);">Chức năng chính</h2>
            <div class="quick-actions-grid">
                <a href="${pageContext.request.contextPath}/accountant/payments" class="quick-card">
                    <div class="quick-card-icon" style="background:var(--success-light);color:var(--success);">
                        <i data-lucide="credit-card"></i>
                    </div>
                    <h3>Theo Dõi Thanh Toán</h3>
                    <p>Xem toàn bộ giao dịch tiền vào (Success) và tiền ra (Refunded) của hệ thống.</p>
                    <span class="arrow">Xem giao dịch <i data-lucide="arrow-right" style="width:14px;height:14px;"></i></span>
                </a>

                <a href="${pageContext.request.contextPath}/accountant/refunds" class="quick-card">
                    <div class="quick-card-icon" style="background:var(--danger-light);color:var(--danger);">
                        <i data-lucide="rotate-ccw"></i>
                    </div>
                    <h3>Xử Lý Hoàn Tiền</h3>
                    <p>Duyệt hoặc từ chối các yêu cầu hủy tour và thực hiện hoàn tiền cho khách.</p>
                    <span class="arrow">Xử lý ngay <i data-lucide="arrow-right" style="width:14px;height:14px;"></i></span>
                </a>

                <a href="${pageContext.request.contextPath}/admin/analytics" class="quick-card">
                    <div class="quick-card-icon" style="background:var(--warning-light);color:var(--warning);">
                        <i data-lucide="bar-chart-2"></i>
                    </div>
                    <h3>Thống Kê Doanh Thu</h3>
                    <p>Xem báo cáo doanh thu, xu hướng tài chính và các chỉ số kinh doanh.</p>
                    <span class="arrow">Xem báo cáo <i data-lucide="arrow-right" style="width:14px;height:14px;"></i></span>
                </a>
            </div>

        </div>
    </main>
</div>

<script>lucide.createIcons();</script>
</body>
</html>
