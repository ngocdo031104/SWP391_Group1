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
    <title>L?ch Trình & Giá — TourBuddy Enterprise</title>
    <!-- Outfit & Inter Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons & FontAwesome CDNs -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.1">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-schedules.css?v=1.0">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-space-overrides.css?v=1.0">
</head>
<body class="dashboard-body tb-cosmic">

<div class="dashboard-wrapper">
    <c:set var="activePage" value="schedules" scope="request" />
    <jsp:include page="sidebar.jsp" />

    <!-- -- Main Content Area -- -->
    <main class="main-content">
        <!-- Top Header -->
        <header class="top-header">
            <h1>Qu?n lý L?ch trình & Giá Tour</h1>
            <div class="header-right">
                <div class="header-search">
                    <i data-lucide="search"></i>
                    <input type="text" placeholder="Tìm ki?m nhanh...">
                </div>
                
                <div class="profile-user" style="cursor: pointer;">
                    <div class="profile-meta" style="text-align: right; margin-right: 5px;">
                        <span class="name">${not empty sessionUser.fullName ? sessionUser.fullName : 'Sarah Jenkins'}</span>
                        <span class="role">Qu?n tr? viên</span>
                    </div>
                    <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80" alt="Avatar">
                </div>
            </div>
        </header>

        <!-- Dynamic Content Tabs -->
        <div class="tabs-container">
            <button class="tab-btn active" onclick="switchTab(event, 'tab-schedules')">
                <i data-lucide="calendar-days"></i> L?ch Kh?i Hành & Giá
            </button>
            <!-- Temporarily hidden as requested
            <button class="tab-btn" onclick="switchTab(event, 'tab-coupons')">
                <i data-lucide="ticket"></i> Chuong Trình Khuy?n Mãi (Coupons)
            </button>
            -->
        </div>

        <!-- -- TAB 1: SCHEDULES MANAGEMENT -- -->
        <section class="tab-panel active" id="tab-schedules">
            <div class="control-bar">
                <div class="selector-group">
                    <span class="control-label">Ch?n Tour:</span>
                    <select class="custom-select" id="tour-selector" onchange="loadSchedules(this.value)">
                        <option value="">-- Ch?n Tour c?n qu?n lý --</option>
                        <c:forEach var="t" items="${tours}">
                            <option value="${t.tourId}" data-category-id="${t.categoryId}" data-duration="${t.durationDays}">${t.tourName}</option>
                        </c:forEach>
                    </select>
                </div>
                <button class="btn-primary" onclick="openAddScheduleModal()">
                    <i data-lucide="plus"></i> Thêm L?ch Kh?i Hành
                </button>
            </div>

            <!-- Schedules Table -->
            <div class="table-responsive">
                <table class="custom-table">
                    <thead>
                        <tr>
                            <th>Ngày Kh?i Hành</th>
                            <th>Ngày V?</th>
                            <th>Gh? (Tr?ng/T?ng)</th>
                            <th>B?ng Giá</th>
                            <th>Phuong Ti?n</th>
                            <th>Tr?ng Thái</th>
                            <th>HDV ph? trách</th>
                            <th>V?n Hành</th>
                            <th style="width: 100px; text-align: center;">Hành Ð?ng</th>
                        </tr>
                    </thead>
                    <tbody id="schedules-table-body">
                        <tr>
                            <td colspan="9">
                                <div class="empty-state">
                                    <i data-lucide="compass" style="width: 48px; height: 48px;"></i>
                                    <h4>Chua ch?n Tour</h4>
                                    <p>Vui lòng ch?n m?t tour t? danh sách trên d? xem và qu?n lý l?ch kh?i hành.</p>
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
                    <span class="control-label">T?ng s? mã khuy?n mãi:</span>
                    <span class="control-label" style="color: var(--text-light); font-weight: 600;" id="coupon-count">${coupons.size()}</span>
                </div>
                <button class="btn-primary" onclick="openAddCouponModal()">
                    <i data-lucide="plus"></i> Thêm Mã Khuy?n Mãi
                </button>
            </div>

            <!-- Coupons Table -->
            <div class="table-responsive">
                <table class="custom-table">
                    <thead>
                        <tr>
                            <th>Mã Gi?m Giá</th>
                            <th>Lo?i Gi?m</th>
                            <th>Giá Tr?</th>
                            <th>Ðon T?i Thi?u</th>
                            <th>Lu?t Dùng (Ðã dùng/T?i da)</th>
                            <th>Ngày B?t Ð?u</th>
                            <th>Ngày K?t Thúc</th>
                            <th>Ho?t Ð?ng</th>
                            <th style="width: 100px; text-align: center;">Hành Ð?ng</th>
                        </tr>
                    </thead>
                    <tbody id="coupons-table-body">
                        <c:forEach var="c" items="${coupons}">
                            <tr id="coupon-row-${c.couponId}">
                                <td style="font-weight: 700; color: #f59e0b; font-family: monospace; font-size: 1.1rem;">${c.couponCode}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${c.discountType eq 'Percentage'}">Ph?n tram (%)</c:when>
                                        <c:otherwise>S? ti?n c? d?nh (d)</c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="font-weight: 600;">
                                    <c:choose>
                                        <c:when test="${c.discountType eq 'Percentage'}">${c.discountValue}%</c:when>
                                        <c:otherwise><fmt:formatNumber value="${c.discountValue}" pattern="#,##0" /> ?</c:otherwise>
                                    </c:choose>
                                </td>
                                <td><fmt:formatNumber value="${c.minOrderAmount}" pattern="#,##0" /> ?</td>
                                <td>
                                    <span style="color: var(--success-green); font-weight: 600;">${c.usedCount}</span> / 
                                    <span style="color: var(--text-gray);">${c.maxUses eq null || c.maxUses eq 0 ? 'Vô h?n' : c.maxUses}</span>
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
                                        <button class="btn-icon delete" title="Xóa" onclick="deleteCoupon(${c.couponId})">
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
                                        <h4>Chua có mã gi?m giá nào</h4>
                                        <p>Click vào "Thêm Mã Khuy?n Mãi" ? trên d? t?o mã m?i.</p>
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
            <h3 id="schedule-modal-title">Thêm L?ch Kh?i Hành</h3>
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
                        <label>Ngày Kh?i Hành *</label>
                        <input type="date" name="departureDate" id="form-schedule-dep" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>Ngày V? *</label>
                        <input type="date" name="returnDate" id="form-schedule-ret" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>T?ng S? Ch? *</label>
                        <input type="number" name="totalSeats" id="form-schedule-seats" class="form-control" min="1" required>
                    </div>
                    <div class="form-group" id="available-seats-group" style="display: none;">
                        <label>S? Gh? Còn Tr?ng</label>
                        <input type="number" name="availableSeats" id="form-schedule-avai" class="form-control" min="0">
                    </div>
                    <div class="form-group">
                        <label>Phuong Ti?n Di Chuy?n</label>
                        <input type="text" name="transportation" id="form-schedule-transport" class="form-control" placeholder="Ví d?: Ô tô, Máy bay kh? h?i...">
                    </div>
                    <div class="form-group">
                        <label>Tr?ng Thái Nh?n Ch?</label>
                        <select name="status" id="form-schedule-status" class="form-control">
                            <option value="Open">Open (Còn ch?)</option>
                            <option value="Full">Full (Ð?y ch?)</option>
                            <option value="Closed">Closed (Ðã dóng dang ký)</option>
                            <option value="Cancelled">Cancelled (Ðã h?y)</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Hu?ng D?n Viên</label>
                        <select name="guideId" id="form-schedule-guide" class="form-control">
                            <option value="0">-- Chua phân công --</option>
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
                                    (${not empty g.specialization ? g.specialization : 'Ðoàn'})
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Tr?ng Thái Tour (V?n Hành)</label>
                        <select name="tourStatus" id="form-schedule-tourstatus" class="form-control">
                            <option value="Preparing">Preparing (Chu?n b?)</option>
                            <option value="Scheduled">Scheduled (Lên l?ch kh?i hành)</option>
                            <option value="InProgress">InProgress (Ðang di)</option>
                            <option value="Completed">Completed (Ðã hoàn thành)</option>
                            <option value="Cancelled">Cancelled (Ðã h?y doàn)</option>
                        </select>
                    </div>
                    <div class="form-group form-grid-full">
                        <label>Ghi chú phân công HDV (Notes)</label>
                        <textarea name="notes" id="form-schedule-notes" class="form-control" rows="2" placeholder="Nh?p ghi chú cho hu?ng d?n viên..." style="resize: vertical; min-height: 60px; font-family: inherit; font-size: 0.9rem; padding: 8px 12px;"></textarea>
                    </div>
                    
                    <div class="form-grid-full" style="border-top: 1px solid var(--border-dark); margin: 0.5rem 0; padding-top: 1rem;">
                        <span style="font-family: 'Outfit', sans-serif; font-size: 1rem; font-weight: 600; color: var(--text-light);">C?u hình B?ng Giá:</span>
                    </div>
                    <div class="form-group">
                        <label>Giá Ngu?i L?n * (d) <small style="color: var(--text-gray); font-size: 0.8rem; font-weight: normal;">(T? 12 tu?i tr? lên)</small></label>
                        <input type="number" name="priceAdult" id="form-schedule-price-adult" class="form-control" min="0" required>
                    </div>
                    <div class="form-group">
                        <label>Giá Tr? Em (d) <small style="color: var(--text-gray); font-size: 0.8rem; font-weight: normal;">(T? 2 d?n 11 tu?i)</small></label>
                        <input type="number" name="priceChild" id="form-schedule-price-child" class="form-control" min="0" value="0">
                    </div>
                    <div class="form-group">
                        <label>Giá Tr? So Sinh (d) <small style="color: var(--text-gray); font-size: 0.8rem; font-weight: normal;">(Du?i 2 tu?i)</small></label>
                        <input type="number" name="priceInfant" id="form-schedule-price-infant" class="form-control" min="0" value="0">
                        <span id="infant-warning" style="display: none; color: var(--error-red); font-size: 0.8rem; margin-top: 0.25rem; font-weight: 500;">
                            <i class="fa-solid fa-triangle-exclamation"></i> Tour m?o hi?m - Không cho phép Tr? so sinh tham gia.
                        </span>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-secondary" onclick="closeModal('schedule-modal')">H?y b?</button>
                <button type="submit" class="btn-primary">Luu L?ch Trình</button>
            </div>
        </form>
    </div>
