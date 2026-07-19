<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ page import="java.util.List" %>
<%@ page import="Entities.Tour" %>
<%@ page import="Entities.TourCategory" %>
<%@ page import="Entities.TourSchedule" %>
<%@ page import="Entities.TourMedia" %>
<%@ page import="Entities.TourItinerary" %>
<%@ page import="Entities.TourInclusion" %>
<%@ page import="Entities.TourFAQ" %>
<%@ page import="Entities.Review" %>
<%@ page import="Entities.User" %>
<%
    // L&#221; DO V&#192; CH&#7912;C N&#224;NG C&#7910;A &#272;O&#7840;N CODE N&#192;Y:
    // - extraCss: Thu&#7897;c t&#237;nh n&#224;y &#273;&#432;&#7907;c header.jsp &#273;&#7885;c &#273;&#7875; nh&#250;ng file CSS detail.css t&#432;&#417;ng &#7913;ng (t&#7841;o giao di&#7879;n ri&#234;ng cho trang chi ti&#7871;t).
    // - activeTour: &#272;&#7889;i t&#432;&#7907;ng Tour ch&#237;nh &#273;&#432;&#7907;c Servlet DetailController.java n&#7841;p t&#7915; DB (b&#7857;ng tourDAO.getTourById(id))
    //   v&#224; &#273;&#7849;y v&#224;o request attribute &#273;&#7875; JSP n&#224;y hi&#7875;n th&#7883; th&#244;ng tin &#273;&#7897;ng.
    request.setAttribute("extraCss", "css/detail.css");
    request.setAttribute("bodyClass", "detail-page");
    Tour activeTour = (Tour) request.getAttribute("tour");
    boolean isLoggedIn = (session.getAttribute("sessionUser") != null);
    
    List<Review> tourReviews = activeTour != null ? activeTour.getReviews() : null;
    int totalReviews = (tourReviews != null) ? tourReviews.size() : 0;
    double avgRating = 0.0;
    int[] starCounts = new int[6]; // index 1 to 5
    int[] starPercentages = new int[6]; // index 1 to 5
    
    if (totalReviews > 0) {
        double sumRating = 0;
        for (Review rev : tourReviews) {
            int rating = rev.getRating();
            sumRating += rating;
            if (rating >= 1 && rating <= 5) {
                starCounts[rating]++;
            }
        }
        avgRating = sumRating / totalReviews;
        for (int i = 1; i <= 5; i++) {
            starPercentages[i] = (int) Math.round(((double) starCounts[i] / totalReviews) * 100);
        }
    }
    
    int activeSeatsLeft = 0;
    int totalSeatsAll = 0;
    if (activeTour != null) {
        // D&#432;&#417;ng: T&#7893;ng ch&#7895; tr&#7889;ng & t&#7893;ng ch&#7895; l&#7845;y t&#7915; T&#7844;T C&#7842; schedule t&#432;&#417;ng lai
        // (Tour c&#243; th&#7875; c&#243; nhi&#7873;u l&#7883;ch &#8212; ch&#7881; l&#7845;y l&#7883;ch &#273;&#7847;u ti&#234;n l&#224; sai cho hi&#7875;n th&#7883;)
        if (activeTour.getSchedules() != null) {
            for (TourSchedule s : activeTour.getSchedules()) {
                if ("Open".equalsIgnoreCase(s.getStatus())) {
                    activeSeatsLeft += s.getAvailableSeats();
                    totalSeatsAll += s.getTotalSeats();
                }
            }
        }
    }
    // D&#432;&#417;ng: Gi&#7899;i h&#7841;n s&#7889; ng&#432;&#7901;i t&#7889;i &#273;a c&#7911;a m&#7895;i &#273;o&#224;n l&#7845;y t&#7915; Tour.MaxParticipants (do admin c&#7845;u h&#236;nh khi t&#7841;o tour).
    // Fallback 10 khi DB ch&#432;a set &#273;&#7875; kh&#7899;p v&#7899;i constraint c&#361; v&#224; tr&#225;nh hi&#7875;n th&#7883; r&#7895;ng.
    int maxParticipantsPerDeparture = (activeTour != null && activeTour.getMaxParticipants() > 0)
            ? activeTour.getMaxParticipants() : 10;
