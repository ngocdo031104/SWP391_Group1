<%-- 
    Màn hình 4: View Home Page - Trang chủ hiển thị banners, featured tours, trending tours
    Tác giả: Dương Quang Sơn
    MSSV: HE186525
    Ngày tạo: 2026-07-21
--%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="Entities.Tour" %>
<%@ page import="Entities.TourCategory" %>
<%@ page import="Entities.TourSchedule" %>
<%@ page import="Entities.DestinationInfo" %>
<%@ page import="Entities.Review" %>
<%@ page import="Entities.Coupon" %>
<%
    request.setAttribute("bodyClass", "home-page");
    if (request.getAttribute("categories") == null) {
        // Prevent redirect loop if the request is a forward from HomeController
        if (request.getAttribute("jakarta.servlet.forward.request_uri") == null) {
            String uri = request.getRequestURI();
            if (uri != null && !uri.contains("/home") && !uri.contains("/HomeController")) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        }
    }
%>
<jsp:include page="/common/header.jsp" />

    <section class="hero" id="hero">
        <div class="hero-slideshow" id="hero-slideshow">
            <div class="hero-slide active" style="background-image: url('https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1920&q=80');"></div>
            <div class="hero-slide" style="background-image: url('https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1920&q=80');"></div>
        </div>

        <div class="hero-content">
            <h1>Ki&#7871;n T&#7841;o Nh&#7919;ng K&#7927; Ni&#7879;m <span>&#272;&#225;ng Nh&#7899;</span></h1>
            <p>Kh&#225;m ph&#225; tour cao c&#7845;p, tr&#7843;i nghi&#7879;m v&#259;n h&#243;a &#273;&#7853;m ch&#7845;t v&#224; nh&#7919;ng &#273;i&#7875;m &#273;&#7871;n tuy&#7879;t &#273;&#7865;p kh&#7855;p Vi&#7879;t Nam &#8212; &#273;&#432;&#7907;c thi&#7871;t k&#7871; ri&#234;ng cho b&#7841;n.</p>
            <div class="hero-ctas">
                <a href="${pageContext.request.contextPath}/tourdiscovery" class="btn btn-primary" id="hero-explore-btn">Kh&#225;m Ph&#225; Tour <i data-lucide="arrow-right"></i></a>
                <a href="#promotions" class="btn btn-secondary" id="hero-book-btn">Xem &#431;u &#272;&#227;i</a>
            </div>
        </div>

        <div class="hero-indicators" id="hero-indicators">
            <div class="indicator-dot active" data-slide="0"></div>
            <div class="indicator-dot" data-slide="1"></div>
        </div>
    </section>

    <div class="container">
        <div class="search-widget-container">
            <form class="search-widget" id="search-widget-form">
                <div class="search-field">
                    <label for="search-dest"><i data-lucide="map-pin"></i> &#272;i&#7875;m &#273;&#7871;n</label>
                    <div class="search-field-input">
                        <input type="text" id="search-dest" placeholder="&#272;&#224; N&#7861;ng, Ph&#250; Qu&#7889;c, H&#7841; Long..." required>
                    </div>
                </div>
                <div class="search-field">
                    <label for="search-date"><i data-lucide="calendar"></i> Ng&#224;y kh&#7903;i h&#224;nh</label>
                    <div class="search-field-input">
                        <input type="date" id="search-date" required>
                    </div>
                </div>
                <div class="search-field">
                    <label for="search-guests"><i data-lucide="users"></i> S&#7889; kh&#225;ch</label>
                    <div class="search-field-input">
                        <select id="search-guests">
                            <option value="1">1 Kh&#225;ch</option>
                            <option value="2" selected>2 Kh&#225;ch</option>
                            <option value="3">3 Kh&#225;ch</option>
                            <option value="4">4+ Kh&#225;ch</option>
                        </select>
                    </div>
                </div>
                <div class="search-field">
                    <div class="range-slider-wrapper">
                        <label for="search-budget"><i data-lucide="wallet"></i> Ng&#226;n s&#225;ch t&#7889;i &#273;a: <span id="budget-value" class="budget-val">15.000.000 &#8363;</span></label>
                        <input type="range" id="search-budget" class="budget-slider" min="2000000" max="30000000" step="1000000" value="15000000">
                    </div>
                </div>
                <button type="submit" class="btn btn-primary btn-search" id="search-submit-btn" aria-label="T&#236;m ki&#7871;m tour">
                    <i data-lucide="search"></i>
                </button>
            </form>
        </div>

        <section class="section-padding" id="categories-section">
            <div class="categories-container" id="categories-scroll">
                <div class="category-card active" data-category="all" id="cat-all">
                    <div class="category-icon-wrapper"><i data-lucide="compass"></i></div>
                    <span>T&#7845;t C&#7843;</span>
                </div>
                <% 
                    List<TourCategory> categories = (List<TourCategory>) request.getAttribute("categories");
                    if (categories != null) {
                        for (TourCategory cat : categories) {
                            String catName = cat.getCategoryName();
                            String icon = "compass";
                            String dataCategory = "all";
                            
                            if (catName.toLowerCase().contains("bi&#7875;n")) {
                                icon = "palmtree";
                                dataCategory = "beach";
                            } else if (catName.toLowerCase().contains("n&#250;i") || catName.toLowerCase().contains("trekking") || catName.toLowerCase().contains("hiking")) {
                                icon = "mountain";
                                dataCategory = "hiking";
                            } else if (catName.toLowerCase().contains("v&#259;n h&#243;a") || catName.toLowerCase().contains("di s&#7843;n") || catName.toLowerCase().contains("cultural")) {
                                icon = "landmark";
                                dataCategory = "cultural";
                            } else if (catName.toLowerCase().contains("city") || catName.toLowerCase().contains("m&#7841;o hi&#7875;m")) {
                                icon = "map";
                                dataCategory = "adventure";
                            } else if (catName.toLowerCase().contains("mice") || catName.toLowerCase().contains("gia &#273;&#236;nh")) {
                                icon = "briefcase";
                                dataCategory = "family";
                            } else if (catName.toLowerCase().contains("cao c&#7845;p") || catName.toLowerCase().contains("luxury")) {
                                icon = "gem";
                                dataCategory = "luxury";
                            }
                %>
                <div class="category-card" data-category="<%= dataCategory %>" id="cat-<%= cat.getCategoryId() %>">
                    <div class="category-icon-wrapper"><i data-lucide="<%= icon %>"></i></div>
                    <span><%= catName %></span>
                </div>
                <% 
                        }
                    }
                %>
            </div>
        </section>

        <section class="section-padding" id="tours">
            <div class="section-header">
                <h2>Tour N&#7893;i B&#7853;t</h2>
                <p>C&#225;c h&#224;nh tr&#236;nh cao c&#7845;p &#273;&#432;&#7907;c ch&#7885;n l&#7885;c b&#7903;i &#273;&#7897;i ng&#361; chuy&#234;n gia du l&#7883;ch TourBuddy.</p>
            </div>

            <div class="tours-grid" id="tours-grid-container">
                <%
                    List<Tour> featuredTours = (List<Tour>) request.getAttribute("featuredTours");
                    if (featuredTours != null && !featuredTours.isEmpty()) {
                        for (Tour tour : featuredTours) {
                            // Map category ID to data category string
                            String catClass = "all";
                            if (tour.getCategoryId() == 1) catClass = "beach";
                            else if (tour.getCategoryId() == 2) catClass = "hiking";
                            else if (tour.getCategoryId() == 3) catClass = "cultural";
                            else if (tour.getCategoryId() == 4) catClass = "adventure";
                            else if (tour.getCategoryId() == 5) catClass = "family";
                            
                            // Determine image
                            String imgUrl = "assets/images/tour_halong.png"; // Fallback
                            if (tour.getMediaList() != null && !tour.getMediaList().isEmpty()) {
                                imgUrl = tour.getMediaList().get(0).getMediaUrl();
                            } else {
                                String dest = tour.getDestination().toLowerCase();
                                if (dest.contains("&#273;&#224; n&#7861;ng")) imgUrl = "assets/images/tour_danang.png";
                                else if (dest.contains("ph&#250; qu&#7889;c")) imgUrl = "assets/images/tour_phuquoc.png";
                                else if (dest.contains("h&#7841; long")) imgUrl = "assets/images/tour_halong.png";
                                else if (dest.contains("h&#7897;i an")) imgUrl = "assets/images/tour_hoian.png";
                                else if (dest.contains("&#273;&#224; l&#7841;t")) imgUrl = "assets/images/tour_dalat.png";
                                else if (dest.contains("sa pa") || dest.contains("sapa")) imgUrl = "assets/images/tour_sapa.png";
                                else if (dest.contains("nha trang")) imgUrl = "assets/images/tour_nhatrang.png";
                                else if (dest.contains("h&#224; giang")) imgUrl = "assets/images/tour_hagiang.png";
                            }
                            // If URL is absolute (http/https), use directly; otherwise prefix with contextPath
                            String imageUrl = (imgUrl.startsWith("http://") || imgUrl.startsWith("https://"))
                                ? imgUrl
                                : request.getContextPath() + "/" + imgUrl;
                            
                            // Remaining seats and progress
                            int availableSeats = 10;
                            int totalSeats = 20;
                            List<TourSchedule> schedules = tour.getSchedules();
                            if (schedules != null && !schedules.isEmpty()) {
                                availableSeats = schedules.get(0).getAvailableSeats();
                                totalSeats = schedules.get(0).getTotalSeats();
                            }
                            int bookedSeats = totalSeats - availableSeats;
                            int progressPercent = (totalSeats > 0) ? (bookedSeats * 100 / totalSeats) : 50;
                            String progressClass = (availableSeats <= 5) ? "danger" : "";
                            
                            // Format price
                            String formattedPrice = String.format("%,.0f", tour.getBasePrice()).replace(',', '.') + " &#8363;";
                            
                            // Badge name
                            String badgeName = "B&#225;n Ch&#7841;y";
                            if (tour.getTourId() % 3 == 0) badgeName = "&#272;&#7897;c Quy&#7873;n";
                            else if (tour.getTourId() % 3 == 2) badgeName = "Xu H&#432;&#7899;ng";
                %>
                <div class="tour-card" data-tour-category="<%= catClass %>">
                    <div class="tour-img-wrapper">
                        <img src="<%= imageUrl %>" alt="<%= tour.getTourName() %>" class="tour-img">
                        <div class="tour-badge"><span class="badge badge-featured"><%= badgeName %></span></div>
                        <%
                            List<Integer> wishlistTourIds = (List<Integer>) request.getAttribute("wishlistTourIds");
                            boolean isWishlisted = wishlistTourIds != null && wishlistTourIds.contains(tour.getTourId());
                        %>
                        <button class="btn-wishlist<%= isWishlisted ? " active" : "" %>" id="wishlist-<%= tour.getTourId() %>" aria-label="Th&#234;m v&#224;o y&#234;u th&#237;ch">
                            <i data-lucide="heart"<%= isWishlisted ? " fill=\"currentColor\"" : "" %>></i>
                        </button>
                    </div>
                    <div class="tour-details">
                        <div class="tour-meta">
                            <div class="tour-rating">
                                <i data-lucide="star"></i>
                                <span><%= tour.getRating() %> (<%= tour.getReviewsCount() %> &#273;&#225;nh gi&#225;)</span>
                            </div>
                            <div class="tour-duration">
                                <i data-lucide="clock"></i>
                                <span><%= tour.getDurationDays() %> Ng&#224;y</span>
                            </div>
                        </div>
                        <h3><%= tour.getTourName() %></h3>
                        <div class="tour-seats-progress">
                            <div class="seats-info">
                                <span>Ch&#7895; tr&#7889;ng</span>
                                <span class="seats-left <%= progressClass.equals("danger") ? "seats-left" : "" %>">
                                    <%= availableSeats > 0 ? "C&#242;n " + availableSeats + " ch&#7895;!" : "H&#7871;t ch&#7895;!" %>
                                </span>
                            </div>
                            <div class="progress-bar-bg">
                                <div class="progress-bar-fill <%= progressClass %>" style="width: <%= progressPercent %>%;"></div>
                            </div>
                        </div>
                        <div class="tour-footer">
                            <div class="tour-price">
                                <span class="price-label">Gi&#225; m&#7895;i kh&#225;ch</span>
                                <span class="price-val"><%= formattedPrice.replace(" &#8363;", "") %> <span>&#8363;</span></span>
                            </div>
                            <button class="btn btn-primary btn-sm" onclick="window.location.href='${pageContext.request.contextPath}/detail?id=<%= tour.getTourId() %>'">Xem Chi Ti&#7871;t</button>
                        </div>
                    </div>
                </div>
                <%
                        }
                    } else {
                %>
                <p>Kh&#244;ng t&#236;m th&#7845;y tour n&#7893;i b&#7853;t n&#224;o.</p>
                <%
                    }
                %>
            </div>

            <div class="view-more-container" id="view-more-tours-wrapper" style="display: none;">
                <button type="button" class="btn btn-secondary" id="btn-view-more-tours">
                    <span class="btn-label">Xem th&#234;m tour</span>
                    <span id="btn-view-more-icon"><i data-lucide="chevron-down"></i></span>
                </button>
            </div>
        </section>

        <section class="section-padding" id="destinations">
            <div class="section-header">
                <h2>&#272;i&#7875;m &#272;&#7871;n Hot Nh&#7845;t</h2>
                <p>Nh&#7919;ng &#273;&#7883;a danh &#273;&#432;&#7907;c du kh&#225;ch t&#236;m ki&#7871;m nhi&#7873;u nh&#7845;t hi&#7879;n nay.</p>
            </div>

            <div class="destinations-grid" id="destinations-grid-container">
                <% 
                    List<DestinationInfo> destinations = (List<DestinationInfo>) request.getAttribute("destinations");
                    if (destinations != null && !destinations.isEmpty()) {
                        for (int i = 0; i < destinations.size(); i++) {
                            DestinationInfo dest = destinations.get(i);
                            String contextPath = request.getContextPath();
                            String imgPath = contextPath + "/" + dest.getImageUrl();
                %>
                <div class="dest-card" onclick="window.location.href='<%= contextPath %>/tourdiscovery?dest=<%= java.net.URLEncoder.encode(dest.getName(), "UTF-8") %>'">
                    <img src="<%= imgPath %>" alt="<%= dest.getName() %>" class="dest-img">
                    <div class="dest-content">
                        <h3 class="dest-name"><%= dest.getName() %></h3>
                        <div class="dest-count"><i data-lucide="compass"></i> <%= dest.getTourCount() %> Tour</div>
                    </div>
                </div>
                <% 
                        }
                    } else {
                %>
                <p>Kh&#244;ng t&#236;m th&#7845;y &#273;i&#7875;m &#273;&#7871;n n&#7893;i b&#7853;t n&#224;o.</p>
                <% 
                    }
                %>
            </div>

            <div class="view-more-container" id="view-more-dests-wrapper" style="display: none;">
                <button type="button" class="btn btn-secondary" id="btn-view-more-dests">
                    <span class="btn-label">Xem th&#234;m &#273;i&#7875;m &#273;&#7871;n</span>
                    <span id="btn-view-more-dests-icon"><i data-lucide="chevron-down"></i></span>
                </button>
            </div>
        </section>

        <section class="section-padding" id="promotions">
            <div class="section-header">
                <h2>&#431;u &#272;&#227;i C&#243; H&#7841;n</h2>
                <p>&#272;&#7863;t tour cao c&#7845;p v&#7899;i m&#7913;c gi&#225; &#432;u &#273;&#227;i theo m&#249;a &#8212; &#273;&#7915;ng b&#7887; l&#7905;.</p>
            </div>

            <div class="promo-grid">
                <div class="promo-banner-card">
                    <div class="promo-info">
                        <span class="promo-badge-sale">Flash Sale</span>
                        <h3 class="promo-title">Gi&#7843;m 20% Tour Bi&#7875;n & Resort M&#249;a H&#232;</h3>
                        <p class="promo-desc">&#193;p d&#7909;ng cho t&#7845;t c&#7843; g&#243;i bi&#7875;n &#273;&#7843;o v&#224; ngh&#7881; d&#432;&#7905;ng &#273;&#7863;t tr&#432;&#7899;c khi h&#7871;t th&#7901;i gian &#273;&#7871;m ng&#432;&#7907;c. M&#7897;t s&#7889; tour c&#243; th&#7875; lo&#7841;i tr&#7915;.</p>

                        <div class="promo-timer" id="flash-sale-timer">
                            <div class="timer-box">
                                <span class="timer-num" id="timer-hours">08</span>
                                <span class="timer-label">Gi&#7901;</span>
                            </div>
                            <div class="timer-box">
                                <span class="timer-num" id="timer-mins">45</span>
                                <span class="timer-label">Ph&#250;t</span>
                            </div>
                            <div class="timer-box">
                                <span class="timer-num" id="timer-secs">29</span>
                                <span class="timer-label">Gi&#226;y</span>
                            </div>
                        </div>

                        <a href="#tours" class="btn btn-secondary">Nh&#7853;n &#431;u &#272;&#227;i</a>
                    </div>
                </div>

                <%
                    List<Coupon> activeCoupons = (List<Coupon>) request.getAttribute("activeCoupons");
                    String promoCode = "TOURBUDDY2026"; // Fallback
                    String promoDesc = "Gi&#7843;m th&#234;m 1.000.000&#8363; cho l&#7847;n &#273;&#7863;t tour &#273;&#7847;u ti&#234;n."; // Fallback
                    if (activeCoupons != null && !activeCoupons.isEmpty()) {
                        Coupon firstCoupon = activeCoupons.get(0);
                        promoCode = firstCoupon.getCouponCode();
                        
                        // Format discount description dynamically
                        String valStr = "";
                        if ("Percentage".equals(firstCoupon.getDiscountType())) {
                            valStr = String.format("%.0f%%", firstCoupon.getDiscountValue());
                        } else {
                            valStr = String.format("%,.0f&#273;", firstCoupon.getDiscountValue()).replace(',', '.');
                        }
                        
                        String minStr = String.format("%,.0f&#273;", firstCoupon.getMinOrderAmount()).replace(',', '.');
                        promoDesc = "Gi&#7843;m ngay " + valStr + " cho &#273;&#417;n h&#224;ng t&#7915; " + minStr + ". H&#7841;n d&#249;ng &#273;&#7871;n " + firstCoupon.getEndDate() + ".";
                    }
                %>
                <div class="promo-code-card" id="promo-card">
                    <div class="category-icon-wrapper"><i data-lucide="gift"></i></div>
                    <span class="promo-code-label">Nh&#7853;p m&#227; khi thanh to&#225;n</span>
                    <div class="promo-code-value" id="promo-coupon-code"><%= promoCode %></div>
                    <p>Nh&#7845;n &#273;&#7875; sao ch&#233;p m&#227;. <%= promoDesc %></p>
                </div>
            </div>
        </section>

        <section class="section-padding" id="testimonials">
            <div class="section-header">
                <h2>Du Kh&#225;ch N&#243;i G&#236; V&#7873; TourBuddy</h2>
                <p>Tr&#7843;i nghi&#7879;m th&#7921;c t&#7871; t&#7915; nh&#7919;ng ng&#432;&#7901;i &#273;&#227; &#273;&#7891;ng h&#224;nh c&#249;ng ch&#250;ng t&#244;i.</p>
            </div>

            <div class="testimonials-slider-container">
                <div class="testimonials-slider" id="testimonial-slider-track">
                    <%
                        List<Review> topReviews = (List<Review>) request.getAttribute("topReviews");
                        if (topReviews != null && !topReviews.isEmpty()) {
                            for (Review rev : topReviews) {
                                String avatar = rev.getCustomerAvatar();
                                if (avatar == null || avatar.trim().isEmpty()) {
                                    avatar = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=120&q=80"; // Fallback avatar
                                }
                    %>
                    <div class="testimonial-card">
                        <div class="testimonial-rating">
                            <% for (int s = 0; s < rev.getRating(); s++) { %>
                            <i data-lucide="star"></i>
                            <% } %>
                        </div>
                        <%
                             String content = rev.getContent();
                             if (content == null) {
                                 content = "";
                             } else {
                                 content = content.replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
                             }
                         %>
                        <p class="testimonial-quote">"<%= content %>"</p>
                        <div class="testimonial-author">
                            <div class="author-avatar">
                                <img src="<%= avatar %>" alt="<%= rev.getCustomerName() %>">
                            </div>
                            <div class="author-info">
                                <div class="author-name"><%= rev.getCustomerName() %></div>
                                <div class="author-role">Kh&#225;ch du l&#7883;ch th&#224;nh vi&#234;n</div>
                            </div>
                        </div>
                    </div>
                    <%
                            }
                        } else {
                    %>
                    <!-- Fallback if no reviews seeded -->
                    <div class="testimonial-card">
                        <div class="testimonial-rating">
                            <i data-lucide="star"></i><i data-lucide="star"></i><i data-lucide="star"></i><i data-lucide="star"></i><i data-lucide="star"></i>
                        </div>
                        <p class="testimonial-quote">"Tour du l&#7883;ch tuy&#7879;t v&#7901;i! D&#7883;ch v&#7909; ch&#259;m s&#243;c kh&#225;ch h&#224;ng v&#244; c&#249;ng chuy&#234;n nghi&#7879;p. Ch&#7855;c ch&#7855;n s&#7869; quay l&#7841;i c&#249;ng TourBuddy Travels."</p>
                        <div class="testimonial-author">
                            <div class="author-avatar">
                                <img src="https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=120&q=80" alt="Kh&#225;ch h&#224;ng">
                            </div>
                            <div class="author-info">
                                <div class="author-name">Kh&#225;ch h&#224;ng &#7849;n danh</div>
                                <div class="author-role">Th&#224;nh vi&#234;n TourBuddy</div>
                            </div>
                        </div>
                    </div>
                    <%
                        }
                    %>
                </div>

                <button class="btn-icon slider-btn prev" id="test-prev" aria-label="&#272;&#225;nh gi&#225; tr&#432;&#7899;c">
                    <i data-lucide="chevron-left"></i>
                </button>
                <button class="btn-icon slider-btn next" id="test-next" aria-label="&#272;&#225;nh gi&#225; sau">
                    <i data-lucide="chevron-right"></i>
                </button>

                <div class="slider-dots" id="slider-dots-container">
                    <%
                        if (topReviews != null && !topReviews.isEmpty()) {
                            for (int i = 0; i < topReviews.size(); i++) {
                    %>
                    <div class="slider-dot<%= (i == 0) ? " active" : "" %>" data-index="<%= i %>"></div>
                    <%
                            }
                        } else {
                    %>
                    <div class="slider-dot active" data-index="0"></div>
                    <%
                        }
                    %>
                </div>
            </div>
        </section>
    </div>

<% request.setAttribute("extraScript", "js/homepage.js"); %>
<jsp:include page="/common/footer.jsp" />
