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
    // list l\u00E0 v\u00F9ng ch\u1EE9a c\u00E1c card nh\u1EADp th\u00F4ng tin participant \u0111\u01B0\u1EE3c sinh \u0111\u1ED9ng b\u1EB1ng JavaScript.
    const list = document.getElementById('participant-list');
    // minusBtn v\u00E0 plusBtn \u0111i\u1EC1u ch\u1EC9nh s\u1ED1 ng\u01B0\u1EDDi nh\u01B0ng kh\u00F4ng reload trang.
    const minusBtn = document.getElementById('minus-participant');
    const plusBtn = document.getElementById('plus-participant');

    // formatMoney \u0111\u1ECBnh d\u1EA1ng s\u1ED1 ti\u1EC1n theo chu\u1EA9n Vi\u1EC7t Nam \u0111\u1EC3 b\u1EA3ng t\u1ED5ng quan d\u1EC5 \u0111\u1ECDc.
    function formatMoney(value) {
        return new Intl.NumberFormat('vi-VN').format(Math.round(Number(value) || 0));
    }

    // getSelectedSchedulePrice l\u1EA5y gi\u00E1 Adult/Child/Infant t\u1EEB radio l\u1ECBch kh\u1EDFi h\u00E0nh \u0111ang \u0111\u01B0\u1EE3c ch\u1ECDn.
    function getSelectedSchedulePrice() {
        const checkedSchedule = document.querySelector('[name="scheduleId"]:checked');
        const form = document.getElementById('booking-create-form');
        const fallbackBase = form ? Number(form.dataset.basePrice || 0) : 0;
        return {
            adult: checkedSchedule ? Number(checkedSchedule.dataset.priceAdult || fallbackBase) : fallbackBase,
            child: checkedSchedule ? Number(checkedSchedule.dataset.priceChild || 0) : 0,
            infant: checkedSchedule ? Number(checkedSchedule.dataset.priceInfant || 0) : 0
        };
    }

    // collectParticipants \u0111\u1ECDc d\u1EEF li\u1EC7u hi\u1EC7n c\u00F3 tr\u01B0\u1EDBc khi render l\u1EA1i danh s\u00E1ch card.
    // M\u1EE5c \u0111\u00EDch l\u00E0 khi kh\u00E1ch b\u1EA5m t\u0103ng/gi\u1EA3m s\u1ED1 ng\u01B0\u1EDDi, th\u00F4ng tin \u0111\u00E3 nh\u1EADp \u1EDF c\u00E1c card c\u0169 kh\u00F4ng b\u1ECB m\u1EA5t.
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

    // escapeHtml b\u1EA3o v\u1EC7 chu\u1ED7i nh\u1EADp t\u1EEB ng\u01B0\u1EDDi d\u00F9ng tr\u01B0\u1EDBc khi \u0111\u01B0a l\u1EA1i v\u00E0o innerHTML.
    // H\u00E0m n\u00E0y tr\u00E1nh l\u1ED7i v\u1EE1 HTML khi t\u00EAn/email ch\u1EE9a k\u00FD t\u1EF1 \u0111\u1EB7c bi\u1EC7t nh\u01B0 ", <, > ho\u1EB7c &.
    function escapeHtml(value) {
        return String(value || '').replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    // field t\u1EA1o m\u1ED9t label g\u1ED3m input/select v\u00E0 v\u00F9ng hi\u1EC3n th\u1ECB l\u1ED7i ngay d\u01B0\u1EDBi \u00F4 nh\u1EADp.
    // C\u00E1ch n\u00E0y gi\u00FAp m\u1ECDi \u00F4 \u0111\u1EC1u c\u00F3 ch\u1ED7 in validate error ri\u00EAng.
    function field(labelText, html) {
        return '<label>' + labelText + html + '<span class="field-error"></span></label>';
    }

    // buildAgeTypeSelect t\u1EA1o select nh\u00F3m tu\u1ED5i.
    // Ng\u01B0\u1EDDi \u0111\u1EA1i di\u1EC7n ch\u1EC9 c\u00F3 Adult \u0111\u1EC3 \u0111\u1EA3m b\u1EA3o tr\u01B0\u1EDFng \u0111o\u00E0n l\u00E0 ng\u01B0\u1EDDi l\u1EDBn; th\u00E0nh vi\u00EAn c\u00F2n l\u1EA1i \u0111\u01B0\u1EE3c ch\u1ECDn \u0111\u1EE7 3 nh\u00F3m gi\u00E1.
    function buildAgeTypeSelect(index, currentAgeType) {
        if (index === 0) {
            return '<input type="hidden" name="participantAgeType" value="Adult"><div class="leader-age-fixed">Ng\u01B0\u1EDDi l\u1EDBn (12 tu\u1ED5i tr\u1EDF l\u00EAn)</div>';
        }
        const form = document.getElementById('booking-create-form');
        const catId = form ? parseInt(form.dataset.tourCategoryId || '0', 10) : 0;
        const isAdventure = (catId === 1 || catId === 2);
        
        let value = currentAgeType || 'Adult';
        if (isAdventure && value === 'Infant') {
            value = 'Adult';
        }

        let options = '<option value="Adult"' + (value === 'Adult' ? ' selected' : '') + '>Ng\u01B0\u1EDDi l\u1EDBn (12 tu\u1ED5i tr\u1EDF l\u00EAn)</option>' +
            '<option value="Child"' + (value === 'Child' ? ' selected' : '') + '>Tr\u1EBB em (2 - d\u01B0\u1EDBi 12 tu\u1ED5i)</option>';
            
        if (!isAdventure) {
            options += '<option value="Infant"' + (value === 'Infant' ? ' selected' : '') + '>Tr\u1EBB s\u01A1 sinh (d\u01B0\u1EDBi 2 tu\u1ED5i)</option>';
        }

        return '<select name="participantAgeType" aria-label="\u0110\u1ED9 tu\u1ED5i ng\u01B0\u1EDDi tham gia">' + options + '</select>';
    }

    // updateBookingSummary \u0111\u1EBFm s\u1ED1 Adult/Child/Infant hi\u1EC7n t\u1EA1i v\u00E0 t\u00EDnh l\u1EA1i t\u1ED5ng ti\u1EC1n tour theo l\u1ECBch \u0111ang ch\u1ECDn.
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

    // renderParticipants d\u1EF1ng l\u1EA1i to\u00E0n b\u1ED9 form ng\u01B0\u1EDDi tham gia theo s\u1ED1 l\u01B0\u1EE3ng hi\u1EC7n t\u1EA1i.
    // previousData l\u00E0 d\u1EEF li\u1EC7u c\u0169 \u0111\u00E3 collect tr\u01B0\u1EDBc \u0111\u00F3 \u0111\u1EC3 \u0111\u1ED5 l\u1EA1i v\u00E0o c\u00E1c input sau khi render.
    function renderParticipants(previousData) {
        if (!countInput || !list) return;
        const count = parseInt(countInput.value, 10);
        const data = previousData || collectParticipants();
        list.innerHTML = '';

        for (let i = 0; i < count; i++) {
            const current = data[i] || { name: '', ageType: 'Adult', phone: '', email: '' };
            const card = document.createElement('div');
            card.className = 'participant-card';
            const titleText = i === 0 ? 'Th\u00F4ng tin tr\u01B0\u1EDFng \u0111o\u00E0n' : 'Th\u00F4ng tin ng\u01B0\u1EDDi \u0111i c\u00F9ng #' + (i + 1);
            const roleText = i === 0 ? 'Ng\u01B0\u1EDDi \u0111\u1EA1i di\u1EC7n li\u00EAn h\u1EC7' : 'Th\u00E0nh vi\u00EAn';
            const removeButton = i === 0 ? '' : '<button type="button" class="remove-participant-btn" data-remove-index="' + i + '" aria-label="X\u00F3a ng\u01B0\u1EDDi \u0111i c\u00F9ng #' + (i + 1) + '" title="X\u00F3a ng\u01B0\u1EDDi \u0111i c\u00F9ng"><i data-lucide="trash-2"></i></button>';
            const phoneRequired = i === 0 ? ' data-required="true"' : '';
            const emailRequired = i === 0 ? ' data-required="true"' : '';

            // M\u1ED7i card c\u00F3 4 tr\u01B0\u1EDDng: h\u1ECD t\u00EAn, \u0111\u1ED9 tu\u1ED5i, s\u1ED1 \u0111i\u1EC7n tho\u1EA1i, email.
            // H\u1ECD t\u00EAn b\u1EAFt bu\u1ED9c cho t\u1EA5t c\u1EA3; phone/email ch\u1EC9 b\u1EAFt bu\u1ED9c v\u1EDBi tr\u01B0\u1EDFng \u0111o\u00E0n.
            card.innerHTML =
                '<div class="participant-card-head"><strong>' + titleText + '</strong><span>' + roleText + '</span>' + removeButton + '</div>' +
                '<div class="participant-fields">' +
                    field('H\u1ECD v\u00E0 t\u00EAn', '<input name="participantName" data-required="true" value="' + escapeHtml(current.name) + '" placeholder="Nh\u1EADp h\u1ECD t\u00EAn">') +
                    field('\u0110\u1ED9 tu\u1ED5i', buildAgeTypeSelect(i, current.ageType)) +
                    field('S\u1ED1 \u0111i\u1EC7n tho\u1EA1i', '<input name="participantPhone"' + phoneRequired + ' value="' + escapeHtml(current.phone) + '" placeholder="09xxxxxxxx">') +
                    field('Email', '<input name="participantEmail" type="email"' + emailRequired + ' value="' + escapeHtml(current.email) + '" placeholder="email@example.com">') +
                '</div>';
            list.appendChild(card);
        }
        updateBookingSummary();
    }

    // setError in l\u1ED7i d\u01B0\u1EDBi \u00F4 input v\u00E0 b\u1EADt class input-invalid \u0111\u1EC3 vi\u1EC1n \u00F4 chuy\u1EC3n sang tr\u1EA1ng th\u00E1i l\u1ED7i.
    function setError(input, message) {
        const error = input.closest('label').querySelector('.field-error');
        if (error) error.textContent = message;
        input.classList.toggle('input-invalid', Boolean(message));
    }

    // validateCreateForm ki\u1EC3m tra d\u1EEF li\u1EC7u client-side tr\u01B0\u1EDBc khi submit.
    // Server v\u1EABn validate l\u1EA1i trong BookingCreateController \u0111\u1EC3 tr\u00E1nh d\u1EEF li\u1EC7u s\u1EEDa b\u1EB1ng devtool/request th\u1EE7 c\u00F4ng.
    function validateCreateForm() {
        let valid = true;
        const scheduleError = document.getElementById('schedule-error');
        const checkedSchedule = document.querySelector('[name="scheduleId"]:checked');
        if (scheduleError) scheduleError.textContent = '';
        if (!checkedSchedule) {
            if (scheduleError) scheduleError.textContent = 'Vui l\u00F2ng ch\u1ECDn m\u1ED9t l\u1ECBch kh\u1EDFi h\u00E0nh.';
            valid = false;
        } else {
            // BR-19 / BR-20: server-side DAO \u0111\u00e3 l\u1ecdc past-date nh\u01b0ng t\u1ea7ng b\u1ea3o v\u1ec7 cu\u1ed1i \u1edf client v\u1eabn ch\u1eb7n.
            const todayMidnight = new Date();
            todayMidnight.setHours(0, 0, 0, 0);
            const departureMs = parseInt(checkedSchedule.dataset.departureMs || '0', 10);
            if (departureMs && departureMs < todayMidnight.getTime()) {
                if (scheduleError) scheduleError.textContent = 'L\u1ecbch kh\u1edfi h\u00e0nh \u0111\u00e3 \u1edf trong qu\u00e1 kh\u1ee9. Vui l\u00f2ng ch\u1ecdn l\u1ecbch kh\u00e1c.';
                valid = false;
            }
        }

        list.querySelectorAll('input, select').forEach(function (input) {
            setError(input, '');
            if (input.dataset.required === 'true' && !input.value.trim()) {
                setError(input, 'Vui l\u00F2ng nh\u1EADp th\u00F4ng tin n\u00E0y.');
                valid = false;
            } else if (input.type === 'email' && input.value.trim() && !input.value.includes('@')) {
                setError(input, 'Email ch\u01B0a \u0111\u00FAng \u0111\u1ECBnh d\u1EA1ng.');
                valid = false;
            }
        });
        return valid;
    }

    // Khi gi\u1EA3m s\u1ED1 ng\u01B0\u1EDDi, d\u1EEF li\u1EC7u hi\u1EC7n t\u1EA1i \u0111\u01B0\u1EE3c collect tr\u01B0\u1EDBc r\u1ED3i render l\u1EA1i theo s\u1ED1 l\u01B0\u1EE3ng m\u1EDBi.
    if (minusBtn) {
        minusBtn.addEventListener('click', function () {
            const data = collectParticipants();
            countInput.value = Math.max(1, parseInt(countInput.value, 10) - 1);
            renderParticipants(data);
        });
    }

    // Khi t\u0103ng s\u1ED1 ng\u01B0\u1EDDi, gi\u1EEF d\u1EEF li\u1EC7u c\u0169 v\u00E0 th\u00EAm m\u1ED9t card m\u1EDBi r\u1ED7ng \u1EDF cu\u1ED1i danh s\u00E1ch.
    if (plusBtn) {
        plusBtn.addEventListener('click', function () {
            const data = collectParticipants();
            countInput.value = Math.min(10, parseInt(countInput.value, 10) + 1);
            renderParticipants(data);
        });
    }

    // Thay \u0111\u1ED5i l\u1ECBch kh\u1EDFi h\u00E0nh ho\u1EB7c nh\u00F3m tu\u1ED5i \u0111\u1EC1u c\u1EADp nh\u1EADt l\u1EA1i b\u1EA3ng t\u1ED5ng quan \u0111\u01A1n \u0111\u1EB7t.
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


    // D\u01B0\u01A1ng l\u00E0m \u0111o\u1EA1n n\u00E0y: n\u00FAt th\u00F9ng r\u00E1c ch\u1EC9 xu\u1EA5t hi\u1EC7n \u1EDF ng\u01B0\u1EDDi \u0111i c\u00F9ng \u0111\u1EC3 xo\u00E1 nhanh \u0111\u00FAng card \u0111\u00F3.
    // Sau khi xo\u00E1, danh s\u00E1ch \u0111\u01B0\u1EE3c render l\u1EA1i \u0111\u1EC3 s\u1ED1 th\u1EE9 t\u1EF1, participantCount v\u00E0 b\u1EA3ng t\u1ED5ng quan ti\u1EC1n lu\u00F4n \u0111\u1ED3ng b\u1ED9.
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
    // Ch\u1EB7n submit n\u1EBFu validate client-side ch\u01B0a \u0111\u1EA1t.
    if (createForm) {
        createForm.addEventListener('submit', function (event) {
            if (!validateCreateForm()) {
                event.preventDefault();
            }
        });
    }


    // D\u01B0\u01A1ng l\u00E0m \u0111o\u1EA1n n\u00E0y: customerNote t\u1EF1 t\u0103ng chi\u1EC1u cao theo n\u1ED9i dung kh\u00E1ch nh\u1EADp.
    // Textarea v\u1EABn gi\u1EEF maxlength=500 n\u00EAn khi t\u1EDBi gi\u1EDBi h\u1EA1n tr\u00ECnh duy\u1EC7t s\u1EBD kh\u00F4ng cho nh\u1EADp th\u00EAm k\u00FD t\u1EF1.
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
    // Render m\u1EB7c \u0111\u1ECBnh m\u1ED9t participant khi trang v\u1EEBa load.
    renderParticipants([]);
    if (window.lucide) lucide.createIcons();
})();