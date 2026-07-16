<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<c:set var="isAccountant" value="${sessionScope.sessionUser.roleId eq 5 || sessionScope.userRole eq 'Accountant'}" />

<aside class="sidebar">
    <div class="sidebar-brand">
        <div class="logo-icon">T</div>
        <span>TourBuddy</span>
    </div>

    <%-- Scrollable menu area: cho phép cuộn khi danh sách dài hơn viewport --%>
    <div class="sidebar-menu-wrapper">
        <ul class="sidebar-menu">

            <%-- ═══ NHÓM 1: TỔNG QUAN ═══ --%>
            <li class="sidebar-group ${isAccountant ? 'sidebar-group--hidden' : ''}">
                <button type="button" class="sidebar-group-toggle" data-group="overview" aria-expanded="true">
                    <i data-lucide="layout-dashboard"></i>
                    <span>Tổng quan</span>
                    <i data-lucide="chevron-down" class="chevron"></i>
                </button>
                <ul class="sidebar-submenu" data-submenu="overview">
                    <li class="${activePage eq 'dashboard' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/admin/dashboard">
                            <i data-lucide="gauge"></i>
                            <span>Dashboard</span>
                        </a>
                    </li>
                </ul>
            </li>

            <%-- ═══ NHÓM 2: QUẢN LÝ (Admin only) ═══ --%>
            <c:if test="${!isAccountant}">
            <li class="sidebar-group">
                <button type="button" class="sidebar-group-toggle" data-group="manage" aria-expanded="true">
                    <i data-lucide="briefcase"></i>
                    <span>Quản lý</span>
                    <i data-lucide="chevron-down" class="chevron"></i>
                </button>
                <ul class="sidebar-submenu" data-submenu="manage">
                    <li class="${activePage eq 'users' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/admin/users">
                            <i data-lucide="users"></i>
                            <span>Người dùng</span>
                        </a>
                    </li>
                    <li class="${activePage eq 'tours' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/admin/tours">
                            <i data-lucide="compass"></i>
                            <span>Tour</span>
                        </a>
                    </li>
                    <li class="${activePage eq 'coupons' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/admin/coupons">
                            <i data-lucide="tag"></i>
                            <span>Coupon</span>
                        </a>
                    </li>
                    <li class="${activePage eq 'schedules' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/admin/schedules">
                            <i data-lucide="calendar"></i>
                            <span>Lịch trình &amp; Giá</span>
                        </a>
                    </li>
                    <li class="${activePage eq 'media' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/admin/media">
                            <i data-lucide="image"></i>
                            <span>Thư viện Media</span>
                        </a>
                    </li>
                </ul>
            </li>
            </c:if>

            <%-- ═══ NHÓM 3: THỐNG KÊ & BÁO CÁO ═══ --%>
            <li class="sidebar-group">
                <button type="button" class="sidebar-group-toggle" data-group="reports" aria-expanded="true">
                    <i data-lucide="bar-chart-3"></i>
                    <span>Thống kê &amp; Báo cáo</span>
                    <i data-lucide="chevron-down" class="chevron"></i>
                </button>
                <ul class="sidebar-submenu" data-submenu="reports">
                    <li class="${activePage eq 'analytics' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/admin/analytics">
                            <i data-lucide="chart-line"></i>
                            <span>Thống kê chi tiết</span>
                        </a>
                    </li>
                    <li class="${activePage eq 'forecast' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/admin/forecast">
                            <i data-lucide="trending-up"></i>
                            <span>Dự báo &amp; Xu hướng</span>
                        </a>
                    </li>
                    <li class="${activePage eq 'financial-audit' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/admin/financial-audit">
                            <i data-lucide="file-check-2"></i>
                            <span>Kiểm toán tài chính</span>
                        </a>
                    </li>
                </ul>
            </li>

            <%-- ═══ NHÓM 4: GIÁM SÁT & KIỂM DUYỆT (Admin only) ═══ --%>
            <c:if test="${!isAccountant}">
            <li class="sidebar-group">
                <button type="button" class="sidebar-group-toggle" data-group="monitor" aria-expanded="false">
                    <i data-lucide="shield"></i>
                    <span>Giám sát</span>
                    <i data-lucide="chevron-down" class="chevron"></i>
                </button>
                <ul class="sidebar-submenu" data-submenu="monitor">
                    <li class="${activePage eq 'fraud-monitor' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/admin/fraud-monitor">
                            <i data-lucide="shield-alert"></i>
                            <span>Giám sát gian lận</span>
                        </a>
                    </li>
                    <li class="${activePage eq 'moderation' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/admin/moderation">
                            <i data-lucide="message-square-warning"></i>
                            <span>Kiểm duyệt nội dung</span>
                        </a>
                    </li>
                </ul>
            </li>
            </c:if>

            <%-- ═══ NHÓM 5: VẬN HÀNH ═══ --%>
            <li class="sidebar-group">
                <button type="button" class="sidebar-group-toggle" data-group="ops" aria-expanded="false">
                    <i data-lucide="activity"></i>
                    <span>Vận hành</span>
                    <i data-lucide="chevron-down" class="chevron"></i>
                </button>
                <ul class="sidebar-submenu" data-submenu="ops">
                    <li class="${activePage eq 'assignments' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/admin/assignments">
                            <i data-lucide="clipboard-list"></i>
                            <span>Nhật ký phân công</span>
                        </a>
                    </li>
                    <li class="${activePage eq 'oplogs' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/admin/operation-logs">
                            <i data-lucide="history"></i>
                            <span>Nhật ký vận hành</span>
                        </a>
                    </li>
                    <li class="${activePage eq 'history' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/admin/users?action=history">
                            <i data-lucide="scroll-text"></i>
                            <span>Lịch sử quản trị</span>
                        </a>
                    </li>
                </ul>
            </li>

            <%-- ═══ NHÓM 6: HỆ THỐNG (Admin only) ═══ --%>
            <c:if test="${!isAccountant}">
            <li class="sidebar-group">
                <button type="button" class="sidebar-group-toggle" data-group="system" aria-expanded="false">
                    <i data-lucide="settings-2"></i>
                    <span>Hệ thống</span>
                    <i data-lucide="chevron-down" class="chevron"></i>
                </button>
                <ul class="sidebar-submenu" data-submenu="system">
                    <li class="${activePage eq 'roles' ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/admin/roles">
                            <i data-lucide="shield-check"></i>
                            <span>Phân quyền</span>
                        </a>
                    </li>
                </ul>
            </li>
            </c:if>

        </ul>
    </div>

    <div class="sidebar-footer">
        <a href="${pageContext.request.contextPath}/home" class="sidebar-footer-link sidebar-footer-home">
            <i data-lucide="home"></i>
            <span>Về Trang Chủ</span>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="sidebar-footer-link sidebar-footer-logout">
            <i data-lucide="log-out"></i>
            <span>Đăng Xuất</span>
        </a>
    </div>
