&#65279;<%-- 
    Li&#234;n quan &#273;&#7871;n UCs: Exchange Messages, Schedule Video Calls
    T&#225;c gi&#7843;: &#272;&#7895; V&#361; Minh Ng&#7885;c
    MSSV: HE182479
--%>
&#65279;<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<jsp:include page="/common/header.jsp"/>

<style>
    body {
        background-color: #f3f4f6;
    }
    .chat-container {
        display: flex;
        height: calc(100vh - 120px); /* Adjust based on header height */
        max-width: 1200px;
        margin: 100px auto 20px auto; /* 100px top margin to clear the fixed header */
        background: #ffffff;
        border-radius: 16px;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.05);
        overflow: hidden;
        position: relative; /* For modal positioning */
    }

    /* Sidebar (Conversation List) */
    .chat-sidebar {
        width: 350px;
        border-right: 1px solid #e5e7eb;
        display: flex;
        flex-direction: column;
        background: #fdfdfd;
    }

    .chat-sidebar-header {
        padding: 20px;
        border-bottom: 1px solid #e5e7eb;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }

    .chat-sidebar-header h2 {
        font-family: 'Outfit', sans-serif;
        font-size: 1.5rem;
        margin: 0;
        color: #111827;
    }

    .search-box {
        padding: 15px 20px;
        border-bottom: 1px solid #e5e7eb;
    }

    .search-input {
        width: 100%;
        padding: 10px 15px 10px 40px;
        border-radius: 20px;
        border: 1px solid #d1d5db;
        background: #f9fafb;
        outline: none;
        transition: all 0.3s ease;
    }

    .search-input:focus {
        border-color: #3b82f6;
        background: #ffffff;
        box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
    }

    .conversation-list {
        flex: 1;
        overflow-y: auto;
    }

    .conversation-item {
        display: flex;
        padding: 15px 20px;
        align-items: center;
        cursor: pointer;
        transition: background-color 0.2s;
        border-bottom: 1px solid #f3f4f6;
    }

    .conversation-item:hover, .conversation-item.active {
        background-color: #eff6ff;
    }

    .conversation-avatar {
        width: 50px;
        height: 50px;
        border-radius: 50%;
        background: #d1d5db;
        margin-right: 15px;
        flex-shrink: 0;
        overflow: hidden;
    }

    .conversation-avatar img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .conversation-details {
        flex: 1;
        min-width: 0;
    }

    .conversation-title {
        font-weight: 600;
        color: #1f2937;
        margin-bottom: 4px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .conversation-preview {
        font-size: 0.85rem;
        color: #6b7280;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    /* Main Chat Area */
    .chat-main {
        flex: 1;
        display: flex;
        flex-direction: column;
        background: #ffffff;
    }

    .chat-main-header {
        padding: 20px;
        border-bottom: 1px solid #e5e7eb;
        display: flex;
        align-items: center;
        background: #ffffff;
    }

    .chat-main-header .avatar {
        width: 45px;
        height: 45px;
        border-radius: 50%;
        background: #d1d5db;
        margin-right: 15px;
    }

    .chat-main-header .info h3 {
        margin: 0;
        font-size: 1.2rem;
        color: #111827;
    }

    .chat-main-header .info p {
        margin: 0;
        font-size: 0.85rem;
        color: #10b981; /* Green for online */
    }

    .chat-history {
        flex: 1;
        padding: 20px;
        overflow-y: auto;
        display: flex;
        flex-direction: column;
        gap: 15px;
        background: #f9fafb;
    }

    .message {
        display: flex;
        max-width: 70%;
    }

    .message.received {
        align-self: flex-start;
    }

    .message.sent {
        align-self: flex-end;
        flex-direction: row-reverse;
    }

    .message-avatar {
        width: 35px;
        height: 35px;
        border-radius: 50%;
        margin: 0 10px;
        background: #d1d5db;
        flex-shrink: 0;
    }

    .message-content {
        padding: 12px 16px;
        border-radius: 18px;
        font-size: 0.95rem;
        line-height: 1.5;
        position: relative;
    }

    .message.received .message-content {
        background: #ffffff;
        color: #1f2937;
        border: 1px solid #e5e7eb;
        border-top-left-radius: 4px;
    }

    .message.sent .message-content {
        background: #3b82f6;
        color: #ffffff;
        border-top-right-radius: 4px;
    }

    .message-time {
        font-size: 0.75rem;
        color: #9ca3af;
        margin-top: 5px;
        text-align: right;
    }

    .message.sent .message-time {
        color: #d1d5db;
    }

    .chat-input-area {
        padding: 20px;
        border-top: 1px solid #e5e7eb;
        background: #ffffff;
        display: flex;
        align-items: center;
        gap: 15px;
    }

    .chat-input-box {
        flex: 1;
        display: flex;
        align-items: center;
        background: #f3f4f6;
        border-radius: 24px;
        padding: 5px 15px;
    }

    .chat-input-box input {
        flex: 1;
        border: none;
        background: transparent;
        padding: 10px;
        outline: none;
        font-size: 1rem;
    }

    .btn-send {
        background: #3b82f6;
        color: white;
        border: none;
        width: 45px;
        height: 45px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: background 0.2s;
    }

    .btn-send:hover {
        background: #2563eb;
    }

    .btn-icon {
        background: transparent;
        border: none;
        color: #6b7280;
        cursor: pointer;
        padding: 10px;
        border-radius: 50%;
        transition: background 0.2s, color 0.2s;
    }

    .btn-icon:hover {
        background: #e5e7eb;
        color: #374151;
    }

    .empty-state {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        height: 100%;
        color: #6b7280;
    }

    .empty-state i {
        color: #d1d5db;
        margin-bottom: 15px;
    }

    /* Scrollbar Styling */
    ::-webkit-scrollbar {
        width: 6px;
    }
    ::-webkit-scrollbar-track {
        background: transparent;
    }
    ::-webkit-scrollbar-thumb {
        background: #d1d5db;
        border-radius: 10px;
    }
    ::-webkit-scrollbar-thumb:hover {
        background: #9ca3af;
    }

    /* Modal Styles */
    .modal-overlay {
        display: none;
        position: fixed;
        top: 0; left: 0; right: 0; bottom: 0;
        background: rgba(0,0,0,0.5);
        z-index: 1000;
        align-items: center;
        justify-content: center;
    }
    .modal-overlay.active { display: flex; }
    .modal-content {
        background: white;
        padding: 30px;
        border-radius: 12px;
        width: 100%;
        max-width: 450px;
        box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);
    }
    .modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
    }
    .modal-header h3 { margin: 0; font-size: 1.25rem; color: #111827; }
    .modal-close {
        background: none; border: none; cursor: pointer; color: #6b7280;
    }
    .form-group { margin-bottom: 15px; }
    .form-group label { display: block; margin-bottom: 5px; color: #374151; font-weight: 500; font-size: 0.9rem;}
    .form-group input { width: 100%; padding: 10px; border: 1px solid #d1d5db; border-radius: 6px; }
    .btn-primary { background: #3b82f6; color: white; padding: 10px 20px; border: none; border-radius: 6px; cursor: pointer; font-weight: 500; width: 100%; }
    .btn-primary:hover { background: #2563eb; }
    .header-actions { display: flex; gap: 10px; margin-left: auto; }
</style>

<div class="chat-container">
    <!-- Thanh menu b&#234;n tr&#225;i (Sidebar) -->
    <div class="chat-sidebar">
        <div class="chat-sidebar-header">
            <h2>Tin nh&#7855;n</h2>
            <button class="btn-icon" title="T&#7841;o nh&#243;m m&#7899;i" onclick="openCreateGroupModal()">
                <i data-lucide="users"></i>
            </button>
        </div>
        <div class="search-box" style="position: relative;">
            <i data-lucide="search" style="position: absolute; left: 35px; top: 25px; width: 18px; color: #9ca3af;"></i>
            <input type="text" class="search-input" placeholder="T&#236;m ki&#7871;m cu&#7897;c tr&#242; chuy&#7879;n...">
        </div>
        <div class="conversation-list" id="conversationList">
            <c:forEach var="conv" items="${conversations}">
                <c:set var="rawTitle" value="User" />
                <c:if test="${not empty conv.title}">
                    <c:set var="rawTitle" value="${conv.title}" />
                </c:if>
                <c:choose>
                    <c:when test="${not empty conv.avatarUrl}">
                        <c:set var="convAvatarUrl" value="${conv.avatarUrl}" />
                    </c:when>
                    <c:otherwise>
                        <c:set var="convAvatarUrl" value="https://ui-avatars.com/api/?name=${fn:escapeXml(rawTitle)}&background=random" />
                    </c:otherwise>
                </c:choose>
                <div class="conversation-item" data-id="${conv.conversationId}" data-name="${fn:escapeXml(rawTitle)}" data-avatar="${fn:escapeXml(convAvatarUrl)}">
                    <div class="conversation-avatar">
                        <img src="${convAvatarUrl}" alt="Avatar">
                    </div>
                    <div class="conversation-details">
                        <div class="conversation-title">${conv.title != null ? conv.title : "Ng&#432;&#7901;i d&#249;ng &#7849;n danh"}</div>
                        <div class="conversation-preview">Nh&#7845;n &#273;&#7875; xem tin nh&#7855;n</div>
                    </div>
                </div>
            </c:forEach>
            <c:if test="${empty conversations}">
                <div style="padding: 20px; text-align: center; color: #6b7280;">Ch&#432;a c&#243; cu&#7897;c tr&#242; chuy&#7879;n n&#224;o.</div>
            </c:if>
        </div>
    </div>

    <!-- Khung chat ch&#237;nh -->
    <div class="chat-main">
        <div id="emptyChat" class="empty-state">
            <i data-lucide="message-circle" style="width: 64px; height: 64px;"></i>
            <h3>Ch&#224;o m&#7915;ng &#273;&#7871;n v&#7899;i h&#7879; th&#7889;ng tin nh&#7855;n</h3>
            <p>Ch&#7885;n m&#7897;t cu&#7897;c tr&#242; chuy&#7879;n &#273;&#7875; b&#7855;t &#273;&#7847;u.</p>
        </div>

        <div id="activeChat" style="display: none; flex-direction: column; height: 100%;">
            <div class="chat-main-header">
                <div class="avatar">
                    <img id="chatHeaderAvatar" src="https://ui-avatars.com/api/?name=User&background=random" style="width: 100%; height: 100%; border-radius: 50%;" alt="Avatar">
                </div>
                <div class="info">
                    <h3 id="chatHeaderName">T&#234;n Ng&#432;&#7901;i Nh&#7853;n</h3>
                    <p>&#272;ang ho&#7841;t &#273;&#7897;ng</p>
                </div>
                <div class="header-actions">
                    <button class="btn-icon" title="Upcoming Calls" onclick="showUpcomingCalls()">
                        <i data-lucide="calendar"></i>
                    </button>
                    <button class="btn-icon" title="Schedule Video Call" onclick="openScheduleModal()">
                        <i data-lucide="video"></i>
                    </button>
                </div>
            </div>

            <div class="chat-history" id="chatHistory">
                <!-- Tin nh&#7855;n s&#7869; &#273;&#432;&#7907;c load v&#224;o &#273;&#226;y qua JS -->
            </div>

            <div class="chat-input-area">
                <input type="file" id="chatFileInput" accept="image/*" style="display: none;">
                <button class="btn-icon" onclick="document.getElementById('chatFileInput').click()"><i data-lucide="paperclip"></i></button>
                <div class="chat-input-box">
                    <input type="text" id="messageInput" placeholder="Nh&#7853;p tin nh&#7855;n c&#7911;a b&#7841;n..." autocomplete="off">
                    <button class="btn-icon"><i data-lucide="smile"></i></button>
                </div>
                <button class="btn-send" id="btnSend" onclick="sendMessage()"><i data-lucide="send" style="width: 20px; height: 20px; margin-left: 2px;"></i></button>
            </div>
        </div>
    </div>
</div>

<!-- H&#7897;p tho&#7841;i t&#7841;o nh&#243;m chat -->
<div class="modal-overlay" id="createGroupModal">
    <div class="modal-content">
        <div class="modal-header">
            <h3>T&#7841;o Nh&#243;m Chat</h3>
            <button class="btn-icon" onclick="closeCreateGroupModal()"><i data-lucide="x"></i></button>
        </div>
        <form action="${pageContext.request.contextPath}/customer/chat" method="post" id="createGroupForm">
            <input type="hidden" name="action" value="createGroup">
            <div class="modal-body" style="max-height: 400px; overflow-y: auto;">
                <div class="form-group" style="margin-bottom: 20px;">
                    <label style="display: block; margin-bottom: 8px; font-weight: 500;">T&#234;n nh&#243;m:</label>
                    <input type="text" name="groupName" id="groupName" style="width: 100%; padding: 10px; border: 1px solid #d1d5db; border-radius: 8px;" placeholder="Nh&#7853;p t&#234;n nh&#243;m" required>
                </div>
                
                <label style="display: block; margin-bottom: 8px; font-weight: 500;">Ch&#7885;n b&#7841;n b&#232; &#273;&#7875; th&#234;m:</label>
                <div style="display: flex; flex-direction: column; gap: 10px;">
                    <c:forEach var="buddy" items="${buddies}">
                        <label style="display: flex; align-items: center; gap: 10px; cursor: pointer; padding: 10px; border: 1px solid #f3f4f6; border-radius: 8px; background: #fafafa;">
                            <input type="checkbox" name="participants" value="${buddy.userId}">
                            <img src="${not empty buddy.profile.avatarUrl ? buddy.profile.avatarUrl : 'https://ui-avatars.com/api/?name=User&background=random'}" 
                                 style="width: 40px; height: 40px; border-radius: 50%; object-fit: cover;">
                            <span style="font-weight: 500; color: #374151;">${buddy.fullName}</span>
                        </label>
                    </c:forEach>
                    <c:if test="${empty buddies}">
                        <div style="color: #6b7280; font-size: 14px;">B&#7841;n ch&#432;a c&#243; b&#7841;n b&#232; n&#224;o &#273;&#7875; t&#7841;o nh&#243;m.</div>
                    </c:if>
                </div>
            </div>
            <div class="modal-footer" style="padding: 20px; border-top: 1px solid #f3f4f6; display: flex; justify-content: flex-end; gap: 10px;">
                <button type="button" class="btn-cancel" onclick="closeCreateGroupModal()" style="padding: 10px 20px; border: none; border-radius: 8px; background: #f3f4f6; color: #374151; cursor: pointer;">H&#7911;y</button>
                <button type="button" class="btn-primary" onclick="submitCreateGroup()" style="padding: 10px 20px; border: none; border-radius: 8px; background: #2563eb; color: white; cursor: pointer; font-weight: 500;">T&#7841;o nh&#243;m</button>
            </div>
        </form>
    </div>
</div>

<!-- H&#7897;p tho&#7841;i l&#234;n l&#7883;ch g&#7885;i Video -->
<div class="modal-overlay" id="scheduleModal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="scheduleModalTitle">L&#234;n l&#7883;ch g&#7885;i Video</h3>
            <button class="modal-close" onclick="closeScheduleModal()"><i data-lucide="x"></i></button>
        </div>
        <form id="scheduleForm" onsubmit="handleScheduleSubmit(event)">
            <input type="hidden" id="callId" value="">
            <div class="form-group">
                <label>Ch&#7911; &#273;&#7873; cu&#7897;c g&#7885;i</label>
                <input type="text" id="callTitle" required placeholder="V&#237; d&#7909;: B&#224;n k&#7871; ho&#7841;ch &#273;i &#272;&#224; L&#7841;t">
            </div>
            <div class="form-group">
                <label>Th&#7901;i gian</label>
                <input type="datetime-local" id="callTime" required>
            </div>
            <div class="form-group">
                <label>Th&#7901;i l&#432;&#7907;ng (ph&#250;t)</label>
                <input type="number" id="callDuration" value="30" min="5" required>
            </div>
            <div class="form-group">
                <label>Link cu&#7897;c h&#7885;p (Google Meet/Zoom)</label>
                <input type="url" id="callUrl" required placeholder="https://meet.google.com/xxx-yyy-zzz">
            </div>
            <button type="submit" class="btn-primary" id="scheduleSubmitBtn">T&#7841;o l&#7883;ch g&#7885;i</button>
        </form>
    </div>
</div>

<!-- Upcoming Calls Modal -->
<div class="modal-overlay" id="upcomingCallsModal">
    <div class="modal-content" style="max-width: 600px;">
        <div class="modal-header">
            <h3>L&#7883;ch g&#7885;i Video s&#7855;p t&#7899;i</h3>
            <button class="modal-close" onclick="closeUpcomingCallsModal()"><i data-lucide="x"></i></button>
        </div>
        <div id="upcomingCallsList" style="max-height: 400px; overflow-y: auto;">
            <!-- Rendered by JS -->
        </div>
    </div>
</div>

<script>
    // Embedded initial configuration for chat-client.js
    const currentUserId = ${sessionScope.sessionUser.userId};
    const autoLoadConvId = ${not empty param.convId ? param.convId : 'null'};
</script>
<script src="${pageContext.request.contextPath}/js/chat-client.js?v=<%= System.currentTimeMillis() %>" charset="UTF-8"></script>

<script>
    lucide.createIcons();
    
    // Allow sending message with Enter key
    document.getElementById('messageInput').addEventListener('keypress', function (e) {
        if (e.key === 'Enter') {
            sendMessage();
        }
    });
</script>

<jsp:include page="/common/footer.jsp"/>

