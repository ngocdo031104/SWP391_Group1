/*
 * Người làm: Dương
 * Thời gian tạo: 04/06/2026
 * Chức năng: JavaScript cho màn Customer tạo booking.
 * Ý nghĩa: Giữ dữ liệu người tham gia khi tăng/giảm số lượng và validate lỗi ngay dưới từng ô nhập.
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

    // collectParticipants đọc dữ liệu hiện có trước khi render lại danh sách card.
    // Mục đích là khi khách bấm tăng/giảm số người, thông tin đã nhập ở các card cũ không bị mất.
    function collectParticipants() {
        if (!list) return [];
        const cards = list.querySelectorAll('.participant-card');
        const data = [];
        cards.forEach(function (card) {
            data.push({
                name: card.querySelector('[name="participantName"]').value,
                ageType: card.querySelector('[name="participantAgeType"]').value,
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
            const phoneRequired = i === 0 ? ' data-required="true"' : '';
            const emailRequired = i === 0 ? ' data-required="true"' : '';

            // Mỗi card có 4 trường: họ tên, độ tuổi, số điện thoại, email.
            // Họ tên bắt buộc cho tất cả; phone/email chỉ bắt buộc với trưởng đoàn.
            card.innerHTML =
                '<div class="participant-card-head"><strong>' + titleText + '</strong><span>' + roleText + '</span></div>' +
                '<div class="participant-fields">' +
                    field('Họ và tên', '<input name="participantName" data-required="true" value="' + escapeHtml(current.name) + '" placeholder="Nhập họ tên">') +
                    field('Độ tuổi', '<select name="participantAgeType"><option value="Adult">Người lớn</option><option value="Child">Trẻ em</option><option value="Infant">Em bé</option></select>') +
                    field('Số điện thoại', '<input name="participantPhone"' + phoneRequired + ' value="' + escapeHtml(current.phone) + '" placeholder="09xxxxxxxx">') +
                    field('Email', '<input name="participantEmail" type="email"' + emailRequired + ' value="' + escapeHtml(current.email) + '" placeholder="email@example.com">') +
                '</div>';
            list.appendChild(card);
            card.querySelector('[name="participantAgeType"]').value = current.ageType || 'Adult';
        }
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

    // Chặn submit nếu validate client-side chưa đạt.
    if (createForm) {
        createForm.addEventListener('submit', function (event) {
            if (!validateCreateForm()) {
                event.preventDefault();
            }
        });
    }

    // Render mặc định một participant khi trang vừa load.
    renderParticipants([]);
    if (window.lucide) lucide.createIcons();
})();