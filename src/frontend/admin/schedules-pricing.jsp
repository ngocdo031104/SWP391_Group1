<%-- 
    Màn hình 21: Manage Tour Schedule and Pricing - Quản lý lịch khởi hành & giá tour
    Tác giả: Dương Quang Sơn
    MSSV: HE186525
    Ngày tạo: 2026-07-21
--%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt"  prefix="fmt" %>
<c:if test="${empty sessionUser || (sessionUser.roleId ne 1 && userRole ne 'Admin')}">
    <c:redirect url="/login" />
</c:if>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>L&#7883;ch Tr&#236;nh & Gi&#225; &#151; TourBuddy Enterprise</title>
    <!-- Outfit & Inter Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons & FontAwesome CDNs -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.3">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-schedules.css?v=1.0">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-space-overrides.css?v=1.0">
</head>
<body class="dashboard-body tb-cosmic">

<div class="dashboard-wrapper">
    <c:set var="activePage" value="schedules" scope="request" />
    <jsp:include page="sidebar.jsp" />

    <!-- -- Main Content Area -- -->
    <main class="main-content theme-light">
        <!-- Top Header -->
        <header class="top-header">
            <h1>Qu&#7843;n l&#253; L&#7883;ch tr&#236;nh & Gi&#225; Tour</h1>
            <div class="header-right">
                <div class="header-search">
                    <i data-lucide="search"></i>
                    <input type="text" placeholder="T&#236;m ki&#7871;m nhanh...">
                </div>
                
                <div class="profile-user" style="cursor: pointer;">
                    <div class="profile-meta" style="text-align: right; margin-right: 5px;">
                        <span class="name">${not empty sessionUser.fullName ? sessionUser.fullName : 'Sarah Jenkins'}</span>
                        <span class="role">Qu&#7843;n tr&#7883; vi&#234;n</span>
                    </div>
                    <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80" alt="Avatar">
                </div>
            </div>
        </header>

        <!-- Dynamic Content Tabs -->
        <div class="tabs-container">
            <button class="tab-btn active" onclick="switchTab(event, 'tab-schedules')">
                <i data-lucide="calendar-days"></i> L&#7883;ch Kh&#7903;i H&#224;nh & Gi&#225;
            </button>
            <!-- Temporarily hidden as requested
            <button class="tab-btn" onclick="switchTab(event, 'tab-coupons')">
                <i data-lucide="ticket"></i> Chu&#417;ng Tr&#236;nh Khuy&#7871;n M&#227;i (Coupons)
            </button>
            -->
        </div>

        <!-- -- TAB 1: SCHEDULES MANAGEMENT -- -->
        <section class="tab-panel active" id="tab-schedules">
            <div class="control-bar">
                <div class="selector-group">
                    <span class="control-label">Ch&#7885;n Tour:</span>
                    <select class="custom-select" id="tour-selector" onchange="loadSchedules(this.value)">
                        <option value="">-- Ch&#7885;n Tour c&#7847;n qu&#7843;n l&#253; --</option>
                        <c:forEach var="t" items="${tours}">
                            <option value="${t.tourId}" data-category-id="${t.categoryId}" data-duration="${t.durationDays}">${t.tourName}</option>
                        </c:forEach>
                    </select>
                </div>
                <button class="btn-primary" onclick="openAddScheduleModal()">
                    <i data-lucide="plus"></i> Th&#234;m L&#7883;ch Kh&#7903;i H&#224;nh
                </button>
            </div>

            <!-- Schedules Table -->
            <div class="table-responsive">
                <table class="custom-table">
                    <thead>
                        <tr>
                            <th>Ng&#224;y Kh&#7903;i H&#224;nh</th>
                            <th>Ng&#224;y V&#7870;</th>
                            <th>Gh&#7870; (Tr&#7888;ng/T&#7892;ng)</th>
                            <th>B&#7842;ng Gi&#225;</th>
                            <th>Ph&#431;&#416;ng Ti&#7878;n</th>
                            <th>Tr&#7840;ng Th&#193;i</th>
                            <th>HDV ph&#7908; tr&#225;ch</th>
                            <th>V&#7852;N H&#192;NH</th>
                            <th style="width: 100px; text-align: center;">H&#192;NH &#272;&#7896;NG</th>
                        </tr>
                    </thead>
                    <tbody id="schedules-table-body">
                        <tr>
                            <td colspan="9">
                                <div class="empty-state">
                                    <i data-lucide="compass" style="width: 48px; height: 48px;"></i>
                                    <h4>Ch&#432;a ch&#7885;n Tour</h4>
                                    <p>Vui l&#242;ng ch&#7885;n m&#7897;t tour t&#7913; danh s&#225;ch tr&#234;n &#273;&#7875; xem v&#224; qu&#7843;n l&#253; l&#7883;ch kh&#7903;i h&#224;nh.</p>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- -- TAB 2: COUPONS MANAGEMENT -- -->
        <%-- Temporarily hidden as requested
        <section class="tab-panel" id="tab-coupons">
            <div class="control-bar">
                <div class="selector-group">
                    <span class="control-label">T&#7893;ng s&#7889; m&#227; khuy&#7871;n m&#227;i:</span>
                    <span class="control-label" style="color: var(--text-light); font-weight: 600;" id="coupon-count">${coupons.size()}</span>
                </div>
                <button class="btn-primary" onclick="openAddCouponModal()">
                    <i data-lucide="plus"></i> Th&#234;m M&#227; Khuy&#7871;n M&#227;i
                </button>
            </div>

            <!-- Coupons Table -->
            <div class="table-responsive">
                <table class="custom-table">
                    <thead>
                        <tr>
                            <th>M&#227; Gi&#7843;m Gi&#225;</th>
                            <th>Lo&#7841;i Gi&#7843;m</th>
                            <th>Gi&#225; Tr&#7883;</th>
                            <th>&#272;&#417;n T&#7889;i Thi&#7875;u</th>
                            <th>L&#432;&#7907;t D&#249;ng (&#272;&#227; d&#249;ng/T&#7889;i &#272;a)</th>
                            <th>Ng&#224;y B&#7855;t &#272;&#7847;u</th>
                            <th>Ng&#224;y K&#7871;t Th&#250;c</th>
                            <th>Ho&#7841;t &#272;&#7897;ng</th>
                            <th style="width: 100px; text-align: center;">H&#192;NH &#272;&#7896;NG</th>
                        </tr>
                    </thead>
                    <tbody id="coupons-table-body">
                        <c:forEach var="c" items="${coupons}">
                            <tr id="coupon-row-${c.couponId}">
                                <td style="font-weight: 700; color: #f59e0b; font-family: monospace; font-size: 1.1rem;">${c.couponCode}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${c.discountType eq 'Percentage'}">Ph&#7847;n tr&#259;m (%)</c:when>
                                        <c:otherwise>S&#7889; ti&#7873;n c&#7889; &#272;&#7883;nh (&#8363;)</c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="font-weight: 600;">
                                    <c:choose>
                                        <c:when test="${c.discountType eq 'Percentage'}">${c.discountValue}%</c:when>
                                        <c:otherwise><fmt:formatNumber value="${c.discountValue}" pattern="#,##0" /> &#8363;</c:otherwise>
                                    </c:choose>
                                </td>
                                <td><fmt:formatNumber value="${c.minOrderAmount}" pattern="#,##0" /> &#8363;</td>
                                <td>
                                    <span style="color: var(--success-green); font-weight: 600;">${c.usedCount}</span> / 
                                    <span style="color: var(--text-gray);">${c.maxUses eq null || c.maxUses eq 0 ? 'V&#244; h&#7841;n' : c.maxUses}</span>
                                </td>
                                <td>${c.startDate}</td>
                                <td>${c.endDate}</td>
                                <td>
                                    <label class="switch">
                                        <input type="checkbox" ${c.isActive ? 'checked' : ''} onchange="toggleCouponStatus(${c.couponId}, this.checked)">
                                        <span class="slider"></span>
                                    </label>
                                </td>
                                <td style="text-align: center;">
                                    <div class="action-btn-group">
                                        <button class="btn-icon edit" title="S?a" onclick="openEditCouponModal(${c.couponId}, '${c.couponCode}', '${c.discountType}', ${c.discountValue}, ${c.minOrderAmount}, '${c.maxUses}', '${c.startDate}', '${c.endDate}', ${c.isActive})">
                                            <i data-lucide="edit-3"></i>
                                        </button>
                                        <button class="btn-icon delete" title="X&#243;a" onclick="deleteCoupon(${c.couponId})">
                                            <i data-lucide="trash-2"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty coupons}">
                            <tr>
                                <td colspan="9">
                                    <div class="empty-state">
                                        <i data-lucide="ticket" style="width: 48px; height: 48px;"></i>
                                        <h4>Ch&#432;a c&#243; m&#227; gi&#7843;m gi&#225; n&#224;o</h4>
                                        <p>Click v&#224;o "Th&#234;m M&#227; Khuy&#7871;n M&#227;i" &#7903; tr&#234;n &#273;&#7875; t&#7841;o m&#227; m&#7899;i.</p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </section>
        --%>
    </main>