%>
<!-- Nh&#250;ng header d&#249;ng chung cho to&#224;n b&#7897; website, n&#7857;m trong th&#432; m&#7909;c web/common/ -->
<jsp:include page="/common/header.jsp" />

    <!-- TOUR TITLE & HEAD SECTION -->
    <section class="tour-detail-head-section">
        <div class="container">
            <!-- Breadcrumbs -->
            <div class="breadcrumbs">
                <a href="${pageContext.request.contextPath}/home">Trang ch&#7911;</a> &gt; 
                <a href="${pageContext.request.contextPath}/tourdiscovery">Tours</a> &gt; 
                <span id="breadcrumb-active">Chi ti&#7871;t Tour</span>
            </div>

            <!-- Title & Rating info -->
            <div class="tour-head-flex">
                <div class="tour-head-left">
                    <h1 id="detail-title">&#272;ang t&#7843;i t&#234;n tour...</h1>
                    <div class="tour-meta-row">
                        <div class="tour-rating-stars">
                            <i data-lucide="star" class="star-filled"></i>
                            <strong id="detail-rating">0.0</strong> 
                            <span id="detail-reviews-count">(0 &#273;&#225;nh gi&#225;)</span>
                        </div>
                        <div class="tour-location-text">
                            <i data-lucide="map-pin"></i>
                            <span id="detail-location-name">&#272;ang t&#7843;i &#273;&#7883;a &#273;i&#7875;m...</span>
                        </div>
                        <div class="tour-badge-category">
                            <i data-lucide="tag"></i>
                            <span id="detail-category-badge">Premium</span>
                        </div>
                    </div>
                </div>
                <!-- Action sharing / wishlist buttons -->
                <div class="tour-head-actions">
                    <button class="btn btn-secondary btn-icon-text" id="share-btn">
                        <i data-lucide="share-2"></i> Chia s&#7867;
                    </button>
                    <%
                        List<Integer> wishlistTourIds = (List<Integer>) request.getAttribute("wishlistTourIds");
                        boolean isWishlisted = activeTour != null && wishlistTourIds != null && wishlistTourIds.contains(activeTour.getTourId());
                    %>
                    <button class="btn btn-secondary btn-icon-text btn-wishlist-detail <%= isWishlisted ? "active" : "" %>" id="wishlist-detail-btn" data-tour-id="<%= activeTour != null ? activeTour.getTourId() : "" %>">
                        <% if (isWishlisted) { %>
                            <i data-lucide="heart" fill="currentColor"></i> &#272;&#227; l&#432;u Y&#234;u th&#237;ch
                        <% } else { %>
                            <i data-lucide="heart"></i> L&#432;u v&#224;o Y&#234;u th&#237;ch
                        <% } %>
                    </button>
                </div>
            </div>
        </div>
    </section>

    <!-- MASONRY IMAGE GALLERY -->
    <section class="tour-gallery-section">
        <div class="container">
            <div class="masonry-gallery" id="photo-gallery-grid">
                <%
                    String mainImgUrl = "assets/images/tour_halong.png";
                    if (activeTour != null && activeTour.getMediaList() != null && !activeTour.getMediaList().isEmpty()) {
                        mainImgUrl = activeTour.getMediaList().get(0).getMediaUrl();
                    } else if (activeTour != null) {
                        String dest = activeTour.getDestination().toLowerCase();
                        if (dest.contains("&#273;&#224; n&#7861;ng")) mainImgUrl = "assets/images/tour_danang.png";
                        else if (dest.contains("ph&#250; qu&#7889;c")) mainImgUrl = "assets/images/tour_phuquoc.png";
                        else if (dest.contains("h&#7841; long")) mainImgUrl = "assets/images/tour_halong.png";
                        else if (dest.contains("h&#7897;i an")) mainImgUrl = "assets/images/tour_hoian.png";
                        else if (dest.contains("&#273;&#224; l&#7841;t")) mainImgUrl = "assets/images/tour_dalat.png";
                        else if (dest.contains("sa pa") || dest.contains("sapa")) mainImgUrl = "assets/images/tour_sapa.png";
                        else if (dest.contains("nha trang")) mainImgUrl = "assets/images/tour_nhatrang.png";
                        else if (dest.contains("h&#224; giang")) mainImgUrl = "assets/images/tour_hagiang.png";
                    }

                    // Construct gallery images list
                    List<TourMedia> mediaList = activeTour != null ? activeTour.getMediaList() : null;
                    java.util.List<String> galleryImages = new java.util.ArrayList<>();
                    if (mediaList != null && !mediaList.isEmpty()) {
                        for (TourMedia m : mediaList) {
                            String mUrl = m.getMediaUrl();
                            if (!mUrl.startsWith("http") && !mUrl.startsWith("/")) {
                                mUrl = request.getContextPath() + "/" + mUrl;
                            }
                            galleryImages.add(mUrl);
                        }
                    }
                    if (galleryImages.isEmpty() && activeTour != null) {
                        galleryImages.add(request.getContextPath() + "/" + mainImgUrl);
                    }

                    // Pad up to 5 images using the main image to avoid displaying unrelated tours
                    String resolvedMainImg = mainImgUrl;
                    if (!resolvedMainImg.startsWith("http") && !resolvedMainImg.startsWith("/")) {
                        resolvedMainImg = request.getContextPath() + "/" + resolvedMainImg;
                    }
                    while (galleryImages.size() < 5) {
                        galleryImages.add(resolvedMainImg);
                    }
                %>
                <div class="gallery-item main-photo">
                    <img src="<%= galleryImages.get(0) %>" alt="Tour ch&#237;nh" id="gallery-main-img">
                </div>
                <!-- Sub photos (Right grid) -->
                <div class="gallery-item sub-photo sub-1">
                    <img src="<%= galleryImages.get(1) %>" alt="&#7842;nh ph&#7909; 1" class="gallery-thumb" data-index="1">
                </div>
                <div class="gallery-item sub-photo sub-2">
                    <img src="<%= galleryImages.get(2) %>" alt="&#7842;nh ph&#7909; 2" class="gallery-thumb" data-index="2">
                </div>
                <div class="gallery-item sub-photo sub-3">
                    <img src="<%= galleryImages.get(3) %>" alt="&#7842;nh ph&#7909; 3" class="gallery-thumb" data-index="3">
                </div>
                <div class="gallery-item sub-photo sub-4">
                    <img src="<%= galleryImages.get(4) %>" alt="&#7842;nh ph&#7909; 4" class="gallery-thumb" data-index="4">
                    <button class="btn-all-photos" id="view-all-photos-btn">
                        <i data-lucide="grid"></i> Xem T&#7845;t C&#7843; &#7842;nh
                    </button>
                </div>
            </div>
        </div>
    </section>

    <!-- MAIN DETAIL COLUMN LAYOUT -->
    <main class="tour-detail-container">
        <div class="container detail-grid-layout">
            
            <!-- LEFT MAIN DETAILS AREA (65%) -->
            <div class="detail-main-left">
                
                <!-- Quick Highlights Info Widget -->
                <div class="tour-highlights-widget">
                    <div class="highlight-item">
                        <div class="icon-wrapper"><i data-lucide="clock"></i></div>
                        <div class="item-text">
                            <span class="label">Th&#7901;i l&#432;&#7907;ng</span>
                            <strong id="hl-duration">&#272;ang t&#7843;i...</strong>
                        </div>
                    </div>
                    <div class="highlight-item">
                        <div class="icon-wrapper"><i data-lucide="users"></i></div>
                        <div class="item-text">
                            <span class="label">Gi&#7899;i h&#7841;n &#273;o&#224;n</span>
                            <strong id="hl-group-size" title="S&#7889; ng&#432;&#7901;i t&#7889;i &#273;a cho m&#7895;i &#273;o&#224;n kh&#7903;i h&#224;nh &#8212; do Admin c&#7845;u h&#236;nh khi t&#7841;o tour">T&#7889;i &#273;a <%= maxParticipantsPerDeparture %> kh&#225;ch/&#273;o&#224;n</strong>
                        </div>
                    </div>
                    <div class="highlight-item">
                        <div class="icon-wrapper"><i data-lucide="ticket"></i></div>
                        <div class="item-text">
                            <span class="label">Ch&#7895; tr&#7889;ng (t&#7845;t c&#7843; l&#7883;ch)</span>
                            <strong id="hl-seats-left"><%= activeSeatsLeft %> Ch&#7895;</strong>
                        </div>
                    </div>
                    <div class="highlight-item">
                        <div class="icon-wrapper"><i data-lucide="languages"></i></div>
                        <div class="item-text">
                            <span class="label">Ng&#244;n ng&#7919;</span>
                            <strong id="hl-languages">Ti&#7871;ng Vi&#7879;t / Anh</strong>
                        </div>
                    </div>
                    <div class="highlight-item">
                        <div class="icon-wrapper"><i data-lucide="activity"></i></div>
                        <div class="item-text">
                            <span class="label">M&#7913;c &#273;&#7897; v&#7853;n &#273;&#7897;ng</span>
                            <strong id="hl-difficulty">&#272;ang t&#7843;i...</strong>
                        </div>
                    </div>
                </div>


                <!-- Tour Description -->
                <div class="tour-description-section">
                    <h3>Gi&#7899;i Thi&#7879;u H&#224;nh Tr&#236;nh</h3>
                    <p id="tour-detail-desc">&#272;ang t&#7843;i n&#7897;i dung h&#224;nh tr&#236;nh...</p>
                </div>

                <!-- Itinerary Timeline Section -->
                <div class="tour-itinerary-section">
                    <h3>Chi Ti&#7871;t L&#7883;ch Tr&#236;nh T&#7915;ng Ng&#224;y</h3>
                    <p class="itinerary-intro">Xem l&#7883;ch tr&#236;nh chi ti&#7871;t v&#224; h&#7845;p d&#7851;n &#273;&#432;&#7907;c thi&#7871;t k&#7871; chuy&#234;n nghi&#7879;p c&#7911;a ch&#250;ng t&#244;i.</p>
                    
                    <div class="itinerary-timeline" id="itinerary-timeline-container">
                        <!-- Populated dynamically via detail.js -->
                    </div>
                </div>

                <!-- Included / Excluded Services Card -->
                <!-- L&#221; DO V&#192; CH&#7912;C N&#224;NG C&#7910;A &#272;O&#7840;N N&#192;Y:
                     - Gi&#250;p ng&#432;&#7901;i d&#249;ng bi&#7871;t tour bao g&#7891;m nh&#7919;ng ti&#7879;n &#237;ch g&#236; (INCLUDED) v&#224; nh&#7919;ng g&#236; h&#7885; ph&#7843;i t&#7921; tr&#7843; chi ph&#237; (EXCLUDED).
                     - T&#7843;i &#273;&#7897;ng t&#7915; b&#7843;ng TourInclusion th&#244;ng qua tour.getInclusions().
                     - Ph&#226;n t&#225;ch l&#224;m hai c&#7897;t tr&#225;i v&#224; ph&#7843;i. N&#7871;u DB ch&#432;a c&#243; d&#7919; li&#7879;u, s&#7869; hi&#7875;n th&#7883; danh s&#225;ch t&#297;nh m&#7863;c &#273;&#7883;nh &#273;&#7875; gi&#7919; UI &#273;&#7865;p. -->
                <div class="tour-services-card">
                    <h3>D&#7883;ch V&#7909; Bao G&#7891;m & Lo&#7841;i Tr&#7915;</h3>
                    <div class="services-split-grid">
                        <div class="services-column included">
                            <h4><i data-lucide="check-circle" class="icon-included"></i> D&#7883;ch v&#7909; bao g&#7891;m</h4>
                            <ul class="services-list">
                                <%
                                    // L&#7845;y danh s&#225;ch d&#7883;ch v&#7909; &#273;i k&#232;m
                                    List<TourInclusion> inclusions = activeTour.getInclusions();
                                    boolean hasIncluded = false;
                                    
                                    // Duy&#7879;t danh s&#225;ch, l&#7885;c d&#7883;ch v&#7909; bao g&#7891;m (INCLUDED)
                                    if (inclusions != null) {
                                        for (TourInclusion inc : inclusions) {
                                            if ("INCLUDED".equalsIgnoreCase(inc.getInclusionType())) {
                                                hasIncluded = true;
                                                String iconName = (inc.getIconName() != null && !inc.getIconName().trim().isEmpty()) ? inc.getIconName() : "sparkles";
                                %>
                                <li><i data-lucide="<%= iconName %>"></i> <%= inc.getServiceName() %></li>
                                <%
                                            }
                                        }
                                    }
                                    
                                    // Kh&#244;ng c&#243; d&#7919; li&#7879;u t&#7915; DB &#8594; hi&#7879;n th&#244;ng b&#225;o tr&#7889;ng
                                    if (!hasIncluded) {
                                %>
                                <li style="color: var(--slate-400); font-style: italic;"><i data-lucide="info"></i> Ch&#432;a c&#243; th&#244;ng tin d&#7883;ch v&#7909; bao g&#7891;m.</li>
                                <%
                                    }
                                %>
                            </ul>
                        </div>
                        <div class="services-column excluded">
                            <h4><i data-lucide="x-circle" class="icon-excluded"></i> D&#7883;ch v&#7909; kh&#244;ng bao g&#7891;m</h4>
                            <ul class="services-list">
                                <%
                                    boolean hasExcluded = false;
                                    // Duy&#7879;t danh s&#225;ch, l&#7885;c d&#7883;ch v&#7909; lo&#7841;i tr&#7915; (EXCLUDED)
                                    if (inclusions != null) {
                                        for (TourInclusion inc : inclusions) {
                                            if ("EXCLUDED".equalsIgnoreCase(inc.getInclusionType())) {
                                                hasExcluded = true;
                                                String iconName = (inc.getIconName() != null && !inc.getIconName().trim().isEmpty()) ? inc.getIconName() : "x-circle";
                                %>
                                <li><i data-lucide="<%= iconName %>"></i> <%= inc.getServiceName() %></li>
                                <%
                                            }
                                        }
                                    }
                                    
                                    // Kh&#244;ng c&#243; d&#7919; li&#7879;u t&#7915; DB &#8594; hi&#7879;n th&#244;ng b&#225;o tr&#7889;ng
                                    if (!hasExcluded) {
                                %>
                                <li style="color: var(--slate-400); font-style: italic;"><i data-lucide="info"></i> Ch&#432;a c&#243; th&#244;ng tin d&#7883;ch v&#7909; kh&#244;ng bao g&#7891;m.</li>
                                <%
                                    }
                                %>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- Reviews & Ratings Section -->
                <div class="tour-reviews-section" id="reviews">
                    <h3>&#272;&#225;nh Gi&#225; Th&#7921;c T&#7871; T&#7915; Du Kh&#225;ch</h3>
                    
                    <div class="reviews-scorecard">
                        <div class="scorecard-left">
                            <span class="big-score" id="scorecard-avg"><%= String.format(java.util.Locale.US, "%.1f", avgRating) %></span>
                            <div class="stars-row">
                                <%
                                    int fullStars = (int) Math.round(avgRating);
                                    for (int i = 1; i <= 5; i++) {
                                %>
                                <i data-lucide="star" class="<%= (i <= fullStars) ? "star-filled" : "" %>"></i>
                                <%
                                    }
                                %>
                            </div>
                            <span class="reviews-count-label" id="scorecard-total">D&#7921;a tr&#234;n <%= totalReviews %> &#273;&#225;nh gi&#225;</span>
                        </div>
                        <div class="scorecard-right">
                            <%
                                for (int star = 5; star >= 1; star--) {
                                    int percent = starPercentages[star];
                            %>
                            <div class="rating-bar-item" data-star="<%= star %>">
                                <span><%= star %> &#9733;</span>
                                <div class="rating-bar-bg"><div class="rating-bar-fill" style="width: <%= percent %>%;"></div></div>
                                <span class="rating-percent"><%= percent %>%</span>
                            </div>
                            <%
                                }
                            %>
                        </div>
                    </div>

                    <div class="reviews-list-container" id="reviews-list-container">
                        <%
                            if (tourReviews != null && !tourReviews.isEmpty()) {
                                for (Review rev : tourReviews) {
                                    String avatar = rev.getCustomerAvatar();
                                    if (avatar == null || avatar.trim().isEmpty()) {
                                        avatar = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80"; // Fallback avatar
                                    }
                                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                                    String dateStr = sdf.format(rev.getCreatedAt());
                                    
                                    String content = rev.getContent();
                                    if (content == null) {
                                        content = "";
                                    } else {
                                        content = content.replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
                                    }
                        %>
                        <div class="review-comment-card">
                            <div class="review-comment-header">
                                <div class="reviewer-info">
                                    <img src="<%= avatar %>" alt="<%= rev.getCustomerName() %>" class="reviewer-avatar">
                                    <div class="reviewer-meta">
                                        <span class="reviewer-name"><%= rev.getCustomerName() %></span>
                                        <span class="reviewer-date">&#272;&#259;ng ng&#224;y: <%= dateStr %></span>
                                        <button class="btn-report-review" data-id="<%= rev.getReviewId() %>" style="background:none; border:none; color:#ea580c; cursor:pointer; font-size:0.75rem; margin-top:4px; display:inline-flex; align-items:center; gap:4px; padding:0; outline:none;"><i class="fa-solid fa-flag"></i> B&#225;o c&#225;o vi ph&#7841;m</button>
                                    </div>
                                </div>
                                <div class="reviewer-actions">
                                    <div class="reviewer-stars-row">
                                        <% for (int s = 1; s <= 5; s++) { %>
                                        <i data-lucide="star" class="<%= (s <= rev.getRating()) ? "star-filled" : "" %>"></i>
                                        <% } %>
                                    </div>
                                    <% if (rev.isIsVerified()) { %>
                                    <div class="verified-badge">
                                        <i data-lucide="shield-check"></i>
                                        <span>&#272;&#227; tr&#7843;i nghi&#7879;m</span>
                                    </div>
                                    <% } %>
                                </div>
                            </div>
                            <div class="review-comment-body">
                                <p><%= content %></p>
                            </div>
                        </div>
                        <%
                                }
                            } else {
                        %>
                        <div class="no-reviews-message" style="text-align: center; padding: 40px; color: var(--text-light); width: 100%;">
                            <i data-lucide="message-square" style="width: 48px; height: 48px; margin-bottom: 12px; color: var(--border-color); display: block; margin-left: auto; margin-right: auto;"></i>
                            <p>Ch&#432;a c&#243; &#273;&#225;nh gi&#225; n&#224;o cho h&#224;nh tr&#236;nh n&#224;y. H&#227;y l&#224; ng&#432;&#7901;i &#273;&#7847;u ti&#234;n chia s&#7867; c&#7843;m nh&#7853;n!</p>
                        </div>
                        <%
                            }
                        %>
                    </div>

                    <!-- BI&#7874;U M&#7850;U &#272;&#224;NG K&#221; B&#204;NH LU&#7852;N / &#272;&#193;NH GI&#193; (ADD REVIEW FORM)
                         L&#253; do t&#7841;i sao l&#7841;i ph&#7843;i l&#224;m nh&#432; v&#7853;y:
                         - Cho ph&#233;p kh&#225;ch h&#224;ng chia s&#7867; c&#7843;m nh&#7853;n, b&#236;nh ch&#7885;n s&#7889; sao th&#7921;c t&#7871; t&#7915; 1-5.
                         - Form post d&#7919; li&#7879;u tr&#7921;c ti&#7871;p l&#234;n DetailController (/detail) th&#244;ng qua ph&#432;&#417;ng th&#7913;c POST.
                         - S&#7917; d&#7909;ng 2 hidden input &#273;&#7875; truy&#7873;n tourId (x&#225;c &#273;&#7883;nh tour &#273;&#432;&#7907;c review) v&#224; rating (sao).
                         - T&#234;n c&#225;c th&#7867; input (name="name", name="email", name="content") tr&#249;ng kh&#7899;p v&#7899;i tham s&#7889;
                           Servlet &#273;&#7885;c b&#7857;ng request.getParameter(). -->
                    <div class="add-review-card">
                        <h4>Chia S&#7867; Tr&#7843;i Nghi&#7879;m C&#7911;a B&#7841;n</h4>
                        <% 
                            String reviewError = (String) session.getAttribute("reviewError");
                            String reviewSuccess = (String) session.getAttribute("reviewSuccess");
                            if (reviewError != null) {
                                session.removeAttribute("reviewError");
                        %>
                            <div style="background: #fee2e2; border: 1px solid #fecaca; color: #ef4444; padding: 12px; border-radius: 8px; margin-bottom: 16px; font-weight: 500; font-family: 'Inter', sans-serif;">
                                <i class="fa-solid fa-triangle-exclamation"></i> <%= reviewError %>
                            </div>
                        <% 
                            }
                            if (reviewSuccess != null) {
                                session.removeAttribute("reviewSuccess");
                        %>
                            <div style="background: #d1fae5; border: 1px solid #a7f3d0; color: #065f46; padding: 12px; border-radius: 8px; margin-bottom: 16px; font-weight: 500; font-family: 'Inter', sans-serif;">
                                <i class="fa-solid fa-circle-check"></i> <%= reviewSuccess %>
                            </div>
                        <% 
                            }
                        %>
                        <% 
                            isLoggedIn = (session.getAttribute("sessionUser") != null);
                            User currentUser = isLoggedIn ? (User) session.getAttribute("sessionUser") : null;
                            if (isLoggedIn && currentUser != null) {
                        %>
                            <p>&#221; ki&#7871;n c&#7911;a b&#7841;n gi&#250;p c&#7897;ng &#273;&#7891;ng du l&#7883;ch c&#243; th&#234;m nh&#7919;ng quy&#7871;t &#273;&#7883;nh &#273;&#250;ng &#273;&#7855;n.</p>
                            
                            <form class="add-review-form" id="new-review-form" action="${pageContext.request.contextPath}/detail" method="POST" enctype="multipart/form-data">
                                <!-- L&#432;u ID c&#7911;a Tour &#273;&#7875; Controller bi&#7871;t c&#7847;n g&#225;n review n&#224;y cho tour n&#224;o -->
                                <input type="hidden" name="tourId" value="<%= activeTour != null ? activeTour.getTourId() : 1 %>">
                                <!-- L&#432;u s&#7889; sao &#273;&#225;nh gi&#225; (s&#7869; &#273;&#432;&#7907;c c&#7853;p nh&#7853;t b&#7857;ng JS khi ng&#432;&#7901;i d&#249;ng click v&#224;o c&#225;c ng&#244;i sao b&#234;n d&#432;&#7899;i) -->
                                <input type="hidden" name="rating" id="review-rating-input" value="5">
                                
                                <div class="form-rating-selector">
                                    <span>&#272;&#225;nh gi&#225; c&#7911;a b&#7841;n:</span>
                                    <div class="stars-selector-row" id="stars-selector">
                                        <span class="star-select" data-rating="1"><i data-lucide="star"></i></span>
                                        <span class="star-select" data-rating="2"><i data-lucide="star"></i></span>
                                        <span class="star-select" data-rating="3"><i data-lucide="star"></i></span>
                                        <span class="star-select" data-rating="4"><i data-lucide="star"></i></span>
                                        <span class="star-select" data-rating="5"><i data-lucide="star"></i></span>
                                    </div>
                                </div>
                                
                                <div class="form-grid">
                                    <div class="form-group">
                                        <label for="rev-name">H&#7885; & T&#234;n *</label>
                                        <input type="text" id="rev-name" name="name" value="<%= currentUser.getFullName() %>" readonly style="background-color: var(--slate-100); cursor: not-allowed;" required>
                                    </div>
                                    <div class="form-group">
                                        <label for="rev-email">Email (S&#7869; &#273;&#432;&#7907;c &#7849;n) *</label>
                                        <input type="email" id="rev-email" name="email" value="<%= currentUser.getEmail() %>" readonly style="background-color: var(--slate-100); cursor: not-allowed;" required>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="rev-text">B&#236;nh lu&#7853;n chi ti&#7871;t *</label>
                                    <textarea id="rev-text" name="content" rows="4" placeholder="Chia s&#7867; v&#7873; l&#7883;ch tr&#236;nh, d&#7883;ch v&#7909; &#259;n u&#7889;ng, h&#432;&#7899;ng d&#7851;n vi&#234;n v&#224; ph&#432;&#417;ng ti&#7879;n di chuy&#7875;n..." required></textarea>
                                </div>

                                <div class="form-group">
                                    <label>T&#7843;i l&#234;n h&#236;nh &#7843;nh chuy&#7871;n &#273;i</label>
                                    <div class="upload-simulator-btn" id="upload-sim-btn">
                                        <i data-lucide="camera"></i>
                                        <span>Ch&#7885;n h&#236;nh &#7843;nh t&#7915; thi&#7871;t b&#7883; c&#7911;a b&#7841;n</span>
                                    </div>
                                    <input type="file" id="review-image-input" name="reviewImage" accept="image/*" style="display: none;">
                                    <div class="uploaded-images-preview" id="uploaded-images-preview-row"></div>
                                </div>

                                <button type="submit" class="btn btn-primary">G&#7917;i &#272;&#225;nh Gi&#225;</button>
                            </form>
                        <% } else { %>
                            <div class="login-to-review-wrapper" style="text-align: center; padding: 2rem 1rem;">
                                <i data-lucide="message-square" style="width: 3rem; height: 3rem; color: var(--slate-400); margin-bottom: 1rem; display: block; margin-left: auto; margin-right: auto;"></i>
                                <p style="margin-bottom: 1.5rem; color: var(--slate-600);">Vui l&#242;ng &#273;&#259;ng nh&#7853;p t&#224;i kho&#7843;n &#273;&#7875; g&#7917;i &#273;&#225;nh gi&#225; v&#224; chia s&#7867; tr&#7843;i nghi&#7879;m chuy&#7871;n &#273;i c&#7911;a b&#7841;n.</p>
                                <a href="${pageContext.request.contextPath}/login" class="btn btn-primary" style="display: inline-flex; align-items: center; gap: 0.5rem; padding: 0.75rem 1.5rem; border-radius: 8px;">
                                    <i data-lucide="log-in" style="width: 1.25rem; height: 1.25rem;"></i> &#272;&#259;ng Nh&#7853;p &#272;&#7875; &#272;&#225;nh Gi&#225;
                                </a>
                            </div>
                        <% } %>
                    </div>
                </div>

                <!-- PH&#194;N H&#7878; C&#194;U H&#7886;I TH&#431;&#7900;NG G&#7862;P (FAQ SECTION)
                     L&#253; do c&#7847;n thi&#7871;t k&#7871; nh&#432; th&#7871; n&#224;y:
                     - Gi&#250;p hi&#7875;n th&#7883; b&#7897; FAQs &#273;&#432;&#7907;c qu&#7843;n l&#253; n&#259;ng &#273;&#7897;ng trong c&#417; s&#7903; d&#7919; li&#7879;u.
                     - S&#7917; d&#7909;ng v&#242;ng l&#7863;p Java Scriplet &#273;&#7875; &#273;&#7885;c danh s&#225;ch List<TourFAQ> t&#7915; thu&#7897;c t&#237;nh faqs c&#7911;a activeTour.
                     - N&#7871;u DB ch&#432;a &#273;&#432;&#7907;c c&#7845;u h&#236;nh c&#226;u h&#7887;i cho tour n&#224;y, hi&#7875;n th&#7883; 3 c&#226;u h&#7887;i m&#7863;c &#273;&#7883;nh l&#224;m d&#7921; ph&#242;ng (fallback) &#273;&#7875; giao di&#7879;n kh&#244;ng b&#7883; tr&#7889;ng. -->
                <div class="tour-faq-section">
                    <h3>Nh&#7919;ng C&#226;u H&#7887;i Th&#432;&#7901;ng G&#7863;p</h3>
                    
                    <div class="faq-accordion-wrapper">
                        <%
                            List<TourFAQ> faqs = activeTour != null ? activeTour.getFaqs() : null;
                            boolean hasFaqs = false;
                            
                            // Duy&#7879;t qua danh s&#225;ch FAQs v&#224; xu&#7845;t m&#227; HTML &#273;&#7897;ng
                            if (faqs != null && !faqs.isEmpty()) {
                                for (TourFAQ faq : faqs) {
                                    hasFaqs = true;
                        %>
                        <div class="faq-item">
                            <div class="faq-question">
                                <h4><%= faq.getQuestion() %></h4>
                                <i data-lucide="chevron-down" class="faq-arrow"></i>
                            </div>
                            <div class="faq-answer">
                                <p><%= faq.getAnswer() %></p>
                            </div>
                        </div>
                        <%
                                }
                            }
                            
                            // Ph&#7847;n hi&#7875;n th&#7883; fallback n&#7871;u DB tr&#7889;ng
                            if (!hasFaqs) {
                        %>
                        <div class="faq-item">
                            <div class="faq-question">
                                <h4>Ch&#237;nh s&#225;ch h&#7911;y tour du l&#7883;ch c&#7911;a TourBuddy nh&#432; th&#7871; n&#224;o?</h4>
                                <i data-lucide="chevron-down" class="faq-arrow"></i>
                            </div>
                            <div class="faq-answer">
                                <p>B&#7841;n s&#7869; &#273;&#432;&#7907;c ho&#224;n ti&#7873;n 100% n&#7871;u h&#7911;y tour tr&#432;&#7899;c 7 ng&#224;y k&#7875; t&#7915; ng&#224;y kh&#7903;i h&#224;nh d&#7921; ki&#7871;n. Ho&#224;n ti&#7873;n 50% n&#7871;u h&#7911;y tr&#432;&#7899;c t&#7915; 3-6 ng&#224;y. H&#7911;y tour trong v&#242;ng 48 gi&#7901; tr&#432;&#7899;c gi&#7901; &#273;i s&#7869; kh&#244;ng &#273;&#432;&#7907;c ho&#224;n tr&#7843; chi ph&#237; theo quy &#273;&#7883;nh chung.</p>
                            </div>
                        </div>

                        <div class="faq-item">
                            <div class="faq-question">
                                <h4>T&#244;i c&#7847;n chu&#7849;n b&#7883; nh&#7919;ng h&#224;nh l&#253; c&#225; nh&#226;n g&#236; khi &#273;i tour leo n&#250;i/trekking?</h4>
                                <i data-lucide="chevron-down" class="faq-arrow"></i>
                            </div>
                            <div class="faq-answer">
                                <p>&#272;&#7889;i v&#7899;i c&#225;c tour v&#7853;n &#273;&#7897;ng trung b&#236;nh tr&#7903; l&#234;n (&#272;&#224; L&#7841;t, Sa Pa, H&#224; Giang), b&#7841;n n&#234;n mang theo gi&#224;y trekking chuy&#234;n d&#7909;ng c&#243; &#273;&#7897; b&#225;m cao, qu&#7847;n &#225;o ch&#7889;ng gi&#243; th&#7845;m h&#250;t m&#7891; h&#244;i t&#7889;t, m&#7897;t chai n&#432;&#7899;c c&#225; nh&#226;n, kem ch&#7889;ng n&#7855;ng, thu&#7889;c l&#225; c&#244;n tr&#249;ng v&#224; s&#7841;c d&#7921; ph&#242;ng.</p>
                            </div>
                        </div>

                        <div class="faq-item">
                            <div class="faq-question">
                                <h4>Tr&#7867; em c&#243; th&#7875; tham gia c&#225;c g&#243;i tour n&#224;y kh&#244;ng?</h4>
                                <i data-lucide="chevron-down" class="faq-arrow"></i>
                            </div>
                            <div class="faq-answer">
                                <p>Tr&#7867; em t&#7915; 5 tu&#7893;i tr&#7903; l&#234;n c&#243; th&#7875; tham gia h&#7847;u h&#7871;t c&#225;c tour v&#259;n h&#243;a/bi&#7875;n &#273;&#7843;o. V&#7899;i c&#225;c tour th&#225;m hi&#7875;m v&#7853;n &#273;&#7897;ng m&#7841;nh (Fansipan trekking, H&#224; Giang), tr&#7867; em t&#7915; 12 tu&#7893;i tr&#7903; l&#234;n v&#224; c&#243; th&#7875; l&#7921;c t&#7889;t m&#7899;i &#273;&#432;&#7907;c khuy&#7871;n c&#225;o tham gia.</p>
                            </div>
                        </div>
                        <%
                            }
                        %>
                    </div>
                </div>

            </div>

            <!-- RIGHT STICKY BOOKING SIDEBAR (35%) -->
            <div class="detail-main-right">
                <div class="sticky-booking-sidebar" id="booking-sidebar">
                    <div class="booking-sidebar-card">

                        <!-- Hidden inputs to prevent detail.js script failures -->
                        <input type="hidden" id="book-date" value="">
                        <input type="hidden" id="book-travelers" value="1">

                        <div class="payment-section-box" style="margin-top: 0;">
                            <div class="payment-trust-badge">
                                <span class="trust-dot"></span>
                                <span>C&#7893;ng &#273;&#259;ng k&#253; tr&#7921;c tuy&#7871;n ch&#237;nh th&#7913;c</span>
                            </div>
                            <button type="button" class="btn btn-primary btn-payment-cta" id="go-payment-btn"
                                    onclick="if (<%= isLoggedIn %>) { window.location.href='${pageContext.request.contextPath}/customer/booking/create?tourId=<%= activeTour != null ? activeTour.getTourId() : 1 %>' } else { alert('Vui l&#242;ng &#273;&#259;ng nh&#7853;p &#273;&#7875; th&#7921;c hi&#7879;n &#273;&#7863;t tour!'); window.location.href='${pageContext.request.contextPath}/login'; }">
                                <span class="btn-payment-text">
                                    <i data-lucide="compass"></i>
                                    &#272;&#259;ng k&#253; tham gia ngay
                                </span>
                                <i data-lucide="arrow-right" class="btn-payment-arrow"></i>
                            </button>
                            <div class="payment-trust-footer">
                                <span class="trust-item"><i data-lucide="shield-check"></i> An to&#224;n</span>
                                <span class="trust-divider">&#8226;</span>
                                <span class="trust-item"><i data-lucide="zap"></i> Nhanh ch&#243;ng</span>
                                <span class="trust-divider">&#8226;</span>
                                <span class="trust-item"><i data-lucide="lock"></i> B&#7843;o m&#7853;t</span>
                            </div>
                        </div>

                    </div>
                </div>
            </div>

        </div>
    </main>

    <!-- RELATED TOURS RECOMMENDATION SECTION -->
    <section class="section-padding related-tours-outer-section">
        <div class="container">
            <div class="section-header" style="text-align: left; margin-left: 0; margin-bottom: 2.5rem;">
                <h2>H&#224;nh Tr&#236;nh T&#432;&#417;ng T&#7921; B&#7841;n S&#7869; Th&#237;ch</h2>
                <p style="margin-left: 0; margin-right: auto;">Kh&#225;m ph&#225; th&#234;m c&#225;c &#273;&#7883;a danh du l&#7883;ch k&#7923; th&#250; c&#243; th&#7875; b&#7841;n s&#7869; mu&#7889;n th&#234;m v&#224;o danh s&#225;ch ti&#7871;p theo.</p>
            </div>
            
            <div class="tours-grid" id="related-tours-grid-container">
                <!-- Dynamically loaded related tours -->
            </div>
        </div>
    </section>

    <!-- FULLSCREEN LIGHTBOX PHOTO VIEW OVERLAY -->
    <div class="lightbox-overlay" id="gallery-lightbox">
        <span class="lightbox-close" id="lightbox-close-btn">&times;</span>
        <button class="lightbox-nav-btn lightbox-prev" id="lightbox-prev-btn"><i data-lucide="chevron-left"></i></button>
        <div class="lightbox-content-wrapper">
            <img src="" alt="&#7842;nh ph&#243;ng to" id="lightbox-expanded-img">
        </div>
        <button class="lightbox-nav-btn lightbox-next" id="lightbox-next-btn"><i data-lucide="chevron-right"></i></button>
        <div class="lightbox-caption" id="lightbox-caption-txt">&#7842;nh tr&#236;nh chi&#7871;u</div>
    </div>

<script>
    window.activeTourId = <%= activeTour != null ? activeTour.getTourId() : 1 %>;
    window.toursData = [
        <% 
        List<Tour> tours = (List<Tour>) request.getAttribute("tours");
        if (tours != null) {
            for (int i = 0; i < tours.size(); i++) {
                Tour t = tours.get(i);
                
                // Determine image
                String imgUrl = "assets/images/tour_halong.png"; // Fallback
                if (t.getMediaList() != null && !t.getMediaList().isEmpty()) {
                    imgUrl = t.getMediaList().get(0).getMediaUrl();
                } else {
                    String dest = t.getDestination().toLowerCase();
                    if (dest.contains("\u0111\u00e0 n\u1eb5ng")) imgUrl = "assets/images/tour_danang.png";
                    else if (dest.contains("ph\u00fa qu\u1ed1c")) imgUrl = "assets/images/tour_phuquoc.png";
                    else if (dest.contains("h\u1ea1 long")) imgUrl = "assets/images/tour_halong.png";
                    else if (dest.contains("h\u1ed9i an")) imgUrl = "assets/images/tour_hoian.png";
                    else if (dest.contains("\u0111\u00e0 l\u1ea1t")) imgUrl = "assets/images/tour_dalat.png";
                    else if (dest.contains("sa pa") || dest.contains("sapa")) imgUrl = "assets/images/tour_sapa.png";
                    else if (dest.contains("nha trang")) imgUrl = "assets/images/tour_nhatrang.png";
                    else if (dest.contains("h\u00e0 giang")) imgUrl = "assets/images/tour_hagiang.png";
                }
                
                // Map category
                String catStr = "luxury";
                if (t.getCategoryId() == 1) catStr = "beach";
                else if (t.getCategoryId() == 2) catStr = "hiking";
                else if (t.getCategoryId() == 3) catStr = "cultural";
                else if (t.getCategoryId() == 4) catStr = "adventure";
                else if (t.getCategoryId() == 5) catStr = "luxury";
                
                // Get seats and departure city
                // D\u01b0\u01a1ng: fallback d\u00f9ng Tour.MaxParticipants \u0111\u1ec3 \u0111\u1ed3ng b\u1ed9 v\u1edbi trang booking-create.
                int tourMaxParts = t.getMaxParticipants() > 0 ? t.getMaxParticipants() : 10;
                int seatsLeft = tourMaxParts;
                int seatsTotal = tourMaxParts;
                String departureCity = t.getDepartureCity();
                if (departureCity == null || departureCity.trim().isEmpty()) {
                    departureCity = "H\u00e0 N\u1ed9i";
                }

                if (t.getSchedules() != null && !t.getSchedules().isEmpty()) {
                    seatsLeft = t.getSchedules().get(0).getAvailableSeats();
                    seatsTotal = t.getSchedules().get(0).getTotalSeats();
                }
                
                // Difficulty
                String diffStr = "easy";
                String dl = t.getDifficultyLevel() != null ? t.getDifficultyLevel().toLowerCase() : "";
                if (dl.contains("trung") || dl.contains("medium")) diffStr = "medium";
                else if (dl.contains("kh\u00f3") || dl.contains("hard") || dl.contains("th\u1eed th\u00e1ch")) diffStr = "hard";
                
                // Map pins coordinates
                String lat = "48%";
                String lng = "50%";
                String destName = t.getDestination();
                if (destName.contains("\u0110\u00e0 N\u1eb5ng")) { lat = "45%"; lng = "52%"; }
                else if (destName.contains("Ph\u00fa Qu\u1ed1c")) { lat = "88%"; lng = "25%"; }
                else if (destName.contains("H\u1ea1 Long")) { lat = "18%"; lng = "47%"; }
                else if (destName.contains("H\u1ed9i An")) { lat = "48%"; lng = "54%"; }
                else if (destName.contains("\u0110\u00e0 L\u1ea1t")) { lat = "72%"; lng = "48%"; }
                else if (destName.contains("Sa Pa") || destName.contains("Sapa")) { lat = "10%"; lng = "28%"; }
                else if (destName.contains("Nha Trang")) { lat = "65%"; lng = "55%"; }
                else if (destName.contains("H\u00e0 Giang")) { lat = "5%"; lng = "35%"; }
                else if (destName.contains("Hu\u1ebf")) { lat = "38%"; lng = "46%"; }
                else if (destName.contains("H\u00e0 N\u1ed9i")) { lat = "15%"; lng = "38%"; }
                
                // L\u1ea5y th\u00f4ng tin H\u01b0\u1edbng d\u1eabn vi\u00ean th\u1ef1c t\u1ebf t\u1eeb l\u1ecbch kh\u1edfi h\u00e0nh \u0111\u1ea7u ti\u00ean c\u1ee7a Tour
                String guideName = "Ch\u01b0a ph\u00e2n c\u00f4ng";
                String guideAvatar = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80";
                double guideRating = 4.8;
                int guideToursLed = 15;
                int guideExp = 3;
                String guideBio = "H\u01b0\u1edbng d\u1eabn vi\u00ean chuy\u00ean nghi\u1ec7p s\u1ebd \u0111\u1ed3ng h\u00e0nh v\u00e0 h\u1ed7 tr\u1ee3 b\u1ea1n su\u1ed1t h\u00e0nh tr\u00ecnh kh\u00e1m ph\u00e1.";
                
                if (t.getSchedules() != null && !t.getSchedules().isEmpty()) {
                    TourSchedule sched = t.getSchedules().get(0);
                    if (sched.getGuide() != null) {
                        guideName = sched.getGuide().getFullName();
                        if (sched.getGuide().getProfile() != null && sched.getGuide().getProfile().getAvatarUrl() != null) {
                            guideAvatar = sched.getGuide().getProfile().getAvatarUrl();
                            if (!guideAvatar.startsWith("http") && !guideAvatar.startsWith("/")) {
                                guideAvatar = request.getContextPath() + "/" + guideAvatar;
                            }
                        }
                        if (sched.getGuideProfile() != null) {
                            guideRating = sched.getGuideProfile().getRating();
                            guideToursLed = sched.getGuideProfile().getTotalToursLed();
                            guideExp = sched.getGuideProfile().getYearsOfExperience();
                            if (sched.getGuideProfile().getBio() != null && !sched.getGuideProfile().getBio().trim().isEmpty()) {
                                guideBio = sched.getGuideProfile().getBio();
                            }
                        }
                    }
                }
        %>
        {
            id: <%= t.getTourId() %>,
            title: "<%= t.getTourName().replace("\"", "\\\"") %>",
            description: "<%= t.getDescription() != null ? t.getDescription().replace("\"", "\\\"").replace("\n", " ") : "" %>",
            image: "${pageContext.request.contextPath}/<%= imgUrl %>",
            departure: "<%= departureCity %>",
            tourType: "group",
            rating: <%= (t.getTourId() == activeTour.getTourId()) ? avgRating : t.getRating() %>,
            reviews: <%= (t.getTourId() == activeTour.getTourId()) ? totalReviews : t.getReviewsCount() %>,
            priceVND: <%= t.getBasePrice() %>,
            duration: <%= t.getDurationDays() %>,
            difficulty: "<%= diffStr %>",
            category: "<%= catStr %>",
            seatsLeft: <%= seatsLeft %>,
            seatsTotal: <%= seatsTotal %>,
            maxParticipants: <%= t.getMaxParticipants() %>,
            languages: "<%= t.getLanguages() != null && !t.getLanguages().trim().isEmpty() ? t.getLanguages().replace("\"", "\\\"") : "Ti\u1ebfng Vi\u1ec7t" %>",
            photos: [
                <%
                if (t.getTourId() == activeTour.getTourId()) {
                    for (int j = 0; j < galleryImages.size(); j++) {
                %>
                "<%= galleryImages.get(j) %>"<%= (j < galleryImages.size() - 1) ? "," : "" %>
                <%
                    }
                } else {
                    if (t.getMediaList() != null && !t.getMediaList().isEmpty()) {
                        for (int j = 0; j < t.getMediaList().size(); j++) {
                            TourMedia media = t.getMediaList().get(j);
                            String mediaUrl = media.getMediaUrl();
                            if (!mediaUrl.startsWith("http") && !mediaUrl.startsWith("/")) {
                                mediaUrl = request.getContextPath() + "/" + mediaUrl;
                            }
                %>
                "<%= mediaUrl %>"<%= (j < t.getMediaList().size() - 1) ? "," : "" %>
                <%
                        }
                    } else {
                %>
                "${pageContext.request.contextPath}/<%= imgUrl %>"
                <%
                    }
                }
                %>
            ],
            lat: "<%= lat %>",
            lng: "<%= lng %>",
            location: "<%= t.getDestination().split(",")[0] %>"
        }<%= (i < tours.size() - 1) ? "," : "" %>
        <% 
            }
        } 
        %>
    ];
