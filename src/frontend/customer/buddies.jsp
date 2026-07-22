<%-- 
    Li&#234;n quan &#273;&#7871;n UCs: Match Travel Companions, Manage Buddy Requests
    T&#225;c gi&#7843;: &#272;&#7895; V&#361; Minh Ng&#7885;c
    MSSV: HE182479
--%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
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
        object-position: center 15%;
        position: relative;
        z-index: 10;
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
            <!-- C&#7897;t n&#7897;i dung ch&#237;nh b&#234;n tr&#225;i -->
            <div class="main-column">
                
                <div class="buddy-tabs">
                    <button class="buddy-tab-btn active" onclick="switchBuddyTab('discover', this)">Kh&#225;m ph&#225;</button>
                    <button class="buddy-tab-btn" onclick="switchBuddyTab('received', this)">
                        &#272;&#227; nh&#7853;n <span style="background:#ef4444;color:white;padding:2px 8px;border-radius:10px;font-size:11px;margin-left:4px;">${receivedRequests.stream().filter(r -> r.status == 'Pending').count()}</span>
                    </button>
                    <button class="buddy-tab-btn" onclick="switchBuddyTab('sent', this)">&#272;&#227; g&#7917;i</button>
                    <button class="buddy-tab-btn" onclick="switchBuddyTab('friends', this)">B&#7841;n &#273;&#7891;ng h&#224;nh (${acceptedBuddies.size()})</button>
                </div>

                <!-- Tab: Kh&#225;m ph&#225; b&#7841;n &#273;&#7891;ng h&#224;nh -->
                <div class="buddy-tab-content active" id="buddy-tab-discover">
                    <div class="matches-header">
                        <h3>G&#7907;i &#253; h&#224;ng &#273;&#7847;u cho b&#7841;n <i data-lucide="info" style="width: 16px; color: #94a3b8;"></i></h3>
                        <div style="display: flex; align-items: center; gap: 20px;">
                            <span class="count">${topMatches.size()} ng&#432;&#7901;i ph&#249; h&#7907;p</span>
                            <div class="sort-by">
                                S&#7855;p x&#7871;p: 
                                <select id="matchSortSelect" onchange="sortMatches()">
                                    <option value="match">Ph&#249; h&#7907;p nh&#7845;t</option>
                                    <option value="newest">M&#7899;i nh&#7845;t</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="match-grid">
                        <c:if test="${empty topMatches}">
                            <div style="grid-column: 1 / -1; text-align: center; padding: 40px; background: white; border-radius: 12px; color: #64748b;">
                                Kh&#244;ng t&#236;m th&#7845;y ai ph&#249; h&#7907;p v&#7899;i ti&#234;u ch&#237; hi&#7879;n t&#7841;i. H&#227;y th&#7917; &#273;i&#7873;u ch&#7881;nh &#7903; trang <a href="${pageContext.request.contextPath}/profile">S&#7903; th&#237;ch c&#225; nh&#226;n</a>!
                            </div>
                        </c:if>
                        
                        <c:forEach var="m" items="${topMatches}">
                            <div class="match-card" data-match="${m.matchPercentage}" data-id="${m.user.userId}">
                                <div class="match-card-cover">
                                    <div class="match-badge">${m.matchPercentage}% Ph&#249; h&#7907;p</div>
                                    <button class="btn-heart" onclick="toggleHeart(this, ${m.user.userId})"><i data-lucide="heart" style="width: 16px;"></i></button>
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
                                        <i data-lucide="map-pin" style="width: 14px;"></i> ${not empty m.profile.address ? m.profile.address : 'Ch&#432;a c&#7853;p nh&#7853;t v&#7883; tr&#237;'}
                                    </div>
                                    <div class="match-style">
                                        Phong c&#225;ch: <span>${not empty m.preference.travelStyle ? m.preference.travelStyle : 'Explorer'}</span>
                                    </div>
                                    <div class="tags">
                                        <c:if test="${not empty m.preference.tags}">
                                            <c:forEach var="tag" items="${m.preference.tags.split(',')}">
                                                <span class="tag">${tag.trim()}</span>
                                            </c:forEach>
                                        </c:if>
                                        <c:if test="${empty m.preference.tags}">
                                            <span class="tag">Ch&#432;a c&#243; Tags</span>
                                        </c:if>
                                    </div>
                                    <div class="match-bio">
                                        ${not empty m.profile.biography ? m.profile.biography : '&#272;am m&#234; du l&#7883;ch v&#224; kh&#225;m ph&#225; nh&#7919;ng v&#249;ng &#273;&#7845;t m&#7899;i. C&#249;ng nhau x&#225;ch balo l&#234;n v&#224; &#273;i nh&#233;!'}
                                    </div>
                                    <div class="match-details">
                                        <div><i data-lucide="calendar" style="width: 14px;"></i> ${not empty m.preference.startDate ? m.preference.startDate : 'Anytime'}</div>
                                        <div><i data-lucide="dollar-sign" style="width: 14px;"></i> 
                                            <c:choose>
                                                <c:when test="${m.preference.maxBudget > 0}">
                                                    <fmt:formatNumber value="${m.preference.maxBudget}" type="number" pattern="#,##0"/>
                                                </c:when>
                                                <c:otherwise>Flexible</c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                    <div class="card-actions">
                                        <a href="javascript:void(0)" 
                                           class="btn-action btn-action-secondary btn-block"
                                           data-name="${m.user.fullName}"
                                           data-avatar="${not empty m.profile.avatarUrl ? m.profile.avatarUrl : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80'}"
                                           data-address="${not empty m.profile.address ? m.profile.address : 'Vietnam'}"
                                           data-email="${m.user.email}"
                                           data-bio="${not empty m.profile.biography ? m.profile.biography : 'Ch&#432;a c&#243; th&#244;ng tin ti&#7875;u s&#7917;.'}"
                                           data-style="${not empty m.preference.travelStyle ? m.preference.travelStyle : 'Ch&#432;a c&#7853;p nh&#7853;t'}"
                                           data-dest="${not empty m.preference.destination ? m.preference.destination : 'B&#7845;t k&#7923;'}"
                                           data-tags="${not empty m.preference.tags ? m.preference.tags : 'Ch&#432;a c&#243;'}"
                                           data-duration="${not empty m.preference.tripDuration ? m.preference.tripDuration : 'B&#7845;t k&#7923;'}"
                                           data-freq="${not empty m.preference.travelFrequency ? m.preference.travelFrequency : 'B&#7845;t k&#7923;'}"
                                           data-smoke="${not empty m.preference.smokingPreference ? m.preference.smokingPreference : 'Ch&#432;a r&#245;'}"
                                           data-drink="${not empty m.preference.drinkingPreference ? m.preference.drinkingPreference : 'Ch&#432;a r&#245;'}"
                                           data-lang="${not empty m.preference.languages ? m.preference.languages : 'Ch&#432;a c&#243;'}"
                                           onclick="openProfileModal(this)">Xem h&#7891; s&#417;</a>
                                        <form action="${pageContext.request.contextPath}/customer/buddies" method="POST">
                                            <input type="hidden" name="action" value="send">
                                            <input type="hidden" name="receiverId" value="${m.user.userId}">
                                            <button type="submit" class="btn-action btn-action-primary btn-block">
                                                <i data-lucide="user-plus" style="width: 16px;"></i> G&#7917;i k&#7871;t b&#7841;n
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- Tab: L&#7901;i m&#7901;i &#273;&#227; nh&#7853;n -->
                <div class="buddy-tab-content" id="buddy-tab-received">
                    <div class="request-list">
                        <c:if test="${empty receivedRequests}">
                            <div style="text-align: center; padding: 40px; background: white; border-radius: 12px; color: #64748b;">
                                B&#7841;n ch&#432;a c&#243; l&#7901;i m&#7901;i k&#7871;t b&#7841;n n&#224;o.
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
                                        <p>${req.sender.email} &bull; <i data-lucide="clock" style="width:12px"></i> <fmt:formatDate value="${req.createdAt}" pattern="yyyy-MM-dd HH:mm"/></p>
                                    </div>
                                </div>
                                <div class="request-actions">
                                    <c:choose>
                                        <c:when test="${req.status == 'Pending'}">
                                            <form action="${pageContext.request.contextPath}/customer/buddies" method="POST" style="display:inline;">
                                                <input type="hidden" name="action" value="accept">
                                                <input type="hidden" name="requestId" value="${req.requestId}">
                                                <button type="submit" class="btn-action btn-action-success"><i data-lucide="check" style="width:16px;"></i> Ch&#7845;p nh&#7853;n</button>
                                            </form>
                                            <form action="${pageContext.request.contextPath}/customer/buddies" method="POST" style="display:inline;">
                                                <input type="hidden" name="action" value="reject">
                                                <input type="hidden" name="requestId" value="${req.requestId}">
                                                <button type="submit" class="btn-action btn-action-danger"><i data-lucide="x" style="width:16px;"></i> T&#7915; ch&#7889;i</button>
                                            </form>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge status-${req.status.toLowerCase()}">${req.status == 'Accepted' ? '&#272;&#227; k&#7871;t n&#7889;i' : (req.status == 'Rejected' ? '&#272;&#227; t&#7915; ch&#7889;i' : req.status)}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- Tab: L&#7901;i m&#7901;i &#273;&#227; g&#7917;i -->
                <div class="buddy-tab-content" id="buddy-tab-sent">
                    <div class="request-list">
                        <c:if test="${empty sentRequests}">
                            <div style="text-align: center; padding: 40px; background: white; border-radius: 12px; color: #64748b;">
                                B&#7841;n ch&#432;a g&#7917;i l&#7901;i m&#7901;i k&#7871;t b&#7841;n n&#224;o.
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
                                        <h4>&#272;&#227; g&#7917;i &#273;&#7871;n: ${req.sender.fullName}</h4>
                                        <p>${req.sender.email} &bull; <i data-lucide="clock" style="width:12px"></i> <fmt:formatDate value="${req.createdAt}" pattern="yyyy-MM-dd HH:mm"/></p>
                                    </div>
                                </div>
                                <div class="request-actions">
                                    <span class="status-badge status-${req.status.toLowerCase()}">${req.status == 'Pending' ? '&#272;ang ch&#7901;' : (req.status == 'Accepted' ? '&#272;&#227; k&#7871;t n&#7889;i' : (req.status == 'Rejected' ? 'B&#7883; t&#7915; ch&#7889;i' : '&#272;&#227; h&#7911;y'))}</span>
                                    <c:if test="${req.status == 'Pending'}">
                                        <form action="${pageContext.request.contextPath}/customer/buddies" method="POST" style="display:inline; margin-left:8px;">
                                            <input type="hidden" name="action" value="cancel">
                                            <input type="hidden" name="requestId" value="${req.requestId}">
                                            <button type="submit" class="btn-action btn-action-danger">H&#7911;y l&#7901;i m&#7901;i</button>
                                        </form>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- Tab: Danh s&#225;ch b&#7841;n b&#232; -->
                <div class="buddy-tab-content" id="buddy-tab-friends">
                    <div class="request-list">
                        <c:if test="${empty acceptedBuddies}">
                            <div style="text-align: center; padding: 40px; background: white; border-radius: 12px; color: #64748b;">
                                B&#7841;n ch&#432;a c&#243; ng&#432;&#7901;i b&#7841;n &#273;&#7891;ng h&#224;nh n&#224;o.
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
                                    <form action="${pageContext.request.contextPath}/customer/chat" method="POST" style="display:inline;">
                                        <input type="hidden" name="action" value="create">
                                        <input type="hidden" name="targetUserId" value="${friend.userId}">
                                        <button type="submit" class="btn-action btn-action-info"><i data-lucide="message-circle" style="width:16px;"></i> Nh&#7855;n tin</button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/customer/buddies" method="POST" style="display:inline;" onsubmit="return confirm('B&#7841;n c&#243; ch&#7855;c ch&#7855;n mu&#7889;n h&#7911;y k&#7871;t b&#7841;n v&#7899;i ng&#432;&#7901;i n&#224;y kh&#244;ng?');">
                                        <input type="hidden" name="action" value="unfriend">
                                        <input type="hidden" name="targetId" value="${friend.userId}">
                                        <button type="submit" class="btn-action btn-action-danger"><i data-lucide="user-minus" style="width:16px;"></i> H&#7911;y k&#7871;t b&#7841;n</button>
                                    </form>
                                    <c:set var="pref" value="${friendPrefs[friend.userId]}"/>
                                    <a href="javascript:void(0)" 
                                       class="btn-action btn-action-secondary"
                                       data-name="${friend.fullName}"
                                       data-avatar="${not empty friend.profile.avatarUrl ? friend.profile.avatarUrl : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80'}"
                                       data-address="${not empty friend.profile.address ? friend.profile.address : 'Vietnam'}"
                                       data-email="${friend.email}"
                                       data-bio="${not empty friend.profile.biography ? friend.profile.biography : 'Ch&#432;a c&#243; th&#244;ng tin ti&#7875;u s&#7917;.'}"
                                       data-style="${not empty pref.travelStyle ? pref.travelStyle : 'Ch&#432;a c&#7853;p nh&#7853;t'}"
                                       data-dest="${not empty pref.destination ? pref.destination : 'B&#7845;t k&#7923;'}"
                                       data-tags="${not empty pref.tags ? pref.tags : 'Ch&#432;a c&#243;'}"
                                       data-duration="${not empty pref.tripDuration ? pref.tripDuration : 'B&#7845;t k&#7923;'}"
                                       data-freq="${not empty pref.travelFrequency ? pref.travelFrequency : 'B&#7845;t k&#7923;'}"
                                       data-smoke="${not empty pref.smokingPreference ? pref.smokingPreference : 'Ch&#432;a r&#245;'}"
                                       data-drink="${not empty pref.drinkingPreference ? pref.drinkingPreference : 'Ch&#432;a r&#245;'}"
                                       data-lang="${not empty pref.languages ? pref.languages : 'Ch&#432;a c&#243;'}"
                                       onclick="openProfileModal(this)">H&#7891; s&#417;</a>
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
                        <h3>H&#7891; s&#417; Matching c&#7911;a b&#7841;n</h3>
                        <a href="${pageContext.request.contextPath}/profile"><i data-lucide="edit-2" style="width: 14px;"></i> S&#7917;a</a>
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
                            <p>Phong c&#225;ch: <span style="color: #5b21b6; font-weight: 500;">${myPref.travelStyle}</span></p>
                            <p>Ng&#244;n ng&#7919;: ${myPref.languages}</p>
                        </div>
                    </div>
                    <div class="completeness-box">
                        <div class="comp-header">
                            <span>&#272;&#7897; ho&#224;n thi&#7879;n h&#7891; s&#417;</span>
                            <span>${completeness}%</span>
                        </div>
                        <div class="comp-bar-bg">
                            <div class="comp-bar-fill" style="width: ${completeness}%;"></div>
                        </div>
                        <a href="${pageContext.request.contextPath}/profile" class="comp-link">Th&#234;m chi ti&#7871;t &#273;&#7875; match t&#7889;t h&#417;n! <i data-lucide="chevron-right" style="width: 14px;"></i></a>
                    </div>
                </div>

                <div class="sidebar-widget">
                    <div class="widget-header">
                        <h3>&#272;i&#7875;m &#273;&#7871;n ph&#7893; bi&#7871;n</h3>
                        <a href="${pageContext.request.contextPath}/home#destinations">Xem t&#7845;t c&#7843;</a>
                    </div>
                    <ul class="dest-list">
                        <c:forEach var="dest" items="${destinations}" begin="0" end="3">
                            <li class="dest-item" onclick="window.location.href='${pageContext.request.contextPath}/tourdiscovery?dest=${dest.name}'" style="cursor: pointer;" title="T&#236;m tour t&#7841;i ${dest.name}">
                                <c:choose>
                                    <c:when test="${not empty dest.imageUrl && (dest.imageUrl.startsWith('http://') || dest.imageUrl.startsWith('https://'))}">
                                        <img src="${dest.imageUrl}" alt="${dest.name}">
                                    </c:when>
                                    <c:when test="${not empty dest.imageUrl}">
                                        <img src="${pageContext.request.contextPath}/${dest.imageUrl}" alt="${dest.name}">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=100&q=80" alt="${dest.name}">
                                    </c:otherwise>
                                </c:choose>
                                <div class="dest-info">
                                    <h5>${dest.name}</h5>
                                    <p>${dest.tourCount} tours</p>
                                </div>
                            </li>
                        </c:forEach>
                    </ul>
                </div>

                <div class="sidebar-widget tips-box">
                    <h3 style="margin-top: 0;"><i data-lucide="lightbulb"></i> M&#7865;o t&#236;m b&#7841;n</h3>
                    <ul class="tips-list">
                        <li><i data-lucide="check-circle-2"></i> Ho&#224;n thi&#7879;n h&#7891; s&#417; &#273;&#7875; t&#259;ng &#273;&#7897; ch&#237;nh x&#225;c</li>
                        <li><i data-lucide="check-circle-2"></i> Ghi r&#245; s&#7903; th&#237;ch du l&#7883;ch (Tags)</li>
                        <li><i data-lucide="check-circle-2"></i> Th&#234;m ng&#224;y d&#7921; ki&#7871;n ch&#237;nh x&#225;c</li>
                        <li><i data-lucide="check-circle-2"></i> Ph&#7843;n h&#7891;i tin nh&#7855;n nhanh ch&#243;ng</li>
                    </ul>
                    <a href="${pageContext.request.contextPath}/help#buddies" class="tips-link">T&#236;m hi&#7875;u th&#234;m &rarr;</a>
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
        
        <h4 style="margin: 0 0 8px 0; font-size: 15px; color: #0f172a;">Ti&#7875;u s&#7917;</h4>
        <div class="modal-bio" id="modalBio" style="margin-bottom: 24px;">
            Bio goes here.
        </div>
        
        <h4 style="margin: 0 0 12px 0; font-size: 15px; color: #0f172a; border-bottom: 1px solid #e2e8f0; padding-bottom: 8px;">S&#7903; th&#237;ch du l&#7883;ch</h4>
        
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; font-size: 13px; color: #475569; margin-bottom: 24px;">
            <div><strong>Phong c&#225;ch:</strong> <span id="m-style" style="color: #0f172a;"></span></div>
            <div><strong>&#272;i&#7875;m &#273;&#7871;n:</strong> <span id="m-dest" style="color: #0f172a;"></span></div>
            <div><strong>Th&#7901;i gian:</strong> <span id="m-duration" style="color: #0f172a;"></span></div>
            <div><strong>T&#7847;n su&#7845;t:</strong> <span id="m-freq" style="color: #0f172a;"></span></div>
            <div><strong>H&#250;t thu&#7889;c:</strong> <span id="m-smoke" style="color: #0f172a;"></span></div>
            <div><strong>&#272;&#7891; u&#7889;ng c&#243; c&#7891;n:</strong> <span id="m-drink" style="color: #0f172a;"></span></div>
            <div style="grid-column: 1 / -1;"><strong>Ng&#244;n ng&#7919;:</strong> <span id="m-lang" style="color: #0f172a;"></span></div>
            <div style="grid-column: 1 / -1;"><strong>S&#7903; th&#237;ch (Tags):</strong> <span id="m-tags" style="color: #0f172a;"></span></div>
        </div>
        
        <button class="btn-block btn-block-light" onclick="closeProfileModal()">&#272;&#243;ng</button>
    </div>
