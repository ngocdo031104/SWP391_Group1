<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="Entities.Tour" %>
<%@ page import="Entities.TourSchedule" %>
<%@ page import="Entities.BookingParticipant" %>
<%@ page import="Controller.customer.BookingFlowSupport.BookingDraft" %>
<%
    // Người làm: Dương
    // Thời gian tạo: 04/06/2026
    // Chức năng: Màn Customer xác nhận chi tiết đơn đặt tour.
    // Ý nghĩa: Hiển thị tour, lịch khởi hành, danh sách người đi và tổng tiền trước khi hệ thống tạo booking trong DB.

    // Chỉ nạp CSS của màn review vì màn này không cần xử lý JavaScript riêng.
    request.setAttribute("extraCss", "css/customer-booking-review.css");
    request.setAttribute("bodyClass", "booking-page");

    // tour và selectedSchedule được controller đọc lại từ draft trong session để đảm bảo dữ liệu review đúng với lựa chọn trước đó.
    Tour tour = (Tour) request.getAttribute("tour");
    TourSchedule selectedSchedule = (TourSchedule) request.getAttribute("selectedSchedule");

    // draft chứa toàn bộ dữ liệu tạm của đơn đặt trước khi ghi xuống DB: tourId, scheduleId, số người, danh sách người đi và tiền.
    BookingDraft draft = (BookingDraft) request.getAttribute("draft");

    // errorMessage hiển thị lỗi nếu draft bị thiếu, tour/lịch không còn hợp lệ hoặc tạo booking thất bại.
    String errorMessage = (String) request.getAttribute("errorMessage");

    // money và dateFormat dùng để format số tiền/ngày tháng nhất quán trên màn review.
    NumberFormat money = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");

    // Dương làm đoạn này: escape ghi chú trước khi hiển thị để nội dung khách nhập không phá vỡ HTML của màn review.
    String customerNoteDisplay = draft != null && draft.customerNote != null ? draft.customerNote : "";
    customerNoteDisplay = customerNoteDisplay.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
%>
<jsp:include page="/common/header.jsp"/>

