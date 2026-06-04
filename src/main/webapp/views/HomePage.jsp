<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="Entities.Tour" %>
<%@ page import="Entities.TourCategory" %>
<%@ page import="Entities.TourSchedule" %>
<%@ page import="Entities.DestinationInfo" %>
<%@ page import="Entities.Review" %>
<%@ page import="Entities.Coupon" %>
<%
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
            <h1>Kiến Tạo Những Kỷ Niệm <span>Đáng Nhớ</span></h1>
            <p>Khám phá tour cao cấp, trải nghiệm văn hóa đậm chất và những điểm đến tuyệt đẹp khắp Việt Nam — được thiết kế riêng cho bạn.</p>
            <div class="hero-ctas">
                <a href="${pageContext.request.contextPath}/tourdiscovery" class="btn btn-primary" id="hero-explore-btn">Khám Phá Tour <i data-lucide="arrow-right"></i></a>
                <a href="#promotions" class="btn btn-secondary" id="hero-book-btn">Xem Ưu Đãi</a>
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
                    <label for="search-dest"><i data-lucide="map-pin"></i> Điểm đến</label>
                    <div class="search-field-input">
                        <input type="text" id="search-dest" placeholder="Đà Nẵng, Phú Quốc, Hạ Long..." required>
                    </div>
                </div>
                <div class="search-field">
                    <label for="search-date"><i data-lucide="calendar"></i> Ngày khởi hành</label>
                    <div class="search-field-input">
                        <input type="date" id="search-date" required>
                    </div>
                </div>
                <div class="search-field">
                    <label for="search-guests"><i data-lucide="users"></i> Số khách</label>
                    <div class="search-field-input">
                        <select id="search-guests">
                            <option value="1">1 Khách</option>
                            <option value="2" selected>2 Khách</option>
                            <option value="3">3 Khách</option>
                            <option value="4">4+ Khách</option>
                        </select>
                    </div>
                </div>
                <div class="search-field">
                    <div class="range-slider-wrapper">
                        <label for="search-budget"><i data-lucide="wallet"></i> Ngân sách tối đa: <span id="budget-value" class="budget-val">15.000.000 ₫</span></label>
                        <input type="range" id="search-budget" class="budget-slider" min="2000000" max="30000000" step="1000000" value="15000000">
                    </div>
                </div>
                <button type="submit" class="btn btn-primary btn-search" id="search-submit-btn" aria-label="Tìm kiếm tour">
                    <i data-lucide="search"></i>
                </button>
            </form>
        </div>

        <section class="section-padding" id="categories-section">
            <div class="categories-container" id="categories-scroll">
                <div class="category-card active" data-category="all" id="cat-all">
                    <div class="category-icon-wrapper"><i data-lucide="compass"></i></div>
                    <span>Tất Cả</span>
                </div>
                <% 
                    List<TourCategory> categories = (List<TourCategory>) request.getAttribute("categories");
                    if (categories != null) {
                        for (TourCategory cat : categories) {
                            String catName = cat.getCategoryName();
                            String icon = "compass";
                            String dataCategory = "all";
                            
                            if (catName.toLowerCase().contains("biển")) {
                                icon = "palmtree";
                                dataCategory = "beach";
                            } else if (catName.toLowerCase().contains("núi") || catName.toLowerCase().contains("trekking") || catName.toLowerCase().contains("hiking")) {
                                icon = "mountain";
                                dataCategory = "hiking";
                            } else if (catName.toLowerCase().contains("văn hóa") || catName.toLowerCase().contains("di sản") || catName.toLowerCase().contains("cultural")) {
                                icon = "landmark";
                                dataCategory = "cultural";
                            } else if (catName.toLowerCase().contains("city") || catName.toLowerCase().contains("mạo hiểm")) {
                                icon = "map";
                                dataCategory = "adventure";
                            } else if (catName.toLowerCase().contains("mice") || catName.toLowerCase().contains("gia đình")) {
                                icon = "briefcase";
                                dataCategory = "family";
                            } else if (catName.toLowerCase().contains("cao cấp") || catName.toLowerCase().contains("luxury")) {
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
                <h2>Tour Nổi Bật</h2>
                <p>Các hành trình cao cấp được chọn lọc bởi đội ngũ chuyên gia du lịch TourBuddy.</p>
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
                                if (dest.contains("đà nẵng")) imgUrl = "assets/images/tour_danang.png";
                                else if (dest.contains("phú quốc")) imgUrl = "assets/images/tour_phuquoc.png";
                                else if (dest.contains("hạ long")) imgUrl = "assets/images/tour_halong.png";
                                else if (dest.contains("hội an")) imgUrl = "assets/images/tour_hoian.png";
                                else if (dest.contains("đà lạt")) imgUrl = "assets/images/tour_dalat.png";
                                else if (dest.contains("sa pa") || dest.contains("sapa")) imgUrl = "assets/images/tour_sapa.png";
                                else if (dest.contains("nha trang")) imgUrl = "assets/images/tour_nhatrang.png";
                                else if (dest.contains("hà giang")) imgUrl = "assets/images/tour_hagiang.png";
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
                            String formattedPrice = String.format("%,.0f", tour.getBasePrice()).replace(',', '.') + " ₫";
                            
                            // Badge name
                            String badgeName = "Bán Chạy";
                            if (tour.getTourId() % 3 == 0) badgeName = "Độc Quyền";
                            else if (tour.getTourId() % 3 == 2) badgeName = "Xu Hướng";
                %>
                <div class="tour-card" data-tour-category="<%= catClass %>">
                    <div class="tour-img-wrapper">
                        <img src="<%= imageUrl %>" alt="<%= tour.getTourName() %>" class="tour-img">
                        <div class="tour-badge"><span class="badge badge-featured"><%= badgeName %></span></div>
                        <button class="btn-wishlist" id="wishlist-<%= tour.getTourId() %>" aria-label="Thêm vào yêu thích">
                            <i data-lucide="heart"></i>
                        </button>
                    </div>
                    <div class="tour-details">
                        <div class="tour-meta">
                            <div class="tour-rating">
                                <i data-lucide="star"></i>
                                <span><%= tour.getRating() %> (<%= tour.getReviewsCount() %> đánh giá)</span>
                            </div>
                            <div class="tour-duration">
                                <i data-lucide="clock"></i>
                                <span><%= tour.getDurationDays() %> Ngày</span>
                            </div>
                        </div>
                        <h3><%= tour.getTourName() %></h3>
                        <div class="tour-seats-progress">
                            <div class="seats-info">
                                <span>Chỗ trống</span>
                                <span class="seats-left <%= progressClass.equals("danger") ? "seats-left" : "" %>">
                                    <%= availableSeats > 0 ? "Còn " + availableSeats + " chỗ!" : "Hết chỗ!" %>
                                </span>
                            </div>
                            <div class="progress-bar-bg">
                                <div class="progress-bar-fill <%= progressClass %>" style="width: <%= progressPercent %>%;"></div>
                            </div>
                        </div>
                        <div class="tour-footer">
                            <div class="tour-price">
                                <span class="price-label">Giá mỗi khách</span>
                                <span class="price-val"><%= formattedPrice.replace(" ₫", "") %> <span>₫</span></span>
                            </div>
                            <button class="btn btn-primary btn-sm" onclick="window.location.href='${pageContext.request.contextPath}/detail?id=<%= tour.getTourId() %>'">Xem Chi Tiết</button>
                        </div>
                    </div>
                </div>
                <%
                        }
                    } else {
                %>
                <p>Không tìm thấy tour nổi bật nào.</p>
                <%
                    }
                %>
            </div>

            <div class="view-more-container" id="view-more-tours-wrapper" style="display: none;">
                <button type="button" class="btn btn-secondary" id="btn-view-more-tours">
                    <span class="btn-label">Xem thêm tour</span>
                    <span id="btn-view-more-icon"><i data-lucide="chevron-down"></i></span>
                </button>
            </div>
        </section>

        <section class="section-padding" id="destinations">
            <div class="section-header">
                <h2>Điểm Đến Hot Nhất</h2>
                <p>Những địa danh được du khách tìm kiếm nhiều nhất hiện nay.</p>
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
                <p>Không tìm thấy điểm đến nổi bật nào.</p>
                <% 
                    }
                %>
            </div>

            <div class="view-more-container" id="view-more-dests-wrapper" style="display: none;">
                <button type="button" class="btn btn-secondary" id="btn-view-more-dests">
                    <span class="btn-label">Xem thêm điểm đến</span>
                    <span id="btn-view-more-dests-icon"><i data-lucide="chevron-down"></i></span>
                </button>
            </div>
        </section>

        <section class="section-padding" id="promotions">
            <div class="section-header">
                <h2>Ưu Đãi Có Hạn</h2>
                <p>Đặt tour cao cấp với mức giá ưu đãi theo mùa — đừng bỏ lỡ.</p>
            </div>

            <div class="promo-grid">
                <div class="promo-banner-card">
                    <div class="promo-info">
                        <span class="promo-badge-sale">Flash Sale</span>
                        <h3 class="promo-title">Giảm 20% Tour Biển & Resort Mùa Hè</h3>
                        <p class="promo-desc">Áp dụng cho tất cả gói biển đảo và nghỉ dưỡng đặt trước khi hết thời gian đếm ngược. Một số tour có thể loại trừ.</p>

                        <div class="promo-timer" id="flash-sale-timer">
                            <div class="timer-box">
                                <span class="timer-num" id="timer-hours">08</span>
                                <span class="timer-label">Giờ</span>
                            </div>
                            <div class="timer-box">
                                <span class="timer-num" id="timer-mins">45</span>
                                <span class="timer-label">Phút</span>
                            </div>
                            <div class="timer-box">
                                <span class="timer-num" id="timer-secs">29</span>
                                <span class="timer-label">Giây</span>
                            </div>
                        </div>

                        <a href="#tours" class="btn btn-secondary">Nhận Ưu Đãi</a>
                    </div>
                </div>

                <%
                    List<Coupon> activeCoupons = (List<Coupon>) request.getAttribute("activeCoupons");
                    String promoCode = "TOURBUDDY2026"; // Fallback
                    String promoDesc = "Giảm thêm 1.000.000₫ cho lần đặt tour đầu tiên."; // Fallback
                    if (activeCoupons != null && !activeCoupons.isEmpty()) {
                        Coupon firstCoupon = activeCoupons.get(0);
                        promoCode = firstCoupon.getCouponCode();
                        
                        // Format discount description dynamically
                        String valStr = "";
                        if ("Percentage".equals(firstCoupon.getDiscountType())) {
                            valStr = String.format("%.0f%%", firstCoupon.getDiscountValue());
                        } else {
                            valStr = String.format("%,.0fđ", firstCoupon.getDiscountValue()).replace(',', '.');
                        }
                        
                        String minStr = String.format("%,.0fđ", firstCoupon.getMinOrderAmount()).replace(',', '.');
                        promoDesc = "Giảm ngay " + valStr + " cho đơn hàng từ " + minStr + ". Hạn dùng đến " + firstCoupon.getEndDate() + ".";
                    }
                %>
                <div class="promo-code-card" id="promo-card">
                    <div class="category-icon-wrapper"><i data-lucide="gift"></i></div>
                    <span class="promo-code-label">Nhập mã khi thanh toán</span>
                    <div class="promo-code-value" id="promo-coupon-code"><%= promoCode %></div>
                    <p>Nhấn để sao chép mã. <%= promoDesc %></p>
                </div>
            </div>
        </section>

        <section class="section-padding" id="testimonials">
            <div class="section-header">
                <h2>Du Khách Nói Gì Về TourBuddy</h2>
                <p>Trải nghiệm thực tế từ những người đã đồng hành cùng chúng tôi.</p>
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
                                <div class="author-role">Khách du lịch thành viên</div>
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
                        <p class="testimonial-quote">"Tour du lịch tuyệt vời! Dịch vụ chăm sóc khách hàng vô cùng chuyên nghiệp. Chắc chắn sẽ quay lại cùng TourBuddy Travels."</p>
                        <div class="testimonial-author">
                            <div class="author-avatar">
                                <img src="https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=120&q=80" alt="Khách hàng">
                            </div>
                            <div class="author-info">
                                <div class="author-name">Khách hàng ẩn danh</div>
                                <div class="author-role">Thành viên TourBuddy</div>
                            </div>
                        </div>
                    </div>
                    <%
                        }
                    %>
                </div>

                <button class="btn-icon slider-btn prev" id="test-prev" aria-label="Đánh giá trước">
                    <i data-lucide="chevron-left"></i>
                </button>
                <button class="btn-icon slider-btn next" id="test-next" aria-label="Đánh giá sau">
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
