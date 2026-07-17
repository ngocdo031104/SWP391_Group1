\uFEFF/*
 * Ng\u01B0\u1EDDi l\u00E0m: D\u01B0\u01A1ng
 * Th\u1EDDi gian t\u1EA1o: 04/06/2026
 * Ch\u1EE9c n\u0103ng: JavaScript cho m\u00E0n Customer thanh to\u00E1n booking.
 * \u00DD ngh\u0129a: H\u01B0\u1EDBng d\u1EABn \u00E1p d\u1EE5ng coupon, \u0111\u1EBFm ng\u01B0\u1EE3c th\u1EDDi gian gi\u1EEF slot v\u00E0 polling tr\u1EA1ng th\u00E1i SePay \u0111\u1EC3 t\u1EF1 chuy\u1EC3n sang m\u00E0n th\u00E0nh c\u00F4ng khi webhook x\u00E1c nh\u1EADn ti\u1EC1n v\u00E0o.
 */
(function () {
    // couponBtn l\u00E0 n\u00FAt "\u00C1p d\u1EE5ng" \u1EDF khung coupon, ch\u1EC9 hi\u1EC3n th\u1ECB h\u01B0\u1EDBng d\u1EABn ch\u1EE9 kh\u00F4ng submit form.
    const couponBtn = document.getElementById('coupon-preview-btn');
    // couponInput l\u00E0 \u00F4 nh\u1EADp m\u00E3 coupon, thu\u1ED9c payment-form th\u00F4ng qua thu\u1ED9c t\u00EDnh form="payment-form".
    const couponInput = document.getElementById('payment-coupon-code');
    // couponError l\u00E0 v\u00F9ng th\u00F4ng b\u00E1o ngay d\u01B0\u1EDBi \u00F4 coupon.
    const couponError = document.getElementById('coupon-error');

    if (couponBtn && couponInput && couponError) {
        couponBtn.addEventListener('click', function () {
            couponError.textContent = couponInput.value.trim()
                ? 'B\u1EA5m c\u1EADp nh\u1EADt coupon v\u00E0 m\u00E3 QR \u0111\u1EC3 h\u1EC7 th\u1ED1ng t\u00EDnh l\u1EA1i s\u1ED1 ti\u1EC1n chuy\u1EC3n kho\u1EA3n.'
                : 'Vui l\u00F2ng nh\u1EADp m\u00E3 coupon tr\u01B0\u1EDBc khi \u00E1p d\u1EE5ng.';
        });
    }

    // D\u01B0\u01A1ng l\u00E0m \u0111o\u1EA1n n\u00E0y: expiryCard \u0111\u1ECDc m\u1ED1c h\u1EBFt h\u1EA1n gi\u1EEF slot do server l\u01B0u trong BookingDraft.
    // B\u1ED9 \u0111\u1EBFm gi\u00FAp kh\u00E1ch bi\u1EBFt c\u00F2n bao l\u00E2u tr\u01B0\u1EDBc khi booking PendingPayment b\u1ECB h\u1EE7y v\u00E0 tr\u1EA3 l\u1EA1i s\u1ED1 gh\u1EBF.
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
                expiryCard.querySelector('span').textContent = 'Th\u00F4ng b\u00E1o \u0111\u00E3 h\u1EBFt h\u1EA1n. H\u1EC7 th\u1ED1ng s\u1EBD nh\u1EA3 slot n\u1EBFu booking v\u1EABn ch\u01B0a \u0111\u01B0\u1EE3c thanh to\u00E1n.';
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

    // D\u01B0\u01A1ng l\u00E0m \u0111o\u1EA1n n\u00E0y: sepayStatusBox ch\u1EE9a bookingCode v\u00E0 c\u00E1c URL c\u1EA7n d\u00F9ng \u0111\u1EC3 polling tr\u1EA1ng th\u00E1i thanh to\u00E1n.
    // Khi Booking.Status \u0111\u00E3 \u0111\u01B0\u1EE3c webhook \u0111\u1ED5i sang Success, tr\u00ECnh duy\u1EC7t t\u1EF1 chuy\u1EC3n sang m\u00E0n success.
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
                    sepayStatusBox.querySelector('strong').textContent = '\u0110\u01A1n gi\u1EEF ch\u1ED7 \u0111\u00E3 h\u1EBFt h\u1EA1n';
                    sepayStatusBox.querySelector('span').textContent = 'Qu\u00E1 10 ph\u00FAt ch\u01B0a thanh to\u00E1n, h\u1EC7 th\u1ED1ng \u0111\u00E3 nh\u1EA3 slot. Vui l\u00F2ng quay l\u1EA1i t\u1EA1o booking m\u1EDBi.';
                    return;
                }

                if (data.paid) {
                    sepayStatusBox.classList.add('paid');
                    sepayStatusBox.querySelector('strong').textContent = 'SePay \u0111\u00E3 ghi nh\u1EADn chuy\u1EC3n kho\u1EA3n';
                    sepayStatusBox.querySelector('span').textContent = '\u0110ang chuy\u1EC3n sang m\u00E0n ho\u00E0n t\u1EA5t \u0111\u01A1n \u0111\u1EB7t tour.';
                    window.location.href = successUrl;
                } else if (data.status) {
                    sepayStatusBox.querySelector('span').textContent = 'Tr\u1EA1ng th\u00E1i hi\u1EC7n t\u1EA1i: ' + data.status + '. H\u1EC7 th\u1ED1ng s\u1EBD ki\u1EC3m tra l\u1EA1i sau v\u00E0i gi\u00E2y.';
                }
            } catch (error) {
                sepayStatusBox.querySelector('span').textContent = 'Ch\u01B0a k\u1EBFt n\u1ED1i \u0111\u01B0\u1EE3c tr\u1EA1ng th\u00E1i thanh to\u00E1n, h\u1EC7 th\u1ED1ng s\u1EBD th\u1EED l\u1EA1i.';
            }
        };

        pollPaymentStatus();
        window.setInterval(pollPaymentStatus, 5000);
    }

    if (window.lucide) lucide.createIcons();
})();