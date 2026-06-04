document.addEventListener('DOMContentLoaded', () => {
    // Initialize Lucide Icons
    lucide.createIcons();

    // Constant for Currency Rate
    const EXCHANGE_RATE = 25000; // 1 USD = 25,000 VND

    /* ==========================================================================
       DỮ LIỆU CƠ BẢN TOUR ĐỒNG BỘ VỚI EXPLORE.JS
       ========================================================================== */
    const toursData = window.toursData || [
        {
            id: 1,
            title: "Tour Thượng Lưu Bà Nà Hills, Cầu Vàng & Ngũ Hành Sơn 3 Ngày",
            description: "Trải nghiệm cáp treo đạt nhiều kỷ lục thế giới, check-in Cầu Vàng huyền thoại giữa mây ngàn, khám phá làng Pháp cổ kính và lưu trú tại resort 5 sao bên bờ biển Mỹ Khê tuyệt mỹ.",
            image: "assets/images/tour_danang.png",
            rating: 4.9,
            reviews: 142,
            priceVND: 4800000,
            duration: 3,
            difficulty: "easy",
            category: "luxury",
            seatsLeft: 8,
            seatsTotal: 20,
            guide: { name: "Nguyễn Văn Hùng", avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=80&q=80" },
            location: "Đà Nẵng"
        },
        {
            id: 2,
            title: "Thiên Đường Đảo Ngọc Phú Quốc - Lặn San Hô & Ngắm Hoàng Hôn 4 Ngày",
            description: "Khám phá các đảo hoang sơ phía Nam, lên du thuyền câu cá lặn ngắm san hô tại hòn Móng Tay, thưởng thức tiệc hải sản tươi sống và ngắm hoàng hôn Sunset Sanato rực rỡ.",
            image: "assets/images/tour_phuquoc.png",
            rating: 5.0,
            reviews: 98,
            priceVND: 6200000,
            duration: 4,
            difficulty: "easy",
            category: "beach",
            seatsLeft: 12,
            seatsTotal: 20,
            guide: { name: "Trần Minh Tâm", avatar: "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=80&q=80" },
            location: "Phú Quốc"
        },
        {
            id: 3,
            title: "Nghỉ Dưỡng Du Thuyền 5 Sao Vịnh Hạ Long & Chèo Thuyền Kayak 2 Ngày",
            description: "Thư giãn trên du thuyền sang trọng giữa kỳ quan thiên nhiên thế giới. Trải nghiệm chèo kayak qua Hang Luồn kỳ thú, chinh phục đỉnh đảo Ti Tốp và thưởng thức ẩm thực Á-Âu thượng hạng.",
            image: "assets/images/tour_halong.png",
            rating: 4.8,
            reviews: 215,
            priceVND: 3900000,
            duration: 2,
            difficulty: "easy",
            category: "luxury",
            seatsLeft: 4,
            seatsTotal: 10,
            guide: { name: "Lê Hoàng Nam", avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=80&q=80" },
            location: "Hạ Long"
        },
        {
            id: 4,
            title: "Hành Trình Phố Cổ Hội An Hoài Cổ & Thả Đèn Hoa Đăng Sông Hoài 2 Ngày",
            description: "Tản bộ qua những bức tường vàng phủ rêu phong hàng trăm năm tuổi, tham gia làm đèn lồng truyền thống nghệ thuật, thưởng thức Cao Lầu đặc sản và đi thuyền gỗ thả đèn hoa đăng lung linh.",
            image: "assets/images/tour_hoian.png",
            rating: 4.7,
            reviews: 86,
            priceVND: 1850000,
            duration: 2,
            difficulty: "easy",
            category: "cultural",
            seatsLeft: 15,
            seatsTotal: 30,
            guide: { name: "Phạm Thùy Linh", avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=80&q=80" },
            location: "Hội An"
        },
        {
            id: 5,
            title: "Săn Mây Đà Lạt, Chinh Phục Langbiang & Cắm Trại Rừng Thông 3 Ngày",
            description: "Săn mây bình minh tuyệt diệu tại Đồi Chè Cầu Đất, trekking chinh phục đỉnh núi Langbiang huyền thoại, cắm trại rừng thông thơ mộng và thưởng thức tiệc BBQ ấm cúng trong sương mờ.",
            image: "assets/images/tour_dalat.png",
            rating: 4.9,
            reviews: 110,
            priceVND: 2900000,
            duration: 3,
            difficulty: "medium",
            category: "hiking",
            seatsLeft: 6,
            seatsTotal: 8,
            guide: { name: "Lâm Quốc Bảo", avatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=80&q=80" },
            location: "Đà Lạt"
        },
        {
            id: 6,
            title: "Trekking Ruộng Bậc Thang Sa Pa & Chinh Phục Fansipan Kỳ Vĩ 3 Ngày",
            description: "Hành trình trekking ngắm ruộng bậc thang thung lũng Mường Hoa kỳ vĩ, chinh phục đỉnh Fansipan - Nóc nhà Đông Dương bằng cáp treo hiện đại và trải nghiệm văn hóa bản địa độc đáo.",
            image: "assets/images/tour_sapa.png",
            rating: 4.9,
            reviews: 154,
            priceVND: 3500000,
            duration: 3,
            difficulty: "hard",
            category: "hiking",
            seatsLeft: 3,
            seatsTotal: 8,
            guide: { name: "Vàng A Tủa", avatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=120&q=80" },
            location: "Sa Pa"
        },
        {
            id: 7,
            title: "Khám Phá Vịnh Nha Trang - Đi Bộ Dưới Đại Dương & VinWonders 4 Ngày",
            description: "Trải nghiệm đi bộ dưới đáy biển ngắm rạn san hô rực rỡ tại Hòn Mun, đi ca-nô cao tốc ngắm vịnh và thỏa sức vui chơi giải trí tại thiên đường VinWonders đẳng cấp thế giới.",
            image: "assets/images/tour_nhatrang.png",
            rating: 4.6,
            reviews: 73,
            priceVND: 4200000,
            duration: 4,
            difficulty: "medium",
            category: "beach",
            seatsLeft: 18,
            seatsTotal: 25,
            guide: { name: "Nguyễn Minh Triết", avatar: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=120&q=80" },
            location: "Nha Trang"
        },
        {
            id: 8,
            title: "Hành Trình Kỳ Vĩ Hà Giang - Mã Pí Lèng & Đi Thuyền Sông Nho Quế 4 Ngày",
            description: "Chinh phục đèo Mã Pí Lèng - một trong tứ đại đỉnh đèo Việt Nam, ngắm thung lũng hoa tam giác mạch rừng đá Đồng Văn và đi thuyền trên dòng sông Nho Quế xanh như ngọc bích.",
            image: "assets/images/tour_hagiang.png",
            rating: 5.0,
            reviews: 120,
            priceVND: 3200000,
            duration: 4,
            difficulty: "hard",
            category: "adventure",
            seatsLeft: 5,
            seatsTotal: 10,
            guide: { name: "Sùng Mí Phìn", avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&q=80" },
            location: "Hà Giang"
        }
    ];

    /* ==========================================================================
       DỮ LIỆU LỊCH TRÌNH CHI TIẾT TỪNG NGÀY (DAILY ITINERARIES)
       ========================================================================== */
    const itinerariesData = window.itinerariesData || {};

    /* ==========================================================================
       DỮ LIỆU ĐÁNH GIÁ MẪU CHO TỪNG TOUR (SAMPLE REVIEWS)
       Lý do tại sao lại sử dụng window.reviewsData:
       - Để nhận dữ liệu danh sách đánh giá của tour hiện tại được nạp động từ DB (qua detail.jsp).
       - Nếu DB chưa có đánh giá nào, sẽ sử dụng các đánh giá mẫu đã chuẩn bị sẵn để hiển thị cho đẹp mắt.
       ========================================================================== */
    const reviewsData = window.reviewsData || {
        6: [
            { name: "Phạm Minh Hoàng", rating: 5, date: "15/05/2026", text: "Chuyến trekking Fansipan thực sự là trải nghiệm để đời! Đường leo dốc tuy mệt nhưng phong cảnh ruộng bậc thang Sa Pa lộng gió quá đẹp. Đỉnh núi mây mù giăng lối sương lạnh buốt chạm tay vào chóp cảm giác tự hào vô cùng. Hướng dẫn viên Tủa rất chu đáo, nhiệt tình hỗ trợ đoàn.", isVerified: true, avatar: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80", image: "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=400&q=80" },
            { name: "Nguyễn Thùy Chi", rating: 5, date: "02/05/2026", text: "Du lịch Sa Pa dịch vụ của TourBuddy rất xuất sắc. Khách sạn 5 sao có bồn tắm nước nóng ngắm thung lũng, đồ ăn buffet ngon miệng phong phú. Trải nghiệm tắm lá thuốc Dao đỏ ở bản Tả Phìn vô cùng thư giãn, đỡ mỏi hẳn sau ngày trekking dốc núi.", isVerified: true, avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=80&q=80" },
            { name: "Lê Quốc Bảo", rating: 4, date: "24/04/2026", text: "Phong cảnh thung lũng Mường Hoa rất thơ mộng. Dịch vụ ăn uống ngon nhưng lịch trình ngày 2 leo Fansipan đi bộ hơi mỏi chân chút. Cáp treo rất hiện đại, cabin kính rộng lớn. Đáng tiền trải nghiệm!", isVerified: true, avatar: "https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=80&q=80" }
        ]
    };

    // Fallback reviews for tours that don't have specified review lists
    const defaultReviews = [
        { name: "Trần Anh Tuấn", rating: 5, date: "20/05/2026", text: "Dịch vụ đẳng cấp chuyên nghiệp! Đưa đón đúng giờ, hướng dẫn viên nhiệt tình vui tính. Các điểm tham quan cực đẹp, khách sạn resort ở siêu thích. Chắc chắn sẽ tiếp tục ủng hộ TourBuddy trong các hành trình du lịch tiếp theo.", isVerified: true, avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=80&q=80" },
        { name: "Lê Minh Thư", rating: 5, date: "14/05/2026", text: "Trải nghiệm du lịch 5 sao đáng tiền từng xu. Thức ăn siêu ngon đa dạng, lịch trình sắp xếp cực kỳ khoa học không gây cảm giác mệt mỏi. Gia đình tôi đều rất hài lòng.", isVerified: true, avatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=80&q=80" }
    ];


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
    document.getElementById('breadcrumb-active').textContent = activeTour.title;
    document.getElementById('detail-title').textContent = activeTour.title;
    document.getElementById('detail-rating').textContent = activeTour.rating.toFixed(1);
    document.getElementById('detail-reviews-count').textContent = `(${activeTour.reviews} đánh giá)`;
    document.getElementById('detail-location-name').textContent = activeTour.location;
    document.getElementById('gallery-main-img').src = activeTour.image;
    document.getElementById('gallery-main-img').alt = activeTour.title;

    // Load category translation
    let categoryText = "Premium";
    if (activeTour.category === "luxury") categoryText = "Nghỉ dưỡng 5★";
    else if (activeTour.category === "beach") categoryText = "Khám phá Biển";
    else if (activeTour.category === "hiking") categoryText = "Trekking Thử thách";
    else if (activeTour.category === "cultural") categoryText = "Văn hóa Hoài cổ";
    else if (activeTour.category === "adventure") categoryText = "Thám hiểm Mạo hiểm";
    document.getElementById('detail-category-badge').textContent = categoryText;

    // Load description
    document.getElementById('tour-detail-desc').textContent = activeTour.description;

    // Highlights translation
    let difficultyText = "Nhẹ nhàng";
    if (activeTour.difficulty === "medium") difficultyText = "Trung bình";
    else if (activeTour.difficulty === "hard") difficultyText = "Thử thách mạnh";
    
    document.getElementById('hl-difficulty').textContent = difficultyText;
    document.getElementById('hl-duration').textContent = `${activeTour.duration} Ngày`;
    document.getElementById('hl-group-size').textContent = `${activeTour.seatsLeft} Chỗ`;
    const hlLang = document.getElementById('hl-languages');
    if (hlLang && activeTour.languages) {
        hlLang.textContent = activeTour.languages;
    }

    // Available seats progress sidebar
    const seatsPill = document.getElementById('booking-seats-left-pill');
    if (seatsPill) {
        if (activeTour.seatsLeft <= 5) {
            seatsPill.className = "price-side-right warning-pill";
            seatsPill.innerHTML = `<span>Chỉ còn ${activeTour.seatsLeft} chỗ!</span>`;
        } else {
            seatsPill.className = "price-side-right";
            seatsPill.innerHTML = `<span>Còn ${activeTour.seatsLeft} chỗ trống</span>`;
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
            return `${vndAmount.toLocaleString('vi-VN')} ₫`;
        } else {
            const usdAmount = Math.round(vndAmount / EXCHANGE_RATE);
            return `$${usdAmount.toLocaleString('en-US')}`;
        }
    }

    // Update prices on page load
    function renderStaticPrices() {
        document.getElementById('booking-base-price').textContent = formatPrice(activeTour.priceVND);
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
                    promoMessageTxt.textContent = `Đơn hàng chưa đạt tối thiểu ${formatPrice(appliedCoupon.minOrderAmount)}.`;
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
        if (billCalcLabel) billCalcLabel.textContent = `${travelers} khách x ${formatPrice(basePriceVND)}`;
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
                    promoMessageTxt.textContent = `Mã yêu cầu đơn hàng tối thiểu từ ${formatPrice(found.minOrderAmount)}.`;
                    runCalculations();
                } else {
                    isPromoApplied = true;
                    appliedCoupon = found;
                    promoMessageTxt.style.color = "#16a34a";
                    const desc = found.discountType.toLowerCase().includes('percent') || found.discountType.toLowerCase() === 'percentage' ? `${found.discountValue}%` : formatPrice(found.discountValue);
                    promoMessageTxt.textContent = `Áp dụng mã giảm giá ${desc} thành công!`;
                    runCalculations();
                }
            } else {
                isPromoApplied = false;
                appliedCoupon = null;
                promoMessageTxt.style.color = "#dc2626";
                promoMessageTxt.textContent = "Mã giảm giá không tồn tại hoặc đã hết hạn.";
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
            timelineContainer.innerHTML = '<p class="no-itinerary-msg" style="padding: 2rem; text-align: center; color: var(--slate-500);">Đang cập nhật lịch trình chi tiết cho tour này...</p>';
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
                        <span class="timeline-day-label">Ngày ${item.day}</span>
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
        expandedImg.src = photosList[currentPhotoIndex];
        captionTxt.textContent = `Hình ảnh ${currentPhotoIndex + 1} / ${photosList.length} - ${activeTour.title}`;
        lightbox.classList.add('active');
    }

    // Main photo click
    document.getElementById('gallery-main-img').addEventListener('click', () => openLightbox(0));

    // Thumbnails click
    subThumbnails.forEach((img, idx) => {
        img.addEventListener('click', () => openLightbox(idx + 1));
    });

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
        expandedImg.src = photosList[currentPhotoIndex];
        captionTxt.textContent = `Hình ảnh ${currentPhotoIndex + 1} / ${photosList.length} - ${activeTour.title}`;
    }

    // Prev Slide
    function prevSlide() {
        currentPhotoIndex = (currentPhotoIndex - 1 + photosList.length) % photosList.length;
        expandedImg.src = photosList[currentPhotoIndex];
        captionTxt.textContent = `Hình ảnh ${currentPhotoIndex + 1} / ${photosList.length} - ${activeTour.title}`;
    }

    if (nextLightboxBtn) nextLightboxBtn.addEventListener('click', nextSlide);
    if (prevLightboxBtn) prevLightboxBtn.addEventListener('click', prevSlide);

    // Keyboard support for Lightbox
    document.addEventListener('keydown', (e) => {
        if (!lightbox.classList.contains('active')) return;
        if (e.key === 'Escape') lightbox.classList.remove('active');
        if (e.key === 'ArrowRight') nextSlide();
        if (e.key === 'ArrowLeft') prevSlide();
    });

    // Play video simulated alert
    const playVideoBtn = document.getElementById('play-video-btn');
    if (playVideoBtn) {
        playVideoBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            alert("Đang tải video giới thiệu hành trình du lịch cao cấp của TourBuddy...");
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
    const uploadSimBtn = document.getElementById('upload-sim-btn');
    const uploadPreviewRow = document.getElementById('uploaded-images-preview-row');
    let simulatedUploadedImgUrl = '';

    if (uploadSimBtn) {
        uploadSimBtn.addEventListener('click', () => {
            // Simulated upload of a beautiful landscape image
            simulatedUploadedImgUrl = "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=400&q=80";
            if (uploadPreviewRow) {
                uploadPreviewRow.innerHTML = `
                    <div class="preview-img-wrapper">
                        <img src="${simulatedUploadedImgUrl}" alt="Ảnh xem trước">
                        <span class="remove-preview-btn" id="remove-preview-img-btn">&times;</span>
                    </div>
                `;
                document.getElementById('remove-preview-img-btn').addEventListener('click', () => {
                    uploadPreviewRow.innerHTML = '';
                    simulatedUploadedImgUrl = '';
                });
            }
        });
    }

    // LÝ DO VÀ CHỨC NĂNG CỦA ĐOẠN SUBMIT FORM ĐÁNH GIÁ (SUBMIT REVIEW FORM):
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
                        <span class="badge badge-featured">Tương Tự</span>
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
                            <span class="price-label">Giá từ</span>
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
            alert(`Đã sao chép liên kết chia sẻ hành trình:\n${window.location.href}`);
        });
    }

    // Wishlist detail button toggle
    const wishlistDetailBtn = document.getElementById('wishlist-detail-btn');
    if (wishlistDetailBtn) {
        wishlistDetailBtn.addEventListener('click', () => {
            wishlistDetailBtn.classList.toggle('active');
            const heartIcon = wishlistDetailBtn.querySelector('svg');
            if (wishlistDetailBtn.classList.contains('active')) {
                heartIcon.setAttribute('fill', 'currentColor');
                wishlistDetailBtn.innerHTML = `<i data-lucide="heart" fill="currentColor"></i> Đã lưu Yêu thích`;
            } else {
                heartIcon.setAttribute('fill', 'none');
                wishlistDetailBtn.innerHTML = `<i data-lucide="heart"></i> Lưu vào Yêu thích`;
            }
            lucide.createIcons();
        });
    }

    /* ==========================================================================
       MOBILE RESPONSIVE CONTROLS
       ========================================================================== */
    const mobileMenuToggle = document.getElementById('mobile-menu-toggle');
    const navMenu = document.getElementById('nav-menu');

    if (mobileMenuToggle && navMenu) {
        mobileMenuToggle.addEventListener('click', () => {
            if (navMenu.style.display === 'flex') {
                navMenu.style.display = 'none';
            } else {
                navMenu.style.display = 'flex';
                navMenu.style.flexDirection = 'column';
                navMenu.style.position = 'absolute';
                navMenu.style.top = '70px';
                navMenu.style.left = '0';
                navMenu.style.width = '100%';
                navMenu.style.backgroundColor = 'var(--bg-glass)';
                navMenu.style.backdropFilter = 'blur(12px)';
                navMenu.style.padding = '1.5rem var(--space-md)';
                navMenu.style.boxShadow = 'var(--shadow-lg)';
                navMenu.style.gap = '1rem';
                
                navMenu.querySelectorAll('.nav-link').forEach(link => {
                    link.style.color = 'var(--slate-800)';
                });
            }
        });
    }
});