</script>

<script>
    window.itinerariesData = {};

    // L\u00dd DO V\u00c0 CH\u1ee8C N\u00e0NG C\u1ee6A \u0110O\u1ea0N D\u01af\u1edaI \u0110\u00c2Y:
    // - D\u1eef li\u1ec7u l\u1ecbch tr\u00ecnh (TourItinerary) c\u1ea7n \u0111\u01b0\u1ee3c chuy\u1ec3n sang m\u00f4i tr\u01b0\u1eddng Client (JavaScript)
    //   \u0111\u1ec3 detail.js v\u1ebd tr\u1ee5c th\u1eddi gian (Timeline) \u0111\u1ed9ng.
    // - \u0110o\u1ea1n code Java \u1edf d\u01b0\u1edbi s\u1ebd ki\u1ec3m tra xem Tour n\u00e0y \u0111\u00e3 c\u00f3 L\u1ecbch tr\u00ecnh chi ti\u1ebft trong DB ch\u01b0a:
    //   + N\u1ebfu C\u00d3: L\u1eb7p qua t\u1eebng ng\u00e0y, t\u1ef1 \u0111\u1ed9ng g\u00e1n icon (plane, ship, hotel, camera...) d\u1ef1a v\u00e0o ti\u00eau \u0111\u1ec1 ng\u00e0y \u0111\u00f3,
    //     chuy\u1ec3n c\u00e1c k\u00fd t\u1ef1 xu\u1ed1ng d\u00f2ng th\u00e0nh kho\u1ea3ng tr\u1eafng v\u00e0 xu\u1ea5t ra d\u1ea1ng m\u1ea3ng JS Object.
    //   + N\u1ebfu KH\u00d4NG C\u00d3: Th\u1eed ph\u00e2n t\u00edch chu\u1ed7i v\u0103n b\u1ea3n Itinerary c\u0169 trong b\u1ea3ng Tour l\u00e0m fallback.
    //   + N\u1ebfu c\u1ea3 hai tr\u1ed1ng: Gi\u1eef nguy\u00ean m\u1ea3ng m\u1eb7c \u0111\u1ecbnh \u0111\u00e3 \u0111\u1ecbnh ngh\u0129a t\u0129nh \u1edf tr\u00ean.
    <%
        if (activeTour != null) {
            List<TourItinerary> its = activeTour.getItineraries();
            if (its != null && !its.isEmpty()) {
    %>
    window.itinerariesData[<%= activeTour.getTourId() %>] = [
        <%
            for (int k = 0; k < its.size(); k++) {
                TourItinerary it = its.get(k);
                // M\u1eb7c \u0111\u1ecbnh l\u00e0 icon "activity" (ho\u1ea1t \u0111\u1ed9ng chung)
                String iconName = it.getImageUrl() != null && !it.getImageUrl().trim().isEmpty() ? it.getImageUrl() : "activity";
                
                // Quy t\u1eafc g\u00e1n t\u1ef1 \u0111\u1ed9ng Icon chuy\u00ean nghi\u1ec7p d\u1ef1a theo t\u1eeb kh\u00f3a trong ti\u00eau \u0111\u1ec1
                String tL = it.getTitle().toLowerCase();
                if (tL.contains("bay") || tL.contains("plane") || tL.contains("ti\u1ec5n") || tL.contains("s\u00e2n bay")) iconName = "plane";
                else if (tL.contains("t\u00e0u") || tL.contains("boat") || tL.contains("cruise") || tL.contains("du thuy\u1ec1n") || tL.contains("can\u00f4")) iconName = "ship";
                else if (tL.contains("leo") || tL.contains("trek") || tL.contains("chinh ph\u1ee5c") || tL.contains("\u0111\u1ec9nh") || tL.contains("n\u00fai")) iconName = "mountain";
                else if (tL.contains("kh\u00e1ch s\u1ea1n") || tL.contains("hotel") || tL.contains("resort") || tL.contains("nh\u1eadn ph\u00f2ng")) iconName = "hotel";
                else if (tL.contains("ch\u1ee5p \u1ea3nh") || tL.contains("check") || tL.contains("quay")) iconName = "camera";
                else if (tL.contains("t\u1ef1 do") || tL.contains("free") || tL.contains("vui ch\u01a1i") || tL.contains("l\u1ec5 h\u1ed9i")) iconName = "sparkles";
                else if (tL.contains("\u0111\u00f3n") || tL.contains("ch\u00e0o")) iconName = "map-pin";
        %>
        { 
            day: <%= it.getDayNumber() %>, 
            // Thay th\u1ebf k\u00fd t\u1ef1 nh\u00e1y k\u00e9p b\u1eb1ng nh\u00e1y k\u00e9p escape v\u00e0 b\u1ecf k\u00fd t\u1ef1 xu\u1ed1ng d\u00f2ng \u0111\u1ec3 tr\u00e1nh l\u1ed7i c\u00fa ph\u00e1p JavaScript
            title: "<%= it.getTitle().replace("\"", "\\\"").replace("\r", "").replace("\n", " ") %>", 
            desc: "<%= it.getDescription() != null ? it.getDescription().replace("\"", "\\\"").replace("\r", "").replace("\n", " ") : "" %>", 
            icon: "<%= iconName %>" 
        }<%= (k < its.size() - 1) ? "," : "" %>
        <%
            }
        %>
    ];
    <%
            } else if (activeTour.getItinerary() != null && !activeTour.getItinerary().trim().isEmpty()) {
                // Fallback n\u1ebfu tour ch\u1ec9 l\u01b0u chu\u1ed7i m\u00f4 t\u1ea3 g\u1ed9p trong tr\u01b0\u1eddng Itinerary c\u1ee7a b\u1ea3ng Tour
                String itin = activeTour.getItinerary().trim();
                if (itin.startsWith("[")) {
                    // N\u1ebfu l\u00e0 chu\u1ed7i JSON s\u1eb5n
    %>
    window.itinerariesData[<%= activeTour.getTourId() %>] = <%= itin %>;
    <%
                } else {
                    // N\u1ebfu l\u00e0 chu\u1ed7i v\u0103n b\u1ea3n d\u00f2ng th\u01b0\u1eddng, t\u1ef1 \u0111\u1ed9ng ph\u00e2n t\u00e1ch b\u1eb1ng d\u1ea5u xu\u1ed1ng d\u00f2ng v\u00e0 d\u1ea5u hai ch\u1ea5m ho\u1eb7c g\u1ea1ch ngang
                    String[] lines = itin.split("\n");
    %>
    window.itinerariesData[<%= activeTour.getTourId() %>] = [
        <% 
            int dayCount = 1;
            for (int k = 0; k < lines.length; k++) {
                String line = lines[k].trim();
                if (!line.isEmpty()) {
                    String title = line;
                    String desc = "";
                    if (line.contains(":")) {
                        int colonIdx = line.indexOf(":");
                        title = line.substring(0, colonIdx).trim();
                        desc = line.substring(colonIdx + 1).trim();
                    } else if (line.contains("-")) {
                        int dashIdx = line.indexOf("-");
                        title = line.substring(0, dashIdx).trim();
                        desc = line.substring(dashIdx + 1).trim();
                    }
        %>
        { day: <%= dayCount %>, title: "<%= title.replace("\"", "\\\"") %>", desc: "<%= desc.replace("\"", "\\\"") %>", icon: "activity" }<%= (k < lines.length - 1) ? "," : "" %>
        <% 
                    dayCount++;
                }
            }
        %>
    ];
    <%
                }
            }
        }
    %>


    // Thanh to\u00e1n \u0111\u01b0\u1ee3c qu\u1ea3n l\u00fd ngo\u00e0i h\u1ec7 th\u1ed1ng.


    // \u0110\u00e1nh gi\u00e1 \u0111\u00e3 \u0111\u01b0\u1ee3c n\u1ea1p v\u00e0 k\u1ebft xu\u1ea5t tr\u1ef1c ti\u1ebfp b\u1eb1ng m\u00e3 ngu\u1ed3n JSP \u1edf ph\u00eda tr\u00ean, kh\u00f4ng s\u1eed d\u1ee5ng javascript.
