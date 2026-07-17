<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<aside class="sidebar">
    <div class="sidebar-brand">
        <div class="logo-icon">T</div>
        <span>TourBuddy</span>
    </div>

    <ul class="sidebar-menu">
        <li class="${activePage eq 'staff-dashboard' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/staff/dashboard">
                <i data-lucide="layout-dashboard"></i>
                <span>Tổng Quan</span>
            </a>
        </li>
        <li class="${activePage eq 'staff-bookings' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/staff/bookings">
                <i data-lucide="clipboard-list"></i>
                <span>Quản Lý Booking</span>
            </a>
        </li>
        <li class="${activePage eq 'staff-assignments' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/staff/tour-assignments">
                <i data-lucide="user-check"></i>
                <span>Phân Công Guide</span>
            </a>
        </li>
        <li class="${activePage eq 'staff-guests' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/staff/guests">
                <i data-lucide="users"></i>
                <span>Danh Sách Khách</span>
            </a>
        </li>
        <li class="${activePage eq 'staff-incidents' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/staff/incidents">
                <i data-lucide="alert-triangle"></i>
                <span>Quản Lý Sự Cố</span>
            </a>
        </li>
        <li class="${activePage eq 'staff-logs' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/staff/operation-logs">
                <i data-lucide="file-text"></i>
                <span>Nhật Ký Vận Hành</span>
            </a>
        </li>
        <li class="${activePage eq 'staff-tour-status' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/staff/tour-status">
                <i data-lucide="activity"></i>
                <span>Cập Nhật Trạng Thái</span>
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
