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
    // LÝ DO VÀ CHỨC NàNG CỦA ĐOẠN CODE NÀY:
    // - extraCss: Thuộc tính này được header.jsp đọc để nhúng file CSS detail.css tương ứng (tạo giao diện riêng cho trang chi tiết).
    // - activeTour: Đối tượng Tour chính được Servlet DetailController.java nạp từ DB (bằng tourDAO.getTourById(id))
    //   và đẩy vào request attribute để JSP này hiển thị thông tin động.
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
        // Dương: Tổng chỗ trống & tổng chỗ lấy từ TẤT CẢ schedule tương lai
        // (Tour có thể có nhiều lịch — chỉ lấy lịch đầu tiên là sai cho hiển thị)
        if (activeTour.getSchedules() != null) {
            for (TourSchedule s : activeTour.getSchedules()) {
                if ("Open".equalsIgnoreCase(s.getStatus())) {
                    activeSeatsLeft += s.getAvailableSeats();
                    totalSeatsAll += s.getTotalSeats();
                }
            }
        }
    }
    // Dương: Giới hạn số người tối đa của mỗi đoàn lấy từ Tour.MaxParticipants (do admin cấu hình khi tạo tour).
    // Fallback 10 khi DB chưa set để khớp với constraint cũ và tránh hiển thị rỗng.
    int maxParticipantsPerDeparture = (activeTour != null && activeTour.getMaxParticipants() > 0)
            ? activeTour.getMaxParticipants() : 10;
