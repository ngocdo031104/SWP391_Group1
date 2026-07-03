<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

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
