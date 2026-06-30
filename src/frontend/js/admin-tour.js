document.addEventListener('DOMContentLoaded', () => {
    // Initialize Lucide Icons
    lucide.createIcons();

    // Global Data Holders
    let allTours = [];
    let tourIdToDelete = null;

    // DOM Elements Selector
    const toursTableBody = document.getElementById('tours-table-body');
    const searchFilterInput = document.getElementById('search-filter');
    const categoryFilterSelect = document.getElementById('category-filter');
    const statusFilterSelect = document.getElementById('status-filter');

    // Stats Elements
    const statTotal = document.getElementById('stat-total');
    const statActive = document.getElementById('stat-active');
    const statDraft = document.getElementById('stat-draft');
    const statDisabled = document.getElementById('stat-disabled');

    // Modals
    const tourModal = document.getElementById('tour-modal');
    const modalTitle = document.getElementById('modal-title');
    const tourForm = document.getElementById('tour-form');
    const tourIdInput = document.getElementById('tour-id');
    const modalCloseBtn = document.getElementById('modal-close');
    const modalCancelBtn = document.getElementById('modal-cancel');
    const addTourBtn = document.getElementById('add-tour-btn');

    // Confirm Modal
    const confirmModal = document.getElementById('confirm-modal');
    const confirmCancelBtn = document.getElementById('confirm-cancel');
    const confirmDeleteBtn = document.getElementById('confirm-delete');

    // Inclusions Selectors
    const inclusionsInputsList = document.getElementById('inclusions-inputs-list');
    const btnAddInclusionRow = document.getElementById('btn-add-inclusion-row');

    if (btnAddInclusionRow) {
        btnAddInclusionRow.addEventListener('click', () => {
            addInclusionRow();
        });
    }

    function addInclusionRow(type = 'INCLUDED', icon = 'sparkles', name = '') {
        if (!inclusionsInputsList) return;
        const row = document.createElement('div');
        row.className = 'inclusion-input-row';
        row.style.display = 'grid';
        row.style.gridTemplateColumns = '140px 140px 1fr auto';
        row.style.gap = '0.75rem';
        row.style.alignItems = 'center';

        row.innerHTML = `
            <div class="select-wrapper">
                <select name="incType" required>
                    <option value="INCLUDED" ${type === 'INCLUDED' ? 'selected' : ''}>Bao gồm</option>
                    <option value="EXCLUDED" ${type === 'EXCLUDED' ? 'selected' : ''}>Không bao gồm</option>
                </select>
            </div>
            <div class="select-wrapper">
                <select name="incIcon" required>
                    <option value="sparkles" ${icon === 'sparkles' ? 'selected' : ''}>Lấp lánh</option>
                    <option value="car" ${icon === 'car' ? 'selected' : ''}>Xe cộ (car)</option>
                    <option value="hotel" ${icon === 'hotel' ? 'selected' : ''}>Khách sạn (hotel)</option>
                    <option value="utensils" ${icon === 'utensils' ? 'selected' : ''}>Ăn uống (utensils)</option>
                    <option value="ticket" ${icon === 'ticket' ? 'selected' : ''}>Vé tham quan (ticket)</option>
                    <option value="shield" ${icon === 'shield' ? 'selected' : ''}>Bảo hiểm (shield)</option>
                    <option value="plane" ${icon === 'plane' ? 'selected' : ''}>Máy bay (plane)</option>
                    <option value="glass-water" ${icon === 'glass-water' ? 'selected' : ''}>Nước uống (glass-water)</option>
                    <option value="badge-dollar-sign" ${icon === 'badge-dollar-sign' ? 'selected' : ''}>Tiền tip</option>
                    <option value="landmark" ${icon === 'landmark' ? 'selected' : ''}>Thuế VAT</option>
                </select>
            </div>
            <input type="text" name="incService" required placeholder="Tên dịch vụ..." value="${escapeHtml(name)}" style="width: 100%; padding: 0.7rem 0.9rem; border: 1px solid rgba(95, 59, 246, 0.25); border-radius: var(--radius-md); background: rgba(0, 0, 0, 0.2); color: var(--text-light);">
            <button type="button" class="btn btn-danger btn-icon-only btn-sm btn-remove-inc-row" style="background: none; border: none; color: var(--error-red); cursor: pointer;" title="Xóa dòng">
                <i data-lucide="trash-2" style="width: 14px; height: 14px;"></i>
            </button>
        `;

        inclusionsInputsList.appendChild(row);
        if (window.lucide) {
            lucide.createIcons();
        }

        row.querySelector('.btn-remove-inc-row').addEventListener('click', () => {
            row.remove();
        });
    }

    function escapeHtml(str) {
        if (!str) return '';
        return str.replace(/&/g, "&amp;")
                  .replace(/</g, "&lt;")
                  .replace(/>/g, "&gt;")
                  .replace(/"/g, "&quot;")
                  .replace(/'/g, "&#039;");
    }

    /* ── Fetch Tours from DB ── */
    function fetchTours() {
        // Relative to admin/tours or admin/dashboard
        fetch('tours?ajax=true')
            .then(res => {
                if (!res.ok) throw new Error('Không thể kết nối đến máy chủ');
                return res.json();
            })
            .then(data => {
                allTours = Array.isArray(data) ? data : data.tours;
                updateStats();
                renderTable();
            })
            .catch(err => {
                console.error(err);
                showToast(err.message || 'Lỗi tải danh sách tour du lịch', 'error');
            });
    }

    /* ── Update KPI Stats ── */
    function updateStats() {
        const total = allTours.length;
        const active = allTours.filter(t => t.status === 'Active').length;
        const draft = allTours.filter(t => t.status === 'Draft').length;
        const disabled = allTours.filter(t => t.status === 'Inactive').length;

        animateNumber('stat-total', total);
        animateNumber('stat-active', active);
        animateNumber('stat-draft', draft);
        animateNumber('stat-disabled', disabled);

        // Update footers dynamically to remove hardcoding
        const currentMonthPrefix = new Date().toISOString().substring(0, 7); // e.g. "2026-06"
        const newToursInMonth = allTours.filter(t => t.createdAt && t.createdAt.startsWith(currentMonthPrefix)).length;

        const totalFooter = document.getElementById('stat-total-footer');
        if (totalFooter) {
            totalFooter.innerHTML = `
                <span class="stat-trend up"><i data-lucide="trending-up"></i> +${newToursInMonth} tour</span>
                <span>mới thêm trong tháng</span>
            `;
        }

        const activeFooter = document.getElementById('stat-active-footer');
        if (activeFooter) {
            activeFooter.innerHTML = `
                <span class="stat-trend up"><i data-lucide="trending-up"></i> ${active} tour</span>
                <span>đang hoạt động</span>
            `;
        }

        const draftFooter = document.getElementById('stat-draft-footer');
        if (draftFooter) {
            draftFooter.innerHTML = `
                <span class="stat-trend"><i data-lucide="file-edit"></i> ${draft} bản nháp</span>
                <span>chờ xuất bản</span>
            `;
        }

        const disabledFooter = document.getElementById('stat-disabled-footer');
        if (disabledFooter) {
            disabledFooter.innerHTML = `
                <span class="stat-trend"><i data-lucide="eye-off"></i> ${disabled} tạm ngưng</span>
                <span>đang tạm ẩn</span>
            `;
        }

        if (window.lucide) {
            lucide.createIcons();
        }
    }

    // Smooth count-up micro-animation for numbers
    function animateNumber(elementId, targetValue) {
        const el = document.getElementById(elementId);
        if (!el) return;
        
        let current = parseInt(el.textContent) || 0;
        if (current === targetValue) {
            el.textContent = targetValue;
            return;
        }
        
        const step = Math.ceil(Math.abs(targetValue - current) / 15) || 1;
        const interval = setInterval(() => {
            if (current < targetValue) {
                current = Math.min(current + step, targetValue);
            } else {
                current = Math.max(current - step, targetValue);
            }
            el.textContent = current;
            if (current === targetValue) {
                clearInterval(interval);
            }
        }, 20);
    }

    /* ── Render Tours Table ── */
    function renderTable() {
        toursTableBody.innerHTML = '';
        
        const searchQuery = searchFilterInput.value.toLowerCase().trim();
        const categoryFilter = categoryFilterSelect.value;
        const statusFilter = statusFilterSelect.value;

        // Perform client-side search & filtering
        const filtered = allTours.filter(tour => {
            const matchesSearch = 
                tour.tourName.toLowerCase().includes(searchQuery) ||
                tour.destination.toLowerCase().includes(searchQuery) ||
                tour.departureCity.toLowerCase().includes(searchQuery);

            const matchesCategory = categoryFilter === 'all' || tour.categoryId.toString() === categoryFilter;
            const matchesStatus = statusFilter === 'all' || tour.status === statusFilter;

            return matchesSearch && matchesCategory && matchesStatus;
        });

        if (filtered.length === 0) {
            toursTableBody.innerHTML = `
                <tr>
                    <td colspan="7" style="text-align: center; color: var(--slate-400); padding: 4rem 0;">
                        <i data-lucide="compass" style="width: 2.5rem; height: 2.5rem; margin-bottom: 0.5rem; opacity: 0.5;"></i>
                        <p>Không tìm thấy tour du lịch nào phù hợp.</p>
                    </td>
                </tr>
            `;
            lucide.createIcons();
            return;
        }

        filtered.forEach(tour => {
            const tr = document.createElement('tr');
            
            // Format status badge label
            let statusText = 'Bản nháp';
            if (tour.status === 'Active') statusText = 'Hoạt động';
            else if (tour.status === 'Inactive') statusText = 'Tạm ngưng';

            // Determine image preview
            let previewImg = tour.videoUrl || ''; // Dummy path
            if (tour.tourName.toLowerCase().includes('đà nẵng')) previewImg = '../assets/images/tour_danang.png';
            else if (tour.tourName.toLowerCase().includes('phú quốc')) previewImg = '../assets/images/tour_phuquoc.png';
            else if (tour.tourName.toLowerCase().includes('hạ long')) previewImg = '../assets/images/tour_halong.png';
            else if (tour.tourName.toLowerCase().includes('hội an')) previewImg = '../assets/images/tour_hoian.png';
            else if (tour.tourName.toLowerCase().includes('đà lạt')) previewImg = '../assets/images/tour_dalat.png';
            else if (tour.tourName.toLowerCase().includes('sa pa') || tour.tourName.toLowerCase().includes('sapa')) previewImg = '../assets/images/tour_sapa.png';
            else if (tour.tourName.toLowerCase().includes('nha trang')) previewImg = '../assets/images/tour_nhatrang.png';
            else if (tour.tourName.toLowerCase().includes('hà giang')) previewImg = '../assets/images/tour_hagiang.png';
            else previewImg = '../assets/images/tour_halong.png'; // standard fallback

            tr.innerHTML = `
                <td>
                    <div class="tour-cell">
                        <img src="${previewImg}" alt="${tour.tourName}" class="tour-cell-img" onerror="this.src='../assets/images/tour_halong.png'">
                        <div class="tour-cell-info">
                            <span class="tour-cell-name" title="${tour.tourName}">${tour.tourName}</span>
                            <span class="tour-cell-dest">
                                <i data-lucide="map-pin" style="width: 12px; height: 12px;"></i>
                                ${tour.departureCity} &rarr; ${tour.destination}
                            </span>
                        </div>
                    </div>
                </td>
                <td><span style="font-weight: 500;">${tour.categoryName}</span></td>
                <td>${tour.durationDays} Ngày</td>
                <td><span style="font-weight: 600; color: var(--warning-amber);">${tour.basePrice.toLocaleString('vi-VN')} ₫</span></td>
                <td>
                    <span class="badge badge-${tour.status.toLowerCase()}">
                        ${statusText}
                    </span>
                </td>
                <td><span style="color: var(--slate-500); font-size: 0.85rem;">${tour.createdAt || '2026-05-20'}</span></td>
                <td style="text-align: right; padding-right: 2rem;">
                    <div class="actions-cell" style="justify-content: flex-end;">
                        <button class="btn btn-secondary btn-icon-only btn-sm edit-btn" data-id="${tour.tourId}" title="Chỉnh sửa tour">
                            <i data-lucide="edit-3" style="width: 14px; height: 14px;"></i>
                        </button>
                        <button class="btn btn-secondary btn-icon-only btn-sm toggle-status-btn" data-id="${tour.tourId}" data-status="${tour.status}" title="${tour.status === 'Active' ? 'Tạm ngưng tour' : 'Kích hoạt hoạt động'}">
                            <i data-lucide="${tour.status === 'Active' ? 'eye-off' : 'eye'}" style="width: 14px; height: 14px; color: ${tour.status === 'Active' ? 'var(--slate-500)' : 'var(--primary)'};"></i>
                        </button>
                        <button class="btn btn-danger btn-icon-only btn-sm delete-btn" data-id="${tour.tourId}" title="Xóa tour">
                            <i data-lucide="trash-2" style="width: 14px; height: 14px;"></i>
                        </button>
                    </div>
                </td>
            `;

            toursTableBody.appendChild(tr);
        });

        // Re-apply Lucide Icons
        lucide.createIcons();

        // Attach action listeners
        attachTableActionListeners();
    }

    /* ── Action Listeners inside Table Rows ── */
    function attachTableActionListeners() {
        // Edit Button Click
        toursTableBody.querySelectorAll('.edit-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const id = parseInt(btn.getAttribute('data-id'));
                const tour = allTours.find(t => t.tourId === id);
                if (tour) {
                    openEditModal(tour);
                }
            });
        });

        // Toggle Status Click
        toursTableBody.querySelectorAll('.toggle-status-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const id = parseInt(btn.getAttribute('data-id'));
                const currentStatus = btn.getAttribute('data-status');
                const newStatus = currentStatus === 'Active' ? 'Inactive' : 'Active';
                toggleTourStatus(id, newStatus);
            });
        });

        // Delete Button Click
        toursTableBody.querySelectorAll('.delete-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                tourIdToDelete = parseInt(btn.getAttribute('data-id'));
                openConfirmModal();
            });
        });
    }

    /* ── Toggle Status AJAX Call ── */
    function toggleTourStatus(tourId, newStatus) {
        const params = new URLSearchParams();
        params.append('action', 'toggle-status');
        params.append('tourId', tourId);
        params.append('status', newStatus);

        fetch('tours', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
            body: params.toString()
        })
        .then(res => {
            if (!res.ok) throw new Error('Phản hồi mạng không hợp lệ');
            return res.json();
        })
        .then(data => {
            if (data.status === 'success') {
                showToast(data.message || 'Cập nhật trạng thái thành công!');
                fetchTours();
            } else {
                showToast(data.message || 'Lỗi cập nhật trạng thái', 'error');
            }
        })
        .catch(err => {
            console.error(err);
            showToast('Lỗi kết nối máy chủ', 'error');
        });
    }

    /* ── Delete Tour AJAX Call ── */
    function performDeleteTour(tourId) {
        const params = new URLSearchParams();
        params.append('action', 'delete');
        params.append('tourId', tourId);

        fetch('tours', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
            body: params.toString()
        })
        .then(res => {
            if (!res.ok) throw new Error('Phản hồi mạng không hợp lệ');
            return res.json();
        })
        .then(data => {
            if (data.status === 'success') {
                showToast(data.message || 'Xóa tour thành công!');
                closeConfirmModal();
                fetchTours();
            } else {
                showToast(data.message || 'Lỗi khi xóa tour', 'error');
                closeConfirmModal();
            }
        })
        .catch(err => {
            console.error(err);
            showToast('Lỗi kết nối máy chủ khi xóa tour', 'error');
            closeConfirmModal();
        });
    }

    /* ── Add / Edit Modal Actions ── */
    addTourBtn.addEventListener('click', () => {
        openAddModal();
    });

    modalCloseBtn.addEventListener('click', () => closeModal());
    modalCancelBtn.addEventListener('click', () => closeModal());
    
    // Close modal by clicking overlay
    tourModal.addEventListener('click', (e) => {
        if (e.target === tourModal) closeModal();
    });

    function openAddModal() {
        modalTitle.textContent = 'Thêm Tour Mới';
        tourForm.reset();
        tourIdInput.value = '';
        document.getElementById('tour-status').value = 'Draft';
        document.getElementById('tour-max-parts').value = '20';
        document.getElementById('tour-group-min').value = '1';
        document.getElementById('tour-group-max').value = '20';
        document.getElementById('tour-featured').checked = false;
        
        // Clear and add empty inclusions rows
        if (inclusionsInputsList) {
            inclusionsInputsList.innerHTML = '';
            addInclusionRow('INCLUDED', 'sparkles', '');
            addInclusionRow('EXCLUDED', 'plane', '');
        }
        
        tourModal.classList.add('open');
    }

    function openEditModal(tour) {
        modalTitle.textContent = 'Chỉnh Sửa Tour';
        tourForm.reset();
        
        // Populate inputs
        tourIdInput.value = tour.tourId;
        document.getElementById('tour-name').value = tour.tourName;
        document.getElementById('tour-category').value = tour.categoryId;
        document.getElementById('tour-difficulty').value = tour.difficultyLevel;
        document.getElementById('tour-status').value = tour.status;
        
        document.getElementById('tour-price').value = tour.basePrice;
        document.getElementById('tour-duration').value = tour.durationDays;
        document.getElementById('tour-max-parts').value = tour.maxParticipants;
        
        document.getElementById('tour-group-min').value = tour.groupSizeMin;
        document.getElementById('tour-group-max').value = tour.groupSizeMax;
        document.getElementById('tour-departure').value = tour.departureCity;
        document.getElementById('tour-destination').value = tour.destination;
        
        document.getElementById('tour-languages').value = tour.languages;
        // Parse floats safely
        document.getElementById('tour-latitude').value = tour.latitude || '';
        document.getElementById('tour-longitude').value = tour.longitude || '';
        document.getElementById('tour-video').value = tour.videoUrl || '';
        
        document.getElementById('tour-description').value = tour.description;
        
        // Nếu tour.itinerary có sẵn text thì điền vào, ngược lại load từ bảng TourItinerary trong DB
        const itineraryTextarea = document.getElementById('tour-itinerary');
        if (tour.itinerary && tour.itinerary.trim() !== '') {
            itineraryTextarea.value = tour.itinerary;
        } else {
            // Load từ bảng TourItinerary → dựng lại text để admin chỉnh sửa
            itineraryTextarea.value = 'Đang tải lịch trình...';
            fetch(`tours?ajax=true&action=getItinerary&tourId=${tour.tourId}`)
                .then(res => res.json())
                .then(data => {
                    itineraryTextarea.value = data.text || '';
                })
                .catch(() => {
                    itineraryTextarea.value = '';
                });
        }
        
        document.getElementById('tour-featured').checked = tour.isFeatured;

        // Load inclusions dynamically via AJAX
        if (inclusionsInputsList) {
            inclusionsInputsList.innerHTML = '';
            fetch(`tours?ajax=true&action=getInclusions&tourId=${tour.tourId}`)
                .then(res => res.json())
                .then(inclusions => {
                    if (inclusions && inclusions.length > 0) {
                        inclusions.forEach(inc => {
                            addInclusionRow(inc.inclusionType, inc.iconName, inc.serviceName);
                        });
                    } else {
                        addInclusionRow('INCLUDED', 'sparkles', '');
                        addInclusionRow('EXCLUDED', 'plane', '');
                    }
                })
                .catch(err => {
                    console.error('Lỗi khi tải dịch vụ đi kèm:', err);
                    addInclusionRow('INCLUDED', 'sparkles', '');
                    addInclusionRow('EXCLUDED', 'plane', '');
                });
        }

        tourModal.classList.add('open');
    }

    function closeModal() {
        tourModal.classList.remove('open');
    }

    /* ── Form Submit (Add/Edit) ── */
    tourForm.addEventListener('submit', (e) => {
        e.preventDefault();

        const formData = new FormData(tourForm);
        const params = new URLSearchParams();
        
        // Build URL parameters
        for (const [key, value] of formData.entries()) {
            if (key === 'isFeatured') {
                // If present in formData, it means checked, value will be true
                params.append(key, 'true');
            } else {
                params.append(key, value);
            }
        }
        
        // Handle unchecked isFeatured
        if (!params.has('isFeatured')) {
            params.append('isFeatured', 'false');
        }

        const id = tourIdInput.value;
        const isEdit = id && id !== '';
        params.append('action', isEdit ? 'edit' : 'add');

        fetch('tours', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
            body: params.toString()
        })
        .then(res => {
            if (!res.ok) throw new Error('Không thể lưu thông tin tour');
            return res.json();
        })
        .then(data => {
            if (data.status === 'success') {
                showToast(data.message || 'Lưu thành công!');
                closeModal();
                fetchTours();
            } else {
                showToast(data.message || 'Lỗi khi lưu thông tin', 'error');
            }
        })
        .catch(err => {
            console.error(err);
            showToast(err.message || 'Lỗi kết nối máy chủ', 'error');
        });
    });

    /* ── Delete Confirmation Modal Actions ── */
    confirmCancelBtn.addEventListener('click', () => closeConfirmModal());
    confirmModal.addEventListener('click', (e) => {
        if (e.target === confirmModal) closeConfirmModal();
    });

    confirmDeleteBtn.addEventListener('click', () => {
        if (tourIdToDelete) {
            performDeleteTour(tourIdToDelete);
        }
    });

    function openConfirmModal() {
        confirmModal.classList.add('open');
    }

    function closeConfirmModal() {
        confirmModal.classList.remove('open');
        tourIdToDelete = null;
    }

    /* ── Filter & Search Listeners ── */
    let searchTimeout;
    searchFilterInput.addEventListener('input', () => {
        clearTimeout(searchTimeout);
        // Debounce search slightly to make it ultra smooth
        searchTimeout = setTimeout(() => {
            renderTable();
        }, 150);
    });

    categoryFilterSelect.addEventListener('change', () => renderTable());
    statusFilterSelect.addEventListener('change', () => renderTable());

    /* ── Custom Toast Notification Helper ── */
    function showToast(message, type = 'success') {
        const container = document.getElementById('toast-container');
        if (!container) return;

        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;
        
        toast.innerHTML = `
            <div class="toast-body">
                <i data-lucide="${type === 'success' ? 'check-circle-2' : 'alert-circle'}" class="${type === 'success' ? 'success-icon' : 'error-icon'}" style="width: 1.2rem; height: 1.2rem;"></i>
                <span class="toast-message">${message}</span>
            </div>
            <button class="toast-close" type="button"><i data-lucide="x" style="width: 0.9rem; height: 0.9rem;"></i></button>
        `;
        
        container.appendChild(toast);
        lucide.createIcons();

        // Close toast on button click
        toast.querySelector('.toast-close').addEventListener('click', () => {
            toast.classList.add('fade-out');
            setTimeout(() => toast.remove(), 300);
        });

        // Auto close after 4 seconds
        setTimeout(() => {
            if (toast.parentNode) {
                toast.classList.add('fade-out');
                setTimeout(() => toast.remove(), 300);
            }
        }, 4000);
    }

    // Toggle profile avatar dropdown
    const profileTrigger = document.getElementById('admin-profile-trigger');
    const avatarMenu = document.getElementById('admin-avatar-menu');
    if (profileTrigger && avatarMenu) {
        profileTrigger.addEventListener('click', (e) => {
            e.stopPropagation();
            const isOpen = avatarMenu.style.display === 'flex';
            avatarMenu.style.display = isOpen ? 'none' : 'flex';
        });
        document.addEventListener('click', () => {
            avatarMenu.style.display = 'none';
        });
    }

    // First load
    fetchTours();
});
