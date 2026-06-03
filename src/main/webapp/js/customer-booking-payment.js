/*
 * Người làm: Dương
 * Thời gian tạo: 04/06/2026
 * Chức năng: JavaScript cho màn Customer thanh toán booking.
 * Ý nghĩa: Cho khách biết coupon sẽ được kiểm tra khi bấm thực hiện thanh toán, tránh submit nhầm khi chỉ bấm áp dụng.
 */
(function () {
    // couponBtn là nút "Áp dụng" ở khung coupon, chỉ hiển thị hướng dẫn chứ không submit form.
    const couponBtn = document.getElementById('coupon-preview-btn');
    // couponInput là ô nhập mã coupon, thuộc payment-form thông qua thuộc tính form="payment-form".
    const couponInput = document.getElementById('payment-coupon-code');
    // couponError là vùng thông báo ngay dưới ô coupon.
    const couponError = document.getElementById('coupon-error');

    if (couponBtn && couponInput && couponError) {
        couponBtn.addEventListener('click', function () {
            couponError.textContent = couponInput.value.trim()
                ? 'Mã sẽ được kiểm tra và áp dụng khi bạn thực hiện thanh toán.'
                : 'Vui lòng nhập mã coupon trước khi áp dụng.';
        });
    }

    if (window.lucide) lucide.createIcons();
})();