/*
 * Ng\u01b0\u1eddi l\u00e0m: D\u01b0\u01a1ng
 * Th\u1eddi gian t\u1ea1o: 04/06/2026
 * Ch\u1ee9c n\u0103ng: JavaScript cho m\u00e0n Customer thanh to\u00e1n booking.
 * \u00dd ngh\u0129a: H\u01b0\u1edbng d\u1eabn \u00e1p d\u1ee5ng coupon, \u0111\u1ebfm ng\u01b0\u1ee3c th\u1eddi gian gi\u1eef slot v\u00e0 polling tr\u1ea1ng th\u00e1i SePay \u0111\u1ec3 t\u1ef1 chuy\u1ec3n sang m\u00e0n th\u00e0nh c\u00f4ng khi webhook x\u00e1c nh\u1eadn ti\u1ec1n v\u00e0o.
 */
(function () {
    // couponBtn l\u00e0 n\u00fat "\u00c1p d\u1ee5ng" \u1edf khung coupon, ch\u1ec9 hi\u1ec3n th\u1ecb h\u01b0\u1edbng d\u1eabn ch\u1ee9 kh\u00f4ng submit form.
    const couponBtn = document.getElementById('coupon-preview-btn');
    // couponInput l\u00e0 \u00f4 nh\u1eadp m\u00e3 coupon, thu\u1ed9c payment-form th\u00f4ng qua thu\u1ed9c t\u00ednh form="payment-form".
    const couponInput = document.getElementById('payment-coupon-code');
    // couponError l\u00e0 v\u00f9ng th\u00f4ng b\u00e1o ngay d\u01b0\u1edbi \u00f4 coupon.
    const couponError = document.getElementById('coupon-error');

    if (couponBtn && couponInput && couponError) {
        couponBtn.addEventListener('click', function () {
            couponError.textContent = couponInput.value.trim()
                ? 'B\u1ea5m c\u1eadp nh\u1eadt coupon v\u00e0 m\u00e3 QR \u0111\u1ec3 h\u1ec7 th\u1ed1ng t\u00ednh l\u1ea1i s\u1ed1 ti\u1ec1n chuy\u1ec3n kho\u1ea3n.'
                : 'Vui l\u00f2ng nh\u1eadp m\u00e3 coupon tr\u01b0\u1edbc khi \u00e1p d\u1ee5ng.';
        });
    }

    // D\u01b0\u01a1ng l\u00e0m \u0111o\u1ea1n n\u00e0y: expiryCard \u0111\u1ecdc m\u1ed1c h\u1ebft h\u1ea1n gi\u1eef slot do server l\u01b0u trong BookingDraft.
    // B\u1ed9 \u0111\u1ebfm gi\u00fap kh\u00e1ch bi\u1ebft c\u00f2n bao l\u00e2u tr\u01b0\u1edbc khi booking PendingPayment b\u1ecb h\u1ee7y v\u00e0 tr\u1ea3 l\u1ea1i s\u1ed1 gh\u1ebf.
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
                expiryCard.querySelector('span').textContent = 'Th\u00f4ng b\u00e1o \u0111\u00e3 h\u1ebft h\u1ea1n. H\u1ec7 th\u1ed1ng s\u1ebd nh\u1ea3 slot n\u1ebfu booking v\u1eabn ch\u01b0a \u0111\u01b0\u1ee3c thanh to\u00e1n.';
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

    // D\u01b0\u01a1ng l\u00e0m \u0111o\u1ea1n n\u00e0y: sepayStatusBox ch\u1ee9a bookingCode v\u00e0 c\u00e1c URL c\u1ea7n d\u00f9ng \u0111\u1ec3 polling tr\u1ea1ng th\u00e1i thanh to\u00e1n.
    // Khi Booking.Status \u0111\u00e3 \u0111\u01b0\u1ee3c webhook \u0111\u1ed5i sang Success, tr\u00ecnh duy\u1ec7t t\u1ef1 chuy\u1ec3n sang m\u00e0n success.
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
                    sepayStatusBox.querySelector('strong').textContent = '\u0110\u01a1n gi\u1eef ch\u1ed7 \u0111\u00e3 h\u1ebft h\u1ea1n';
                    sepayStatusBox.querySelector('span').textContent = 'Qu\u00e1 10 ph\u00fat ch\u01b0a thanh to\u00e1n, h\u1ec7 th\u1ed1ng \u0111\u00e3 nh\u1ea3 slot. Vui l\u00f2ng quay l\u1ea1i t\u1ea1o booking m\u1edbi.';
                    return;
                }

                if (data.paid) {
                    sepayStatusBox.classList.add('paid');
                    sepayStatusBox.querySelector('strong').textContent = 'SePay \u0111\u00e3 ghi nh\u1eadn chuy\u1ec3n kho\u1ea3n';
                    sepayStatusBox.querySelector('span').textContent = '\u0110ang chuy\u1ec3n sang m\u00e0n ho\u00e0n t\u1ea5t \u0111\u01a1n \u0111\u1eb7t tour.';
                    window.location.href = successUrl;
                } else if (data.status) {
                    sepayStatusBox.querySelector('span').textContent = 'Tr\u1ea1ng th\u00e1i hi\u1ec7n t\u1ea1i: ' + data.status + '. H\u1ec7 th\u1ed1ng s\u1ebd ki\u1ec3m tra l\u1ea1i sau v\u00e0i gi\u00e2y.';
                }
            } catch (error) {
                sepayStatusBox.querySelector('span').textContent = 'Ch\u01b0a k\u1ebft n\u1ed1i \u0111\u01b0\u1ee3c tr\u1ea1ng th\u00e1i thanh to\u00e1n, h\u1ec7 th\u1ed1ng s\u1ebd th\u1eed l\u1ea1i.';
            }
        };

        pollPaymentStatus();
        window.setInterval(pollPaymentStatus, 5000);
    }

    if (window.lucide) lucide.createIcons();
})();