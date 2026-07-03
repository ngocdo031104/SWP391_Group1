/*
 * Ng\u01b0\u1eddi l\u00e0m: D\u01b0\u01a1ng
 * Th\u1eddi gian t\u1ea1o: 04/06/2026
 * Ch\u1ee9c n\u0103ng: JavaScript cho m\u00e0n Customer t\u1ea1o booking.
 * \u00dd ngh\u0129a: Gi\u1eef d\u1eef li\u1ec7u ng\u01b0\u1eddi tham gia khi t\u0103ng/gi\u1ea3m s\u1ed1 l\u01b0\u1ee3ng, b\u1eaft ng\u01b0\u1eddi \u0111\u1ea1i di\u1ec7n l\u00e0 ng\u01b0\u1eddi l\u1edbn, validate l\u1ed7i d\u01b0\u1edbi t\u1eebng \u00f4 v\u00e0 t\u00ednh t\u1ea1m ti\u1ec1n tour theo nh\u00f3m tu\u1ed5i.
 */
(function () {
    // createForm l\u00e0 form g\u1eedi d\u1eef li\u1ec7u t\u1eeb m\u00e0n t\u1ea1o booking sang BookingCreateController.doPost.
    const createForm = document.getElementById('booking-create-form');
    // countInput l\u01b0u s\u1ed1 ng\u01b0\u1eddi tham gia hi\u1ec7n t\u1ea1i, \u0111\u01b0\u1ee3c g\u1eedi l\u00ean server b\u1eb1ng name participantCount.
    const countInput = document.getElementById('participant-count');
    // list l\u00e0 v\u00f9ng ch\u1ee9a c\u00e1c card nh\u1eadp th\u00f4ng tin participant \u0111\u01b0\u1ee3c sinh \u0111\u1ed9ng b\u1eb1ng JavaScript.
    const list = document.getElementById('participant-list');
    // minusBtn v\u00e0 plusBtn \u0111i\u1ec1u ch\u1ec9nh s\u1ed1 ng\u01b0\u1eddi nh\u01b0ng kh\u00f4ng reload trang.
    const minusBtn = document.getElementById('minus-participant');
    const plusBtn = document.getElementById('plus-participant');

    // formatMoney \u0111\u1ecbnh d\u1ea1ng s\u1ed1 ti\u1ec1n theo chu\u1ea9n Vi\u1ec7t Nam \u0111\u1ec3 b\u1ea3ng t\u1ed5ng quan d\u1ec5 \u0111\u1ecdc.
    function formatMoney(value) {
        return new Intl.NumberFormat('vi-VN').format(Math.round(Number(value) || 0));
    }

    // getSelectedSchedulePrice l\u1ea5y gi\u00e1 Adult/Child/Infant t\u1eeb radio l\u1ecbch kh\u1edfi h\u00e0nh \u0111ang \u0111\u01b0\u1ee3c ch\u1ecdn.
    function getSelectedSchedulePrice() {
        const checkedSchedule = document.querySelector('[name="scheduleId"]:checked');
        return {
            adult: checkedSchedule ? Number(checkedSchedule.dataset.priceAdult || 0) : 0,
            child: checkedSchedule ? Number(checkedSchedule.dataset.priceChild || 0) : 0,
            infant: checkedSchedule ? Number(checkedSchedule.dataset.priceInfant || 0) : 0
        };
    }

    // collectParticipants \u0111\u1ecdc d\u1eef li\u1ec7u hi\u1ec7n c\u00f3 tr\u01b0\u1edbc khi render l\u1ea1i danh s\u00e1ch card.
    // M\u1ee5c \u0111\u00edch l\u00e0 khi kh\u00e1ch b\u1ea5m t\u0103ng/gi\u1ea3m s\u1ed1 ng\u01b0\u1eddi, th\u00f4ng tin \u0111\u00e3 nh\u1eadp \u1edf c\u00e1c card c\u0169 kh\u00f4ng b\u1ecb m\u1ea5t.
    function collectParticipants() {
        if (!list) return [];
        const cards = list.querySelectorAll('.participant-card');
        const data = [];
        cards.forEach(function (card, index) {
            data.push({
                name: card.querySelector('[name="participantName"]').value,
                ageType: index === 0 ? 'Adult' : card.querySelector('[name="participantAgeType"]').value,
                phone: card.querySelector('[name="participantPhone"]').value,
                email: card.querySelector('[name="participantEmail"]').value
            });
        });
        return data;
    }

    // escapeHtml b\u1ea3o v\u1ec7 chu\u1ed7i nh\u1eadp t\u1eeb ng\u01b0\u1eddi d\u00f9ng tr\u01b0\u1edbc khi \u0111\u01b0a l\u1ea1i v\u00e0o innerHTML.
    // H\u00e0m n\u00e0y tr\u00e1nh l\u1ed7i v\u1ee1 HTML khi t\u00ean/email ch\u1ee9a k\u00fd t\u1ef1 \u0111\u1eb7c bi\u1ec7t nh\u01b0 ", <, > ho\u1eb7c &.
    function escapeHtml(value) {
        return String(value || '').replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    // field t\u1ea1o m\u1ed9t label g\u1ed3m input/select v\u00e0 v\u00f9ng hi\u1ec3n th\u1ecb l\u1ed7i ngay d\u01b0\u1edbi \u00f4 nh\u1eadp.
    // C\u00e1ch n\u00e0y gi\u00fap m\u1ecdi \u00f4 \u0111\u1ec1u c\u00f3 ch\u1ed7 in validate error ri\u00eang.
    function field(labelText, html) {
        return '<label>' + labelText + html + '<span class="field-error"></span></label>';
    }

    // buildAgeTypeSelect t\u1ea1o select nh\u00f3m tu\u1ed5i.
    // Ng\u01b0\u1eddi \u0111\u1ea1i di\u1ec7n ch\u1ec9 c\u00f3 Adult \u0111\u1ec3 \u0111\u1ea3m b\u1ea3o tr\u01b0\u1edfng \u0111o\u00e0n l\u00e0 ng\u01b0\u1eddi l\u1edbn; th\u00e0nh vi\u00ean c\u00f2n l\u1ea1i \u0111\u01b0\u1ee3c ch\u1ecdn \u0111\u1ee7 3 nh\u00f3m gi\u00e1.
    function buildAgeTypeSelect(index, currentAgeType) {
        if (index === 0) {
            return '<input type="hidden" name="participantAgeType" value="Adult"><div class="leader-age-fixed">Ng\u01b0\u1eddi l\u1edbn (12 tu\u1ed5i tr\u1edf l\u00ean)</div>';
        }
        const value = currentAgeType || 'Adult';
        return '<select name="participantAgeType" aria-label="\u0110\u1ed9 tu\u1ed5i ng\u01b0\u1eddi tham gia">' +
            '<option value="Adult"' + (value === 'Adult' ? ' selected' : '') + '>Ng\u01b0\u1eddi l\u1edbn (12 tu\u1ed5i tr\u1edf l\u00ean)</option>' +
            '<option value="Child"' + (value === 'Child' ? ' selected' : '') + '>Tr\u1ebb em (2 - d\u01b0\u1edbi 12 tu\u1ed5i)</option>' +
            '<option value="Infant"' + (value === 'Infant' ? ' selected' : '') + '>Tr\u1ebb s\u01a1 sinh (d\u01b0\u1edbi 2 tu\u1ed5i)</option>' +
            '</select>';
    }

    // updateBookingSummary \u0111\u1ebfm s\u1ed1 Adult/Child/Infant hi\u1ec7n t\u1ea1i v\u00e0 t\u00ednh l\u1ea1i t\u1ed5ng ti\u1ec1n tour theo l\u1ecbch \u0111ang ch\u1ecdn.
    function updateBookingSummary() {
        const price = getSelectedSchedulePrice();
        let adultCount = 0;
        let childCount = 0;
        let infantCount = 0;

        if (list) {
            list.querySelectorAll('[name="participantAgeType"]').forEach(function (select) {
                if (select.value === 'Child') {
                    childCount++;
                } else if (select.value === 'Infant') {
                    infantCount++;
                } else {
                    adultCount++;
                }
            });
        }

        const baseAmount = adultCount * price.adult + childCount * price.child + infantCount * price.infant;
        const targets = {
            'summary-adult-count': adultCount,
            'summary-child-count': childCount,
            'summary-infant-count': infantCount,
            'summary-adult-price': formatMoney(price.adult),
            'summary-child-price': formatMoney(price.child),
            'summary-infant-price': formatMoney(price.infant),
            'summary-base-amount': formatMoney(baseAmount) + ' \u0111'
        };

        Object.keys(targets).forEach(function (id) {
            const element = document.getElementById(id);
            if (element) element.textContent = targets[id];
        });
    }

    // renderParticipants d\u1ef1ng l\u1ea1i to\u00e0n b\u1ed9 form ng\u01b0\u1eddi tham gia theo s\u1ed1 l\u01b0\u1ee3ng hi\u1ec7n t\u1ea1i.
    // previousData l\u00e0 d\u1eef li\u1ec7u c\u0169 \u0111\u00e3 collect tr\u01b0\u1edbc \u0111\u00f3 \u0111\u1ec3 \u0111\u1ed5 l\u1ea1i v\u00e0o c\u00e1c input sau khi render.
    function renderParticipants(previousData) {
        if (!countInput || !list) return;
        const count = parseInt(countInput.value, 10);
        const data = previousData || collectParticipants();
        list.innerHTML = '';

        for (let i = 0; i < count; i++) {
            const current = data[i] || { name: '', ageType: 'Adult', phone: '', email: '' };
            const card = document.createElement('div');
            card.className = 'participant-card';
            const titleText = i === 0 ? 'Th\u00f4ng tin tr\u01b0\u1edfng \u0111o\u00e0n' : 'Th\u00f4ng tin ng\u01b0\u1eddi \u0111i c\u00f9ng #' + (i + 1);
            const roleText = i === 0 ? 'Ng\u01b0\u1eddi \u0111\u1ea1i di\u1ec7n li\u00ean h\u1ec7' : 'Th\u00e0nh vi\u00ean';
            const removeButton = i === 0 ? '' : '<button type="button" class="remove-participant-btn" data-remove-index="' + i + '" aria-label="X\u00f3a ng\u01b0\u1eddi \u0111i c\u00f9ng #' + (i + 1) + '" title="X\u00f3a ng\u01b0\u1eddi \u0111i c\u00f9ng"><i data-lucide="trash-2"></i></button>';
            const phoneRequired = i === 0 ? ' data-required="true"' : '';
            const emailRequired = i === 0 ? ' data-required="true"' : '';

            // M\u1ed7i card c\u00f3 4 tr\u01b0\u1eddng: h\u1ecd t\u00ean, \u0111\u1ed9 tu\u1ed5i, s\u1ed1 \u0111i\u1ec7n tho\u1ea1i, email.
            // H\u1ecd t\u00ean b\u1eaft bu\u1ed9c cho t\u1ea5t c\u1ea3; phone/email ch\u1ec9 b\u1eaft bu\u1ed9c v\u1edbi tr\u01b0\u1edfng \u0111o\u00e0n.
            card.innerHTML =
                '<div class="participant-card-head"><strong>' + titleText + '</strong><span>' + roleText + '</span>' + removeButton + '</div>' +
                '<div class="participant-fields">' +
                    field('H\u1ecd v\u00e0 t\u00ean', '<input name="participantName" data-required="true" value="' + escapeHtml(current.name) + '" placeholder="Nh\u1eadp h\u1ecd t\u00ean">') +
                    field('\u0110\u1ed9 tu\u1ed5i', buildAgeTypeSelect(i, current.ageType)) +
                    field('S\u1ed1 \u0111i\u1ec7n tho\u1ea1i', '<input name="participantPhone"' + phoneRequired + ' value="' + escapeHtml(current.phone) + '" placeholder="09xxxxxxxx">') +
                    field('Email', '<input name="participantEmail" type="email"' + emailRequired + ' value="' + escapeHtml(current.email) + '" placeholder="email@example.com">') +
                '</div>';
            list.appendChild(card);
        }
        updateBookingSummary();
    }

    // setError in l\u1ed7i d\u01b0\u1edbi \u00f4 input v\u00e0 b\u1eadt class input-invalid \u0111\u1ec3 vi\u1ec1n \u00f4 chuy\u1ec3n sang tr\u1ea1ng th\u00e1i l\u1ed7i.
    function setError(input, message) {
        const error = input.closest('label').querySelector('.field-error');
        if (error) error.textContent = message;
        input.classList.toggle('input-invalid', Boolean(message));
    }

    // validateCreateForm ki\u1ec3m tra d\u1eef li\u1ec7u client-side tr\u01b0\u1edbc khi submit.
    // Server v\u1eabn validate l\u1ea1i trong BookingCreateController \u0111\u1ec3 tr\u00e1nh d\u1eef li\u1ec7u s\u1eeda b\u1eb1ng devtool/request th\u1ee7 c\u00f4ng.
    function validateCreateForm() {
        let valid = true;
        const scheduleError = document.getElementById('schedule-error');
        const checkedSchedule = document.querySelector('[name="scheduleId"]:checked');
        if (scheduleError) scheduleError.textContent = '';
        if (!checkedSchedule) {
            if (scheduleError) scheduleError.textContent = 'Vui l\u00f2ng ch\u1ecdn m\u1ed9t l\u1ecbch kh\u1edfi h\u00e0nh.';
            valid = false;
        }

        list.querySelectorAll('input, select').forEach(function (input) {
            setError(input, '');
            if (input.dataset.required === 'true' && !input.value.trim()) {
                setError(input, 'Vui l\u00f2ng nh\u1eadp th\u00f4ng tin n\u00e0y.');
                valid = false;
            } else if (input.type === 'email' && input.value.trim() && !input.value.includes('@')) {
                setError(input, 'Email ch\u01b0a \u0111\u00fang \u0111\u1ecbnh d\u1ea1ng.');
                valid = false;
            }
        });
        return valid;
    }

    // Khi gi\u1ea3m s\u1ed1 ng\u01b0\u1eddi, d\u1eef li\u1ec7u hi\u1ec7n t\u1ea1i \u0111\u01b0\u1ee3c collect tr\u01b0\u1edbc r\u1ed3i render l\u1ea1i theo s\u1ed1 l\u01b0\u1ee3ng m\u1edbi.
    if (minusBtn) {
        minusBtn.addEventListener('click', function () {
            const data = collectParticipants();
            countInput.value = Math.max(1, parseInt(countInput.value, 10) - 1);
            renderParticipants(data);
        });
    }

    // Khi t\u0103ng s\u1ed1 ng\u01b0\u1eddi, gi\u1eef d\u1eef li\u1ec7u c\u0169 v\u00e0 th\u00eam m\u1ed9t card m\u1edbi r\u1ed7ng \u1edf cu\u1ed1i danh s\u00e1ch.
    if (plusBtn) {
        plusBtn.addEventListener('click', function () {
            const data = collectParticipants();
            countInput.value = Math.min(10, parseInt(countInput.value, 10) + 1);
            renderParticipants(data);
        });
    }

    // Thay \u0111\u1ed5i l\u1ecbch kh\u1edfi h\u00e0nh ho\u1eb7c nh\u00f3m tu\u1ed5i \u0111\u1ec1u c\u1eadp nh\u1eadt l\u1ea1i b\u1ea3ng t\u1ed5ng quan \u0111\u01a1n \u0111\u1eb7t.
    document.querySelectorAll('[name="scheduleId"]').forEach(function (radio) {
        radio.addEventListener('change', updateBookingSummary);
    });
    if (list) {
        list.addEventListener('change', function (event) {
            if (event.target && event.target.name === 'participantAgeType') {
                updateBookingSummary();
            }
        });
    }


    // D\u01b0\u01a1ng l\u00e0m \u0111o\u1ea1n n\u00e0y: n\u00fat th\u00f9ng r\u00e1c ch\u1ec9 xu\u1ea5t hi\u1ec7n \u1edf ng\u01b0\u1eddi \u0111i c\u00f9ng \u0111\u1ec3 xo\u00e1 nhanh \u0111\u00fang card \u0111\u00f3.
    // Sau khi xo\u00e1, danh s\u00e1ch \u0111\u01b0\u1ee3c render l\u1ea1i \u0111\u1ec3 s\u1ed1 th\u1ee9 t\u1ef1, participantCount v\u00e0 b\u1ea3ng t\u1ed5ng quan ti\u1ec1n lu\u00f4n \u0111\u1ed3ng b\u1ed9.
    if (list) {
        list.addEventListener('click', function (event) {
            const removeButton = event.target.closest('.remove-participant-btn');
            if (!removeButton) return;

            const removeIndex = parseInt(removeButton.dataset.removeIndex, 10);
            const data = collectParticipants();
            data.splice(removeIndex, 1);
            countInput.value = Math.max(1, data.length);
            renderParticipants(data);
            if (window.lucide) lucide.createIcons();
        });
    }
    // Ch\u1eb7n submit n\u1ebfu validate client-side ch\u01b0a \u0111\u1ea1t.
    if (createForm) {
        createForm.addEventListener('submit', function (event) {
            if (!validateCreateForm()) {
                event.preventDefault();
            }
        });
    }


    // D\u01b0\u01a1ng l\u00e0m \u0111o\u1ea1n n\u00e0y: customerNote t\u1ef1 t\u0103ng chi\u1ec1u cao theo n\u1ed9i dung kh\u00e1ch nh\u1eadp.
    // Textarea v\u1eabn gi\u1eef maxlength=500 n\u00ean khi t\u1edbi gi\u1edbi h\u1ea1n tr\u00ecnh duy\u1ec7t s\u1ebd kh\u00f4ng cho nh\u1eadp th\u00eam k\u00fd t\u1ef1.
    const customerNote = document.getElementById('customer-note');
    function autoResizeCustomerNote() {
        if (!customerNote) return;
        customerNote.style.height = 'auto';
        customerNote.style.height = Math.min(customerNote.scrollHeight, 260) + 'px';
    }

    if (customerNote) {
        customerNote.addEventListener('input', autoResizeCustomerNote);
        autoResizeCustomerNote();
    }
    // Render m\u1eb7c \u0111\u1ecbnh m\u1ed9t participant khi trang v\u1eeba load.
    renderParticipants([]);
    if (window.lucide) lucide.createIcons();
})();