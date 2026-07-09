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
    <title>Lịch Trình & Giá — TourBuddy Enterprise</title>
    <!-- Outfit & Inter Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons & FontAwesome CDNs -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=1.7">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-schedules.css?v=1.0">
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <c:set var="activePage" value="schedules" scope="request" />
    <jsp:include page="sidebar.jsp" />

    <!-- ── Main Content Area ── -->
    <main class="main-content">
        <!-- Top Header -->
        <header class="top-header">
            <h1>Quản lý Lịch trình & Giá Tour</h1>
            <div class="header-right">
                <div class="header-search">
                    <i data-lucide="search"></i>
                    <input type="text" placeholder="Tìm kiếm nhanh...">
                </div>
                
                <div class="profile-user" style="cursor: pointer;">
                    <div class="profile-meta" style="text-align: right; margin-right: 5px;">
                        <span class="name">${not empty sessionUser.fullName ? sessionUser.fullName : 'Sarah Jenkins'}</span>
                        <span class="role">Quản trị viên</span>
                    </div>
                    <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80" alt="Avatar">
                </div>
            </div>
        </header>

        <!-- Dynamic Content Tabs -->
        <div class="tabs-container">
            <button class="tab-btn active" onclick="switchTab(event, 'tab-schedules')">
                <i data-lucide="calendar-days"></i> Lịch Khởi Hành & Giá
            </button>
            <!-- Temporarily hidden as requested
            <button class="tab-btn" onclick="switchTab(event, 'tab-coupons')">
                <i data-lucide="ticket"></i> Chương Trình Khuyến Mãi (Coupons)
            </button>
            -->
        </div>

        <!-- ── TAB 1: SCHEDULES MANAGEMENT ── -->
        <section class="tab-panel active" id="tab-schedules">
            <div class="control-bar">
                <div class="selector-group">
                    <span class="control-label">Chọn Tour:</span>
                    <select class="custom-select" id="tour-selector" onchange="loadSchedules(this.value)">
                        <option value="">-- Chọn Tour cần quản lý --</option>
                        <c:forEach var="t" items="${tours}">
                            <option value="${t.tourId}" data-category-id="${t.categoryId}" data-duration="${t.durationDays}">${t.tourName}</option>
                        </c:forEach>
                    </select>
                </div>
                <button class="btn-primary" onclick="openAddScheduleModal()">
                    <i data-lucide="plus"></i> Thêm Lịch Khởi Hành
                </button>
            </div>

            <!-- Schedules Table -->
            <div class="table-responsive">
                <table class="custom-table">
                    <thead>
                        <tr>
                            <th>Ngày Khởi Hành</th>
                            <th>Ngày Về</th>
                            <th>Ghế (Trống/Tổng)</th>
                            <th>Bảng Giá</th>
                            <th>Phương Tiện</th>
                            <th>Trạng Thái</th>
                            <th>HDV phụ trách</th>
                            <th>Vận Hành</th>
                            <th style="width: 100px; text-align: center;">Hành Động</th>
                        </tr>
                    </thead>
                    <tbody id="schedules-table-body">
                        <tr>
                            <td colspan="9">
                                <div class="empty-state">
                                    <i data-lucide="compass" style="width: 48px; height: 48px;"></i>
                                    <h4>Chưa chọn Tour</h4>
                                    <p>Vui lòng chọn một tour từ danh sách trên để xem và quản lý lịch khởi hành.</p>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- ── TAB 2: COUPONS MANAGEMENT ── -->
        <%-- Temporarily hidden as requested
        <section class="tab-panel" id="tab-coupons">
            <div class="control-bar">
                <div class="selector-group">
                    <span class="control-label">Tổng số mã khuyến mãi:</span>
                    <span class="control-label" style="color: var(--text-light); font-weight: 600;" id="coupon-count">${coupons.size()}</span>
                </div>
                <button class="btn-primary" onclick="openAddCouponModal()">
                    <i data-lucide="plus"></i> Thêm Mã Khuyến Mãi
                </button>
            </div>

            <!-- Coupons Table -->
            <div class="table-responsive">
                <table class="custom-table">
                    <thead>
                        <tr>
                            <th>Mã Giảm Giá</th>
                            <th>Loại Giảm</th>
                            <th>Giá Trị</th>
                            <th>Đơn Tối Thiểu</th>
                            <th>Lượt Dùng (Đã dùng/Tối đa)</th>
                            <th>Ngày Bắt Đầu</th>
                            <th>Ngày Kết Thúc</th>
                            <th>Hoạt Động</th>
                            <th style="width: 100px; text-align: center;">Hành Động</th>
                        </tr>
                    </thead>
                    <tbody id="coupons-table-body">
                        <c:forEach var="c" items="${coupons}">
                            <tr id="coupon-row-${c.couponId}">
                                <td style="font-weight: 700; color: #f59e0b; font-family: monospace; font-size: 1.1rem;">${c.couponCode}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${c.discountType eq 'Percentage'}">Phần trăm (%)</c:when>
                                        <c:otherwise>Số tiền cố định (đ)</c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="font-weight: 600;">
                                    <c:choose>
                                        <c:when test="${c.discountType eq 'Percentage'}">${c.discountValue}%</c:when>
                                        <c:otherwise><fmt:formatNumber value="${c.discountValue}" pattern="#,##0" /> ₫</c:otherwise>
                                    </c:choose>
                                </td>
                                <td><fmt:formatNumber value="${c.minOrderAmount}" pattern="#,##0" /> ₫</td>
                                <td>
                                    <span style="color: var(--success-green); font-weight: 600;">${c.usedCount}</span> / 
                                    <span style="color: var(--text-gray);">${c.maxUses eq null || c.maxUses eq 0 ? 'Vô hạn' : c.maxUses}</span>
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
                                        <button class="btn-icon edit" title="Sửa" onclick="openEditCouponModal(${c.couponId}, '${c.couponCode}', '${c.discountType}', ${c.discountValue}, ${c.minOrderAmount}, '${c.maxUses}', '${c.startDate}', '${c.endDate}', ${c.isActive})">
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
                                        <h4>Chưa có mã giảm giá nào</h4>
                                        <p>Click vào "Thêm Mã Khuyến Mãi" ở trên để tạo mã mới.</p>
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

