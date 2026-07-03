/*
 * Người làm: Dương
 * Thời gian tạo: 04/06/2026
 * Chức năng: JavaScript cho màn Customer tạo booking.
 * Ý nghĩa: Giữ dữ liệu người tham gia khi tăng/giảm số lượng, bắt người đại diện là người lớn, validate lỗi dưới từng ô và tính tạm tiền tour theo nhóm tuổi.
 */
(function () {
    // createForm là form gửi dữ liệu từ màn tạo booking sang BookingCreateController.doPost.
    const createForm = document.getElementById('booking-create-form');
    // countInput lưu số người tham gia hiện tại, được gửi lên server bằng name participantCount.
    const countInput = document.getElementById('participant-count');
    // list là vùng chứa các card nhập thông tin participant được sinh động bằng JavaScript.
    const list = document.getElementById('participant-list');
    // minusBtn và plusBtn điều chỉnh số người nhưng không reload trang.
    const minusBtn = document.getElementById('minus-participant');
    const plusBtn = document.getElementById('plus-participant');

    // formatMoney định dạng số tiền theo chuẩn Việt Nam để bảng tổng quan dễ đọc.
    function formatMoney(value) {
        return new Intl.NumberFormat('vi-VN').format(Math.round(Number(value) || 0));
    }

    // getSelectedSchedulePrice lấy giá Adult/Child/Infant từ radio lịch khởi hành đang được chọn.
    function getSelectedSchedulePrice() {
        const checkedSchedule = document.querySelector('[name="scheduleId"]:checked');
        return {
            adult: checkedSchedule ? Number(checkedSchedule.dataset.priceAdult || 0) : 0,
            child: checkedSchedule ? Number(checkedSchedule.dataset.priceChild || 0) : 0,
            infant: checkedSchedule ? Number(checkedSchedule.dataset.priceInfant || 0) : 0
        };
    }

    // collectParticipants đọc dữ liệu hiện có trước khi render lại danh sách card.
    // Mục đích là khi khách bấm tăng/giảm số người, thông tin đã nhập ở các card cũ không bị mất.
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

    // escapeHtml bảo vệ chuỗi nhập từ người dùng trước khi đưa lại vào innerHTML.
    // Hàm này tránh lỗi vỡ HTML khi tên/email chứa ký tự đặc biệt như ", <, > hoặc &.
    function escapeHtml(value) {
        return String(value || '').replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    // field tạo một label gồm input/select và vùng hiển thị lỗi ngay dưới ô nhập.
    // Cách này giúp mọi ô đều có chỗ in validate error riêng.
    function field(labelText, html) {
        return '<label>' + labelText + html + '<span class="field-error"></span></label>';
    }

    // buildAgeTypeSelect tạo select nhóm tuổi.
    // Người đại diện chỉ có Adult để đảm bảo trưởng đoàn là người lớn; thành viên còn lại được chọn đủ 3 nhóm giá.
    function buildAgeTypeSelect(index, currentAgeType) {
        if (index === 0) {
            return '<input type="hidden" name="participantAgeType" value="Adult"><div class="leader-age-fixed">Người lớn (12 tuổi trở lên)</div>';
        }
        const value = currentAgeType || 'Adult';
        return '<select name="participantAgeType" aria-label="Độ tuổi người tham gia">' +
            '<option value="Adult"' + (value === 'Adult' ? ' selected' : '') + '>Người lớn (12 tuổi trở lên)</option>' +
            '<option value="Child"' + (value === 'Child' ? ' selected' : '') + '>Trẻ em (2 - dưới 12 tuổi)</option>' +
            '<option value="Infant"' + (value === 'Infant' ? ' selected' : '') + '>Trẻ sơ sinh (dưới 2 tuổi)</option>' +
            '</select>';
    }

    // updateBookingSummary đếm số Adult/Child/Infant hiện tại và tính lại tổng tiền tour theo lịch đang chọn.
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
            'summary-base-amount': formatMoney(baseAmount) + ' đ'
        };

        Object.keys(targets).forEach(function (id) {
            const element = document.getElementById(id);
            if (element) element.textContent = targets[id];
        });
    }

    // renderParticipants dựng lại toàn bộ form người tham gia theo số lượng hiện tại.
    // previousData là dữ liệu cũ đã collect trước đó để đổ lại vào các input sau khi render.
    function renderParticipants(previousData) {
        if (!countInput || !list) return;
        const count = parseInt(countInput.value, 10);
        const data = previousData || collectParticipants();
        list.innerHTML = '';

        for (let i = 0; i < count; i++) {
            const current = data[i] || { name: '', ageType: 'Adult', phone: '', email: '' };
            const card = document.createElement('div');
            card.className = 'participant-card';
            const titleText = i === 0 ? 'Thông tin trưởng đoàn' : 'Thông tin người đi cùng #' + (i + 1);
            const roleText = i === 0 ? 'Người đại diện liên hệ' : 'Thành viên';
            const removeButton = i === 0 ? '' : '<button type="button" class="remove-participant-btn" data-remove-index="' + i + '" aria-label="Xóa người đi cùng #' + (i + 1) + '" title="Xóa người đi cùng"><i data-lucide="trash-2"></i></button>';
            const phoneRequired = i === 0 ? ' data-required="true"' : '';
            const emailRequired = i === 0 ? ' data-required="true"' : '';

            // Mỗi card có 4 trường: họ tên, độ tuổi, số điện thoại, email.
            // Họ tên bắt buộc cho tất cả; phone/email chỉ bắt buộc với trưởng đoàn.
            card.innerHTML =
                '<div class="participant-card-head"><strong>' + titleText + '</strong><span>' + roleText + '</span>' + removeButton + '</div>' +
                '<div class="participant-fields">' +
                    field('Họ và tên', '<input name="participantName" data-required="true" value="' + escapeHtml(current.name) + '" placeholder="Nhập họ tên">') +
                    field('Độ tuổi', buildAgeTypeSelect(i, current.ageType)) +
                    field('Số điện thoại', '<input name="participantPhone"' + phoneRequired + ' value="' + escapeHtml(current.phone) + '" placeholder="09xxxxxxxx">') +
                    field('Email', '<input name="participantEmail" type="email"' + emailRequired + ' value="' + escapeHtml(current.email) + '" placeholder="email@example.com">') +
                '</div>';
            list.appendChild(card);
        }
        updateBookingSummary();
    }

    // setError in lỗi dưới ô input và bật class input-invalid để viền ô chuyển sang trạng thái lỗi.
    function setError(input, message) {
        const error = input.closest('label').querySelector('.field-error');
        if (error) error.textContent = message;
        input.classList.toggle('input-invalid', Boolean(message));
    }

    // validateCreateForm kiểm tra dữ liệu client-side trước khi submit.
    // Server vẫn validate lại trong BookingCreateController để tránh dữ liệu sửa bằng devtool/request thủ công.
    function validateCreateForm() {
        let valid = true;
        const scheduleError = document.getElementById('schedule-error');
        const checkedSchedule = document.querySelector('[name="scheduleId"]:checked');
        if (scheduleError) scheduleError.textContent = '';
        if (!checkedSchedule) {
            if (scheduleError) scheduleError.textContent = 'Vui lòng chọn một lịch khởi hành.';
            valid = false;
        }

        list.querySelectorAll('input, select').forEach(function (input) {
            setError(input, '');
            if (input.dataset.required === 'true' && !input.value.trim()) {
                setError(input, 'Vui lòng nhập thông tin này.');
                valid = false;
            } else if (input.type === 'email' && input.value.trim() && !input.value.includes('@')) {
                setError(input, 'Email chưa đúng định dạng.');
                valid = false;
            }
        });
        return valid;
    }

    // Khi giảm số người, dữ liệu hiện tại được collect trước rồi render lại theo số lượng mới.
    if (minusBtn) {
        minusBtn.addEventListener('click', function () {
            const data = collectParticipants();
            countInput.value = Math.max(1, parseInt(countInput.value, 10) - 1);
            renderParticipants(data);
        });
    }

    // Khi tăng số người, giữ dữ liệu cũ và thêm một card mới rỗng ở cuối danh sách.
    if (plusBtn) {
        plusBtn.addEventListener('click', function () {
            const data = collectParticipants();
            countInput.value = Math.min(10, parseInt(countInput.value, 10) + 1);
            renderParticipants(data);
        });
    }

    // Thay đổi lịch khởi hành hoặc nhóm tuổi đều cập nhật lại bảng tổng quan đơn đặt.
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


    // Dương làm đoạn này: nút thùng rác chỉ xuất hiện ở người đi cùng để xoá nhanh đúng card đó.
    // Sau khi xoá, danh sách được render lại để số thứ tự, participantCount và bảng tổng quan tiền luôn đồng bộ.
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
    // Chặn submit nếu validate client-side chưa đạt.
    if (createForm) {
        createForm.addEventListener('submit', function (event) {
            if (!validateCreateForm()) {
                event.preventDefault();
            }
        });
    }


    // Dương làm đoạn này: customerNote tự tăng chiều cao theo nội dung khách nhập.
    // Textarea vẫn giữ maxlength=500 nên khi tới giới hạn trình duyệt sẽ không cho nhập thêm ký tự.
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
    // Render mặc định một participant khi trang vừa load.
    renderParticipants([]);
    if (window.lucide) lucide.createIcons();
})();