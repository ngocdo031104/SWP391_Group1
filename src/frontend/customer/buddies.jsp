<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:if test="${empty sessionUser}">
    <c:redirect url="/login" />
</c:if>

<%
    request.setAttribute("bodyClass", "buddies-page");
%>

<jsp:include page="/common/header.jsp"/>

<style>
    .buddies-page {
        background-color: #f8fafc;
        font-family: 'Inter', sans-serif;
    }
    #navbar {
        background-color: white !important;
        border-bottom: 1px solid #e2e8f0;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    }
    #navbar .nav-link, #navbar .logo, #navbar .btn-login-text, #navbar .notification-bell, #navbar .mobile-nav-toggle {
        color: #0f172a !important;
    }

    .container {
        max-width: 1300px;
        margin: 0 auto;
        padding: 0 20px;
    }

    .layout-grid {
        display: grid;
        grid-template-columns: 1fr 300px;
        gap: 24px;
        align-items: start;
    }

    /* Buddy Tabs */
    .buddy-tabs {
        display: flex;
        gap: 12px;
        margin-bottom: 24px;
        border-bottom: 1px solid #e2e8f0;
        padding-bottom: 0;
    }
    .buddy-tab-btn {
        background: none;
        border: none;
        padding: 12px 20px;
        font-family: 'Outfit', sans-serif;
        font-size: 15px;
        font-weight: 600;
        color: #64748b;
        cursor: pointer;
        position: relative;
        transition: color 0.2s;
    }
    .buddy-tab-btn:hover {
        color: #0f172a;
    }
    .buddy-tab-btn.active {
        color: #5b21b6;
    }
    .buddy-tab-btn.active::after {
        content: '';
        position: absolute;
        bottom: -1px;
        left: 0;
        right: 0;
        height: 3px;
        background-color: #5b21b6;
        border-radius: 3px 3px 0 0;
    }
    .buddy-tab-content {
        display: none;
    }
    .buddy-tab-content.active {
        display: block;
        animation: fadeIn 0.3s ease;
    }
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(5px); }
        to { opacity: 1; transform: translateY(0); }
    }

    /* Request Lists */
    .request-list {
        display: flex;
        flex-direction: column;
        gap: 16px;
    }
    .request-card {
        background: white;
        border-radius: 12px;
        padding: 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        border: 1px solid #e2e8f0;
    }
    .request-info {
        display: flex;
        gap: 16px;
        align-items: center;
    }
    .request-info img {
        width: 56px;
        height: 56px;
        border-radius: 50%;
        object-fit: cover;
    }
    .request-details h4 {
        margin: 0 0 4px 0;
        font-size: 16px;
        font-family: 'Outfit', sans-serif;
    }
    .request-details p {
        margin: 0;
        font-size: 13px;
        color: #64748b;
    }
    .request-actions {
        display: flex;
        gap: 8px;
    }
    .status-badge {
        padding: 6px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 600;
    }
    .status-pending { background: #fef08a; color: #854d0e; }
    .status-accepted { background: #dcfce7; color: #166534; }
    .status-rejected { background: #fee2e2; color: #991b1b; }
    .status-cancelled { background: #f1f5f9; color: #475569; }

    /* Matches Header */
    .matches-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 16px;
    }
    .matches-header h3 {
        font-family: 'Outfit', sans-serif;
        font-size: 20px;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .matches-header .count {
        color: #64748b;
        font-size: 14px;
        font-weight: 500;
    }
    .sort-by {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 14px;
        color: #475569;
    }
    .sort-by select {
        border: 1px solid #cbd5e1;
        padding: 6px 30px 6px 12px;
        border-radius: 6px;
        font-size: 14px;
        font-weight: 500;
        color: #0f172a;
        appearance: none;
        background-color: white;
        background-image: url('data:image/svg+xml;utf8,<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="%2394a3b8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>');
        background-repeat: no-repeat;
        background-position: right 8px center;
        background-size: 16px;
    }

    /* Match Grid */
    .match-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 20px;
    }
    .match-card {
        background: white;
        border-radius: 12px;
        overflow: hidden;
        box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        border: 1px solid #e2e8f0;
        display: flex;
        flex-direction: column;
    }
    .match-card-cover {
        height: 120px;
        background: url('https://images.unsplash.com/photo-1506929562872-bb421503ef21?auto=format&fit=crop&w=600&q=80') center/cover;
        position: relative;
    }
    .match-badge {
        position: absolute;
        top: 12px;
        right: 12px;
        background-color: #ecfccb;
        color: #4d7c0f;
        padding: 4px 10px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 700;
        display: flex;
        align-items: center;
        gap: 4px;
    }
    .btn-heart {
        position: absolute;
        bottom: -16px;
        right: 16px;
        width: 32px;
        height: 32px;
        background: white;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        color: #64748b;
        border: none;
        cursor: pointer;
    }
    .match-card-body {
        padding: 20px;
        flex: 1;
        display: flex;
        flex-direction: column;
    }
    .avatar-lg {
        width: 64px;
        height: 64px;
        border-radius: 50%;
        border: 3px solid white;
        margin-top: -52px;
        margin-bottom: 12px;
        background-color: #e2e8f0;
        object-fit: cover;
    }
    .match-name {
        font-family: 'Outfit', sans-serif;
        font-size: 18px;
        font-weight: 700;
        margin: 0 0 4px 0;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .match-name i { color: #8b5cf6; width: 16px; height: 16px; }
    .match-location {
        color: #64748b;
        font-size: 13px;
        display: flex;
        align-items: center;
        gap: 4px;
        margin-bottom: 12px;
    }
    .match-style {
        font-size: 13px;
        font-weight: 600;
        margin-bottom: 12px;
        color: #0f172a;
    }
    .match-style span { color: #3b82f6; }
    
    .tags {
        display: flex;
        flex-wrap: wrap;
        gap: 6px;
        margin-bottom: 12px;
    }
    .tag {
        background-color: #f1f5f9;
        color: #475569;
        padding: 4px 10px;
        border-radius: 6px;
        font-size: 12px;
        font-weight: 500;
    }
    .match-bio {
        font-size: 13px;
        color: #475569;
        line-height: 1.5;
        margin-bottom: 16px;
        flex: 1;
    }
    .match-details {
        display: flex;
        justify-content: space-between;
        font-size: 12px;
        color: #64748b;
        padding-top: 16px;
        border-top: 1px solid #f1f5f9;
        margin-bottom: 16px;
    }
    .match-details div {
        display: flex;
        align-items: center;
        gap: 4px;
    }
    .card-actions {
        display: flex;
        flex-direction: column;
        gap: 8px;
    }
    .btn-action {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        padding: 8px 16px;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s ease;
        text-decoration: none;
        border: none;
    }
    .btn-action:active {
        transform: scale(0.97);
    }
    .btn-action-primary {
        background-color: #5b21b6;
        color: white;
    }
    .btn-action-primary:hover { background-color: #4c1d95; box-shadow: 0 4px 12px rgba(91, 33, 182, 0.2); }
    
    .btn-action-secondary {
        background-color: #f8fafc;
        color: #475569;
        border: 1px solid #e2e8f0;
    }
    .btn-action-secondary:hover { background-color: #f1f5f9; color: #0f172a; border-color: #cbd5e1; }
    
    .btn-action-success {
        background-color: #16a34a;
        color: white;
    }
    .btn-action-success:hover { background-color: #15803d; box-shadow: 0 4px 12px rgba(22, 163, 74, 0.2); }
    
    .btn-action-danger {
        background-color: #fef2f2;
        color: #dc2626;
        border: 1px solid #fee2e2;
    }
    .btn-action-danger:hover { background-color: #fee2e2; color: #b91c1c; border-color: #fecaca; }

    .btn-action-info {
        background-color: #0284c7;
        color: white;
    }
    .btn-action-info:hover { background-color: #0369a1; box-shadow: 0 4px 12px rgba(2, 132, 199, 0.2); }
    
    .btn-block { width: 100%; }

    /* Right Sidebar */
    .sidebar-widget {
        background: white;
        border-radius: 12px;
        padding: 20px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        margin-bottom: 20px;
        border: 1px solid #e2e8f0;
    }
    .widget-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 16px;
    }
    .widget-header h3 {
        font-family: 'Outfit', sans-serif;
        font-size: 16px;
        font-weight: 700;
        margin: 0;
        color: #0f172a;
    }
    .widget-header a {
        color: #5b21b6;
        font-size: 13px;
        font-weight: 500;
        text-decoration: none;
    }
    
    .my-profile-mini {
        display: flex;
        gap: 12px;
        margin-bottom: 16px;
    }
    .my-profile-mini img {
        width: 48px;
        height: 48px;
        border-radius: 50%;
        object-fit: cover;
    }
    .my-profile-info h4 {
        margin: 0 0 4px 0;
        font-size: 15px;
    }
    .my-profile-info p {
        margin: 0 0 4px 0;
        font-size: 12px;
        color: #64748b;
    }
    .completeness-box {
        background-color: #f0fdf4;
        border-radius: 8px;
        padding: 12px;
        border: 1px solid #dcfce7;
    }
    .comp-header {
        display: flex;
        justify-content: space-between;
        font-size: 13px;
        font-weight: 600;
        color: #166534;
        margin-bottom: 8px;
    }
    .comp-bar-bg {
        height: 6px;
        background-color: #dcfce7;
        border-radius: 3px;
        overflow: hidden;
        margin-bottom: 8px;
    }
    .comp-bar-fill {
        height: 100%;
        background-color: #22c55e;
        border-radius: 3px;
    }
    .comp-link {
        font-size: 12px;
        color: #166534;
        text-decoration: none;
        display: flex;
        justify-content: space-between;
    }

    .dest-list { list-style: none; padding: 0; margin: 0; }
    .dest-item {
        display: flex;
        gap: 12px;
        align-items: center;
        margin-bottom: 12px;
    }
    .dest-item:last-child { margin-bottom: 0; }
    .dest-item img {
        width: 40px; height: 40px; border-radius: 8px; object-fit: cover;
    }
    .dest-info h5 { margin: 0; font-size: 14px; font-weight: 600; }
    .dest-info p { margin: 2px 0 0 0; font-size: 12px; color: #64748b; }

    .tips-box {
        background-color: #f8fafc;
    }
    .tips-box h3 { color: #5b21b6; display: flex; align-items: center; gap: 8px; }
    .tips-list { list-style: none; padding: 0; margin: 0; }
    .tips-list li {
        font-size: 13px;
        color: #475569;
        margin-bottom: 10px;
        display: flex;
        gap: 8px;
        align-items: flex-start;
    }
    .tips-list li i { color: #64748b; width: 16px; height: 16px; flex-shrink: 0; margin-top: 2px; }
    .tips-link {
        font-size: 13px;
        color: #5b21b6;
        text-decoration: none;
        font-weight: 500;
        margin-top: 8px;
        display: inline-block;
    }

    /* Modal Styles */
    .profile-modal-overlay {
        position: fixed;
        top: 0; left: 0; right: 0; bottom: 0;
        background: rgba(0,0,0,0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 1000;
        opacity: 0;
        visibility: hidden;
        transition: all 0.3s;
    }
    .profile-modal-overlay.active {
        opacity: 1;
        visibility: visible;
    }
    .profile-modal {
        background: white;
        border-radius: 16px;
        width: 100%;
        max-width: 480px;
        padding: 30px;
        position: relative;
        transform: translateY(20px);
        transition: all 0.3s;
        box-shadow: 0 10px 25px rgba(0,0,0,0.1);
    }
    .profile-modal-overlay.active .profile-modal {
        transform: translateY(0);
    }
    .modal-close {
        position: absolute;
        top: 16px;
        right: 16px;
        background: none;
        border: none;
        color: #64748b;
        cursor: pointer;
    }
    .modal-avatar {
        width: 80px;
        height: 80px;
        border-radius: 50%;
        object-fit: cover;
        margin-bottom: 16px;
        border: 2px solid #e2e8f0;
    }
    .modal-name {
        font-family: 'Outfit', sans-serif;
        font-size: 24px;
        font-weight: 700;
        margin: 0 0 4px 0;
        color: #0f172a;
    }
    .modal-location {
        color: #64748b;
        font-size: 14px;
        margin-bottom: 16px;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .modal-bio {
        background: #f8fafc;
        padding: 16px;
        border-radius: 8px;
        font-size: 14px;
        color: #475569;
        line-height: 1.6;
        margin-bottom: 20px;
    }
</style>

<main style="min-height: 80vh; padding-top: 120px; padding-bottom: 60px;">
    <div class="container">
        
        <c:if test="${not empty sessionScope.successMsg}">
            <div style="background-color: #d1fae5; color: #065f46; padding: 12px 20px; border-radius: 8px; margin-bottom: 20px; font-weight: 500;">
                ${sessionScope.successMsg}
            </div>
            <c:remove var="successMsg" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMsg}">
            <div style="background-color: #fee2e2; color: #991b1b; padding: 12px 20px; border-radius: 8px; margin-bottom: 20px; font-weight: 500;">
                ${sessionScope.errorMsg}
            </div>
            <c:remove var="errorMsg" scope="session"/>
        </c:if>

        <div class="layout-grid">
            <!-- LEFT MAIN COLUMN -->
            <div class="main-column">
                
                <div class="buddy-tabs">
                    <button class="buddy-tab-btn active" onclick="switchBuddyTab('discover', this)">Khám phá</button>
                    <button class="buddy-tab-btn" onclick="switchBuddyTab('received', this)">
                        Đã nhận <span style="background:#ef4444;color:white;padding:2px 8px;border-radius:10px;font-size:11px;margin-left:4px;">${receivedRequests.stream().filter(r -> r.status == 'Pending').count()}</span>
                    </button>
                    <button class="buddy-tab-btn" onclick="switchBuddyTab('sent', this)">Đã gửi</button>
                    <button class="buddy-tab-btn" onclick="switchBuddyTab('friends', this)">Bạn đồng hành (${acceptedBuddies.size()})</button>
                </div>

                <!-- Tab: Discover -->
                <div class="buddy-tab-content active" id="buddy-tab-discover">
                    <div class="matches-header">
                        <h3>Gợi ý hàng đầu cho bạn <i data-lucide="info" style="width: 16px; color: #94a3b8;"></i></h3>
                        <div style="display: flex; align-items: center; gap: 20px;">
                            <span class="count">${topMatches.size()} người phù hợp</span>
                            <div class="sort-by">
                                Sắp xếp: 
                                <select>
                                    <option>Phù hợp nhất</option>
                                    <option>Mới nhất</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="match-grid">
                        <c:if test="${empty topMatches}">
                            <div style="grid-column: 1 / -1; text-align: center; padding: 40px; background: white; border-radius: 12px; color: #64748b;">
                                Không tìm thấy ai phù hợp với tiêu chí hiện tại. Hãy thử điều chỉnh ở trang <a href="${pageContext.request.contextPath}/profile">Sở thích cá nhân</a>!
                            </div>
                        </c:if>
                        
                        <c:forEach var="m" items="${topMatches}">
                            <div class="match-card">
                                <div class="match-card-cover">
                                    <div class="match-badge">${m.matchPercentage}% Phù hợp</div>
                                    <button class="btn-heart"><i data-lucide="heart" style="width: 16px;"></i></button>
                                </div>
                                <div class="match-card-body">
                                    <c:choose>
                                        <c:when test="${not empty m.profile.avatarUrl}">
                                            <img src="${m.profile.avatarUrl}" class="avatar-lg">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80" class="avatar-lg">
                                        </c:otherwise>
                                    </c:choose>
                                    
                                    <h4 class="match-name">${m.user.fullName} <i data-lucide="badge-check"></i></h4>
                                    <div class="match-location">
                                        <i data-lucide="map-pin" style="width: 14px;"></i> ${not empty m.profile.address ? m.profile.address : 'Chưa cập nhật vị trí'}
                                    </div>
                                    <div class="match-style">
                                        Phong cách: <span>${not empty m.preference.travelStyle ? m.preference.travelStyle : 'Explorer'}</span>
                                    </div>
                                    <div class="tags">
                                        <c:if test="${not empty m.preference.tags}">
                                            <c:forEach var="tag" items="${m.preference.tags.split(',')}">
                                                <span class="tag">${tag.trim()}</span>
                                            </c:forEach>
                                        </c:if>
                                        <c:if test="${empty m.preference.tags}">
                                            <span class="tag">Chưa có Tags</span>
                                        </c:if>
                                    </div>
                                    <div class="match-bio">
                                        ${not empty m.profile.biography ? m.profile.biography : 'Đam mê du lịch và khám phá những vùng đất mới. Cùng nhau xách balo lên và đi nhé!'}
                                    </div>
                                    <div class="match-details">
                                        <div><i data-lucide="calendar" style="width: 14px;"></i> ${not empty m.preference.startDate ? m.preference.startDate : 'Anytime'}</div>
                                        <div><i data-lucide="dollar-sign" style="width: 14px;"></i> ${m.preference.maxBudget > 0 ? m.preference.maxBudget : 'Flexible'}</div>
                                    </div>
                                    <div class="card-actions">
                                        <a href="javascript:void(0)" 
                                           class="btn-action btn-action-secondary btn-block"
                                           data-name="${m.user.fullName}"
                                           data-avatar="${not empty m.profile.avatarUrl ? m.profile.avatarUrl : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80'}"
                                           data-address="${not empty m.profile.address ? m.profile.address : 'Vietnam'}"
                                           data-email="${m.user.email}"
                                           data-bio="${not empty m.profile.biography ? m.profile.biography : 'Chưa có thông tin tiểu sử.'}"
                                           data-style="${not empty m.preference.travelStyle ? m.preference.travelStyle : 'Chưa cập nhật'}"
                                           data-dest="${not empty m.preference.destination ? m.preference.destination : 'Bất kỳ'}"
                                           data-tags="${not empty m.preference.tags ? m.preference.tags : 'Chưa có'}"
                                           data-duration="${not empty m.preference.tripDuration ? m.preference.tripDuration : 'Bất kỳ'}"
                                           data-freq="${not empty m.preference.travelFrequency ? m.preference.travelFrequency : 'Bất kỳ'}"
                                           data-smoke="${not empty m.preference.smokingPreference ? m.preference.smokingPreference : 'Chưa rõ'}"
                                           data-drink="${not empty m.preference.drinkingPreference ? m.preference.drinkingPreference : 'Chưa rõ'}"
                                           data-lang="${not empty m.preference.languages ? m.preference.languages : 'Chưa có'}"
                                           onclick="openProfileModal(this)">Xem hồ sơ</a>
                                        <form action="${pageContext.request.contextPath}/customer/buddies" method="POST">
                                            <input type="hidden" name="action" value="send">
                                            <input type="hidden" name="receiverId" value="${m.user.userId}">
                                            <button type="submit" class="btn-action btn-action-primary btn-block">
                                                <i data-lucide="user-plus" style="width: 16px;"></i> Gửi kết bạn
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- Tab: Received -->
                <div class="buddy-tab-content" id="buddy-tab-received">
                    <div class="request-list">
                        <c:if test="${empty receivedRequests}">
                            <div style="text-align: center; padding: 40px; background: white; border-radius: 12px; color: #64748b;">
                                Bạn chưa có lời mời kết bạn nào.
                            </div>
                        </c:if>
                        <c:forEach var="req" items="${receivedRequests}">
                            <div class="request-card">
                                <div class="request-info">
                                    <c:choose>
                                        <c:when test="${not empty req.sender.profile.avatarUrl}">
                                            <img src="${req.sender.profile.avatarUrl}">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80">
                                        </c:otherwise>
                                    </c:choose>
                                    <div class="request-details">
                                        <h4>${req.sender.fullName}</h4>
                                        <p>${req.sender.email} &bull; <i data-lucide="clock" style="width:12px"></i> ${req.createdAt}</p>
                                    </div>
                                </div>
                                <div class="request-actions">
                                    <c:choose>
                                        <c:when test="${req.status == 'Pending'}">
                                            <form action="${pageContext.request.contextPath}/customer/buddies" method="POST" style="display:inline;">
                                                <input type="hidden" name="action" value="accept">
                                                <input type="hidden" name="requestId" value="${req.requestId}">
                                                <button type="submit" class="btn-action btn-action-success"><i data-lucide="check" style="width:16px;"></i> Chấp nhận</button>
                                            </form>
                                            <form action="${pageContext.request.contextPath}/customer/buddies" method="POST" style="display:inline;">
                                                <input type="hidden" name="action" value="reject">
                                                <input type="hidden" name="requestId" value="${req.requestId}">
                                                <button type="submit" class="btn-action btn-action-danger"><i data-lucide="x" style="width:16px;"></i> Từ chối</button>
                                            </form>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge status-${req.status.toLowerCase()}">${req.status == 'Accepted' ? 'Đã kết nối' : (req.status == 'Rejected' ? 'Đã từ chối' : req.status)}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- Tab: Sent -->
                <div class="buddy-tab-content" id="buddy-tab-sent">
                    <div class="request-list">
                        <c:if test="${empty sentRequests}">
                            <div style="text-align: center; padding: 40px; background: white; border-radius: 12px; color: #64748b;">
                                Bạn chưa gửi lời mời kết bạn nào.
                            </div>
                        </c:if>
                        <c:forEach var="req" items="${sentRequests}">
                            <div class="request-card">
                                <div class="request-info">
                                    <c:choose>
                                        <c:when test="${not empty req.sender.profile.avatarUrl}">
                                            <img src="${req.sender.profile.avatarUrl}">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80">
                                        </c:otherwise>
                                    </c:choose>
                                    <div class="request-details">
                                        <h4>Đã gửi đến: ${req.sender.fullName}</h4>
                                        <p>${req.sender.email} &bull; <i data-lucide="clock" style="width:12px"></i> ${req.createdAt}</p>
                                    </div>
                                </div>
                                <div class="request-actions">
                                    <span class="status-badge status-${req.status.toLowerCase()}">${req.status == 'Pending' ? 'Đang chờ' : (req.status == 'Accepted' ? 'Đã kết nối' : (req.status == 'Rejected' ? 'Bị từ chối' : 'Đã hủy'))}</span>
                                    <c:if test="${req.status == 'Pending'}">
                                        <form action="${pageContext.request.contextPath}/customer/buddies" method="POST" style="display:inline; margin-left:8px;">
                                            <input type="hidden" name="action" value="cancel">
                                            <input type="hidden" name="requestId" value="${req.requestId}">
                                            <button type="submit" class="btn-action btn-action-danger">Hủy lời mời</button>
                                        </form>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- Tab: Friends -->
                <div class="buddy-tab-content" id="buddy-tab-friends">
                    <div class="request-list">
                        <c:if test="${empty acceptedBuddies}">
                            <div style="text-align: center; padding: 40px; background: white; border-radius: 12px; color: #64748b;">
                                Bạn chưa có người bạn đồng hành nào.
                            </div>
                        </c:if>
                        <c:forEach var="friend" items="${acceptedBuddies}">
                            <div class="request-card">
                                <div class="request-info">
                                    <c:choose>
                                        <c:when test="${not empty friend.profile.avatarUrl}">
                                            <img src="${friend.profile.avatarUrl}">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80">
                                        </c:otherwise>
                                    </c:choose>
                                    <div class="request-details">
                                        <h4>${friend.fullName}</h4>
                                        <p>${friend.email} &bull; ${not empty friend.profile.address ? friend.profile.address : 'Vietnam'}</p>
                                    </div>
                                </div>
                                <div class="request-actions">
                                    <button class="btn-action btn-action-info"><i data-lucide="message-circle" style="width:16px;"></i> Nhắn tin</button>
                                    <c:set var="pref" value="${friendPrefs[friend.userId]}"/>
                                    <a href="javascript:void(0)" 
                                       class="btn-action btn-action-secondary"
                                       data-name="${friend.fullName}"
                                       data-avatar="${not empty friend.profile.avatarUrl ? friend.profile.avatarUrl : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80'}"
                                       data-address="${not empty friend.profile.address ? friend.profile.address : 'Vietnam'}"
                                       data-email="${friend.email}"
                                       data-bio="${not empty friend.profile.biography ? friend.profile.biography : 'Chưa có thông tin tiểu sử.'}"
                                       data-style="${not empty pref.travelStyle ? pref.travelStyle : 'Chưa cập nhật'}"
                                       data-dest="${not empty pref.destination ? pref.destination : 'Bất kỳ'}"
                                       data-tags="${not empty pref.tags ? pref.tags : 'Chưa có'}"
                                       data-duration="${not empty pref.tripDuration ? pref.tripDuration : 'Bất kỳ'}"
                                       data-freq="${not empty pref.travelFrequency ? pref.travelFrequency : 'Bất kỳ'}"
                                       data-smoke="${not empty pref.smokingPreference ? pref.smokingPreference : 'Chưa rõ'}"
                                       data-drink="${not empty pref.drinkingPreference ? pref.drinkingPreference : 'Chưa rõ'}"
                                       data-lang="${not empty pref.languages ? pref.languages : 'Chưa có'}"
                                       onclick="openProfileModal(this)">Hồ sơ</a>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

            </div>

            <!-- RIGHT SIDEBAR -->
            <div class="sidebar">
                
                <div class="sidebar-widget">
                    <div class="widget-header">
                        <h3>Hồ sơ Matching của bạn</h3>
                        <a href="#"><i data-lucide="edit-2" style="width: 14px;"></i> Sửa</a>
                    </div>
                    <div class="my-profile-mini">
                        <c:choose>
                            <c:when test="${not empty sessionUser.profile.avatarUrl}">
                                <img src="${sessionUser.profile.avatarUrl}">
                            </c:when>
                            <c:otherwise>
                                <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80">
                            </c:otherwise>
                        </c:choose>
                        <div class="my-profile-info">
                            <h4>${sessionUser.fullName}</h4>
                            <p><i data-lucide="map-pin" style="width: 12px;"></i> ${not empty sessionUser.profile.address ? sessionUser.profile.address : 'Vietnam'}</p>
                            <p>Phong cách: <span style="color: #5b21b6; font-weight: 500;">${myPref.travelStyle}</span></p>
                            <p>Ngôn ngữ: ${myPref.languages}</p>
                        </div>
                    </div>
                    <div class="completeness-box">
                        <div class="comp-header">
                            <span>Độ hoàn thiện hồ sơ</span>
                            <span>${completeness}%</span>
                        </div>
                        <div class="comp-bar-bg">
                            <div class="comp-bar-fill" style="width: ${completeness}%;"></div>
                        </div>
                        <a href="#" class="comp-link">Thêm chi tiết để match tốt hơn! <i data-lucide="chevron-right" style="width: 14px;"></i></a>
                    </div>
                </div>

                <div class="sidebar-widget">
                    <div class="widget-header">
                        <h3>Điểm đến phổ biến</h3>
                        <a href="#">Xem tất cả</a>
                    </div>
                    <ul class="dest-list">
                        <li class="dest-item">
                            <img src="https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=100&q=80">
                            <div class="dest-info">
                                <h5>Bali, Indonesia</h5>
                                <p>1,234 travelers</p>
                            </div>
                        </li>
                        <li class="dest-item">
                            <img src="https://images.unsplash.com/photo-1530122037265-a5f1f91d3b99?auto=format&fit=crop&w=100&q=80">
                            <div class="dest-info">
                                <h5>Thụy Sĩ (Switzerland)</h5>
                                <p>987 travelers</p>
                            </div>
                        </li>
                        <li class="dest-item">
                            <img src="https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=100&q=80">
                            <div class="dest-info">
                                <h5>Nhật Bản (Japan)</h5>
                                <p>875 travelers</p>
                            </div>
                        </li>
                        <li class="dest-item">
                            <img src="https://images.unsplash.com/photo-1583417311029-7d8ab439569e?auto=format&fit=crop&w=100&q=80">
                            <div class="dest-info">
                                <h5>Thái Lan (Thailand)</h5>
                                <p>765 travelers</p>
                            </div>
                        </li>
                    </ul>
                </div>

                <div class="sidebar-widget tips-box">
                    <h3 style="margin-top: 0;"><i data-lucide="lightbulb"></i> Mẹo tìm bạn</h3>
                    <ul class="tips-list">
                        <li><i data-lucide="check-circle-2"></i> Hoàn thiện hồ sơ để tăng độ chính xác</li>
                        <li><i data-lucide="check-circle-2"></i> Ghi rõ sở thích du lịch (Tags)</li>
                        <li><i data-lucide="check-circle-2"></i> Thêm ngày dự kiến chính xác</li>
                        <li><i data-lucide="check-circle-2"></i> Phản hồi tin nhắn nhanh chóng</li>
                    </ul>
                    <a href="#" class="tips-link">Tìm hiểu thêm &rarr;</a>
                </div>

            </div>
        </div>
    </div>
</main>

<!-- Profile Modal -->
<div class="profile-modal-overlay" id="profileModal">
    <div class="profile-modal" style="max-height: 90vh; overflow-y: auto;">
        <button class="modal-close" onclick="closeProfileModal()"><i data-lucide="x"></i></button>
        <div style="text-align: center; margin-bottom: 20px;">
            <img src="" id="modalAvatar" class="modal-avatar">
            <h3 class="modal-name" id="modalName">Name</h3>
            <div class="modal-location" style="justify-content: center; margin-bottom: 8px;">
                <i data-lucide="map-pin" style="width: 14px;"></i> <span id="modalLocation">Location</span>
            </div>
            <div class="modal-location" style="justify-content: center; margin-bottom: 0; color: #5b21b6;">
                <i data-lucide="mail" style="width: 14px;"></i> <span id="modalEmail">Email</span>
            </div>
        </div>
        
        <h4 style="margin: 0 0 8px 0; font-size: 15px; color: #0f172a;">Tiểu sử</h4>
        <div class="modal-bio" id="modalBio" style="margin-bottom: 24px;">
            Bio goes here.
        </div>
        
        <h4 style="margin: 0 0 12px 0; font-size: 15px; color: #0f172a; border-bottom: 1px solid #e2e8f0; padding-bottom: 8px;">Sở thích du lịch</h4>
        
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; font-size: 13px; color: #475569; margin-bottom: 24px;">
            <div><strong>Phong cách:</strong> <span id="m-style" style="color: #0f172a;"></span></div>
            <div><strong>Điểm đến:</strong> <span id="m-dest" style="color: #0f172a;"></span></div>
            <div><strong>Thời gian:</strong> <span id="m-duration" style="color: #0f172a;"></span></div>
            <div><strong>Tần suất:</strong> <span id="m-freq" style="color: #0f172a;"></span></div>
            <div><strong>Hút thuốc:</strong> <span id="m-smoke" style="color: #0f172a;"></span></div>
            <div><strong>Đồ uống có cồn:</strong> <span id="m-drink" style="color: #0f172a;"></span></div>
            <div style="grid-column: 1 / -1;"><strong>Ngôn ngữ:</strong> <span id="m-lang" style="color: #0f172a;"></span></div>
            <div style="grid-column: 1 / -1;"><strong>Sở thích (Tags):</strong> <span id="m-tags" style="color: #0f172a;"></span></div>
        </div>
        
        <button class="btn-block btn-block-light" onclick="closeProfileModal()">Đóng</button>
    </div>
</div>

<script>
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }
    
    function switchBuddyTab(tabId, btn) {
        document.querySelectorAll('.buddy-tab-content').forEach(t => t.classList.remove('active'));
        document.querySelectorAll('.buddy-tab-btn').forEach(b => b.classList.remove('active'));
        
        document.getElementById('buddy-tab-' + tabId).classList.add('active');
        btn.classList.add('active');
    }

    function openProfileModal(btn) {
        document.getElementById('modalName').textContent = btn.getAttribute('data-name');
        document.getElementById('modalAvatar').src = btn.getAttribute('data-avatar');
        document.getElementById('modalLocation').textContent = btn.getAttribute('data-address');
        document.getElementById('modalBio').textContent = btn.getAttribute('data-bio');
        document.getElementById('modalEmail').textContent = btn.getAttribute('data-email') || 'Chưa cập nhật email';
        
        document.getElementById('m-style').textContent = btn.getAttribute('data-style');
        document.getElementById('m-dest').textContent = btn.getAttribute('data-dest');
        document.getElementById('m-tags').textContent = btn.getAttribute('data-tags');
        document.getElementById('m-duration').textContent = btn.getAttribute('data-duration');
        document.getElementById('m-freq').textContent = btn.getAttribute('data-freq');
        document.getElementById('m-smoke').textContent = btn.getAttribute('data-smoke');
        document.getElementById('m-drink').textContent = btn.getAttribute('data-drink');
        document.getElementById('m-lang').textContent = btn.getAttribute('data-lang');
        
        document.getElementById('profileModal').classList.add('active');
    }

    function closeProfileModal() {
        document.getElementById('profileModal').classList.remove('active');
    }
</script>

<jsp:include page="/common/footer.jsp"/>
