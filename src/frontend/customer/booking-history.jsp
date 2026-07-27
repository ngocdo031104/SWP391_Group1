<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%--
    Người làm: Dương
    Thời gian tạo: 04/06/2026
    Chức năng: Màn hình lịch sử đặt tour của Khách hàng (UC9 - View Booking History).
    Ý nghĩa: Hiển thị toàn bộ danh sách các booking (đã đặt, đang chờ, đã hủy) của khách hàng hiện tại.
             Hỗ trợ lọc theo tên tour, khoảng ngày đặt và trạng thái booking.
             Mỗi dòng có nút "Xem chi tiết" dẫn sang trang booking-detail.jsp.
--%>
<%-- Nhúng header dùng chung của toàn bộ website --%>
<jsp:include page="/common/header.jsp"/>

<%-- ===================== CSS ===================== --%>
<style>
    body {
        padding-top: 80px;
    }
    .header {
        background: linear-gradient(135deg, #4f46e5, #3b82f6) !important;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1) !important;
    }

    /* Vùng chứa toàn bộ nội dung lịch sử đặt tour */
    .history-container {
        max-width: 1200px;
        margin: 40px auto;
        padding: 0 20px;
    }
    
    /* Tiêu đề trang */
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

    /* Bảng danh sách booking */
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

    /* Badge trạng thái booking */
    .booking-status {
        padding: 6px 12px;
        border-radius: 20px;
        font-size: 0.85rem;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        display: inline-block;
    }

    /* Màu sắc theo từng trạng thái booking */
    .status-pendingpayment { background: #fef3c7; color: #d97706; }
    .status-paid { background: #d1fae5; color: #059669; }
    .status-cancelled { background: #fee2e2; color: #dc2626; }
    .status-completed { background: #dbeafe; color: #2563eb; }

    /* Nút xem chi tiết từng booking */
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
    
    /* Trạng thái rỗng khi chưa có booking nào */
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

    /* Responsive: trên màn hình nhỏ cuộn ngang bảng */
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
    
    /* Khu vực form lọc tìm kiếm */
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

    /* Dropdown gợi ý tên tour khi gõ tìm kiếm */
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

<%-- ===================== NỘI DUNG CHÍNH ===================== --%>
<main class="history-container">

    <%-- Tiêu đề trang --%>
    <div class="history-header">
        <h1>Lịch Sử Đặt Tour</h1>
        <p>Quản lý và theo dõi các chuyến đi của bạn</p>
    </div>

    <%-- Form lọc: Tìm kiếm theo tên tour, ngày đặt và trạng thái booking --%>
    <div class="filter-container">
        <form action="${pageContext.request.contextPath}/customer/booking/history" method="get" class="filter-form" id="historyFilterForm">

            <%-- Ô tìm kiếm tên tour có hỗ trợ autocomplete --%>
            <div class="filter-group" style="flex: 2;">
                <label for="searchName">Tên Tour</label>
                <div class="autocomplete-wrapper">
                    <input type="text" id="searchName" name="searchName" placeholder="Nhập tên tour..." value="${searchName}" autocomplete="off">
                    <div id="autocomplete-list" class="autocomplete-list"></div>
                </div>
            </div>

            <%-- Khoảng ngày đặt tour (từ ngày - đến ngày) --%>
            <div class="filter-group">
                <label for="fromDate">Từ ngày (Ngày đặt)</label>
                <input type="date" id="fromDate" name="fromDate" value="${fromDate}">
            </div>
            <div class="filter-group">
                <label for="toDate">Đến ngày</label>
                <input type="date" id="toDate" name="toDate" value="${toDate}">
            </div>

            <%-- Lọc theo trạng thái booking --%>
            <div class="filter-group">
                <label for="status">Trạng thái</label>
                <select id="status" name="status">
                    <option value="All" ${empty status or status eq 'All' ? 'selected' : ''}>Tất cả</option>
                    <option value="Success" ${status eq 'Success' ? 'selected' : ''}>Thanh toán thành công</option>
                    <option value="Completed" ${status eq 'Completed' ? 'selected' : ''}>Đã hoàn thành</option>
                    <option value="Cancelled" ${status eq 'Cancelled' ? 'selected' : ''}>Đã hủy</option>
                </select>
            </div>

            <%-- Nút thực hiện lọc và nút xóa bộ lọc --%>
            <div class="filter-actions">
                <button type="submit" class="btn-filter">
                    <i data-lucide="search" style="width: 16px; height: 16px;"></i> Lọc
                </button>
                <a href="${pageContext.request.contextPath}/customer/booking/history" class="btn-clear">
                    Xóa lọc
                </a>
            </div>
        </form>
    </div>

    <%-- Phần hiển thị kết quả --%>
    <c:choose>
        <%-- Trường hợp chưa có booking nào: hiển thị trạng thái rỗng và gợi ý khám phá tour --%>
        <c:when test="${empty bookings}">
            <div class="empty-state">
                <i data-lucide="calendar-x" style="width: 48px; height: 48px;"></i>
                <h3>Bạn chưa có chuyến đi nào</h3>
                <p>Khám phá các điểm đến tuyệt vời và bắt đầu hành trình của bạn cùng TourBuddy ngay hôm nay.</p>
                <a href="${pageContext.request.contextPath}/tourdiscovery" class="btn btn-view-detail">Khám phá Tour</a>
            </div>
        </c:when>

        <%-- Trường hợp có dữ liệu: hiển thị bảng danh sách các booking --%>
        <c:otherwise>
            <div class="booking-table-wrapper">
                <table class="booking-table">
                    <thead>
                        <tr>
                            <th>Mã đơn</th>
                            <th>Tên Tour</th>
                            <th>Ngày đặt</th>
                            <th>Giờ đặt</th>
                            <th>Trạng thái</th>
                            <th style="text-align: right;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%-- Lặp qua từng booking và render thành 1 dòng trong bảng --%>
                        <c:forEach var="booking" items="${bookings}">
                            <tr>
                                <%-- Mã đơn đặt tour --%>
                                <td>
                                    <span class="booking-code">#${booking.bookingCode}</span>
                                </td>
                                <%-- Tên tour (lấy qua booking → schedule → tour) --%>
                                <td>
                                    <span style="font-weight:500; color:#1e293b;">
                                        ${booking.schedule.tour.tourName}
                                    </span>
                                </td>
                                <%-- Ngày đặt tour --%>
                                <td>
                                    <fmt:formatDate value="${booking.createdAt}" pattern="dd/MM/yyyy" />
                                </td>
                                <%-- Giờ đặt tour --%>
                                <td>
                                    <fmt:formatDate value="${booking.createdAt}" pattern="HH:mm" />
                                </td>
                                <%-- Badge trạng thái hiển thị tên tiếng Việt tương ứng --%>
                                <td>
                                    <span class="booking-status status-${booking.status.toLowerCase()}">
                                        <c:choose>
                                            <c:when test="${booking.status eq 'PendingPayment'}">Chờ thanh toán</c:when>
                                            <c:when test="${booking.status eq 'Success'}">Thanh toán thành công</c:when>
                                            <c:when test="${booking.status eq 'Cancelled'}">Đã hủy</c:when>
                                            <c:when test="${booking.status eq 'Completed'}">Đã hoàn thành</c:when>
                                            <c:otherwise>${booking.status}</c:otherwise>
                                        </c:choose>
                                    </span>
                                </td>
                                <%-- Nút xem chi tiết dẫn sang trang booking-detail.jsp với bookingCode --%>
                                <td style="text-align: right;">
                                    <a href="${pageContext.request.contextPath}/customer/booking/detail?code=${booking.bookingCode}" class="btn-view-detail">
                                        Xem chi tiết <i data-lucide="arrow-right" style="width: 14px; height: 14px;"></i>
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

<%-- ===================== JAVASCRIPT ===================== --%>
<script>
    lucide.createIcons();

    // Kiểm tra khoảng ngày hợp lệ trước khi submit form lọc
    document.getElementById('historyFilterForm').addEventListener('submit', function(e) {
        const fromDateStr = document.getElementById('fromDate').value;
        const toDateStr = document.getElementById('toDate').value;
        if (fromDateStr && toDateStr) {
            if (new Date(fromDateStr) > new Date(toDateStr)) {
                alert('Từ ngày không thể lớn hơn Đến ngày. Vui lòng chọn lại!');
                e.preventDefault();
                return;
            }
        }
    });

    // Lọc bảng ngay trên client khi người dùng gõ tên tour (không cần reload trang)
    const searchInput = document.getElementById('searchName');
    const tableBody = document.querySelector('.booking-table tbody');

    // Hàm chuẩn hóa chuỗi: bỏ dấu tiếng Việt để tìm kiếm không phân biệt dấu
    function removeDiacritics(str) {
        return str.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').replace(/Đ/g, 'D');
    }

    // Hàm ẩn/hiện các dòng trong bảng dựa theo từ khóa tìm kiếm
    function filterTableByTourName(keyword) {
        if (!tableBody) return;
        const rows = tableBody.querySelectorAll('tr');
        const normalizedKeyword = removeDiacritics(keyword.trim().toLowerCase());
        rows.forEach(function(row) {
            // Tên tour nằm ở cột thứ 2 (index 1) trong mỗi dòng
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
        // Chạy lọc ngay khi trang được load với giá trị đã điền sẵn (nếu có)
        filterTableByTourName(searchInput.value);

        // Lắng nghe sự kiện người dùng gõ vào ô tìm kiếm
        searchInput.addEventListener('input', function() {
            filterTableByTourName(this.value);
        });
    }
</script>

<%-- Nhúng footer dùng chung của toàn bộ website --%>
<jsp:include page="/common/footer.jsp"/>
