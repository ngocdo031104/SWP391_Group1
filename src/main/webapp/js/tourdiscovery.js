document.addEventListener('DOMContentLoaded', () => {
    // Initialize Lucide Icons
    lucide.createIcons();

    // Constant for Currency Rate
    const EXCHANGE_RATE = 25000; // 1 USD = 25,000 VND

    /* ==========================================================================
       DOM ELEMENTS SELECTORS
       ========================================================================== */
    const exploreGrid = document.getElementById('explore-grid');
    const recToursGrid = document.getElementById('rec-tours-grid');
    const matchingCountEl = document.getElementById('matching-count');
    const priceSlider = document.getElementById('filter-price');
    const priceLimitVal = document.getElementById('price-limit-val');
    const sortSelect = document.getElementById('sort-select');
    const clearFiltersBtn = document.getElementById('clear-filters-btn');
    const difficultyChips = document.querySelectorAll('.difficulty-chip');
    const categoryCheckboxes = document.querySelectorAll('input[name="category"]');
    const ratingCheckboxes = document.querySelectorAll('input[name="rating"]');
    const durationRadios = document.querySelectorAll('input[name="duration"]');
    const tourTypeRadios = document.querySelectorAll('input[name="tour-type"]');
    const departureCheckboxes = document.querySelectorAll('input[name="departure"]');
    const seatsRadios = document.querySelectorAll('input[name="seats"]');
    const searchForm = document.getElementById('explore-search-form');
    
    // Map Selectors
    const mapPinsContainer = document.getElementById('map-pins-container');
    const mapPopup = document.getElementById('map-popup');
    const exploreMapPane = document.getElementById('explore-map-pane');

    // Mobile Selectors
    const filterSidebar = document.getElementById('filter-sidebar');
    const mobileFilterTrigger = document.getElementById('mobile-filter-trigger');
    const mobileMapToggle = document.getElementById('mobile-map-toggle');
    const closeFiltersBtn = document.getElementById('close-filters-btn');
    const applyFiltersBtn = document.getElementById('apply-filters-btn');

    // Currency selector
    const currSelect = document.getElementById('curr-select');

    // Mobile navigation controls & elements (declared at top to prevent Temporal Dead Zone / ReferenceError issues)
    const mapToggleBtn = document.getElementById('map-toggle-btn');
    const mapCloseBtn = document.getElementById('map-close-btn');

    /* ==========================================================================
       DỮ LIỆU TOUR VIỆT NAM (100% BẢN ĐỊA HÓA - SỬ DỤNG ẢNH NỘI BỘ ĐÃ GENERATE)
       ========================================================================== */
    const VIETNAM_IMAGES = {
        "Đà Nẵng": "assets/images/tour_danang.png",
        "Phú Quốc": "assets/images/tour_phuquoc.png",
        "Hạ Long": "assets/images/tour_halong.png",
        "Hội An": "assets/images/tour_hoian.png",
        "Đà Lạt": "assets/images/tour_dalat.png",
        "Sa Pa": "assets/images/tour_sapa.png",
        "Nha Trang": "assets/images/tour_nhatrang.png",
        "Hà Giang": "assets/images/tour_hagiang.png"
    };

    const toursData = window.toursData || [
        {
            id: 1,
            title: "Tour Thượng Lưu Bà Nà Hills, Cầu Vàng & Ngũ Hành Sơn 3 Ngày",
            description: "Trải nghiệm cáp treo đạt nhiều kỷ lục thế giới, check-in Cầu Vàng huyền thoại giữa mây ngàn, khám phá làng Pháp cổ kính và lưu trú tại resort 5 sao bên bờ biển Mỹ Khê tuyệt mỹ.",
            image: "assets/images/tour_danang.png",
            departure: "Đà Nẵng",
            tourType: "group",
            rating: 4.9,
            reviews: 142,
            priceVND: 4800000,
            duration: 3,
            difficulty: "easy",
            category: "luxury",
            seatsLeft: 8,
            seatsTotal: 20,
            guide: { name: "Nguyễn Văn Hùng", avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=80&q=80" },
            lat: "48%",
            lng: "50%",
            location: "Đà Nẵng"
        },
        {
            id: 2,
            title: "Thiên Đường Đảo Ngọc Phú Quốc - Lặn San Hô & Ngắm Hoàng Hôn 4 Ngày",
            description: "Khám phá các đảo hoang sơ phía Nam, lên du thuyền câu cá lặn ngắm san hô tại hòn Móng Tay, thưởng thức tiệc hải sản tươi sống và ngắm hoàng hôn Sunset Sanato rực rỡ.",
            image: "assets/images/tour_phuquoc.png",
            departure: "TP. Hồ Chí Minh",
            tourType: "group",
            rating: 5.0,
            reviews: 98,
            priceVND: 6200000,
            duration: 4,
            difficulty: "easy",
            category: "beach",
            seatsLeft: 12,
            seatsTotal: 20,
            guide: { name: "Trần Minh Tâm", avatar: "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=80&q=80" },
            lat: "88%",
            lng: "25%",
            location: "Phú Quốc"
        },
        {
            id: 3,
            title: "Nghỉ Dưỡng Du Thuyền 5 Sao Vịnh Hạ Long & Chèo Thuyền Kayak 2 Ngày",
            description: "Thư giãn trên du thuyền sang trọng giữa kỳ quan thiên nhiên thế giới. Trải nghiệm chèo kayak qua Hang Luồn kỳ thú, chinh phục đỉnh đảo Ti Tốp và thưởng thức ẩm thực Á-Âu thượng hạng.",
            image: "assets/images/tour_halong.png",
            departure: "Hà Nội",
            tourType: "group",
            rating: 4.8,
            reviews: 215,
            priceVND: 3900000,
            duration: 2,
            difficulty: "easy",
            category: "luxury",
            seatsLeft: 4,
            seatsTotal: 10,
            guide: { name: "Lê Hoàng Nam", avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=80&q=80" },
            lat: "15%",
            lng: "48%",
            location: "Hạ Long"
        },
        {
            id: 4,
            title: "Hành Trình Phố Cổ Hội An Hoài Cổ & Thả Đèn Hoa Đăng Sông Hoài 2 Ngày",
            description: "Tản bộ qua những bức tường vàng phủ rêu phong hàng trăm năm tuổi, tham gia làm đèn lồng truyền thống nghệ thuật, thưởng thức Cao Lầu đặc sản và đi thuyền gỗ thả đèn hoa đăng lung linh.",
            image: "assets/images/tour_hoian.png",
            departure: "Đà Nẵng",
            tourType: "private",
            rating: 4.7,
            reviews: 86,
            priceVND: 1850000,
            duration: 2,
            difficulty: "easy",
            category: "cultural",
            seatsLeft: 15,
            seatsTotal: 30,
            guide: { name: "Phạm Thùy Linh", avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=80&q=80" },
            lat: "52%",
            lng: "54%",
            location: "Hội An"
        },
        {
            id: 5,
            title: "Săn Mây Đà Lạt, Chinh Phục Langbiang & Cắm Trại Rừng Thông 3 Ngày",
            description: "Săn mây bình minh tuyệt diệu tại Đồi Chè Cầu Đất, trekking chinh phục đỉnh núi Langbiang huyền thoại, cắm trại rừng thông thơ mộng và thưởng thức tiệc BBQ ấm cúng trong sương mờ.",
            image: "assets/images/tour_dalat.png",
            departure: "TP. Hồ Chí Minh",
            tourType: "group",
            rating: 4.9,
            reviews: 110,
            priceVND: 2900000,
            duration: 3,
            difficulty: "medium",
            category: "hiking",
            seatsLeft: 6,
            seatsTotal: 8,
            guide: { name: "Lâm Quốc Bảo", avatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=80&q=80" },
            lat: "72%",
            lng: "46%",
            location: "Đà Lạt"
        },
        {
            id: 6,
            title: "Trekking Ruộng Bậc Thang Sa Pa & Chinh Phục Fansipan Kỳ Vĩ 3 Ngày",
            description: "Hành trình trekking ngắm ruộng bậc thang thung lũng Mường Hoa kỳ vĩ, chinh phục đỉnh Fansipan - Nóc nhà Đông Dương bằng cáp treo hiện đại và trải nghiệm văn hóa bản địa độc đáo.",
            image: "assets/images/tour_sapa.png",
            departure: "Hà Nội",
            tourType: "group",
            rating: 4.9,
            reviews: 154,
            priceVND: 3500000,
            duration: 3,
            difficulty: "hard",
            category: "hiking",
            seatsLeft: 3,
            seatsTotal: 8,
            guide: { name: "Vàng A Tủa", avatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=120&q=80" },
            lat: "10%",
            lng: "22%",
            location: "Sa Pa"
        },
        {
            id: 7,
            title: "Khám Phá Vịnh Nha Trang - Đi Bộ Dưới Đại Dương & VinWonders 4 Ngày",
            description: "Trải nghiệm đi bộ dưới đáy biển ngằn rạn san hô rực rỡ tại Hòn Mun, đi ca-nô cao tốc ngắm vịnh và thỏa sức vui chơi giải trí tại thiên đường VinWonders đẳng cấp thế giới.",
            image: "assets/images/tour_nhatrang.png",
            departure: "TP. Hồ Chí Minh",
            tourType: "group",
            rating: 4.6,
            reviews: 73,
            priceVND: 4200000,
            duration: 4,
            difficulty: "medium",
            category: "beach",
            seatsLeft: 18,
            seatsTotal: 25,
            guide: { name: "Nguyễn Minh Triết", avatar: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=120&q=80" },
            lat: "64%",
            lng: "50%",
            location: "Nha Trang"
        },
        {
            id: 8,
            title: "Hành Trình Kỳ Vĩ Hà Giang - Mã Pí Lèng & Đi Thuyền Sông Nho Quế 4 Ngày",
            description: "Chinh phục đèo Mã Pí Lèng - một trong tứ đại đỉnh đèo Việt Nam, ngắm thung lũng hoa tam giác mạch rừng đá Đồng Văn và đi thuyền trên dòng sông Nho Quế xanh như ngọc bích.",
            image: "assets/images/tour_hagiang.png",
            departure: "Hà Nội",
            tourType: "private",
            rating: 5.0,
            reviews: 120,
            priceVND: 3200000,
            duration: 4,
            difficulty: "hard",
            category: "adventure",
            seatsLeft: 5,
            seatsTotal: 10,
            guide: { name: "Sùng Mí Phìn", avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&q=80" },
            lat: "5%",
            lng: "34%",
            location: "Hà Giang"
        }
    ];

    // Current State variables
    let filteredTours = [...toursData];
    let currentPage = 1;
    const cardsPerPage = 6; // Increased to show more cards comfortably
    let selectedDifficulty = '';
    let currentCurrency = 'usd'; // Default on load

    /* ==========================================================================
       CURRENCY & FORMATTING UTIL FUNCTIONS
       ========================================================================== */
    function getActiveCurrency() {
        return currSelect ? currSelect.value : 'usd';
    }

    function formatPrice(vndAmount) {
        const currency = getActiveCurrency();
        if (currency === 'vnd') {
            return `${vndAmount.toLocaleString('vi-VN')} ₫`;
        } else {
            const usdAmount = Math.round(vndAmount / EXCHANGE_RATE);
            return `$${usdAmount.toLocaleString('en-US')}`;
        }
    }

    function updatePriceSliderRange() {
        const currency = getActiveCurrency();
        const prevPercent = (priceSlider.value - priceSlider.min) / (priceSlider.max - priceSlider.min || 1);
        
        if (currency === 'vnd') {
            priceSlider.min = 1000000;
            priceSlider.max = 10000000;
            priceSlider.step = 500000;
            if (priceSlider.value < 1000000) {
                priceSlider.value = 10000000;
            } else {
                priceSlider.value = Math.round((priceSlider.min + prevPercent * (priceSlider.max - priceSlider.min)) / 500000) * 500000;
            }
            priceLimitVal.textContent = `Tối đa: ${formatPrice(parseInt(priceSlider.value))}`;
        } else {
            priceSlider.min = 40;
            priceSlider.max = 400;
            priceSlider.step = 10;
            if (priceSlider.value > 1000) {
                priceSlider.value = 400;
            } else {
                priceSlider.value = Math.round((priceSlider.min + prevPercent * (priceSlider.max - priceSlider.min)) / 10) * 10;
            }
            priceLimitVal.textContent = `Tối đa: ${formatPrice(parseInt(priceSlider.value) * EXCHANGE_RATE)}`;
        }
    }

    /* ==========================================================================
       FILTERING & SORTING LOGIC
       ========================================================================== */
    function filterAndSortTours() {
        const rawSliderVal = parseInt(priceSlider.value);
        const currency = getActiveCurrency();
        
        // Convert active slider budget to VND equivalent for calculations
        const maxPriceVND = currency === 'vnd' ? rawSliderVal : rawSliderVal * EXCHANGE_RATE;

        const searchDest = document.getElementById('search-destination').value.toLowerCase().trim();

        const selectedCategories = Array.from(categoryCheckboxes)
            .filter(cb => cb.checked)
            .map(cb => cb.value);

        const selectedRatings = Array.from(ratingCheckboxes)
            .filter(cb => cb.checked)
            .map(cb => parseFloat(cb.value));

        const selectedDepartures = Array.from(departureCheckboxes)
            .filter(cb => cb.checked)
            .map(cb => cb.value);

        let activeDuration = 'all';
        durationRadios.forEach(radio => {
            if (radio.checked) activeDuration = radio.value;
        });

        let activeTourType = 'all';
        tourTypeRadios.forEach(radio => {
            if (radio.checked) activeTourType = radio.value;
        });

        let activeSeats = 'all';
        seatsRadios.forEach(radio => {
            if (radio.checked) activeSeats = radio.value;
        });

        filteredTours = toursData.filter(tour => {
            if (tour.priceVND > maxPriceVND) return false;

            if (searchDest && !tour.location.toLowerCase().includes(searchDest) && !tour.title.toLowerCase().includes(searchDest)) {
                return false;
            }

            // Category Filter
            if (selectedCategories.length > 0 && !selectedCategories.includes(tour.category)) {
                return false;
            }

            // Difficulty Filter
            if (selectedDifficulty && tour.difficulty !== selectedDifficulty) {
                return false;
            }

            // Rating Filter
            if (selectedRatings.length > 0) {
                const passesRating = selectedRatings.some(minRate => tour.rating >= minRate);
                if (!passesRating) return false;
            }

            // Duration Filter
            if (activeDuration !== 'all') {
                if (activeDuration === '1-3' && (tour.duration < 1 || tour.duration > 3)) return false;
                if (activeDuration === '4-6' && (tour.duration < 4 || tour.duration > 6)) return false;
                if (activeDuration === '7+' && tour.duration < 7) return false;
            }

            if (activeTourType !== 'all' && tour.tourType !== activeTourType) return false;

            if (selectedDepartures.length > 0 && !selectedDepartures.includes(tour.departure)) return false;

            if (activeSeats === 'available' && tour.seatsLeft <= 5) return false;
            if (activeSeats === 'limited' && tour.seatsLeft > 5) return false;

            return true;
        });

        // Apply Sorting
        const sortBy = sortSelect.value;
        if (sortBy === 'price-asc') {
            filteredTours.sort((a, b) => a.priceVND - b.priceVND);
        } else if (sortBy === 'price-desc') {
            filteredTours.sort((a, b) => b.priceVND - a.priceVND);
        } else if (sortBy === 'rating') {
            filteredTours.sort((a, b) => b.rating - a.rating);
        } else {
            // "Recommended" Default: sort by reviews/popularity
            filteredTours.sort((a, b) => b.reviews - a.reviews);
        }

        currentPage = 1; // Reset to page 1
        matchingCountEl.textContent = filteredTours.length;

        renderGrid();
        renderMapPins();
        renderPagination();
    }

    /* ==========================================================================
       RENDER TOUR CARDS GRID
       ========================================================================== */
    function renderGrid() {
        exploreGrid.innerHTML = '';
        
        if (filteredTours.length === 0) {
            exploreGrid.innerHTML = `
                <div style="grid-column: span 12; text-align: center; padding: 4rem 0; color: var(--slate-400);">
                    <i data-lucide="compass" style="width: 3.5rem; height: 3.5rem; margin-bottom: 1rem; color: var(--primary); opacity: 0.8;"></i>
                    <p style="font-size: 1.1rem; font-weight: 600; color: var(--slate-700);">Không tìm thấy tour phù hợp với bộ lọc hiện tại.</p>
                    <button class="btn btn-secondary btn-sm" id="reset-no-results-btn" style="margin-top: 1.25rem; font-size: 0.875rem;">Đặt lại bộ lọc</button>
                </div>
            `;
            // Attach reset handler to dynamic button
            document.getElementById('reset-no-results-btn').addEventListener('click', clearAllFilters);
            lucide.createIcons();
            return;
        }

        // Calculate slice range for pagination
        const startIndex = (currentPage - 1) * cardsPerPage;
        const endIndex = startIndex + cardsPerPage;
        const pageCards = filteredTours.slice(startIndex, endIndex);

        pageCards.forEach(tour => {
            const card = document.createElement('div');
            card.className = 'tour-card';
            card.setAttribute('data-id', tour.id);

            const isSeatsCritical = tour.seatsLeft <= 5;
            const progressPercent = ((tour.seatsTotal - tour.seatsLeft) / tour.seatsTotal) * 100;

            // Map standard difficulty string to Vietnamese
            let difficultyText = "Dễ dàng";
            let difficultyClass = "easy";
            if (tour.difficulty === "medium") {
                difficultyText = "Trung bình";
                difficultyClass = "medium";
            } else if (tour.difficulty === "hard") {
                difficultyText = "Thử thách";
                difficultyClass = "hard";
            }

            let priceText = formatPrice(tour.priceVND);
            let priceSpan = `<span>₫</span>`;
            if (priceText.endsWith(' ₫')) {
                priceText = priceText.replace(' ₫', '');
            } else if (priceText.startsWith('$')) {
                priceText = priceText.replace('$', '');
                priceSpan = `<span>$</span>`;
            }

            card.innerHTML = `
                <div class="tour-img-wrapper">
                    <img src="${tour.image}" alt="${tour.title}" class="tour-img" loading="lazy">
                    <div class="tour-badge">
                        <span class="badge badge-featured">${difficultyText}</span>
                    </div>
                    <button class="btn-wishlist" aria-label="Thêm vào yêu thích">
                        <i data-lucide="heart"></i>
                    </button>
                </div>
                <div class="tour-details">
                    <div class="tour-meta">
                        <div class="tour-rating">
                            <i data-lucide="star"></i>
                            <span>${tour.rating} (${tour.reviews} đánh giá)</span>
                        </div>
                        <div class="tour-duration">
                            <i data-lucide="clock"></i>
                            <span>${tour.duration} Ngày</span>
                        </div>
                    </div>
                    <h3>${tour.title}</h3>
                    <div class="tour-seats-progress">
                        <div class="seats-info">
                            <span>Chỗ trống</span>
                            <span class="seats-left ${isSeatsCritical ? 'danger' : ''}">
                                ${tour.seatsLeft > 0 ? "Còn " + tour.seatsLeft + " chỗ!" : "Hết chỗ!"}
                            </span>
                        </div>
                        <div class="progress-bar-bg">
                            <div class="progress-bar-fill ${isSeatsCritical ? 'danger' : ''}" style="width: ${progressPercent}%;"></div>
                        </div>
                    </div>
                    <div class="tour-footer">
                        <div class="tour-price">
                            <span class="price-label">Giá mỗi khách</span>
                            <span class="price-val">${priceText} ${priceSpan}</span>
                        </div>
                        <button class="btn btn-primary btn-sm btn-cta-detail" onclick="window.location.href='detail?id=${tour.id}'">Xem Chi Tiết</button>
                    </div>
                </div>
            `;

            // Hover interactions to sync with Map Pins
            card.addEventListener('mouseenter', () => highlightPin(tour.id));
            card.addEventListener('mouseleave', () => unhighlightPins());

            // Wishlist Heart Click
            const wishlistBtn = card.querySelector('.btn-wishlist');
            wishlistBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                wishlistBtn.classList.toggle('active');
                const heartIcon = wishlistBtn.querySelector('svg');
                if (wishlistBtn.classList.contains('active')) {
                    heartIcon.setAttribute('fill', 'currentColor');
                } else {
                    heartIcon.setAttribute('fill', 'none');
                }
            });

            exploreGrid.appendChild(card);
        });

        lucide.createIcons();
    }

    /* ==========================================================================
       RENDER INTERACTIVE MAP PINS
       ========================================================================== */
    function renderMapPins() {
        if (!mapPinsContainer) return;
        mapPinsContainer.innerHTML = '';
        if (mapPopup) mapPopup.classList.remove('active'); // Hide popups

        filteredTours.forEach(tour => {
            const pin = document.createElement('div');
            pin.className = 'map-pin';
            pin.setAttribute('data-id', tour.id);
            pin.style.top = tour.lat;
            pin.style.left = tour.lng;

            pin.innerHTML = `
                <div class="map-pin-marker">
                    <i data-lucide="map-pin" style="width:0.8rem; height:0.8rem;"></i>
                    ${formatPrice(tour.priceVND)}
                </div>
            `;

            // Click Pin to show Popup Card on Map
            pin.addEventListener('click', (e) => {
                e.stopPropagation();
                showMapPopup(tour);
                highlightPin(tour.id);
            });

            mapPinsContainer.appendChild(pin);
        });

        lucide.createIcons();
    }

    function showMapPopup(tour) {
        if (!mapPopup) return;
        mapPopup.innerHTML = `
            <span class="map-popup-close" id="popup-close-btn">&times;</span>
            <img src="${tour.image}" alt="${tour.title}" class="map-popup-img">
            <div class="map-popup-details">
                <div class="map-popup-title">${tour.title}</div>
                <div class="map-popup-meta">
                    <span>★ ${tour.rating}</span>
                    <span class="map-popup-price">${formatPrice(tour.priceVND)}</span>
                </div>
            </div>
        `;
        
        mapPopup.classList.add('active');

        document.getElementById('popup-close-btn').addEventListener('click', (e) => {
            e.stopPropagation();
            mapPopup.classList.remove('active');
            unhighlightPins();
        });
    }

    function highlightPin(tourId) {
        if (!mapPinsContainer) return;
        unhighlightPins();
        const pins = mapPinsContainer.querySelectorAll('.map-pin');
        pins.forEach(pin => {
            if (parseInt(pin.getAttribute('data-id')) === tourId) {
                pin.classList.add('active');
            }
        });

        // Also add active card highlight class in list if visible
        const cards = exploreGrid.querySelectorAll('.tour-card');
        cards.forEach(card => {
            if (parseInt(card.getAttribute('data-id')) === tourId) {
                card.classList.add('highlight-card');
            }
        });
    }

    function unhighlightPins() {
        if (!mapPinsContainer) return;
        const pins = mapPinsContainer.querySelectorAll('.map-pin');
        pins.forEach(pin => pin.classList.remove('active'));

        const cards = exploreGrid.querySelectorAll('.tour-card');
        cards.forEach(card => card.classList.remove('highlight-card'));
    }

    // Click map background to close popups
    const mapSvg = document.querySelector('.vector-map-bg');
    if (mapSvg) {
        mapSvg.addEventListener('click', () => {
            if (mapPopup) mapPopup.classList.remove('active');
            unhighlightPins();
        });
    }

    /* ==========================================================================
       PAGINATION CONTROLS
       ========================================================================== */
    const prevBtn = document.getElementById('pag-prev');
    const nextBtn = document.getElementById('pag-next');
    const pagNumbersEl = document.getElementById('pag-numbers');

    function renderPagination() {
        if (!pagNumbersEl) return;
        pagNumbersEl.innerHTML = '';
        const totalPages = Math.ceil(filteredTours.length / cardsPerPage);

        if (totalPages <= 1) {
            if (prevBtn) prevBtn.disabled = true;
            if (nextBtn) nextBtn.disabled = true;
            return;
        }

        if (prevBtn) prevBtn.disabled = currentPage === 1;
        if (nextBtn) nextBtn.disabled = currentPage === totalPages;

        for (let i = 1; i <= totalPages; i++) {
            const pageNumBtn = document.createElement('button');
            pageNumBtn.className = `pagination-number-btn ${i === currentPage ? 'active' : ''}`;
            pageNumBtn.textContent = i;

            pageNumBtn.addEventListener('click', () => {
                currentPage = i;
                renderGrid();
                renderPagination();
                exploreGrid.scrollIntoView({ behavior: 'smooth' });
            });

            pagNumbersEl.appendChild(pageNumBtn);
        }
    }

    if (prevBtn) {
        prevBtn.addEventListener('click', () => {
            if (currentPage > 1) {
                currentPage--;
                renderGrid();
                renderPagination();
                exploreGrid.scrollIntoView({ behavior: 'smooth' });
            }
        });
    }

    if (nextBtn) {
        nextBtn.addEventListener('click', () => {
            const totalPages = Math.ceil(filteredTours.length / cardsPerPage);
            if (currentPage < totalPages) {
                currentPage++;
                renderGrid();
                renderPagination();
                exploreGrid.scrollIntoView({ behavior: 'smooth' });
            }
        });
    }

    /* ==========================================================================
       SIDEBAR INTERACTION HANDLERS
       ========================================================================== */
    // Budget range live slide
    if (priceSlider) {
        priceSlider.addEventListener('input', (e) => {
            const value = parseInt(e.target.value);
            const displayVal = getActiveCurrency() === 'vnd' ? value : value * EXCHANGE_RATE;
            priceLimitVal.textContent = `Tối đa: ${formatPrice(displayVal)}`;
            filterAndSortTours();
        });
    }

    // Difficulty level chips toggle
    difficultyChips.forEach(chip => {
        chip.addEventListener('click', () => {
            if (chip.classList.contains('active')) {
                chip.classList.remove('active');
                selectedDifficulty = '';
            } else {
                difficultyChips.forEach(c => c.classList.remove('active'));
                chip.classList.add('active');
                selectedDifficulty = chip.getAttribute('data-val');
            }
            filterAndSortTours();
        });
    });

    // Checkboxes and radio events trigger filtering
    categoryCheckboxes.forEach(cb => cb.addEventListener('change', filterAndSortTours));
    ratingCheckboxes.forEach(cb => cb.addEventListener('change', filterAndSortTours));
    durationRadios.forEach(radio => radio.addEventListener('change', filterAndSortTours));
    tourTypeRadios.forEach(radio => radio.addEventListener('change', filterAndSortTours));
    departureCheckboxes.forEach(cb => cb.addEventListener('change', filterAndSortTours));
    seatsRadios.forEach(radio => radio.addEventListener('change', filterAndSortTours));
    if (sortSelect) sortSelect.addEventListener('change', filterAndSortTours);

    // Search bar submit
    if (searchForm) {
        searchForm.addEventListener('submit', (e) => {
            e.preventDefault();
            filterAndSortTours();
        });
    }

    // Currency Switcher
    if (currSelect) {
        currSelect.addEventListener('change', () => {
            const prevCurrency = currentCurrency;
            currentCurrency = currSelect.value;
            
            // Adjust slider ranges to keep filters synchronized
            updatePriceSliderRange();
            
            // Re-run filter and render
            filterAndSortTours();
            renderRecommendations();
        });
    }

    // Clear All Filters
    function clearAllFilters() {
        if (priceSlider) {
            priceSlider.value = getActiveCurrency() === 'vnd' ? 10000000 : 400;
            priceLimitVal.textContent = `Tối đa: ${formatPrice(getActiveCurrency() === 'vnd' ? 10000000 : 400 * EXCHANGE_RATE)}`;
        }
        const searchDestinationEl = document.getElementById('search-destination');
        if (searchDestinationEl) searchDestinationEl.value = '';
        selectedDifficulty = '';
        
        difficultyChips.forEach(c => c.classList.remove('active'));
        categoryCheckboxes.forEach(cb => cb.checked = false);
        ratingCheckboxes.forEach(cb => cb.checked = false);
        departureCheckboxes.forEach(cb => cb.checked = false);
        durationRadios.forEach(radio => {
            if (radio.value === 'all') radio.checked = true;
            else radio.checked = false;
        });
        tourTypeRadios.forEach(radio => {
            if (radio.value === 'all') radio.checked = true;
            else radio.checked = false;
        });
        seatsRadios.forEach(radio => {
            if (radio.value === 'all') radio.checked = true;
            else radio.checked = false;
        });

        if (sortSelect) sortSelect.value = 'recommended';
        filterAndSortTours();
    }

    if (clearFiltersBtn) {
        clearFiltersBtn.addEventListener('click', clearAllFilters);
    }

    /* ==========================================================================
       MOBILE LAYOUT & MAP COLLAPSIBLE CONTROLS
       ========================================================================== */
    // Slide filter sidebar in/out
    if (mobileFilterTrigger && filterSidebar) {
        mobileFilterTrigger.addEventListener('click', () => {
            filterSidebar.classList.add('active');
        });
    }

    if (closeFiltersBtn && filterSidebar) {
        closeFiltersBtn.addEventListener('click', () => {
            filterSidebar.classList.remove('active');
        });
    }

    if (applyFiltersBtn && filterSidebar) {
        applyFiltersBtn.addEventListener('click', () => {
            filterSidebar.classList.remove('active');
        });
    }

    function updateMapToggleLabel(isOpen) {
        if (!mapToggleBtn) return;
        mapToggleBtn.innerHTML = isOpen
            ? `<i data-lucide="x"></i><span>Đóng bản đồ</span>`
            : `<i data-lucide="map"></i><span>Xem bản đồ</span>`;
        lucide.createIcons();
    }

    function setMapOpen(isOpen) {
        if (!exploreMapPane) return;
        exploreMapPane.classList.toggle('collapsed', !isOpen);
        updateMapToggleLabel(isOpen);
    }

    // Toggle Mobile Map Pane
    if (mobileMapToggle && exploreMapPane) {
        mobileMapToggle.addEventListener('click', () => {
            const willOpen = exploreMapPane.classList.contains('collapsed');
            setMapOpen(willOpen);
            if (willOpen) {
                exploreMapPane.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        });
    }

    // (mapToggleBtn and mapCloseBtn are declared at the top level of DOMContentLoaded)

    if (mapToggleBtn && exploreMapPane) {
        mapToggleBtn.addEventListener('click', () => {
            setMapOpen(exploreMapPane.classList.contains('collapsed'));
        });
    }

    if (mapCloseBtn && exploreMapPane) {
        mapCloseBtn.addEventListener('click', () => setMapOpen(false));
    }



    /* ==========================================================================
       RECOMMENDATION SECTION POPULATING (Tour dành cho bạn)
       ========================================================================== */
    function renderRecommendations() {
        if (!recToursGrid) return;
        recToursGrid.innerHTML = '';
        
        // Pick 4 premium tours for recommendation safely
        const recs = [];
        [1, 2, 4, 7].forEach(idx => {
            if (toursData[idx]) recs.push(toursData[idx]);
        });
        if (recs.length < 4) {
            for (let i = 0; i < toursData.length && recs.length < 4; i++) {
                if (!recs.includes(toursData[i])) {
                    recs.push(toursData[i]);
                }
            }
        }

        recs.forEach(tour => {
            const card = document.createElement('div');
            card.className = 'rec-tour-card';
            
            card.innerHTML = `
                <div class="rec-tour-img-wrapper">
                    <img src="${tour.image}" alt="${tour.title}" class="rec-tour-img">
                    <div class="rec-tour-badge"><span class="badge badge-featured">Gợi ý</span></div>
                </div>
                <div class="rec-tour-details">
                    <div class="rec-tour-location">
                        <i data-lucide="map-pin"></i>
                        <span>${tour.location}</span>
                    </div>
                    <h3>${tour.title}</h3>
                    <div class="rec-tour-footer">
                        <div class="rec-tour-price">
                            <span class="price-label">Chỉ từ</span>
                            <span class="price-val">${formatPrice(tour.priceVND)}</span>
                        </div>
                        <button class="btn btn-primary btn-sm" onclick="window.location.href='detail?id=${tour.id}'">Xem Ngay</button>
                    </div>
                </div>
            `;
            recToursGrid.appendChild(card);
        });

        lucide.createIcons();
    }

    /* ==========================================================================
       INITIAL RUN
       ========================================================================== */
    // Parse URL params for query preset (e.g. search from homepage redirection)
    const urlParams = new URLSearchParams(window.location.search);
    const destParam = urlParams.get('dest');
    const searchDestInput = document.getElementById('search-destination');
    if (destParam && searchDestInput) {
        searchDestInput.value = destParam;
    }

    // Default search date to tomorrow
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    const searchDateInput = document.getElementById('search-date');
    if (searchDateInput) {
        searchDateInput.value = tomorrow.toISOString().split('T')[0];
    }

    // Setup initial ranges based on currency dropdown
    updatePriceSliderRange();

    // Initial render
    filterAndSortTours();
    renderRecommendations();
});
