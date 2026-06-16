<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%
    request.setAttribute("bodyClass", "notifications-page");
%>
<jsp:include page="/common/header.jsp" />
<style>
        .header { background-color: rgba(255,255,255,0.95) !important; box-shadow: 0 1px 4px rgba(0,0,0,.06) !important; }
        .header .logo { color: var(--clr-primary) !important; }
        .header .nav-link { color: var(--clr-muted) !important; }
        .header .nav-link:hover { color: var(--clr-accent) !important; }
        .header .notification-bell { color: var(--clr-text) !important; }
        .header .user-avatar { border-color: var(--clr-primary) !important; }
        .header .nav-search { opacity: 1 !important; visibility: visible !important; transform: translateY(0) !important; }
        .header .mobile-nav-toggle { color: var(--clr-text) !important; }
        .notifications-container { max-width: 800px; margin: 120px auto 50px auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        h1 { color: #1E7D4B; border-bottom: 2px solid #eee; padding-bottom: 10px; }
        .notification-list { list-style: none; padding: 0; }
        .notification-item { border-bottom: 1px solid #eee; padding: 15px 0; display: flex; justify-content: space-between; align-items: flex-start; }
        .notification-item.unread { background-color: #f0fdf4; border-left: 4px solid #1E7D4B; padding-left: 11px; }
        .notification-content { flex: 1; margin-right: 20px; }
        .notification-title { font-weight: bold; font-size: 18px; margin: 0 0 5px 0; color: #333; }
        .notification-body { color: #555; margin: 0 0 10px 0; }
        .notification-meta { font-size: 12px; color: #999; }
        .btn-read { background-color: #e2e8f0; color: #475569; text-decoration: none; padding: 5px 10px; border-radius: 4px; font-size: 14px; }
        .btn-read:hover { background-color: #cbd5e1; }
        .badge { background-color: #e11d48; color: white; padding: 2px 8px; border-radius: 12px; font-size: 14px; vertical-align: super; }
        .empty-state { text-align: center; color: #888; padding: 40px 0; }
        .filter-bar { display: flex; gap: 15px; margin-bottom: 20px; background: #f8fafc; padding: 15px; border-radius: 8px; align-items: center; flex-wrap: wrap; }
        .filter-bar input[type="text"], .filter-bar select { padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 4px; flex: 1; min-width: 150px; }
        .filter-bar button { padding: 8px 16px; background-color: #1E7D4B; color: white; border: none; border-radius: 4px; cursor: pointer; }
        .filter-bar button:hover { background-color: #155d38; }
        .header-actions { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #eee; padding-bottom: 10px; margin-bottom: 20px; }
        .header-actions h1 { border-bottom: none; padding-bottom: 0; margin: 0; }
        .cat-badge { display: inline-block; padding: 3px 8px; border-radius: 12px; font-size: 11px; font-weight: bold; margin-left: 10px; vertical-align: middle; background: #e2e8f0; color: #475569; }
    </style>
    <div class="notifications-container">
        <div class="header-actions">
            <h1>Thông Báo Của Tôi 
                <c:if test="${unreadCount > 0}">
                    <span class="badge">${unreadCount} mới</span>
                </c:if>
            </h1>
            <c:if test="${unreadCount > 0}">
                <a href="${pageContext.request.contextPath}/customer/notifications/read-all" class="btn-read" style="background-color: #1E7D4B; color: white;">Đánh dấu tất cả đã đọc</a>
            </c:if>
        </div>
        
        <form class="filter-bar" method="get" action="${pageContext.request.contextPath}/customer/notifications">
            <input type="text" name="keyword" placeholder="Tìm kiếm thông báo..." value="${currentKeyword}">
            <select name="category">
                <option value="All" ${currentCategory == 'All' || empty currentCategory ? 'selected' : ''}>Tất cả thể loại</option>
                <option value="System Announcement" ${currentCategory == 'System Announcement' ? 'selected' : ''}>Thông báo hệ thống</option>
                <option value="Booking" ${currentCategory == 'Booking' ? 'selected' : ''}>Đặt chỗ</option>
                <option value="Payment" ${currentCategory == 'Payment' ? 'selected' : ''}>Thanh toán</option>
                <option value="Tour Update" ${currentCategory == 'Tour Update' ? 'selected' : ''}>Cập nhật Tour</option>
                <option value="Promotion" ${currentCategory == 'Promotion' ? 'selected' : ''}>Khuyến mãi</option>
                <option value="Account Activity" ${currentCategory == 'Account Activity' ? 'selected' : ''}>Hoạt động tài khoản</option>
            </select>
            <label style="display: flex; align-items: center; gap: 5px; font-size: 14px;">
                <input type="checkbox" name="unreadOnly" ${currentUnreadOnly ? 'checked' : ''}> Chỉ chưa đọc
            </label>
            <button type="submit">Lọc</button>
        </form>
        <c:choose>
            <c:when test="${empty notifications}">
                <div class="empty-state">
                    <p>Bạn chưa có thông báo nào.</p>
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
                                    Ngày nhận: <fmt:formatDate value="${notif.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    <c:if test="${notif.senderName != null}">
                                        &bull; Từ: ${notif.senderName}
                                    </c:if>
                                </div>
                            </div>
                            <c:if test="${!notif.isRead}">
                                <div>
                                    <a href="${pageContext.request.contextPath}/customer/notifications/read?id=${notif.notificationId}" class="btn-read">Đánh dấu đã đọc</a>
                                </div>
                            </c:if>
                        </li>
                    </c:forEach>
                </ul>
            </c:otherwise>
        </c:choose>
        
        <div style="margin-top: 30px; text-align: center;">
            <a href="${pageContext.request.contextPath}/" style="color: #666; text-decoration: none;">&larr; Quay lại trang chủ</a>
        </div>
    </div>
<jsp:include page="/common/footer.jsp" />
