<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TourBuddy | Đặt Tour Du Lịch Cao Cấp Việt Nam</title>
    <meta name="description" content="Khám phá tour du lịch cao cấp, resort sang trọng và ưu đãi hấp dẫn khắp Việt Nam. Đặt hành trình đáng nhớ cùng TourBuddy ngay hôm nay.">
    <!-- Using Lucide CDN for icons reliability -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
    <% 
        String extraCss = (String) request.getAttribute("extraCss");
        if (extraCss != null && !extraCss.trim().isEmpty()) {
    %>
    <link class="page-css" rel="stylesheet" href="${pageContext.request.contextPath}/<%= extraCss %>?v=1.9">
    <% 
        } else {
    %>
    <link class="page-css" rel="stylesheet" href="${pageContext.request.contextPath}/css/homepage.css?v=1.9">
    <% 
        }
        String bodyClass = (String) request.getAttribute("bodyClass");
        if (bodyClass == null) {
            bodyClass = "";
        }
    %>
</head>
<body class="<%= bodyClass %>">

    <header class="header" id="navbar">
        <div class="container navbar">
            <a href="${pageContext.request.contextPath}/home" class="logo" id="nav-logo">
                <div class="logo-icon">T</div>
                <span>TourBuddy</span>
            </a>

            <div class="nav-search" id="nav-search-bar">
                <input type="text" placeholder="Bạn muốn đi đâu?" id="nav-search-input">
                <button type="button" aria-label="Tìm kiếm"><i data-lucide="search"></i></button>
            </div>

            <ul class="nav-menu" id="nav-menu">
                <li><a href="${pageContext.request.contextPath}/home" class="nav-link active">Trang Chủ</a></li>
                <li><a href="${pageContext.request.contextPath}/tourdiscovery" class="nav-link">Tours</a></li>
                <li><a href="#destinations" class="nav-link">Điểm Đến</a></li>
                <li><a href="#promotions" class="nav-link">Khuyến Mãi</a></li>
                <li><a href="#testimonials" class="nav-link">Đánh Giá</a></li>
            </ul>

            <div class="nav-actions">
                <c:choose>
                    <c:when test="${empty sessionUser}">
                        <button class="btn btn-text btn-login-text" id="login-button" onclick="window.location.href='${pageContext.request.contextPath}/login'">Đăng Nhập</button>
                        <button class="btn btn-primary" id="register-button" onclick="window.location.href='${pageContext.request.contextPath}/register'">Đăng Ký</button>
                    </c:when>
                    <c:otherwise>
                        <div class="notification-bell" id="notification-btn" aria-label="Thông báo">
                            <i data-lucide="bell"></i>
                            <span class="badge-count" id="notification-count">3</span>
                        </div>

                        <div class="user-avatar-wrapper">
                            <div class="user-avatar" id="user-avatar-btn">
                                <c:choose>
                                    <c:when test="${not empty sessionUser.profile.avatarUrl}">
                                        <img src="${sessionUser.profile.avatarUrl}" alt="Ảnh đại diện">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80" alt="Ảnh đại diện">
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="avatar-dropdown" id="user-dropdown-menu">
                                <div class="dropdown-user-info">
                                    <div class="name">${not empty sessionUser.fullName ? sessionUser.fullName : 'Người dùng TourBuddy'}</div>
                                    <div class="email">${sessionUser.email}</div>
                                </div>
                                <a href="${pageContext.request.contextPath}/profile" id="dropdown-profile-link"><i data-lucide="user"></i> Hồ Sơ Của Tôi</a>
                                <a href="${pageContext.request.contextPath}/bookings" id="dropdown-bookings-link"><i data-lucide="compass"></i> Đơn Đặt Chỗ</a>
                                <a href="#" id="dropdown-wishlist-link"><i data-lucide="heart"></i> Yêu Thích</a>
                                <c:if test="${sessionUser.role.roleName eq 'Admin'}">
                                    <a href="${pageContext.request.contextPath}/admin/dashboard" id="dropdown-admin-link"><i data-lucide="shield-alert"></i> Quản Trị (Admin)</a>
                                </c:if>
                                <a href="#" id="dropdown-settings-link"><i data-lucide="settings"></i> Cài Đặt</a>
                                <a href="${pageContext.request.contextPath}/logout" class="logout-btn" id="dropdown-logout-btn"><i data-lucide="log-out"></i> Đăng Xuất</a>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>

                <button class="mobile-nav-toggle" id="mobile-menu-toggle" aria-label="Bật/Tắt menu">
                    <i data-lucide="menu"></i>
                </button>
            </div>
        </div>
    </header>
