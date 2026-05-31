<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="Entities.Tour" %>
<%@ page import="Entities.TourCategory" %>
<%@ page import="Entities.TourSchedule" %>
<%@ page import="Entities.TourMedia" %>
<%@ page import="Entities.TourItinerary" %>
<%@ page import="Entities.TourInclusion" %>
<%@ page import="Entities.TourFAQ" %>
<%@ page import="Entities.Review" %>
<%
    // LÝ DO VÀ CHỨC NĂNG CỦA ĐOẠN CODE NÀY:
    // - extraCss: Thuộc tính này được header.jsp đọc để nhúng file CSS detail.css tương ứng (tạo giao diện riêng cho trang chi tiết).
    // - activeTour: Đối tượng Tour chính được Servlet DetailController.java nạp từ DB (bằng tourDAO.getTourById(id))
    //   và đẩy vào request attribute để JSP này hiển thị thông tin động.
    request.setAttribute("extraCss", "css/detail.css");
    Tour activeTour = (Tour) request.getAttribute("tour");
%>
<!-- Nhúng header dùng chung cho toàn bộ website, nằm trong thư mục web/common/ -->
<jsp:include page="../common/header.jsp" />

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
                    <button class="btn btn-secondary btn-icon-text btn-wishlist-detail" id="wishlist-detail-btn">
                        <i data-lucide="heart"></i> Lưu vào Yêu thích
                    </button>
                </div>
            </div>
        </div>
    </section>

    <!-- MASONRY IMAGE GALLERY -->
    <section class="tour-gallery-section">
        <div class="container">
            <div class="masonry-gallery" id="photo-gallery-grid">
                <!-- Main big photo (Left) -->
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
                %>
                <div class="gallery-item main-photo">
                    <img src="${pageContext.request.contextPath}/<%= mainImgUrl %>" alt="Tour chính" id="gallery-main-img">
                    <button class="btn-play-video" id="play-video-btn">
                        <i data-lucide="play"></i> Xem Video
                    </button>
                </div>
                <!-- Sub photos (Right grid) -->
                <div class="gallery-item sub-photo sub-1">
                    <img src="${pageContext.request.contextPath}/assets/images/tour_halong.png" alt="Ảnh phụ 1" class="gallery-thumb" data-index="1">
                </div>
                <div class="gallery-item sub-photo sub-2">
                    <img src="${pageContext.request.contextPath}/assets/images/tour_phuquoc.png" alt="Ảnh phụ 2" class="gallery-thumb" data-index="2">
                </div>
                <div class="gallery-item sub-photo sub-3">
                    <img src="${pageContext.request.contextPath}/assets/images/hero_beach.png" alt="Ảnh phụ 3" class="gallery-thumb" data-index="3">
                </div>
                <div class="gallery-item sub-photo sub-4">
                    <img src="${pageContext.request.contextPath}/assets/images/tour_dalat.png" alt="Ảnh phụ 4" class="gallery-thumb" data-index="4">
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
                            <span class="label">Số người tối đa</span>
                            <strong id="hl-group-size">15 Khách</strong>
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

                <!-- Tour Guide Profile Widget -->
                <div class="tour-guide-profile-widget">
                    <h3>Hướng Dẫn Viên Đồng Hành</h3>
                    <div class="guide-profile-flex">
                        <img src="" alt="Hướng dẫn viên" class="guide-big-avatar" id="guide-avatar-img">
                        <div class="guide-profile-details">
                            <h4 id="guide-name-txt">Đang tải...</h4>
                            <p class="guide-rating-row"><i data-lucide="star"></i> <strong id="guide-rating-txt">4.9★</strong> (<span id="guide-tours-txt">42</span> tour đã dẫn)</p>
                            <p class="guide-bio" id="guide-bio-txt">"Đang tải giới thiệu..."</p>
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
                <!-- LÝ DO VÀ CHỨC NĂNG CỦA ĐOẠN NÀY:
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
                                    
                                    // Hiển thị dự phòng (Fallback) nếu DB trống
                                    if (!hasIncluded) {
                                %>
                                <li><i data-lucide="car"></i> Xe du lịch đưa đón suốt tuyến cao cấp</li>
                                <li><i data-lucide="hotel"></i> Lưu trú tại khách sạn/resort 5 sao hoặc cắm trại cao cấp</li>
                                <li><i data-lucide="utensils"></i> Các bữa ăn trong chương trình (Đặc sản địa phương Á - Âu)</li>
                                <li><i data-lucide="ticket"></i> Vé tham quan tất cả các điểm trong hành trình</li>
                                <li><i data-lucide="shield"></i> Bảo hiểm du lịch quốc tế/nội địa mức đền bù tối đa</li>
                                <li><i data-lucide="sparkles"></i> Nước uống, khăn lạnh và trang thiết bị an toàn đi kèm</li>
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
                                    
                                    // Hiển thị dự phòng (Fallback) nếu DB trống
                                    if (!hasExcluded) {
                                %>
                                <li><i data-lucide="plane"></i> Vé máy bay khứ hồi (Nếu khách khởi hành từ tỉnh khác)</li>
                                <li><i data-lucide="glass-water"></i> Đồ uống có cồn và chi tiêu mua sắm cá nhân ngoài chương trình</li>
                                <li><i data-lucide="badge-dollar-sign"></i> Tiền tip (bồi dưỡng) cho HDV và tài xế (Không bắt buộc)</li>
                                <li><i data-lucide="landmark"></i> Thuế VAT 8% (Chỉ tính khi yêu cầu xuất hóa đơn đỏ)</li>
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
                            <span class="big-score" id="scorecard-avg">0.0</span>
                            <div class="stars-row"><i data-lucide="star"></i><i data-lucide="star"></i><i data-lucide="star"></i><i data-lucide="star"></i><i data-lucide="star"></i></div>
                            <span class="reviews-count-label" id="scorecard-total">Dựa trên 0 đánh giá</span>
                        </div>
                        <div class="scorecard-right">
                            <div class="rating-bar-item" data-star="5">
                                <span>5 ★</span>
                                <div class="rating-bar-bg"><div class="rating-bar-fill" style="width: 0%;"></div></div>
                                <span class="rating-percent">0%</span>
                            </div>
                            <div class="rating-bar-item" data-star="4">
                                <span>4 ★</span>
                                <div class="rating-bar-bg"><div class="rating-bar-fill" style="width: 0%;"></div></div>
                                <span class="rating-percent">0%</span>
                            </div>
                            <div class="rating-bar-item" data-star="3">
                                <span>3 ★</span>
                                <div class="rating-bar-bg"><div class="rating-bar-fill" style="width: 0%;"></div></div>
                                <span class="rating-percent">0%</span>
                            </div>
                            <div class="rating-bar-item" data-star="2">
                                <span>2 ★</span>
                                <div class="rating-bar-bg"><div class="rating-bar-fill" style="width: 0%;"></div></div>
                                <span class="rating-percent">0%</span>
                            </div>
                            <div class="rating-bar-item" data-star="1">
                                <span>1 ★</span>
                                <div class="rating-bar-bg"><div class="rating-bar-fill" style="width: 0%;"></div></div>
                                <span class="rating-percent">0%</span>
                            </div>
                        </div>
                    </div>

                    <div class="reviews-list-container" id="reviews-list-container">
                        <!-- Rendered by detail.js -->
                    </div>

                    <!-- BIỂU MẪU ĐĂNG KÝ BÌNH LUẬN / ĐÁNH GIÁ (ADD REVIEW FORM)
                         Lý do tại sao lại phải làm như vậy:
                         - Cho phép khách hàng chia sẻ cảm nhận, bình chọn số sao thực tế từ 1-5.
                         - Form post dữ liệu trực tiếp lên DetailController (/detail) thông qua phương thức POST.
                         - Sử dụng 2 hidden input để truyền tourId (xác định tour được review) và rating (sao).
                         - Tên các thẻ input (name="name", name="email", name="content") trùng khớp với tham số
                           Servlet đọc bằng request.getParameter(). -->
                    <div class="add-review-card">
                        <h4>Chia Sẻ Trải Nghiệm Của Bạn</h4>
                        <p>Ý kiến của bạn giúp cộng đồng du lịch có thêm những quyết định đúng đắn.</p>
                        
                        <form class="add-review-form" id="new-review-form" action="${pageContext.request.contextPath}/detail" method="POST">
                            <!-- Lưu ID của Tour để Controller biết cần gán review này cho tour nào -->
                            <input type="hidden" name="tourId" value="<%= activeTour != null ? activeTour.getTourId() : 1 %>">
                            <!-- Lưu số sao đánh giá (sẽ được cập nhật bằng JS khi người dùng click vào các ngôi sao bên dưới) -->
                            <input type="hidden" name="rating" id="review-rating-input" value="5">
                            
                            <div class="form-rating-selector">
                                <span>Đánh giá của bạn:</span>
                                <div class="stars-selector-row" id="stars-selector">
                                    <i data-lucide="star" class="star-select" data-rating="1"></i>
                                    <i data-lucide="star" class="star-select" data-rating="2"></i>
                                    <i data-lucide="star" class="star-select" data-rating="3"></i>
                                    <i data-lucide="star" class="star-select" data-rating="4"></i>
                                    <i data-lucide="star" class="star-select" data-rating="5"></i>
                                </div>
                            </div>
                            
                            <div class="form-grid">
                                <div class="form-group">
                                    <label for="rev-name">Họ & Tên *</label>
                                    <input type="text" id="rev-name" name="name" placeholder="Ví dụ: Nguyễn Văn A" required>
                                </div>
                                <div class="form-group">
                                    <label for="rev-email">Email (Sẽ được ẩn) *</label>
                                    <input type="email" id="rev-email" name="email" placeholder="example@mail.com" required>
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
                                    <span>Tải ảnh lên (Mô phỏng)</span>
                                </div>
                                <div class="uploaded-images-preview" id="uploaded-images-preview-row"></div>
                            </div>

                            <button type="submit" class="btn btn-primary">Gửi Đánh Giá</button>
                        </form>
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
                                <h4>Chính sách hủy tour du lịch của Mirai Travels như thế nào?</h4>
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
                        
                        <div class="booking-card-price-header">
                            <div class="price-side-left">
                                <span class="sidebar-price-label">Giá mỗi khách</span>
                                <span class="sidebar-price-value" id="booking-base-price">0 đ</span>
                            </div>
                            <div class="price-side-right" id="booking-seats-left-pill">
                                <span>Chỉ còn 6 chỗ!</span>
                            </div>
                        </div>

                        <div class="booking-form-fields-wrapper">
                            <div class="booking-field-group">
                                <label for="book-date"><i data-lucide="calendar"></i> Ngày khởi hành</label>
                                <input type="date" id="book-date" required>
                            </div>

                            <div class="booking-field-group">
                                <label for="book-travelers"><i data-lucide="users"></i> Số lượng khách</label>
                                <select id="book-travelers">
                                    <option value="1">1 Người lớn</option>
                                    <option value="2" selected>2 Người lớn</option>
                                    <option value="3">3 Người lớn</option>
                                    <option value="4">4 Người lớn</option>
                                    <option value="5">5+ Người lớn</option>
                                </select>
                            </div>
                        </div>

                        <div class="booking-bill-calculations" id="booking-bill-row">
                            <div class="bill-line">
                                <span id="bill-calc-label">2 khách x 0 đ</span>
                                <span id="bill-subtotal-val">0 đ</span>
                            </div>
                            <div class="bill-line text-discount" id="promo-discount-line" style="display: none;">
                                <span>Mã giảm giá (MIRAI2026)</span>
                                <span id="bill-discount-val">-0 đ</span>
                            </div>
                            <div class="bill-line">
                                <span>Thuế du lịch (VAT 8%)</span>
                                <span id="bill-tax-val">0 đ</span>
                            </div>
                            <hr class="bill-divider">
                            <div class="bill-line total-price">
                                <span>Tổng chi phí</span>
                                <span id="bill-total-val">0 đ</span>
                            </div>
                        </div>

                        <div class="booking-coupon-wrapper">
                            <input type="text" id="promo-code-input" placeholder="Nhập mã giảm giá (MIRAI2026)">
                            <button type="button" class="btn btn-secondary" id="apply-promo-btn">Áp dụng</button>
                        </div>
                        <div class="promo-success-message" id="promo-message-txt"></div>

                        <button type="button" class="btn btn-primary btn-block btn-booking-submit" id="submit-booking-btn">
                            Đặt Ngay & Thanh Toán
                        </button>
                        
                        <p class="booking-card-security-note"><i data-lucide="shield-check"></i> Đảm bảo hoàn tiền 100% | Thanh toán an toàn SSL</p>
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
                <p>Khám phá thêm các địa danh du lịch kỳ thú có thể bạn sẽ muốn thêm vào danh sách tiếp theo.</p>
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
                int seatsLeft = 10;
                int seatsTotal = 20;
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
            rating: <%= t.getRating() %>,
            reviews: <%= t.getReviewsCount() %>,
            priceVND: <%= t.getBasePrice() %>,
            duration: <%= t.getDurationDays() %>,
            difficulty: "<%= diffStr %>",
            category: "<%= catStr %>",
            seatsLeft: <%= seatsLeft %>,
            seatsTotal: <%= seatsTotal %>,
            guide: { 
                name: "<%= guideName %>", 
                avatar: "<%= guideAvatar %>",
                rating: <%= guideRating %>,
                toursLed: <%= guideToursLed %>,
                expYears: <%= guideExp %>,
                bio: "<%= guideBio.replace("\"", "\\\"").replace("\n", " ").replace("\r", "") %>"
            },
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
    // Define daily itineraries data (with default fallbacks)
    window.itinerariesData = {
        1: [
            { day: 1, title: "Đón đoàn - Di chuyển đi Bà Nà Hills - Trải nghiệm Làng Pháp", desc: "Đón khách tại sân bay Đà Nẵng. Di chuyển lên đỉnh Bà Nà bằng hệ thống cáp treo đạt nhiều kỷ lục. Khám phá lâu đài cổ kính kiểu Pháp, lâu đài tâm linh và thưởng thức buffet trưa thịnh soạn.", icon: "cable-car" },
            { day: 2, title: "Check-in Cầu Vàng huyền ảo - Tham quan hầm rượu cổ Debay & Chùa Linh Ứng", desc: "Đón bình minh sớm trên Cầu Vàng (Golden Bridge) tuyệt đẹp không bóng người. Khám phá Vườn hoa Le Jardin D'Amour rực rỡ, hầm rượu cổ sâu trong lòng đất và chùa Linh Ứng uy nghiêm.", icon: "camera" },
            { day: 3, title: "Khám phá danh thắng Ngũ Hành Sơn - Mua sắm đặc sản - Tiễn đoàn", desc: "Xuống cáp treo, di chuyển tham quan quần thể Ngũ Hành Sơn kỳ bí, ghé thăm làng đá mỹ nghệ Non Nước. Tự do mua sắm quà lưu niệm và xe tiễn đoàn ra sân bay Đà Nẵng kết thúc chuyến đi.", icon: "plane" }
        ],
        2: [
            { day: 1, title: "Chào đón Phú Quốc - Khám phá Dinh Cậu & Chợ đêm ẩm thực", desc: "Đón du khách tại sân bay Phú Quốc, nhận phòng resort 5 sao sát biển. Chiều tham quan Dinh Cậu tâm linh và ngắm hoàng hôn đỏ lịm. Tối dạo chơi tự do và thưởng thức hải sản tại Chợ đêm Đảo Ngọc.", icon: "palmtree" },
            { day: 2, title: "Lên Du thuyền sang trọng - Câu cá & Lặn ngắm san hô Hòn Móng Tay", desc: "Lên tàu cao cấp du ngoạn 4 đảo phía Nam. Trải nghiệm câu cá giải trí, bơi lặn ngắm san hô tự nhiên tại Hòn Móng Tay, Hòn Gầm Ghì, Hòn Mây Rút. Thưởng thức bữa trưa hải sản thịnh soạn chế biến trực tiếp trên tàu.", icon: "ship" },
            { day: 3, title: "Tham quan Safari hoang dã - Khám phá siêu quần thể Grand World", desc: "Ghé thăm Công viên bảo tồn động vật bán hoang dã Vinpearl Safari lớn nhất Việt Nam. Chiều tối hòa mình vào không gian lễ hội Châu Âu thu nhỏ của siêu dự án Grand World không ngủ.", icon: "sparkles" },
            { day: 4, title: "Ghé thăm Nhà thùng Nước mắm truyền thống - Tiễn sân bay", desc: "Tìm hiểu quy trình ủ nước mắm cá cơm Phú Quốc nổi tiếng tại nhà thùng cổ truyền. Ghé mua sắm đặc sản tiêu sọ, ngọc trai Phú Quốc làm quà và xe đưa ra sân bay tiễn đoàn.", icon: "plane" }
        ],
        3: [
            { day: 1, title: "Đón Cảng Tuần Châu - Lên Du thuyền 5 sao - Khám phá Hang Sửng Sốt", desc: "Đoàn làm thủ tục lên tàu tại Cảng Tuần Châu. Thưởng thức đồ uống chào mừng, nghe phổ biến an toàn. Tàu nhổ neo xuyên vịnh, tham quan Hang Sửng Sốt - hang động lớn và đẹp nhất vịnh Hạ Long với thạch nhũ lấp lánh.", icon: "ship" },
            { day: 2, title: "Chèo kayak Hang Luồn - Chinh phục đảo Ti Tốp - Trở về cảng", desc: "Đón ngày mới với bài tập Thái Cực Quyền trên boong tàu. Chèo thuyền Kayak xuyên qua vách đá Hang Luồn kỳ bí. Chinh phục đỉnh núi đảo Ti Tốp ngắm toàn cảnh Vịnh Hạ Long từ trên cao trước khi tàu cập bến cảng Tuần Châu.", icon: "mountain" }
        ],
        4: [
            { day: 1, title: "Chào Hội An cổ kính - Khám phá thánh địa Mỹ Sơn kỳ bí", desc: "Đoàn di chuyển tham quan Thánh địa Mỹ Sơn - thủ đô đền tháp của vương triều Chăm Pa xưa cổ. Chiều tối nhận phòng khách sạn, tản bộ ngắm phố cổ Hội An lên đèn lung linh huyền ảo.", icon: "landmark" },
            { day: 2, title: "Trải nghiệm đi thuyền gỗ thả đèn hoa đăng sông Hoài - Học làm đèn lồng", desc: "Tự tay làm một chiếc đèn lồng Hội An nhỏ xinh dưới sự hướng dẫn của nghệ nhân. Chiều mát lên thuyền thả đèn hoa đăng lung linh dọc dòng sông Hoài thơ mộng cầu an lành.", icon: "heart" }
        ],
        5: [
            { day: 1, title: "Đón sân bay Liên Khương - Check-in Đà Lạt mộng mơ - Chợ đêm", desc: "Xe đón đoàn di chuyển lên cao nguyên Đà Lạt trong lành. Nhận phòng khách sạn, chiều tham quan ga xe lửa cổ Đà Lạt và check-in quảng trường Lâm Viên. Tối tự do ăn uống lẩu gà lá é và dạo chợ đêm.", icon: "map-pin" },
            { day: 2, title: "Săn mây bình minh Đồi chè Cầu Đất - Chinh phục Langbiang huyền thoại", desc: "Thức dậy sớm di chuyển săn mây bồng bềnh tại cầu gỗ đồi chè Cầu Đất. Chiều trekking/đi xe jeep chinh phục đỉnh Langbiang huyền thoại ngắm dòng sông Vàng từ đỉnh núi sương mù.", icon: "mountain" },
            { day: 3, title: "Thăm vườn dâu tây công nghệ cao - Thác Datanla - Trở về", desc: "Ghé thăm vườn dâu tây tươi hái tại vườn. Trải nghiệm máng trượt xuyên thác nước Datanla kỳ vĩ trước khi xe tiễn đoàn ra sân bay Liên Khương kết thúc tour.", icon: "plane" }
        ],
        6: [
            { day: 1, title: "Đón Sa Pa - Trekking Bản Cát Cát hoang sơ - Thung lũng Mường Hoa", desc: "Xe giường nằm đón du khách đến thị trấn Sa Pa mù sương. Buổi chiều trekking tản bộ dọc theo bản Cát Cát xinh đẹp của người đồng bào H'Mông, ngắm ruộng bậc thang trải dài và thác nước Cát Cát thơ mộng.", icon: "activity" },
            { day: 2, title: "Chinh phục Đỉnh núi Fansipan bằng Cáp treo - Cột mốc Nóc nhà Đông Dương", desc: "Di chuyển bằng tàu hỏa leo núi Mường Hoa, sau đó lên Cáp treo Fansipan vượt qua thung lũng mây kỳ vĩ. Chinh phục 600 bậc đá để chạm tay vào chóp inox 3.143m huyền thoại - Nóc nhà của Đông Dương.", icon: "mountain" },
            { day: 3, title: "Thăm Bản Tả Phìn yên bình - Trải nghiệm tắm lá thuốc Dao Đỏ - Trở về Hà Nội", desc: "Ghé thăm bản Tả Phìn nguyên sơ, tự do trải nghiệm tắm lá thuốc thảo mộc của người Dao Đỏ để xua tan mệt mỏi. Trưa mua sắm nông sản hạt dẻ, nấm hương trước khi lên xe về lại Hà Nội.", icon: "plane" }
        ],
        7: [
            { day: 1, title: "Chào Nha Trang nắng vàng - Khám phá Chùa Long Sơn & Tháp Bà Ponagar", desc: "Xe đón khách đưa đi tham quan di tích lịch sử vương triều Chăm cổ Tháp Bà Ponagar, chiêm ngưỡng tượng Phật trắng chùa Long Sơn. Nhận phòng khách sạn cao cấp sát biển Nha Trang.", icon: "landmark" },
            { day: 2, title: "Lên ca-nô cao tốc - Đi bộ dưới đại dương ngắm san hô Hòn Mun", desc: "Trải nghiệm lặn biển và đi bộ dưới đáy biển (Sea Walk) ngắm san hô, cá màu rực rỡ tại khu bảo tồn biển Hòn Mun bằng mũ dưỡng khí công nghệ cao. Trưa ăn trưa dã ngoại hải sản trên Bè nổi.", icon: "anchor" },
            { day: 3, title: "Vui chơi thả ga VinWonders đảo Hòn Tre", desc: "Dành trọn vẹn 1 ngày vui chơi tại thiên đường giải trí VinWonders Nha Trang với cáp treo vượt biển, công viên nước khổng lồ và các show diễn thực cảnh Tata Show triệu đô đầy choáng ngợp.", icon: "sparkles" },
            { day: 4, title: "Mua sắm hải sản Chợ Đầm - Xe tiễn sân bay Cam Ranh", desc: "Mua sắm đặc sản yến sào, mực khô, nem nướng tại Chợ Đầm lịch sử. Xe tiễn đoàn ra sân bay Cam Ranh kết thúc chuyến du lịch biển tuyệt vời.", icon: "plane" }
        ],
        8: [
            { day: 1, title: "Hành trình Hà Nội - Hà Giang - Cổng trời Quản Bạ - Rừng thông Yên Minh", desc: "Khởi hành từ Hà Nội đi Hà Giang. Dừng chân check-in Dốc Bắc Sum quanh co và Cổng trời Quản Bạ ngắm núi đôi Cô Tiên. Chiều đi qua rừng thông Yên Minh xanh mát, nhận phòng homestay người Tày.", icon: "activity" },
            { day: 2, title: "Cột cờ Lũng Cú địa đầu - Dinh thự Vua Mèo cổ kính - Phố cổ Đồng Văn", desc: "Check-in Cột cờ quốc gia Lũng Cú cực kỳ tự hào. Tham quan kiến trúc cổ kính giao thoa Pháp-Hoa của Dinh thự Vua Mèo Vương Chính Đức. Tối dạo chơi uống cafe Phố cổ Đồng Văn trong gió lạnh vùng cao.", icon: "landmark" },
            { day: 3, title: "Chinh phục Đệ nhất hùng đèo Mã Pí Lèng - Du thuyền hẻm vực sông Nho Quế", desc: "Vượt qua những khúc cua ngoạn mục đèo Mã Pí Lèng kỳ vĩ bậc nhất Việt Nam. Xuống bến thuyền tản bộ dọc hẻm Tu Sản sâu nhất Đông Nam Á và đi thuyền trên dòng sông Nho Quế xanh biếc thơ mộng.", icon: "mountain" },
            { day: 4, title: "Check-in Dốc Thẩm Mã huyền thoại - Mua sắm sản vật - Hà Nội", desc: "Chụp ảnh lưu niệm tại Dốc Thẩm Mã - con dốc nổi tiếng nhất Hà Giang với những em bé dân tộc đeo gùi hoa. Ghé mua mật ong bạc hà đặc sản trước khi xe chạy xuyên đêm tiễn về lại Hà Nội.", icon: "plane" }
        ]
    };

    // LÝ DO VÀ CHỨC NĂNG CỦA ĐOẠN DƯỚI ĐÂY:
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

    // LÝ DO VÀ CHỨC NĂNG CỦA ĐOẠN ĐÁNH GIÁ (REVIEWS):
    // - Dữ liệu đánh giá thật trong cơ sở dữ liệu được nạp lên và đưa vào thuộc tính reviews của activeTour.
    // - Ta cần kết xuất danh sách này sang JSON (gán vào thuộc tính của window.reviewsData) để detail.js có thể vẽ
    //   lưới đánh giá động (Reviews list) và scorecard tính điểm trung bình thật.
    // - Nếu DB của tour này chưa có ai viết review, hệ thống tự động in ra các review mẫu (fallback) tương thích với tour
    //   để giữ giao diện chuyên nghiệp.
    window.reviewsData = {
        <%
            if (activeTour != null) {
                List<Review> revs = activeTour.getReviews();
        %>
        <%= activeTour.getTourId() %>: [
            <%
                if (revs != null && !revs.isEmpty()) {
                    for (int k = 0; k < revs.size(); k++) {
                        Review r = revs.get(k);
                        // Định dạng ngày đăng theo kiểu Việt Nam dd/MM/yyyy
                        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                        String dateStr = sdf.format(r.getCreatedAt());
                        String name = r.getCustomerName() != null ? r.getCustomerName() : "Khách hàng";
                        // Link ảnh đại diện mặc định nếu khách hàng không tải avatar lên
                        String avatar = r.getCustomerAvatar() != null ? r.getCustomerAvatar() : "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80";
            %>
            {
                name: "<%= name.replace("\"", "\\\"") %>",
                rating: <%= r.getRating() %>,
                date: "<%= dateStr %>",
                text: "<%= r.getContent().replace("\"", "\\\"").replace("\r", "").replace("\n", " ") %>",
                isVerified: <%= r.isIsVerified() %>,
                avatar: "<%= avatar %>"
            }<%= (k < revs.size() - 1) ? "," : "" %>
            <%
                    }
                } else {
                    // Trường hợp DB chưa có review nào cho tour, in ra reviews mẫu dựa theo ID của Tour
                    if (activeTour.getTourId() == 1) {
            %>
            { name: "Phạm Minh Hoàng", rating: 5, date: "15/05/2026", text: "Chuyến đi Vịnh Hạ Long tuyệt vời! Du thuyền sang trọng, cabin sạch sẽ rộng rãi. Đồ ăn hải sản tươi ngon phong phú, nhân viên phục vụ tận tình chu đáo. Trải nghiệm chèo thuyền kayak qua hang Luồn rất thú vị, cảnh quan thiên nhiên tráng lệ đáng để trải nghiệm.", isVerified: true, avatar: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80" },
            { name: "Lê Minh Thư", rating: 5, date: "14/05/2026", text: "Dịch vụ của Mirai Travels cực kỳ chuyên nghiệp. Đón trả khách đúng giờ, hướng dẫn viên nhiệt tình vui vẻ am hiểu lịch sử địa phương. Khách sạn/Du thuyền chất lượng đúng chuẩn 5 sao, gia đình tôi đã có kỳ nghỉ vô cùng ý nghĩa.", isVerified: true, avatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=80&q=80" }
            <%
                    } else if (activeTour.getTourId() == 2) {
            %>
            { name: "Lê Minh Thư", rating: 5, date: "14/05/2026", text: "Trải nghiệm tuyệt vời tại Đà Nẵng và Hội An. Check-in Cầu Vàng sáng sớm trời mát mẻ chụp hình siêu đẹp. Phố cổ Hội An lung linh sắc đèn lồng về đêm, trải nghiệm thả hoa đăng sông Hoài thơ mộng. Đồ ăn buffet trên Bà Nà Hills rất ngon và đa dạng.", isVerified: true, avatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=80&q=80" }
            <%
                    } else if (activeTour.getTourId() == 3) {
            %>
            { name: "Phạm Minh Hoàng", rating: 4, date: "15/05/2026", text: "Sapa mây mù giăng lối rất đẹp, khách sạn view thung lũng Mường Hoa thơ mộng. Chinh phục đỉnh Fansipan bằng cáp treo rất nhanh chóng, đứng trên nóc nhà Đông Dương cảm giác tự hào ngập tràn. Trekking bản Cát Cát hơi mỏi chân nhưng cảnh sắc rất hoang sơ bình yên.", isVerified: true, avatar: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80" }
            <%
                    } else {
            %>
            { name: "Trần Anh Tuấn", rating: 5, date: "20/05/2026", text: "Dịch vụ đẳng cấp chuyên nghiệp! Đưa đón đúng giờ, hướng dẫn viên nhiệt tình vui tính. Các điểm tham quan cực đẹp, khách sạn resort ở siêu thích. Chắc chắn sẽ tiếp tục ủng hộ Mirai trong các hành trình du lịch tiếp theo.", isVerified: true, avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=80&q=80" },
            { name: "Lê Minh Thư", rating: 5, date: "14/05/2026", text: "Trải nghiệm du lịch 5 sao đáng tiền từng xu. Thức ăn siêu ngon đa dạng, lịch trình sắp xếp cực kỳ khoa học không gây cảm giác mệt mỏi. Gia đình tôi đều rất hài lòng.", isVerified: true, avatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=80&q=80" }
            <%
                    }
                }
            %>
        ]
        <%
            }
        %>
    };
</script>

<%
    // CHỨC NĂNG CỦA ĐOẠN NÀY:
    // - extraScript: header/footer dùng chung sẽ đọc thuộc tính này để tự động nhúng file JavaScript detail.js
    //   ở phía cuối trang, đảm bảo trang HTML được load xong hết mới chạy script xử lý giao diện.
%>
<% request.setAttribute("extraScript", "js/detail.js"); %>
<jsp:include page="../common/footer.jsp" />
