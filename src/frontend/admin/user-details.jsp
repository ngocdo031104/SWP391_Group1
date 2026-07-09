<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:if test="${empty sessionScope.sessionUser || (sessionScope.sessionUser.roleId ne 1 && sessionScope.sessionUser.role.roleName ne 'Admin')}">
    <c:redirect url="/login" />
</c:if>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi Tiết Người Dùng — TourBuddy Enterprise</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=1.6">
    <style>
        .detail-grid { display: grid; grid-template-columns: 1fr 2fr; gap: 20px; }
        .detail-card { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        .detail-item { margin-bottom: 15px; }
        .detail-label { font-size: 12px; color: #666; font-weight: 500; text-transform: uppercase; letter-spacing: 0.5px; }
        .detail-value { font-size: 15px; color: #333; margin-top: 5px; }
        .avatar-lg { width: 100px; height: 100px; border-radius: 50%; object-fit: cover; margin-bottom: 15px; }
    </style>
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <c:set var="activePage" value="users" scope="request" />
    <jsp:include page="sidebar.jsp" />

    <main class="main-content">
        <header class="top-header">
            <h1>Chi Tiết Người Dùng</h1>
            <div class="header-right">
                <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-secondary btn-sm" style="background:#f1f3f4; color:#333; padding: 8px 16px; border-radius:4px; text-decoration:none;">
                    <i data-lucide="arrow-left" style="width:16px; height:16px; vertical-align:middle;"></i> Quay lại
                </a>
            </div>
        </header>

        <section class="view-panel active">
            <div class="detail-grid">
                <!-- Left Column: Avatar & Basic Info -->
                <div class="detail-card">
                    <div style="text-align: center;">
                        <c:choose>
                            <c:when test="${not empty user.profile && not empty user.profile.avatarUrl}">
                                <img src="${user.profile.avatarUrl}" alt="Avatar" class="avatar-lg">
                            </c:when>
                            <c:otherwise>
                                <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=80" alt="Avatar" class="avatar-lg">
                            </c:otherwise>
                        </c:choose>
                        <h3>${user.fullName}</h3>
                        <p style="color:#666;">${user.role.roleName}</p>
                        
                        <div style="margin-top: 20px;">
                            <span class="badge ${user.isActive ? 'badge-active' : 'badge-locked'}">
                                ${user.isActive ? 'Tài khoản Đang Hoạt Động' : 'Tài khoản Bị Khóa'}
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Right Column: Detailed Information -->
                <div class="detail-card">
                    <h3 style="margin-bottom: 20px; border-bottom: 1px solid #eee; padding-bottom: 10px;">Thông Tin Chi Tiết</h3>
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                        <div class="detail-item">
                            <div class="detail-label">Email</div>
                            <div class="detail-value">${user.email}</div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">Số Điện Thoại</div>
                            <div class="detail-value">${user.phoneNumber}</div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">Đã Xác Thực Email</div>
                            <div class="detail-value">${user.isVerified ? 'Rồi' : 'Chưa'}</div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">Ngày Đăng Ký</div>
                            <div class="detail-value"><fmt:formatDate value="${user.createdAt}" pattern="dd/MM/yyyy HH:mm"/></div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">Lần Đăng Nhập Cuối</div>
                            <div class="detail-value">
                                <c:choose>
                                    <c:when test="${not empty user.lastLoginAt}">
                                        <fmt:formatDate value="${user.lastLoginAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </c:when>
                                    <c:otherwise>Chưa từng đăng nhập</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <c:if test="${not empty user.profile}">
                        <h3 style="margin-top: 30px; margin-bottom: 20px; border-bottom: 1px solid #eee; padding-bottom: 10px;">Hồ Sơ Cá Nhân</h3>
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                            <div class="detail-item">
                                <div class="detail-label">Ngày Sinh</div>
                                <div class="detail-value">${user.profile.dateOfBirth}</div>
                            </div>
                            <div class="detail-item">
                                <div class="detail-label">Giới Tính</div>
                                <div class="detail-value">${user.profile.gender}</div>
                            </div>
                            <div class="detail-item" style="grid-column: span 2;">
                                <div class="detail-label">Địa Chỉ</div>
                                <div class="detail-value">${user.profile.address}</div>
                            </div>
                        </div>
                    </c:if>
                </div>
            </div>
        </section>
    </main>
</div>

<script>
    lucide.createIcons();
</script>
</body>
</html>