</script>

<script>
    // \u2500\u2500 Safety net: n\u1ebfu footer.jsp ch\u01b0a k\u1ecbp \u0111\u1ecbnh ngh\u0129a showToast (cache, l\u1ed7i include), v\u1eabn c\u00f3 b\u1ea3n fallback \u2500\u2500
    (function () {
        if (typeof window.showToast === 'function') return;
        window.showToast = function (message, type) {
            type = type || 'success';
            let container = document.getElementById('toastContainer');
            if (!container) {
                container = document.createElement('div');
                container.id = 'toastContainer';
                container.className = 'toast-container';
                document.body.appendChild(container);
            }
            const toast = document.createElement('div');
            toast.className = 'toast ' + type;
            let icon = 'check-circle';
            if (type === 'error') icon = 'alert-triangle';
            else if (type === 'warning') icon = 'alert-circle';
            toast.innerHTML = '<i data-lucide="' + icon + '"></i> <span>' + (message || '') + '</span>';
            container.appendChild(toast);
            if (window.lucide) { try { window.lucide.createIcons(); } catch (e) {} }
            setTimeout(function () {
                toast.style.animation = 'toastExit 0.35s cubic-bezier(.16,1,.3,1) forwards';
                setTimeout(function () { toast.remove(); }, 350);
            }, 3000);
        };
    })();
</script>

<%
    // CH&#7912;C N&#224;NG C&#7910;A &#272;O&#7840;N N&#192;Y:
    // - extraScript: header/footer d&#249;ng chung s&#7869; &#273;&#7885;c thu&#7897;c t&#237;nh n&#224;y &#273;&#7875; t&#7921; &#273;&#7897;ng nh&#250;ng file JavaScript detail.js
    //   &#7903; ph&#237;a cu&#7889;i trang, &#273;&#7843;m b&#7843;o trang HTML &#273;&#432;&#7907;c load xong h&#7871;t m&#7899;i ch&#7841;y script x&#7917; l&#253; giao di&#7879;n.
%>
<% request.setAttribute("extraScript", "js/detail.js"); %>
<jsp:include page="/common/footer.jsp" />
