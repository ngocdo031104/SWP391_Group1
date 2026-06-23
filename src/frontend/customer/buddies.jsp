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
    }
    .container {
        max-width: 1200px;
        margin: 40px auto;
        padding: 0 20px;
    }
    .grid-layout {
        display: grid;
        grid-template-columns: 1fr 1fr 1fr;
        gap: 20px;
    }
    .card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        padding: 20px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
    }
    .card h2 {
        font-family: 'Outfit', sans-serif;
        margin-top: 0;
        margin-bottom: 20px;
        font-size: 18px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .user-item {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 12px 0;
        border-bottom: 1px solid #e2e8f0;
    }
    .user-item:last-child {
        border-bottom: none;
    }
    .user-info {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .avatar {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background-color: #e2e8f0;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: bold;
        color: var(--primary-color, #4f46e5);
    }
    .name {
        font-weight: 500;
        margin: 0;
    }
    .email {
        font-size: 13px;
        color: #64748b;
        margin: 0;
    }
    .btn {
        padding: 8px 12px;
        border-radius: 6px;
        font-weight: 500;
        font-size: 13px;
        cursor: pointer;
        border: none;
        transition: background-color 0.2s;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }
    .btn-primary { background-color: var(--primary-color, #4f46e5); color: white; }
    .btn-primary:hover { background-color: #4338ca; }
    .btn-outline { background-color: transparent; border: 1px solid #e2e8f0; color: #0f172a; }
    .btn-outline:hover { background-color: #f1f5f9; }
    .btn-success { background-color: #10b981; color: white; }
    .btn-success:hover { background-color: #059669; }
    .btn-danger { background-color: #ef4444; color: white; }
    .btn-danger:hover { background-color: #dc2626; }
    .alert {
        padding: 15px;
        border-radius: 8px;
        margin-bottom: 20px;
    }
    .alert-success { background-color: #d1fae5; color: #065f46; }
    .alert-error { background-color: #fee2e2; color: #991b1b; }
    
    /* Header Override for solid background */
    #navbar {
        background-color: white !important;
        border-bottom: 1px solid #e2e8f0;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    }
    #navbar .nav-link, #navbar .logo, #navbar .btn-login-text, #navbar .notification-bell, #navbar .mobile-nav-toggle {
        color: #0f172a !important;
    }
    
    .hero-section {
        background: linear-gradient(135deg, var(--primary-color, #4f46e5), #a855f7);
        padding: 60px 20px;
        color: white;
        border-radius: 12px;
        margin-bottom: 40px;
        text-align: center;
        box-shadow: 0 10px 15px -3px rgba(79, 70, 229, 0.3);
    }
</style>

<main style="min-height: 80vh; padding-top: 120px;">
    <div class="container" style="margin-top: 0;">
        <div class="hero-section">
            <h2 style="font-family: 'Outfit', sans-serif; font-size: 36px; margin: 0 0 10px 0;">Tìm Bạn Đồng Hành Khắp Thế Giới</h2>
            <p style="font-size: 18px; opacity: 0.9; margin: 0;">Khám phá, kết nối và chia sẻ những khoảnh khắc tuyệt vời cùng cộng đồng TourBuddy.</p>
        </div>

        <c:if test="${not empty sessionScope.successMsg}">
            <div class="alert alert-success">
                ${sessionScope.successMsg}
            </div>
            <c:remove var="successMsg" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMsg}">
            <div class="alert alert-error">
                ${sessionScope.errorMsg}
            </div>
            <c:remove var="errorMsg" scope="session"/>
        </c:if>

        <div class="grid-layout">
            
            <!-- Cột 1: Gợi ý kết nối -->
            <div class="card">
                <h2><i data-lucide="sparkles"></i> Gợi ý kết nối</h2>
                <c:if test="${empty suggestedBuddies}">
                    <p style="color: #64748b; font-size: 14px; text-align: center;">Chưa có gợi ý nào mới.</p>
                </c:if>
                <c:forEach var="u" items="${suggestedBuddies}">
                    <div class="user-item">
                        <div class="user-info">
                            <div class="avatar">${u.fullName.substring(0, 1)}</div>
                            <div>
                                <p class="name">${u.fullName}</p>
                                <p class="email">Matching: TBD%</p>
                            </div>
                        </div>
                        <form action="buddies" method="POST">
                            <input type="hidden" name="action" value="send">
                            <input type="hidden" name="receiverId" value="${u.userId}">
                            <button type="submit" class="btn btn-primary"><i data-lucide="user-plus" style="width: 16px; height: 16px;"></i> Kết nối</button>
                        </form>
                    </div>
                </c:forEach>
            </div>

            <!-- Cột 2: Lời mời đã nhận -->
            <div class="card">
                <h2><i data-lucide="bell"></i> Lời mời đang chờ</h2>
                <c:if test="${empty pendingRequests}">
                    <p style="color: #64748b; font-size: 14px; text-align: center;">Bạn không có lời mời nào.</p>
                </c:if>
                <c:forEach var="req" items="${pendingRequests}">
                    <div class="user-item" style="flex-direction: column; align-items: flex-start; gap: 10px;">
                        <div class="user-info">
                            <div class="avatar">${req.sender.fullName.substring(0, 1)}</div>
                            <div>
                                <p class="name">${req.sender.fullName}</p>
                                <p class="email">Đã gửi lời mời cho bạn</p>
                            </div>
                        </div>
                        <div style="display: flex; gap: 10px; width: 100%;">
                            <form action="buddies" method="POST" style="flex: 1;">
                                <input type="hidden" name="action" value="accept">
                                <input type="hidden" name="requestId" value="${req.requestId}">
                                <button type="submit" class="btn btn-success" style="width: 100%; justify-content: center;">Chấp nhận</button>
                            </form>
                            <form action="buddies" method="POST" style="flex: 1;">
                                <input type="hidden" name="action" value="reject">
                                <input type="hidden" name="requestId" value="${req.requestId}">
                                <button type="submit" class="btn btn-outline" style="width: 100%; justify-content: center;">Từ chối</button>
                            </form>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- Cột 3: Danh sách Buddy -->
            <div class="card">
                <h2><i data-lucide="users"></i> Bạn bè (Buddies)</h2>
                <c:if test="${empty acceptedBuddies}">
                    <p style="color: #64748b; font-size: 14px; text-align: center;">Bạn chưa có buddy nào.</p>
                </c:if>
                <c:forEach var="b" items="${acceptedBuddies}">
                    <div class="user-item">
                        <div class="user-info">
                            <div class="avatar" style="background-color: var(--primary-color, #4f46e5); color: white;">
                                ${b.fullName.substring(0, 1)}
                            </div>
                            <div>
                                <p class="name">${b.fullName}</p>
                                <p class="email">${b.email}</p>
                            </div>
                        </div>
                        <button class="btn btn-outline" title="Nhắn tin (Sắp ra mắt)"><i data-lucide="message-square" style="width: 16px; height: 16px;"></i></button>
                    </div>
                </c:forEach>
            </div>

        </div>
    </div>
</main>

<script>
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }
</script>

<jsp:include page="/common/footer.jsp"/>