</div>

<script>
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
        document.getElementById('modalEmail').textContent = btn.getAttribute('data-email') || 'Ch\u01b0a c\u1eadp nh\u1eadt email';
        
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

    function toggleHeart(btn, userId) {
        let favorites = JSON.parse(localStorage.getItem('buddyFavorites')) || [];
        const isFavorited = favorites.includes(userId);
        
        let icon = btn.querySelector('svg') || btn.querySelector('i');
        
        if (isFavorited) {
            favorites = favorites.filter(id => id !== userId);
            btn.style.color = '#64748b';
            if (icon) icon.style.fill = 'none';
        } else {
            favorites.push(userId);
            btn.style.color = '#ef4444';
            if (icon) icon.style.fill = '#ef4444';
        }
        
        localStorage.setItem('buddyFavorites', JSON.stringify(favorites));
        sortMatches(); // Re-sort automatically when clicking heart
    }

    document.addEventListener('DOMContentLoaded', function() {
        if (typeof lucide !== 'undefined') {
            lucide.createIcons();
        }
        
        let favorites = JSON.parse(localStorage.getItem('buddyFavorites')) || [];
        var grid = document.querySelector('.match-grid');
        if (!grid) return;
        
        var cards = Array.from(grid.querySelectorAll('.match-card'));
        
        // Restore visual heart state
        cards.forEach(function(card) {
            var id = parseInt(card.dataset.id);
            if (favorites.includes(id)) {
                var btn = card.querySelector('.btn-heart');
                if (btn) {
                    btn.style.color = '#ef4444';
                    var icon = btn.querySelector('svg') || btn.querySelector('i');
                    if (icon) icon.style.fill = '#ef4444';
                }
            }
        });
        
        sortMatches(); // Run sort on initial load
    });

    function sortMatches() {
        var sortBy = document.getElementById('matchSortSelect').value;
        var grid = document.querySelector('.match-grid');
        if (!grid) return;
        var cards = Array.from(grid.querySelectorAll('.match-card'));
        let favorites = JSON.parse(localStorage.getItem('buddyFavorites')) || [];
        
        cards.sort(function(a, b) {
            var idA = parseInt(a.dataset.id) || 0;
            var idB = parseInt(b.dataset.id) || 0;
            
            var favA = favorites.includes(idA) ? 1 : 0;
            var favB = favorites.includes(idB) ? 1 : 0;
            
            if (favA !== favB) {
                return favB - favA; // Favorites always at the top
            }
            
            if (sortBy === 'match') {
                var matchA = parseFloat(a.dataset.match) || 0;
                var matchB = parseFloat(b.dataset.match) || 0;
                return matchB - matchA; // Descending match %
            } else if (sortBy === 'newest') {
                return idB - idA; // Descending ID (newest user first)
            }
            return 0;
        });
        
        cards.forEach(function(card) {
            grid.appendChild(card);
        });
    }
</script>

<jsp:include page="/common/footer.jsp"/>

