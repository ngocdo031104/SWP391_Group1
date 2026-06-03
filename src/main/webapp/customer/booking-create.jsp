<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="Entities.Tour" %>
<%@ page import="Entities.TourSchedule" %>
<%
    // Người làm: Dương
    // Thời gian tạo: 04/06/2026
    // Chức năng: Màn Customer tạo booking cho tour đã chọn.
    // Ý nghĩa: Chỉ hiển thị lịch khởi hành của tour hiện tại, nhập số người và thông tin người tham gia; không nhập coupon ở bước này.

    // Khai báo CSS/JS riêng cho màn tạo booking để header.jsp tự nhúng đúng tài nguyên của trang này.
    request.setAttribute("extraCss", "css/customer-booking-create.css");
    request.setAttribute("extraScript", "js/customer-booking-create.js");
    request.setAttribute("bodyClass", "booking-page");

    // tour là tour đã được chọn từ trang detail thông qua tourId, dùng để hiển thị tên tour và giá tham khảo.
    Tour tour = (Tour) request.getAttribute("tour");

    // schedules là danh sách lịch khởi hành thuộc tour hiện tại, dùng để khách chọn ngày đi cụ thể.
    List<TourSchedule> schedules = (List<TourSchedule>) request.getAttribute("schedules");

    // errorMessage nhận lỗi validate từ controller, ví dụ chưa chọn lịch hoặc thông tin người đi chưa hợp lệ.
    String errorMessage = (String) request.getAttribute("errorMessage");

    // money định dạng số tiền theo kiểu Việt Nam; dateFormat định dạng ngày để người dùng dễ đọc.
    NumberFormat money = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");

    // hasSchedules quyết định có cho submit form hay không; sideBase là giá gốc hiển thị ở thẻ tổng quan bên phải.
    boolean hasSchedules = schedules != null && !schedules.isEmpty();
    double sideBase = tour != null ? tour.getBasePrice() : 0;
%>
<jsp:include page="/common/header.jsp"/>

<main class="booking-shell">
    <%-- Thanh tiến trình cho biết khách đang ở bước tạo booking trong luồng 4 bước. --%>
    <section class="booking-progress" aria-label="Tiến trình đặt tour">
        <div class="progress-step active"><span>1</span><strong>Đặt tour</strong><small>Booking creation</small></div>
        <div class="progress-line"></div>
        <div class="progress-step"><span>2</span><strong>Chi tiết đơn</strong><small>Booking review</small></div>
        <div class="progress-line"></div>
        <div class="progress-step"><span>3</span><strong>Thanh toán</strong><small>Payment processing</small></div>
        <div class="progress-line"></div>
        <div class="progress-step"><span>4</span><strong>Hoàn tất</strong><small>Success screen</small></div>
    </section>

    <div class="booking-layout">
        <section class="booking-main-panel">
            <%-- Nếu controller trả lỗi, in lỗi ngay phía trên form để khách biết cần sửa gì. --%>
            <% if (errorMessage != null) { %>
                <div class="booking-alert"><i data-lucide="triangle-alert"></i><span><%= errorMessage %></span></div>
            <% } %>

            <%-- Phần heading xác nhận tour đã được lấy từ trang detail, không cho chọn lại điểm đến. --%>
            <div class="booking-heading">
                <p>Thiết lập đơn đặt tour</p>
                <h1><%= tour != null ? tour.getTourName() : "TourBuddy" %></h1>
                <span>Tour đã được chọn từ trang chi tiết. Bạn chỉ cần chọn lịch khởi hành và nhập thông tin đoàn.</span>
            </div>

            <%-- Form gửi về BookingCreateController để validate rồi lưu booking draft vào session. --%>
            <form method="post" action="${pageContext.request.contextPath}/customer/booking/create" id="booking-create-form" novalidate>
                <input type="hidden" name="action" value="review">
                <input type="hidden" name="tourId" value="<%= tour != null ? tour.getTourId() : 0 %>">

                <div class="booking-section" id="schedule-section">
                    <div class="section-title"><span>1</span><strong>Lịch khởi hành mong muốn</strong></div>
                    <%-- Khối lịch khởi hành: mỗi schedule được render thành radio để khách chọn đúng ngày đi. --%>
                    <div class="schedule-grid">
                        <% if (hasSchedules) { %>
                            <% for (int i = 0; i < schedules.size(); i++) { TourSchedule schedule = schedules.get(i); %>
                                <label class="schedule-card">
                                    <input type="radio" name="scheduleId" value="<%= schedule.getScheduleId() %>" <%= i == 0 ? "checked" : "" %>>
                                    <strong><%= dateFormat.format(schedule.getDepartureDate()) %></strong>
                                    <span><%= dateFormat.format(schedule.getDepartureDate()) %> - <%= dateFormat.format(schedule.getReturnDate()) %></span>
                                    <small><%= schedule.getAvailableSeats() %> chỗ trống · <%= money.format(schedule.getPriceAdult()) %> đ / khách</small>
                                </label>
                            <% } %>
                        <% } else { %>
                            <div class="empty-state">Tour này chưa có lịch khởi hành đang mở. Vui lòng chọn tour khác hoặc liên hệ nhân viên hỗ trợ.</div>
                        <% } %>
                    </div>
                    <div class="field-error" id="schedule-error"></div>
                </div>

                <%-- Khối số lượng người đi: JS sẽ tăng/giảm số form người tham gia theo participantCount. --%>
                <div class="booking-section">
                    <div class="section-title"><span>2</span><strong>Số lượng người tham gia</strong></div>
                    <div class="participant-counter">
                        <button type="button" id="minus-participant" aria-label="Giảm số người">-</button>
                        <input type="number" name="participantCount" id="participant-count" min="1" max="10" value="1" readonly>
                        <button type="button" id="plus-participant" aria-label="Tăng số người">+</button>
                    </div>
                    <p class="booking-note">Tour giới hạn tối đa 10 người cho mỗi đơn để đảm bảo chất lượng phục vụ.</p>
                    <%-- participant-list là vùng JS customer-booking-create.js sinh form người tham gia theo participantCount. --%>
                    <div id="participant-list" class="participant-list"></div>
                </div>

                <button type="submit" class="booking-primary-btn" <%= hasSchedules ? "" : "disabled" %>>
                    Xác nhận thông tin đặt tour
                    <i data-lucide="arrow-right"></i>
                </button>
            </form>
        </section>

        <%-- Thẻ tổng quan giúp khách kiểm tra nhanh tour và giá tham khảo trước khi nhập thông tin. --%>
        <aside class="booking-summary">
            <div class="summary-card">
                <small>Tổng quan đơn đặt</small>
                <h2><%= tour != null ? tour.getTourName() : "TourBuddy" %></h2>
                <dl>
                    <div><dt>Điểm đến</dt><dd><%= tour != null ? tour.getDestination() : "-" %></dd></div>
                    <div><dt>Thời gian</dt><dd><%= tour != null ? tour.getDurationDays() : 0 %> ngày</dd></div>
                    <div><dt>Giá tham khảo</dt><dd><%= money.format(sideBase) %> đ</dd></div>
                </dl>
                <div class="summary-total"><span>Tạm tính từ</span><strong><%= money.format(sideBase) %> đ</strong></div>
            </div>
        </aside>
    </div>
</main>

<jsp:include page="/common/footer.jsp"/>
