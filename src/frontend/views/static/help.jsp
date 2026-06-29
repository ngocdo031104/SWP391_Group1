<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/common/header.jsp" />

<div class="container" style="margin-top: 120px; margin-bottom: 60px; max-width: 800px; font-family: 'Inter', sans-serif;">
    <h1 style="font-family: 'Outfit', sans-serif; font-size: 2.5rem; color: #1e1b4b; text-align: center; margin-bottom: 10px;">Trung Tâm Trợ Giúp & FAQ</h1>
    <p style="text-align: center; color: #64748b; margin-bottom: 40px; font-size: 1.1rem;">Giải đáp mọi thắc mắc và cung cấp cẩm nang hỗ trợ bạn nhanh nhất.</p>

    <div style="background: #ffffff; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); padding: 30px;">
        <h2 style="font-family: 'Outfit', sans-serif; color: #4f46e5; border-bottom: 2px solid #e2e8f0; padding-bottom: 10px; margin-top: 0; font-size: 1.5rem;">1. Câu hỏi thường gặp</h2>
        
        <div style="margin-top: 20px;">
            <h3 style="font-size: 1.1rem; color: #0f172a; margin-bottom: 8px;">Q: Làm thế nào để đặt tour trên TourBuddy?</h3>
            <p style="color: #475569; line-height: 1.6; margin-bottom: 20px;">A: Bạn chỉ cần chọn tour mong muốn, click "Đăng ký tham gia ngay" ở cột bên phải, đăng nhập tài khoản và điền thông tin đặt chỗ. Sau khi hoàn tất đăng ký, lịch trình sẽ hiển thị trong phần "Đơn đặt chỗ" của bạn.</p>
        </div>

        <div style="margin-top: 20px;">
            <h3 style="font-size: 1.1rem; color: #0f172a; margin-bottom: 8px;">Q: Làm thế nào để tìm bạn đồng hành (Tour Buddy)?</h3>
            <p style="color: #475569; line-height: 1.6; margin-bottom: 20px;">A: Truy cập vào mục "Mạng Lưới Buddy" trong menu tài khoản. Bạn có thể thiết lập sở thích du lịch cá nhân để hệ thống tự động tìm kiếm và gợi ý những người bạn đồng hành phù hợp nhất với hành trình của bạn.</p>
        </div>

        <div style="margin-top: 20px;">
            <h3 style="font-size: 1.1rem; color: #0f172a; margin-bottom: 8px;">Q: Tôi có thể hủy tour và hoàn tiền không?</h3>
            <p style="color: #475569; line-height: 1.6; margin-bottom: 20px;">A: Hoàn toàn có thể. Tùy thuộc vào thời gian hủy tour trước ngày khởi hành dự kiến, bạn sẽ nhận được phần tiền hoàn trả tương ứng theo đúng <a href="${pageContext.request.contextPath}/policy/cancel" style="color: #4f46e5; text-decoration: none; font-weight: 500;">Chính sách hủy tour</a> của chúng tôi.</p>
        </div>

        <h2 style="font-family: 'Outfit', sans-serif; color: #4f46e5; border-bottom: 2px solid #e2e8f0; padding-bottom: 10px; margin-top: 40px; font-size: 1.5rem;">2. Liên hệ trực tiếp</h2>
        <p style="color: #475569; line-height: 1.6; margin-bottom: 25px;">Nếu bạn không tìm thấy câu trả lời phù hợp, vui lòng liên hệ ngay với bộ phận hỗ trợ khách hàng 24/7 của chúng tôi.</p>
        <a href="${pageContext.request.contextPath}/contact" class="btn btn-primary" style="display: inline-flex; align-items: center; text-decoration: none;">Gửi Yêu Cầu Liên Hệ &rarr;</a>
    </div>
</div>

<jsp:include page="/common/footer.jsp" />
