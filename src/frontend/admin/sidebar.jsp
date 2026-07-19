<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<c:set var="userRoleId" value="${sessionScope.sessionUser != null ? sessionScope.sessionUser.roleId : 0}" />
<c:set var="isAccountant" value="${userRoleId eq 5 || sessionScope.userRole eq 'Accountant'}" />

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
                    <span>T&#7893;ng Quan</span>
                </a>
            </li>
            <li class="${activePage eq 'users' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/users">
                    <i data-lucide="users"></i>
                    <span>Qu&#7843;n L&#253; Ng&#432;&#7901;i D&#249;ng</span>
                </a>
            </li>
            <li class="${activePage eq 'history' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/users?action=history">
                    <i data-lucide="history"></i>
                    <span>L&#7883;ch S&#7917; Qu&#7843;n Tr&#7883;</span>
                </a>
            </li>
            <li class="${activePage eq 'tours' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/tours">
                    <i data-lucide="compass"></i>
                    <span>Qu&#7843;n L&#253; Tour</span>
                </a>
            </li>
            <li class="${activePage eq 'coupons' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/coupons">
                    <i data-lucide="tag"></i>
                    <span>Qu&#7843;n L&#253; Coupon</span>
                </a>
            </li>
            <li class="${activePage eq 'schedules' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/schedules">
                    <i data-lucide="calendar"></i>
                    <span>L&#7883;ch Tr&#236;nh & Gi&#225;</span>
                </a>
            </li>
            <li class="${activePage eq 'media' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/media">
                    <i data-lucide="image"></i>
                    <span>Th&#432; Vi&#7879;n Media</span>
                </a>
            </li>
        </c:if>
        
        <c:if test="${isAccountant || sessionScope.sessionUser.roleId eq 1}">
            <li class="${activePage eq 'payments' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/accountant/payments">
                    <i data-lucide="wallet"></i>
                    <span>Qu&#7843;n L&#253; D&#242;ng Ti&#7873;n</span>
                </a>
            </li>
            <li class="${activePage eq 'refunds' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/accountant/refunds">
                    <i data-lucide="refresh-ccw"></i>
                    <span>X&#7917; L&#253; Ho&#224;n Ti&#7873;n</span>
                </a>
            </li>
        </c:if>

        <li class="${activePage eq 'analytics' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/analytics">
                <i data-lucide="bar-chart-3"></i>
                <span>Th&#7889;ng K&#234; Chi Ti&#7871;t</span>
            </a>
        </li>

        <li class="${activePage eq 'forecast' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/forecast">
                <i data-lucide="trending-up"></i>
                <span>D&#7921; B&#225;o & Xu H&#432;&#7899;ng</span>
            </a>
        </li>

        <li class="${activePage eq 'fraud-monitor' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/fraud-monitor">
                <i data-lucide="shield-alert"></i>
                <span>Gi&#225;m S&#225;t Gian L&#7853;n</span>
            </a>
        </li>

        <li class="${activePage eq 'financial-audit' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/financial-audit">
                <i data-lucide="file-check-2"></i>
                <span>Ki&#7875;m To&#225;n T&#224;i Ch&#237;nh</span>
            </a>
        </li>

        <li class="${activePage eq 'moderation' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/moderation">
                <i data-lucide="shield-alert"></i>
                <span>Ki&#7875;m Duy&#7879;t N&#7897;i Dung</span>
            </a>
        </li>

        <li class="${activePage eq 'assignments' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/assignments">
                <i data-lucide="clipboard-list"></i>
                <span>Nh&#7853;t K&#253; Ph&#226;n C&#244;ng</span>
            </a>
        </li>

        <li class="${activePage eq 'oplogs' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/operation-logs">
                <i data-lucide="scroll-text"></i>
                <span>Nh&#7853;t K&#253; V&#7853;n H&#224;nh</span>
            </a>
        </li>

        <c:if test="${!isAccountant}">
            <li class="${activePage eq 'roles' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/roles">
                    <i data-lucide="shield-check"></i>
                    <span>Ph&#226;n Quy&#7873;n</span>
                </a>
            </li>
        </c:if>
        
        <li class="${activePage eq 'settings' ? 'active' : ''}">
            <a href="#">
                <i data-lucide="settings"></i>
                <span>C&#7845;u H&#236;nh</span>
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