</div>

<!-- -- MODAL 2: COUPON FORM (ADD/EDIT) -- -->
<%-- Temporarily hidden as requested
<div class="modal-backdrop" id="coupon-modal">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 id="coupon-modal-title">Thêm Mã Khuy?n Mãi</h3>
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
                        <label>Mã Gi?m Giá *</label>
                        <input type="text" name="couponCode" id="form-coupon-code" class="form-control" placeholder="VD: FLASH20, TOURBUDDY" required style="text-transform: uppercase;">
                    </div>
                    <div class="form-group">
                        <label>Lo?i Gi?m Giá</label>
                        <select name="discountType" id="form-coupon-type" class="form-control" onchange="adjustDiscountInput(this.value)">
                            <option value="Percentage">Gi?m theo Ph?n Tram (%)</option>
                            <option value="FixedAmount">Gi?m S? Ti?n C? Ð?nh (d)</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label id="label-discount-value">Giá tr? gi?m * (%)</label>
                        <input type="number" name="discountValue" id="form-coupon-value" class="form-control" min="0.01" step="any" required>
                    </div>
                    <div class="form-group">
                        <label>Ðon Hàng T?i Thi?u (d)</label>
                        <input type="number" name="minOrderAmount" id="form-coupon-minorder" class="form-control" min="0" value="0">
                    </div>
                    <div class="form-group">
                        <label>S? Lu?t S? D?ng T?i Ða</label>
                        <input type="number" name="maxUses" id="form-coupon-maxuses" class="form-control" min="1" placeholder="Vô h?n n?u b? tr?ng">
                    </div>
                    <div class="form-group">
                        <label>Tr?ng Thái Ho?t Ð?ng</label>
                        <select name="isActive" id="form-coupon-status" class="form-control">
                            <option value="true">Active (Kích ho?t)</option>
                            <option value="false">Inactive (Vô hi?u hóa)</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Ngày B?t Ð?u *</label>
                        <input type="date" name="startDate" id="form-coupon-start" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>Ngày K?t Thúc *</label>
                        <input type="date" name="endDate" id="form-coupon-end" class="form-control" required>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-secondary" onclick="closeModal('coupon-modal')">H?y b?</button>
                <button type="submit" class="btn-primary">Luu Khuy?n Mãi</button>
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

    // Ðóng/M? Modal
    function openModal(modalId) {
        document.getElementById(modalId).classList.add("open");
    }
    function closeModal(modalId) {
        document.getElementById(modalId).classList.remove("open");
    }

    // Ð?nh d?ng s? thành VND
    function formatVND(amount) {
        return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
    }

    // -- LOGIC L?CH TRÌNH --
    function loadSchedules(tourId) {
        const tbody = document.getElementById("schedules-table-body");
        if (!tourId) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="9">
                        <div class="empty-state">
                            <i data-lucide="compass" style="width: 48px; height: 48px;"></i>
                            <h4>Chua ch?n Tour</h4>
                            <p>Vui lòng ch?n m?t tour t? danh sách trên d? xem và qu?n lý l?ch kh?i hành.</p>
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
                        <span>Ðang t?i l?ch trình kh?i hành...</span>
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
                                    <h4>Chua có l?ch trình</h4>
                                    <p>Tour này hi?n t?i chua du?c lên l?ch kh?i hành nào. Click "Thêm L?ch Kh?i Hành" d? t?o m?i.</p>
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
                    let opText = 'Chu?n b?';
                    if (s.tourStatus === 'Scheduled') { opBadgeClass = 'badge-op-scheduled'; opText = 'Lên l?ch'; }
                    else if (s.tourStatus === 'InProgress') { opBadgeClass = 'badge-op-progress'; opText = 'Ðang di'; }
                    else if (s.tourStatus === 'Completed') { opBadgeClass = 'badge-op-completed'; opText = 'Hoàn thành'; }
                    else if (s.tourStatus === 'Cancelled') { opBadgeClass = 'badge-cancelled'; opText = 'H?y doàn'; }

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
                            <td>\${s.transportation || 'Chua rõ'}</td>
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
                                    <button class="btn-icon delete" title="Xóa" onclick="deleteSchedule(\${s.scheduleId}, '\${s.tourStatus}')">
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
                            Có l?i khi t?i danh sách l?ch kh?i hành. Vui lòng th? l?i.
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
            // Tour m?o hi?m: Reset v? 0, khóa ch?nh s?a b?ng readonly, làm m?
            infantInput.value = 0;
            infantInput.readOnly = true;
            infantInput.style.opacity = "0.5";
            infantInput.style.pointerEvents = "none";
            if (infantWarning) infantWarning.style.display = "block";
        } else {
            // Tour bình thu?ng: M? khóa
            infantInput.readOnly = false;
            infantInput.style.opacity = "1";
            infantInput.style.pointerEvents = "auto";
            if (infantWarning) infantWarning.style.display = "none";
        }
    }

    function openAddScheduleModal() {
        const tourId = document.getElementById("tour-selector").value;
        if (!tourId) {
            alert("Vui lòng ch?n m?t Tour tru?c khi thêm l?ch kh?i hành!");
            return;
        }

        document.getElementById("schedule-form").reset();
        document.getElementById("schedule-modal-title").innerText = "Thêm L?ch Kh?i Hành";
        document.getElementById("schedule-action").value = "addSchedule";
        document.getElementById("form-schedule-id").value = "";
        document.getElementById("form-schedule-tour-id").value = tourId;
        document.getElementById("available-seats-group").style.display = "none";
        
        // Ki?m tra ràng bu?c tr? so sinh d?i v?i tour m?o hi?m
        checkInfantRestriction();
        
        openModal("schedule-modal");
    }

    // Nh?n chu?i JSON c?a schedule d? di?n vào form khi Edit
    function openEditScheduleModal(s) {
        document.getElementById("schedule-modal-title").innerText = "S?a L?ch Kh?i Hành";
        document.getElementById("schedule-action").value = "editSchedule";
        document.getElementById("form-schedule-id").value = s.scheduleId;
        document.getElementById("form-schedule-tour-id").value = s.tourId;
        
        document.getElementById("form-schedule-dep").value = s.departureStr;
        document.getElementById("form-schedule-ret").value = s.returnStr;
        document.getElementById("form-schedule-seats").value = s.totalSeats;
        
        // Hi?n s? ch? tr?ng d? ch?nh s?a
        document.getElementById("available-seats-group").style.display = "flex";
        document.getElementById("form-schedule-avai").value = s.availableSeats;
        
        document.getElementById("form-schedule-transport").value = s.transportation || "";
        document.getElementById("form-schedule-status").value = s.status;
        document.getElementById("form-schedule-guide").value = s.guideId || "0";
        document.getElementById("form-schedule-tourstatus").value = s.tourStatus || "Preparing";
        
        document.getElementById("form-schedule-price-adult").value = s.priceAdult;
        document.getElementById("form-schedule-price-child").value = s.priceChild;
        document.getElementById("form-schedule-price-infant").value = s.priceInfant;
        document.getElementById("form-schedule-notes").value = s.notes || "";

        // Ki?m tra ràng bu?c tr? so sinh d?i v?i tour m?o hi?m
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
        const priceAdult = parseFloat(document.getElementById("form-schedule-price-adult").value) || 0;
        const priceChild = parseFloat(document.getElementById("form-schedule-price-child").value) || 0;
        const priceInfant = parseFloat(document.getElementById("form-schedule-price-infant").value) || 0;

        if (!depVal || !retVal) {
            alert("Vui lòng ch?n d?y d? ngày kh?i hành và ngày v?!");
            return;
        }

        const depDate = new Date(depVal);
        const retDate = new Date(retVal);
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        depDate.setHours(0, 0, 0, 0);
        retDate.setHours(0, 0, 0, 0);

        // 1. Không cho phép ngày kh?i hành ? quá kh? khi thêm m?i
        if (action === "addSchedule" && depDate < today) {
            alert("Ngày kh?i hành không du?c ? quá kh?!");
            return;
        }

        // 2. Ngày v? không du?c tru?c ngày kh?i hành
        if (retDate < depDate) {
            alert("Ngày v? không du?c tru?c ngày kh?i hành!");
            return;
        }

        // 3. Tour không du?c kéo dài quá lâu (chênh l?ch ngày không vu?t quá th?i lu?ng tour)
        const selector = document.getElementById("tour-selector");
        const selectedOpt = selector.options[selector.selectedIndex];
        const duration = parseInt(selectedOpt.getAttribute("data-duration")) || 1;
        
        const timeDiff = Math.abs(retDate.getTime() - depDate.getTime());
        const diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24)) + 1; // S? ngày th?c t? di
        
        if (diffDays > duration) {
            alert("L?ch trình kéo dài quá lâu (" + diffDays + " ngày). Th?i lu?ng c?a tour này du?c c?u hình t?i da là " + duration + " ngày!");
            return;
        }

        // 3.5. Ki?m tra s? gh? còn tr?ng không du?c l?n hon t?ng s? ch? (ch? khi s?a l?ch trình)
        if (action === "editSchedule") {
            const avaiSeats = parseInt(document.getElementById("form-schedule-avai").value) || 0;
            if (avaiSeats > totalSeats) {
                alert("S? gh? còn tr?ng (" + avaiSeats + ") không du?c l?n hon t?ng s? ch? (" + totalSeats + ")!");
                return;
            }
        }

        // 4. Khóa/ch?n giá tr? so sinh d?i v?i các tour m?o hi?m (Bi?n/Núi)
        const catId = parseInt(selectedOpt.getAttribute("data-category-id")) || 0;
        if ((catId === 1 || catId === 2) && priceInfant > 0) {
            alert("Tour thu?c danh m?c m?o hi?m (Bi?n & Ð?o / Núi & R?ng), không cho phép tr? so sinh tham gia!");
            return;
        }

        if (totalSeats <= 0) {
            alert("T?ng s? ch? ph?i l?n hon 0!");
            return;
        }
        if (priceAdult < 0 || priceChild < 0 || priceInfant < 0) {
            alert("Giá vé c?u hình không du?c âm!");
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
            alert("Có l?i k?t n?i h? th?ng.");
        });
    }

    function deleteSchedule(scheduleId, tourStatus) {
        if (tourStatus && tourStatus !== 'Preparing' && tourStatus !== 'Completed' && tourStatus !== 'Cancelled') {
            let statusText = tourStatus;
            if (tourStatus === 'Scheduled') statusText = 'Scheduled (Lên l?ch kh?i hành)';
            else if (tourStatus === 'InProgress') statusText = 'InProgress (Ðang di)';
            alert("Không th? xóa l?ch kh?i hành dang ? tr?ng thái '" + statusText + "'. Ch? cho phép xóa khi ? tr?ng thái Chu?n b?, Hoàn thành ho?c H?y doàn.");
            return;
        }

        if (!confirm("B?n có ch?c ch?n mu?n xóa l?ch kh?i hành này? Hành d?ng này không th? hoàn tác.")) {
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
            alert("Có l?i x?y ra khi g?i yêu c?u.");
        });
    }

    // -- LOGIC MÃ GI?M GIÁ (COUPONS) --
    function adjustDiscountInput(type) {
        const label = document.getElementById("label-discount-value");
        if (type === "Percentage") {
            label.innerText = "Giá tr? gi?m * (%)";
        } else {
            label.innerText = "Giá tr? gi?m * (d)";
        }
    }

    function openAddCouponModal() {
        document.getElementById("coupon-form").reset();
        document.getElementById("coupon-modal-title").innerText = "Thêm Mã Khuy?n Mãi";
        document.getElementById("coupon-action").value = "addCoupon";
        document.getElementById("form-coupon-id").value = "";
        adjustDiscountInput("Percentage");
        openModal("coupon-modal");
    }

    function openEditCouponModal(id, code, type, value, minOrder, maxUses, start, end, isActive) {
        document.getElementById("coupon-modal-title").innerText = "S?a Mã Khuy?n Mãi";
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
                location.reload(); // T?i l?i trang d? c?p nh?t danh sách
            } else {
                alert(res.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert("Có l?i k?t n?i h? th?ng.");
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
            alert("L?i k?t n?i khi thay d?i tr?ng thái mã gi?m giá.");
            location.reload();
        });
    }

    function deleteCoupon(couponId) {
        if (!confirm("B?n có ch?c ch?n mu?n xóa mã gi?m giá này?")) {
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
            alert("Có l?i x?y ra khi xóa mã gi?m giá.");
        });
    }
</script>
</body>
</html>