<!-- ── MODAL 1: SCHEDULE FORM (ADD/EDIT) ── -->
<div class="modal-backdrop" id="schedule-modal">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 id="schedule-modal-title">Thêm Lịch Khởi Hành</h3>
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
                        <label>Ngày Khởi Hành *</label>
                        <input type="date" name="departureDate" id="form-schedule-dep" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>Ngày Về *</label>
                        <input type="date" name="returnDate" id="form-schedule-ret" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>Tổng Số Chỗ *</label>
                        <input type="number" name="totalSeats" id="form-schedule-seats" class="form-control" min="1" required>
                    </div>
                    <div class="form-group" id="available-seats-group" style="display: none;">
                        <label>Số Ghế Còn Trống</label>
                        <input type="number" name="availableSeats" id="form-schedule-avai" class="form-control" min="0">
                    </div>
                    <div class="form-group">
                        <label>Phương Tiện Di Chuyển</label>
                        <input type="text" name="transportation" id="form-schedule-transport" class="form-control" placeholder="Ví dụ: Ô tô, Máy bay khứ hồi...">
                    </div>
                    <div class="form-group">
                        <label>Trạng Thái Nhận Chỗ</label>
                        <select name="status" id="form-schedule-status" class="form-control">
                            <option value="Open">Open (Còn chỗ)</option>
                            <option value="Full">Full (Đầy chỗ)</option>
                            <option value="Closed">Closed (Đã đóng đăng ký)</option>
                            <option value="Cancelled">Cancelled (Đã hủy)</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Hướng Dẫn Viên</label>
                        <select name="guideId" id="form-schedule-guide" class="form-control">
                            <option value="0">-- Chưa phân công --</option>
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
                                    (${not empty g.specialization ? g.specialization : 'Đoàn'})
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Trạng Thái Tour (Vận Hành)</label>
                        <select name="tourStatus" id="form-schedule-tourstatus" class="form-control">
                            <option value="Preparing">Preparing (Chuẩn bị)</option>
                            <option value="Scheduled">Scheduled (Lên lịch khởi hành)</option>
                            <option value="InProgress">InProgress (Đang đi)</option>
                            <option value="Completed">Completed (Đã hoàn thành)</option>
                            <option value="Cancelled">Cancelled (Đã hủy đoàn)</option>
                        </select>
                    </div>
                    
                    <div class="form-grid-full" style="border-top: 1px solid var(--border-dark); margin: 0.5rem 0; padding-top: 1rem;">
                        <span style="font-family: 'Outfit', sans-serif; font-size: 1rem; font-weight: 600; color: var(--text-light);">Cấu hình Bảng Giá:</span>
                    </div>
                    <div class="form-group">
                        <label>Giá Người Lớn * (đ) <small style="color: var(--text-gray); font-size: 0.8rem; font-weight: normal;">(Từ 12 tuổi trở lên)</small></label>
                        <input type="number" name="priceAdult" id="form-schedule-price-adult" class="form-control" min="0" required>
                    </div>
                    <div class="form-group">
                        <label>Giá Trẻ Em (đ) <small style="color: var(--text-gray); font-size: 0.8rem; font-weight: normal;">(Từ 2 đến 11 tuổi)</small></label>
                        <input type="number" name="priceChild" id="form-schedule-price-child" class="form-control" min="0" value="0">
                    </div>
                    <div class="form-group">
                        <label>Giá Trẻ Sơ Sinh (đ) <small style="color: var(--text-gray); font-size: 0.8rem; font-weight: normal;">(Dưới 2 tuổi)</small></label>
                        <input type="number" name="priceInfant" id="form-schedule-price-infant" class="form-control" min="0" value="0">
                        <span id="infant-warning" style="display: none; color: var(--error-red); font-size: 0.8rem; margin-top: 0.25rem; font-weight: 500;">
                            <i class="fa-solid fa-triangle-exclamation"></i> Tour mạo hiểm - Không cho phép Trẻ sơ sinh tham gia.
                        </span>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-secondary" onclick="closeModal('schedule-modal')">Hủy bỏ</button>
                <button type="submit" class="btn-primary">Lưu Lịch Trình</button>
            </div>
        </form>
    </div>
