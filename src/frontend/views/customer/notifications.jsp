<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%
    request.setAttribute("bodyClass", "notifications-page");
%>
<jsp:include page="/common/header.jsp" />
<style>
    .notifications-page {
        background-color: #f8fafc;
        font-family: 'Inter', sans-serif;
    }
    /* Header Override for solid background */
    #navbar {
        background-color: white !important;
        border-bottom: 1px solid #e2e8f0;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    }
    #navbar .nav-link, #navbar .logo, #navbar .btn-login-text, #navbar .notification-bell, #navbar .mobile-nav-toggle {
        color: #0f172a !important;
    }

    .container {
        max-width: 900px;
        margin: 0 auto;
        padding: 0 20px;
    }

    .hero-section {
        background: linear-gradient(135deg, var(--primary-color, #4f46e5), #a855f7);
        padding: 40px 20px;
        color: white;
        border-radius: 12px;
        margin-bottom: 30px;
        text-align: left;
        box-shadow: 0 10px 15px -3px rgba(79, 70, 229, 0.3);
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .hero-section h1 {
        font-family: 'Outfit', sans-serif;
        font-size: 32px;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .hero-section .badge {
        background-color: #ef4444;
        color: white;
        padding: 4px 10px;
        border-radius: 20px;
        font-size: 14px;
        font-weight: 600;
        vertical-align: middle;
        box-shadow: 0 2px 4px rgba(0,0,0,0.2);
    }

    .btn-read-all {
        background-color: rgba(255, 255, 255, 0.2);
        color: white;
        text-decoration: none;
        padding: 8px 16px;
        border-radius: 6px;
        font-size: 14px;
        font-weight: 500;
        transition: background-color 0.2s;
        border: 1px solid rgba(255, 255, 255, 0.4);
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }
    .btn-read-all:hover {
        background-color: rgba(255, 255, 255, 0.3);
    }

    .filter-bar {
        display: flex;
        gap: 15px;
        margin-bottom: 30px;
        background: white;
        padding: 20px;
        border-radius: 12px;
        align-items: center;
        flex-wrap: wrap;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
        border: 1px solid #e2e8f0;
    }
    .filter-bar input[type="text"], .filter-bar select {
        padding: 10px 15px;
        border: 1px solid #cbd5e1;
        border-radius: 6px;
        flex: 1;
        min-width: 150px;
        font-family: 'Inter', sans-serif;
        font-size: 14px;
        outline: none;
        transition: border-color 0.2s;
    }
    .filter-bar input[type="text"]:focus, .filter-bar select:focus {
        border-color: var(--primary-color, #4f46e5);
    }
    .filter-bar button {
        padding: 10px 20px;
        background-color: var(--primary-color, #4f46e5);
        color: white;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        font-weight: 500;
        font-family: 'Inter', sans-serif;
        transition: background-color 0.2s;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .filter-bar button:hover {
        background-color: #4338ca;
    }

    .notification-list {
        list-style: none;
        padding: 0;
        margin: 0 0 50px 0;
    }
    .notification-item {
        background: white;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        margin-bottom: 15px;
        padding: 20px;
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        box-shadow: 0 2px 4px rgba(0,0,0,0.02);
        transition: transform 0.2s, box-shadow 0.2s;
    }
    .notification-item:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 12px rgba(0,0,0,0.05);
    }
    .notification-item.unread {
        background-color: #f0f5ff;
        border-left: 4px solid var(--primary-color, #4f46e5);
    }
    .notification-content {
        flex: 1;
        margin-right: 20px;
    }
    .notification-title {
        font-family: 'Outfit', sans-serif;
        font-weight: 600;
        font-size: 18px;
        margin: 0 0 8px 0;
        color: #0f172a;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .cat-badge {
        display: inline-block;
        padding: 4px 10px;
        border-radius: 12px;
        font-size: 12px;
        font-weight: 500;
        background: #e2e8f0;
        color: #475569;
    }
    .notification-body {
        color: #475569;
        margin: 0 0 12px 0;
        font-size: 15px;
        line-height: 1.5;
    }
    .notification-meta {
        font-size: 13px;
        color: #94a3b8;
        display: flex;
        align-items: center;
        gap: 15px;
    }
    .meta-item {
        display: flex;
        align-items: center;
        gap: 4px;
    }
    .btn-read {
        background-color: white;
        color: var(--primary-color, #4f46e5);
        text-decoration: none;
        padding: 6px 12px;
        border-radius: 6px;
        font-size: 13px;
        font-weight: 500;
        border: 1px solid var(--primary-color, #4f46e5);
        transition: all 0.2s;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        white-space: nowrap;
    }
    .btn-read:hover {
        background-color: var(--primary-color, #4f46e5);
        color: white;
    }
    .empty-state {
        text-align: center;
        color: #64748b;
        padding: 60px 20px;
        background: white;
        border-radius: 12px;
        border: 1px dashed #cbd5e1;
    }
</style>

<main style="min-height: 80vh; padding-top: 120px;">
    <div class="container">
        
        <div class="hero-section">
            <h1>
                <i data-lucide="bell" style="width: 28px; height: 28px;"></i> Thông Báo Của Tôi
                <c:if test="${unreadCount > 0}">
                    <span class="badge">${unreadCount} mới</span>
                </c:if>
            </h1>
            <c:if test="${unreadCount > 0}">
                <a href="${pageContext.request.contextPath}/customer/notifications/read-all" class="btn-read-all">
                    <i data-lucide="check-circle" style="width: 16px; height: 16px;"></i> Đánh dấu tất cả đã đọc
                </a>
            </c:if>
        </div>
        
        <form class="filter-bar" method="get" action="${pageContext.request.contextPath}/customer/notifications">
            <div style="position: relative; flex: 2; min-width: 200px;">
                <i data-lucide="search" style="position: absolute; left: 12px; top: 10px; width: 18px; height: 18px; color: #94a3b8;"></i>
                <input type="text" name="keyword" placeholder="Tìm kiếm thông báo..." value="${currentKeyword}" style="padding-left: 38px; width: 100%; box-sizing: border-box;">
            </div>
            <select name="category" style="flex: 1;">
                <option value="All" ${currentCategory == 'All' || empty currentCategory ? 'selected' : ''}>Tất cả thể loại</option>
                <option value="System Announcement" ${currentCategory == 'System Announcement' ? 'selected' : ''}>Thông báo hệ thống</option>
                <option value="Booking" ${currentCategory == 'Booking' ? 'selected' : ''}>Đặt chỗ</option>
                <option value="Payment" ${currentCategory == 'Payment' ? 'selected' : ''}>Thanh toán</option>
                <option value="Tour Update" ${currentCategory == 'Tour Update' ? 'selected' : ''}>Cập nhật Tour</option>
                <option value="Promotion" ${currentCategory == 'Promotion' ? 'selected' : ''}>Khuyến mãi</option>
                <option value="Account Activity" ${currentCategory == 'Account Activity' ? 'selected' : ''}>Hoạt động tài khoản</option>
            </select>
            <label style="display: flex; align-items: center; gap: 8px; font-size: 14px; color: #475569; flex: 1; min-width: 120px;">
                <input type="checkbox" name="unreadOnly" ${currentUnreadOnly ? 'checked' : ''} style="width: 18px; height: 18px; accent-color: var(--primary-color, #4f46e5);"> Chỉ chưa đọc
            </label>
            <button type="submit">
                <i data-lucide="filter" style="width: 16px; height: 16px;"></i> Lọc
            </button>
        </form>

        <c:choose>
            <c:when test="${empty notifications}">
                <div class="empty-state">
                    <i data-lucide="bell-off" style="width: 48px; height: 48px; color: #cbd5e1; margin-bottom: 15px;"></i>
                    <p style="font-size: 18px; margin: 0;">Bạn chưa có thông báo nào.</p>
                </div>
            </c:when>
            <c:otherwise>
                <ul class="notification-list">
                    <c:forEach var="notif" items="${notifications}">
                        <li class="notification-item ${notif.isRead ? '' : 'unread'}">
                            <div class="notification-content">
                                <h3 class="notification-title">
                                    ${notif.title}
                                    <c:if test="${notif.category != null}">
                                        <span class="cat-badge">${notif.category}</span>
                                    </c:if>
                                </h3>
                                <div class="notification-body">
                                    ${notif.content}
                                </div>
                                <div class="notification-meta">
                                    <span class="meta-item"><i data-lucide="calendar" style="width: 14px; height: 14px;"></i> <fmt:formatDate value="${notif.createdAt}" pattern="dd/MM/yyyy HH:mm"/></span>
                                    <c:if test="${notif.senderName != null}">
                                        <span class="meta-item"><i data-lucide="user" style="width: 14px; height: 14px;"></i> Từ: ${notif.senderName}</span>
                                    </c:if>
                                </div>
                            </div>
                            <c:if test="${!notif.isRead}">
                                <div>
                                    <a href="${pageContext.request.contextPath}/customer/notifications/read?id=${notif.notificationId}" class="btn-read" title="Đánh dấu đã đọc">
                                        <i data-lucide="check" style="width: 16px; height: 16px;"></i>
                                    </a>
                                </div>
                            </c:if>
                        </li>
                    </c:forEach>
                </ul>
            </c:otherwise>
        </c:choose>
        
        <div style="margin-bottom: 50px; text-align: center;">
            <a href="${pageContext.request.contextPath}/" style="color: #64748b; text-decoration: none; font-weight: 500; font-size: 15px;">&larr; Quay lại trang chủ</a>
        </div>
    </div>
</main>

<script>
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }
</script>
<jsp:include page="/common/footer.jsp" />
