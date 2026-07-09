<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%
    // Người làm: Dương
    // Thời gian tạo: 04/06/2026
    // Chức năng: Màn Customer hoàn tất booking.
    // Ý nghĩa: Hiển thị mã booking sau khi SePay ghi nhận thanh toán và đơn chuyển sang trạng thái Success.

    // Nạp CSS riêng cho màn success và giữ bodyClass booking-page để dùng chung layout booking.
    request.setAttribute("extraCss", "css/customer-booking-success.css");
    request.setAttribute("bodyClass", "booking-page");

    // bookingCode được BookingSuccessController lấy từ query string để khách lưu lại mã giao dịch.
    String bookingCode = (String) request.getAttribute("bookingCode");
%>
<jsp:include page="/common/header.jsp"/>

<main class="booking-shell">
    <%-- Dương làm đoạn này: nút quay lại dùng chung cho các màn trong luồng booking để khách có thể trở về bước trước. --%>
    <button type="button" class="booking-back-btn" onclick="window.location.href='${pageContext.request.contextPath}/home'" aria-label="Về trang chủ" title="Về trang chủ">
        <i data-lucide="arrow-left"></i>
    </button>
    <%-- Thanh tiến trình đánh dấu toàn bộ các bước đã hoàn tất. --%>
    <section class="booking-progress" aria-label="Tiến trình đặt tour">
        <div class="progress-step done"><span>1</span><strong>Đặt tour</strong><small>Booking creation</small></div>
        <div class="progress-line"></div>
        <div class="progress-step done"><span>2</span><strong>Chi tiết đơn</strong><small>Booking review</small></div>
        <div class="progress-line"></div>
        <div class="progress-step done"><span>3</span><strong>Thanh toán</strong><small>Payment processing</small></div>
        <div class="progress-line"></div>
        <div class="progress-step active done"><span>4</span><strong>Hoàn tất</strong><small>Success screen</small></div>
    </section>

    <div class="booking-layout">
        <%-- Khối thông báo thành công hiển thị mã booking để khách đối chiếu khi cần hỗ trợ. --%>
        <section class="booking-main-panel success-box">
            <i data-lucide="badge-check"></i>
            <h1>Đã ghi nhận thanh toán</h1>
            <p>Mã booking của bạn là <strong><%= bookingCode %></strong>. Đơn đã được ghi nhận thanh toán và chuyển sang trạng thái Success.</p>
            <div style="display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap; margin-top: 1rem;">
                <a class="booking-primary-btn inline-link" href="${pageContext.request.contextPath}/customer/booking/invoice?code=<%= bookingCode %>">
                    <i data-lucide="file-text" style="width:16px;height:16px;vertical-align:middle;margin-right:6px;"></i>Xem hóa đơn
                </a>
                <a class="booking-primary-btn inline-link" href="${pageContext.request.contextPath}/home">Về trang chủ</a>
            </div>
        </section>
    </div>
</main>

<jsp:include page="/common/footer.jsp"/>
