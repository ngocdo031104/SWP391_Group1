<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
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
    <title>Qu&#7843;n L&#253; Tour &#8212; TourBuddy Enterprise</title>
    <!-- Outfit & Inter Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons & FontAwesome CDNs -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.3">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-space-overrides.css?v=1.0">
</head>
<body class="dashboard-body tb-cosmic">

<div class="dashboard-wrapper">
    <!-- &#9472;&#9472; Left Sidebar &#9472;&#9472; -->
    <c:set var="activePage" value="tours" scope="request" />
    <jsp:include page="sidebar.jsp" />

    <!-- &#9472;&#9472; Main Content Area &#9472;&#9472; -->
    <main class="main-content theme-light">
        <!-- Top Header -->
        <header class="top-header">
            <h1>Qu&#7843;n l&#253; Tour</h1>
            <div class="header-right">
                <div class="header-search">
                    <i data-lucide="search"></i>
                    <input type="text" placeholder="T&#236;m ki&#7871;m nhanh h&#7879; th&#7889;ng...">
                </div>
                
                <div class="notif-bell" aria-label="Th&#244;ng b&#225;o">
                    <i data-lucide="bell"></i>
                    <span class="badge">3</span>
                </div>
                
                <div class="profile-user dropdown-trigger" style="cursor: pointer; position: relative;" id="admin-profile-trigger">
                    <div class="profile-meta" style="text-align: right; margin-right: 5px;">
                        <span class="name">${not empty sessionUser.fullName ? sessionUser.fullName : 'Sarah Jenkins'}</span>
                        <span class="role">${(sessionUser.roleId eq 1 || userRole eq 'Admin') ? 'Qu&#7843;n tr&#7883; vi&#234;n SWP' : 'Nh&#226;n vi&#234;n'}</span>
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
                            <span>H&#7891; S&#417; C&#7911;a T&#244;i</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/home" class="dropdown-item">
                            <i data-lucide="home"></i>
                            <span>V&#7873; Trang Ch&#7911;</span>
                        </a>
                        <div class="dropdown-divider"></div>
                        <a href="${pageContext.request.contextPath}/logout" class="dropdown-item logout-btn">
                            <i data-lucide="log-out"></i>
                            <span>&#272;&#259;ng Xu&#7845;t</span>
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
                    <h2 style="font-family: 'Outfit', sans-serif; font-size: 1.5rem; font-weight: 700; margin: 0; color: var(--text-light);">Danh S&#225;ch Tour Du L&#7883;ch</h2>
                    <p style="color: var(--text-muted); margin-top: 0.25rem; font-size: 0.9rem;">Th&#234;m, ch&#7881;nh s&#7917;a ho&#7863;c t&#7841;m d&#7915;ng c&#225;c tour trong h&#7879; th&#7889;ng</p>
                </div>
                <button class="btn btn-primary" id="add-tour-btn">
                    <i data-lucide="plus-circle" style="width: 18px; height: 18px;"></i>
                    <span>Th&#234;m Tour M&#7899;i</span>
                </button>
            </div>

    <!-- KPI Summary Stats -->
    <div class="stats-grid">
        <!-- 1. T&#7893;ng s&#7889; tour -->
        <div class="stat-card">
            <div class="stat-header">
                <span class="stat-title">T&#7893;ng s&#7889; tour</span>
                <div class="stat-icon blue"><i data-lucide="compass"></i></div>
            </div>
            <span class="stat-value" id="stat-total">0</span>
            <div class="stat-footer" id="stat-total-footer">
                <span class="stat-trend up"><i data-lucide="trending-up"></i> +2 tour</span>
                <span>m&#7899;i th&#234;m trong th&#225;ng</span>
            </div>
        </div>
        <!-- 2. &#272;ang ho&#7841;t &#273;&#7897;ng -->
        <div class="stat-card">
            <div class="stat-header">
                <span class="stat-title">&#272;ang ho&#7841;t &#273;&#7897;ng</span>
                <div class="stat-icon green"><i data-lucide="eye"></i></div>
            </div>
            <span class="stat-value" id="stat-active">0</span>
            <div class="stat-footer" id="stat-active-footer">
                <span class="stat-trend up"><i data-lucide="trending-up"></i> +1 tour</span>
                <span>v&#7915;a k&#237;ch ho&#7841;t m&#7899;i</span>
            </div>
        </div>
        <!-- 3. B&#7843;n nh&#225;p -->
        <div class="stat-card">
            <div class="stat-header">
                <span class="stat-title">B&#7843;n nh&#225;p</span>
                <div class="stat-icon orange"><i data-lucide="file-edit"></i></div>
            </div>
            <span class="stat-value" id="stat-draft">0</span>
            <div class="stat-footer" id="stat-draft-footer">
                <span class="stat-trend down"><i data-lucide="trending-down"></i> -1 nh&#225;p</span>
                <span>so v&#7899;i tu&#7847;n tr&#432;&#7899;c</span>
            </div>
        </div>
        <!-- 4. T&#7841;m ng&#432;ng -->
        <div class="stat-card">
            <div class="stat-header">
                <span class="stat-title">T&#7841;m ng&#432;ng</span>
                <div class="stat-icon purple"><i data-lucide="eye-off"></i></div>
            </div>
            <span class="stat-value" id="stat-disabled">0</span>
            <div class="stat-footer" id="stat-disabled-footer">
                <span class="stat-trend down"><i data-lucide="trending-down"></i> -2 tour</span>
                <span>&#273;ang b&#7843;o tr&#236; l&#7883;ch tr&#236;nh</span>
            </div>
        </div>
    </div>

    <!-- Search & Filter Controllers -->
    <div class="filter-card">
        <div class="filter-row">
            <div class="filter-field" style="flex: 2;">
                <label for="search-filter">T&#236;m ki&#7871;m h&#224;nh tr&#236;nh</label>
                <div class="search-input-wrapper">
                    <i data-lucide="search"></i>
                    <input type="text" id="search-filter" placeholder="T&#236;m theo t&#234;n tour, &#273;i&#7875;m &#273;&#7871;n, ho&#7863;c n&#417;i kh&#7903;i h&#224;nh...">
                </div>
            </div>
            <div class="filter-field">
                <label for="category-filter">Danh m&#7909;c</label>
                <div class="select-wrapper">
                    <select id="category-filter">
                        <option value="all">T&#7845;t c&#7843; danh m&#7909;c</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.categoryId}">${cat.categoryName}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>
            <div class="filter-field">
                <label for="status-filter">Tr&#7841;ng th&#225;i</label>
                <div class="select-wrapper">
                    <select id="status-filter">
                        <option value="all">T&#7845;t c&#7843; tr&#7841;ng th&#225;i</option>
                        <option value="Active">Ho&#7841;t &#273;&#7897;ng</option>
                        <option value="Draft">B&#7843;n nh&#225;p</option>
                        <option value="Inactive">T&#7841;m ng&#432;ng</option>
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
                        <th>H&#224;nh Tr&#236;nh</th>
                        <th>Danh m&#7909;c</th>
                        <th>Th&#7901;i l&#432;&#7907;ng</th>
                        <th>Gi&#225; C&#417; B&#7843;n</th>
                        <th>Tr&#7841;ng Th&#225;i</th>
                        <th>Ng&#224;y t&#7841;o</th>
                        <th style="text-align: right; padding-right: 2rem;">H&#224;nh &#272;&#7897;ng</th>
                    </tr>
                </thead>
                <tbody id="tours-table-body">
                    <!-- Dynamic Rows Loaded from AJAX -->
                    <tr>
                        <td colspan="7" style="text-align: center; color: var(--slate-400); padding: 4rem 0;">
                            <i data-lucide="loader-2" class="spin" style="width: 2.5rem; height: 2.5rem; margin-bottom: 0.5rem; opacity: 0.5; animation: spin 1s linear infinite;"></i>
                            <p>&#272;ang t&#7843;i d&#7919; li&#7879;u tour du l&#7883;ch...</p>
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
            <h3 id="modal-title">Th&#234;m Tour M&#7899;i</h3>
            <button class="modal-close-btn" id="modal-close">&times;</button>
        </div>
        <form id="tour-form" method="POST" action="${pageContext.request.contextPath}/admin/tours">
            <input type="hidden" id="tour-id" name="tourId" value="">
            <input type="hidden" id="form-mode" name="formMode" value="create">
            <div class="modal-body">
                
                <!-- Section: General Info -->
                <div class="form-section">
                    <div class="form-section-title">Th&#244;ng Tin Chung</div>
                    
                    <div class="form-element">
                        <label for="tour-name">T&#234;n H&#224;nh Tr&#236;nh *</label>
                        <input type="text" id="tour-name" name="tourName" required placeholder="Nh&#7853;p t&#234;n tour du l&#7883;ch &#273;&#7847;y &#273;&#7911; v&#224; h&#7845;p d&#7851;n...">
                    </div>
                    
                    <div class="form-grid-3">
                        <div class="form-element">
                            <label for="tour-category">Danh m&#7909;c *</label>
                            <div class="select-wrapper">
                                <select id="tour-category" name="categoryId" required>
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.categoryId}">${cat.categoryName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div class="form-element">
                            <label for="tour-difficulty">&#272;&#7897; kh&#243; *</label>
                            <div class="select-wrapper">
                                <select id="tour-difficulty" name="difficultyLevel" required>
                                    <option value="Easy">D&#7877; (Nh&#7865; nh&#224;ng)</option>
                                    <option value="Medium">V&#7915;a (V&#7915;a ph&#7843;i)</option>
                                    <option value="Hard">Kh&#243; (Th&#7917; th&#225;ch)</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-element">
                            <label for="tour-status">Tr&#7841;ng Th&#225;i *</label>
                            <div class="select-wrapper">
                                <select id="tour-status" name="status" required>
                                    <option value="Active">Ho&#7841;t &#273;&#7897;ng</option>
                                    <option value="Draft" selected>B&#7843;n nh&#225;p</option>
                                    <option value="Inactive">T&#7841;m ng&#432;ng</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Section: Price & Capacity -->
                <div class="form-section">
                    <div class="form-section-title">Chi Ph&#237; & S&#7889; L&#432;&#7907;ng</div>
                    
                    <div class="form-grid-3">
                        <div class="form-element">
                            <label for="tour-price">Gi&#225; C&#417; B&#7843;n (VND) *</label>
                            <input type="number" id="tour-price" name="basePrice" min="0" required placeholder="V&#237; d&#7909;: 3500000">
                        </div>
                        <div class="form-element">
                            <label for="tour-duration">Th&#7901;i l&#432;&#7907;ng (Ng&#224;y) *</label>
                            <input type="number" id="tour-duration" name="durationDays" min="1" required placeholder="V&#237; d&#7909;: 3">
                        </div>
                        <div class="form-element">
                            <label for="tour-max-parts">S&#7889; kh&#225;ch t&#7889;i &#273;a *</label>
                            <input type="number" id="tour-max-parts" name="maxParticipants" min="1" required value="20" placeholder="V&#237; d&#7909;: 20">
                        </div>
                    </div>
                    
                    <div class="form-grid-2">
                        <div class="form-element">
                            <label for="tour-group-min">S&#7889; ng&#432;&#7901;i t&#7889;i thi&#7875;u m&#7895;i &#273;o&#224;n</label>
                            <input type="number" id="tour-group-min" name="groupSizeMin" min="1" value="1" placeholder="V&#237; d&#7909;: 1">
                        </div>
                        <div class="form-element">
                            <label for="tour-group-max">S&#7889; ng&#432;&#7901;i t&#7889;i &#273;a m&#7895;i &#273;o&#224;n</label>
                            <input type="number" id="tour-group-max" name="groupSizeMax" min="1" value="20" placeholder="V&#237; d&#7909;: 20">
                        </div>
                    </div>
                </div>

                <!-- Section: Route & Location -->
                <div class="form-section">
                    <div class="form-section-title">&#272;&#7883;a &#272;i&#7875;m & L&#7883;ch Tr&#236;nh</div>
                    
                    <div class="form-grid-2">
                        <div class="form-element">
                            <label for="tour-departure">&#272;i&#7875;m kh&#7903;i h&#224;nh *</label>
                            <input type="text" id="tour-departure" name="departureCity" required placeholder="V&#237; d&#7909;: H&#224; N&#7897;i, &#272;&#224; N&#7861;ng, TP. H&#7891; Ch&#237; Minh">
                        </div>
                        <div class="form-element">
                            <label for="tour-destination">&#272;i&#7875;m &#273;&#7871;n (Th&#224;nh ph&#7889;/T&#7881;nh) *</label>
                            <input type="text" id="tour-destination" name="destination" required placeholder="V&#237; d&#7909;: Sa Pa, V&#7883;nh H&#7841; Long, Ph&#250; Qu&#7889;c">
                        </div>
                    </div>
                    
                    <div class="form-grid-3">
                        <div class="form-element">
                            <label for="tour-languages">Ng&#244;n ng&#7919; h&#432;&#7899;ng d&#7851;n</label>
                            <input type="text" id="tour-languages" name="languages" value="Ti&#7871;ng Vi&#7879;t, Ti&#7871;ng Anh" placeholder="V&#237; d&#7909;: Ti&#7871;ng Vi&#7879;t, Ti&#7871;ng Anh">
                        </div>
                        <div class="form-element">
                            <label for="tour-latitude">V&#297; &#273;&#7897; (Latitude)</label>
                            <input type="text" id="tour-latitude" name="latitude" placeholder="V&#237; d&#7909;: 21.0285">
                        </div>
                        <div class="form-element">
                            <label for="tour-longitude">Kinh &#273;&#7897; (Longitude)</label>
                            <input type="text" id="tour-longitude" name="longitude" placeholder="V&#237; d&#7909;: 105.8542">
                        </div>
                    </div>
                    
                    <div class="form-element">
                        <label for="tour-video">Video YouTube URL (Gi&#7899;i thi&#7879;u)</label>
                        <input type="text" id="tour-video" name="videoUrl" placeholder="V&#237; d&#7909;: https://www.youtube.com/watch?v=...">
                    </div>
                </div>

                <!-- Section: Descriptions -->
                <div class="form-section">
                    <div class="form-section-title">N&#7897;i Dung Chi Ti&#7871;t</div>
                    
                    <div class="form-element">
                        <label for="tour-description">M&#244; T&#7843; Tour *</label>
                        <textarea id="tour-description" name="description" required placeholder="Nh&#7853;p m&#244; t&#7843; t&#243;m t&#7855;t h&#224;nh tr&#236;nh, resort l&#432;u tr&#250;, c&#225;c &#273;i&#7875;m nh&#7845;n &#273;&#7863;c s&#7855;c..."></textarea>
                    </div>
                    <div class="form-element">
                        <label for="tour-itinerary">T&#243;m t&#7855;t l&#7883;ch tr&#236;nh (Itinerary Outline)</label>
                        <textarea id="tour-itinerary" name="itinerary" placeholder="V&#237; d&#7909;: Ng&#224;y 1: &#272;&#243;n s&#226;n bay - Check-in kh&#225;ch s&#7841;n. Ng&#224;y 2: Tham quan B&#224; N&#224; Hills. Ng&#224;y 3: Mua s&#7855;m qu&#224; l&#432;u ni&#7879;m - Ti&#7877;n kh&#225;ch..."></textarea>
                    </div>
                    
                    <div class="form-element" style="margin-bottom: 0.5rem;">
                        <label class="form-check-inline">
                            <input type="checkbox" id="tour-featured" name="isFeatured" value="true">
                            <span>&#272;&#225;nh d&#7845;u l&#224; Tour N&#7893;i B&#7853;t (Featured Tour) hi&#7875;n th&#7883; tr&#234;n Trang Ch&#7911;</span>
                        </label>
                    </div>
                </div>

                <!-- Section: Inclusions & Exclusions -->
                <div class="form-section">
                    <div class="form-section-title" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                        <span>D&#7883;ch V&#7909; Bao G&#7891;m & Lo&#7841;i Tr&#7915;</span>
                        <button type="button" class="btn btn-secondary btn-sm" id="btn-add-inclusion-row" style="padding: 0.25rem 0.75rem;">
                            <i data-lucide="plus" style="width: 14px; height: 14px; display: inline-block; vertical-align: middle;"></i>
                            <span style="vertical-align: middle;">Th&#234;m d&#242;ng</span>
                        </button>
                    </div>
                    
                    <div class="inclusions-inputs-container" id="inclusions-inputs-list" style="display: flex; flex-direction: column; gap: 0.75rem;">
                        <!-- Inclusions rows will be dynamically appended here via JS -->
                    </div>
                </div>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" id="modal-cancel">H&#7911;y B&#7887;</button>
                <button type="submit" class="btn btn-primary" id="modal-submit">L&#432;u L&#7841;i</button>
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
            <h4>X&#225;c Nh&#7853;n X&#243;a Tour?</h4>
            <p>H&#224;nh &#273;&#7897;ng n&#224;y s&#7869; x&#243;a v&#297;nh vi&#7877;n tour du l&#7883;ch kh&#7887;i h&#7879; th&#7889;ng v&#224; kh&#244;ng th&#7875; ph&#7909;c h&#7891;i. B&#7841;n c&#243; ch&#7855;c ch&#7855;n mu&#7889;n ti&#7871;p t&#7909;c?</p>
        </div>
        <div class="modal-footer" style="padding-top: 0;">
            <button class="btn btn-secondary" style="flex: 1;" id="confirm-cancel">H&#7911;y B&#7887;</button>
            <button class="btn btn-primary" style="flex: 1; background-color: var(--danger); border-color: var(--danger);" id="confirm-delete">&#272;&#7891;ng &#221; X&#243;a</button>
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