</aside>

<script>
    (function () {
        function initSidebar() {
            const groups = document.querySelectorAll('.sidebar-group');
            const activeItem = document.querySelector('.sidebar-menu li.active');

            groups.forEach(function (group) {
                const toggle = group.querySelector('.sidebar-group-toggle');
                const submenu = group.querySelector('.sidebar-submenu');
                if (!toggle || !submenu) return;

                // Kiểm tra xem group này có chứa active item không
                const hasActive = activeItem && group.contains(activeItem);

                if (hasActive) {
                    toggle.setAttribute('aria-expanded', 'true');
                    submenu.style.maxHeight = submenu.scrollHeight + 'px';
                } else {
                    toggle.setAttribute('aria-expanded', 'false');
                    submenu.style.maxHeight = '0px';
                }

                toggle.addEventListener('click', function () {
                    const expanded = toggle.getAttribute('aria-expanded') === 'true';
                    toggle.setAttribute('aria-expanded', expanded ? 'false' : 'true');
                    if (expanded) {
                        submenu.style.maxHeight = '0px';
                    } else {
                        submenu.style.maxHeight = submenu.scrollHeight + 'px';
                    }
                });
            });

            // Lucide icons inside sidebar need explicit init since they are included via JSP include.
            if (window.lucide && typeof lucide.createIcons === 'function') {
                lucide.createIcons();
            }
        }

        // Bắt sự kiện DOM ready an toàn, chống lỡ nhịp DOMContentLoaded
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initSidebar);
        } else {
            initSidebar();
        }
    })();
</script>