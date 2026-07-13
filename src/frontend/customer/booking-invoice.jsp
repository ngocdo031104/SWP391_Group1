<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // Người làm: Dương
    // Thời gian tạo: 25/06/2026
    // Chức năng: Giao diện hiển thị hóa đơn thanh toán của khách hàng sau khi đặt tour thành công.
    // Ý nghĩa: Trang này nhận dữ liệu từ CustomerInvoiceController (booking + invoice),
    //           hiển thị 3 phần: thông tin tour, danh sách hành khách, và chi tiết số tiền.
    //           Hỗ trợ in hóa đơn qua nút "In hóa đơn" sử dụng CSS @media print.

    request.setAttribute("extraCss", "css/customer-booking-invoice.css");
    request.setAttribute("bodyClass", "booking-page");
%>
<jsp:include page="/common/header.jsp"/>

<main class="booking-shell">
    <%-- Nút quay lại dùng window.history.back() để trở về trang trước trong lịch sử trình duyệt --%>
    <button type="button" class="booking-back-btn" onclick="window.history.back()" aria-label="Quay lại" title="Quay lại">
        <i data-lucide="arrow-left"></i>
    </button>

    <div class="invoice-container">
        <c:choose>
            <%-- Hiển thị thông báo lỗi nếu controller truyền attribute "error" (ví dụ: không tìm thấy booking) --%>
            <c:when test="${not empty error}">
                <div class="error-message"><p>${error}</p></div>
            </c:when>
            <%-- Hiển thị thông báo nếu hóa đơn chưa được tạo (webhook chưa kịp xử lý hoặc payment thất bại) --%>
            <c:when test="${empty invoice}">
                <div class="error-message"><p>Hóa đơn chưa được tạo hoặc không tồn tại cho đơn hàng này.</p></div>
            </c:when>
            <c:otherwise>

                <%-- ===== PHẦN 1: HEADER HÓA ĐƠN ===== --%>
                <%-- Hiển thị mã hóa đơn, ngày lập và thông tin liên hệ thương hiệu --%>
                <div class="invoice-header">
                    <div>
                        <h1><i data-lucide="file-text"></i> HÓA ĐƠN THANH TOÁN</h1>
                        <p><strong>Mã hóa đơn:</strong> ${invoice.invoiceCode}</p>
                        <p><strong>Ngày lập:</strong>
                            <fmt:formatDate value="${invoice.issuedAt}" pattern="dd/MM/yyyy HH:mm"/>
                        </p>
                    </div>
                    <div class="invoice-brand">
                        <p class="brand-name">TourBuddy</p>
                        <p>support@tourbuddy.com</p>
                        <p><strong>Mã booking:</strong> ${booking.bookingCode}</p>
                    </div>
                </div>

                <%-- ===== PHẦN 2: THÔNG TIN TOUR ===== --%>
                <%-- Chỉ hiển thị nếu booking.schedule không null (tức là controller dùng getBookingWithTourByCode) --%>
                <c:if test="${not empty booking.schedule}">
                    <div class="invoice-section">
                        <h2 class="invoice-section-title"><i data-lucide="map-pin"></i> Thông tin tour</h2>
                        <div class="invoice-tour-grid">
                            <div class="invoice-tour-item">
                                <span class="label">Tên tour</span>
                                <span class="value">${booking.schedule.tour.tourName}</span>
                            </div>
                            <div class="invoice-tour-item">
                                <span class="label">Điểm đến</span>
                                <span class="value">${booking.schedule.tour.destination}</span>
                            </div>
                            <div class="invoice-tour-item">
                                <span class="label">Ngày khởi hành</span>
                                <span class="value">
                                    <fmt:formatDate value="${booking.schedule.departureDate}" pattern="dd/MM/yyyy"/>
                                </span>
                            </div>
                            <div class="invoice-tour-item">
                                <span class="label">Ngày về</span>
                                <span class="value">
                                    <fmt:formatDate value="${booking.schedule.returnDate}" pattern="dd/MM/yyyy"/>
                                </span>
                            </div>
                            <div class="invoice-tour-item">
                                <span class="label">Thời gian</span>
                                <span class="value">${booking.schedule.tour.durationDays} ngày</span>
                            </div>
                            <%-- Chỉ hiện phương tiện nếu dữ liệu tồn tại, tránh ô trống trên hóa đơn --%>
                            <c:if test="${not empty booking.schedule.transportation}">
                                <div class="invoice-tour-item">
                                    <span class="label">Phương tiện</span>
                                    <span class="value">${booking.schedule.transportation}</span>
                                </div>
                            </c:if>
                            <div class="invoice-tour-item">
                                <span class="label">Số người</span>
                                <span class="value">${booking.numParticipants} người</span>
                            </div>
                        </div>
                    </div>
                </c:if>

                <%-- ===== PHẦN 3: DANH SÁCH HÀNH KHÁCH ===== --%>
                <%-- Lặp qua booking.participants, hiển thị loại vé và đánh dấu trưởng đoàn --%>
                <c:if test="${not empty booking.participants}">
                    <div class="invoice-section">
                        <h2 class="invoice-section-title"><i data-lucide="users"></i> Danh sách hành khách</h2>
                        <table class="invoice-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Họ tên</th>
                                    <th>Loại</th>
                                    <th>Liên hệ</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="p" items="${booking.participants}" varStatus="s">
                                    <tr>
                                        <td>${s.index + 1}</td>
                                        <td>
                                            ${p.fullName}
                                            <%-- Badge "Trưởng đoàn" chỉ hiện cho người có isLeader = true --%>
                                            <c:if test="${p.isLeader}">
                                                <span class="badge-leader">Trưởng đoàn</span>
                                            </c:if>
                                        </td>
                                        <td>
                                            <%-- Chuyển AgeType từ tiếng Anh sang tiếng Việt --%>
                                            <c:choose>
                                                <c:when test="${p.ageType == 'Adult'}">Người lớn</c:when>
                                                <c:when test="${p.ageType == 'Child'}">Trẻ em</c:when>
                                                <c:otherwise>Em bé</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <%-- Ưu tiên hiển thị số điện thoại, nếu không có thì dùng email --%>
                                        <td>${not empty p.phoneNumber ? p.phoneNumber : p.email}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:if>

                <%-- ===== PHẦN 4: BẢNG CHI TIẾT THANH TOÁN ===== --%>
                <%-- Hiển thị tiền gốc, VAT, giảm giá (nếu có) và tổng cộng --%>
                <div class="invoice-section">
                    <h2 class="invoice-section-title"><i data-lucide="receipt"></i> Chi tiết thanh toán</h2>
                    <table class="invoice-table">
                        <thead>
                            <tr>
                                <th>Khoản mục</th>
                                <th style="text-align: right;">Số tiền</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Tiền tour gốc</td>
                                <td style="text-align: right;">
                                    <fmt:formatNumber value="${invoice.subTotal}" type="number" groupingUsed="true"/> ₫
                                </td>
                            </tr>
                            <tr>
                                <td>Thuế VAT (${invoice.vatRate}%)</td>
                                <td style="text-align: right;">
                                    <fmt:formatNumber value="${invoice.vatAmount}" type="number" groupingUsed="true"/> ₫
                                </td>
                            </tr>
                            <%-- Dòng giảm giá chỉ hiện khi khách dùng coupon (discountAmount > 0) --%>
                            <c:if test="${invoice.discountAmount > 0}">
                                <tr class="discount-row">
                                    <td>Giảm giá (coupon)</td>
                                    <td style="text-align: right;">
                                        - <fmt:formatNumber value="${invoice.discountAmount}" type="number" groupingUsed="true"/> ₫
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                        <tfoot>
                            <tr class="total-row">
                                <td><strong>Tổng cộng</strong></td>
                                <td style="text-align: right;">
                                    <strong><fmt:formatNumber value="${invoice.totalAmount}" type="number" groupingUsed="true"/> ₫</strong>
                                </td>
                            </tr>
                        </tfoot>
                    </table>
                </div>

                <%-- ===== ACTIONS ===== --%>
                <%-- Nút in sử dụng window.print(), CSS @media print sẽ ẩn các thành phần không cần thiết --%>
                <div class="invoice-actions">
                    <button class="btn-print" onclick="window.print()">
                        <i data-lucide="printer"></i> In hóa đơn
                    </button>
                    <a class="booking-primary-btn" href="${pageContext.request.contextPath}/home">Về trang chủ</a>
                </div>

            </c:otherwise>
        </c:choose>
    </div>
</main>

<jsp:include page="/common/footer.jsp"/>