</div>

<!-- ── MODAL 2: COUPON FORM (ADD/EDIT) ── -->
<%-- Temporarily hidden as requested
<div class="modal-backdrop" id="coupon-modal">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 id="coupon-modal-title">Thêm Mã Khuyến Mãi</h3>
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
                        <label>Mã Giảm Giá *</label>
                        <input type="text" name="couponCode" id="form-coupon-code" class="form-control" placeholder="VD: FLASH20, TOURBUDDY" required style="text-transform: uppercase;">
                    </div>
                    <div class="form-group">
                        <label>Loại Giảm Giá</label>
                        <select name="discountType" id="form-coupon-type" class="form-control" onchange="adjustDiscountInput(this.value)">
                            <option value="Percentage">Giảm theo Phần Trăm (%)</option>
                            <option value="FixedAmount">Giảm Số Tiền Cố Định (đ)</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label id="label-discount-value">Giá trị giảm * (%)</label>
                        <input type="number" name="discountValue" id="form-coupon-value" class="form-control" min="0.01" step="any" required>
                    </div>
                    <div class="form-group">
                        <label>Đơn Hàng Tối Thiểu (đ)</label>
                        <input type="number" name="minOrderAmount" id="form-coupon-minorder" class="form-control" min="0" value="0">
                    </div>
                    <div class="form-group">
                        <label>Số Lượt Sử Dụng Tối Đa</label>
                        <input type="number" name="maxUses" id="form-coupon-maxuses" class="form-control" min="1" placeholder="Vô hạn nếu bỏ trống">
                    </div>
                    <div class="form-group">
                        <label>Trạng Thái Hoạt Động</label>
                        <select name="isActive" id="form-coupon-status" class="form-control">
                            <option value="true">Active (Kích hoạt)</option>
                            <option value="false">Inactive (Vô hiệu hóa)</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Ngày Bắt Đầu *</label>
                        <input type="date" name="startDate" id="form-coupon-start" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>Ngày Kết Thúc *</label>
                        <input type="date" name="endDate" id="form-coupon-end" class="form-control" required>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-secondary" onclick="closeModal('coupon-modal')">Hủy bỏ</button>
                <button type="submit" class="btn-primary">Lưu Khuyến Mãi</button>
            </div>
        </form>
    </div>
