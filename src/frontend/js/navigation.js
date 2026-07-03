document.addEventListener('DOMContentLoaded', () => {
    // Initialize Lucide Icons
    if (window.lucide) {
        lucide.createIcons();
    }

    /* ==========================================================================
       STICKY NAVBAR & SCROLL EFFECTS
       ========================================================================== */
    const header = document.getElementById('navbar') || document.getElementById('header');
    if (header) {
        // Run once on load in case page is already scrolled
        if (window.scrollY > 50 || document.body.classList.contains('explore-page') || document.body.classList.contains('detail-page') || document.body.classList.contains('wishlist-page')) {
            header.classList.add('scrolled');
        } else {
            header.classList.remove('scrolled');
        }

        window.addEventListener('scroll', () => {
            if (window.scrollY > 50 || document.body.classList.contains('explore-page') || document.body.classList.contains('detail-page') || document.body.classList.contains('wishlist-page')) {
                header.classList.add('scrolled');
            } else {
                header.classList.remove('scrolled');
            }
        });
    }

    /* ==========================================================================
       USER AVATAR DROPDOWN MENU
       ========================================================================== */
    const avatarBtn = document.getElementById('user-avatar-btn');
    const dropdownMenu = document.getElementById('user-dropdown-menu');

    if (avatarBtn && dropdownMenu) {
        avatarBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            dropdownMenu.classList.toggle('active');
        });

        // Close dropdown on click outside
        document.addEventListener('click', (e) => {
            if (!avatarBtn.contains(e.target) && !dropdownMenu.contains(e.target)) {
                dropdownMenu.classList.remove('active');
            }
        });
    }

    /* ==========================================================================
       MOBILE NAVBAR HAMBURGER TOGGLE
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
                
                // Convert mobile links to dark font color for contrast
                const mobileLinks = navMenu.querySelectorAll('.nav-link');
                mobileLinks.forEach(link => {
                    link.style.color = 'var(--slate-800)';
                });
            }
        });
    }

    /* ==========================================================================
       NAVBAR QUICK SEARCH
       ========================================================================== */
    const navSearchInput = document.getElementById('nav-search-input');
    const navSearchBtn = document.querySelector('#nav-search-bar button');

    function goToExploreFromNav() {
        if (!navSearchInput) return;
        const dest = navSearchInput.value.trim();
        window.location.href = dest ? `tourdiscovery?dest=${encodeURIComponent(dest)}` : 'tourdiscovery';
    }

    if (navSearchBtn) {
        navSearchBtn.addEventListener('click', goToExploreFromNav);
    }
    if (navSearchInput) {
        navSearchInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                e.preventDefault();
                goToExploreFromNav();
            }
        });
    }

    /* ==========================================================================
       NEWSLETTER SUBSCRIPTION FORM
       ========================================================================== */
    const newsletterForm = document.getElementById('newsletter-subscription-form');
    if (newsletterForm) {
        newsletterForm.addEventListener('submit', (e) => {
            e.preventDefault();
            alert('\u0110\u0103ng k\u00fd nh\u1eadn tin th\u00e0nh c\u00f4ng! C\u1ea3m \u01a1n b\u1ea1n \u0111\u00e3 theo d\u00f5i TourBuddy.');
            newsletterForm.reset();
        });
    }
});
