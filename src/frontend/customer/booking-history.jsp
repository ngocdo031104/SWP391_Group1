<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%--
    Người làm: Dương
    Ý nghĩa: Màn hình hiển thị lịch sử đặt tour của khách hàng.
--%>
<jsp:include page="/common/header.jsp"/>

<style>
    .history-container {
        max-width: 1200px;
        margin: 40px auto;
        padding: 0 20px;
    }
    
    .history-header {
        margin-bottom: 30px;
        border-bottom: 2px solid #f1f5f9;
        padding-bottom: 15px;
    }
    
    .history-header h1 {
        font-family: 'Outfit', sans-serif;
        font-size: 2rem;
        color: #1e293b;
        margin: 0;
    }
    
    .history-header p {
        color: #64748b;
        margin-top: 5px;
    }

    .booking-table-wrapper {
        background: #ffffff;
        border-radius: 12px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
        border: 1px solid #e2e8f0;
        overflow: hidden;
    }

    .booking-table {
        width: 100%;
        border-collapse: collapse;
    }

    .booking-table th {
        background: #f8fafc;
        color: #475569;
        font-weight: 600;
        text-align: left;
        padding: 16px 20px;
        font-size: 0.95rem;
        border-bottom: 2px solid #e2e8f0;
    }

    .booking-table td {
        padding: 16px 20px;
        border-bottom: 1px solid #e2e8f0;
        vertical-align: middle;
        color: #1e293b;
    }

    .booking-table tbody tr:last-child td {
        border-bottom: none;
    }

    .booking-table tbody tr {
        transition: background-color 0.2s;
    }

    .booking-table tbody tr:hover {
        background-color: #f8fafc;
    }

    .booking-code {
        font-weight: 600;
        color: #0f172a;
    }

    .booking-status {
        padding: 6px 12px;
        border-radius: 20px;
        font-size: 0.85rem;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        display: inline-block;
    }

    .status-pendingpayment { background: #fef3c7; color: #d97706; }
    .status-paid { background: #d1fae5; color: #059669; }
    .status-cancelled { background: #fee2e2; color: #dc2626; }
    .status-completed { background: #dbeafe; color: #2563eb; }

    .btn-view-detail {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 8px 16px;
        background: #3b82f6;
        color: white;
        text-decoration: none;
        border-radius: 6px;
        font-weight: 500;
        transition: background 0.2s;
        font-size: 0.9rem;
    }

    .btn-view-detail:hover {
        background: #2563eb;
        color: white;
    }
    
    .empty-state {
        text-align: center;
        padding: 60px 20px;
        background: #f8fafc;
        border-radius: 12px;
        border: 2px dashed #cbd5e1;
    }
    
    .empty-state i {
        color: #94a3b8;
        margin-bottom: 15px;
    }
    
    .empty-state h3 {
        color: #334155;
        font-family: 'Outfit', sans-serif;
        margin-bottom: 10px;
    }
    
    .empty-state p {
        color: #64748b;
        margin-bottom: 20px;
    }

    @media (max-width: 768px) {
        .booking-table-wrapper {
            overflow-x: auto;
        }
        .booking-table {
            min-width: 800px;
        }
        .filter-form {
            flex-direction: column;
        }
        .filter-group {
            width: 100%;
        }
        .filter-actions {
            width: 100%;
            justify-content: flex-end;
        }
    }
    
    .filter-container {
        background: #ffffff;
        padding: 20px;
        border-radius: 12px;
        border: 1px solid #e2e8f0;
        margin-bottom: 25px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    }
    .filter-form {
        display: flex;
        flex-wrap: wrap;
        gap: 15px;
        align-items: flex-end;
    }
    .filter-group {
        display: flex;
        flex-direction: column;
        flex: 1;
        min-width: 180px;
    }
    .filter-group label {
        font-size: 0.85rem;
        font-weight: 600;
        color: #475569;
        margin-bottom: 6px;
    }
    .filter-group input, .filter-group select {
        padding: 8px 12px;
        border: 1px solid #cbd5e1;
        border-radius: 6px;
        font-size: 0.95rem;
        color: #1e293b;
        outline: none;
        transition: border-color 0.2s;
    }
    .filter-group input:focus, .filter-group select:focus {
        border-color: #3b82f6;
    }
    .filter-actions {
        display: flex;
        gap: 10px;
    }
    .btn-filter {
        padding: 8px 20px;
        background: #3b82f6;
        color: white;
        border: none;
        border-radius: 6px;
        font-weight: 500;
        cursor: pointer;
        transition: background 0.2s;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }
    .btn-filter:hover {
        background: #2563eb;
    }
    .btn-clear {
        padding: 8px 16px;
        background: #f1f5f9;
        color: #475569;
        border: 1px solid #cbd5e1;
        border-radius: 6px;
        font-weight: 500;
        text-decoration: none;
        transition: all 0.2s;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }
    .btn-clear:hover {
        background: #e2e8f0;
        color: #1e293b;
    }

    /* Autocomplete styles */
    .autocomplete-wrapper {
        position: relative;
        width: 100%;
    }
    .autocomplete-list {
        position: absolute;
        top: 100%;
        left: 0;
        right: 0;
        background: #fff;
        border: 1px solid #cbd5e1;
        border-radius: 0 0 6px 6px;
        border-top: none;
        max-height: 200px;
        overflow-y: auto;
        z-index: 1000;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        display: none;
    }
    .autocomplete-item {
        padding: 10px 12px;
        cursor: pointer;
        font-size: 0.95rem;
        color: #1e293b;
        transition: background 0.2s;
    }
    .autocomplete-item:hover, .autocomplete-item.active {
        background: #f1f5f9;
        color: #3b82f6;
    }
</style>

<main class="history-container">
    <div class="history-header">
        <h1>L&#7883;ch S&#7917; &#272;&#7863;t Tour</h1>
        <p>Qu&#7843;n l&#253; v&#224; theo d&#245;i c&#225;c chuy&#7871;n &#273;i c&#7911;a b&#7841;n</p>
    </div>

    <div class="filter-container">
        <form action="${pageContext.request.contextPath}/customer/booking/history" method="get" class="filter-form" id="historyFilterForm">
            <div class="filter-group" style="flex: 2;">
                <label for="searchName">T&#234;n Tour</label>
                <div class="autocomplete-wrapper">
                    <input type="text" id="searchName" name="searchName" placeholder="Nh&#7853;p t&#234;n tour..." value="${searchName}" autocomplete="off">
                    <div id="autocomplete-list" class="autocomplete-list"></div>
                </div>
            </div>
            <div class="filter-group">
                <label for="fromDate">T&#7915; ng&#224;y (Ng&#224;y &#273;&#7863;t)</label>
                <input type="date" id="fromDate" name="fromDate" value="${fromDate}">
            </div>
            <div class="filter-group">
                <label for="toDate">&#272;&#7871;n ng&#224;y</label>
                <input type="date" id="toDate" name="toDate" value="${toDate}">
            </div>
            <div class="filter-group">
                <label for="status">Tr&#7841;ng th&#225;i</label>
                <select id="status" name="status">
                    <option value="All" ${empty status or status eq 'All' ? 'selected' : ''}>T&#7845;t c&#7843;</option>
                    <option value="Success" ${status eq 'Success' ? 'selected' : ''}>Thanh to&#225;n th&#224;nh c&#244;ng</option>
                    <option value="Completed" ${status eq 'Completed' ? 'selected' : ''}>&#272;&#227; ho&#224;n th&#224;nh</option>
                    <option value="Cancelled" ${status eq 'Cancelled' ? 'selected' : ''}>&#272;&#227; h&#7911;y</option>
                </select>
            </div>
            <div class="filter-actions">
                <button type="submit" class="btn-filter">
                    <i data-lucide="search" style="width: 16px; height: 16px;"></i> L&#7885;c
                </button>
                <a href="${pageContext.request.contextPath}/customer/booking/history" class="btn-clear">
                    X&#243;a l&#7885;c
                </a>
            </div>
        </form>
    </div>

    <c:choose>
        <c:when test="${empty bookings}">
            <div class="empty-state">
                <i data-lucide="calendar-x" style="width: 48px; height: 48px;"></i>
                <h3>B&#7841;n ch&#432;a c&#243; chuy&#7871;n &#273;i n&#224;o</h3>
                <p>Kh&#225;m ph&#225; c&#225;c &#273;i&#7875;m &#273;&#7871;n tuy&#7879;t v&#7901;i v&#224; b&#7855;t &#273;&#7847;u h&#224;nh tr&#236;nh c&#7911;a b&#7841;n c&#249;ng TourBuddy ngay h&#244;m nay.</p>
                <a href="${pageContext.request.contextPath}/tourdiscovery" class="btn btn-view-detail">Kh&#225;m ph&#225; Tour</a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="booking-table-wrapper">
                <table class="booking-table">
                    <thead>
                        <tr>
                            <th>M&#227; &#273;&#417;n</th>
                            <th>T&#234;n Tour</th>
                            <th>Ng&#224;y &#273;&#7863;t</th>
                            <th>Gi&#7901; &#273;&#7863;t</th>
                            <th>Tr&#7841;ng th&#225;i</th>
                            <th style="text-align: right;">Thao t&#225;c</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="booking" items="${bookings}">
                            <tr>
                                <td>
                                    <span class="booking-code">#${booking.bookingCode}</span>
                                </td>
                                <td>
                                    <span style="font-weight:500; color:#1e293b;">
                                        ${booking.schedule.tour.tourName}
                                    </span>
                                </td>
                                <td>
                                    <fmt:formatDate value="${booking.createdAt}" pattern="dd/MM/yyyy" />
                                </td>
                                <td>
                                    <fmt:formatDate value="${booking.createdAt}" pattern="HH:mm" />
                                </td>
                                <td>
                                    <span class="booking-status status-${booking.status.toLowerCase()}">
                                        <c:choose>
                                            <c:when test="${booking.status eq 'PendingPayment'}">Ch&#7901; thanh to&#225;n</c:when>
                                            <c:when test="${booking.status eq 'Success'}">Thanh to&#225;n th&#224;nh c&#244;ng</c:when>
                                            <c:when test="${booking.status eq 'Cancelled'}">&#272;&#227; h&#7911;y</c:when>
                                            <c:when test="${booking.status eq 'Completed'}">&#272;&#227; ho&#224;n th&#224;nh</c:when>
                                            <c:otherwise>${booking.status}</c:otherwise>
                                        </c:choose>
                                    </span>
                                </td>
                                <td style="text-align: right;">
                                    <a href="${pageContext.request.contextPath}/customer/booking/detail?code=${booking.bookingCode}" class="btn-view-detail">
                                        Xem chi ti&#7871;t <i data-lucide="arrow-right" style="width: 14px; height: 14px;"></i>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:otherwise>
    </c:choose>
</main>

<script>
    lucide.createIcons();

    // Date validation before submit
    document.getElementById('historyFilterForm').addEventListener('submit', function(e) {
        const fromDateStr = document.getElementById('fromDate').value;
        const toDateStr = document.getElementById('toDate').value;
        if (fromDateStr && toDateStr) {
            if (new Date(fromDateStr) > new Date(toDateStr)) {
                alert('T\u1eeb ng\u00e0y kh\u00f4ng th\u1ec3 l\u1edbn h\u01a1n \u0110\u1ebfn ng\u00e0y. Vui l\u00f2ng ch\u1ecdn l\u1ea1i!');
                e.preventDefault();
                return;
            }
        }
    });

    // Real-time filter table rows by tour name as user types
    const searchInput = document.getElementById('searchName');
    const tableBody = document.querySelector('.booking-table tbody');

    // B\u1ecf d\u1ea5u ti\u1ebfng Vi\u1ec7t \u0111\u1ec3 t\u00ecm ki\u1ebfm kh\u00f4ng ph\u00e2n bi\u1ec7t d\u1ea5u
    function removeDiacritics(str) {
        return str.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/\u0111/g, 'd').replace(/\u0110/g, 'D');
    }

    function filterTableByTourName(keyword) {
        if (!tableBody) return;
        const rows = tableBody.querySelectorAll('tr');
        const normalizedKeyword = removeDiacritics(keyword.trim().toLowerCase());
        rows.forEach(function(row) {
            // Tour name is the 2nd td
            const tourNameCell = row.querySelectorAll('td')[1];
            if (!tourNameCell) return;
            const normalizedTour = removeDiacritics(tourNameCell.textContent.trim().toLowerCase());
            if (normalizedKeyword === '' || normalizedTour.includes(normalizedKeyword)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    }

    if (searchInput) {
        // Run on page load in case search value is pre-filled
        filterTableByTourName(searchInput.value);

        searchInput.addEventListener('input', function() {
            filterTableByTourName(this.value);
        });
    }
</script>

<jsp:include page="/common/footer.jsp"/>

