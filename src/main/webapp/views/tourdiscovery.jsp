<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="java.util.List" %>
<%@ page import="Entities.Tour" %>
<%@ page import="Entities.TourCategory" %>
<%@ page import="Entities.TourSchedule" %>
<%@ page import="Entities.TourMedia" %>
<%
    request.setAttribute("extraCss", "css/tourdiscovery.css");
    request.setAttribute("bodyClass", "explore-page");
%>
<jsp:include page="../common/header.jsp" />

    <section class="explore-search-section">
        <div class="container">
            <form class="explore-search-bar" id="explore-search-form">
                <div class="search-field">
                    <label for="search-destination">Điểm đến</label>
                    <div class="search-input-group">
                        <i data-lucide="map-pin" class="input-icon"></i>
                        <input type="text" placeholder="Đà Nẵng, Phú Quốc, Hạ Long..." id="search-destination" list="destination-list" value="<%= request.getAttribute("searchDest") != null ? request.getAttribute("searchDest") : "" %>">
                        <datalist id="destination-list">
                            <c:forEach var="dest" items="${destinations}">
                                <option value="${dest}">
                            </c:forEach>
                        </datalist>
                    </div>
                </div>
                <div class="search-field">
                    <label for="search-date">Ngày khởi hành</label>
                    <div class="search-input-group">
                        <i data-lucide="calendar" class="input-icon"></i>
                        <input type="date" id="search-date" class="date-input" value="<%= request.getAttribute("searchDate") != null ? request.getAttribute("searchDate") : "" %>">
                    </div>
                </div>
                <div class="search-field">
                    <label for="search-guests">Số khách</label>
                    <div class="search-input-group">
                        <i data-lucide="users" class="input-icon"></i>
                        <select id="search-guests">
                            <option value="1">1 Khách</option>
                            <option value="2" selected>2 Khách</option>
                            <option value="3">3 Khách</option>
                            <option value="4">4 Khách</option>
                            <option value="5">5+ Khách</option>
                        </select>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary btn-search" id="explore-search-submit">
                    <i data-lucide="search"></i>
                    <span>Tìm Kiếm</span>
                </button>
            </form>
        </div>
    </section>

    <main class="explore-container">
        <div class="mobile-floating-controls">
            <button class="btn btn-primary" id="mobile-filter-trigger"><i data-lucide="sliders"></i> Lọc Tour</button>
            <button class="btn btn-secondary" id="mobile-map-toggle"><i data-lucide="map"></i> Bản đồ</button>
        </div>

        <aside class="filter-sidebar" id="filter-sidebar">
            <div class="filter-sidebar-header">
                <h3>Bộ Lọc</h3>
                <button type="button" class="btn-text" id="clear-filters-btn">Xóa tất cả</button>
                <button type="button" class="close-sidebar-btn" id="close-filters-btn" aria-label="Đóng bộ lọc"><i data-lucide="x"></i></button>
            </div>

            <div class="filter-groups-wrapper">
                <div class="filter-group filter-card">
                    <h4>Ngân sách</h4>
                    <div class="range-slider-wrapper">
                        <div class="range-labels">
                            <span>Tối thiểu</span>
                            <span id="price-limit-val" class="active-val">Tối đa</span>
                        </div>
                        <input type="range" id="filter-price" class="budget-slider">
                    </div>
                </div>

                <div class="filter-group filter-card">
                    <h4>Danh mục</h4>
                    <div class="checkbox-list">
                        <% 
                            List<TourCategory> categories = (List<TourCategory>) request.getAttribute("categories");
                            if (categories != null) {
                                for (TourCategory cat : categories) {
                                    String catName = cat.getCategoryName();
                                    String catVal = "luxury";
                                    if (catName.toLowerCase().contains("biển")) catVal = "beach";
                                    else if (catName.toLowerCase().contains("núi") || catName.toLowerCase().contains("trekking") || catName.toLowerCase().contains("hiking")) catVal = "hiking";
                                    else if (catName.toLowerCase().contains("văn hóa") || catName.toLowerCase().contains("di sản") || catName.toLowerCase().contains("cultural")) catVal = "cultural";
                                    else if (catName.toLowerCase().contains("city") || catName.toLowerCase().contains("mạo hiểm")) catVal = "adventure";
                                    else if (catName.toLowerCase().contains("mice") || catName.toLowerCase().contains("gia đình")) catVal = "family";
                                    else if (catName.toLowerCase().contains("cao cấp") || catName.toLowerCase().contains("luxury")) catVal = "luxury";
                        %>
                        <label class="checkbox-label">
                            <input type="checkbox" name="category" value="<%= catVal %>" class="filter-checkbox">
                            <span><%= catName %></span>
                        </label>
                        <% 
                                }
                            }
                        %>
                    </div>
                </div>

                <div class="filter-group filter-card">
                    <h4>Thời lượng</h4>
                    <div class="radio-list">
                        <label class="radio-label">
                            <input type="radio" name="duration" value="all" checked class="filter-radio">
                            <span>Tất cả</span>
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="duration" value="1-3" class="filter-radio">
                            <span>1 - 3 ngày</span>
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="duration" value="4-6" class="filter-radio">
                            <span>4 - 6 ngày</span>
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="duration" value="7+" class="filter-radio">
                            <span>Từ 7 ngày</span>
                        </label>
                    </div>
                </div>

                <div class="filter-group filter-card">
                    <h4>Độ khó</h4>
                    <div class="difficulty-chips">
                        <span class="difficulty-chip" data-val="easy">Nhẹ nhàng</span>
                        <span class="difficulty-chip" data-val="medium">Vừa phải</span>
                        <span class="difficulty-chip" data-val="hard">Thử thách</span>
                    </div>
                </div>

                <div class="filter-group filter-card">
                    <h4>Đánh giá</h4>
                    <div class="checkbox-list">
                        <label class="checkbox-label">
                            <input type="checkbox" name="rating" value="4.8" class="filter-checkbox">
                            <span>4.8★ trở lên</span>
                        </label>
                        <label class="checkbox-label">
                            <input type="checkbox" name="rating" value="4.5" class="filter-checkbox">
                            <span>4.5★ trở lên</span>
                        </label>
                        <label class="checkbox-label">
                            <input type="checkbox" name="rating" value="4.0" class="filter-checkbox">
                            <span>4.0★ trở lên</span>
                        </label>
                    </div>
                </div>

                <div class="filter-group filter-card">
                    <h4>Loại tour</h4>
                    <div class="radio-list">
                        <label class="radio-label">
                            <input type="radio" name="tour-type" value="all" checked class="filter-radio">
                            <span>Tất cả loại tour</span>
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="tour-type" value="group" class="filter-radio">
                            <span>Tour đoàn</span>
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="tour-type" value="private" class="filter-radio">
                            <span>Tour riêng</span>
                        </label>
                    </div>
                </div>

                <div class="filter-group filter-card">
                    <h4>Điểm khởi hành</h4>
                    <div class="checkbox-list">
                        <c:forEach var="city" items="${departureCities}">
                            <label class="checkbox-label">
                                <input type="checkbox" name="departure" value="${city}" class="filter-checkbox">
                                <span>${city}</span>
                            </label>
                        </c:forEach>
                    </div>
                </div>

                <div class="filter-group filter-card">
                    <h4>Chỗ trống</h4>
                    <div class="radio-list">
                        <label class="radio-label">
                            <input type="radio" name="seats" value="all" checked class="filter-radio">
                            <span>Tất cả</span>
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="seats" value="available" class="filter-radio">
                            <span>Còn nhiều chỗ</span>
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="seats" value="limited" class="filter-radio">
                            <span>Sắp hết chỗ</span>
                        </label>
                    </div>
                </div>
            </div>

            <div class="mobile-filter-footer">
                <button type="button" class="btn btn-primary btn-block" id="apply-filters-btn">Áp dụng bộ lọc</button>
            </div>
        </aside>

        <section class="explore-results-section">
            <div class="explore-results-header">
                <div class="results-count">
                    Tìm thấy <span id="matching-count">0</span> tour du lịch
                </div>
                <div class="sorting-selector-wrapper">
                    <label for="sort-select">Sắp xếp:</label>
                    <select id="sort-select" aria-label="Bộ sắp xếp">
                        <option value="recommended">Gợi ý hàng đầu</option>
                        <option value="price-asc">Giá: Thấp → Cao</option>
                        <option value="price-desc">Giá: Cao → Thấp</option>
                        <option value="rating">Đánh giá cao nhất</option>
                    </select>
                    <button type="button" id="map-toggle-btn" class="btn btn-secondary btn-desktop-map-toggle">
                        <i data-lucide="map"></i>
                        <span>Xem bản đồ</span>
                    </button>
                </div>
            </div>

            <section class="explore-map-section collapsed" id="explore-map-pane" aria-label="Bản đồ điểm đến">
                <div class="map-panel-header">
                    <h3><i data-lucide="map-pin"></i> Bản đồ điểm đến Việt Nam</h3>
                    <button type="button" class="map-close-btn" id="map-close-btn" aria-label="Đóng bản đồ"><i data-lucide="x"></i></button>
                </div>
                <div class="map-inner-wrapper">
                    <svg class="vector-map-bg" viewBox="0 0 500 800" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
                        <rect width="100%" height="100%" fill="#e0f2fe"/>
                        <path d="M 180,40 Q 190,70 170,80 T 160,110 T 190,130 T 210,100 T 240,110 T 260,130 T 270,160 T 235,170 T 205,160 T 180,180 T 200,200 Q 215,220 220,250 T 240,290 T 260,330 T 270,380 T 290,420 Q 300,450 280,480 T 250,520 T 230,560 T 200,600 T 170,620 T 180,650 L 220,680 L 150,710 Q 120,700 90,690 L 80,630 Q 100,590 120,580 T 140,540 T 180,500 T 200,450 T 200,380 T 195,300 T 170,250 T 130,220 T 110,180 Q 100,120 120,80 T 160,50 Z" fill="#f0fdf4" stroke="#a7f3d0" stroke-width="2"/>
                        <text x="20" y="40" font-size="12" font-weight="700" fill="#0369a1">BẢN ĐỒ VIỆT NAM</text>
                        <text x="20" y="58" font-size="9" fill="#0284c7">Nhấn vào pin để xem tour</text>
                    </svg>
                    <div class="map-pins-overlay" id="map-pins-container"></div>
                    <div class="map-popup-card" id="map-popup"></div>
                </div>
            </section>

            <div class="explore-tours-grid" id="explore-grid"></div>

            <div class="pagination-container">
                <button class="pagination-btn" id="pag-prev" aria-label="Trang trước"><i data-lucide="chevron-left"></i></button>
                <div class="pagination-numbers" id="pag-numbers"></div>
                <button class="pagination-btn" id="pag-next" aria-label="Trang sau"><i data-lucide="chevron-right"></i></button>
            </div>
        </section>
    </main>

    <section class="section-padding recommendations-section-outer">
        <div class="container">
            <div class="section-header explore-rec-header">
                <h2>Tour Dành Cho Bạn</h2>
                <p>Các hành trình được gợi ý dựa trên xu hướng du lịch và đánh giá cao nhất.</p>
            </div>
            <div class="horizontal-scroll-container">
                <div class="rec-tours-grid" id="rec-tours-grid"></div>
            </div>
        </div>
    </section>

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
                 else if (t.getCategoryId() == 5) catStr = "family";
                 else if (t.getCategoryId() == 6) catStr = "adventure";
                 else if (t.getCategoryId() == 7) catStr = "wellness";
                 else if (t.getCategoryId() == 8) catStr = "food";
                 else if (t.getCategoryId() == 9) catStr = "shopping";
                
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
                
                // No mock guides needed
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
            photos: [
                <%
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

<% request.setAttribute("extraScript", "js/tourdiscovery.js"); %>
<jsp:include page="../common/footer.jsp" />
