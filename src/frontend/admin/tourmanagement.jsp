<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="java.util.List" %>
<%@ page import="Entities.TourCategory" %>
<c:if test="${empty sessionUser || (sessionUser.roleId ne 1 && userRole ne 'Admin')}">
    <c:redirect url="/login" />
</c:if>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Tour — TourBuddy Enterprise</title>
    <!-- Outfit & Inter Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons & FontAwesome CDNs -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=1.7">
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <!-- ── Left Sidebar ── -->
    <aside class="sidebar">
        <div class="sidebar-brand">
            <div class="logo-icon">T</div>
            <span>TourBuddy</span>
        </div>
        
        <ul class="sidebar-menu">
            <li>
                <a href="${pageContext.request.contextPath}/admin/dashboard">
                    <i data-lucide="layout-dashboard"></i>
                    <span>Tổng Quan</span>
                </a>
            </li>
            <li class="active">
                <a href="${pageContext.request.contextPath}/admin/tours">
                    <i data-lucide="compass"></i>
                    <span>Quản Lý Tour</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/coupons">
                    <i data-lucide="tag"></i>
                    <span>Quản Lý Coupon</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i data-lucide="calendar"></i>
                    <span>Lịch Trình & Giá</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i data-lucide="image"></i>
                    <span>Thư Viện Media</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i data-lucide="bar-chart-3"></i>
                    <span>Thống Kê Chi Tiết</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i data-lucide="file-text"></i>
                    <span>Báo Cáo Doanh Thu</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i data-lucide="trending-up"></i>
                    <span>Dự Báo & Xu Hướng</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i data-lucide="settings"></i>
                    <span>Cấu Hình</span>
                </a>
            </li>
        </ul>
        
        <div class="sidebar-footer">
            <a href="${pageContext.request.contextPath}/home" style="color: var(--text-gray);">
                <i data-lucide="home"></i>
                <span>Về Trang Chủ</span>
            </a>
            <a href="${pageContext.request.contextPath}/logout" style="color: var(--error-red); margin-top: 5px;">
                <i data-lucide="log-out"></i>
                <span>Đăng Xuất</span>
            </a>
        </div>
    </aside>

    <!-- ── Main Content Area ── -->
    <main class="main-content">
        <!-- Top Header -->
        <header class="top-header">
            <h1>Quản lý Tour</h1>
            <div class="header-right">
                <div class="header-search">
                    <i data-lucide="search"></i>
                    <input type="text" placeholder="Tìm kiếm nhanh hệ thống...">
                </div>
                
                <div class="notif-bell" aria-label="Thông báo">
                    <i data-lucide="bell"></i>
                    <span class="badge">3</span>
                </div>
                
                <div class="profile-user dropdown-trigger" style="cursor: pointer; position: relative;" id="admin-profile-trigger">
                    <div class="profile-meta" style="text-align: right; margin-right: 5px;">
                        <span class="name">${not empty sessionUser.fullName ? sessionUser.fullName : 'Sarah Jenkins'}</span>
                        <span class="role">${(sessionUser.roleId eq 1 || userRole eq 'Admin') ? 'Quản trị viên SWP' : 'Nhân viên'}</span>
                    </div>
                    <c:choose>
                        <c:when test="${not empty sessionUser.profile && not empty sessionUser.profile.avatarUrl}">
                            <img src="${sessionUser.profile.avatarUrl}" alt="Avatar">
                        </c:when>
                        <c:otherwise>
                            <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80" alt="Avatar">
                        </c:otherwise>
                    </c:choose>
                    
                    <!-- Premium Avatar Dropdown Menu -->
                    <div class="avatar-dropdown-menu" id="admin-avatar-menu" style="display: none;">
                        <div class="dropdown-header">
                            <span class="d-name">${not empty sessionUser.fullName ? sessionUser.fullName : 'Sarah Jenkins'}</span>
                            <span class="d-email">${not empty sessionUser.email ? sessionUser.email : 'admin@tourbuddy.com'}</span>
                        </div>
                        <div class="dropdown-divider"></div>
                        <a href="${pageContext.request.contextPath}/profile" class="dropdown-item">
                            <i data-lucide="user"></i>
                            <span>Hồ Sơ Của Tôi</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/home" class="dropdown-item">
                            <i data-lucide="home"></i>
                            <span>Về Trang Chủ</span>
                        </a>
                        <div class="dropdown-divider"></div>
                        <a href="${pageContext.request.contextPath}/logout" class="dropdown-item logout-btn">
                            <i data-lucide="log-out"></i>
                            <span>Đăng Xuất</span>
                        </a>
                    </div>
                </div>
            </div>
        </header>

        <!-- Main Content Inner Wrapper -->
        <div class="admin-dashboard-page" style="display: flex; flex-direction: column; gap: 1.5rem; width: 100%;">
            <!-- Header Title & Add New Button -->
            <div class="dashboard-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">
                <div>
                    <h2 style="font-family: 'Outfit', sans-serif; font-size: 1.5rem; font-weight: 700; margin: 0; color: var(--text-light);">Danh Sách Tour Du Lịch</h2>
                    <p style="color: var(--text-muted); margin-top: 0.25rem; font-size: 0.9rem;">Thêm, chỉnh sửa hoặc tạm dừng các tour trong hệ thống</p>
                </div>
                <button class="btn btn-primary" id="add-tour-btn">
                    <i data-lucide="plus-circle" style="width: 18px; height: 18px;"></i>
                    <span>Thêm Tour Mới</span>
                </button>
            </div>

    <!-- KPI Summary Stats -->
    <div class="stats-grid">
        <!-- 1. Tổng số tour -->
        <div class="stat-card">
            <div class="stat-header">
                <span class="stat-title">Tổng số tour</span>
                <div class="stat-icon blue"><i data-lucide="compass"></i></div>
            </div>
            <span class="stat-value" id="stat-total">0</span>
            <div class="stat-footer" id="stat-total-footer">
                <span class="stat-trend up"><i data-lucide="trending-up"></i> +2 tour</span>
                <span>mới thêm trong tháng</span>
            </div>
        </div>
        <!-- 2. Đang hoạt động -->
        <div class="stat-card">
            <div class="stat-header">
                <span class="stat-title">Đang hoạt động</span>
                <div class="stat-icon green"><i data-lucide="eye"></i></div>
            </div>
            <span class="stat-value" id="stat-active">0</span>
            <div class="stat-footer" id="stat-active-footer">
                <span class="stat-trend up"><i data-lucide="trending-up"></i> +1 tour</span>
                <span>vừa kích hoạt mới</span>
            </div>
        </div>
        <!-- 3. Bản nháp -->
        <div class="stat-card">
            <div class="stat-header">
                <span class="stat-title">Bản nháp</span>
                <div class="stat-icon orange"><i data-lucide="file-edit"></i></div>
            </div>
            <span class="stat-value" id="stat-draft">0</span>
            <div class="stat-footer" id="stat-draft-footer">
                <span class="stat-trend down"><i data-lucide="trending-down"></i> -1 nháp</span>
                <span>so với tuần trước</span>
            </div>
        </div>
        <!-- 4. Tạm ngưng -->
        <div class="stat-card">
            <div class="stat-header">
                <span class="stat-title">Tạm ngưng</span>
                <div class="stat-icon purple"><i data-lucide="eye-off"></i></div>
            </div>
            <span class="stat-value" id="stat-disabled">0</span>
            <div class="stat-footer" id="stat-disabled-footer">
                <span class="stat-trend down"><i data-lucide="trending-down"></i> -2 tour</span>
                <span>đang bảo trì lịch trình</span>
            </div>
        </div>
    </div>

    <!-- Search & Filter Controllers -->
    <div class="filter-card">
        <div class="filter-row">
            <div class="filter-field" style="flex: 2;">
                <label for="search-filter">Tìm kiếm hành trình</label>
                <div class="search-input-wrapper">
                    <i data-lucide="search"></i>
                    <input type="text" id="search-filter" placeholder="Tìm theo tên tour, điểm đến, hoặc nơi khởi hành...">
                </div>
            </div>
            <div class="filter-field">
                <label for="category-filter">Danh mục</label>
                <div class="select-wrapper">
                    <select id="category-filter">
                        <option value="all">Tất cả danh mục</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.categoryId}">${cat.categoryName}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>
            <div class="filter-field">
                <label for="status-filter">Trạng thái</label>
                <div class="select-wrapper">
                    <select id="status-filter">
                        <option value="all">Tất cả trạng thái</option>
                        <option value="Active">Hoạt động</option>
                        <option value="Draft">Bản nháp</option>
                        <option value="Inactive">Tạm ngưng</option>
                    </select>
                </div>
            </div>
        </div>
    </div>

    <!-- Tour Management Table -->
    <div class="table-card">
        <div class="table-responsive">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>Hành Trình</th>
                        <th>Danh mục</th>
                        <th>Thời lượng</th>
                        <th>Giá Cơ Bản</th>
                        <th>Trạng Thái</th>
                        <th>Ngày tạo</th>
                        <th style="text-align: right; padding-right: 2rem;">Hành Động</th>
                    </tr>
                </thead>
                <tbody id="tours-table-body">
                    <!-- Dynamic Rows Loaded from AJAX -->
                    <tr>
                        <td colspan="7" style="text-align: center; color: var(--slate-400); padding: 4rem 0;">
                            <i data-lucide="loader-2" class="spin" style="width: 2.5rem; height: 2.5rem; margin-bottom: 0.5rem; opacity: 0.5; animation: spin 1s linear infinite;"></i>
                            <p>Đang tải dữ liệu tour du lịch...</p>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

