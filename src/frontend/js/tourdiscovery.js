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
    const avatarBtn = document.getElementById('user-avatar-btn');
    const dropdownMenu = document.getElementById('user-dropdown-menu');
    const mobileMenuToggle = document.getElementById('mobile-menu-toggle');
    const navMenu = document.getElementById('nav-menu');

    /* ==========================================================================
       D\u1eee LI\u1ec6U TOUR VI\u1ec6T NAM (100% B\u1ea2N \u0110\u1ecaA H\u00d3A - S\u1eec D\u1ee4NG \u1ea2NH N\u1ed8I B\u1ed8 \u0110\u00c3 GENERATE)
       ========================================================================== */
    const VIETNAM_IMAGES = {
        "\u0110\u00e0 N\u1eb5ng": "assets/images/tour_danang.png",
        "Ph\u00fa Qu\u1ed1c": "assets/images/tour_phuquoc.png",
        "H\u1ea1 Long": "assets/images/tour_halong.png",
        "H\u1ed9i An": "assets/images/tour_hoian.png",
        "\u0110\u00e0 L\u1ea1t": "assets/images/tour_dalat.png",
        "Sa Pa": "assets/images/tour_sapa.png",
        "Nha Trang": "assets/images/tour_nhatrang.png",
        "H\u00e0 Giang": "assets/images/tour_hagiang.png"
    };

    const toursData = window.toursData || [
        {
            id: 1,
            title: "Tour Th\u01b0\u1ee3ng L\u01b0u B\u00e0 N\u00e0 Hills, C\u1ea7u V\u00e0ng & Ng\u0169 H\u00e0nh S\u01a1n 3 Ng\u00e0y",
            description: "Tr\u1ea3i nghi\u1ec7m c\u00e1p treo \u0111\u1ea1t nhi\u1ec1u k\u1ef7 l\u1ee5c th\u1ebf gi\u1edbi, check-in C\u1ea7u V\u00e0ng huy\u1ec1n tho\u1ea1i gi\u1eefa m\u00e2y ng\u00e0n, kh\u00e1m ph\u00e1 l\u00e0ng Ph\u00e1p c\u1ed5 k\u00ednh v\u00e0 l\u01b0u tr\u00fa t\u1ea1i resort 5 sao b\u00ean b\u1edd bi\u1ec3n M\u1ef9 Kh\u00ea tuy\u1ec7t m\u1ef9.",
            image: "assets/images/tour_danang.png",
            departure: "\u0110\u00e0 N\u1eb5ng",
            tourType: "group",
            rating: 4.9,
            reviews: 142,
            priceVND: 4800000,
            duration: 3,
            difficulty: "easy",
            category: "luxury",
            seatsLeft: 8,
            seatsTotal: 20,
            guide: { name: "Nguy\u1ec5n V\u0103n H\u00f9ng", avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=80&q=80" },
            lat: "48%",
            lng: "50%",
            location: "\u0110\u00e0 N\u1eb5ng"
        },
        {
            id: 2,
            title: "Thi\u00ean \u0110\u01b0\u1eddng \u0110\u1ea3o Ng\u1ecdc Ph\u00fa Qu\u1ed1c - L\u1eb7n San H\u00f4 & Ng\u1eafm Ho\u00e0ng H\u00f4n 4 Ng\u00e0y",
            description: "Kh\u00e1m ph\u00e1 c\u00e1c \u0111\u1ea3o hoang s\u01a1 ph\u00eda Nam, l\u00ean du thuy\u1ec1n c\u00e2u c\u00e1 l\u1eb7n ng\u1eafm san h\u00f4 t\u1ea1i h\u00f2n M\u00f3ng Tay, th\u01b0\u1edfng th\u1ee9c ti\u1ec7c h\u1ea3i s\u1ea3n t\u01b0\u01a1i s\u1ed1ng v\u00e0 ng\u1eafm ho\u00e0ng h\u00f4n Sunset Sanato r\u1ef1c r\u1ee1.",
            image: "assets/images/tour_phuquoc.png",
            departure: "TP. H\u1ed3 Ch\u00ed Minh",
            tourType: "group",
            rating: 5.0,
            reviews: 98,
            priceVND: 6200000,
            duration: 4,
            difficulty: "easy",
            category: "beach",
            seatsLeft: 12,
            seatsTotal: 20,
            guide: { name: "Tr\u1ea7n Minh T\u00e2m", avatar: "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=80&q=80" },
            lat: "88%",
            lng: "25%",
            location: "Ph\u00fa Qu\u1ed1c"
        },
        {
            id: 3,
            title: "Ngh\u1ec9 D\u01b0\u1ee1ng Du Thuy\u1ec1n 5 Sao V\u1ecbnh H\u1ea1 Long & Ch\u00e8o Thuy\u1ec1n Kayak 2 Ng\u00e0y",
            description: "Th\u01b0 gi\u00e3n tr\u00ean du thuy\u1ec1n sang tr\u1ecdng gi\u1eefa k\u1ef3 quan thi\u00ean nhi\u00ean th\u1ebf gi\u1edbi. Tr\u1ea3i nghi\u1ec7m ch\u00e8o kayak qua Hang Lu\u1ed3n k\u1ef3 th\u00fa, chinh ph\u1ee5c \u0111\u1ec9nh \u0111\u1ea3o Ti T\u1ed1p v\u00e0 th\u01b0\u1edfng th\u1ee9c \u1ea9m th\u1ef1c \u00c1-\u00c2u th\u01b0\u1ee3ng h\u1ea1ng.",
            image: "assets/images/tour_halong.png",
            departure: "H\u00e0 N\u1ed9i",
            tourType: "group",
            rating: 4.8,
            reviews: 215,
            priceVND: 3900000,
            duration: 2,
            difficulty: "easy",
            category: "luxury",
            seatsLeft: 4,
            seatsTotal: 10,
            guide: { name: "L\u00ea Ho\u00e0ng Nam", avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=80&q=80" },
            lat: "15%",
            lng: "48%",
            location: "H\u1ea1 Long"
        },
        {
            id: 4,
            title: "H\u00e0nh Tr\u00ecnh Ph\u1ed1 C\u1ed5 H\u1ed9i An Ho\u00e0i C\u1ed5 & Th\u1ea3 \u0110\u00e8n Hoa \u0110\u0103ng S\u00f4ng Ho\u00e0i 2 Ng\u00e0y",
            description: "T\u1ea3n b\u1ed9 qua nh\u1eefng b\u1ee9c t\u01b0\u1eddng v\u00e0ng ph\u1ee7 r\u00eau phong h\u00e0ng tr\u0103m n\u0103m tu\u1ed5i, tham gia l\u00e0m \u0111\u00e8n l\u1ed3ng truy\u1ec1n th\u1ed1ng ngh\u1ec7 thu\u1eadt, th\u01b0\u1edfng th\u1ee9c Cao L\u1ea7u \u0111\u1eb7c s\u1ea3n v\u00e0 \u0111i thuy\u1ec1n g\u1ed7 th\u1ea3 \u0111\u00e8n hoa \u0111\u0103ng lung linh.",
            image: "assets/images/tour_hoian.png",
            departure: "\u0110\u00e0 N\u1eb5ng",
            tourType: "private",
            rating: 4.7,
            reviews: 86,
            priceVND: 1850000,
            duration: 2,
            difficulty: "easy",
            category: "cultural",
            seatsLeft: 15,
            seatsTotal: 30,
            guide: { name: "Ph\u1ea1m Th\u00f9y Linh", avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=80&q=80" },
            lat: "52%",
            lng: "54%",
            location: "H\u1ed9i An"
        },
        {
            id: 5,
            title: "S\u0103n M\u00e2y \u0110\u00e0 L\u1ea1t, Chinh Ph\u1ee5c Langbiang & C\u1eafm Tr\u1ea1i R\u1eebng Th\u00f4ng 3 Ng\u00e0y",
            description: "S\u0103n m\u00e2y b\u00ecnh minh tuy\u1ec7t di\u1ec7u t\u1ea1i \u0110\u1ed3i Ch\u00e8 C\u1ea7u \u0110\u1ea5t, trekking chinh ph\u1ee5c \u0111\u1ec9nh n\u00fai Langbiang huy\u1ec1n tho\u1ea1i, c\u1eafm tr\u1ea1i r\u1eebng th\u00f4ng th\u01a1 m\u1ed9ng v\u00e0 th\u01b0\u1edfng th\u1ee9c ti\u1ec7c BBQ \u1ea5m c\u00fang trong s\u01b0\u01a1ng m\u1edd.",
            image: "assets/images/tour_dalat.png",
            departure: "TP. H\u1ed3 Ch\u00ed Minh",
            tourType: "group",
            rating: 4.9,
            reviews: 110,
            priceVND: 2900000,
            duration: 3,
            difficulty: "medium",
            category: "hiking",
            seatsLeft: 6,
            seatsTotal: 8,
            guide: { name: "L\u00e2m Qu\u1ed1c B\u1ea3o", avatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=80&q=80" },
            lat: "72%",
            lng: "46%",
            location: "\u0110\u00e0 L\u1ea1t"
        },
        {
            id: 6,
            title: "Trekking Ru\u1ed9ng B\u1eadc Thang Sa Pa & Chinh Ph\u1ee5c Fansipan K\u1ef3 V\u0129 3 Ng\u00e0y",
            description: "H\u00e0nh tr\u00ecnh trekking ng\u1eafm ru\u1ed9ng b\u1eadc thang thung l\u0169ng M\u01b0\u1eddng Hoa k\u1ef3 v\u0129, chinh ph\u1ee5c \u0111\u1ec9nh Fansipan - N\u00f3c nh\u00e0 \u0110\u00f4ng D\u01b0\u01a1ng b\u1eb1ng c\u00e1p treo hi\u1ec7n \u0111\u1ea1i v\u00e0 tr\u1ea3i nghi\u1ec7m v\u0103n h\u00f3a b\u1ea3n \u0111\u1ecba \u0111\u1ed9c \u0111\u00e1o.",
            image: "assets/images/tour_sapa.png",
            departure: "H\u00e0 N\u1ed9i",
            tourType: "group",
            rating: 4.9,
            reviews: 154,
            priceVND: 3500000,
            duration: 3,
            difficulty: "hard",
            category: "hiking",
            seatsLeft: 3,
            seatsTotal: 8,
            guide: { name: "V\u00e0ng A T\u1ee7a", avatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=120&q=80" },
            lat: "10%",
            lng: "22%",
            location: "Sa Pa"
        },
        {
            id: 7,
            title: "Kh\u00e1m Ph\u00e1 V\u1ecbnh Nha Trang - \u0110i B\u1ed9 D\u01b0\u1edbi \u0110\u1ea1i D\u01b0\u01a1ng & VinWonders 4 Ng\u00e0y",
            description: "Tr\u1ea3i nghi\u1ec7m \u0111i b\u1ed9 d\u01b0\u1edbi \u0111\u00e1y bi\u1ec3n ng\u1eb1n r\u1ea1n san h\u00f4 r\u1ef1c r\u1ee1 t\u1ea1i H\u00f2n Mun, \u0111i ca-n\u00f4 cao t\u1ed1c ng\u1eafm v\u1ecbnh v\u00e0 th\u1ecfa s\u1ee9c vui ch\u01a1i gi\u1ea3i tr\u00ed t\u1ea1i thi\u00ean \u0111\u01b0\u1eddng VinWonders \u0111\u1eb3ng c\u1ea5p th\u1ebf gi\u1edbi.",
            image: "assets/images/tour_nhatrang.png",
            departure: "TP. H\u1ed3 Ch\u00ed Minh",
            tourType: "group",
            rating: 4.6,
            reviews: 73,
            priceVND: 4200000,
            duration: 4,
            difficulty: "medium",
            category: "beach",
            seatsLeft: 18,
            seatsTotal: 25,
            guide: { name: "Nguy\u1ec5n Minh Tri\u1ebft", avatar: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=120&q=80" },
            lat: "64%",
            lng: "50%",
            location: "Nha Trang"
        },
        {
            id: 8,
            title: "H\u00e0nh Tr\u00ecnh K\u1ef3 V\u0129 H\u00e0 Giang - M\u00e3 P\u00ed L\u00e8ng & \u0110i Thuy\u1ec1n S\u00f4ng Nho Qu\u1ebf 4 Ng\u00e0y",
            description: "Chinh ph\u1ee5c \u0111\u00e8o M\u00e3 P\u00ed L\u00e8ng - m\u1ed9t trong t\u1ee9 \u0111\u1ea1i \u0111\u1ec9nh \u0111\u00e8o Vi\u1ec7t Nam, ng\u1eafm thung l\u0169ng hoa tam gi\u00e1c m\u1ea1ch r\u1eebng \u0111\u00e1 \u0110\u1ed3ng V\u0103n v\u00e0 \u0111i thuy\u1ec1n tr\u00ean d\u00f2ng s\u00f4ng Nho Qu\u1ebf xanh nh\u01b0 ng\u1ecdc b\u00edch.",
            image: "assets/images/tour_hagiang.png",
            departure: "H\u00e0 N\u1ed9i",
            tourType: "private",
            rating: 5.0,
            reviews: 120,
            priceVND: 3200000,
            duration: 4,
            difficulty: "hard",
            category: "adventure",
            seatsLeft: 5,
            seatsTotal: 10,
            guide: { name: "S\u00f9ng M\u00ed Ph\u00ecn", avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&q=80" },
            lat: "5%",
            lng: "34%",
            location: "H\u00e0 Giang"
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
            return `${vndAmount.toLocaleString('vi-VN')} \u20ab`;
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
            priceLimitVal.textContent = `T\u1ed1i \u0111a: ${formatPrice(parseInt(priceSlider.value))}`;
        } else {
            priceSlider.min = 40;
            priceSlider.max = 400;
            priceSlider.step = 10;
            if (priceSlider.value > 1000) {
                priceSlider.value = 400;
            } else {
                priceSlider.value = Math.round((priceSlider.min + prevPercent * (priceSlider.max - priceSlider.min)) / 10) * 10;
            }
            priceLimitVal.textContent = `T\u1ed1i \u0111a: ${formatPrice(parseInt(priceSlider.value) * EXCHANGE_RATE)}`;
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
                    <p style="font-size: 1.1rem; font-weight: 600; color: var(--slate-700);">Kh\u00f4ng t\u00ecm th\u1ea5y tour ph\u00f9 h\u1ee3p v\u1edbi b\u1ed9 l\u1ecdc hi\u1ec7n t\u1ea1i.</p>
                    <button class="btn btn-secondary btn-sm" id="reset-no-results-btn" style="margin-top: 1.25rem; font-size: 0.875rem;">\u0110\u1eb7t l\u1ea1i b\u1ed9 l\u1ecdc</button>
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
            let difficultyText = "D\u1ec5 d\u00e0ng";
            let difficultyClass = "easy";
            if (tour.difficulty === "medium") {
                difficultyText = "Trung b\u00ecnh";
                difficultyClass = "medium";
            } else if (tour.difficulty === "hard") {
                difficultyText = "Th\u1eed th\u00e1ch";
                difficultyClass = "hard";
            }

            let priceText = formatPrice(tour.priceVND);
            let priceSpan = `<span>\u20ab</span>`;
            if (priceText.endsWith(' \u20ab')) {
                priceText = priceText.replace(' \u20ab', '');
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
                    <button class="btn-wishlist" aria-label="Th\u00eam v\u00e0o y\u00eau th\u00edch">
                        <i data-lucide="heart"></i>
                    </button>
                </div>
                <div class="tour-details">
                    <div class="tour-meta">
                        <div class="tour-rating">
                            <i data-lucide="star"></i>
                            <span>${tour.rating} (${tour.reviews} \u0111\u00e1nh gi\u00e1)</span>
                        </div>
                        <div class="tour-duration">
                            <i data-lucide="clock"></i>
                            <span>${tour.duration} Ng\u00e0y</span>
                        </div>
                    </div>
                    <h3>${tour.title}</h3>
                    <div class="tour-seats-progress">
                        <div class="seats-info">
                            <span>Ch\u1ed7 tr\u1ed1ng</span>
                            <span class="seats-left ${isSeatsCritical ? 'danger' : ''}">
                                ${tour.seatsLeft > 0 ? "C\u00f2n " + tour.seatsLeft + " ch\u1ed7!" : "H\u1ebft ch\u1ed7!"}
                            </span>
                        </div>
                        <div class="progress-bar-bg">
                            <div class="progress-bar-fill ${isSeatsCritical ? 'danger' : ''}" style="width: ${progressPercent}%;"></div>
                        </div>
                    </div>
                    <div class="tour-footer">
                        <div class="tour-price">
                            <span class="price-label">Gi\u00e1 m\u1ed7i kh\u00e1ch</span>
                            <span class="price-val">${priceText} ${priceSpan}</span>
                        </div>
                        <button class="btn btn-primary btn-sm btn-cta-detail" onclick="window.location.href='detail?id=${tour.id}'">Xem Chi Ti\u1ebft</button>
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
                    <span>\u2605 ${tour.rating}</span>
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
            priceLimitVal.textContent = `T\u1ed1i \u0111a: ${formatPrice(displayVal)}`;
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
            priceLimitVal.textContent = `T\u1ed1i \u0111a: ${formatPrice(getActiveCurrency() === 'vnd' ? 10000000 : 400 * EXCHANGE_RATE)}`;
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
            ? `<i data-lucide="x"></i><span>\u0110\u00f3ng b\u1ea3n \u0111\u1ed3</span>`
            : `<i data-lucide="map"></i><span>Xem b\u1ea3n \u0111\u1ed3</span>`;
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

    // Profile Dropdown and Mobile Menu Toggle are handled globally by navigation.js

    /* ==========================================================================
       RECOMMENDATION SECTION POPULATING (Tour d\u00e0nh cho b\u1ea1n)
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
                    <div class="rec-tour-badge"><span class="badge badge-featured">G\u1ee3i \u00fd</span></div>
                </div>
                <div class="rec-tour-details">
                    <div class="rec-tour-location">
                        <i data-lucide="map-pin"></i>
                        <span>${tour.location}</span>
                    </div>
                    <h3>${tour.title}</h3>
                    <div class="rec-tour-footer">
                        <div class="rec-tour-price">
                            <span class="price-label">Ch\u1ec9 t\u1eeb</span>
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
