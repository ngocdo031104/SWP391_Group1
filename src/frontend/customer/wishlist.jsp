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
        <h1>Tour Yêu Thích Của Tôi</h1>
        <p>Danh sách các hành trình du lịch bạn đã lưu lại để tham khảo và lên lịch trình.</p>
    </div>

    <!-- Empty State -->
    <div class="wishlist-empty" id="wishlist-empty-state" style="display: ${empty wishlistTours ? 'block' : 'none'};">
        <div class="wishlist-empty-icon">
            <i data-lucide="heart-off"></i>
        </div>
        <h2>Danh sách yêu thích trống</h2>
        <p>Bạn chưa lưu bất kỳ tour du lịch nào. Hãy cùng khám phá các điểm đến hấp dẫn cùng TourBuddy!</p>
        <a href="${pageContext.request.contextPath}/tourdiscovery" class="btn btn-primary">
            <i data-lucide="compass"></i> Khám Phá Tour Ngay
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
                        <button class="wishlist-btn-remove" data-tour-id="${tour.tourId}" aria-label="Xóa khỏi yêu thích">
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
                                            <fmt:formatNumber value="${tour.rating}" maxFractionDigits="1"/> (${tour.reviewsCount} đánh giá)
                                        </c:when>
                                        <c:otherwise>
                                            Chưa có đánh giá
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                            <div class="wishlist-duration">
                                <i data-lucide="clock"></i>
                                <span>${tour.durationDays} Ngày</span>
                            </div>
                        </div>
                        <h3><c:out value="${tour.tourName}"/></h3>
                        
                        <!-- Lịch khởi hành gần nhất -->
                        <div style="font-size: 0.85rem; color: var(--slate-500); margin-bottom: 12px; display: flex; align-items: center; gap: 6px;">
                            <i data-lucide="calendar" style="width: 14px; height: 14px;"></i>
                            <span>
                                <c:choose>
                                    <c:when test="${not empty tour.schedules}">
                                        Khởi hành: <fmt:formatDate value="${tour.schedules[0].departureDate}" pattern="dd/MM/yyyy"/> (Còn ${tour.schedules[0].availableSeats} chỗ)
                                    </c:when>
                                    <c:otherwise>
                                        Liên hệ để xem lịch khởi hành
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        
                        <div class="wishlist-footer">
                            <div class="wishlist-price">
                                <span class="label">Giá chỉ từ</span>
                                <span class="amount"><fmt:formatNumber value="${tour.basePrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                            </div>
                            <a href="${pageContext.request.contextPath}/detail?id=${tour.tourId}" class="btn btn-primary btn-sm">
                                Xem chi tiết
                            </a>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </c:if>
</div>

<jsp:include page="/common/footer.jsp"/>
