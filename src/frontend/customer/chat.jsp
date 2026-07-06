<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<jsp:include page="/common/header.jsp"/>

<style>
    body {
        background-color: #f3f4f6;
    }
    .chat-container {
        display: flex;
        height: calc(100vh - 80px); /* Adjust based on header height */
        max-width: 1200px;
        margin: 20px auto;
        background: #ffffff;
        border-radius: 16px;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.05);
        overflow: hidden;
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
</style>

<div class="chat-container">
    <!-- Sidebar -->
    <div class="chat-sidebar">
        <div class="chat-sidebar-header">
            <h2>Tin nhắn</h2>
            <button class="btn-icon" title="Tin nhắn mới">
                <i data-lucide="edit"></i>
            </button>
        </div>
        <div class="search-box" style="position: relative;">
            <i data-lucide="search" style="position: absolute; left: 35px; top: 25px; width: 18px; color: #9ca3af;"></i>
            <input type="text" class="search-input" placeholder="Tìm kiếm cuộc trò chuyện...">
        </div>
        <div class="conversation-list" id="conversationList">
            <c:forEach var="conv" items="${conversations}">
                <div class="conversation-item" data-id="${conv.conversationId}" onclick="loadConversation(${conv.conversationId}, 'Tên Người Dùng')">
                    <div class="conversation-avatar">
                        <!-- Placeholder avatar -->
                        <img src="https://ui-avatars.com/api/?name=${conv.title != null ? conv.title : 'User'}&background=random" alt="Avatar">
                    </div>
                    <div class="conversation-details">
                        <div class="conversation-title">${conv.title != null ? conv.title : "Người dùng ẩn danh"}</div>
                        <div class="conversation-preview">Nhấn để xem tin nhắn</div>
                    </div>
                </div>
            </c:forEach>
            <c:if test="${empty conversations}">
                <div style="padding: 20px; text-align: center; color: #6b7280;">Chưa có cuộc trò chuyện nào.</div>
            </c:if>
        </div>
    </div>

    <!-- Main Chat -->
    <div class="chat-main">
        <div id="emptyChat" class="empty-state">
            <i data-lucide="message-circle" style="width: 64px; height: 64px;"></i>
            <h3>Chào mừng đến với hệ thống tin nhắn</h3>
            <p>Chọn một cuộc trò chuyện để bắt đầu.</p>
        </div>

        <div id="activeChat" style="display: none; flex-direction: column; height: 100%;">
            <div class="chat-main-header">
                <div class="avatar">
                    <img id="chatHeaderAvatar" src="https://ui-avatars.com/api/?name=User&background=random" style="width: 100%; height: 100%; border-radius: 50%;" alt="Avatar">
                </div>
                <div class="info">
                    <h3 id="chatHeaderName">Tên Người Nhận</h3>
                    <p>Đang hoạt động</p>
                </div>
            </div>

            <div class="chat-history" id="chatHistory">
                <!-- Messages will be injected here via JS -->
            </div>

            <div class="chat-input-area">
                <button class="btn-icon"><i data-lucide="paperclip"></i></button>
                <div class="chat-input-box">
                    <input type="text" id="messageInput" placeholder="Nhập tin nhắn của bạn..." autocomplete="off">
                    <button class="btn-icon"><i data-lucide="smile"></i></button>
                </div>
                <button class="btn-send" id="btnSend" onclick="sendMessage()"><i data-lucide="send" style="width: 20px; height: 20px; margin-left: 2px;"></i></button>
            </div>
        </div>
    </div>
</div>

<script>
    // Embedded initial configuration for chat-client.js
    const currentUserId = ${sessionScope.sessionUser.userId};
    const autoLoadConvId = ${not empty param.convId ? param.convId : 'null'};
</script>
<script src="${pageContext.request.contextPath}/js/chat-client.js"></script>

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