%>
<!-- Nhúng header dùng chung cho toàn bộ website, nằm trong thư mục web/common/ -->
<jsp:include page="/common/header.jsp" />

    <!-- TOUR TITLE & HEAD SECTION -->
    <section class="tour-detail-head-section">
        <div class="container">
            <!-- Breadcrumbs -->
            <div class="breadcrumbs">
                <a href="${pageContext.request.contextPath}/home">Trang chủ</a> &gt; 
                <a href="${pageContext.request.contextPath}/tourdiscovery">Tours</a> &gt; 
                <span id="breadcrumb-active">Chi tiết Tour</span>
            </div>

            <!-- Title & Rating info -->
            <div class="tour-head-flex">
                <div class="tour-head-left">
                    <h1 id="detail-title">Đang tải tên tour...</h1>
                    <div class="tour-meta-row">
                        <div class="tour-rating-stars">
                            <i data-lucide="star" class="star-filled"></i>
                            <strong id="detail-rating">0.0</strong> 
                            <span id="detail-reviews-count">(0 đánh giá)</span>
                        </div>
                        <div class="tour-location-text">
                            <i data-lucide="map-pin"></i>
                            <span id="detail-location-name">Đang tải địa điểm...</span>
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
                        <i data-lucide="share-2"></i> Chia sẻ
                    </button>
                    <%
                        List<Integer> wishlistTourIds = (List<Integer>) request.getAttribute("wishlistTourIds");
                        boolean isWishlisted = activeTour != null && wishlistTourIds != null && wishlistTourIds.contains(activeTour.getTourId());
                    %>
                    <button class="btn btn-secondary btn-icon-text btn-wishlist-detail <%= isWishlisted ? "active" : "" %>" id="wishlist-detail-btn" data-tour-id="<%= activeTour != null ? activeTour.getTourId() : "" %>">
                        <% if (isWishlisted) { %>
                            <i data-lucide="heart" fill="currentColor"></i> Đã lưu Yêu thích
                        <% } else { %>
                            <i data-lucide="heart"></i> Lưu vào Yêu thích
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
                        if (dest.contains("đà nẵng")) mainImgUrl = "assets/images/tour_danang.png";
                        else if (dest.contains("phú quốc")) mainImgUrl = "assets/images/tour_phuquoc.png";
                        else if (dest.contains("hạ long")) mainImgUrl = "assets/images/tour_halong.png";
                        else if (dest.contains("hội an")) mainImgUrl = "assets/images/tour_hoian.png";
                        else if (dest.contains("đà lạt")) mainImgUrl = "assets/images/tour_dalat.png";
                        else if (dest.contains("sa pa") || dest.contains("sapa")) mainImgUrl = "assets/images/tour_sapa.png";
                        else if (dest.contains("nha trang")) mainImgUrl = "assets/images/tour_nhatrang.png";
                        else if (dest.contains("hà giang")) mainImgUrl = "assets/images/tour_hagiang.png";
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
                    <img src="<%= galleryImages.get(0) %>" alt="Tour chính" id="gallery-main-img">
                </div>
                <!-- Sub photos (Right grid) -->
                <div class="gallery-item sub-photo sub-1">
                    <img src="<%= galleryImages.get(1) %>" alt="Ảnh phụ 1" class="gallery-thumb" data-index="1">
                </div>
                <div class="gallery-item sub-photo sub-2">
                    <img src="<%= galleryImages.get(2) %>" alt="Ảnh phụ 2" class="gallery-thumb" data-index="2">
                </div>
                <div class="gallery-item sub-photo sub-3">
                    <img src="<%= galleryImages.get(3) %>" alt="Ảnh phụ 3" class="gallery-thumb" data-index="3">
                </div>
                <div class="gallery-item sub-photo sub-4">
                    <img src="<%= galleryImages.get(4) %>" alt="Ảnh phụ 4" class="gallery-thumb" data-index="4">
                    <button class="btn-all-photos" id="view-all-photos-btn">
                        <i data-lucide="grid"></i> Xem Tất Cả Ảnh
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
                            <span class="label">Thời lượng</span>
                            <strong id="hl-duration">Đang tải...</strong>
                        </div>
                    </div>
                    <div class="highlight-item">
                        <div class="icon-wrapper"><i data-lucide="users"></i></div>
                        <div class="item-text">
                            <span class="label">Giới hạn đoàn</span>
                            <strong id="hl-group-size" title="Số người tối đa cho mỗi đoàn khởi hành — do Admin cấu hình khi tạo tour">Tối đa <%= maxParticipantsPerDeparture %> khách/đoàn</strong>
                        </div>
                    </div>
                    <div class="highlight-item">
                        <div class="icon-wrapper"><i data-lucide="ticket"></i></div>
                        <div class="item-text">
                            <span class="label">Chỗ trống (tất cả lịch)</span>
                            <strong id="hl-seats-left"><%= activeSeatsLeft %> Chỗ</strong>
                        </div>
                    </div>
                    <div class="highlight-item">
                        <div class="icon-wrapper"><i data-lucide="languages"></i></div>
                        <div class="item-text">
                            <span class="label">Ngôn ngữ</span>
                            <strong id="hl-languages">Tiếng Việt / Anh</strong>
                        </div>
                    </div>
                    <div class="highlight-item">
                        <div class="icon-wrapper"><i data-lucide="activity"></i></div>
                        <div class="item-text">
                            <span class="label">Mức độ vận động</span>
                            <strong id="hl-difficulty">Đang tải...</strong>
                        </div>
                    </div>
                </div>


                <!-- Tour Description -->
                <div class="tour-description-section">
                    <h3>Giới Thiệu Hành Trình</h3>
                    <p id="tour-detail-desc">Đang tải nội dung hành trình...</p>
                </div>

                <!-- Itinerary Timeline Section -->
                <div class="tour-itinerary-section">
                    <h3>Chi Tiết Lịch Trình Từng Ngày</h3>
                    <p class="itinerary-intro">Xem lịch trình chi tiết và hấp dẫn được thiết kế chuyên nghiệp của chúng tôi.</p>
                    
                    <div class="itinerary-timeline" id="itinerary-timeline-container">
                        <!-- Populated dynamically via detail.js -->
                    </div>
                </div>

                <!-- Included / Excluded Services Card -->
                <!-- LÝ DO VÀ CHỨC NàNG CỦA ĐOẠN NÀY:
                     - Giúp người dùng biết tour bao gồm những tiện ích gì (INCLUDED) và những gì họ phải tự trả chi phí (EXCLUDED).
                     - Tải động từ bảng TourInclusion thông qua tour.getInclusions().
                     - Phân tách làm hai cột trái và phải. Nếu DB chưa có dữ liệu, sẽ hiển thị danh sách tĩnh mặc định để giữ UI đẹp. -->
                <div class="tour-services-card">
                    <h3>Dịch Vụ Bao Gồm & Loại Trừ</h3>
                    <div class="services-split-grid">
                        <div class="services-column included">
                            <h4><i data-lucide="check-circle" class="icon-included"></i> Dịch vụ bao gồm</h4>
                            <ul class="services-list">
                                <%
                                    // Lấy danh sách dịch vụ đi kèm
                                    List<TourInclusion> inclusions = activeTour.getInclusions();
                                    boolean hasIncluded = false;
                                    
                                    // Duyệt danh sách, lọc dịch vụ bao gồm (INCLUDED)
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
                                    
                                    // Không có dữ liệu từ DB → hiện thông báo trống
                                    if (!hasIncluded) {
                                %>
                                <li style="color: var(--slate-400); font-style: italic;"><i data-lucide="info"></i> Chưa có thông tin dịch vụ bao gồm.</li>
                                <%
                                    }
                                %>
                            </ul>
                        </div>
                        <div class="services-column excluded">
                            <h4><i data-lucide="x-circle" class="icon-excluded"></i> Dịch vụ không bao gồm</h4>
                            <ul class="services-list">
                                <%
                                    boolean hasExcluded = false;
                                    // Duyệt danh sách, lọc dịch vụ loại trừ (EXCLUDED)
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
                                    
                                    // Không có dữ liệu từ DB → hiện thông báo trống
                                    if (!hasExcluded) {
                                %>
                                <li style="color: var(--slate-400); font-style: italic;"><i data-lucide="info"></i> Chưa có thông tin dịch vụ không bao gồm.</li>
                                <%
                                    }
                                %>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- Reviews & Ratings Section -->
                <div class="tour-reviews-section" id="reviews">
                    <h3>Đánh Giá Thực Tế Từ Du Khách</h3>
                    
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
                            <span class="reviews-count-label" id="scorecard-total">Dựa trên <%= totalReviews %> đánh giá</span>
                        </div>
                        <div class="scorecard-right">
                            <%
                                for (int star = 5; star >= 1; star--) {
                                    int percent = starPercentages[star];
                            %>
                            <div class="rating-bar-item" data-star="<%= star %>">
                                <span><%= star %> ★</span>
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
                                        <span class="reviewer-date">Đăng ngày: <%= dateStr %></span>
                                        <button class="btn-report-review" data-id="<%= rev.getReviewId() %>" style="background:none; border:none; color:#ea580c; cursor:pointer; font-size:0.75rem; margin-top:4px; display:inline-flex; align-items:center; gap:4px; padding:0; outline:none;"><i class="fa-solid fa-flag"></i> Báo cáo vi phạm</button>
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
                                        <span>Đã trải nghiệm</span>
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
                            <p>Chưa có đánh giá nào cho hành trình này. Hãy là người đầu tiên chia sẻ cảm nhận!</p>
                        </div>
                        <%
                            }
                        %>
                    </div>

                    <!-- BIỂU MẪU ĐàNG KÝ BÌNH LUẬN / ĐÁNH GIÁ (ADD REVIEW FORM)
                         Lý do tại sao lại phải làm như vậy:
                         - Cho phép khách hàng chia sẻ cảm nhận, bình chọn số sao thực tế từ 1-5.
                         - Form post dữ liệu trực tiếp lên DetailController (/detail) thông qua phương thức POST.
                         - Sử dụng 2 hidden input để truyền tourId (xác định tour được review) và rating (sao).
                         - Tên các thẻ input (name="name", name="email", name="content") trùng khớp với tham số
                           Servlet đọc bằng request.getParameter(). -->
                    <div class="add-review-card">
                        <h4>Chia Sẻ Trải Nghiệm Của Bạn</h4>
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
                            <p>Ý kiến của bạn giúp cộng đồng du lịch có thêm những quyết định đúng đắn.</p>
                            
                            <form class="add-review-form" id="new-review-form" action="${pageContext.request.contextPath}/detail" method="POST" enctype="multipart/form-data">
                                <!-- Lưu ID của Tour để Controller biết cần gán review này cho tour nào -->
                                <input type="hidden" name="tourId" value="<%= activeTour != null ? activeTour.getTourId() : 1 %>">
                                <!-- Lưu số sao đánh giá (sẽ được cập nhật bằng JS khi người dùng click vào các ngôi sao bên dưới) -->
                                <input type="hidden" name="rating" id="review-rating-input" value="5">
                                
                                <div class="form-rating-selector">
                                    <span>Đánh giá của bạn:</span>
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
                                        <label for="rev-name">Họ & Tên *</label>
                                        <input type="text" id="rev-name" name="name" value="<%= currentUser.getFullName() %>" readonly style="background-color: var(--slate-100); cursor: not-allowed;" required>
                                    </div>
                                    <div class="form-group">
                                        <label for="rev-email">Email (Sẽ được ẩn) *</label>
                                        <input type="email" id="rev-email" name="email" value="<%= currentUser.getEmail() %>" readonly style="background-color: var(--slate-100); cursor: not-allowed;" required>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="rev-text">Bình luận chi tiết *</label>
                                    <textarea id="rev-text" name="content" rows="4" placeholder="Chia sẻ về lịch trình, dịch vụ ăn uống, hướng dẫn viên và phương tiện di chuyển..." required></textarea>
                                </div>

                                <div class="form-group">
                                    <label>Tải lên hình ảnh chuyến đi</label>
                                    <div class="upload-simulator-btn" id="upload-sim-btn">
                                        <i data-lucide="camera"></i>
                                        <span>Chọn hình ảnh từ thiết bị của bạn</span>
                                    </div>
                                    <input type="file" id="review-image-input" name="reviewImage" accept="image/*" style="display: none;">
                                    <div class="uploaded-images-preview" id="uploaded-images-preview-row"></div>
                                </div>

                                <button type="submit" class="btn btn-primary">Gửi Đánh Giá</button>
                            </form>
                        <% } else { %>
                            <div class="login-to-review-wrapper" style="text-align: center; padding: 2rem 1rem;">
                                <i data-lucide="message-square" style="width: 3rem; height: 3rem; color: var(--slate-400); margin-bottom: 1rem; display: block; margin-left: auto; margin-right: auto;"></i>
                                <p style="margin-bottom: 1.5rem; color: var(--slate-600);">Vui lòng đăng nhập tài khoản để gửi đánh giá và chia sẻ trải nghiệm chuyến đi của bạn.</p>
                                <a href="${pageContext.request.contextPath}/login" class="btn btn-primary" style="display: inline-flex; align-items: center; gap: 0.5rem; padding: 0.75rem 1.5rem; border-radius: 8px;">
                                    <i data-lucide="log-in" style="width: 1.25rem; height: 1.25rem;"></i> Đăng Nhập Để Đánh Giá
                                </a>
                            </div>
                        <% } %>
                    </div>
                </div>

                <!-- PHÂN HỆ CÂU HỎI THƯỜNG GẶP (FAQ SECTION)
                     Lý do cần thiết kế như thế này:
                     - Giúp hiển thị bộ FAQs được quản lý năng động trong cơ sở dữ liệu.
                     - Sử dụng vòng lặp Java Scriplet để đọc danh sách List<TourFAQ> từ thuộc tính faqs của activeTour.
                     - Nếu DB chưa được cấu hình câu hỏi cho tour này, hiển thị 3 câu hỏi mặc định làm dự phòng (fallback) để giao diện không bị trống. -->
                <div class="tour-faq-section">
                    <h3>Những Câu Hỏi Thường Gặp</h3>
                    
                    <div class="faq-accordion-wrapper">
                        <%
                            List<TourFAQ> faqs = activeTour != null ? activeTour.getFaqs() : null;
                            boolean hasFaqs = false;
                            
                            // Duyệt qua danh sách FAQs và xuất mã HTML động
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
                            
                            // Phần hiển thị fallback nếu DB trống
                            if (!hasFaqs) {
                        %>
                        <div class="faq-item">
                            <div class="faq-question">
                                <h4>Chính sách hủy tour du lịch của TourBuddy như thế nào?</h4>
                                <i data-lucide="chevron-down" class="faq-arrow"></i>
                            </div>
                            <div class="faq-answer">
                                <p>Bạn sẽ được hoàn tiền 100% nếu hủy tour trước 7 ngày kể từ ngày khởi hành dự kiến. Hoàn tiền 50% nếu hủy trước từ 3-6 ngày. Hủy tour trong vòng 48 giờ trước giờ đi sẽ không được hoàn trả chi phí theo quy định chung.</p>
                            </div>
                        </div>

                        <div class="faq-item">
                            <div class="faq-question">
                                <h4>Tôi cần chuẩn bị những hành lý cá nhân gì khi đi tour leo núi/trekking?</h4>
                                <i data-lucide="chevron-down" class="faq-arrow"></i>
                            </div>
                            <div class="faq-answer">
                                <p>Đối với các tour vận động trung bình trở lên (Đà Lạt, Sa Pa, Hà Giang), bạn nên mang theo giày trekking chuyên dụng có độ bám cao, quần áo chống gió thấm hút mồ hôi tốt, một chai nước cá nhân, kem chống nắng, thuốc lá côn trùng và sạc dự phòng.</p>
                            </div>
                        </div>

                        <div class="faq-item">
                            <div class="faq-question">
                                <h4>Trẻ em có thể tham gia các gói tour này không?</h4>
                                <i data-lucide="chevron-down" class="faq-arrow"></i>
                            </div>
                            <div class="faq-answer">
                                <p>Trẻ em từ 5 tuổi trở lên có thể tham gia hầu hết các tour văn hóa/biển đảo. Với các tour thám hiểm vận động mạnh (Fansipan trekking, Hà Giang), trẻ em từ 12 tuổi trở lên và có thể lực tốt mới được khuyến cáo tham gia.</p>
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
                                <span>Cổng đăng ký trực tuyến chính thức</span>
                            </div>
                            <button type="button" class="btn btn-primary btn-payment-cta" id="go-payment-btn"
                                    onclick="if (<%= isLoggedIn %>) { window.location.href='${pageContext.request.contextPath}/customer/booking/create?tourId=<%= activeTour != null ? activeTour.getTourId() : 1 %>' } else { alert('Vui lòng đăng nhập để thực hiện đặt tour!'); window.location.href='${pageContext.request.contextPath}/login'; }">
                                <span class="btn-payment-text">
                                    <i data-lucide="compass"></i>
                                    Đăng ký tham gia ngay
                                </span>
                                <i data-lucide="arrow-right" class="btn-payment-arrow"></i>
                            </button>
                            <div class="payment-trust-footer">
                                <span class="trust-item"><i data-lucide="shield-check"></i> An toàn</span>
                                <span class="trust-divider">•</span>
                                <span class="trust-item"><i data-lucide="zap"></i> Nhanh chóng</span>
                                <span class="trust-divider">•</span>
                                <span class="trust-item"><i data-lucide="lock"></i> Bảo mật</span>
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
                <h2>Hành Trình Tương Tự Bạn Sẽ Thích</h2>
                <p style="margin-left: 0; margin-right: auto;">Khám phá thêm các địa danh du lịch kỳ thú có thể bạn sẽ muốn thêm vào danh sách tiếp theo.</p>
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
            <img src="" alt="Ảnh phóng to" id="lightbox-expanded-img">
        </div>
        <button class="lightbox-nav-btn lightbox-next" id="lightbox-next-btn"><i data-lucide="chevron-right"></i></button>
        <div class="lightbox-caption" id="lightbox-caption-txt">Ảnh trình chiếu</div>
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
                    if (dest.contains("đà nẵng")) imgUrl = "assets/images/tour_danang.png";
                    else if (dest.contains("phú quốc")) imgUrl = "assets/images/tour_phuquoc.png";
                    else if (dest.contains("hạ long")) imgUrl = "assets/images/tour_halong.png";
                    else if (dest.contains("hội an")) imgUrl = "assets/images/tour_hoian.png";
                    else if (dest.contains("đà lạt")) imgUrl = "assets/images/tour_dalat.png";
                    else if (dest.contains("sa pa") || dest.contains("sapa")) imgUrl = "assets/images/tour_sapa.png";
                    else if (dest.contains("nha trang")) imgUrl = "assets/images/tour_nhatrang.png";
                    else if (dest.contains("hà giang")) imgUrl = "assets/images/tour_hagiang.png";
                }
                
                // Map category
                String catStr = "luxury";
                if (t.getCategoryId() == 1) catStr = "beach";
                else if (t.getCategoryId() == 2) catStr = "hiking";
                else if (t.getCategoryId() == 3) catStr = "cultural";
                else if (t.getCategoryId() == 4) catStr = "adventure";
                else if (t.getCategoryId() == 5) catStr = "luxury";
                
                // Get seats and departure city
                // Dương: fallback dùng Tour.MaxParticipants để đồng bộ với trang booking-create.
                int tourMaxParts = t.getMaxParticipants() > 0 ? t.getMaxParticipants() : 10;
                int seatsLeft = tourMaxParts;
                int seatsTotal = tourMaxParts;
                String departureCity = t.getDepartureCity();
                if (departureCity == null || departureCity.trim().isEmpty()) {
                    departureCity = "Hà Nội";
                }

                if (t.getSchedules() != null && !t.getSchedules().isEmpty()) {
                    seatsLeft = t.getSchedules().get(0).getAvailableSeats();
                    seatsTotal = t.getSchedules().get(0).getTotalSeats();
                }
                
                // Difficulty
                String diffStr = "easy";
                String dl = t.getDifficultyLevel() != null ? t.getDifficultyLevel().toLowerCase() : "";
                if (dl.contains("trung") || dl.contains("medium")) diffStr = "medium";
                else if (dl.contains("khó") || dl.contains("hard") || dl.contains("thử thách")) diffStr = "hard";
                
                // Map pins coordinates
                String lat = "48%";
                String lng = "50%";
                String destName = t.getDestination();
                if (destName.contains("Đà Nẵng")) { lat = "45%"; lng = "52%"; }
                else if (destName.contains("Phú Quốc")) { lat = "88%"; lng = "25%"; }
                else if (destName.contains("Hạ Long")) { lat = "18%"; lng = "47%"; }
                else if (destName.contains("Hội An")) { lat = "48%"; lng = "54%"; }
                else if (destName.contains("Đà Lạt")) { lat = "72%"; lng = "48%"; }
                else if (destName.contains("Sa Pa") || destName.contains("Sapa")) { lat = "10%"; lng = "28%"; }
                else if (destName.contains("Nha Trang")) { lat = "65%"; lng = "55%"; }
                else if (destName.contains("Hà Giang")) { lat = "5%"; lng = "35%"; }
                else if (destName.contains("Huế")) { lat = "38%"; lng = "46%"; }
                else if (destName.contains("Hà Nội")) { lat = "15%"; lng = "38%"; }
                
                // Lấy thông tin Hướng dẫn viên thực tế từ lịch khởi hành đầu tiên của Tour
                String guideName = "Chưa phân công";
                String guideAvatar = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80";
                double guideRating = 4.8;
                int guideToursLed = 15;
                int guideExp = 3;
                String guideBio = "Hướng dẫn viên chuyên nghiệp sẽ đồng hành và hỗ trợ bạn suốt hành trình khám phá.";
                
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
            languages: "<%= t.getLanguages() != null && !t.getLanguages().trim().isEmpty() ? t.getLanguages().replace("\"", "\\\"") : "Tiếng Việt" %>",
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

    // LÝ DO VÀ CHỨC NàNG CỦA ĐOẠN DƯỚI ĐÂY:
    // - Dữ liệu lịch trình (TourItinerary) cần được chuyển sang môi trường Client (JavaScript)
    //   để detail.js vẽ trục thời gian (Timeline) động.
    // - Đoạn code Java ở dưới sẽ kiểm tra xem Tour này đã có Lịch trình chi tiết trong DB chưa:
    //   + Nếu CÓ: Lặp qua từng ngày, tự động gán icon (plane, ship, hotel, camera...) dựa vào tiêu đề ngày đó,
    //     chuyển các ký tự xuống dòng thành khoảng trắng và xuất ra dạng mảng JS Object.
    //   + Nếu KHÔNG CÓ: Thử phân tích chuỗi văn bản Itinerary cũ trong bảng Tour làm fallback.
    //   + Nếu cả hai trống: Giữ nguyên mảng mặc định đã định nghĩa tĩnh ở trên.
    <%
        if (activeTour != null) {
            List<TourItinerary> its = activeTour.getItineraries();
            if (its != null && !its.isEmpty()) {
    %>
    window.itinerariesData[<%= activeTour.getTourId() %>] = [
        <%
            for (int k = 0; k < its.size(); k++) {
                TourItinerary it = its.get(k);
                // Mặc định là icon "activity" (hoạt động chung)
                String iconName = it.getImageUrl() != null && !it.getImageUrl().trim().isEmpty() ? it.getImageUrl() : "activity";
                
                // Quy tắc gán tự động Icon chuyên nghiệp dựa theo từ khóa trong tiêu đề
                String tL = it.getTitle().toLowerCase();
                if (tL.contains("bay") || tL.contains("plane") || tL.contains("tiễn") || tL.contains("sân bay")) iconName = "plane";
                else if (tL.contains("tàu") || tL.contains("boat") || tL.contains("cruise") || tL.contains("du thuyền") || tL.contains("canô")) iconName = "ship";
                else if (tL.contains("leo") || tL.contains("trek") || tL.contains("chinh phục") || tL.contains("đỉnh") || tL.contains("núi")) iconName = "mountain";
                else if (tL.contains("khách sạn") || tL.contains("hotel") || tL.contains("resort") || tL.contains("nhận phòng")) iconName = "hotel";
                else if (tL.contains("chụp ảnh") || tL.contains("check") || tL.contains("quay")) iconName = "camera";
                else if (tL.contains("tự do") || tL.contains("free") || tL.contains("vui chơi") || tL.contains("lễ hội")) iconName = "sparkles";
                else if (tL.contains("đón") || tL.contains("chào")) iconName = "map-pin";
        %>
        { 
            day: <%= it.getDayNumber() %>, 
            // Thay thế ký tự nháy kép bằng nháy kép escape và bỏ ký tự xuống dòng để tránh lỗi cú pháp JavaScript
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
                // Fallback nếu tour chỉ lưu chuỗi mô tả gộp trong trường Itinerary của bảng Tour
                String itin = activeTour.getItinerary().trim();
                if (itin.startsWith("[")) {
                    // Nếu là chuỗi JSON sẵn
    %>
    window.itinerariesData[<%= activeTour.getTourId() %>] = <%= itin %>;
    <%
                } else {
                    // Nếu là chuỗi văn bản dòng thường, tự động phân tách bằng dấu xuống dòng và dấu hai chấm hoặc gạch ngang
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


    // Thanh toán được quản lý ngoài hệ thống.


    // Đánh giá đã được nạp và kết xuất trực tiếp bằng mã nguồn JSP ở phía trên, không sử dụng javascript.
</script>

<script>
    // ── Safety net: nếu footer.jsp chưa kịp định nghĩa showToast (cache, lỗi include), vẫn có bản fallback ──
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
    // CHỨC NàNG CỦA ĐOẠN NÀY:
    // - extraScript: header/footer dùng chung sẽ đọc thuộc tính này để tự động nhúng file JavaScript detail.js
    //   ở phía cuối trang, đảm bảo trang HTML được load xong hết mới chạy script xử lý giao diện.
%>
<% request.setAttribute("extraScript", "js/detail.js"); %>
<jsp:include page="/common/footer.jsp" />