<!-- Add / Edit Tour Modal Overlay -->
<div class="modal-overlay" id="tour-modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="modal-title">Thêm Tour Mới</h3>
            <button class="modal-close-btn" id="modal-close">&times;</button>
        </div>
        <form id="tour-form" method="POST">
            <input type="hidden" id="tour-id" name="tourId" value="">
            <div class="modal-body">
                
                <!-- Section: General Info -->
                <div class="form-section">
                    <div class="form-section-title">Thông Tin Chung</div>
                    
                    <div class="form-element">
                        <label for="tour-name">Tên Hành Trình *</label>
                        <input type="text" id="tour-name" name="tourName" required placeholder="Nhập tên tour du lịch đầy đủ và hấp dẫn...">
                    </div>
                    
                    <div class="form-grid-3">
                        <div class="form-element">
                            <label for="tour-category">Danh mục *</label>
                            <div class="select-wrapper">
                                <select id="tour-category" name="categoryId" required>
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.categoryId}">${cat.categoryName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div class="form-element">
                            <label for="tour-difficulty">Độ khó *</label>
                            <div class="select-wrapper">
                                <select id="tour-difficulty" name="difficultyLevel" required>
                                    <option value="Easy">Dễ (Nhẹ nhàng)</option>
                                    <option value="Medium">Vừa (Vừa phải)</option>
                                    <option value="Hard">Khó (Thử thách)</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-element">
                            <label for="tour-status">Trạng Thái *</label>
                            <div class="select-wrapper">
                                <select id="tour-status" name="status" required>
                                    <option value="Active">Hoạt động</option>
                                    <option value="Draft" selected>Bản nháp</option>
                                    <option value="Inactive">Tạm ngưng</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Section: Price & Capacity -->
                <div class="form-section">
                    <div class="form-section-title">Chi Phí & Số Lượng</div>
                    
                    <div class="form-grid-3">
                        <div class="form-element">
                            <label for="tour-price">Giá Cơ Bản (VND) *</label>
                            <input type="number" id="tour-price" name="basePrice" min="0" required placeholder="Ví dụ: 3500000">
                        </div>
                        <div class="form-element">
                            <label for="tour-duration">Thời lượng (Ngày) *</label>
                            <input type="number" id="tour-duration" name="durationDays" min="1" required placeholder="Ví dụ: 3">
                        </div>
                        <div class="form-element">
                            <label for="tour-max-parts">Số khách tối đa *</label>
                            <input type="number" id="tour-max-parts" name="maxParticipants" min="1" required value="20" placeholder="Ví dụ: 20">
                        </div>
                    </div>
                    
                    <div class="form-grid-2">
                        <div class="form-element">
                            <label for="tour-group-min">Số người tối thiểu mỗi đoàn</label>
                            <input type="number" id="tour-group-min" name="groupSizeMin" min="1" value="1" placeholder="Ví dụ: 1">
                        </div>
                        <div class="form-element">
                            <label for="tour-group-max">Số người tối đa mỗi đoàn</label>
                            <input type="number" id="tour-group-max" name="groupSizeMax" min="1" value="20" placeholder="Ví dụ: 20">
                        </div>
                    </div>
                </div>

                <!-- Section: Route & Location -->
                <div class="form-section">
                    <div class="form-section-title">Địa Điểm & Lịch Trình</div>
                    
                    <div class="form-grid-2">
                        <div class="form-element">
                            <label for="tour-departure">Điểm khởi hành *</label>
                            <input type="text" id="tour-departure" name="departureCity" required placeholder="Ví dụ: Hà Nội, Đà Nẵng, TP. Hồ Chí Minh">
                        </div>
                        <div class="form-element">
                            <label for="tour-destination">Điểm đến (Thành phố/Tỉnh) *</label>
                            <input type="text" id="tour-destination" name="destination" required placeholder="Ví dụ: Sa Pa, Vịnh Hạ Long, Phú Quốc">
                        </div>
                    </div>
                    
                    <div class="form-grid-3">
                        <div class="form-element">
                            <label for="tour-languages">Ngôn ngữ hướng dẫn</label>
                            <input type="text" id="tour-languages" name="languages" value="Tiếng Việt, Tiếng Anh" placeholder="Ví dụ: Tiếng Việt, Tiếng Anh">
                        </div>
                        <div class="form-element">
                            <label for="tour-latitude">Vĩ độ (Latitude)</label>
                            <input type="text" id="tour-latitude" name="latitude" placeholder="Ví dụ: 21.0285">
                        </div>
                        <div class="form-element">
                            <label for="tour-longitude">Kinh độ (Longitude)</label>
                            <input type="text" id="tour-longitude" name="longitude" placeholder="Ví dụ: 105.8542">
                        </div>
                    </div>
                    
                    <div class="form-element">
                        <label for="tour-video">Video YouTube URL (Giới thiệu)</label>
                        <input type="text" id="tour-video" name="videoUrl" placeholder="Ví dụ: https://www.youtube.com/watch?v=...">
                    </div>
                </div>

                <!-- Section: Descriptions -->
                <div class="form-section">
                    <div class="form-section-title">Nội Dung Chi Tiết</div>
                    
                    <div class="form-element">
                        <label for="tour-description">Mô Tả Tour *</label>
                        <textarea id="tour-description" name="description" required placeholder="Nhập mô tả tóm tắt hành trình, resort lưu trú, các điểm nhấn đặc sắc..."></textarea>
                    </div>
                    <div class="form-element">
                        <label for="tour-itinerary">Tóm tắt lịch trình (Itinerary Outline)</label>
                        <textarea id="tour-itinerary" name="itinerary" placeholder="Ví dụ: Ngày 1: Đón sân bay - Check-in khách sạn. Ngày 2: Tham quan Bà Nà Hills. Ngày 3: Mua sắm quà lưu niệm - Tiễn khách..."></textarea>
                    </div>
                    
                    <div class="form-element" style="margin-bottom: 0.5rem;">
                        <label class="form-check-inline">
                            <input type="checkbox" id="tour-featured" name="isFeatured" value="true">
                            <span>Đánh dấu là Tour Nổi Bật (Featured Tour) hiển thị trên Trang Chủ</span>
                        </label>
                    </div>
                </div>

                <!-- Section: Inclusions & Exclusions -->
                <div class="form-section">
                    <div class="form-section-title" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                        <span>Dịch Vụ Bao Gồm & Loại Trừ</span>
                        <button type="button" class="btn btn-secondary btn-sm" id="btn-add-inclusion-row" style="padding: 0.25rem 0.75rem;">
                            <i data-lucide="plus" style="width: 14px; height: 14px; display: inline-block; vertical-align: middle;"></i>
                            <span style="vertical-align: middle;">Thêm dòng</span>
                        </button>
                    </div>
                    
                    <div class="inclusions-inputs-container" id="inclusions-inputs-list" style="display: flex; flex-direction: column; gap: 0.75rem;">
                        <!-- Inclusions rows will be dynamically appended here via JS -->
                    </div>
                </div>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" id="modal-cancel">Hủy Bỏ</button>
                <button type="submit" class="btn btn-primary" id="modal-submit">Lưu Lại</button>
            </div>
        </form>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal-overlay confirm-overlay" id="confirm-modal">
    <div class="modal-content">
        <div class="confirm-body">
            <div class="confirm-icon">
                <i data-lucide="alert-triangle" style="width: 2.25rem; height: 2.25rem;"></i>
            </div>
            <h4>Xác Nhận Xóa Tour?</h4>
            <p>Hành động này sẽ xóa vĩnh viễn tour du lịch khỏi hệ thống và không thể phục hồi. Bạn có chắc chắn muốn tiếp tục?</p>
        </div>
        <div class="modal-footer" style="padding-top: 0;">
            <button class="btn btn-secondary" style="flex: 1;" id="confirm-cancel">Hủy Bỏ</button>
            <button class="btn btn-primary" style="flex: 1; background-color: var(--danger); border-color: var(--danger);" id="confirm-delete">Đồng Ý Xóa</button>
        </div>
    </div>
</div>

<!-- Custom Toast Message Notification Container -->
<div class="toast-container" id="toast-container"></div>

        </div> <!-- End of admin-dashboard-page -->
    </main> <!-- End of main-content -->
</div> <!-- End of dashboard-wrapper -->

<style>
@keyframes spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
}
.spin {
    display: inline-block;
}
</style>

<script src="${pageContext.request.contextPath}/js/admin-tour.js?v=1.3"></script>
</body>
</html>
