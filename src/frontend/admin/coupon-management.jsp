<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%--
    Người làm: Dương
    Thời gian tạo: 25/06/2026
    Chức năng: Giao diện quản lý mã giảm giá cho Admin.
    Ý nghĩa: Hiển thị danh sách coupon bằng Datatables, có nút thêm mới, sửa, và bật/tắt (toggle) từng coupon.
--%>
<c:if test="${empty sessionUser || (sessionUser.roleId ne 1 && userRole ne 'Admin')}">
    <c:redirect url="/login" />
</c:if>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Qu&#7843;n L&#253; Coupon &#151; TourBuddy Enterprise</title>
    <!-- Outfit & Inter Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons & FontAwesome CDNs -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- DataTables CSS -->
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
    <!-- Bootstrap CSS (for DataTables styling only) -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css">
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.3">
    <style>
        .admin-dashboard-page { padding: 20px; }
        .action-btn { background: none; border: none; cursor: pointer; color: var(--accent-cyan); transition: color 0.2s; }
        .action-btn:hover { color: #ffffff; }
        .badge-active { background: rgba(16, 185, 129, 0.2); color: #10b981; padding: 6px 10px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; border: 1px solid rgba(16, 185, 129, 0.3); }
        .badge-inactive { background: rgba(239, 68, 68, 0.2); color: #ef4444; padding: 6px 10px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; border: 1px solid rgba(239, 68, 68, 0.3); }
        .btn-close { filter: invert(1); }
    </style>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-space-overrides.css?v=1.0">
</head>
<body class="dashboard-body tb-cosmic">

<div class="dashboard-wrapper">
    <!-- -- Left Sidebar -- -->
    <c:set var="activePage" value="coupons" scope="request" />
    <jsp:include page="sidebar.jsp" />

    <!-- -- Main Content Area -- -->
    <main class="main-content theme-light">
        <!-- Top Header -->
        <header class="top-header">
            <h1>Qu&#7843;n l&#253; Coupon</h1>
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
                        <span class="name">${not empty sessionUser.fullName ? sessionUser.fullName : 'Admin User'}</span>
                        <span class="role">${(sessionUser.roleId eq 1 || userRole eq 'Admin') ? 'Qu&#7843;n tr&#7883; vi&#234;n' : 'Nh&#226;n vi&#234;n'}</span>
                    </div>
                    <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80" alt="Avatar">
                </div>
            </div>
        </header>

        <!-- Main Content Inner Wrapper -->
        <div class="admin-dashboard-page">
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <c:out value="${sessionScope.successMessage}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="successMessage" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <c:out value="${sessionScope.errorMessage}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="errorMessage" scope="session"/>
            </c:if>

            <!-- Header Title & Add New Button -->
            <div class="dashboard-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">
                <div>
                    <h2 style="font-family: 'Outfit', sans-serif; font-size: 1.5rem; font-weight: 700; margin: 0; color: var(--text-light);">Danh S&#225;ch M&#227; Gi&#7843;m Gi&#225;</h2>
                    <p style="color: var(--text-muted); margin-top: 0.25rem; font-size: 0.9rem;">Th&#234;m, s&#7917;a, v&#224; c&#7845;u h&#236;nh m&#227; gi&#7843;m gi&#225;</p>
                </div>
                <button class="btn btn-primary" onclick="openCouponModal()">
                    <i data-lucide="plus-circle" style="width: 18px; height: 18px; display: inline-block;"></i>
                    <span>Th&#234;m Coupon</span>
                </button>
            </div>

            <!-- Custom Filters & Search -->
            <div class="row mb-3 filter-card-row">
                <div class="col-md-3">
                    <label class="form-label">T&#236;m ki&#7871;m m&#227;/gi&#225; tr&#7883;</label>
                    <input type="text" id="customSearch" class="form-control" placeholder="Nh&#7853;p t&#7913; kh&#243;a...">
                </div>
                <div class="col-md-3">
                    <label class="form-label">L&#7885;c theo lo&#7841;i gi&#7843;m gi&#225;</label>
                    <select id="filterType" class="form-select">
                        <option value="">-- T&#7855;t c&#7843; --</option>
                        <option value="Ph&#7847;n Tr&#259;m (%)">Ph&#7847;n Tr&#259;m (%)</option>
                        <option value="C&#7889; &#272;&#7883;nh (VN&#272;)">C&#7889; &#272;&#7883;nh (VN&#272;)</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">L&#7885;c theo tr&#7840;ng th&#193;i</label>
                    <select id="filterStatus" class="form-select">
                        <option value="">-- T&#7855;t c&#7843; --</option>
                        <option value="Ho&#7841;t &#273;&#7897;ng">Ho&#7841;t &#273;&#7897;ng</option>
                        <option value="T&#7841;m d&#7915;ng">T&#7841;m d&#7915;ng</option>
                    </select>
                </div>
                <div class="col-md-3 d-flex align-items-end">
                    <button class="btn btn-outline-secondary w-100" id="resetFilters" style="padding: 9px 12px;">
                        <i data-lucide="refresh-cw" style="width: 16px; height: 16px; vertical-align: middle;"></i> &#272;&#7863;t l&#7841;i b&#7883; l&#7885;c
                    </button>
                </div>
            </div>

            <!-- Table -->
            <table id="couponTable" class="table table-striped" style="width:100%">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>M&#227;</th>
                        <th>Lo&#7841;i Gi&#7843;m</th>
                        <th>Gi&#225; Tr&#7883;</th>
                        <th>Gi&#7843;m T&#7889;i &#272;a</th>
                        <th>&#272;&#417;n T&#7889;i Thi&#7875;u</th>
                        <th>&#272;&#227; D&#249;ng / T&#7889;i &#272;a</th>
                        <th>Ng&#224;y B&#7855;t &#272;&#7847;u</th>
                        <th>Ng&#224;y K&#7871;t Th&#250;c</th>
                        <th>Tr&#7840;ng Th&#193;i</th>
                        <th>Thao t&#225;c</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="c" items="${coupons}">
                        <tr>
                            <td>${c.couponId}</td>
                            <td><strong>${c.couponCode}</strong></td>
                            <td>${c.discountType == 'Percentage' ? 'Ph&#7847;n Tr&#259;m (%)' : 'C&#7889; &#272;&#7883;nh (VN&#272;)'}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${c.discountType == 'Percentage'}">${c.discountValue}%</c:when>
                                    <c:otherwise><fmt:formatNumber value="${c.discountValue}" type="number" groupingUsed="true"/> &#8363;</c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${c.maxDiscountAmount != null}"><fmt:formatNumber value="${c.maxDiscountAmount}" type="number" groupingUsed="true"/> &#8363;</c:when>
                                    <c:otherwise>Kh&#244;ng gi&#7899;i h&#7841;n</c:otherwise>
                                </c:choose>
                            </td>
                            <td><fmt:formatNumber value="${c.minOrderAmount}" type="number" groupingUsed="true"/> &#8363;</td>
                            <td>${c.usedCount} / ${c.maxUses != null ? c.maxUses : 'V&#244; h&#7841;n'}</td>
                            <td><fmt:formatDate value="${c.startDate}" pattern="dd/MM/yyyy"/></td>
                            <td><fmt:formatDate value="${c.endDate}" pattern="dd/MM/yyyy"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${c.isActive}">
                                        <span class="badge-active">Ho&#7841;t &#273;&#7897;ng</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-inactive">T&#7841;m d&#7915;ng</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div style="display: flex; gap: 10px;">
                                    <button class="action-btn edit-coupon-btn"
                                            title="S&#7917;a"
                                            data-id="<c:out value='${c.couponId}'/>">
                                        <i data-lucide="edit"></i>
                                    </button>
                                    <form action="${pageContext.request.contextPath}/admin/coupons/toggle" method="post" style="display:inline;">
                                        <input type="hidden" name="couponId" value="<c:out value='${c.couponId}'/>">
                                        <input type="hidden" name="status" value="${!c.isActive}">
                                        <button type="submit" class="action-btn" title="<c:out value='${c.isActive ? "T&#7841;m d&#7915;ng" : "K&#237;ch ho&#7841;t"}'/>" style="color: <c:out value='${c.isActive ? "#dc3545" : "#198754"}'/>">
                                            <i data-lucide="<c:out value='${c.isActive ? "power-off" : "power"}'/>"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </main>
</div>

<!-- Modal Form -->
<div class="modal fade" id="couponModal" tabindex="-1" aria-labelledby="couponModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <form action="${pageContext.request.contextPath}/admin/coupons" method="post">
          <div class="modal-header">
            <h5 class="modal-title" id="couponModalLabel">Th&#234;m Coupon M&#7899;i</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <input type="hidden" id="couponId" name="couponId">
            <div class="mb-3">
                <label for="couponCode" class="form-label">M&#227; Coupon</label>
                <input type="text" class="form-control" id="couponCode" name="couponCode"
                       required style="text-transform:uppercase;"
                       oninput="this.value=this.value.toUpperCase()"
                       onblur="checkCouponCode(this.value)">
                <div id="couponCodeError" style="color:#dc3545; font-size:0.85rem; margin-top:4px; display:none;"></div>
            </div>
            <div class="mb-3">
                <label for="discountType" class="form-label">Lo&#7841;i Gi&#7843;m Gi&#225;</label>
                <select class="form-select" id="discountType" name="discountType">
                    <option value="Percentage">Ph&#7847;n Tr&#259;m (%)</option>
                    <option value="FixedAmount">S&#7889; Ti&#7873;n C&#7889; &#272;&#7883;nh (VN&#272;)</option>
                </select>
            </div>
            <div class="mb-3">
                <label for="discountValue" class="form-label">Gi&#225; Tr&#7883; Gi&#7843;m</label>
                <input type="number" class="form-control" id="discountValue" name="discountValue" step="0.01" required>
            </div>
            <div class="mb-3">
                <label for="minOrderAmount" class="form-label">Gi&#225; Tr&#7883; &#272;&#417;n T&#7889;i Thi&#7875;u (VN&#272;)</label>
                <input type="number" class="form-control" id="minOrderAmount" name="minOrderAmount" step="1" required>
            </div>
            <div class="mb-3" id="maxDiscountContainer">
                <label for="maxDiscountAmount" class="form-label">Gi&#7843;m T&#7889;i &#272;a (VN&#272;) <span class="text-danger">*</span></label>
                <input type="number" class="form-control" id="maxDiscountAmount" name="maxDiscountAmount" step="1">
            </div>
            <div class="mb-3">
                <label for="maxUses" class="form-label">S&#7889; L&#432;&#7907;t T&#7889;i &#272;a (&#272;&#7875; tr&#7888;ng = V&#244; h&#7841;n)</label>
                <input type="number" class="form-control" id="maxUses" name="maxUses" step="1">
            </div>
            <div class="row mb-3">
                <div class="col-6">
                    <label for="startDate" class="form-label">Ng&#224;y B&#7855;t &#272;&#7847;u</label>
                    <input type="date" class="form-control" id="startDate" name="startDate" required>
                </div>
                <div class="col-6">
                    <label for="endDate" class="form-label">Ng&#224;y K&#7871;t Th&#250;c</label>
                    <input type="date" class="form-control" id="endDate" name="endDate" required>
                </div>
            </div>
            <div class="form-check form-switch mb-3">
              <input class="form-check-input" type="checkbox" id="isActive" name="isActive" checked>
              <label class="form-check-label" for="isActive">K&#237;ch ho&#7841;t ngay</label>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">H&#7911;y</button>
            <button type="submit" class="btn btn-primary">L&#432;u Coupon</button>
          </div>
      </form>
    </div>
  </div>
</div>

<!-- Scripts -->
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
<script>
    lucide.createIcons();
    $(document).ready(function() {
        var table = $('#couponTable').DataTable({
            language: {
                url: '//cdn.datatables.net/plug-ins/1.13.6/i18n/vi.json'
            },
            pageLength: 10,       // C? d?nh 10 d\u00f2ng m?i trang, kh\u00f4ng cho d?i
            order: [[7, 'asc']],  // M?c d?nh s?p x?p theo Ng\u00e0y B?t \u00d0?u
            dom: 'rt<"row"<"col-sm-12 d-flex justify-content-center"p>>', // ?n info (i), m?c d?nh search (f), length (l). Ch? gi? table(t) v\u00e0 pagination(p)
            // Ch? cho ph\u00e9p s?p x?p ? c?t Ng\u00e0y B?t \u00d0?u (7) v\u00e0 Ng\u00e0y K?t Th\u00fac (8)
            columnDefs: [
                { orderable: false, targets: [0, 1, 2, 3, 4, 5, 6, 9, 10] },
                { orderable: true,  targets: [7, 8] }
            ]
        });

        // Duong l\u00e0m ph?n n\u00e0y: \u00c1p d?ng b? l?c t\u00f9y ch?nh theo lo?i gi?m v\u00e0 tr?ng th\u00e1i
        // B?ng sau khi th\u00eam c?t "Gi?m T?i \u00d0a":
        // 0=ID, 1=M\u00e3, 2=Lo?i Gi?m, 3=Gi\u00e1 Tr?, 4=Gi?m T?i \u00d0a, 5=\u00d0on T?i Thi?u,
        // 6=\u00d0\u00e3 D\u00f9ng/T?i \u00d0a, 7=Ng\u00e0y B?t \u00d0?u, 8=Ng\u00e0y K?t Th\u00fac, 9=Tr?ng Th\u00e1i, 10=Thao T\u00e1c
        // Duong l\u00e0m ph?n n\u00e0y: \u00c1p d?ng t\u00ecm ki?m v\u00e0 b? l?c t\u00f9y ch?nh
        $('#customSearch').on('keyup change', function() {
            table.search(this.value).draw();
        });

        $('#filterType').on('change', function() {
            table.column(2).search(this.value).draw();
        });

        $('#filterStatus').on('change', function() {
            table.column(9).search(this.value).draw(); // C?t 9 l\u00e0 Tr?ng Th\u00e1i
        });

        $('#resetFilters').on('click', function() {
            $('#customSearch').val('');
            $('#filterType').val('');
            $('#filterStatus').val('');
            table.search('').columns().search('').draw();
        });
    });

    const couponModal = new bootstrap.Modal(document.getElementById('couponModal'));

    // Khởi tạo modal thêm mới coupon (mặc định chưa kích hoạt)
    function openCouponModal() {
        document.getElementById('couponModalLabel').innerText = "Th\u00eam Coupon M\u1edbi";
        document.getElementById('couponId').value = "";
        document.getElementById('couponCode').value = "";
        document.getElementById('discountType').value = "Percentage";
        document.getElementById('discountValue').value = "";
        document.getElementById('minOrderAmount').value = "0";
        document.getElementById('maxDiscountAmount').value = "";
        document.getElementById('maxUses').value = "";
        document.getElementById('startDate').value = "";
        document.getElementById('endDate').value = "";
        document.getElementById('isActive').checked = false; // Mặc định chưa kích hoạt
        toggleMaxDiscountVisibility();
        couponModal.show();
    }

    function editCoupon(id) {
        const url = '${pageContext.request.contextPath}/admin/coupons?action=getCoupon&id=' + encodeURIComponent(id);
        fetch(url)
            .then(r => r.json())
            .then(res => {
                if (res.status !== 'success' || !res.coupon) {
                    alert('Kh\u00f4ng t\u1ea3i \u0111\u01b0\u1ee3c coupon: ' + (res.message || 'L\u1ed7i kh\u00f4ng x\u00e1c \u0111\u1ecbnh.'));
                    return;
                }
                const c = res.coupon;
                document.getElementById('couponModalLabel').innerText = "C\u1eadp Nh\u1eadt Coupon";
                document.getElementById('couponId').value = c.couponId;
                document.getElementById('couponCode').value = c.couponCode;
                document.getElementById('discountType').value = c.discountType;
                document.getElementById('discountValue').value = c.discountValue;
                document.getElementById('minOrderAmount').value = c.minOrderAmount;
                document.getElementById('maxDiscountAmount').value = c.maxDiscountAmount == null ? '' : c.maxDiscountAmount;
                document.getElementById('maxUses').value = c.maxUses == null ? '' : c.maxUses;
                document.getElementById('startDate').value = c.startDate || '';
                document.getElementById('endDate').value = c.endDate || '';
                document.getElementById('isActive').checked = !!c.isActive;
                toggleMaxDiscountVisibility();
                couponModal.show();
            })
            .catch(() => alert('L\u1ed7i k\u1ebft n\u1ed1i khi t\u1ea3i coupon.'));
    }

    // G?n handler cho t?t c? n\u00fat edit \u0097 an to\u00e0n, kh\u00f4ng nh\u00fang d? li?u v\u00e0o onclick.
    document.querySelectorAll('.edit-coupon-btn').forEach(btn => {
        btn.addEventListener('click', () => editCoupon(btn.getAttribute('data-id')));
    });

    // Duong l\u00e0m ph?n n\u00e0y: T? d?ng ?n/hi?n v\u00e0 b?t bu?c nh?p tru?ng gi?m t?i da t\u00f9y theo lo?i gi?m gi\u00e1
    function toggleMaxDiscountVisibility() {
        const maxDiscountInput = document.getElementById('maxDiscountAmount');
        if(document.getElementById('discountType').value === 'Percentage') {
            document.getElementById('maxDiscountContainer').style.display = 'block';
            maxDiscountInput.setAttribute('required', 'required');
        } else {
            document.getElementById('maxDiscountContainer').style.display = 'none';
            maxDiscountInput.removeAttribute('required');
            maxDiscountInput.value = '';
        }
    }
    document.getElementById('discountType').addEventListener('change', toggleMaxDiscountVisibility);

    // Ki?m tra tr\u00f9ng m\u00e3 coupon qua AJAX \u0097 hi?n th? l?i inline ngay du?i input
    let _couponCodeDuplicate = false;

    function checkCouponCode(code) {
        const errEl = document.getElementById('couponCodeError');
        const inputEl = document.getElementById('couponCode');
        if (!code || !code.trim()) {
            errEl.style.display = 'none';
            inputEl.classList.remove('is-invalid');
            _couponCodeDuplicate = false;
            return;
        }
        const excludeId = document.getElementById('couponId').value || '';
        const url = '${pageContext.request.contextPath}/admin/coupons?action=checkCode&code=' + encodeURIComponent(code.trim()) + '&excludeId=' + encodeURIComponent(excludeId);
        fetch(url)
            .then(r => r.json())
            .then(data => {
                if (data.exists) {
                    errEl.textContent = 'M\u00e3 coupon "' + code.trim() + '" d\u00e3 t\u1ed3n t\u1ea1i. Vui l\u00f2ng d\u00f9ng m\u00e3 kh\u00e1c.';
                    errEl.style.display = 'block';
                    inputEl.classList.add('is-invalid');
                    _couponCodeDuplicate = true;
                } else {
                    errEl.style.display = 'none';
                    inputEl.classList.remove('is-invalid');
                    _couponCodeDuplicate = false;
                }
            })
            .catch(() => { _couponCodeDuplicate = false; });
    }

    // Reset l?i khi m? modal
    const _origOpenCouponModal = openCouponModal;
    openCouponModal = function() {
        _origOpenCouponModal();
        document.getElementById('couponCodeError').style.display = 'none';
        document.getElementById('couponCode').classList.remove('is-invalid');
        _couponCodeDuplicate = false;
    };
    const _origEditCoupon = editCoupon;
    editCoupon = function(id) {
        _origEditCoupon(id);
        document.getElementById('couponCodeError').style.display = 'none';
        document.getElementById('couponCode').classList.remove('is-invalid');
        _couponCodeDuplicate = false;
    };

    // Duong l\u00e0m ph?n n\u00e0y: Validate ng\u00e0y b?t d?u v\u00e0 k?t th\u00fac tru?c khi submit form
    document.querySelector('#couponModal form').addEventListener('submit', function(e) {
        // Ch?n submit n?u m\u00e3 coupon dang b? tr\u00f9ng
        if (_couponCodeDuplicate) {
            e.preventDefault();
            document.getElementById('couponCode').focus();
            return;
        }

        const startDateVal = document.getElementById('startDate').value;
        const endDateVal   = document.getElementById('endDate').value;

        if (!startDateVal || !endDateVal) return; // \u00d0? browser t? validate required

        const today     = new Date(); today.setHours(0, 0, 0, 0);
        const startDate = new Date(startDateVal);
        const endDate   = new Date(endDateVal);

        // Ng&#224;y b&#7855;t &#272;&#7847;u ph&#7843;i t&#7913; h&#244;m nay tr&#7903; &#273;i (ch&#7881; ki&#7875;m tra khi t&#7841;o m&#7899;i)
        const isNewCoupon = !document.getElementById('couponId').value;
        if (isNewCoupon && startDate < today) {
            alert('Ng\u00e0y b\u1ea8t \u0111\u1ea7u kh\u00f4ng \u0111\u01b0\u1ee3c l\u00e0 ng\u00e0y trong qu\u00e1 kh\u1ee9!');
            e.preventDefault();
            return;
        }

        // Ngày kết thúc phải sau ngày bắt đầu
        if (endDate <= startDate) {
            alert('Ng\u00e0y k\u1ebft th\u00fac ph\u1ea3i sau ng\u00e0y b\u1eaft \u0111\u1ea7u!');
            e.preventDefault();
            return;
        }
    });
</script>
</body>
</html>
