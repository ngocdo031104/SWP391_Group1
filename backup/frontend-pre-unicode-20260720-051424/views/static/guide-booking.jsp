<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<jsp:include page="/common/header.jsp" />

<div class="container" style="margin-top: 120px; margin-bottom: 60px; max-width: 800px; font-family: 'Inter', sans-serif;">
    <h1 style="font-family: 'Outfit', sans-serif; font-size: 2.5rem; color: #1e1b4b; text-align: center; margin-bottom: 10px;">Hướng Dẫn Đặt Tour</h1>
    <p style="text-align: center; color: #64748b; margin-bottom: 40px; font-size: 1.1rem;">Hướng dẫn các bước đặt tour đơn giản và thanh toán an toàn tại TourBuddy.</p>

    <div style="background: #ffffff; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); padding: 30px;">
        <div style="margin-bottom: 30px;">
            <h3 style="font-family: 'Outfit', sans-serif; color: #4f46e5; margin-bottom: 10px;">Bước 1: Tìm kiếm hành trình</h3>
            <p style="color: #475569; line-height: 1.6;">Truy cập trang <a href="${pageContext.request.contextPath}/tourdiscovery" style="color: #4f46e5; text-decoration: none; font-weight: 500;">Tìm kiếm Tour</a>, lựa chọn điểm đến, ngày khởi hành phù hợp và phân loại bộ lọc mong muốn ở thanh bên trái.</p>
        </div>

        <div style="margin-bottom: 30px;">
            <h3 style="font-family: 'Outfit', sans-serif; color: #4f46e5; margin-bottom: 10px;">Bước 2: Xem chi tiết và chọn lịch trình</h3>
            <p style="color: #475569; line-height: 1.6;">Click vào tour để xem thông tin chi tiết về điểm đến, khách sạn, lịch trình các ngày, giá cả và đánh giá. Ở sidebar bên phải, chọn ngày khởi hành thực tế của bạn.</p>
        </div>

        <div style="margin-bottom: 30px;">
            <h3 style="font-family: 'Outfit', sans-serif; color: #4f46e5; margin-bottom: 10px;">Bước 3: Điền thông tin hành khách</h3>
            <p style="color: #475569; line-height: 1.6;">Sau khi ấn đặt tour, bạn sẽ điền số lượng khách (người lớn, trẻ em), nhập thông tin liên lạc và có thể áp dụng mã giảm giá (coupon) để nhận chiết khấu trực tiếp.</p>
        </div>

        <div style="margin-bottom: 30px;">
            <h3 style="font-family: 'Outfit', sans-serif; color: #4f46e5; margin-bottom: 10px;">Bước 4: Thanh toán và nhận vé</h3>
            <p style="color: #475569; line-height: 1.6;">Thực hiện chuyển khoản quét mã QR hoặc sử dụng cổng thanh toán VNPAY/SePay bảo mật. Khi hệ thống xác thực thanh toán thành công, vé điện tử và hóa đơn sẽ lập tức được gửi đến email đăng ký của bạn.</p>
        </div>
    </div>
</div>

<jsp:include page="/common/footer.jsp" />