</div>
--%>

<!-- JS Controller Logic -->
<script>
    // Khởi tạo Lucide Icons khi tải trang
    document.addEventListener("DOMContentLoaded", function() {
        lucide.createIcons();
    });

    // Chuyển Tab
    function switchTab(evt, tabId) {
        document.querySelectorAll(".tab-btn").forEach(btn => btn.classList.remove("active"));
        document.querySelectorAll(".tab-panel").forEach(panel => panel.classList.remove("active"));

        evt.currentTarget.classList.add("active");
        document.getElementById(tabId).classList.add("active");
    }

    // Đóng/Mở Modal
    function openModal(modalId) {
        document.getElementById(modalId).classList.add("open");
    }
    function closeModal(modalId) {
        document.getElementById(modalId).classList.remove("open");
    }

    // Định dạng số thành VND
    function formatVND(amount) {
        return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
    }

    // ── LOGIC LỊCH TRÌNH ──
    function loadSchedules(tourId) {
        const tbody = document.getElementById("schedules-table-body");
        if (!tourId) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="9">
                        <div class="empty-state">
                            <i data-lucide="compass" style="width: 48px; height: 48px;"></i>
                            <h4>Chưa chọn Tour</h4>
                            <p>Vui lòng chọn một tour từ danh sách trên để xem và quản lý lịch khởi hành.</p>
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
                        <span>Đang tải lịch trình khởi hành...</span>
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
                                    <h4>Chưa có lịch trình</h4>
                                    <p>Tour này hiện tại chưa được lên lịch khởi hành nào. Click "Thêm Lịch Khởi Hành" để tạo mới.</p>
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
                    let opText = 'Chuẩn bị';
                    if (s.tourStatus === 'Scheduled') { opBadgeClass = 'badge-op-scheduled'; opText = 'Lên lịch'; }
                    else if (s.tourStatus === 'InProgress') { opBadgeClass = 'badge-op-progress'; opText = 'Đang đi'; }
                    else if (s.tourStatus === 'Completed') { opBadgeClass = 'badge-op-completed'; opText = 'Hoàn thành'; }
                    else if (s.tourStatus === 'Cancelled') { opBadgeClass = 'badge-cancelled'; opText = 'Hủy đoàn'; }

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
                                        <span class="price-type">Lớn:</span>
                                        <span class="price-amount">\${formatVND(s.priceAdult)}</span>
                                    </div>
                                    <div class="price-row">
                                        <span class="price-type">Trẻ em:</span>
                                        <span class="price-amount">\${formatVND(s.priceChild)}</span>
                                    </div>
                                    <div class="price-row">
                                        <span class="price-type">Sơ sinh:</span>
                                        <span class="price-amount">\${formatVND(s.priceInfant)}</span>
                                    </div>
                                </div>
                            </td>
                            <td>\${s.transportation || 'Chưa rõ'}</td>
                            <td>
                                <span class="badge \${badgeClass}">\${s.status}</span>
                            </td>
                            <td style="font-weight: 500;">\${s.guideName}</td>
                            <td>
                                <span class="badge \${opBadgeClass}">\${opText}</span>
                            </td>
                            <td style="text-align: center;">
                                <div class="action-btn-group">
                                    <button class="btn-icon edit" title="Sửa" onclick="openEditScheduleModal(\${JSON.stringify(s).replace(/"/g, '&quot;')})">
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
                            Có lỗi khi tải danh sách lịch khởi hành. Vui lòng thử lại.
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
            // Tour mạo hiểm: Reset về 0, khóa chỉnh sửa bằng readonly, làm mờ
            infantInput.value = 0;
            infantInput.readOnly = true;
            infantInput.style.opacity = "0.5";
            infantInput.style.pointerEvents = "none";
            if (infantWarning) infantWarning.style.display = "block";
        } else {
            // Tour bình thường: Mở khóa
            infantInput.readOnly = false;
            infantInput.style.opacity = "1";
            infantInput.style.pointerEvents = "auto";
            if (infantWarning) infantWarning.style.display = "none";
        }
    }

    function openAddScheduleModal() {
        const tourId = document.getElementById("tour-selector").value;
        if (!tourId) {
            alert("Vui lòng chọn một Tour trước khi thêm lịch khởi hành!");
            return;
        }

        document.getElementById("schedule-form").reset();
        document.getElementById("schedule-modal-title").innerText = "Thêm Lịch Khởi Hành";
        document.getElementById("schedule-action").value = "addSchedule";
        document.getElementById("form-schedule-id").value = "";
        document.getElementById("form-schedule-tour-id").value = tourId;
        document.getElementById("available-seats-group").style.display = "none";
        
        // Kiểm tra ràng buộc trẻ sơ sinh đối với tour mạo hiểm
        checkInfantRestriction();
        
        openModal("schedule-modal");
    }

    // Nhận chuỗi JSON của schedule để điền vào form khi Edit
    function openEditScheduleModal(s) {
        document.getElementById("schedule-modal-title").innerText = "Sửa Lịch Khởi Hành";
        document.getElementById("schedule-action").value = "editSchedule";
        document.getElementById("form-schedule-id").value = s.scheduleId;
        document.getElementById("form-schedule-tour-id").value = s.tourId;
        
        document.getElementById("form-schedule-dep").value = s.departureStr;
        document.getElementById("form-schedule-ret").value = s.returnStr;
        document.getElementById("form-schedule-seats").value = s.totalSeats;
        
        // Hiện số chỗ trống để chỉnh sửa
        document.getElementById("available-seats-group").style.display = "flex";
        document.getElementById("form-schedule-avai").value = s.availableSeats;
        
        document.getElementById("form-schedule-transport").value = s.transportation || "";
        document.getElementById("form-schedule-status").value = s.status;
        document.getElementById("form-schedule-guide").value = s.guideId || "0";
        document.getElementById("form-schedule-tourstatus").value = s.tourStatus || "Preparing";
        
        document.getElementById("form-schedule-price-adult").value = s.priceAdult;
        document.getElementById("form-schedule-price-child").value = s.priceChild;
        document.getElementById("form-schedule-price-infant").value = s.priceInfant;
        
        // Kiểm tra ràng buộc trẻ sơ sinh đối với tour mạo hiểm
        checkInfantRestriction();
        
        openModal("schedule-modal");
    }

    function saveSchedule(e) {
        e.preventDefault();
        const form = document.getElementById("schedule-form");
        
        // ── CLIENT-SIDE VALIDATIONS ──
        const action = document.getElementById("schedule-action").value;
        const depVal = document.getElementById("form-schedule-dep").value;
        const retVal = document.getElementById("form-schedule-ret").value;
        const totalSeats = parseInt(document.getElementById("form-schedule-seats").value) || 0;
        const priceAdult = parseFloat(document.getElementById("form-schedule-price-adult").value) || 0;
        const priceChild = parseFloat(document.getElementById("form-schedule-price-child").value) || 0;
        const priceInfant = parseFloat(document.getElementById("form-schedule-price-infant").value) || 0;

        if (!depVal || !retVal) {
            alert("Vui lòng chọn đầy đủ ngày khởi hành và ngày về!");
            return;
        }

        const depDate = new Date(depVal);
        const retDate = new Date(retVal);
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        depDate.setHours(0, 0, 0, 0);
        retDate.setHours(0, 0, 0, 0);

        // 1. Không cho phép ngày khởi hành ở quá khứ khi thêm mới
        if (action === "addSchedule" && depDate < today) {
            alert("Ngày khởi hành không được ở quá khứ!");
            return;
        }

        // 2. Ngày về không được trước ngày khởi hành
        if (retDate < depDate) {
            alert("Ngày về không được trước ngày khởi hành!");
            return;
        }

        // 3. Tour không được kéo dài quá lâu (chênh lệch ngày không vượt quá thời lượng tour)
        const selector = document.getElementById("tour-selector");
        const selectedOpt = selector.options[selector.selectedIndex];
        const duration = parseInt(selectedOpt.getAttribute("data-duration")) || 1;
        
        const timeDiff = Math.abs(retDate.getTime() - depDate.getTime());
        const diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24)) + 1; // Số ngày thực tế đi
        
        if (diffDays > duration) {
            alert("Lịch trình kéo dài quá lâu (" + diffDays + " ngày). Thời lượng của tour này được cấu hình tối đa là " + duration + " ngày!");
            return;
        }

        // 3.5. Kiểm tra số ghế còn trống không được lớn hơn tổng số chỗ (chỉ khi sửa lịch trình)
        if (action === "editSchedule") {
            const avaiSeats = parseInt(document.getElementById("form-schedule-avai").value) || 0;
            if (avaiSeats > totalSeats) {
                alert("Số ghế còn trống (" + avaiSeats + ") không được lớn hơn tổng số chỗ (" + totalSeats + ")!");
                return;
            }
        }

        // 4. Khóa/chặn giá trẻ sơ sinh đối với các tour mạo hiểm (Biển/Núi)
        const catId = parseInt(selectedOpt.getAttribute("data-category-id")) || 0;
        if ((catId === 1 || catId === 2) && priceInfant > 0) {
            alert("Tour thuộc danh mục mạo hiểm (Biển & Đảo / Núi & Rừng), không cho phép trẻ sơ sinh tham gia!");
            return;
        }

        if (totalSeats <= 0) {
            alert("Tổng số chỗ phải lớn hơn 0!");
            return;
        }
        if (priceAdult < 0 || priceChild < 0 || priceInfant < 0) {
            alert("Giá vé cấu hình không được âm!");
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
            alert("Có lỗi kết nối hệ thống.");
        });
    }

    function deleteSchedule(scheduleId, tourStatus) {
        if (tourStatus && tourStatus !== 'Preparing' && tourStatus !== 'Completed' && tourStatus !== 'Cancelled') {
            let statusText = tourStatus;
            if (tourStatus === 'Scheduled') statusText = 'Scheduled (Lên lịch khởi hành)';
            else if (tourStatus === 'InProgress') statusText = 'InProgress (Đang đi)';
            alert(`Không thể xóa lịch khởi hành đang ở trạng thái '${statusText}'. Chỉ cho phép xóa khi ở trạng thái Chuẩn bị, Hoàn thành hoặc Hủy đoàn.`);
            return;
        }

        if (!confirm("Bạn có chắc chắn muốn xóa lịch khởi hành này? Hành động này không thể hoàn tác.")) {
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
            alert("Có lỗi xảy ra khi gửi yêu cầu.");
        });
    }

    // ── LOGIC MÃ GIẢM GIÁ (COUPONS) ──
    function adjustDiscountInput(type) {
        const label = document.getElementById("label-discount-value");
        if (type === "Percentage") {
            label.innerText = "Giá trị giảm * (%)";
        } else {
            label.innerText = "Giá trị giảm * (đ)";
        }
    }

    function openAddCouponModal() {
        document.getElementById("coupon-form").reset();
        document.getElementById("coupon-modal-title").innerText = "Thêm Mã Khuyến Mãi";
        document.getElementById("coupon-action").value = "addCoupon";
        document.getElementById("form-coupon-id").value = "";
        adjustDiscountInput("Percentage");
        openModal("coupon-modal");
    }

    function openEditCouponModal(id, code, type, value, minOrder, maxUses, start, end, isActive) {
        document.getElementById("coupon-modal-title").innerText = "Sửa Mã Khuyến Mãi";
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
                location.reload(); // Tải lại trang để cập nhật danh sách
            } else {
                alert(res.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert("Có lỗi kết nối hệ thống.");
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
            alert("Lỗi kết nối khi thay đổi trạng thái mã giảm giá.");
            location.reload();
        });
    }

    function deleteCoupon(couponId) {
        if (!confirm("Bạn có chắc chắn muốn xóa mã giảm giá này?")) {
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
                
                // Cập nhật đếm
                const cnt = document.getElementById("coupon-count");
                if (cnt) cnt.innerText = parseInt(cnt.innerText) - 1;
            } else {
                alert(res.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert("Có lỗi xảy ra khi xóa mã giảm giá.");
        });
    }
</script>
</body>
</html>
