\uFEFFdocument.addEventListener('DOMContentLoaded', () => {
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
        return `${amount.toLocaleString('vi-VN')} \u20ab`;
    }

    if (budgetSlider && budgetValue) {
        budgetSlider.addEventListener('input', (e) => {
            const value = parseInt(e.target.value);
            budgetValue.textContent = formatVND(value);
        });
    }

    // Redirect search to Explore page with full parameters
    if (searchForm) {
        searchForm.addEventListener('submit', (e) => {
            e.preventDefault();
            const destination = document.getElementById('search-dest').value.trim();
            const date = document.getElementById('search-date').value;
            const budget = document.getElementById('search-budget').value;
            
            const params = new URLSearchParams();
            if (destination) params.set('dest', destination);
            if (date) params.set('date', date);
            if (budget) params.set('budget', budget);
            
            const query = params.toString();
            // Get context path dynamically if possible (assuming js is in context)
            const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
            const path = contextPath ? `${contextPath}/tourdiscovery` : 'tourdiscovery';
            window.location.href = query ? `${path}?${query}` : path;
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
                if (!isExpanded && matchingCount > 3) {
                    tour.style.display = 'none';
                } else {
                    tour.style.display = 'flex';
                }
            } else {
                tour.style.display = 'none';
            }
        });

        // Show/hide "Xem th\u00eam" / "Thu g\u1ecdn" button based on matchingCount
        if (viewMoreWrapper && viewMoreBtn) {
            if (matchingCount > 3) {
                viewMoreWrapper.style.display = 'flex';
                
                const btnLabel = viewMoreBtn.querySelector('.btn-label');
                const iconContainer = document.getElementById('btn-view-more-icon');
                
                if (isExpanded) {
                    if (btnLabel) btnLabel.textContent = 'Thu g\u1ecdn';
                    if (iconContainer) {
                        iconContainer.innerHTML = '<i data-lucide="chevron-up"></i>';
                    }
                } else {
                    if (btnLabel) btnLabel.textContent = 'Xem th\u00eam tour';
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
            
            const tourId = btn.id.replace('wishlist-', '');
            const contextPath = window.contextPath || '';
            
            fetch(`${contextPath}/customer/wishlist/toggle?tourId=${tourId}`, {
                method: 'POST'
            })
            .then(res => {
                if (res.status === 401) {
                    window.showToast('Vui l\u00f2ng \u0111\u0103ng nh\u1eadp \u0111\u1ec3 l\u01b0u tour y\u00eau th\u00edch.', 'warning');
                    return null;
                }
                if (!res.ok) {
                    throw new Error('L\u1ed7i h\u1ec7 th\u1ed1ng');
                }
                return res.json();
            })
            .then(data => {
                if (!data) return;
                
                if (data.status === 'success' || data.status === 'added' || data.status === 'removed') {
                    btn.classList.toggle('active', data.isSaved);
                    const heartIcon = btn.querySelector('svg') || btn.querySelector('i');
                    if (heartIcon) {
                        if (data.isSaved) {
                            heartIcon.setAttribute('fill', 'currentColor');
                        } else {
                            heartIcon.setAttribute('fill', 'none');
                        }
                    }
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
                    couponCode.textContent = '\u0110\u00c3 SAO CH\u00c9P!';
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
                    console.error('Kh\u00f4ng th\u1ec3 sao ch\u00e9p m\u00e3 coupon: ', err);
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

    /* ==========================================================================
       DYNAMIC TRENDING DESTINATIONS LIMIT & TOGGLE
       ========================================================================== */
    const destCards = document.querySelectorAll('.dest-card');
    const viewMoreDestsWrapper = document.getElementById('view-more-dests-wrapper');
    const viewMoreDestsBtn = document.getElementById('btn-view-more-dests');
    
    let isDestsExpanded = false;

    function updateDestVisibility() {
        destCards.forEach((card, index) => {
            if (!isDestsExpanded && index >= 3) {
                card.style.display = 'none';
            } else {
                card.style.display = '';
            }
        });

        // Show/hide button based on count
        if (viewMoreDestsWrapper && viewMoreDestsBtn) {
            if (destCards.length > 3) {
                viewMoreDestsWrapper.style.display = 'flex';
                
                const btnLabel = viewMoreDestsBtn.querySelector('.btn-label');
                const iconContainer = document.getElementById('btn-view-more-dests-icon');
                
                if (isDestsExpanded) {
                    if (btnLabel) btnLabel.textContent = 'Thu g\u1ecdn';
                    if (iconContainer) {
                        iconContainer.innerHTML = '<i data-lucide="chevron-up"></i>';
                    }
                } else {
                    if (btnLabel) btnLabel.textContent = 'Xem th\u00eam \u0111i\u1ec3m \u0111\u1ebfn';
                    if (iconContainer) {
                        iconContainer.innerHTML = '<i data-lucide="chevron-down"></i>';
                    }
                }
                
                if (window.lucide) {
                    lucide.createIcons();
                }
            } else {
                viewMoreDestsWrapper.style.display = 'none';
            }
        }
    }

    // Initialize destinations on load
    updateDestVisibility();

    // View More Destinations click handler
    if (viewMoreDestsBtn) {
        viewMoreDestsBtn.addEventListener('click', () => {
            isDestsExpanded = !isDestsExpanded;
            updateDestVisibility();
            
            // Scroll back to destinations section smoothly if collapsed
            if (!isDestsExpanded) {
                const destsSection = document.getElementById('destinations');
                if (destsSection) {
                    destsSection.scrollIntoView({ behavior: 'smooth' });
                }
            }
        });
    }
});
