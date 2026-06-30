/*
 * Người làm: Dương
 * Thời gian tạo: 04/06/2026
 * Chức năng: JavaScript cho màn Customer thanh toán booking.
 * Ý nghĩa: Hướng dẫn áp dụng coupon, đếm ngược thời gian giữ slot và polling trạng thái SePay để tự chuyển sang màn thành công khi webhook xác nhận tiền vào.
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
                ? 'Bấm cập nhật coupon và mã QR để hệ thống tính lại số tiền chuyển khoản.'
                : 'Vui lòng nhập mã coupon trước khi áp dụng.';
        });
    }

    // Dương làm đoạn này: expiryCard đọc mốc hết hạn giữ slot do server lưu trong BookingDraft.
    // Bộ đếm giúp khách biết còn bao lâu trước khi booking PendingPayment bị hủy và trả lại số ghế.
    const expiryCard = document.getElementById('payment-expiry-card');
    const countdownInline = document.getElementById('payment-countdown-inline');
    const paymentForm = document.getElementById('payment-form');
    let countdownTimer = null;

    const formatRemainTime = function (remainMs) {
        const totalSeconds = Math.max(0, Math.floor(remainMs / 1000));
        const minutes = String(Math.floor(totalSeconds / 60)).padStart(2, '0');
        const seconds = String(totalSeconds % 60).padStart(2, '0');
        return minutes + ':' + seconds;
    };

    if (expiryCard && countdownInline) {
        const expiresAt = Number(expiryCard.dataset.expiresAt || 0);
        const updateCountdown = function () {
            const remainMs = expiresAt - Date.now();
            const remainText = formatRemainTime(remainMs);
            countdownInline.textContent = remainText;

            if (remainMs <= 60000) {
                expiryCard.classList.add('is-warning');
            }

            if (remainMs <= 0) {
                expiryCard.classList.remove('is-warning');
                expiryCard.classList.add('is-expired');
                countdownInline.textContent = '00:00';
                expiryCard.querySelector('span').textContent = 'Thông báo đã hết hạn. Hệ thống sẽ nhả slot nếu booking vẫn chưa được thanh toán.';
                if (paymentForm) {
                    paymentForm.querySelectorAll('button, input').forEach(function (element) {
                        element.disabled = true;
                    });
                }
                window.clearInterval(countdownTimer);
            }
        };

        updateCountdown();
        countdownTimer = window.setInterval(updateCountdown, 1000);
    }

    // Dương làm đoạn này: sepayStatusBox chứa bookingCode và các URL cần dùng để polling trạng thái thanh toán.
    // Khi Booking.Status đã được webhook đổi sang Success, trình duyệt tự chuyển sang màn success.
    const sepayStatusBox = document.getElementById('sepay-status-box');
    if (sepayStatusBox) {
        const bookingCode = sepayStatusBox.dataset.bookingCode;
        const statusUrl = sepayStatusBox.dataset.statusUrl;
        const successUrl = sepayStatusBox.dataset.successUrl;

        const pollPaymentStatus = async function () {
            if (!bookingCode || !statusUrl || !successUrl) return;

            try {
                const response = await fetch(statusUrl + '?code=' + encodeURIComponent(bookingCode), {
                    method: 'GET',
                    cache: 'no-store'
                });
                if (!response.ok) return;

                const data = await response.json();
                if (data.expired) {
                    sepayStatusBox.classList.remove('paid');
                    sepayStatusBox.classList.add('expired');
                    sepayStatusBox.querySelector('strong').textContent = 'Đơn giữ chỗ đã hết hạn';
                    sepayStatusBox.querySelector('span').textContent = 'Quá 10 phút chưa thanh toán, hệ thống đã nhả slot. Vui lòng quay lại tạo booking mới.';
                    return;
                }

                if (data.paid) {
                    sepayStatusBox.classList.add('paid');
                    sepayStatusBox.querySelector('strong').textContent = 'SePay đã ghi nhận chuyển khoản';
                    sepayStatusBox.querySelector('span').textContent = 'Đang chuyển sang màn hoàn tất đơn đặt tour.';
                    window.location.href = successUrl;
                } else if (data.status) {
                    sepayStatusBox.querySelector('span').textContent = 'Trạng thái hiện tại: ' + data.status + '. Hệ thống sẽ kiểm tra lại sau vài giây.';
                }
            } catch (error) {
                sepayStatusBox.querySelector('span').textContent = 'Chưa kết nối được trạng thái thanh toán, hệ thống sẽ thử lại.';
            }
        };

        pollPaymentStatus();
        window.setInterval(pollPaymentStatus, 5000);
    }

    if (window.lucide) lucide.createIcons();
})();