</div>

<!-- -- MODAL 1: SCHEDULE FORM (ADD/EDIT) -- -->
<div class="modal-backdrop" id="schedule-modal">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 id="schedule-modal-title">Th&#234;m L&#7883;ch Kh&#7903;i H&#224;nh</h3>
            <button class="modal-close" onclick="closeModal('schedule-modal')">
                <i data-lucide="x"></i>
            </button>
        </div>
        <form id="schedule-form" onsubmit="saveSchedule(event)">
            <input type="hidden" name="action" id="schedule-action" value="addSchedule">
            <input type="hidden" name="scheduleId" id="form-schedule-id" value="">
            <input type="hidden" name="tourId" id="form-schedule-tour-id" value="">
            <div class="modal-body">
                <div class="form-grid">
                    <div class="form-group">
                        <label>Ng&#224;y Kh&#7903;i H&#224;nh *</label>
                        <input type="date" name="departureDate" id="form-schedule-dep" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>Ng&#224;y V&#7870; *</label>
                        <input type="date" name="returnDate" id="form-schedule-ret" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>T&#7893;ng S&#7889; Ch&#7895; *</label>
                        <input type="number" name="totalSeats" id="form-schedule-seats" class="form-control" min="1" required>
                    </div>
                    <div class="form-group" id="available-seats-group" style="display: none;">
                        <label>S&#7889; Gh&#7870; C&#242;n Tr&#7888;ng</label>
                        <input type="number" name="availableSeats" id="form-schedule-avai" class="form-control" min="0">
                    </div>
                    <div class="form-group">
                        <label>Ph&#431;&#416;ng Ti&#7878;n Di Chuy&#7875;n</label>
                        <input type="text" name="transportation" id="form-schedule-transport" class="form-control" placeholder="V&#237; d?: &#212; t&#244;, M&#225;y bay kh&#7913; h&#7891;i...">
                    </div>
                    <div class="form-group">
                        <label>Tr&#7840;ng Th&#193;i Nh&#7853;n Ch&#7895;</label>
                        <select name="status" id="form-schedule-status" class="form-control">
                            <option value="Open">Open (C&#242;n ch&#7895;)</option>
                            <option value="Full">Full (&#272;&#7847;y ch&#7895;)</option>
                            <option value="Closed">Closed (&#272;&#227; d&#243;ng &#273;&#259;ng k&#253;)</option>
                            <option value="Cancelled">Cancelled (&#272;&#227; h&#7911;y)</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>H&#432;&#7899;ng D&#7851;n Vi&#234;n</label>
                        <select name="guideId" id="form-schedule-guide" class="form-control">
                            <option value="0">-- Ch&#432;a ph&#226;n c&#244;ng --</option>
                            <c:forEach var="g" items="${guides}">
                                <option value="${g.userId}">
                                    <c:choose>
                                        <c:when test="${not empty g.user}">
                                            ${g.user.fullName}
                                        </c:when>
                                        <c:otherwise>
                                            Guide #${g.userId}
                                        </c:otherwise>
                                    </c:choose>
                                    (${not empty g.specialization ? g.specialization : '&#272;o&#224;n'})
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Tr&#7840;ng Th&#193;i Tour (V&#7852;N H&#192;NH)</label>
                        <select name="tourStatus" id="form-schedule-tourstatus" class="form-control">
                            <option value="Preparing">Preparing (Chu&#7843;n b&#7883;)</option>
                            <option value="Scheduled">Scheduled (L&#234;n l&#7883;ch kh&#7903;i h&#224;nh)</option>
                            <option value="InProgress">InProgress (&#272;&#259;ng &#273;i)</option>
                            <option value="Completed">Completed (&#272;&#227; ho&#224;n th&#224;nh)</option>
                            <option value="Cancelled">Cancelled (&#272;&#227; h&#7911;y &#273;o&#224;n)</option>
                        </select>
                    </div>
                    <div class="form-group form-grid-full">
                        <label>Ghi ch&#250; ph&#226;n c&#244;ng HDV (Notes)</label>
                        <textarea name="notes" id="form-schedule-notes" class="form-control" rows="2" placeholder="Nh&#7853;p ghi ch&#250; cho h&#432;&#7899;ng d&#7851;n vi&#234;n..." style="resize: vertical; min-height: 60px; font-family: inherit; font-size: 0.9rem; padding: 8px 12px;"></textarea>
                    </div>
                    
                    <div class="form-grid-full" style="border-top: 1px solid var(--border-dark); margin: 0.5rem 0; padding-top: 1rem;">
                        <span style="font-family: 'Outfit', sans-serif; font-size: 1rem; font-weight: 600; color: var(--text-light);">C&#7845;u h&#236;nh B&#7842;ng Gi&#225;:</span>
                    </div>
                    <div class="form-group">
                        <label>Gi&#225; Ng&#432;&#7901;i L&#7899;n * (&#8363;) <small style="color: var(--text-gray); font-size: 0.8rem; font-weight: normal;">(T&#7913; 12 tu&#7893;i tr&#7903; l&#234;n)</small></label>
                        <input type="number" name="priceAdult" id="form-schedule-price-adult" class="form-control" min="1" placeholder="Nh&#7853;p gi&#225; ng&#432;&#7901;i l&#7899;n (* > 0)" required>
                    </div>
                    <div class="form-group">
                        <label>Gi&#225; Tr&#7867; Em (&#8363;) <small style="color: var(--text-gray); font-size: 0.8rem; font-weight: normal;">(T&#7913; 2 &#273;&#7871;n 11 tu&#7893;i)</small></label>
                        <input type="number" name="priceChild" id="form-schedule-price-child" class="form-control" min="0" placeholder="&#272;&#7875; tr&#7889;ng n&#7871;u kh&#244;ng &#225;p d&#7909;ng">
                    </div>
                    <div class="form-group">
                        <label>Gi&#225; Tr&#7867; S&#417; Sinh (&#8363;) <small style="color: var(--text-gray); font-size: 0.8rem; font-weight: normal;">(D&#432;&#7899;i 2 tu&#7893;i)</small></label>
                        <input type="number" name="priceInfant" id="form-schedule-price-infant" class="form-control" min="0" placeholder="&#272;&#7875; tr&#7889;ng n&#7871;u kh&#244;ng cho tr&#7867; s&#417; sinh &#273;i">
                        <span id="infant-warning" style="display: none; color: var(--error-red); font-size: 0.8rem; margin-top: 0.25rem; font-weight: 500;">
                            <i class="fa-solid fa-triangle-exclamation"></i> Tour m&#7841;o hi&#7875;m - Kh&#244;ng cho ph&#233;p Tr&#7867; s&#417; sinh tham gia.
                        </span>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-secondary" onclick="closeModal('schedule-modal')">H&#7911;y b&#7887;</button>
                <button type="submit" class="btn-primary">L&#432;u L&#7883;ch Tr&#236;nh</button>
            </div>
        </form>
    </div>
</div>

<!-- -- MODAL 2: COUPON FORM (ADD/EDIT) -- -->
<%-- Temporarily hidden as requested
<div class="modal-backdrop" id="coupon-modal">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 id="coupon-modal-title">Th&#234;m M&#227; Khuy&#7871;n M&#227;i</h3>
            <button class="modal-close" onclick="closeModal('coupon-modal')">
                <i data-lucide="x"></i>
            </button>
        </div>
        <form id="coupon-form" onsubmit="saveCoupon(event)">
            <input type="hidden" name="action" id="coupon-action" value="addCoupon">
            <input type="hidden" name="couponId" id="form-coupon-id" value="">
            <div class="modal-body">
                <div class="form-grid">
                    <div class="form-group">
                        <label>M&#227; Gi&#7843;m Gi&#225; *</label>
                        <input type="text" name="couponCode" id="form-coupon-code" class="form-control" placeholder="VD: FLASH20, TOURBUDDY" required style="text-transform: uppercase;">
                    </div>
                    <div class="form-group">
                        <label>Lo&#7841;i Gi&#7843;m Gi&#225;</label>
                        <select name="discountType" id="form-coupon-type" class="form-control" onchange="adjustDiscountInput(this.value)">
                            <option value="Percentage">Gi&#7843;m theo Ph&#7847;n Tr&#259;m (%)</option>
                            <option value="FixedAmount">Gi&#7843;m S&#7889; Ti&#7873;n C&#7889; &#272;&#7883;nh (&#8363;)</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label id="label-discount-value">Gi&#225; tr&#7883; gi&#7843;m * (%)</label>
                        <input type="number" name="discountValue" id="form-coupon-value" class="form-control" min="0.01" step="any" required>
                    </div>
                    <div class="form-group">
                        <label>&#272;&#417;n H&#224;ng T&#7889;i Thi&#7875;u (&#8363;)</label>
                        <input type="number" name="minOrderAmount" id="form-coupon-minorder" class="form-control" min="0" value="0">
                    </div>
                    <div class="form-group">
                        <label>S&#7889; L&#432;&#7907;t S&#7917; D&#7921;ng T&#7889;i &#272;a</label>
                        <input type="number" name="maxUses" id="form-coupon-maxuses" class="form-control" min="1" placeholder="V&#244; h&#7841;n n&#7871;u b&#7883; tr&#7888;ng">
                    </div>
                    <div class="form-group">
                        <label>Tr&#7840;ng Th&#193;i Ho&#7841;t &#272;&#7897;ng</label>
                        <select name="isActive" id="form-coupon-status" class="form-control">
                            <option value="true">Active (K&#237;ch ho&#7841;t)</option>
                            <option value="false">Inactive (V&#244; hi&#7875;u h&#243;a)</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Ng&#224;y B&#7855;t &#272;&#7847;u *</label>
                        <input type="date" name="startDate" id="form-coupon-start" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>Ng&#224;y K&#7871;t Th&#250;c *</label>
                        <input type="date" name="endDate" id="form-coupon-end" class="form-control" required>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-secondary" onclick="closeModal('coupon-modal')">H&#7911;y b&#7887;</button>
                <button type="submit" class="btn-primary">L&#432;u Khuy&#7871;n M&#227;i</button>
            </div>
        </form>
    </div>
</div>
--%>

<!-- JS Controller Logic -->
<script>
    // Kh?i t?o Lucide Icons khi t?i trang
    document.addEventListener("DOMContentLoaded", function() {
        lucide.createIcons();
    });

    // Chuy?n Tab
    function switchTab(evt, tabId) {
        document.querySelectorAll(".tab-btn").forEach(btn => btn.classList.remove("active"));
        document.querySelectorAll(".tab-panel").forEach(panel => panel.classList.remove("active"));

        evt.currentTarget.classList.add("active");
        document.getElementById(tabId).classList.add("active");
    }

    // \u00d0\u00f3ng/M? Modal
    function openModal(modalId) {
        document.getElementById(modalId).classList.add("open");
    }
    function closeModal(modalId) {
        document.getElementById(modalId).classList.remove("open");
    }

    // \u00d0?nh d?ng s? th\u00e0nh VND
    function formatVND(amount) {
        return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
    }

    // -- LOGIC L?CH TR\u00ccNH --
    function loadSchedules(tourId) {
        const tbody = document.getElementById("schedules-table-body");
        if (!tourId) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="9">
                        <div class="empty-state">
                            <i data-lucide="compass" style="width: 48px; height: 48px;"></i>
                            <h4>Ch&#432;a ch&#7885;n Tour</h4>
                            <p>Vui l&#242;ng ch&#7885;n m&#7897;t tour t&#7913; danh s&#225;ch tr&#234;n &#273;&#7875; xem v&#224; qu&#7843;n l&#253; l&#7883;ch kh&#7903;i h&#224;nh.</p>
                        </div>
                    </td>
                </tr>`;
            lucide.createIcons();
            return;
        }

        tbody.innerHTML = `
            <tr>
                <td colspan="9" style="text-align: center; padding: 3rem 0;">
                    <div style="display:inline-flex; align-items:center; gap: 10px; color: var(--text-gray);">
                        <i class="fa-solid fa-circle-notch fa-spin fa-lg" style="color: #8b5cf6;"></i>
                        <span>&#272;&#259;ng t&#7843;i l&#7883;ch tr&#236;nh kh&#7903;i h&#224;nh...</span>
                    </div>
                </td>
            </tr>`;

        fetch(`?ajax=true&action=getSchedules&tourId=\${tourId}`)
            .then(res => res.json())
            .then(schedules => {
                if (schedules.length === 0) {
                    tbody.innerHTML = `
                        <tr>
                            <td colspan="9">
                                <div class="empty-state">
                                    <i data-lucide="calendar-x" style="width: 48px; height: 48px;"></i>
                                    <h4>Ch&#432;a c&#243; l&#7883;ch tr&#236;nh</h4>
                                    <p>Tour n&#224;y hi&#7875;n t&#7841;i ch&#432;a &#273;&#432;&#7901;c l&#234;n l&#7883;ch kh&#7903;i h&#224;nh n&#224;o. Click "Th&#234;m L&#7883;ch Kh&#7903;i H&#224;nh" &#273;&#7875; t&#7841;o m&#227; m&#7899;i.</p>
                                </div>
                            </td>
                        </tr>`;
                    lucide.createIcons();
                    return;
                }

                let html = '';
                schedules.forEach(s => {
                    let badgeClass = 'badge-closed';
                    if (s.status === 'Open') badgeClass = 'badge-open';
                    else if (s.status === 'Full') badgeClass = 'badge-full';
                    else if (s.status === 'Cancelled') badgeClass = 'badge-cancelled';

                    let opBadgeClass = 'badge-op-preparing';
                    let opText = 'Chu&#7843;n b&#7883;';
                    if (s.tourStatus === 'Scheduled') { opBadgeClass = 'badge-op-scheduled'; opText = 'L&#234;n l&#7883;ch'; }
                    else if (s.tourStatus === 'InProgress') { opBadgeClass = 'badge-op-progress'; opText = '&#272;&#259;ng &#273;i'; }
                    else if (s.tourStatus === 'Completed') { opBadgeClass = 'badge-op-completed'; opText = 'Ho&#224;n th&#224;nh'; }
                    else if (s.tourStatus === 'Cancelled') { opBadgeClass = 'badge-cancelled'; opText = 'H&#7911;y &#273;o&#224;n'; }

                    html += `
                        <tr id="schedule-row-\${s.scheduleId}">
                            <td style="font-weight: 600;">\${s.departureStr}</td>
                            <td style="color: var(--text-gray);">\${s.returnStr}</td>
                            <td>
                                <strong style="color: var(--text-light);">\${s.availableSeats}</strong>
                                <span style="color: var(--text-muted);">/ \${s.totalSeats}</span>
                            </td>
                            <td>
                                <div class="price-tag-group">
                                    <div class="price-row">
                                        <span class="price-type">L?n:</span>
                                        <span class="price-amount">\${formatVND(s.priceAdult)}</span>
                                    </div>
                                    <div class="price-row">
                                        <span class="price-type">Tr? em:</span>
                                        <span class="price-amount">\${formatVND(s.priceChild)}</span>
                                    </div>
                                    <div class="price-row">
                                        <span class="price-type">So sinh:</span>
                                        <span class="price-amount">\${formatVND(s.priceInfant)}</span>
                                    </div>
                                </div>
                            </td>
                            <td>\${s.transportation || 'Chua r\u00f5'}</td>
                            <td>
                                <span class="badge \${badgeClass}">\${s.status}</span>
                            </td>
                            <td style="font-weight: 500;">\${s.guideName}</td>
                            <td>
                                <span class="badge \${opBadgeClass}">\${opText}</span>
                            </td>
                            <td style="text-align: center;">
                                <div class="action-btn-group">
                                    <button class="btn-icon edit" title="S?a" onclick="openEditScheduleModal(\${JSON.stringify(s).replace(/"/g, '&quot;')})">
                                        <i data-lucide="edit-3"></i>
                                    </button>
                                    <button class="btn-icon delete" title="X\u00f3a" onclick="deleteSchedule(\${s.scheduleId}, '\${s.tourStatus}')">
                                        <i data-lucide="trash-2"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>`;
                });
                tbody.innerHTML = html;
                lucide.createIcons();
            })
            .catch(err => {
                console.error(err);
                tbody.innerHTML = `
                    <tr>
                        <td colspan="9" style="text-align: center; color: var(--error-red); padding: 2rem;">
                            C&#243; l&#7895;i khi t&#7843;i danh s&#225;ch l&#7883;ch kh&#7903;i h&#224;nh. Vui l&#242;ng th&#7917; l&#7841;i.
                        </td>
                    </tr>`;
            });
    }

    function checkInfantRestriction() {
        const selector = document.getElementById("tour-selector");
        if (!selector) return;
        const selectedOpt = selector.options[selector.selectedIndex];
        if (!selectedOpt) return;
        const catId = parseInt(selectedOpt.getAttribute("data-category-id")) || 0;
        
        const infantInput = document.getElementById("form-schedule-price-infant");
        const infantWarning = document.getElementById("infant-warning");
        
        if (catId === 1 || catId === 2) {
            // Tour m&#7841;o hi&#7875;m: Reset v&#7873; 0, kh&#243;a ch&#7881;nh s&#7917;a b&#7855;ng readonly, l&#224;m m&#7901;
            infantInput.value = 0;
            infantInput.readOnly = true;
            infantInput.style.opacity = "0.5";
            infantInput.style.pointerEvents = "none";
            if (infantWarning) infantWarning.style.display = "block";
        } else {
            // Tour b&#236;nh th&#432;&#7901;ng: M&#7903; kh&#243;a
            infantInput.readOnly = false;
            infantInput.style.opacity = "1";
            infantInput.style.pointerEvents = "auto";
            if (infantWarning) infantWarning.style.display = "none";
        }
    }

    function openAddScheduleModal() {
        const tourId = document.getElementById("tour-selector").value;
        if (!tourId) {
            alert("Vui l&#242;ng ch&#7885;n m&#7897;t Tour tr&#432;&#7899;c khi th&#234;m l&#7883;ch kh&#7903;i h&#224;nh!");
            return;
        }

        document.getElementById("schedule-form").reset();
        document.getElementById("schedule-modal-title").innerText = "Th&#234;m L&#7883;ch Kh&#7903;i H&#224;nh";
        document.getElementById("schedule-action").value = "addSchedule";
        document.getElementById("form-schedule-id").value = "";
        document.getElementById("form-schedule-tour-id").value = tourId;
        document.getElementById("form-schedule-price-adult").value = "";
        document.getElementById("form-schedule-price-child").value = "";
        document.getElementById("form-schedule-price-infant").value = "";
        document.getElementById("available-seats-group").style.display = "none";
        
        // Kiểm tra ràng buộc trẻ sơ sinh đối với tour mạo hiểm
        checkInfantRestriction();
        
        openModal("schedule-modal");
    }

    // Nh&#7853;n chu&#7895;i JSON c&#7911;a schedule &#273;&#7875; &#273;i&#7875;n v&#224;o form khi Edit
    function openEditScheduleModal(s) {
        document.getElementById("schedule-modal-title").innerText = "S&#7917;a L&#7883;ch Kh&#7903;i H&#224;nh";
        document.getElementById("schedule-action").value = "editSchedule";
        document.getElementById("form-schedule-id").value = s.scheduleId;
        document.getElementById("form-schedule-tour-id").value = s.tourId;
        
        document.getElementById("form-schedule-dep").value = s.departureStr;
        document.getElementById("form-schedule-ret").value = s.returnStr;
        document.getElementById("form-schedule-seats").value = s.totalSeats;
        
        // Hi&#7875;n s&#7889; ch&#7895; tr&#7888;ng &#273;&#7875; ch&#7881;nh s&#7917;a
        document.getElementById("available-seats-group").style.display = "flex";
        document.getElementById("form-schedule-avai").value = s.availableSeats;
        
        document.getElementById("form-schedule-transport").value = s.transportation || "";
        document.getElementById("form-schedule-status").value = s.status;
        document.getElementById("form-schedule-guide").value = s.guideId || "0";
        document.getElementById("form-schedule-tourstatus").value = s.tourStatus || "Preparing";
        
        document.getElementById("form-schedule-price-adult").value = (s.priceAdult && s.priceAdult > 0) ? s.priceAdult : "";
        document.getElementById("form-schedule-price-child").value = (s.priceChild && s.priceChild > 0) ? s.priceChild : "";
        document.getElementById("form-schedule-price-infant").value = (s.priceInfant && s.priceInfant > 0) ? s.priceInfant : "";
        document.getElementById("form-schedule-notes").value = s.notes || "";

        // Kiểm tra ràng buộc trẻ sơ sinh đối với tour mạo hiểm
        checkInfantRestriction();

        openModal("schedule-modal");
    }

    function saveSchedule(e) {
        e.preventDefault();
        const form = document.getElementById("schedule-form");
        
        // -- CLIENT-SIDE VALIDATIONS --
        const action = document.getElementById("schedule-action").value;
        const depVal = document.getElementById("form-schedule-dep").value;
        const retVal = document.getElementById("form-schedule-ret").value;
        const totalSeats = parseInt(document.getElementById("form-schedule-seats").value) || 0;
        const priceAdultRaw = document.getElementById("form-schedule-price-adult").value.trim();
        const priceChildRaw = document.getElementById("form-schedule-price-child").value.trim();
        const priceInfantRaw = document.getElementById("form-schedule-price-infant").value.trim();

        if (!depVal || !retVal) {
            alert("Vui l&#242;ng ch&#7885;n &#273;&#7847;y &#273;&#7911; ng&#224;y kh&#7903;i h&#224;nh v&#224; ng&#224;y v&#7870;!");
            return;
        }

        const depDate = new Date(depVal);
        const retDate = new Date(retVal);
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        depDate.setHours(0, 0, 0, 0);
        retDate.setHours(0, 0, 0, 0);

        // 1. Kh&#244;ng cho ph&#233;p ng&#224;y kh&#7903;i h&#224;nh &#7903; qu&#225; kh&#7913; khi th&#234;m m&#7899;i
        if (action === "addSchedule" && depDate < today) {
            alert("Ng&#224;y kh&#7903;i h&#224;nh kh&#244;ng &#273;&#432;&#7901;c &#7903; qu&#225; kh&#7913;!");
            return;
        }

        // 2. Ng&#224;y v&#7870; kh&#244;ng &#273;&#432;&#7901;c tr&#432;&#7899;c ng&#224;y kh&#7903;i h&#224;nh
        if (retDate < depDate) {
            alert("Ng&#224;y v&#7870; kh&#244;ng &#273;&#432;&#7901;c tr&#432;&#7899;c ng&#224;y kh&#7903;i h&#224;nh!");
            return;
        }

        // 3. Tour kh&#244;ng &#273;&#432;&#7901;c k&#233;o d&#224;i qu&#225; l&#222;u (ch&#234;nh l&#7883;ch ng&#224;y kh&#244;ng v&#432;&#7907;t qu&#225; th&#7901;i l&#432;&#7907;t tour)
        const selector = document.getElementById("tour-selector");
        const selectedOpt = selector.options[selector.selectedIndex];
        const duration = parseInt(selectedOpt.getAttribute("data-duration")) || 1;
        
        const timeDiff = Math.abs(retDate.getTime() - depDate.getTime());
        const diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24)) + 1; // S&#7889; ng&#224;y th&#7921;c t&#7871; di
        
        if (diffDays > duration) {
            alert("L&#7883;ch tr&#236;nh k&#233;o d&#224;i qu&#225; l&#222;u (" + diffDays + " ng&#224;y). Th&#7901;i l&#432;&#7907;t c&#7911;a tour n&#224;y &#273;&#432;&#7901;c c&#7845;u h&#236;nh t&#7889;i &#272;a l&#224; " + duration + " ng&#224;y!");
            return;
        }

        // 3.5. Ki&#7875;m tra s&#7889; gh&#7870; c&#242;n tr&#7888;ng kh&#244;ng &#273;&#432;&#7901;c l&#7899;n h&#417;n t&#7893;ng s&#7889; ch&#7895; (ch&#7881; khi s&#7917;a l&#7883;ch tr&#236;nh)
        if (action === "editSchedule") {
            const avaiSeats = parseInt(document.getElementById("form-schedule-avai").value) || 0;
            if (avaiSeats > totalSeats) {
                alert("S&#7889; gh&#7870; c&#242;n tr&#7888;ng (" + avaiSeats + ") kh&#244;ng &#273;&#432;&#7901;c l&#7899;n h&#417;n t&#7893;ng s&#7889; ch&#7895; (" + totalSeats + ")!");
                return;
            }
        }

        if (!priceAdultRaw || parseFloat(priceAdultRaw) <= 0) {
            alert("Gi&#225; ng&#432;&#7901;i l&#7899;n b&#785f;t bu&#7897;c ph&#7843;i l&#7899;n h&#417;n 0!");
            return;
        }
        if ((priceChildRaw !== "" && parseFloat(priceChildRaw) < 0) || (priceInfantRaw !== "" && parseFloat(priceInfantRaw) < 0)) {
            alert("Gi&#225; v&#233; c&#7845;u h&#236;nh kh&#244;ng &#273;&#432;&#7901;c l&#224; s&#7889; &#226;m!");
            return;
        }

        const priceInfant = priceInfantRaw !== "" ? parseFloat(priceInfantRaw) : 0;

        // 4. Kh&#243;a/ch&#7885;n gi&#225; tr&#7883; s&#417; sinh &#273;&#7889;i v&#7899;i c&#225;c tour m&#7841;o hi&#7875;m (Bi&#7875;n/N&#250;i)
        const catId = parseInt(selectedOpt.getAttribute("data-category-id")) || 0;
        if ((catId === 1 || catId === 2) && priceInfantRaw !== "" && priceInfant > 0) {
            alert("Tour thu&#7897;c danh m&#7909;c m&#7841;o hi&#7875;m (Bi&#7875;n & &#272;&#7843;o / N&#250;i & R&#7915;ng), kh&#244;ng cho ph&#233;p tr&#7867; s&#417; sinh tham gia!");
            return;
        }

        if (totalSeats <= 0) {
            alert("T&#7893;ng s&#7889; ch&#7895; ph&#7843;i l&#7899;n h&#417;n 0!");
            return;
        }

        const formData = new FormData(form);
        const params = new URLSearchParams(formData);

        fetch("", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: params.toString()
        })
        .then(res => res.json())
        .then(res => {
            if (res.status === "success") {
                alert(res.message);
                closeModal("schedule-modal");
                loadSchedules(document.getElementById("tour-selector").value);
            } else {
                alert(res.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert("C&#243; l&#7895;i k&#7871;t n&#7889;i h&#7879; th&#7889;ng.");
        });
    }

    function deleteSchedule(scheduleId, tourStatus) {
        if (tourStatus && tourStatus !== 'Preparing' && tourStatus !== 'Completed' && tourStatus !== 'Cancelled') {
            let statusText = tourStatus;
            if (tourStatus === 'Scheduled') statusText = 'Scheduled (L&#234;n l&#7883;ch kh&#7903;i h&#224;nh)';
            else if (tourStatus === 'InProgress') statusText = 'InProgress (&#272;&#259;ng &#273;i)';
            alert("Kh&#244;ng th&#7875; x&#243;a l&#7883;ch kh&#7903;i h&#224;nh &#272;&#259;ng &#7903; tr&#7840;ng th&#193;i '" + statusText + "'. Ch&#7881; cho ph&#233;p x&#243;a khi &#7903; tr&#7840;ng th&#193;i Chu&#7843;n b&#7883;, Ho&#224;n th&#224;nh ho&#7863;c H&#7911;y &#273;o&#224;n.");
            return;
        }

        if (!confirm("B&#7841;n c&#243; ch&#7855;c ch&#7855;n mu&#7889;n x&#243;a l&#7883;ch kh&#7903;i h&#224;nh n&#224;y? H&#224;nh &#272;&#7896;NG n&#224;y kh&#244;ng th&#7875; ho&#224;n t&#225;c.")) {
            return;
        }

        fetch("", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: `action=deleteSchedule&scheduleId=\${scheduleId}`
        })
        .then(res => res.json())
        .then(res => {
            if (res.status === "success") {
                alert(res.message);
                loadSchedules(document.getElementById("tour-selector").value);
            } else {
                alert(res.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert("C&#243; l&#7895;i x&#7843;y ra khi g&#7917;i y&#234;u c&#7847;u.");
        });
    }

    // -- LOGIC M\u00c3 GI?M GI\u00c1 (COUPONS) --
    function adjustDiscountInput(type) {
        const label = document.getElementById("label-discount-value");
        if (type === "Percentage") {
            label.innerText = "Gi&#225; tr&#7883; gi&#7843;m * (%)";
        } else {
            label.innerText = "Gi&#225; tr&#7883; gi&#7843;m * (&#8363;)";
        }
    }

    function openAddCouponModal() {
        document.getElementById("coupon-form").reset();
        document.getElementById("coupon-modal-title").innerText = "Th&#234;m M&#227; Khuy&#7871;n M&#227;i";
        document.getElementById("coupon-action").value = "addCoupon";
        document.getElementById("form-coupon-id").value = "";
        adjustDiscountInput("Percentage");
        openModal("coupon-modal");
    }

    function openEditCouponModal(id, code, type, value, minOrder, maxUses, start, end, isActive) {
        document.getElementById("coupon-modal-title").innerText = "S&#7917;a M&#227; Khuy&#7871;n M&#227;i";
        document.getElementById("coupon-action").value = "editCoupon";
        document.getElementById("form-coupon-id").value = id;
        document.getElementById("form-coupon-code").value = code;
        document.getElementById("form-coupon-type").value = type;
        adjustDiscountInput(type);
        document.getElementById("form-coupon-value").value = value;
        document.getElementById("form-coupon-minorder").value = minOrder;
        document.getElementById("form-coupon-maxuses").value = (maxUses === "null" || maxUses === "") ? "" : maxUses;
        document.getElementById("form-coupon-start").value = start;
        document.getElementById("form-coupon-end").value = end;
        document.getElementById("form-coupon-status").value = isActive ? "true" : "false";

        openModal("coupon-modal");
    }

    function saveCoupon(e) {
        e.preventDefault();
        const form = document.getElementById("coupon-form");
        const formData = new FormData(form);
        const params = new URLSearchParams(formData);

        fetch("", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: params.toString()
        })
        .then(res => res.json())
        .then(res => {
            if (res.status === "success") {
                alert(res.message);
                closeModal("coupon-modal");
                location.reload(); // T&#7843;i l&#7841;i trang &#273;&#7875; c&#7853;p nh&#7853;t danh s&#225;ch
            } else {
                alert(res.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert("C&#243; l&#7895;i k&#7871;t n&#7889;i h&#7879; th&#7889;ng.");
        });
    }

    function toggleCouponStatus(couponId, isChecked) {
        fetch("", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: `action=toggleCouponStatus&couponId=\${couponId}&isActive=\${isChecked}`
        })
        .then(res => res.json())
        .then(res => {
            if (res.status !== "success") {
                alert(res.message);
                location.reload();
            }
        })
        .catch(err => {
            console.error(err);
            alert("L&#7895;i k&#7871;t n&#7889;i khi thay &#273;&#7893;i tr&#7840;ng th&#193;i m&#227; gi&#7843;m gi&#225;.");
            location.reload();
        });
    }

    function deleteCoupon(couponId) {
        if (!confirm("B&#7841;n c&#243; ch&#7855;c ch&#7855;n mu&#7889;n x&#243;a m&#227; gi&#7843;m gi&#225; n&#224;o?")) {
            return;
        }

        fetch("", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: `action=deleteCoupon&couponId=\${couponId}`
        })
        .then(res => res.json())
        .then(res => {
            if (res.status === "success") {
                alert(res.message);
                const row = document.getElementById(`coupon-row-\${couponId}`);
                if (row) row.remove();
                
                // C?p nh?t d?m
                const cnt = document.getElementById("coupon-count");
                if (cnt) cnt.innerText = parseInt(cnt.innerText) - 1;
            } else {
                alert(res.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert("C&#243; l&#7895;i x&#7843;y ra khi x&#243;a m&#227; gi&#7843;m gi&#225;.");
        });
    }
</script>
</body>
</html>
