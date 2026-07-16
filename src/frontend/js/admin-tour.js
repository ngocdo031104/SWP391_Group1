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
                    <option value="INCLUDED" ${type === 'INCLUDED' ? 'selected' : ''}>Bao g\u1ed3m</option>
                    <option value="EXCLUDED" ${type === 'EXCLUDED' ? 'selected' : ''}>Kh\u00f4ng bao g\u1ed3m</option>
                </select>
            </div>
            <div class="select-wrapper">
                <select name="incIcon" required>
                    <option value="sparkles" ${icon === 'sparkles' ? 'selected' : ''}>L\u1ea5p l\u00e1nh</option>
                    <option value="car" ${icon === 'car' ? 'selected' : ''}>Xe c\u1ed9 (car)</option>
                    <option value="hotel" ${icon === 'hotel' ? 'selected' : ''}>Kh\u00e1ch s\u1ea1n (hotel)</option>
                    <option value="utensils" ${icon === 'utensils' ? 'selected' : ''}>\u0102n u\u1ed1ng (utensils)</option>
                    <option value="ticket" ${icon === 'ticket' ? 'selected' : ''}>V\u00e9 tham quan (ticket)</option>
                    <option value="shield" ${icon === 'shield' ? 'selected' : ''}>B\u1ea3o hi\u1ec3m (shield)</option>
                    <option value="plane" ${icon === 'plane' ? 'selected' : ''}>M\u00e1y bay (plane)</option>
                    <option value="glass-water" ${icon === 'glass-water' ? 'selected' : ''}>N\u01b0\u1edbc u\u1ed1ng (glass-water)</option>
                    <option value="badge-dollar-sign" ${icon === 'badge-dollar-sign' ? 'selected' : ''}>Ti\u1ec1n tip</option>
                    <option value="landmark" ${icon === 'landmark' ? 'selected' : ''}>Thu\u1ebf VAT</option>
                </select>
            </div>
            <input type="text" name="incService" required placeholder="T\u00ean d\u1ecbch v\u1ee5..." value="${escapeHtml(name)}" style="width: 100%; padding: 0.7rem 0.9rem; border: 1px solid rgba(95, 59, 246, 0.25); border-radius: var(--radius-md); background: rgba(0, 0, 0, 0.2); color: var(--text-light);">
            <button type="button" class="btn btn-danger btn-icon-only btn-sm btn-remove-inc-row" style="background: none; border: none; color: var(--error-red); cursor: pointer;" title="X\u00f3a d\u00f2ng">
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

    /* \u2500\u2500 Fetch Tours from DB \u2500\u2500 */
    function fetchTours() {
        // Relative to admin/tours or admin/dashboard
        fetch('tours?ajax=true')
            .then(res => {
                if (!res.ok) throw new Error('Kh\u00f4ng th\u1ec3 k\u1ebft n\u1ed1i \u0111\u1ebfn m\u00e1y ch\u1ee7');
                return res.json();
            })
            .then(data => {
                allTours = Array.isArray(data) ? data : data.tours;
                updateStats();
                renderTable();
            })
            .catch(err => {
                console.error(err);
                showToast(err.message || 'L\u1ed7i t\u1ea3i danh s\u00e1ch tour du l\u1ecbch', 'error');
            });
    }

    /* \u2500\u2500 Update KPI Stats \u2500\u2500 */
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
                <span>m\u1edbi th\u00eam trong th\u00e1ng</span>
            `;
        }

        const activeFooter = document.getElementById('stat-active-footer');
        if (activeFooter) {
            activeFooter.innerHTML = `
                <span class="stat-trend up"><i data-lucide="trending-up"></i> ${active} tour</span>
                <span>\u0111ang ho\u1ea1t \u0111\u1ed9ng</span>
            `;
        }

        const draftFooter = document.getElementById('stat-draft-footer');
        if (draftFooter) {
            draftFooter.innerHTML = `
                <span class="stat-trend"><i data-lucide="file-edit"></i> ${draft} b\u1ea3n nh\u00e1p</span>
                <span>ch\u1edd xu\u1ea5t b\u1ea3n</span>
            `;
        }

        const disabledFooter = document.getElementById('stat-disabled-footer');
        if (disabledFooter) {
            disabledFooter.innerHTML = `
                <span class="stat-trend"><i data-lucide="eye-off"></i> ${disabled} t\u1ea1m ng\u01b0ng</span>
                <span>\u0111ang t\u1ea1m \u1ea9n</span>
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

    /* \u2500\u2500 Render Tours Table \u2500\u2500 */
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
                        <p>Kh\u00f4ng t\u00ecm th\u1ea5y tour du l\u1ecbch n\u00e0o ph\u00f9 h\u1ee3p.</p>
                    </td>
                </tr>
            `;
            lucide.createIcons();
            return;
        }

        filtered.forEach(tour => {
            const tr = document.createElement('tr');
            
            // Format status badge label
            let statusText = 'B\u1ea3n nh\u00e1p';
            if (tour.status === 'Active') statusText = 'Ho\u1ea1t \u0111\u1ed9ng';
            else if (tour.status === 'Inactive') statusText = 'T\u1ea1m ng\u01b0ng';

            // Determine image preview
            let previewImg = tour.videoUrl || ''; // Dummy path
            if (tour.tourName.toLowerCase().includes('\u0111\u00e0 n\u1eb5ng')) previewImg = '../assets/images/tour_danang.png';
            else if (tour.tourName.toLowerCase().includes('ph\u00fa qu\u1ed1c')) previewImg = '../assets/images/tour_phuquoc.png';
            else if (tour.tourName.toLowerCase().includes('h\u1ea1 long')) previewImg = '../assets/images/tour_halong.png';
            else if (tour.tourName.toLowerCase().includes('h\u1ed9i an')) previewImg = '../assets/images/tour_hoian.png';
            else if (tour.tourName.toLowerCase().includes('\u0111\u00e0 l\u1ea1t')) previewImg = '../assets/images/tour_dalat.png';
            else if (tour.tourName.toLowerCase().includes('sa pa') || tour.tourName.toLowerCase().includes('sapa')) previewImg = '../assets/images/tour_sapa.png';
            else if (tour.tourName.toLowerCase().includes('nha trang')) previewImg = '../assets/images/tour_nhatrang.png';
            else if (tour.tourName.toLowerCase().includes('h\u00e0 giang')) previewImg = '../assets/images/tour_hagiang.png';
            else previewImg = '../assets/images/tour_halong.png'; // standard fallback

            // Escape các trường do admin/người dùng nhập trước khi nhúng vào innerHTML
            // để chặn stored XSS khi 1 admin khác (hoặc kẻ tấn công có session admin)
            // cố tình nhập tourName/destination chứa <script> hoặc onerror handler.
            const safeTourName = escapeHtml(tour.tourName);
            const safePreviewImg = escapeHtml(previewImg);
            const safeDepartureCity = escapeHtml(tour.departureCity);
            const safeDestination = escapeHtml(tour.destination);
            const safeCategoryName = escapeHtml(tour.categoryName);
            const safeStatus = escapeHtml(tour.status);
            const safeCreatedAt = escapeHtml(tour.createdAt || '2026-05-20');
            const safeTourId = parseInt(tour.tourId, 10) || 0;
            const safeDurationDays = parseInt(tour.durationDays, 10) || 0;
            const safeBasePrice = Number(tour.basePrice) || 0;

            tr.innerHTML = `
                <td>
                    <div class="tour-cell">
                        <img src="${safePreviewImg}" alt="${safeTourName}" class="tour-cell-img" onerror="this.src='../assets/images/tour_halong.png'">
                        <div class="tour-cell-info">
                            <span class="tour-cell-name" title="${safeTourName}">${safeTourName}</span>
                            <span class="tour-cell-dest">
                                <i data-lucide="map-pin" style="width: 12px; height: 12px;"></i>
                                ${safeDepartureCity} &rarr; ${safeDestination}
                            </span>
                        </div>
                    </div>
                </td>
                <td><span style="font-weight: 500;">${safeCategoryName}</span></td>
                <td>${safeDurationDays} Ng\u00e0y</td>
                <td><span style="font-weight: 600; color: var(--warning-amber);">${safeBasePrice.toLocaleString('vi-VN')} \u20ab</span></td>
                <td>
                    <span class="badge badge-${safeStatus.toLowerCase()}">
                        ${statusText}
                    </span>
                </td>
                <td><span style="color: var(--slate-500); font-size: 0.85rem;">${safeCreatedAt}</span></td>
                <td style="text-align: right; padding-right: 2rem;">
                    <div class="actions-cell" style="justify-content: flex-end;">
                        <button class="btn btn-secondary btn-icon-only btn-sm edit-btn" data-id="${safeTourId}" title="Ch\u1ec9nh s\u1eeda tour">
                            <i data-lucide="edit-3" style="width: 14px; height: 14px;"></i>
                        </button>
                        <button class="btn btn-secondary btn-icon-only btn-sm toggle-status-btn" data-id="${safeTourId}" data-status="${safeStatus}" title="${safeStatus === 'Active' ? 'T\u1ea1m ng\u01b0ng tour' : 'K\u00edch ho\u1ea1t ho\u1ea1t \u0111\u1ed9ng'}">
                            <i data-lucide="${safeStatus === 'Active' ? 'eye-off' : 'eye'}" style="width: 14px; height: 14px; color: ${safeStatus === 'Active' ? 'var(--slate-500)' : 'var(--primary)'};"></i>
                        </button>
                        <button class="btn btn-danger btn-icon-only btn-sm delete-btn" data-id="${safeTourId}" title="X\u00f3a tour">
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

    /* \u2500\u2500 Action Listeners inside Table Rows \u2500\u2500 */
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

    /* \u2500\u2500 Toggle Status AJAX Call \u2500\u2500 */
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
            if (!res.ok) throw new Error('Ph\u1ea3n h\u1ed3i m\u1ea1ng kh\u00f4ng h\u1ee3p l\u1ec7');
            return res.json();
        })
        .then(data => {
            if (data.status === 'success') {
                showToast(data.message || 'C\u1eadp nh\u1eadt tr\u1ea1ng th\u00e1i th\u00e0nh c\u00f4ng!');
                fetchTours();
            } else {
                showToast(data.message || 'L\u1ed7i c\u1eadp nh\u1eadt tr\u1ea1ng th\u00e1i', 'error');
            }
        })
        .catch(err => {
            console.error(err);
            showToast('L\u1ed7i k\u1ebft n\u1ed1i m\u00e1y ch\u1ee7', 'error');
        });
    }

    /* \u2500\u2500 Delete Tour AJAX Call \u2500\u2500 */
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
            if (!res.ok) throw new Error('Ph\u1ea3n h\u1ed3i m\u1ea1ng kh\u00f4ng h\u1ee3p l\u1ec7');
            return res.json();
        })
        .then(data => {
            if (data.status === 'success') {
                showToast(data.message || 'X\u00f3a tour th\u00e0nh c\u00f4ng!');
                closeConfirmModal();
                fetchTours();
            } else {
                showToast(data.message || 'L\u1ed7i khi x\u00f3a tour', 'error');
                closeConfirmModal();
            }
        })
        .catch(err => {
            console.error(err);
            showToast('L\u1ed7i k\u1ebft n\u1ed1i m\u00e1y ch\u1ee7 khi x\u00f3a tour', 'error');
            closeConfirmModal();
        });
    }

    /* \u2500\u2500 Add / Edit Modal Actions \u2500\u2500 */
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
        modalTitle.textContent = 'Th\u00eam Tour M\u1edbi';
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
        modalTitle.textContent = 'Ch\u1ec9nh S\u1eeda Tour';
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
        document.getElementById('tour-departure').value = tour.departureCity || '';
        document.getElementById('tour-destination').value = tour.destination || '';
        
        document.getElementById('tour-languages').value = tour.languages || '';
        // Parse floats safely
        document.getElementById('tour-latitude').value = tour.latitude || '';
        document.getElementById('tour-longitude').value = tour.longitude || '';
        document.getElementById('tour-video').value = tour.videoUrl || '';
        
        document.getElementById('tour-description').value = tour.description || '';
        
        // N\u1ebfu tour.itinerary c\u00f3 s\u1eb5n text th\u00ec \u0111i\u1ec1n v\u00e0o, ng\u01b0\u1ee3c l\u1ea1i load t\u1eeb b\u1ea3ng TourItinerary trong DB
        const itineraryTextarea = document.getElementById('tour-itinerary');
        if (tour.itinerary && tour.itinerary.trim() !== '') {
            itineraryTextarea.value = tour.itinerary;
        } else {
            // Load t\u1eeb b\u1ea3ng TourItinerary \u2192 d\u1ef1ng l\u1ea1i text \u0111\u1ec3 admin ch\u1ec9nh s\u1eeda
            itineraryTextarea.value = '\u0110ang t\u1ea3i l\u1ecbch tr\u00ecnh...';
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
                    console.error('L\u1ed7i khi t\u1ea3i d\u1ecbch v\u1ee5 \u0111i k\u00e8m:', err);
                    addInclusionRow('INCLUDED', 'sparkles', '');
                    addInclusionRow('EXCLUDED', 'plane', '');
                });
        }

        tourModal.classList.add('open');
    }

    function closeModal() {
        tourModal.classList.remove('open');
    }

    /* \u2500\u2500 Form Submit (Add/Edit) \u2500\u2500 */
    tourForm.addEventListener('submit', (e) => {
        e.preventDefault();

        // K\u00edch ho\u1ea1t c\u01a1 ch\u1ebf ki\u1ec3m tra h\u1ee3p l\u1ec7 m\u1eb7c \u0111\u1ecbnh c\u1ee7a HTML5 (tr\u1ed1ng, min, max, type...)
        if (!tourForm.reportValidity()) {
            return;
        }

        // \u2500\u2500 CLIENT-SIDE VALIDATION RULES (LOGIC R\u00c0NG BU\u1ed8C) \u2500\u2500
        const basePrice = parseFloat(document.getElementById('tour-price').value) || 0;
        const durationDays = parseInt(document.getElementById('tour-duration').value) || 0;
        const maxParticipants = parseInt(document.getElementById('tour-max-parts').value) || 0;
        const groupSizeMin = parseInt(document.getElementById('tour-group-min').value) || 0;
        const groupSizeMax = parseInt(document.getElementById('tour-group-max').value) || 0;

        if (basePrice < 0) {
            showToast('Gi\u00e1 c\u01a1 b\u1ea3n kh\u00f4ng \u0111\u01b0\u1ee3c \u00e2m!', 'error');
            document.getElementById('tour-price').focus();
            return;
        }
        if (durationDays < 1) {
            showToast('Th\u1eddi l\u01b0\u1ee3ng tour ph\u1ea3i t\u1ed1i thi\u1ec3u l\u00e0 1 ng\u00e0y!', 'error');
            document.getElementById('tour-duration').focus();
            return;
        }
        if (maxParticipants < 1) {
            showToast('S\u1ed1 kh\u00e1ch t\u1ed1i \u0111a ph\u1ea3i l\u1edbn h\u01a1n ho\u1eb7c b\u1eb1ng 1!', 'error');
            document.getElementById('tour-max-parts').focus();
            return;
        }
        if (groupSizeMin < 1) {
            showToast('S\u1ed1 ng\u01b0\u1eddi t\u1ed1i thi\u1ec3u m\u1ed7i \u0111o\u00e0n ph\u1ea3i l\u1edbn h\u01a1n ho\u1eb7c b\u1eb1ng 1!', 'error');
            document.getElementById('tour-group-min').focus();
            return;
        }
        if (groupSizeMax < 1) {
            showToast('S\u1ed1 ng\u01b0\u1eddi t\u1ed1i \u0111a m\u1ed7i \u0111o\u00e0n ph\u1ea3i l\u1edbn h\u01a1n ho\u1eb7c b\u1eb1ng 1!', 'error');
            document.getElementById('tour-group-max').focus();
            return;
        }
        if (groupSizeMin > groupSizeMax) {
            showToast('S\u1ed1 ng\u01b0\u1eddi t\u1ed1i thi\u1ec3u m\u1ed7i \u0111o\u00e0n kh\u00f4ng \u0111\u01b0\u1ee3c v\u01b0\u1ee3t qu\u00e1 s\u1ed1 ng\u01b0\u1eddi t\u1ed1i \u0111a!', 'error');
            document.getElementById('tour-group-min').focus();
            return;
        }
        if (groupSizeMax > maxParticipants) {
            showToast(`S\u1ed1 ng\u01b0\u1eddi t\u1ed1i \u0111a m\u1ed7i \u0111o\u00e0n (${groupSizeMax}) kh\u00f4ng \u0111\u01b0\u1ee3c v\u01b0\u1ee3t qu\u00e1 s\u1ed1 kh\u00e1ch t\u1ed1i \u0111a c\u1ee7a tour (${maxParticipants})!`, 'error');
            document.getElementById('tour-group-max').focus();
            return;
        }

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
            if (!res.ok) throw new Error('Kh\u00f4ng th\u1ec3 l\u01b0u th\u00f4ng tin tour');
            return res.json();
        })
        .then(data => {
            if (data.status === 'success') {
                showToast(data.message || 'L\u01b0u th\u00e0nh c\u00f4ng!');
                closeModal();
                fetchTours();
            } else {
                showToast(data.message || 'L\u1ed7i khi l\u01b0u th\u00f4ng tin', 'error');
            }
        })
        .catch(err => {
            console.error(err);
            showToast(err.message || 'L\u1ed7i k\u1ebft n\u1ed1i m\u00e1y ch\u1ee7', 'error');
        });
    });

    /* \u2500\u2500 Delete Confirmation Modal Actions \u2500\u2500 */
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

    /* \u2500\u2500 Filter & Search Listeners \u2500\u2500 */
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

    /* \u2500\u2500 Custom Toast Notification Helper \u2500\u2500 */
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
