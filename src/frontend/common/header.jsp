<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TourBuddy | &#272;&#7863;t Tour Du L&#7883;ch Cao C&#7845;p Vi&#7879;t Nam</title>
    <meta name="description" content="Kh&#225;m ph&#225; tour du l&#7883;ch cao c&#7845;p, resort sang tr&#7885;ng v&#224; &#432;u &#273;&#227;i h&#7845;p d&#7851;n kh&#7855;p Vi&#7879;t Nam. &#272;&#7863;t h&#224;nh tr&#236;nh &#273;&#225;ng nh&#7899; c&#249;ng TourBuddy ngay h&#244;m nay.">
    <!-- Using Lucide CDN for icons reliability -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <script>
        var APP_CONTEXT = '${pageContext.request.contextPath}';
        window.contextPath = '${pageContext.request.contextPath}';
    </script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css?v=3.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css?v=3.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css?v=3.0">
    <% 
        String extraCss = (String) request.getAttribute("extraCss");
        if (extraCss != null && !extraCss.trim().isEmpty()) {
            String separator = extraCss.contains("?") ? "&" : "?";
    %>
    <link class="page-css" rel="stylesheet" href="${pageContext.request.contextPath}/<%= extraCss %><%= separator %>v=2.1">
    <% 
        } else {
    %>
    <link class="page-css" rel="stylesheet" href="${pageContext.request.contextPath}/css/homepage.css?v=3.0">
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
                <input type="text" placeholder="B&#7841;n mu&#7889;n &#273;i &#273;&#226;u?" id="nav-search-input">
                <button type="button" aria-label="T&#236;m ki&#7871;m"><i data-lucide="search"></i></button>
            </div>

            <ul class="nav-menu" id="nav-menu">
                <li><a href="${pageContext.request.contextPath}/home" class="nav-link active">Trang Ch&#7911;</a></li>
                <li><a href="${pageContext.request.contextPath}/tourdiscovery" class="nav-link">Tours</a></li>
                <li><a href="${pageContext.request.contextPath}/home#destinations" class="nav-link">&#272;i&#7875;m &#272;&#7871;n</a></li>
                <li><a href="${pageContext.request.contextPath}/home#promotions" class="nav-link">Khuy&#7871;n M&#227;i</a></li>
                <li><a href="${pageContext.request.contextPath}/home#testimonials" class="nav-link">&#272;&#225;nh Gi&#225;</a></li>
            </ul>

            <div class="nav-actions">
                <c:choose>
                    <c:when test="${empty sessionUser}">
                        <button class="btn btn-text btn-login-text" id="login-button" onclick="window.location.href='${pageContext.request.contextPath}/login'">&#272;&#259;ng Nh&#7853;p</button>
                        <button class="btn btn-primary" id="register-button" onclick="window.location.href='${pageContext.request.contextPath}/register'">&#272;&#259;ng K&#253;</button>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/customer/chat" class="notification-bell" id="chat-btn" aria-label="Tin nh&#7855;n" style="text-decoration: none; margin-right: 15px;">
                            <i data-lucide="message-square"></i>
                            <span class="badge-count" id="chat-count" style="display: none;">0</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/customer/notifications" class="notification-bell" id="notification-btn" aria-label="Th&#244;ng b&#225;o" style="text-decoration: none;">
                            <i data-lucide="bell"></i>
                            <span class="badge-count" id="notification-count" style="display: none;">0</span>
                        </a>

                        <div class="user-avatar-wrapper">
                            <div class="user-avatar" id="user-avatar-btn">
                                <c:choose>
                                    <c:when test="${not empty sessionUser.profile.avatarUrl}">
                                        <img src="${sessionUser.profile.avatarUrl}" alt="&#7842;nh &#273;&#7841;i di&#7879;n">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80" alt="&#7842;nh &#273;&#7841;i di&#7879;n">
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="avatar-dropdown" id="user-dropdown-menu">
                                <div class="dropdown-user-info">
                                    <div class="name">${not empty sessionUser.fullName ? sessionUser.fullName : 'Ng&#432;&#7901;i d&#249;ng TourBuddy'}</div>
                                    <div class="email">${sessionUser.email}</div>
                                </div>
                                <a href="${pageContext.request.contextPath}/profile" id="dropdown-profile-link"><i data-lucide="user"></i> H&#7891; S&#417; C&#7911;a T&#244;i</a>
                                <a href="${pageContext.request.contextPath}/bookings" id="dropdown-bookings-link"><i data-lucide="compass"></i> &#272;&#417;n &#272;&#7863;t Ch&#7895;</a>
                                <a href="${pageContext.request.contextPath}/customer/buddies" id="dropdown-buddies-link"><i data-lucide="users"></i> M&#7841;ng L&#432;&#7899;i Buddy</a>
                                <a href="${pageContext.request.contextPath}/customer/wishlist" id="dropdown-wishlist-link"><i data-lucide="heart"></i> Y&#234;u Th&#237;ch</a>
                                <c:if test="${sessionUser.role.roleName eq 'Admin'}">
                                    <a href="${pageContext.request.contextPath}/admin/dashboard" id="dropdown-admin-link"><i data-lucide="shield-alert"></i> Qu&#7843;n Tr&#7883; (Admin)</a>
                                </c:if>
                                <c:if test="${sessionUser.role.roleName eq 'Staff'}">
                                    <a href="${pageContext.request.contextPath}/staff/dashboard" id="dropdown-staff-link"><i data-lucide="shield-alert"></i> Qu&#7843;n Tr&#7883; (Staff)</a>
                                </c:if>
                                <c:if test="${sessionUser.role.roleName eq 'Guide'}">
                                    <a href="${pageContext.request.contextPath}/guide/dashboard" id="dropdown-guide-link"><i data-lucide="shield-alert"></i> Qu&#7843;n Tr&#7883; (Guide)</a>
                                </c:if>
                                <c:if test="${sessionUser.role.roleName eq 'Accountant'}">
                                    <a href="${pageContext.request.contextPath}/admin/analytics" id="dropdown-accountant-link"><i data-lucide="shield-alert"></i> Ban K&#7871; To&#225;n (Accountant)</a>
                                </c:if>
                                <a href="${pageContext.request.contextPath}/profile" id="dropdown-settings-link"><i data-lucide="settings"></i> C&#224;i &#272;&#7863;t</a>
                                <a href="${pageContext.request.contextPath}/logout" class="logout-btn" id="dropdown-logout-btn"><i data-lucide="log-out"></i> &#272;&#259;ng Xu&#7845;t</a>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>

                <button class="mobile-nav-toggle" id="mobile-menu-toggle" aria-label="B&#7853;t/T&#7855;t menu">
                    <i data-lucide="menu"></i>
                </button>
            </div>
        </div>
    </header>

    <c:if test="${not empty sessionUser}">
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const ctx = APP_CONTEXT || "${pageContext.request.contextPath}";
            fetch(ctx + '/api/header-counts')
                .then(response => response.json())
                .then(data => {
                    const chatCount = document.getElementById('chat-count');
                    const notifCount = document.getElementById('notification-count');
                    
                    if (chatCount && data.unreadMessages > 0) {
                        chatCount.textContent = data.unreadMessages > 99 ? '99+' : data.unreadMessages;
                        chatCount.style.display = 'block';
                    }
                    
                    if (notifCount && data.unreadNotifications > 0) {
                        notifCount.textContent = data.unreadNotifications > 99 ? '99+' : data.unreadNotifications;
                        notifCount.style.display = 'block';
                    }
                })
                .catch(err => console.error("Error fetching header counts:", err));
        });
    </script>
    </c:if>
