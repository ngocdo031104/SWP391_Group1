<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<c:set var="isAccountant" value="${sessionScope.sessionUser.roleId eq 5 || sessionScope.userRole eq 'Accountant'}" />

<aside class="sidebar">
    <div class="sidebar-brand">
        <div class="logo-icon">T</div>
        <span>TourBuddy</span>
    </div>
    
    <ul class="sidebar-menu">
        <c:if test="${!isAccountant}">
            <li class="${activePage eq 'dashboard' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/dashboard">
                    <i data-lucide="layout-dashboard"></i>
                    <span>Tổng Quan</span>
                </a>
            </li>
            <li class="${activePage eq 'users' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/users">
                    <i data-lucide="users"></i>
                    <span>Quản Lý Người Dùng</span>
                </a>
            </li>
            <li class="${activePage eq 'history' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/users?action=history">
                    <i data-lucide="history"></i>
                    <span>Lịch Sử Quản Trị</span>
                </a>
            </li>
            <li class="${activePage eq 'tours' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/tours">
                    <i data-lucide="compass"></i>
                    <span>Quản Lý Tour</span>
                </a>
            </li>
            <li class="${activePage eq 'coupons' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/coupons">
                    <i data-lucide="tag"></i>
                    <span>Quản Lý Coupon</span>
                </a>
            </li>
            <li class="${activePage eq 'schedules' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/schedules">
                    <i data-lucide="calendar"></i>
                    <span>Lịch Trình & Giá</span>
                </a>
            </li>
            <li class="${activePage eq 'media' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/media">
                    <i data-lucide="image"></i>
                    <span>Thư Viện Media</span>
                </a>
            </li>
        </c:if>
        
        <li class="${activePage eq 'analytics' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/analytics">
                <i data-lucide="bar-chart-3"></i>
                <span>Thống Kê Chi Tiết</span>
            </a>
        </li>
        <li class="${activePage eq 'revenue' ? 'active' : ''}">
            <a href="#">
                <i data-lucide="file-text"></i>
                <span>Báo Cáo Doanh Thu</span>
            </a>
        </li>
        <li class="${activePage eq 'forecast' ? 'active' : ''}">
            <a href="#">
                <i data-lucide="trending-up"></i>
                <span>Dự Báo & Xu Hướng</span>
            </a>
        </li>
        <c:if test="${isAccountant}">
            <li class="${activePage eq 'refunds' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/accountant/refunds">
                    <i data-lucide="refresh-cw"></i>
                    <span>Xử Lý Hoàn Tiền</span>
                    <c:if test="${pendingRefunds != null && pendingRefunds > 0}">
                        <span style="background: #EF4444; color: #fff; padding: 2px 8px; border-radius: 12px; font-size: 12px; font-weight: 600; margin-left: auto;">${pendingRefunds}</span>
                    </c:if>
                </a>
            </li>
        </c:if>
        
        <c:if test="${!isAccountant}">
            <li class="${activePage eq 'roles' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/roles">
                    <i data-lucide="shield-check"></i>
                    <span>Phân Quyền</span>
                </a>
            </li>
        </c:if>
        
        <li class="${activePage eq 'settings' ? 'active' : ''}">
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
