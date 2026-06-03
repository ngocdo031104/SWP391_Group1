<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Người làm: Dương
    // Thời gian tạo: 04/06/2026
    // Chức năng: Màn Customer hoàn tất booking.
    // Ý nghĩa: Hiển thị mã booking sau khi thanh toán thành công và hệ thống đã cập nhật trạng thái đơn.

    // Nạp CSS riêng cho màn success và giữ bodyClass booking-page để dùng chung layout booking.
    request.setAttribute("extraCss", "css/customer-booking-success.css");
    request.setAttribute("bodyClass", "booking-page");

    // bookingCode được BookingSuccessController lấy từ query string để khách lưu lại mã giao dịch.
    String bookingCode = (String) request.getAttribute("bookingCode");
%>
<jsp:include page="/common/header.jsp"/>

<main class="booking-shell">
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
            <h1>Đặt tour thành công</h1>
            <p>Mã booking của bạn là <strong><%= bookingCode %></strong>. Đơn đã được ghi nhận và chuyển sang trạng thái Confirmed.</p>
            <a class="booking-primary-btn inline-link" href="${pageContext.request.contextPath}/home">Về trang chủ</a>
        </section>
    </div>
</main>

<jsp:include page="/common/footer.jsp"/>
