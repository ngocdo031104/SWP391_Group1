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
                <span>T&#7893;ng Quan</span>
            </a>
        </li>
        <li class="${activePage eq 'staff-bookings' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/staff/bookings">
                <i data-lucide="clipboard-list"></i>
                <span>Qu&#7843;n L&#253; Booking</span>
            </a>
        </li>
        <li class="${activePage eq 'staff-assignments' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/staff/tour-assignments">
                <i data-lucide="user-check"></i>
                <span>Ph&#226;n C&#244;ng Guide</span>
            </a>
        </li>

        <li class="${activePage eq 'staff-incidents' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/staff/incidents">
                <i data-lucide="alert-triangle"></i>
                <span>Qu&#7843;n L&#253; S&#7921; C&#7889;</span>
            </a>
        </li>
        <li class="${activePage eq 'staff-logs' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/staff/operation-logs">
                <i data-lucide="file-text"></i>
                <span>Nh&#7853;t K&#253; V&#7853;n H&#224;nh</span>
            </a>
        </li>
        <li class="${activePage eq 'staff-tour-status' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/staff/tour-status">
                <i data-lucide="activity"></i>
                <span>C&#7853;p Nh&#7853;t Tr&#7841;ng Th&#225;i</span>
            </a>
        </li>
    </ul>

    <div class="sidebar-footer">
        <a href="${pageContext.request.contextPath}/home" style="color: var(--text-gray);">
            <i data-lucide="home"></i>
            <span>V&#7873; Trang Ch&#7911;</span>
        </a>
        <a href="${pageContext.request.contextPath}/logout" style="color: var(--error-red); margin-top: 5px;">
            <i data-lucide="log-out"></i>
            <span>&#272;&#259;ng Xu&#7845;t</span>
        </a>
    </div>
</aside>
