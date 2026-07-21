<%-- 
    Màn hình 15: Manage Favorite Tours - Quản lý danh sách tour yêu thích
    Tác giả: Dương Quang Sơn
    MSSV: HE186525
    Ngày tạo: 2026-07-21
--%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ page import="Entities.Tour" %>
<%@ page import="Entities.TourMedia" %>
<%@ page import="Entities.TourSchedule" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("bodyClass", "wishlist-page");
    request.setAttribute("extraCss", "css/wishlist.css");
%>

<jsp:include page="/common/header.jsp"/>

<div class="wishlist-container">
    <div class="wishlist-header">
        <h1>Tour Y&#234;u Th&#237;ch C&#7911;a T&#244;i</h1>
        <p>Danh s&#225;ch c&#225;c h&#224;nh tr&#236;nh du l&#7883;ch b&#7841;n &#273;&#227; l&#432;u l&#7841;i &#273;&#7875; tham kh&#7843;o v&#224; l&#234;n l&#7883;ch tr&#236;nh.</p>
    </div>

    <!-- Empty State -->
    <div class="wishlist-empty" id="wishlist-empty-state" style="display: ${empty wishlistTours ? 'block' : 'none'};">
        <div class="wishlist-empty-icon">
            <i data-lucide="heart-off"></i>
        </div>
        <h2>Danh s&#225;ch y&#234;u th&#237;ch tr&#7889;ng</h2>
        <p>B&#7841;n ch&#432;a l&#432;u b&#7845;t k&#7923; tour du l&#7883;ch n&#224;o. H&#227;y c&#249;ng kh&#225;m ph&#225; c&#225;c &#273;i&#7875;m &#273;&#7871;n h&#7845;p d&#7851;n c&#249;ng TourBuddy!</p>
        <a href="${pageContext.request.contextPath}/tourdiscovery" class="btn btn-primary">
            <i data-lucide="compass"></i> Kh&#225;m Ph&#225; Tour Ngay
        </a>
    </div>

    <!-- Tour List Grid -->
    <c:if test="${not empty wishlistTours}">
        <div class="wishlist-grid">
            <c:forEach var="tour" items="${wishlistTours}">
                <div class="wishlist-card">
                    <div class="wishlist-img-wrapper">
                        <c:choose>
                            <c:when test="${not empty tour.mediaList}">
                                <img src="${pageContext.request.contextPath}/${tour.mediaList[0].mediaUrl}" alt="${tour.tourName}" class="wishlist-img">
                            </c:when>
                            <c:otherwise>
                                <img src="${pageContext.request.contextPath}/assets/images/tour_halong.png" alt="${tour.tourName}" class="wishlist-img">
                            </c:otherwise>
                        </c:choose>
                        <button class="wishlist-btn-remove" data-tour-id="${tour.tourId}" aria-label="X&#243;a kh&#7887;i y&#234;u th&#237;ch">
                            <i data-lucide="heart" fill="currentColor"></i>
                        </button>
                    </div>
                    <div class="wishlist-details">
                        <div class="wishlist-meta">
                            <div class="wishlist-rating">
                                <i data-lucide="star"></i>
                                <span>
                                    <c:choose>
                                        <c:when test="${tour.reviewsCount > 0}">
                                            <fmt:formatNumber value="${tour.rating}" maxFractionDigits="1"/> (${tour.reviewsCount} &#273;&#225;nh gi&#225;)
                                        </c:when>
                                        <c:otherwise>
                                            Ch&#432;a c&#243; &#273;&#225;nh gi&#225;
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                            <div class="wishlist-duration">
                                <i data-lucide="clock"></i>
                                <span>${tour.durationDays} Ng&#224;y</span>
                            </div>
                        </div>
                        <h3><c:out value="${tour.tourName}"/></h3>
                        
                        <!-- L&#7883;ch kh&#7903;i h&#224;nh g&#7847;n nh&#7845;t -->
                        <div style="font-size: 0.85rem; color: var(--slate-500); margin-bottom: 12px; display: flex; align-items: center; gap: 6px;">
                            <i data-lucide="calendar" style="width: 14px; height: 14px;"></i>
                            <span>
                                <c:choose>
                                    <c:when test="${not empty tour.schedules}">
                                        Kh&#7903;i h&#224;nh: <fmt:formatDate value="${tour.schedules[0].departureDate}" pattern="dd/MM/yyyy"/> (C&#242;n ${tour.schedules[0].availableSeats} ch&#7895;)
                                    </c:when>
                                    <c:otherwise>
                                        Li&#234;n h&#7879; &#273;&#7875; xem l&#7883;ch kh&#7903;i h&#224;nh
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        
                        <div class="wishlist-footer">
                            <div class="wishlist-price">
                                <span class="label">Gi&#225; ch&#7881; t&#7915;</span>
                                <span class="amount"><fmt:formatNumber value="${tour.basePrice}" type="currency" currencySymbol="&#8363;" maxFractionDigits="0"/></span>
                            </div>
                            <a href="${pageContext.request.contextPath}/detail?id=${tour.tourId}" class="btn btn-primary btn-sm">
                                Xem chi ti&#7871;t
                            </a>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </c:if>
</div>

<jsp:include page="/common/footer.jsp"/>
