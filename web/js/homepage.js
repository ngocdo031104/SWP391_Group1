document.addEventListener('DOMContentLoaded', () => {
    // Initialize Lucide Icons
    if (window.lucide) {
        lucide.createIcons();
    }

    /* ==========================================================================
       HERO BANNER SLIDESHOW
       ========================================================================== */
    const slides = document.querySelectorAll('.hero-slide');
    const indicatorDots = document.querySelectorAll('.indicator-dot');
    let currentSlide = 0;
    let slideInterval;

    function showSlide(index) {
        if (slides.length === 0) return;
        // Deactivate current slide and dot
        slides[currentSlide].classList.remove('active');
        if (indicatorDots[currentSlide]) {
            indicatorDots[currentSlide].classList.remove('active');
        }

        // Set and activate new slide
        currentSlide = (index + slides.length) % slides.length;
        slides[currentSlide].classList.add('active');
        if (indicatorDots[currentSlide]) {
            indicatorDots[currentSlide].classList.add('active');
        }
    }

    function nextSlide() {
        showSlide(currentSlide + 1);
    }

    function startSlideShow() {
        if (slides.length === 0) return;
        slideInterval = setInterval(nextSlide, 6000); // Crossfade every 6 seconds
    }

    function resetSlideShow() {
        clearInterval(slideInterval);
        startSlideShow();
    }

    // Attach click events to dots
    indicatorDots.forEach((dot, index) => {
        dot.addEventListener('click', () => {
            showSlide(index);
            resetSlideShow();
        });
    });

    // Start auto slideshow
    startSlideShow();

    /* ==========================================================================
       QUICK SEARCH INPUTS & SLIDER
       ========================================================================== */
    const budgetSlider = document.getElementById('search-budget');
    const budgetValue = document.getElementById('budget-value');
    const searchForm = document.getElementById('search-widget-form');

    // Update displayed budget value when sliding
    function formatVND(amount) {
        return `${amount.toLocaleString('vi-VN')} ₫`;
    }

    if (budgetSlider && budgetValue) {
        budgetSlider.addEventListener('input', (e) => {
            const value = parseInt(e.target.value);
            budgetValue.textContent = formatVND(value);
        });
    }

    // Redirect search to Explore page
    if (searchForm) {
        searchForm.addEventListener('submit', (e) => {
            e.preventDefault();
            const destination = document.getElementById('search-dest').value.trim();
            const params = new URLSearchParams();
            if (destination) params.set('dest', destination);
            const query = params.toString();
            window.location.href = query ? `tourdiscovery?${query}` : 'tourdiscovery';
        });
    }

    // Set search date default to tomorrow
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    const dateInput = document.getElementById('search-date');
    if (dateInput) {
        dateInput.value = tomorrow.toISOString().split('T')[0];
    }

    /* ==========================================================================
       DYNAMIC TOUR CATEGORIES FILTERING & VIEW MORE LIMIT
       ========================================================================== */
    const categoryCards = document.querySelectorAll('.category-card');
    const tourCards = document.querySelectorAll('.tour-card');
    const viewMoreWrapper = document.getElementById('view-more-tours-wrapper');
    const viewMoreBtn = document.getElementById('btn-view-more-tours');
    
    let isExpanded = false;
    let activeCategory = 'all';

    function updateTourVisibility() {
        let matchingCount = 0;
        
        tourCards.forEach(tour => {
            const tourCategory = tour.getAttribute('data-tour-category');
            const matchesCategory = (activeCategory === 'all' || tourCategory === activeCategory);
            
            if (matchesCategory) {
                matchingCount++;
                if (!isExpanded && matchingCount > 9) {
                    tour.style.display = 'none';
                } else {
                    tour.style.display = 'flex';
                }
            } else {
                tour.style.display = 'none';
            }
        });

        // Show/hide "Xem thêm" / "Thu gọn" button based on matchingCount
        if (viewMoreWrapper && viewMoreBtn) {
            if (matchingCount > 9) {
                viewMoreWrapper.style.display = 'flex';
                
                const btnLabel = viewMoreBtn.querySelector('.btn-label');
                const iconContainer = document.getElementById('btn-view-more-icon');
                
                if (isExpanded) {
                    if (btnLabel) btnLabel.textContent = 'Thu gọn';
                    if (iconContainer) {
                        iconContainer.innerHTML = '<i data-lucide="chevron-up"></i>';
                    }
                } else {
                    if (btnLabel) btnLabel.textContent = 'Xem thêm tour';
                    if (iconContainer) {
                        iconContainer.innerHTML = '<i data-lucide="chevron-down"></i>';
                    }
                }
                
                // Re-process icons using Lucide
                if (window.lucide) {
                    lucide.createIcons();
                }
            } else {
                viewMoreWrapper.style.display = 'none';
            }
        }
    }

    // Initialize visibility on page load
    updateTourVisibility();

    // Category click handler
    categoryCards.forEach(card => {
        card.addEventListener('click', () => {
            // Set active category tab styling
            categoryCards.forEach(c => c.classList.remove('active'));
            card.classList.add('active');

            activeCategory = card.getAttribute('data-category');
            isExpanded = false; // Reset expansion when changing category
            updateTourVisibility();
        });
    });

    // View More click handler
    if (viewMoreBtn) {
        viewMoreBtn.addEventListener('click', () => {
            isExpanded = !isExpanded;
            updateTourVisibility();
            
            // If collapsed, scroll the user back to the top of the tours section smoothly
            if (!isExpanded) {
                const toursSection = document.getElementById('tours');
                if (toursSection) {
                    toursSection.scrollIntoView({ behavior: 'smooth' });
                }
            }
        });
    }

    /* ==========================================================================
       WISHLIST INTERACTIVE TOGGLE
       ========================================================================== */
    const wishlistBtns = document.querySelectorAll('.btn-wishlist');

    wishlistBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.stopPropagation(); // Avoid card container events
            btn.classList.toggle('active');
            
            const heartIcon = btn.querySelector('svg') || btn.querySelector('i');
            if (heartIcon) {
                if (btn.classList.contains('active')) {
                    heartIcon.setAttribute('fill', 'currentColor');
                } else {
                    heartIcon.setAttribute('fill', 'none');
                }
            }
        });
    });

    /* ==========================================================================
       PROMOTIONS COUNTDOWN TIMER & COUPON COPIER
       ========================================================================== */
    // Dynamic countdown target (always reset to +12 hours for demonstration)
    const countdownTarget = new Date().getTime() + (12 * 60 * 60 * 1000) + (35 * 60 * 1000);

    const hoursEl = document.getElementById('timer-hours');
    const minsEl = document.getElementById('timer-mins');
    const secsEl = document.getElementById('timer-secs');

    function updateCountdown() {
        if (!hoursEl || !minsEl || !secsEl) return;
        const now = new Date().getTime();
        const difference = countdownTarget - now;

        if (difference <= 0) {
            hoursEl.textContent = '00';
            minsEl.textContent = '00';
            secsEl.textContent = '00';
            return;
        }

        const hours = Math.floor((difference % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        const minutes = Math.floor((difference % (1000 * 60 * 60)) / (1000 * 60));
        const seconds = Math.floor((difference % (1000 * 60)) / 1000);

        hoursEl.textContent = String(hours).padStart(2, '0');
        minsEl.textContent = String(minutes).padStart(2, '0');
        secsEl.textContent = String(seconds).padStart(2, '0');
    }

    if (hoursEl && minsEl && secsEl) {
        // Run once and start interval
        updateCountdown();
        setInterval(updateCountdown, 1000);
    }

    // Coupon Code Copier
    const couponCode = document.getElementById('promo-coupon-code');

    if (couponCode) {
        couponCode.addEventListener('click', () => {
            const textToCopy = couponCode.textContent.trim();
            
            navigator.clipboard.writeText(textToCopy)
                .then(() => {
                    const originalText = couponCode.textContent;
                    couponCode.textContent = 'ĐÃ SAO CHÉP!';
                    couponCode.style.backgroundColor = '#10b981';
                    couponCode.style.color = '#ffffff';
                    couponCode.style.borderColor = 'transparent';

                    setTimeout(() => {
                        couponCode.textContent = originalText;
                        couponCode.style.backgroundColor = '';
                        couponCode.style.color = '';
                        couponCode.style.borderColor = '';
                    }, 2000);
                })
                .catch(err => {
                    console.error('Không thể sao chép mã coupon: ', err);
                });
        });
    }

    /* ==========================================================================
       TESTIMONIALS SLIDER
       ========================================================================== */
    const sliderTrack = document.getElementById('testimonial-slider-track');
    const testimonialCards = document.querySelectorAll('.testimonial-card');
    const prevBtn = document.getElementById('test-prev');
    const nextBtn = document.getElementById('test-next');
    const sliderDotsContainer = document.getElementById('slider-dots-container');

    if (sliderTrack && testimonialCards.length > 0) {
        let activeTestimonial = 0;
        const testDots = sliderDotsContainer ? sliderDotsContainer.querySelectorAll('.slider-dot') : [];

        function updateSlider() {
            const offset = -activeTestimonial * 100;
            sliderTrack.style.transform = `translateX(${offset}%)`;

            // Update dots active state
            testDots.forEach((dot, index) => {
                if (index === activeTestimonial) {
                    dot.classList.add('active');
                } else {
                    dot.classList.remove('active');
                }
            });
        }

        if (nextBtn) {
            nextBtn.addEventListener('click', () => {
                activeTestimonial = (activeTestimonial + 1) % testimonialCards.length;
                updateSlider();
            });
        }

        if (prevBtn) {
            prevBtn.addEventListener('click', () => {
                activeTestimonial = (activeTestimonial - 1 + testimonialCards.length) % testimonialCards.length;
                updateSlider();
            });
        }

        testDots.forEach((dot, index) => {
            dot.addEventListener('click', () => {
                activeTestimonial = index;
                updateSlider();
            });
        });
    }
});
