<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
            <%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

                <%-- Kiem tra quyen: chi Staff va Admin moi duoc vao trang nay --%>
                    <c:if test="${empty sessionScope.sessionUser
    || (sessionScope.sessionUser.role.roleName ne 'Staff'
    && sessionScope.sessionUser.role.roleName ne 'Admin')}">
                        <c:redirect url="/login" />
                    </c:if>

                    <!DOCTYPE html>
                    <html lang="vi">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Quản Lý Booking — TourBuddy Staff</title>
                        <link
                            href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap"
                            rel="stylesheet">
                        <script src="https://unpkg.com/lucide@latest"></script>
                        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=1.6">
                        <link rel="stylesheet"
                            href="${pageContext.request.contextPath}/css/staff-booking-management.css?v=1.2">
                    </head>

                    <body class="dashboard-body">

                        <div class="dashboard-wrapper">
                            <c:set var="activePage" value="staff-bookings" scope="request" />
                            <%@ include file="/admin/staff-sidebar.jsp" %>

                                <main class="main-content">
                                    <div class="content-area">
                                        <div class="page-header" style="margin-bottom:24px;">
                                            <div>
                                                <h1 style="margin:0;font-size:24px;font-weight:700;color:#0F172A;">
                                                    Quản Lý Booking</h1>
                                                <p style="margin:4px 0 0;color:#64748B;font-size:14px;">Xem và
                                                    quản lý toàn bộ đơn đặt
                                                    tour của hệ thống</p>
                                            </div>
                                        </div>

                                        <%-- Toast messages --%>
                                            <c:if test="${not empty successMessage}">
                                                <div class="toast success" id="toastMsg">
                                                    <i data-lucide="check-circle"></i> ${successMessage}
                                                </div>
                                            </c:if>
                                            <c:if test="${not empty errorMessage}">
                                                <div class="toast error" id="toastMsg">
                                                    <i data-lucide="x-circle"></i> ${errorMessage}
                                                </div>
                                            </c:if>

                                            <%-- Stats cards --%>
                                                <div class="stats-grid">
                                                    <div class="stat-card">
                                                        <div class="stat-icon primary"><i
                                                                data-lucide="clipboard-list"></i></div>
                                                        <div class="stat-info">
                                                            <h4>Tổng Booking</h4>
                                                            <div class="stat-value">${totalRecords}</div>
                                                        </div>
                                                    </div>
                                                    <div class="stat-card">
                                                        <div class="stat-icon success"><i
                                                                data-lucide="check-circle"></i></div>
                                                        <div class="stat-info">
                                                            <h4>Đang hiển thị</h4>
                                                            <div class="stat-value">${bookings.size()}</div>
                                                        </div>
                                                    </div>
                                                    <div class="stat-card">
                                                        <div class="stat-icon warning"><i data-lucide="clock"></i></div>
                                                        <div class="stat-info">
                                                            <h4>Trang hiện tại</h4>
                                                            <div class="stat-value">${currentPage} / ${totalPages > 0 ?
                                                                totalPages : 1}</div>
                                                        </div>
                                                    </div>
                                                    <div class="stat-card">
                                                        <div class="stat-icon danger"><i data-lucide="filter"></i></div>
                                                        <div class="stat-info">
                                                            <h4>Bộ lọc</h4>
                                                            <div class="stat-value" style="font-size:16px;">
                                                                <c:choose>
                                                                    <c:when test="${statusFilter eq 'All'}">Tất cả
                                                                    </c:when>
                                                                    <c:when test="${statusFilter eq 'Success'}">Thành
                                                                        công</c:when>
                                                                    <c:when test="${statusFilter eq 'PendingPayment'}">
                                                                        Chờ thanh toán</c:when>
                                                                    <c:when test="${statusFilter eq 'Cancelled'}">Đã hủy
                                                                    </c:when>
                                                                    <c:when test="${statusFilter eq 'Completed'}">Đã
                                                                        hoàn thành</c:when>
                                                                    <c:otherwise>${statusFilter}</c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>

                                                <%-- Filter bar --%>
                                                    <form method="get"
                                                        action="${pageContext.request.contextPath}/staff/bookings"
                                                        id="filterForm">
                                                        <div class="filter-bar">
                                                            <div class="search-box">
                                                                <i data-lucide="search"></i>
                                                                <input type="text" name="keyword" value="${keyword}"
                                                                    placeholder="Tìm theo mã booking hoặc tên khách hàng..."
                                                                    id="searchInput">
                                                            </div>
                                                            <div class="filter-group">
                                                                <select name="status" class="filter-select"
                                                                    onchange="this.form.submit()">
                                                                    <option value="All" ${statusFilter eq 'All'
                                                                        ? 'selected' : '' }>Tất cả
                                                                        trạng thái</option>
                                                                    <option value="Success" ${statusFilter eq 'Success'
                                                                        ? 'selected' : '' }>✅ Thành công
                                                                    </option>
                                                                    <option value="PendingPayment" ${statusFilter
                                                                        eq 'PendingPayment' ? 'selected' : '' }>⏳
                                                                        Chờ thanh toán</option>
                                                                    <option value="Cancelled" ${statusFilter
                                                                        eq 'Cancelled' ? 'selected' : '' }>❌
                                                                        Đã hủy</option>
                                                                    <option value="Completed" ${statusFilter
                                                                        eq 'Completed' ? 'selected' : '' }>⚖
                                                                        Đã hoàn thành</option>
                                                                </select>
                                                            </div>
                                                        </div>
                                                    </form>

                                                    <%-- Table --%>
                                                        <div class="modern-card">
                                                            <c:choose>
                                                                <c:when test="${empty bookings}">
                                                                    <div class="empty-state">
                                                                        <i data-lucide="inbox"></i>
                                                                        <h3>Không có booking nào</h3>
                                                                        <p>Thử thay đổi bộ
                                                                            lọc hoặc từ khóa
                                                                            tìm kiếm</p>
                                                                    </div>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <table class="modern-table">
                                                                        <thead>
                                                                            <tr>
                                                                                <th>Mã Booking</th>
                                                                                <th>Khách Hàng</th>
                                                                                <th>Tour</th>
                                                                                <th>Ngày KH</th>
                                                                                <th>Tổng Tiền</th>
                                                                                <th>Trạng Thái</th>
                                                                                <th style="text-align:center;">Thao
                                                                                    Tác</th>
                                                                            </tr>
                                                                        </thead>
                                                                        <tbody>
                                                                            <c:forEach var="b" items="${bookings}">
                                                                                <tr>
                                                                                    <td><span
                                                                                            class="booking-code">${b.bookingCode}</span>
                                                                                    </td>
                                                                                    <td>
                                                                                        <div class="customer-name">
                                                                                            ${b.customer.fullName}</div>
                                                                                        <div class="customer-email">
                                                                                            ${b.customer.email}</div>
                                                                                    </td>
                                                                                    <td>
                                                                                        <div class="tour-name">
                                                                                            ${b.schedule.tour.tourName}
                                                                                        </div>
                                                                                        <div class="tour-dest">
                                                                                            <i data-lucide="map-pin"
                                                                                                style="width:11px;height:11px;"></i>
                                                                                            ${b.schedule.tour.destination}
                                                                                        </div>
                                                                                    </td>
                                                                                    <td>
                                                                                        <fmt:formatDate
                                                                                            value="${b.schedule.departureDate}"
                                                                                            pattern="dd/MM/yyyy" />
                                                                                    </td>
                                                                                    <td class="amount">
                                                                                        <fmt:formatNumber
                                                                                            value="${b.totalAmount}"
                                                                                            type="number"
                                                                                            groupingUsed="true" />
                                                                                        đ
                                                                                    </td>
                                                                                    <td>
                                                                                        <c:choose>
                                                                                            <c:when
                                                                                                test="${b.status eq 'Success'}">
                                                                                                <span
                                                                                                    class="badge badge-success"><i
                                                                                                        data-lucide="check"
                                                                                                        style="width:11px;height:11px;"></i>
                                                                                                    Thành
                                                                                                    công</span>
                                                                                            </c:when>
                                                                                            <c:when
                                                                                                test="${b.status eq 'PendingPayment'}">
                                                                                                <span
                                                                                                    class="badge badge-warning"><i
                                                                                                        data-lucide="clock"
                                                                                                        style="width:11px;height:11px;"></i>
                                                                                                    Chờ TT</span>
                                                                                            </c:when>
                                                                                            <c:when
                                                                                                test="${b.status eq 'Cancelled'}">
                                                                                                <span
                                                                                                    class="badge badge-danger"><i
                                                                                                        data-lucide="x"
                                                                                                        style="width:11px;height:11px;"></i>
                                                                                                    Đã
                                                                                                    hủy</span>
                                                                                            </c:when>
                                                                                            <c:when
                                                                                                test="${b.status eq 'Completed'}">
                                                                                                <span
                                                                                                    class="badge badge-secondary"
                                                                                                    style="background:#EDE9FE;color:#7C3AED;"><i
                                                                                                        data-lucide="flag"
                                                                                                        style="width:11px;height:11px;"></i>
                                                                                                    Đã
                                                                                                    hoàn
                                                                                                    thành</span>
                                                                                            </c:when>
                                                                                            <c:otherwise>
                                                                                                <span
                                                                                                    class="badge badge-secondary">${b.status}</span>
                                                                                            </c:otherwise>
                                                                                        </c:choose>
                                                                                    </td>
                                                                                    <td style="text-align:center;">
                                                                                        <div class="row-actions"
                                                                                            style="justify-content:center;">
                                                                                            <a href="${pageContext.request.contextPath}/staff/guests?action=details&scheduleId=${b.scheduleId}&bookingId=${b.bookingId}"
                                                                                                class="action-btn"
                                                                                                style="background:var(--primary-light); color:var(--primary); text-decoration:none;"
                                                                                                title="Xem danh sách hành khách">
                                                                                                <i data-lucide="users"
                                                                                                    style="width:12px;height:12px;"></i>
                                                                                                Xem Khách
                                                                                            </a>
                                                                                            <button
                                                                                                class="action-btn note"
                                                                                                onclick="openNotifModal(${b.customer.userId}, '${fn:escapeXml(b.customer.fullName)}')"
                                                                                                title="Gửi thông báo cho khách hàng này">
                                                                                                <i data-lucide="bell"
                                                                                                    style="width:12px;height:12px;"></i>
                                                                                                Gửi TB
                                                                                            </button>
                                                                                        </div>
                                                                                    </td>
                                                                                </tr>
                                                                            </c:forEach>
                                                                        </tbody>
                                                                    </table>

                                                                    <%-- Pagination --%>
                                                                        <c:if test="${totalPages > 1}">
                                                                            <div class="pagination">
                                                                                <a href="?status=${statusFilter}&keyword=${keyword}&page=${currentPage - 1}"
                                                                                    class="page-btn ${currentPage le 1 ? 'disabled' : ''}">
                                                                                    <i data-lucide="chevron-left"
                                                                                        style="width:16px;height:16px;"></i>
                                                                                </a>
                                                                                <c:forEach begin="1" end="${totalPages}"
                                                                                    var="p">
                                                                                    <a href="?status=${statusFilter}&keyword=${keyword}&page=${p}"
                                                                                        class="page-btn ${p eq currentPage ? 'active' : ''}">${p}</a>
                                                                                </c:forEach>
                                                                                <a href="?status=${statusFilter}&keyword=${keyword}&page=${currentPage + 1}"
                                                                                    class="page-btn ${currentPage ge totalPages ? 'disabled' : ''}">
                                                                                    <i data-lucide="chevron-right"
                                                                                        style="width:16px;height:16px;"></i>
                                                                                </a>
                                                                            </div>
                                                                        </c:if>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>
                                    </div>
                                </main>
                        </div>

                        <%-- Modal Gui Thong Bao --%>
                            <div class="modal-overlay" id="notifModal">
                                <div class="modal-box">
                                    <div class="modal-header">
                                        <h3><i data-lucide="bell"
                                                style="width:16px;height:16px;vertical-align:middle;"></i> Gửi
                                            Thông Báo</h3>
                                        <button class="modal-close" onclick="closeNotifModal()">
                                            <i data-lucide="x"></i>
                                        </button>
                                    </div>
                                    <form method="post" action="${pageContext.request.contextPath}/staff/bookings">
                                        <input type="hidden" name="action" value="sendNotification">
                                        <input type="hidden" name="customerId" id="modalCustomerId">
                                        <input type="hidden" name="statusFilter" value="${statusFilter}">
                                        <input type="hidden" name="keyword" value="${keyword}">
                                        <input type="hidden" name="page" value="${currentPage}">

                                        <div class="modal-body">
                                            <div class="form-group">
                                                <label>Khách Hàng</label>
                                                <div id="modalCustomerName"
                                                    style="font-weight:600;color:var(--primary);font-size:15px;padding:8px 12px;background:var(--primary-light);border-radius:8px;">
                                                </div>
                                            </div>

                                            <div class="form-group">
                                                <label for="titleInput">Tiêu Đề Thông Báo
                                                    *</label>
                                                <input type="text" id="titleInput" name="title" required
                                                    class="form-control"
                                                    placeholder="Nhập tiêu đề...">
                                            </div>

                                            <div class="form-group">
                                                <label for="contentInput">Nội Dung *</label>
                                                <textarea id="contentInput" name="content" required class="form-control"
                                                    rows="4" placeholder="Nhập nội dung..."></textarea>
                                            </div>

                                            <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
                                                <div class="form-group">
                                                    <label for="categoryInput">Thể Loại</label>
                                                    <select id="categoryInput" name="category" required
                                                        class="form-control">
                                                        <option value="Booking">Đặt chỗ</option>
                                                        <option value="System Announcement">Thông báo hệ
                                                            thống</option>
                                                        <option value="Payment">Thanh toán</option>
                                                        <option value="Tour Update">Cập nhật Tour</option>
                                                        <option value="Promotion">Khuyến mãi</option>
                                                    </select>
                                                </div>
                                                <div class="form-group">
                                                    <label for="scheduledInput">Lên Lịch <span
                                                            style="font-weight:400;color:var(--gray-500);">(tùy
                                                            chọn)</span></label>
                                                    <input type="datetime-local" id="scheduledInput" name="scheduledAt"
                                                        class="form-control">
                                                </div>
                                            </div>
                                            <div
                                                style="font-size:12px;color:var(--gray-500);font-style:italic;margin-top:5px;">
                                                * Thông báo sẽ chỉ được gửi
                                                qua hệ thống (in-app).
                                            </div>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn-modern btn-outline"
                                                onclick="closeNotifModal()">Hủy</button>
                                            <button type="submit" class="btn-modern btn-primary">
                                                <i data-lucide="send" style="width:14px;height:14px;"></i> Gửi
                                                Thông Báo
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <script>
                                lucide.createIcons();

                                // Auto-dismiss toast sau 4 giây
                                const toast = document.getElementById('toastMsg');
                                if (toast) setTimeout(() => toast.style.display = 'none', 4000);

                                // Search on Enter
                                document.getElementById('searchInput')?.addEventListener('keydown', function (e) {
                                    if (e.key === 'Enter') document.getElementById('filterForm').submit();
                                });

                                // Modal gui thong bao
                                function openNotifModal(customerId, customerName) {
                                    document.getElementById('modalCustomerId').value = customerId;
                                    document.getElementById('modalCustomerName').textContent = customerName;
                                    document.getElementById('titleInput').value = '';
                                    document.getElementById('contentInput').value = '';
                                    document.getElementById('scheduledInput').value = '';
                                    document.getElementById('notifModal').classList.add('open');
                                    document.getElementById('titleInput').focus();
                                }

                                function closeNotifModal() {
                                    document.getElementById('notifModal').classList.remove('open');
                                }

                                // Close modal khi click ra ngoai
                                document.getElementById('notifModal')?.addEventListener('click', function (e) {
                                    if (e.target === this) closeNotifModal();
                                });
                            </script>
                    </body>

                    </html>