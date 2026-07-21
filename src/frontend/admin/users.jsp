<%-- 
    Liên quan đến UCs: Admin Management
    Tác giả: Đỗ Vũ Minh Ngọc
    MSSV: HE182479
--%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:if test="${empty sessionScope.sessionUser || (sessionScope.sessionUser.roleId ne 1 && sessionScope.userRole ne 'Admin')}">
    <c:redirect url="/login" />
</c:if>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Qu&#7843;n L&#253; Ng&#432;&#7901;i D&#249;ng &#151; TourBuddy Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=1.3">
    <style>
        :root {
            --primary: #2563EB;
            --primary-light: #EFF6FF;
            --success: #10B981;
            --success-light: #D1FAE5;
            --warning: #F59E0B;
            --warning-light: #FEF3C7;
            --danger: #EF4444;
            --danger-light: #FEE2E2;
            --gray-50: #F8FAFC;
            --gray-100: #F1F5F9;
            --gray-200: #E2E8F0;
            --gray-500: #64748B;
            --gray-700: #334155;
            --gray-900: #0F172A;
        }
        body.dashboard-body { background: var(--gray-50); font-family: 'Inter', sans-serif; }
        
        .header-actions { display: flex; gap: 12px; }
        .btn-modern { padding: 10px 16px; border-radius: 8px; font-weight: 600; display: inline-flex; align-items: center; gap: 8px; border: none; cursor: pointer; transition: all 0.2s; font-size: 14px; }
        .btn-primary { background: var(--primary); color: white; box-shadow: 0 2px 4px rgba(37,99,235,0.2); }
        .btn-primary:hover { background: #1D4ED8; }
        .btn-outline { background: white; color: var(--gray-700); border: 1px solid var(--gray-200); }
        .btn-outline:hover { background: var(--gray-50); border-color: var(--gray-500); }

        /* Sidebar override (users.jsp) — đảm bảo chữ menu luôn đọc được */
        .sidebar-menu a { color: #cbd5e1 !important; opacity: 1 !important; }
        .sidebar-menu a:hover { color: #ffffff !important; background-color: rgba(255,255,255,0.05) !important; }
        .sidebar-menu li.active a { color: #38bdf8 !important; }
        .sidebar-brand { color: #f8fafc !important; }

        /* Stats Cards */
        .stats-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 20px; margin-bottom: 24px; }
        .stat-card { background: #fff; border-radius: 16px; padding: 20px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); display: flex; align-items: center; gap: 16px; border: 1px solid var(--gray-100); transition: transform 0.2s; }
        .stat-card:hover { transform: translateY(-2px); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.08); }
        .stat-icon { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; }
        .stat-icon.primary { background: var(--primary-light); color: var(--primary); }
        .stat-icon.success { background: var(--success-light); color: var(--success); }
        .stat-icon.danger { background: var(--danger-light); color: var(--danger); }
        .stat-icon.warning { background: var(--warning-light); color: var(--warning); }
        .stat-icon.purple { background: #F3E8FF; color: #9333EA; }
        .stat-info h4 { margin: 0; font-size: 13px; color: #64748b; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
        .stat-info .stat-value { margin: 4px 0 0; font-size: 26px; font-weight: 800; color: #0f172a; }
        
        /* Filters */
        .filter-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; gap: 16px; flex-wrap: wrap; }
        .search-box { position: relative; flex: 1; max-width: 400px; }
        .search-box i, .search-box svg { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--gray-500); width: 18px; }
        .search-box input { width: 100%; box-sizing: border-box; height: 42px; padding: 10px 16px 10px 40px; border: 1px solid var(--gray-200); border-radius: 8px; font-family: inherit; outline: none; transition: all 0.2s; }
        .search-box input:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-light); }
        .filter-group { display: flex; gap: 12px; align-items: center; }
        .filter-select { padding: 10px 16px; box-sizing: border-box; height: 42px; border: 1px solid var(--gray-200); border-radius: 8px; font-family: inherit; outline: none; background: #fff; color: var(--gray-700); cursor: pointer; }
        
        /* Table */
        .modern-card { background: #fff; border-radius: 16px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); border: 1px solid var(--gray-100); overflow: hidden; }
        .bulk-actions { padding: 16px 24px; background: var(--primary-light); border-bottom: 1px solid var(--gray-200); display: none; align-items: center; justify-content: space-between; animation: slideDown 0.3s ease; }
        .bulk-actions.active { display: flex; }
        .modern-table { width: 100%; border-collapse: collapse; }
        .modern-table th { background: var(--gray-50); padding: 16px 24px; text-align: left; font-size: 13px; font-weight: 600; color: var(--gray-500); text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1px solid var(--gray-200); }
        .modern-table td { padding: 16px 24px; border-bottom: 1px solid var(--gray-100); color: var(--gray-700); vertical-align: middle; }
        .modern-table tr:last-child td { border-bottom: none; }
        .modern-table tr:hover { background: var(--gray-50); }
        .user-cell { display: flex; align-items: center; gap: 12px; }
        .user-avatar { width: 40px; height: 40px; border-radius: 50%; object-fit: cover; background: var(--primary-light); display: flex; align-items: center; justify-content: center; color: var(--primary); font-weight: 600; }
        .user-info .user-name { font-weight: 600; color: var(--gray-900); }
        .user-info .user-email { font-size: 13px; color: var(--gray-500); margin-top: 2px; }
        
        .custom-checkbox { width: 18px; height: 18px; cursor: pointer; accent-color: var(--primary); border-radius: 4px; }
        
        /* Badges */
        .badge { padding: 4px 10px; border-radius: 999px; font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; }
        .badge.role-Admin { background: #F3E8FF; color: #9333EA; }
        .badge.role-Customer { background: #E0F2FE; color: #0284C7; }
        .badge.role-Guide { background: #FEF3C7; color: #D97706; }
        .badge.role-Staff { background: #FFE4E6; color: #E11D48; }
        .badge.role-Accountant { background: #DCFCE7; color: #15803D; }
        .badge.status-active { background: var(--success-light); color: var(--success); }
        .badge.status-locked { background: var(--danger-light); color: var(--danger); }
        
        /* Row Actions */
        .row-actions { display: flex; gap: 8px; }
        .action-icon { width: 32px; height: 32px; border-radius: 6px; display: flex; align-items: center; justify-content: center; color: var(--gray-500); transition: all 0.2s; cursor: pointer; border: none; background: transparent; }
        .action-icon:hover { background: var(--gray-100); color: var(--primary); }
        .action-icon.danger:hover { background: var(--danger-light); color: var(--danger); }
        
        /* Side Drawer */
        .drawer-overlay { position: fixed; inset: 0; background: rgba(15, 23, 42, 0.4); backdrop-filter: blur(4px); z-index: 1000; opacity: 0; visibility: hidden; transition: all 0.3s; }
        .drawer { position: fixed; top: 0; right: -500px; width: 450px; height: 100vh; background: #fff; z-index: 1001; box-shadow: -4px 0 25px rgba(0,0,0,0.1); transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); display: flex; flex-direction: column; }
        .drawer.open { right: 0; }
        .drawer-overlay.open { opacity: 1; visibility: visible; }
        .drawer-header { padding: 24px; border-bottom: 1px solid var(--gray-200); display: flex; justify-content: space-between; align-items: center; background: var(--gray-50); }
        .drawer-header h3 { margin: 0; font-size: 18px; font-weight: 600; color: var(--gray-900); }
        .drawer-close { cursor: pointer; color: var(--gray-500); padding: 4px; border-radius: 4px; transition: background 0.2s; background: none; border: none; }
        .drawer-close:hover { background: var(--gray-200); color: var(--gray-900); }
        .drawer-body { padding: 24px; overflow-y: auto; flex: 1; }
        .drawer-avatar-lg { width: 100px; height: 100px; border-radius: 50%; margin: 0 auto 16px; display: block; object-fit: cover; border: 4px solid white; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .drawer-name-center { text-align: center; font-size: 20px; font-weight: 700; color: var(--gray-900); margin-bottom: 4px; }
        .drawer-email-center { text-align: center; font-size: 14px; color: var(--gray-500); margin-bottom: 24px; }
        
        .drawer-section { margin-bottom: 24px; background: white; border: 1px solid var(--gray-200); border-radius: 12px; padding: 16px; }
        .drawer-section h4 { font-size: 14px; text-transform: uppercase; color: var(--gray-500); font-weight: 600; margin: 0 0 16px 0; letter-spacing: 0.5px; display: flex; align-items: center; gap: 8px; }
        .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .info-item label { display: block; font-size: 12px; color: var(--gray-500); margin-bottom: 4px; font-weight: 500; }
        .info-item span { font-size: 14px; color: var(--gray-900); font-weight: 500; display: block; }
        
        .stats-boxes { display: grid; grid-template-columns: repeat(2, 1fr); gap: 12px; }
        .stat-box { background: var(--gray-50); padding: 16px; border-radius: 12px; text-align: center; border: 1px solid var(--gray-100); }
        .stat-box .num { font-size: 24px; font-weight: 700; color: var(--primary); margin-bottom: 4px; display: block; }
        .stat-box .label { font-size: 12px; color: var(--gray-500); text-transform: uppercase; font-weight: 600; }

        /* Toast */
        .toast-container { position: fixed; bottom: 24px; right: 24px; z-index: 2000; display: flex; flex-direction: column; gap: 10px; }
        .toast { padding: 14px 20px; border-radius: 8px; color: white; font-weight: 500; display: flex; align-items: center; gap: 12px; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); animation: slideIn 0.3s ease forwards; font-size: 14px; min-width: 300px; }
        .toast.success { background: var(--success); }
        .toast.error { background: var(--danger); }
        
        @keyframes slideIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
        @keyframes slideDown { from { transform: translateY(-10px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
    </style>
</head>
<body class="users-body tb-cosmic">

<div class="dashboard-wrapper">
    <!-- Left Sidebar -->
    <c:set var="activePage" value="users" scope="request" />
    <jsp:include page="sidebar.jsp" />

    <!-- Vùng nội dung chính -->
    <main class="main-content">
        <!-- Tiêu đề trên cùng -->
        <header class="top-header" style="margin-bottom: 24px;">
            <div>
                <h1 style="font-size: 26px; font-weight: 800; color: #c084fc; text-shadow: 0 0 16px rgba(192, 132, 252, 0.4); margin: 0 0 8px 0;">Danh s&#225;ch ng&#432;&#7901;i d&#249;ng</h1>
                <p style="color: #cbd5e1; margin: 0; font-size: 14px;">Qu&#7843;n l&#253; t&#224;i kho&#7843;n ng&#432;&#7901;i d&#249;ng, h&#432;&#7899;ng d&#7851;n vi&#234;n, nh&#226;n vi&#234;n v&#224; qu&#7843;n tr&#7883; vi&#234;n trong h&#7879; th&#7889;ng.</p>
            </div>
            <div class="header-actions">
                <button class="btn-modern btn-outline" onclick="window.location.reload()">
                    <i data-lucide="refresh-cw" style="width: 16px;"></i> L&#224;m m&#7899;i
                </button>
                <button class="btn-modern btn-outline" id="exportUsersBtn">
                    <i data-lucide="download" style="width: 16px;"></i> Xu&#7853;t d&#7919; li&#7879;u
                </button>
                <button class="btn-modern btn-primary" id="addUserBtn">
                    <i data-lucide="plus" style="width: 16px;"></i> Th&#234;m ng&#432;&#7901;i d&#249;ng
                </button>
            </div>
        </header>

        <!-- Lưới thống kê tổng quan -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon primary"><i data-lucide="users"></i></div>
                <div class="stat-info">
                    <h4 style="color: #9fa9cb !important;">T&#7893;ng ng&#432;&#7901;i d&#249;ng</h4>
                    <div class="stat-value" style="color: #ffffff !important; font-weight: 800;">${totalUsers}</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon success"><i data-lucide="user-check"></i></div>
                <div class="stat-info">
                    <h4 style="color: #9fa9cb !important;">&#272;&#259;ng ho&#7841;t &#273;&#7897;ng</h4>
                    <div class="stat-value" style="color: #ffffff !important; font-weight: 800;">${activeUsers}</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon danger"><i data-lucide="lock"></i></div>
                <div class="stat-info">
                    <h4 style="color: #9fa9cb !important;">&#272;&#227; kh&#243;a</h4>
                    <div class="stat-value" style="color: #ffffff !important; font-weight: 800;">${lockedUsers}</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon warning"><i data-lucide="briefcase"></i></div>
                <div class="stat-info">
                    <h4 style="color: #9fa9cb !important;">H&#432;&#7899;ng d&#7851;n vi&#234;n</h4>
                    <div class="stat-value" style="color: #ffffff !important; font-weight: 800;">${guideUsers}</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon purple"><i data-lucide="star"></i></div>
                <div class="stat-info">
                    <h4 style="color: #9fa9cb !important;">Premium Members</h4>
                    <div class="stat-value" style="color: #ffffff !important; font-weight: 800;">${premiumUsers}</div>
                </div>
            </div>
        </div>

        <!-- Bộ lọc và Bảng dữ liệu -->
        <div class="modern-card">
            <!-- Filter Bar -->
            <div style="padding: 20px 24px; border-bottom: 1px solid var(--gray-200);">
                <div class="filter-bar" style="margin: 0;">
                    <div class="search-box">
                        <i data-lucide="search"></i>
                        <input type="text" id="searchInput" placeholder="T&#236;m ki&#7871;m theo t&#234;n, email ho&#7863;c s&#7889; &#273;i&#7879;n tho&#7841;i...">
                    </div>
                    <div class="filter-group">
                        <select class="filter-select" id="roleFilter">
                            <option value="all">T&#7855;t c&#7843; vai tr&#242;</option>
                            <option value="Admin">Admin</option>
                            <option value="Customer">Customer</option>
                            <option value="Guide">Guide</option>
                            <option value="Staff">Staff</option>
                            <option value="Accountant">Accountant</option>
                        </select>
                        <select class="filter-select" id="statusFilter">
                            <option value="all">T&#7855;t c&#7843; tr&#7840;ng th&#193;i</option>
                            <option value="active">Ho&#7841;t &#273;&#7897;ng</option>
                            <option value="locked">&#272;&#227; kh&#243;a</option>
                        </select>
                        <select class="filter-select">
                            <option>Ng&#224;y tham gia (M&#7899;i l&#250;c)</option>
                            <option>Th&#225;ng n&#224;y</option>
                            <option>Tu&#7847;n n&#224;y</option>
                        </select>
                        <button class="btn-modern btn-primary" onclick="applyFilters()" style="padding: 10px 20px; height: 42px;">L&#7885;c</button>
                    </div>
                </div>
            </div>

            <!-- Bulk Actions -->
            <div class="bulk-actions" id="bulkActionsPanel">
                <div style="font-weight: 600; color: var(--primary);">
                    &#272;&#227; ch&#7885;n <span id="selectedCount">0</span> ng&#432;&#7901;i d&#249;ng
                </div>
                <div style="display: flex; gap: 8px;">
                    <button class="btn-modern btn-outline" style="background: white;" onclick="openBulkRoleModal()"><i data-lucide="shield" style="width: 14px;"></i> G&#225;n vai tr&#242;</button>
                    <button class="btn-modern btn-outline" style="background: white; color: var(--danger);" onclick="bulkToggleStatus(false)"><i data-lucide="lock" style="width: 14px;"></i> Kh&#243;a t&#224;i kho&#7843;n</button>
                    <button class="btn-modern btn-outline" style="background: white; color: var(--success);" onclick="bulkToggleStatus(true)"><i data-lucide="unlock" style="width: 14px;"></i> M&#7903; kh&#243;a</button>
                    <button class="btn-modern btn-primary" style="background: var(--danger);" onclick="bulkDeleteUsers()"><i data-lucide="trash-2" style="width: 14px;"></i> X&#243;a</button>
                </div>
            </div>

            <!-- Bảng dữ liệu chính -->
            <div style="overflow-x: auto;">
                <table class="modern-table" id="usersTable">
                    <thead>
                        <tr>
                            <th style="width: 40px;"><input type="checkbox" class="custom-checkbox" id="selectAll"></th>
                            <th>Ng&#432;&#7901;i d&#249;ng</th>
                            <th>Vai tr&#242;</th>
                            <th>Tr&#7840;ng th&#193;i</th>
                            <th>Ng&#224;y tham gia</th>
                            <th style="text-align: right;">H&#192;NH &#272;&#7896;NG</th>
                        </tr>
                    </thead>
                    <tbody id="usersTableBody">
                        <c:forEach var="user" items="${users}">
                            <tr data-role="<c:out value='${user.role.roleName}'/>" data-status="${user.isActive ? 'active' : 'locked'}" data-search="<c:out value='${user.fullName} ${user.email} ${user.phoneNumber}'/>">
                                <td><input type="checkbox" class="custom-checkbox row-checkbox" value="<c:out value='${user.userId}'/>"></td>
                                <td>
                                    <div class="user-cell">
                                        <c:choose>
                                            <c:when test="${not empty user.profile and not empty user.profile.avatarUrl}">
                                                <img src="<c:out value='${user.profile.avatarUrl}'/>" alt="Avatar" class="user-avatar">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="user-avatar"><c:out value="${empty user.fullName ? '?' : user.fullName.substring(0,1)}"/></div>
                                            </c:otherwise>
                                        </c:choose>
                                        <div class="user-info">
                                            <div class="user-name"><c:out value="${user.fullName}"/></div>
                                            <div class="user-email"><c:out value="${user.email}"/></div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <span class="badge role-<c:out value='${user.role.roleName}'/>">
                                        <c:out value="${user.role.roleName}"/>
                                    </span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${user.isActive}">
                                            <span class="badge status-active"><div style="width:6px;height:6px;border-radius:50%;background:currentColor;"></div> Ho&#7841;t &#273;&#7897;ng</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge status-locked"><div style="width:6px;height:6px;border-radius:50%;background:currentColor;"></div> &#272;&#227; kh&#243;a</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <fmt:formatDate var="createdDate" value="${user.createdAt}" pattern="dd/MM/yyyy" />
                                </td>
                                <td>
                                    <div class="row-actions" style="justify-content: flex-end;">
                                        <button class="action-icon" title="Xem chi ti&#7871;t" onclick="openDrawer('<c:out value='${user.userId}'/>')">
                                            <i data-lucide="eye" style="width: 18px;"></i>
                                        </button>
                                        <button class="action-icon" title="S&#7917;a vai tr&#242;" onclick="openSingleRoleModal('<c:out value='${user.userId}'/>')">
                                            <i data-lucide="pencil" style="width: 18px;"></i>
                                        </button>
                                        <c:if test="${user.userId ne sessionScope.sessionUser.userId}">
                                            <form action="?action=toggleStatus" method="POST" style="margin:0;">
                                                <input type="hidden" name="userId" value="<c:out value='${user.userId}'/>">
                                                <input type="hidden" name="status" value="${!user.isActive}">
                                                <button type="button" class="action-icon <c:out value='${user.isActive ? "danger" : ""}'/>" title="<c:out value='${user.isActive ? "Kh&#243;a t&#224;i kho&#7843;n" : "M&#7903; kh&#243;a"}'/>" onclick="confirmToggleStatus(this.form, ${user.isActive})">
                                                    <i data-lucide="<c:out value='${user.isActive ? "lock" : "unlock"}'/>" style="width: 18px;"></i>
                                                </button>
                                            </form>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>

<!-- Side Drawer -->
<div class="drawer-overlay" id="drawerOverlay" onclick="closeDrawer()"></div>
<div class="drawer" id="userDrawer">
    <div class="drawer-header">
        <h3>H&#7891; S&#417; Ng&#432;&#7901;i D&#249;ng</h3>
        <button class="drawer-close" onclick="closeDrawer()"><i data-lucide="x"></i></button>
    </div>
    <div class="drawer-body" id="drawerBody">
        <!-- Content will be loaded via AJAX -->
        <div style="text-align: center; padding: 40px; color: var(--gray-500);">
            <i data-lucide="loader-2" class="lucide-spin" style="width: 32px; height: 32px; animation: spin 1s linear infinite;"></i>
            <p style="margin-top: 10px;">&#272;&#259;ng t&#7843;i th&#244;ng tin...</p>
        </div>
    </div>
</div>

<!-- Bulk Role Modal -->
<div class="drawer-overlay" id="bulkRoleOverlay" style="display: none; align-items: center; justify-content: center; z-index: 2000;">
    <div style="background: white; padding: 24px; border-radius: 12px; width: 400px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);">
        <h3 style="margin: 0 0 16px 0; font-size: 18px; color: var(--gray-900);">G&#225;n vai tr&#242; h&#224;ng lo&#7841;t</h3>
        <form id="bulkRoleForm" action="?action=bulkAssignRole" method="POST">
            <div id="bulkRoleInputs"></div>
            <select name="newRoleId" class="filter-select" style="width: 100%; margin-bottom: 24px;">
                <option value="1">Admin</option>
                <option value="4">Customer</option>
                <option value="2">Guide</option>
                <option value="3">Staff</option>
                <option value="5">Accountant</option>
            </select>
            <div style="display: flex; justify-content: flex-end; gap: 12px;">
                <button type="button" class="btn-modern btn-outline" onclick="closeBulkRoleModal()">H&#7911;y</button>
                <button type="submit" class="btn-modern btn-primary">L&#432;u thay &#273;&#7893;i</button>
            </div>
        </form>
    </div>
</div>

<div class="toast-container" id="toastContainer"></div>

<!-- Alerts from session -->
<c:if test="${not empty sessionScope.successMsg}">
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            showToast('<c:out value="${sessionScope.successMsg}" escapeXml="false"/>', 'success');
        });
    </script>
    <c:remove var="successMsg" scope="session"/>
</c:if>
<c:if test="${not empty sessionScope.errorMsg}">
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            showToast('<c:out value="${sessionScope.errorMsg}" escapeXml="false"/>', 'error');
        });
    </script>
    <c:remove var="errorMsg" scope="session"/>
</c:if>

<script>
    lucide.createIcons();

    // Export users CSV -- NOTE: JSP EL parser s? fail khi th?y chu?i c\u00f3 d?ng "${"..."}" b\u00ean trong script.
    // To\u00e0n b? do?n n\u00e0y ch? d\u00f9ng n?i chu?i b?ng '+', KH\u00d4NG d\u00f9ng template literal.
    function exportUsersCSV() {
        const rows = Array.from(document.querySelectorAll('#usersTableBody tr'))
            .filter(function (row) { return row.style.display !== 'none'; })
            .map(function (row) {
                return {
                    id: row.querySelector('.row-checkbox') ? row.querySelector('.row-checkbox').value : '',
                    name: row.querySelector('.user-name') ? row.querySelector('.user-name').textContent.trim() : '',
                    email: row.querySelector('.user-email') ? row.querySelector('.user-email').textContent.trim() : '',
                    role: row.getAttribute('data-role') || '',
                    status: row.getAttribute('data-status') || ''
                };
            });
        if (rows.length === 0) {
            showToast('Kh\u00f4ng c\u00f3 ngu\u1eddi d\u00f9ng n\u00e0o \u0111\u1ec3 xu\u7853t.', 'error');
            return;
        }
        const header = ['UserID', 'FullName', 'Email', 'Role', 'Status'];
        function escapeCSV(v) {
            return '"' + String(v).replace(/"/g, '""') + '"';
        }
        const lines = [header.join(',')];
        rows.forEach(function (r) {
            lines.push([r.id, r.name, r.email, r.role, r.status].map(escapeCSV).join(','));
        });
        const csv = lines.join('\n');
        const blob = new Blob(['\uFEFF' + csv], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = 'users_' + new Date().toISOString().slice(0, 10) + '.csv';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
        showToast('\u00d0\u00e3 xu\u1ea5t ' + rows.length + ' ngu\u1eddi d\u00f9ng.', 'success');
    }

    function openAddUserModal() {
        showToast('Ch\u1ee9c n\u0103ng t\u1ea1o ng\u01b0\u1eddi d\u0169ng \u0111ang \u0111\u01b0\u1ee3c ph\u00e1t tri\u1ec3n. Vui l\u00f2ng d\u00f9ng form \u0111\u0103ng k\u00fd c\u00f4ng khai.', 'warning');
    }

    document.getElementById('exportUsersBtn')?.addEventListener('click', exportUsersCSV);
    document.getElementById('addUserBtn')?.addEventListener('click', openAddUserModal);

    // Filtering Logic
    function applyFilters() {
        const search = document.getElementById('searchInput').value.toLowerCase();
        const role = document.getElementById('roleFilter').value;
        const status = document.getElementById('statusFilter').value;
        
        const rows = document.querySelectorAll('#usersTableBody tr');
        rows.forEach(row => {
            const rowRole = row.getAttribute('data-role');
            const rowStatus = row.getAttribute('data-status');
            const rowSearch = row.getAttribute('data-search').toLowerCase();
            
            const matchSearch = rowSearch.includes(search);
            const matchRole = (role === 'all' || rowRole === role);
            const matchStatus = (status === 'all' || rowStatus === status);
            
            if (matchSearch && matchRole && matchStatus) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    }

    document.getElementById('searchInput').addEventListener('keyup', applyFilters);
    document.getElementById('roleFilter').addEventListener('change', applyFilters);
    document.getElementById('statusFilter').addEventListener('change', applyFilters);

    // Bulk Actions Logic
    const selectAll = document.getElementById('selectAll');
    const rowCheckboxes = document.querySelectorAll('.row-checkbox');
    const bulkPanel = document.getElementById('bulkActionsPanel');
    const selectedCount = document.getElementById('selectedCount');

    function updateBulkPanel() {
        const count = document.querySelectorAll('.row-checkbox:checked').length;
        selectedCount.textContent = count;
        if (count > 0) {
            bulkPanel.classList.add('active');
        } else {
            bulkPanel.classList.remove('active');
            selectAll.checked = false;
        }
    }

    selectAll.addEventListener('change', (e) => {
        rowCheckboxes.forEach(cb => {
            if(cb.closest('tr').style.display !== 'none') {
                cb.checked = e.target.checked;
            }
        });
        updateBulkPanel();
    });

    rowCheckboxes.forEach(cb => {
        cb.addEventListener('change', updateBulkPanel);
    });

    // Bulk Role Assignment Logic
    function openBulkRoleModal() {
        const checkedBoxes = document.querySelectorAll('.row-checkbox:checked');
        if (checkedBoxes.length === 0) return;
        
        const inputsContainer = document.getElementById('bulkRoleInputs');
        inputsContainer.innerHTML = ''; // Clear old inputs
        checkedBoxes.forEach(cb => {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'userIds';
            input.value = cb.value;
            inputsContainer.appendChild(input);
        });

        const overlay = document.getElementById('bulkRoleOverlay');
        overlay.style.display = 'flex';
        // Add open class for fade in
        setTimeout(() => overlay.classList.add('open'), 10);
    }

    function openSingleRoleModal(userId) {
        const inputsContainer = document.getElementById('bulkRoleInputs');
        inputsContainer.innerHTML = ''; 
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = 'userIds';
        input.value = userId;
        inputsContainer.appendChild(input);

        const overlay = document.getElementById('bulkRoleOverlay');
        overlay.style.display = 'flex';
        setTimeout(() => overlay.classList.add('open'), 10);
    }

    function closeBulkRoleModal() {
        const overlay = document.getElementById('bulkRoleOverlay');
        overlay.classList.remove('open');
        setTimeout(() => overlay.style.display = 'none', 300);
    }

    function bulkToggleStatus(status) {
        const checkedBoxes = document.querySelectorAll('.row-checkbox:checked');
        if (checkedBoxes.length === 0) return;
        
        const actionStr = status ? 'm\u1edf kh\u00f3a' : 'kh\u00f3a';
        if (confirm('B\u1ea1n c\u00f3 ch\u1eafc mu\u1ed1n ' + actionStr + ' ' + checkedBoxes.length + ' t\u00e0i kho\u1ea3n n\u00e0y?')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '?action=bulkToggleStatus&status=' + status;
            
            checkedBoxes.forEach(cb => {
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'userIds';
                input.value = cb.value;
                form.appendChild(input);
            });
            document.body.appendChild(form);
            form.submit();
        }
    }

    function bulkDeleteUsers() {
        const checkedBoxes = document.querySelectorAll('.row-checkbox:checked');
        if (checkedBoxes.length === 0) return;
        
        if (confirm('B\u1ea1n c\u00f3 th\u1ef1c s\u1ef1 mu\u1ed1n x\u00f3a v\u0129nh vi\u1ec5n ' + checkedBoxes.length + ' t\u00e0i kho\u1ea3n n\u00e0y? H\u00e0nh \u0111\u1ed9ng n\u00e0y kh\u00f4ng th\u1ec3 ho\u00e0n t\u00e1c v\u00e0 s\u1ebd x\u00f3a to\u00e0n b\u1ed9 d\u1eef li\u1ec7u h\u1ed3 s\u01a1 li\u00ean quan!')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '?action=bulkDeleteUsers';
            
            checkedBoxes.forEach(cb => {
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'userIds';
                input.value = cb.value;
                form.appendChild(input);
            });
            document.body.appendChild(form);
            form.submit();
        }
    }

    // Drawer Logic
    const drawer = document.getElementById('userDrawer');
    const overlay = document.getElementById('drawerOverlay');
    const drawerBody = document.getElementById('drawerBody');

    function openDrawer(userId) {
        drawer.classList.add('open');
        overlay.classList.add('open');
        
        // Reset content
        drawerBody.innerHTML = `
            <div style="text-align: center; padding: 40px; color: var(--gray-500);">
                <i data-lucide="loader-2" style="width: 32px; height: 32px; animation: spin 1s linear infinite;"></i>
                <p style="margin-top: 10px;">&#272;&#259;ng t&#7843;i th&#244;ng tin...</p>
            </div>
        `;
        lucide.createIcons();

        // Fetch user data via AJAX
        fetch(`?action=api_get&id=\${userId}`)
            .then(res => res.json())
            .then(res => {
                if(res.status === 'success') {
                    renderDrawer(res.data, res.stats);
                } else {
                    drawerBody.innerHTML = `<div style="color: var(--danger); padding: 20px;">L\u1ed7i: \${res.message}</div>`;
                }
            })
            .catch(err => {
                drawerBody.innerHTML = `<div style="color: var(--danger); padding: 20px;">L\u1ed7i k\u1ebft n\u1ed1i m\u00e1y ch\u1ee7!</div>`;
            });
    }

    function closeDrawer() {
        drawer.classList.remove('open');
        overlay.classList.remove('open');
    }

    function renderDrawer(user, stats) {
        const avatarUrl = user.profile?.avatarUrl || 'https://ui-avatars.com/api/?name=' + encodeURIComponent(user.fullName) + '&background=EFF6FF&color=2563EB';
        const dob = user.profile?.dateOfBirth ? new Date(user.profile.dateOfBirth).toLocaleDateString('vi-VN') : 'Ch\u01b0a c\u1eadp nh\u1eadt';
        const address = user.profile?.address || 'Ch\u01b0a c\u1eadp nh\u1eadt';
        const interests = user.profile?.travelInterests || 'Ch\u01b0a c\u1eadp nh\u1eadt';

        drawerBody.innerHTML = `
            <img src="\${avatarUrl}" alt="Avatar" class="drawer-avatar-lg">
            <div class="drawer-name-center">\${user.fullName} <span class="badge role-\${user.role.roleName}" style="vertical-align: middle; margin-left: 8px;">\${user.role.roleName}</span></div>
            <div class="drawer-email-center">\${user.email}</div>

            <div class="drawer-section">
                <h4><i data-lucide="user" style="width:16px;"></i> Th\u00f4ng tin c\u00e1 nh\u00e2n</h4>
                <div class="info-grid">
                    <div class="info-item"><label>S\u1ed1 \u0111i\u1ec7n tho\u1ea1i</label><span>\${user.phoneNumber || 'Ch\u01b0a c\u1eadp nh\u1eadt'}</span></div>
                    <div class="info-item"><label>Ng\u00e0y sinh</label><span>\${dob}</span></div>
                    <div class="info-item"><label>Gi\u1edbi t\u00ednh</label><span>\${user.profile?.gender || 'Ch\u01b0a c\u1eadp nh\u1eadt'}</span></div>
                    <div class="info-item"><label>\u0110\u1ecba ch\u1ec9</label><span>\${address}</span></div>
                </div>
            </div>

            <div class="drawer-section">
                <h4><i data-lucide="map" style="width:16px;"></i> Th\u00f4ng tin du l\u1ecbch</h4>
                <div class="info-grid" style="grid-template-columns: 1fr;">
                    <div class="info-item"><label>S\u1edf th\u00edch & Ho\u1ea1t \u0111\u1ed9ng</label><span>\${interests}</span></div>
                </div>
            </div>

            <div class="drawer-section">
                <h4><i data-lucide="bar-chart-2" style="width:16px;"></i> Th\u1ed1ng k\u00ea ho\u1ea1t \u0111\u1ed9ng</h4>
                <div class="stats-boxes">
                    <div class="stat-box">
                        <span class="num">\${stats.trips}</span>
                        <span class="label">Chuy\u1ebfn \u0111i</span>
                    </div>
                    <div class="stat-box">
                        <span class="num">\${stats.bookings}</span>
                        <span class="label">Booking</span>
                    </div>
                    <div class="stat-box">
                        <span class="num">\${stats.reviews}</span>
                        <span class="label">&#272;&#225;nh gi&#225;</span>
                    </div>
                    <div class="stat-box">
                        <span class="num">\${stats.companions}</span>
                        <span class="label">B\u1ea1n \u0111\u1ed3ng h\u00e0nh</span>
                    </div>
                </div>
            </div>
        `;
        lucide.createIcons();
    }

    // Confirm Action
    function confirmToggleStatus(form, isCurrentlyActive) {
        const actionText = isCurrentlyActive ? 'KH\u00d3A' : 'M\u1EDE KH\u00d3A';
        if (confirm('B\u1ea1n c\u00f3 ch\u1eafc ch\u1eafn mu\u1ed1n ' + actionText + ' t\u00e0i kho\u1ea3n n\u00e0y?')) {
            form.submit();
        }
    }

    // Toast Notification
    function showToast(message, type = 'success') {
        const container = document.getElementById('toastContainer');
        const toast = document.createElement('div');
        toast.className = `toast \${type}`;
        
        let icon = 'check-circle';
        if (type === 'error') icon = 'alert-circle';
        if (type === 'warning') icon = 'alert-triangle';

        toast.innerHTML = `<i data-lucide="\${icon}" style="width: 18px;"></i> \${message}`;
        container.appendChild(toast);
        lucide.createIcons();

        setTimeout(() => {
            toast.style.animation = 'slideDown 0.3s ease forwards reverse';
            setTimeout(() => toast.remove(), 300);
        }, 3000);
    }
</script>
<style>
    @keyframes spin { 100% { transform: rotate(360deg); } }
</style>
</body>
</html>