<main class="booking-shell">
    <%-- Dương làm đoạn này: nút quay lại dùng chung cho các màn trong luồng booking để khách có thể trở về bước trước. --%>
    <button type="button" class="booking-back-btn" onclick="window.location.href='${pageContext.request.contextPath}/customer/booking/create?tourId=<%= draft != null ? draft.tourId : 0 %>'" aria-label="Quay lại bước trước" title="Quay lại bước trước">
        <i data-lucide="arrow-left"></i>
    </button>
    <%-- Thanh tiến trình đánh dấu bước review là bước đang active. --%>
    <section class="booking-progress" aria-label="Tiến trình đặt tour">
        <div class="progress-step done"><span>1</span><strong>Đặt tour</strong><small>Booking creation</small></div>
        <div class="progress-line"></div>
        <div class="progress-step active"><span>2</span><strong>Chi tiết đơn</strong><small>Booking review</small></div>
        <div class="progress-line"></div>
        <div class="progress-step"><span>3</span><strong>Thanh toán</strong><small>Payment processing</small></div>
        <div class="progress-line"></div>
        <div class="progress-step"><span>4</span><strong>Hoàn tất</strong><small>Success screen</small></div>
    </section>

    <div class="booking-layout">
        <section class="booking-main-panel">
            <%-- Nếu BookingReviewController phát hiện lỗi, in thông báo để khách quay lại sửa hoặc thử lại. --%>
            <% if (errorMessage != null) { %>
                <div class="booking-alert"><i data-lucide="triangle-alert"></i><span><%= errorMessage %></span></div>
            <% } %>

            <div class="booking-heading">
                <p>Mã giao dịch (Booking ID)</p>
                <h1>Chi tiết đơn đặt tour</h1>
                <span>Trạng thái đặt: Chờ thanh toán · Thanh toán: Chưa thanh toán</span>
            </div>

            <%-- Layout review chia thành phần thông tin tour/người đi bên trái và tổng kết thanh toán bên phải. --%>
            <div class="booking-review-layout">
                <div>
                    <%-- Card tour hiển thị lịch trình đã chọn để khách kiểm tra lần cuối trước khi tạo booking thật. --%>
                    <div class="review-tour-card">
                        <div class="review-tour-cover">
                            <span>Điểm đến nổi bật</span>
                            <h2><%= tour != null ? tour.getTourName() : "TourBuddy" %></h2>
                            <p><%= tour != null ? tour.getDestination() : "-" %> · <%= tour != null ? tour.getDurationDays() : 0 %> ngày</p>
                        </div>
                        <div class="review-info-grid">
                            <div><small>Ngày khởi hành</small><strong><%= selectedSchedule != null ? dateFormat.format(selectedSchedule.getDepartureDate()) : "-" %></strong></div>
                            <div><small>Phương thức di chuyển</small><strong><%= selectedSchedule != null ? selectedSchedule.getTransportation() : "-" %></strong></div>
                        </div>
                    </div>

                    <%-- Danh sách người đi lấy từ draft.participants, không nhập lại ở màn này. --%>
                    <div class="booking-section">
                        <div class="section-title"><span><i data-lucide="users"></i></span><strong>Danh sách người đi (<%= draft != null ? draft.participantCount : 0 %> khách)</strong></div>
                        <div class="participant-review-list">
                            <% if (draft != null && draft.participants != null) { for (int i = 0; i < draft.participants.size(); i++) { BookingParticipant p = draft.participants.get(i); %>
                                <div class="participant-review-item">
                                    <strong><%= i + 1 %>. <%= p.getFullName() %></strong>
                                    <span><%= i == 0 ? "Người đại diện" : "Khách đi cùng" %></span>
                                    <small>SĐT: <%= p.getPhoneNumber() %> · Email: <%= p.getEmail() %></small>
                                </div>
                            <% }} %>
                        </div>
                    </div>
                </div>

                <%-- Cột bên phải: Coupon và Tổng kết tiền --%>
                <div>
                    <%-- Dương làm phần này: Chuyển form nhập coupon sang màn hình review --%>
                    <div class="coupon-card" style="margin-bottom: 20px; padding: 20px; background: #fff; border-radius: 8px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                        <h3 style="font-size: 1.1rem; margin-bottom: 15px; color: #1a202c;">Sử dụng mã khuyến mãi</h3>
                        <form method="post" action="${pageContext.request.contextPath}/customer/booking/review" style="display: flex; gap: 10px;">
                            <input type="hidden" name="action" value="applyCoupon">
                            <input class="booking-input" type="text" name="couponCode" value="<%= draft != null && draft.couponCode != null ? draft.couponCode : "" %>" placeholder="Nhập mã ví dụ: WELCOME10" style="flex: 1; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px;">
                            <button type="submit" class="booking-primary-btn" style="padding: 10px 20px; background: #10b981; color: white; border: none; border-radius: 6px; cursor: pointer;">Áp dụng</button>
                        </form>
                        <% if (request.getAttribute("errorMessage") != null) { %>
                            <div class="field-error" style="color: #ef4444; margin-top: 8px; font-size: 0.9rem;"><%= request.getAttribute("errorMessage") %></div>
                        <% } %>
                        <% if (request.getAttribute("successMessage") != null) { %>
                            <div style="color: #10b981; margin-top: 8px; font-size: 0.9rem;"><%= request.getAttribute("successMessage") %></div>
                        <% } %>
                    </div>

                    <%-- Thẻ tổng kết tiền: ở bước này coupon chưa nhập nên giảm giá thường là 0. --%>
                    <div class="review-payment-card">
                        <h3>Tổng kết thanh toán đơn đặt</h3>
                        <dl>
                            <div><dt>Tiền tour cơ bản</dt><dd><%= money.format(draft != null ? draft.baseAmount : 0) %> đ</dd></div>
                            <div><dt>Thuế VAT du lịch (<%= draft != null ? money.format(draft.vatRatePercent) : "0" %>%)</dt><dd><%= money.format(draft != null ? draft.vatAmount : 0) %> đ</dd></div>
                            <div><dt>Giảm giá</dt><dd>-<%= money.format(draft != null ? draft.discountAmount : 0) %> đ</dd></div>
                        </dl>
                        <div class="summary-total light"><span>Tổng thanh toán</span><strong><%= money.format(draft != null ? draft.totalAmount : 0) %> đ</strong></div>
                        <%-- Submit form này mới tạo booking trong DB rồi chuyển sang màn payment. --%>
                        <form method="post" action="${pageContext.request.contextPath}/customer/booking/review">
                            <input type="hidden" name="action" value="confirm">
                            <button type="submit" class="booking-primary-btn full-width">Chuyển sang thanh toán <i data-lucide="arrow-right"></i></button>
                        </form>
                    </div>
                </div>

                <%-- Dương làm đoạn này: ghi chú khách được đưa xuống dưới và trải rộng toàn bộ vùng review để không bị lệch sang cột phải. --%>
                <% if (draft != null && draft.customerNote != null && !draft.customerNote.trim().isEmpty()) { %>
                    <div class="booking-section review-note-section">
                        <div class="section-title"><span><i data-lucide="message-square-text"></i></span><strong>Ghi chú của khách</strong></div>
                        <div class="participant-review-item">
                            <small><%= customerNoteDisplay %></small>
                        </div>
                    </div>
                <% } %>
            </div>
        </section>
    </div>
</main>

<jsp:include page="/common/footer.jsp"/>
