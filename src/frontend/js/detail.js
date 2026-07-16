document.addEventListener('DOMContentLoaded', () => {
    // Initialize Lucide Icons
    lucide.createIcons();

    // Constant for Currency Rate
    const EXCHANGE_RATE = 25000; // 1 USD = 25,000 VND

    /* ==========================================================================
       D\u1eee LI\u1ec6U C\u01a0 B\u1ea2N TOUR \u0110\u1ed2NG B\u1ed8 V\u1edaI EXPLORE.JS
       ========================================================================== */
    const toursData = window.toursData || [];

    /* ==========================================================================
       D\u1eee LI\u1ec6U L\u1ecaCH TR\u00ccNH CHI TI\u1ebeT T\u1eeaNG NG\u00c0Y (DAILY ITINERARIES)
       ========================================================================== */
    const itinerariesData = window.itinerariesData || {};


    /* ==========================================================================
       \u0110\u00c1NH GI\u00c1 \u2014 Ch\u1ec9 t\u1ea3i t\u1eeb DB qua detail.jsp, kh\u00f4ng d\u00f9ng d\u1eef li\u1ec7u gen c\u1ee9ng
       ========================================================================== */
    const reviewsData = window.reviewsData || {};
    const defaultReviews = [];


    /* ==========================================================================
       DYNAMIC TARGET TOUR LOADING
       ========================================================================== */
    // Parse query params for ID
    const urlParams = new URLSearchParams(window.location.search);
    const tourId = window.activeTourId || parseInt(urlParams.get('id')) || 1;

    // Load active tour data
    const activeTour = toursData.find(t => t.id === tourId) || toursData[0] || {};
    
    // Dynamic array of photos for lightbox
    const photosList = activeTour.photos || [activeTour.image];
    let currentPhotoIndex = 0;
    
    // Set dynamic HTML headers
    const breadcrumbActive = document.getElementById('breadcrumb-active');
    if (breadcrumbActive) breadcrumbActive.textContent = activeTour.title;
    
    const detailTitle = document.getElementById('detail-title');
    if (detailTitle) detailTitle.textContent = activeTour.title;
    
    const detailRating = document.getElementById('detail-rating');
    if (detailRating) detailRating.textContent = activeTour.rating.toFixed(1);
    
    const detailReviewsCount = document.getElementById('detail-reviews-count');
    if (detailReviewsCount) detailReviewsCount.textContent = `(${activeTour.reviews} \u0111\u00e1nh gi\u00e1)`;
    
    const detailLocationName = document.getElementById('detail-location-name');
    if (detailLocationName) detailLocationName.textContent = activeTour.location;
    
    const galleryMainImg = document.getElementById('gallery-main-img');
    if (galleryMainImg) {
        galleryMainImg.src = activeTour.image;
        galleryMainImg.alt = activeTour.title;
    }

    // Load category translation
    let categoryText = "Premium";
    if (activeTour.category === "luxury") categoryText = "Ngh\u1ec9 d\u01b0\u1ee1ng 5\u2605";
    else if (activeTour.category === "beach") categoryText = "Kh\u00e1m ph\u00e1 Bi\u1ec3n";
    else if (activeTour.category === "hiking") categoryText = "Trekking Th\u1eed th\u00e1ch";
    else if (activeTour.category === "cultural") categoryText = "V\u0103n h\u00f3a Ho\u00e0i c\u1ed5";
    else if (activeTour.category === "adventure") categoryText = "Th\u00e1m hi\u1ec3m M\u1ea1o hi\u1ec3m";
    
    const detailCategoryBadge = document.getElementById('detail-category-badge');
    if (detailCategoryBadge) detailCategoryBadge.textContent = categoryText;

    // Load description
    const tourDetailDesc = document.getElementById('tour-detail-desc');
    if (tourDetailDesc) tourDetailDesc.textContent = activeTour.description;

    // Highlights translation
    let difficultyText = "Nh\u1eb9 nh\u00e0ng";
    if (activeTour.difficulty === "medium") difficultyText = "Trung b\u00ecnh";
    else if (activeTour.difficulty === "hard") difficultyText = "Th\u1eed th\u00e1ch m\u1ea1nh";
    
    const hlDifficulty = document.getElementById('hl-difficulty');
    if (hlDifficulty) hlDifficulty.textContent = difficultyText;
    
    const hlDuration = document.getElementById('hl-duration');
    if (hlDuration) hlDuration.textContent = `${activeTour.duration} Ng\u00e0y`;
    
    const hlGroupSize = document.getElementById('hl-group-size');
    if (hlGroupSize) hlGroupSize.textContent = `${activeTour.seatsLeft} Ch\u1ed7`;
    const hlLang = document.getElementById('hl-languages');
    if (hlLang && activeTour.languages) {
        hlLang.textContent = activeTour.languages;
    }

    // Available seats progress sidebar
    const seatsPill = document.getElementById('booking-seats-left-pill');
    if (seatsPill) {
        if (activeTour.seatsLeft <= 5) {
            seatsPill.className = "price-side-right warning-pill";
            seatsPill.innerHTML = `<span>Ch\u1ec9 c\u00f2n ${activeTour.seatsLeft} ch\u1ed7!</span>`;
        } else {
            seatsPill.className = "price-side-right";
            seatsPill.innerHTML = `<span>C\u00f2n ${activeTour.seatsLeft} ch\u1ed7 tr\u1ed1ng</span>`;
        }
    }

    // Toggle single image layout class if there's only 1 photo
    const galleryGrid = document.getElementById('photo-gallery-grid');
    if (galleryGrid) {
        if (photosList.length <= 1) {
            galleryGrid.classList.add('single-image');
        } else {
            galleryGrid.classList.remove('single-image');
        }
    }

    // Load Thumbnails
    const subThumbnails = document.querySelectorAll('.gallery-thumb');
    subThumbnails.forEach((img, idx) => {
        const subPhotoWrapper = img.closest('.sub-photo');
        if (photosList[idx + 1]) {
            img.src = photosList[idx + 1];
            if (subPhotoWrapper) {
                subPhotoWrapper.style.display = 'block';
            }
        } else {
            if (subPhotoWrapper) {
                subPhotoWrapper.style.display = 'none';
            }
        }
    });

    /* ==========================================================================
       CURRENCY & FORMATTING UTIL FUNCTIONS
       ========================================================================== */
    const currSelect = document.getElementById('curr-select');

    function getActiveCurrency() {
        return currSelect ? currSelect.value : 'vnd';
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

    // Update prices on page load
    function renderStaticPrices() {
        const bookingBasePrice = document.getElementById('booking-base-price');
        if (bookingBasePrice) {
            bookingBasePrice.textContent = formatPrice(activeTour.priceVND);
        }
    }
    renderStaticPrices();

    /* ==========================================================================
       STICKY SIDEBAR CALCULATIONS & PROMO CODE
       ========================================================================== */
    const bookDateInput = document.getElementById('book-date');
    const bookTravelersSelect = document.getElementById('book-travelers');
    const billCalculationsRow = document.getElementById('booking-bill-row');
    const billCalcLabel = document.getElementById('bill-calc-label');
    const billSubtotalVal = document.getElementById('bill-subtotal-val');
    const billTaxVal = document.getElementById('bill-tax-val');
    const billTotalVal = document.getElementById('bill-total-val');
    const promoCodeInput = document.getElementById('promo-code-input');
    const applyPromoBtn = document.getElementById('apply-promo-btn');
    const promoMessageTxt = document.getElementById('promo-message-txt');
    const promoDiscountLine = document.getElementById('promo-discount-line');
    const billDiscountVal = document.getElementById('bill-discount-val');
    const submitBookingBtn = document.getElementById('submit-booking-btn');

    // Default book date to tomorrow
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    if (bookDateInput) {
        bookDateInput.value = tomorrow.toISOString().split('T')[0];
    }

    let isPromoApplied = false;
    let appliedCoupon = null;

    function runCalculations() {
        if (!bookTravelersSelect) return;
        const travelers = parseInt(bookTravelersSelect.value);
        const basePriceVND = activeTour.priceVND;
        const subtotalVND = basePriceVND * travelers;

        // Discount calculation
        let discountVND = 0;
        if (isPromoApplied && appliedCoupon) {
            if (subtotalVND >= appliedCoupon.minOrderAmount) {
                if (appliedCoupon.discountType.toLowerCase().includes('percent') || appliedCoupon.discountType.toLowerCase() === 'percentage') {
                    discountVND = subtotalVND * (appliedCoupon.discountValue / 100.0);
                } else {
                    discountVND = appliedCoupon.discountValue;
                }
                // Discount cannot exceed subtotal
                if (discountVND > subtotalVND) {
                    discountVND = subtotalVND;
                }
            } else {
                if (promoMessageTxt) {
                    promoMessageTxt.style.color = "#dc2626";
                    promoMessageTxt.textContent = `\u0110\u01a1n h\u00e0ng ch\u01b0a \u0111\u1ea1t t\u1ed1i thi\u1ec3u ${formatPrice(appliedCoupon.minOrderAmount)}.`;
                }
                isPromoApplied = false;
                appliedCoupon = null;
            }
        }

        // Tax calculation (8% VAT)
        const taxableAmountVND = subtotalVND - discountVND;
        const taxVND = taxableAmountVND * 0.08;

        // Total
        const totalVND = taxableAmountVND + taxVND;

        // Render calculations
        if (billCalcLabel) billCalcLabel.textContent = `${travelers} kh\u00e1ch x ${formatPrice(basePriceVND)}`;
        if (billSubtotalVal) billSubtotalVal.textContent = formatPrice(subtotalVND);
        if (billTaxVal) billTaxVal.textContent = formatPrice(taxVND);
        if (billTotalVal) billTotalVal.textContent = formatPrice(totalVND);

        if (promoDiscountLine) {
            if (isPromoApplied && appliedCoupon) {
                promoDiscountLine.style.display = 'flex';
                const codeLabel = document.getElementById('promo-applied-code-label');
                if (codeLabel) {
                    codeLabel.textContent = appliedCoupon.code;
                }
                if (billDiscountVal) billDiscountVal.textContent = `-${formatPrice(discountVND)}`;
            } else {
                promoDiscountLine.style.display = 'none';
            }
        }
    }

    runCalculations();

    if (bookTravelersSelect) {
        bookTravelersSelect.addEventListener('change', runCalculations);
    }

    if (applyPromoBtn) {
        applyPromoBtn.addEventListener('click', () => {
            const code = promoCodeInput.value.trim().toUpperCase();
            if (code === "") {
                isPromoApplied = false;
                appliedCoupon = null;
                promoMessageTxt.textContent = "";
                runCalculations();
                return;
            }

            const coupons = window.activeCoupons || [];
            const found = coupons.find(c => c.code.toUpperCase() === code);

            if (found) {
                const travelers = parseInt(bookTravelersSelect.value);
                const subtotal = activeTour.priceVND * travelers;
                if (subtotal < found.minOrderAmount) {
                    isPromoApplied = false;
                    appliedCoupon = null;
                    promoMessageTxt.style.color = "#dc2626";
                    promoMessageTxt.textContent = `M\u00e3 y\u00eau c\u1ea7u \u0111\u01a1n h\u00e0ng t\u1ed1i thi\u1ec3u t\u1eeb ${formatPrice(found.minOrderAmount)}.`;
                    runCalculations();
                } else {
                    isPromoApplied = true;
                    appliedCoupon = found;
                    promoMessageTxt.style.color = "#16a34a";
                    const desc = found.discountType.toLowerCase().includes('percent') || found.discountType.toLowerCase() === 'percentage' ? `${found.discountValue}%` : formatPrice(found.discountValue);
                    promoMessageTxt.textContent = `\u00c1p d\u1ee5ng m\u00e3 gi\u1ea3m gi\u00e1 ${desc} th\u00e0nh c\u00f4ng!`;
                    runCalculations();
                }
            } else {
                isPromoApplied = false;
                appliedCoupon = null;
                promoMessageTxt.style.color = "#dc2626";
                promoMessageTxt.textContent = "M\u00e3 gi\u1ea3m gi\u00e1 kh\u00f4ng t\u1ed3n t\u1ea1i ho\u1eb7c \u0111\u00e3 h\u1ebft h\u1ea1n.";
                runCalculations();
            }
        });
    }

    if (submitBookingBtn) {
        submitBookingBtn.addEventListener('click', () => {
            window.location.href = "https://sandbox.vnpayment.vn/";
        });
    }

    /* ==========================================================================
       VERTICAL ITINERARY TIMELINE accordion RENDER
       ========================================================================== */
    const timelineContainer = document.getElementById('itinerary-timeline-container');

    function renderItinerary() {
        if (!timelineContainer) return;
        timelineContainer.innerHTML = '';
        
        const itinerary = itinerariesData[activeTour.id];
        if (!itinerary || itinerary.length === 0) {
            timelineContainer.innerHTML = '<p class="no-itinerary-msg" style="padding: 2rem; text-align: center; color: var(--slate-500);">\u0110ang c\u1eadp nh\u1eadt l\u1ecbch tr\u00ecnh chi ti\u1ebft cho tour n\u00e0y...</p>';
            return;
        }

        itinerary.forEach((item, idx) => {
            const step = document.createElement('div');
            step.className = `timeline-step ${idx === 0 ? 'active' : ''}`;
            
            // Map standard icons
            let iconName = "map-pin";
            if (item.icon === "cable-car") iconName = "cable-car";
            else if (item.icon === "camera") iconName = "camera";
            else if (item.icon === "plane") iconName = "plane";
            else if (item.icon === "ship") iconName = "ship";
            else if (item.icon === "palmtree") iconName = "palmtree";
            else if (item.icon === "sparkles") iconName = "sparkles";
            else if (item.icon === "mountain") iconName = "mountain";
            else if (item.icon === "activity") iconName = "activity";
            else if (item.icon === "landmark") iconName = "landmark";

            step.innerHTML = `
                <div class="timeline-badge">
                    <i data-lucide="${iconName}"></i>
                </div>
                <div class="timeline-panel">
                    <div class="timeline-heading">
                        <span class="timeline-day-label">Ng\u00e0y ${item.day}</span>
                        <h4>${item.title}</h4>
                        <i data-lucide="chevron-down" class="timeline-arrow"></i>
                    </div>
                    <div class="timeline-body">
                        <p>${item.desc}</p>
                    </div>
                </div>
            `;

            // Toggle timeline body visibility (Accordion)
            const heading = step.querySelector('.timeline-heading');
            heading.addEventListener('click', () => {
                step.classList.toggle('active');
            });

            timelineContainer.appendChild(step);
        });

        lucide.createIcons();
    }
    renderItinerary();

    /* ==========================================================================
       FULLSCREEN LIGHTBOX SLIDESHOW
       ========================================================================== */
    const lightbox = document.getElementById('gallery-lightbox');
    const expandedImg = document.getElementById('lightbox-expanded-img');
    const captionTxt = document.getElementById('lightbox-caption-txt');
    const closeLightboxBtn = document.getElementById('lightbox-close-btn');
    const prevLightboxBtn = document.getElementById('lightbox-prev-btn');
    const nextLightboxBtn = document.getElementById('lightbox-next-btn');

    function openLightbox(index) {
        currentPhotoIndex = index;
        if (expandedImg) expandedImg.src = photosList[currentPhotoIndex];
        if (captionTxt) captionTxt.textContent = `H\u00ecnh \u1ea3nh ${currentPhotoIndex + 1} / ${photosList.length} - ${activeTour.title}`;
        if (lightbox) lightbox.classList.add('active');
    }

    // Main photo click
    const mainImg = document.getElementById('gallery-main-img');
    if (mainImg) {
        mainImg.addEventListener('click', () => openLightbox(0));
    }

    // Thumbnails click
    if (subThumbnails) {
        subThumbnails.forEach((img, idx) => {
            img.addEventListener('click', () => openLightbox(idx + 1));
        });
    }

    // View all button click
    const viewAllBtn = document.getElementById('view-all-photos-btn');
    if (viewAllBtn) {
        viewAllBtn.addEventListener('click', () => openLightbox(0));
    }

    // Close Lightbox
    if (closeLightboxBtn) {
        closeLightboxBtn.addEventListener('click', () => {
            lightbox.classList.remove('active');
        });
    }

    // Next Slide
    function nextSlide() {
        currentPhotoIndex = (currentPhotoIndex + 1) % photosList.length;
        if (expandedImg) expandedImg.src = photosList[currentPhotoIndex];
        if (captionTxt) captionTxt.textContent = `H\u00ecnh \u1ea3nh ${currentPhotoIndex + 1} / ${photosList.length} - ${activeTour.title}`;
    }

    // Prev Slide
    function prevSlide() {
        currentPhotoIndex = (currentPhotoIndex - 1 + photosList.length) % photosList.length;
        if (expandedImg) expandedImg.src = photosList[currentPhotoIndex];
        if (captionTxt) captionTxt.textContent = `H\u00ecnh \u1ea3nh ${currentPhotoIndex + 1} / ${photosList.length} - ${activeTour.title}`;
    }

    if (nextLightboxBtn) nextLightboxBtn.addEventListener('click', nextSlide);
    if (prevLightboxBtn) prevLightboxBtn.addEventListener('click', prevSlide);

    // Keyboard support for Lightbox
    document.addEventListener('keydown', (e) => {
        if (!lightbox || !lightbox.classList.contains('active')) return;
        if (e.key === 'Escape') lightbox.classList.remove('active');
        if (e.key === 'ArrowRight') nextSlide();
        if (e.key === 'ArrowLeft') prevSlide();
    });

    // Play video simulated alert
    const playVideoBtn = document.getElementById('play-video-btn');
    if (playVideoBtn) {
        playVideoBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            alert("\u0110ang t\u1ea3i video gi\u1edbi thi\u1ec7u h\u00e0nh tr\u00ecnh du l\u1ecbch cao c\u1ea5p c\u1ee7a TourBuddy...");
        });
    }

    /* ==========================================================================
       REVIEWS SECTION RENDER & ADD COMMENT FORM
       ========================================================================== */
    const newReviewForm = document.getElementById('new-review-form');
    const starsSelector = document.getElementById('stars-selector');
    
    // Reviews state
    let selectedRatingVal = 5; // Default 5 stars selected

    // Star selector event using event delegation to support Lucide SVG replacement
    if (starsSelector) {
        starsSelector.addEventListener('click', (e) => {
            const star = e.target.closest('.star-select');
            if (!star) return;
            const rating = parseInt(star.getAttribute('data-rating'));
            selectedRatingVal = rating;
            
            const starIcons = starsSelector.querySelectorAll('.star-select');
            starIcons.forEach(s => {
                const r = parseInt(s.getAttribute('data-rating'));
                if (r <= rating) {
                    s.classList.add('active');
                } else {
                    s.classList.remove('active');
                }
            });
        });
        // Init 5 stars selected visually
        setTimeout(() => {
            const starIcons = starsSelector.querySelectorAll('.star-select');
            starIcons.forEach(s => s.classList.add('active'));
        }, 150);
    }

    // Simulator Upload image
    // Real Upload image handling
    const uploadSimBtn = document.getElementById('upload-sim-btn');
    const reviewImageInput = document.getElementById('review-image-input');
    const uploadPreviewRow = document.getElementById('uploaded-images-preview-row');

    if (uploadSimBtn && reviewImageInput) {
        uploadSimBtn.addEventListener('click', () => {
            reviewImageInput.click();
        });

        reviewImageInput.addEventListener('change', (e) => {
            const file = e.target.files[0];
            if (file && uploadPreviewRow) {
                const reader = new FileReader();
                reader.onload = (event) => {
                    uploadPreviewRow.innerHTML = `
                        <div class="preview-img-wrapper" style="position: relative; display: inline-block;">
                            <img src="${event.target.result}" alt="\u1ea2nh xem tr\u01b0\u1edbc" style="max-width: 150px; border-radius: 8px; border: 1px solid #e2e8f0;">
                            <span class="remove-preview-btn" id="remove-preview-img-btn" style="position: absolute; top: -6px; right: -6px; background: #ef4444; color: #ffffff; width: 20px; height: 20px; border-radius: 50%; display: flex; align-items: center; justify-content: center; cursor: pointer; font-size: 12px; font-weight: bold; border: 1px solid #ffffff;">&times;</span>
                        </div>
                    `;
                    document.getElementById('remove-preview-img-btn').addEventListener('click', () => {
                        uploadPreviewRow.innerHTML = '';
                        reviewImageInput.value = ''; // Clear file input
                    });
                };
                reader.readAsDataURL(file);
            }
        });
    }

    // LÝ DO VÀ CHỨC NàNG CỦA ĐOẠN SUBMIT FORM ĐÁNH GIÁ (SUBMIT REVIEW FORM):
    // - Khi người dùng bấm nút gửi đánh giá, trình duyệt sẽ kích hoạt sự kiện submit này.
    // - Ta cần đọc biến `selectedRatingVal` (chứa số sao người dùng vừa chọn bằng cách click vào các ngôi sao trên giao diện).
    // - Gán giá trị sao này vào thẻ input ẩn `#review-rating-input` để nó được gửi đi cùng dữ liệu form POST.
    // - Chúng ta KHÔNG gọi `e.preventDefault()` để cho phép biểu mẫu tự động submit tự nhiên lên servlet
    //   DetailController (POST) lưu trữ vào cơ sở dữ liệu và tải lại trang chi tiết.
    if (newReviewForm) {
        newReviewForm.addEventListener('submit', (e) => {
            const ratingInput = document.getElementById('review-rating-input');
            if (ratingInput) {
                ratingInput.value = selectedRatingVal;
            }
            // Allow natural HTML form submission to backend DetailController doPost
        });
    }

    /* ==========================================================================
       FAQ INTERACTIVE ACCORDION
       ========================================================================== */
    const faqItems = document.querySelectorAll('.faq-item');
    faqItems.forEach(item => {
        const question = item.querySelector('.faq-question');
        question.addEventListener('click', () => {
            item.classList.toggle('active');
        });
    });

    /* ==========================================================================
       RELATED TOURS RENDER (3 other tours recommended)
       ========================================================================== */
    const relatedToursGrid = document.getElementById('related-tours-grid-container');

    function renderRelatedTours() {
        if (!relatedToursGrid) return;
        relatedToursGrid.innerHTML = '';
        
        // Pick three other tours
        const related = toursData.filter(t => t.id !== activeTour.id).slice(0, 3);

        related.forEach(tour => {
            const card = document.createElement('div');
            card.className = 'tour-card';
            card.setAttribute('data-id', tour.id);

            card.innerHTML = `
                <div class="tour-img-wrapper">
                    <img src="${tour.image}" alt="${tour.title}" class="tour-img">
                    <div class="tour-badge">
                        <span class="badge badge-featured">T\u01b0\u01a1ng T\u1ef1</span>
                    </div>
                </div>
                <div class="tour-details">
                    <div class="tour-location-badge">
                        <i data-lucide="map-pin"></i>
                        <span>${tour.location}</span>
                    </div>
                    <h3>${tour.title}</h3>
                    <div class="tour-footer">
                        <div class="tour-price">
                            <span class="price-label">Gi\u00e1 t\u1eeb</span>
                            <span class="price-val">${formatPrice(tour.priceVND)}</span>
                        </div>
                        <button class="btn btn-primary btn-sm" onclick="window.location.href='detail?id=${tour.id}'">Xem Ngay</button>
                    </div>
                </div>
            `;
            relatedToursGrid.appendChild(card);
        });

        lucide.createIcons();
    }
    renderRelatedTours();

    /* ==========================================================================
       CURRENCY CHANGE LISTENER
       ========================================================================== */
    if (currSelect) {
        currSelect.addEventListener('change', () => {
            // Re-render prices, calculated items and related tours
            renderStaticPrices();
            runCalculations();
            renderRelatedTours();
        });
    }

    // Sharing button simulated
    const shareBtn = document.getElementById('share-btn');
    if (shareBtn) {
        shareBtn.addEventListener('click', () => {
            alert(`\u0110\u00e3 sao ch\u00e9p li\u00ean k\u1ebft chia s\u1ebb h\u00e0nh tr\u00ecnh:\n${window.location.href}`);
        });
    }

    // Wishlist detail button toggle
    const wishlistDetailBtn = document.getElementById('wishlist-detail-btn');
    if (wishlistDetailBtn) {
        wishlistDetailBtn.addEventListener('click', () => {
            const tourId = wishlistDetailBtn.getAttribute('data-tour-id');
            const contextPath = window.contextPath || '';
            
            fetch(`${contextPath}/customer/wishlist/toggle?tourId=${tourId}`, {
                method: 'POST'
            })
            .then(res => {
                if (res.status === 401) {
                    window.showToast('Vui l\u00f2ng \u0111\u0103ng nh\u1eadp \u0111\u1ec3 l\u01b0u tour y\u00eau th\u00edch.', 'warning');
                    return null;
                }
                if (!res.ok) throw new Error('L\u1ed7i h\u1ec7 th\u1ed1ng');
                return res.json();
            })
            .then(data => {
                if (!data) return;
                
                if (data.status === 'success' || data.status === 'added' || data.status === 'removed') {
                    wishlistDetailBtn.classList.toggle('active', data.isSaved);
                    if (data.isSaved) {
                        wishlistDetailBtn.innerHTML = `<i data-lucide="heart" fill="currentColor"></i> Đã lưu Yêu thích`;
                    } else {
                        wishlistDetailBtn.innerHTML = `<i data-lucide="heart"></i> Lưu vào Yêu thích`;
                    }
                    if (window.lucide) window.lucide.createIcons();
                    window.showToast(data.message, 'success');
                } else {
                    window.showToast(data.message, 'error');
                }
            })
            .catch(err => {
                console.error(err);
                window.showToast('\u0110\u00e3 x\u1ea3y ra l\u1ed7i k\u1ebft n\u1ed1i!', 'error');
            });
        });
    }

    // Flag/Report review click listener
    const reportReviewBtns = document.querySelectorAll('.btn-report-review');
    reportReviewBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            const reviewId = btn.getAttribute('data-id');
            const contextPath = window.contextPath || '';
            
            const params = new URLSearchParams();
            params.append("entityType", "Review");
            params.append("entityId", reviewId);

            fetch(`${contextPath}/customer/report`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: params
            })
            .then(res => {
                if (res.status === 401) {
                    if (window.showToast) {
                        window.showToast('Vui l\u00f2ng \u0111\u0103ng nh\u1eadp \u0111\u1ec3 b\u00e1o c\u00e1o vi ph\u1ea1m.', 'warning');
                    } else {
                        alert('Vui l\u00f2ng \u0111\u0103ng nh\u1eadp \u0111\u1ec3 b\u00e1o c\u00e1o vi ph\u1ea1m.');
                    }
                    return null;
                }
                if (!res.ok) throw new Error('Thao t\u00e1c th\u1ea5t b\u1ea1i');
                return res.json();
            })
            .then(data => {
                if (!data) return;
                if (data.status === 'success') {
                    if (window.showToast) {
                        window.showToast(data.message, 'success');
                    } else {
                        alert(data.message);
                    }
                    // Disable button after successful reporting
                    btn.disabled = true;
                    btn.style.color = '#94a3b8';
                    btn.innerHTML = `<i class="fa-solid fa-flag"></i> \u0110\u00e3 b\u00e1o c\u00e1o`;
                } else {
                    if (window.showToast) {
                        window.showToast(data.message, 'error');
                    } else {
                        alert(data.message);
                    }
                }
            })
            .catch(err => {
                console.error(err);
                if (window.showToast) {
                    window.showToast('\u0110\u00e3 x\u1ea3y ra l\u1ed7i k\u1ebft n\u1ed1i!', 'error');
                } else {
                    alert('\u0110\u00e3 x\u1ea3y ra l\u1ed7i k\u1ebft n\u1ed1i!');
                }
            });
        });
    });

});

