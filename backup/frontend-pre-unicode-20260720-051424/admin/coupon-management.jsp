<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%-- Duong làm do?n này
     Th?i gian t?o: 25/06/2026
     Ch?c nang: Giao di?n qu?n lý mã gi?m giá cho Admin.
     Ý nghia: Hi?n th? danh sách coupon b?ng Datatables, có nút thêm m?i, s?a, và b?t/t?t (toggle) t?ng coupon.
--%>
<c:if test="${empty sessionUser || (sessionUser.roleId ne 1 && userRole ne 'Admin')}">
    <c:redirect url="/login" />
</c:if>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Qu?n Lý Coupon — TourBuddy Enterprise</title>
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.1">
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
    <main class="main-content">
        <!-- Top Header -->
        <header class="top-header">
            <h1>Qu?n lý Coupon</h1>
            <div class="header-right">
                <div class="header-search">
                    <i data-lucide="search"></i>
                    <input type="text" placeholder="Tìm ki?m nhanh h? th?ng...">
                </div>
                
                <div class="notif-bell" aria-label="Thông báo">
                    <i data-lucide="bell"></i>
                    <span class="badge">3</span>
                </div>
                
                <div class="profile-user dropdown-trigger" style="cursor: pointer; position: relative;" id="admin-profile-trigger">
                    <div class="profile-meta" style="text-align: right; margin-right: 5px;">
                        <span class="name">${not empty sessionUser.fullName ? sessionUser.fullName : 'Admin User'}</span>
                        <span class="role">${(sessionUser.roleId eq 1 || userRole eq 'Admin') ? 'Qu?n tr? viên' : 'Nhân viên'}</span>
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
                    <h2 style="font-family: 'Outfit', sans-serif; font-size: 1.5rem; font-weight: 700; margin: 0; color: var(--text-light);">Danh Sách Mã Gi?m Giá</h2>
                    <p style="color: var(--text-muted); margin-top: 0.25rem; font-size: 0.9rem;">Thêm, s?a, và c?u hình mã gi?m giá</p>
                </div>
                <button class="btn btn-primary" onclick="openCouponModal()">
                    <i data-lucide="plus-circle" style="width: 18px; height: 18px; display: inline-block;"></i>
                    <span>Thêm Coupon</span>
                </button>
            </div>

            <!-- Custom Filters & Search -->
            <div class="row mb-3 filter-card-row">
                <div class="col-md-3">
                    <label class="form-label">Tìm ki?m mã/giá tr?</label>
                    <input type="text" id="customSearch" class="form-control" placeholder="Nh?p t? khóa...">
                </div>
                <div class="col-md-3">
                    <label class="form-label">L?c theo lo?i gi?m giá</label>
                    <select id="filterType" class="form-select">
                        <option value="">-- T?t c? --</option>
                        <option value="Ph?n Tram (%)">Ph?n Tram (%)</option>
                        <option value="C? Ð?nh (VNÐ)">C? Ð?nh (VNÐ)</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">L?c theo tr?ng thái</label>
                    <select id="filterStatus" class="form-select">
                        <option value="">-- T?t c? --</option>
                        <option value="Ho?t d?ng">Ho?t d?ng</option>
                        <option value="T?m d?ng">T?m d?ng</option>
                    </select>
                </div>
                <div class="col-md-3 d-flex align-items-end">
                    <button class="btn btn-outline-secondary w-100" id="resetFilters" style="padding: 9px 12px;">
                        <i data-lucide="refresh-cw" style="width: 16px; height: 16px; vertical-align: middle;"></i> Ð?t l?i b? l?c
                    </button>
                </div>
            </div>

            <!-- Table -->
            <table id="couponTable" class="table table-striped" style="width:100%">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Mã</th>
                        <th>Lo?i Gi?m</th>
                        <th>Giá Tr?</th>
                        <th>Gi?m T?i Ða</th>
                        <th>Ðon T?i Thi?u</th>
                        <th>Ðã Dùng / T?i Ða</th>
                        <th>Ngày B?t Ð?u</th>
                        <th>Ngày K?t Thúc</th>
                        <th>Tr?ng Thái</th>
                        <th>Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="c" items="${coupons}">
                        <tr>
                            <td>${c.couponId}</td>
                            <td><strong>${c.couponCode}</strong></td>
                            <td>${c.discountType == 'Percentage' ? 'Ph?n Tram (%)' : 'C? Ð?nh (VNÐ)'}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${c.discountType == 'Percentage'}">${c.discountValue}%</c:when>
                                    <c:otherwise><fmt:formatNumber value="${c.discountValue}" type="number" groupingUsed="true"/> ?</c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${c.maxDiscountAmount != null}"><fmt:formatNumber value="${c.maxDiscountAmount}" type="number" groupingUsed="true"/> ?</c:when>
                                    <c:otherwise>Không gi?i h?n</c:otherwise>
                                </c:choose>
                            </td>
                            <td><fmt:formatNumber value="${c.minOrderAmount}" type="number" groupingUsed="true"/> ?</td>
                            <td>${c.usedCount} / ${c.maxUses != null ? c.maxUses : '8'}</td>
                            <td><fmt:formatDate value="${c.startDate}" pattern="dd/MM/yyyy"/></td>
                            <td><fmt:formatDate value="${c.endDate}" pattern="dd/MM/yyyy"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${c.isActive}">
                                        <span class="badge-active">Ho?t d?ng</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-inactive">T?m d?ng</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div style="display: flex; gap: 10px;">
                                    <button class="action-btn edit-coupon-btn"
                                            title="Ch?nh s?a"
                                            data-id="<c:out value='${c.couponId}'/>">
                                        <i data-lucide="edit"></i>
                                    </button>
                                    <form action="${pageContext.request.contextPath}/admin/coupons/toggle" method="post" style="display:inline;">
                                        <input type="hidden" name="couponId" value="<c:out value='${c.couponId}'/>">
                                        <input type="hidden" name="status" value="${!c.isActive}">
                                        <button type="submit" class="action-btn" title="<c:out value='${c.isActive ? "T?m d?ng" : "Kích ho?t"}'/>" style="color: <c:out value='${c.isActive ? "#dc3545" : "#198754"}'/>">
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
            <h5 class="modal-title" id="couponModalLabel">Thêm Coupon M?i</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <input type="hidden" id="couponId" name="couponId">
            <div class="mb-3">
                <label for="couponCode" class="form-label">Mã Coupon</label>
                <input type="text" class="form-control" id="couponCode" name="couponCode"
                       required style="text-transform:uppercase;"
                       oninput="this.value=this.value.toUpperCase()"
                       onblur="checkCouponCode(this.value)">
                <div id="couponCodeError" style="color:#dc3545; font-size:0.85rem; margin-top:4px; display:none;"></div>
            </div>
            <div class="mb-3">
                <label for="discountType" class="form-label">Lo?i Gi?m Giá</label>
                <select class="form-select" id="discountType" name="discountType">
                    <option value="Percentage">Ph?n Tram (%)</option>
                    <option value="FixedAmount">S? Ti?n C? Ð?nh (VNÐ)</option>
                </select>
            </div>
            <div class="mb-3">
                <label for="discountValue" class="form-label">Giá Tr? Gi?m</label>
                <input type="number" class="form-control" id="discountValue" name="discountValue" step="0.01" required>
            </div>
            <div class="mb-3">
                <label for="minOrderAmount" class="form-label">Giá Tr? Ðon T?i Thi?u (VNÐ)</label>
                <input type="number" class="form-control" id="minOrderAmount" name="minOrderAmount" step="1" required>
            </div>
            <div class="mb-3" id="maxDiscountContainer">
                <label for="maxDiscountAmount" class="form-label">Gi?m T?i Ða (VNÐ) <span class="text-danger">*</span></label>
                <input type="number" class="form-control" id="maxDiscountAmount" name="maxDiscountAmount" step="1">
            </div>
            <div class="mb-3">
                <label for="maxUses" class="form-label">S? Lu?ng T?i Ða (Ð? tr?ng = Vô h?n)</label>
                <input type="number" class="form-control" id="maxUses" name="maxUses" step="1">
            </div>
            <div class="row mb-3">
                <div class="col-6">
                    <label for="startDate" class="form-label">Ngày B?t Ð?u</label>
                    <input type="date" class="form-control" id="startDate" name="startDate" required>
                </div>
                <div class="col-6">
                    <label for="endDate" class="form-label">Ngày K?t Thúc</label>
                    <input type="date" class="form-control" id="endDate" name="endDate" required>
                </div>
            </div>
            <div class="form-check form-switch mb-3">
              <input class="form-check-input" type="checkbox" id="isActive" name="isActive" checked>
              <label class="form-check-label" for="isActive">Kích ho?t ngay</label>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">H?y</button>
            <button type="submit" class="btn btn-primary">Luu Coupon</button>
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
            pageLength: 10,       // C? d?nh 10 dòng m?i trang, không cho d?i
            order: [[7, 'asc']],  // M?c d?nh s?p x?p theo Ngày B?t Ð?u
            dom: 'rt<"row"<"col-sm-12 d-flex justify-content-center"p>>', // ?n info (i), m?c d?nh search (f), length (l). Ch? gi? table(t) và pagination(p)
            // Ch? cho phép s?p x?p ? c?t Ngày B?t Ð?u (7) và Ngày K?t Thúc (8)
            columnDefs: [
                { orderable: false, targets: [0, 1, 2, 3, 4, 5, 6, 9, 10] },
                { orderable: true,  targets: [7, 8] }
            ]
        });

        // Duong làm ph?n này: Áp d?ng b? l?c tùy ch?nh theo lo?i gi?m và tr?ng thái
        // B?ng sau khi thêm c?t "Gi?m T?i Ða":
        // 0=ID, 1=Mã, 2=Lo?i Gi?m, 3=Giá Tr?, 4=Gi?m T?i Ða, 5=Ðon T?i Thi?u,
        // 6=Ðã Dùng/T?i Ða, 7=Ngày B?t Ð?u, 8=Ngày K?t Thúc, 9=Tr?ng Thái, 10=Thao Tác
        // Duong làm ph?n này: Áp d?ng tìm ki?m và b? l?c tùy ch?nh
        $('#customSearch').on('keyup change', function() {
            table.search(this.value).draw();
        });

        $('#filterType').on('change', function() {
            table.column(2).search(this.value).draw();
        });

        $('#filterStatus').on('change', function() {
            table.column(9).search(this.value).draw(); // C?t 9 là Tr?ng Thái
        });

        $('#resetFilters').on('click', function() {
            $('#customSearch').val('');
            $('#filterType').val('');
            $('#filterStatus').val('');
            table.search('').columns().search('').draw();
        });
    });

    const couponModal = new bootstrap.Modal(document.getElementById('couponModal'));

    // Duong làm do?n này: Kh?i t?o modal thêm m?i coupon (m?c d?nh chua kích ho?t)
    function openCouponModal() {
        document.getElementById('couponModalLabel').innerText = "Thêm Coupon M?i";
        document.getElementById('couponId').value = "";
        document.getElementById('couponCode').value = "";
        document.getElementById('discountType').value = "Percentage";
        document.getElementById('discountValue').value = "";
        document.getElementById('minOrderAmount').value = "0";
        document.getElementById('maxDiscountAmount').value = "";
        document.getElementById('maxUses').value = "";
        document.getElementById('startDate').value = "";
        document.getElementById('endDate').value = "";
        document.getElementById('isActive').checked = false; // M?c d?nh chua kích ho?t
        toggleMaxDiscountVisibility();
        couponModal.show();
    }

    function editCoupon(id) {
        const url = '${pageContext.request.contextPath}/admin/coupons?action=getCoupon&id=' + encodeURIComponent(id);
        fetch(url)
            .then(r => r.json())
            .then(res => {
                if (res.status !== 'success' || !res.coupon) {
                    alert('Không t?i du?c coupon: ' + (res.message || 'L?i không xác d?nh.'));
                    return;
                }
                const c = res.coupon;
                document.getElementById('couponModalLabel').innerText = "C?p Nh?t Coupon";
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
            .catch(() => alert('L?i k?t n?i khi t?i coupon.'));
    }

    // G?n handler cho t?t c? nút edit — an toàn, không nhúng d? li?u vào onclick.
    document.querySelectorAll('.edit-coupon-btn').forEach(btn => {
        btn.addEventListener('click', () => editCoupon(btn.getAttribute('data-id')));
    });

    // Duong làm ph?n này: T? d?ng ?n/hi?n và b?t bu?c nh?p tru?ng gi?m t?i da tùy theo lo?i gi?m giá
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

    // Ki?m tra trùng mã coupon qua AJAX — hi?n th? l?i inline ngay du?i input
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
                    errEl.textContent = 'Mã coupon "' + code.trim() + '" dã t?n t?i. Vui lòng dùng mã khác.';
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

    // Duong làm ph?n này: Validate ngày b?t d?u và k?t thúc tru?c khi submit form
    document.querySelector('#couponModal form').addEventListener('submit', function(e) {
        // Ch?n submit n?u mã coupon dang b? trùng
        if (_couponCodeDuplicate) {
            e.preventDefault();
            document.getElementById('couponCode').focus();
            return;
        }

        const startDateVal = document.getElementById('startDate').value;
        const endDateVal   = document.getElementById('endDate').value;

        if (!startDateVal || !endDateVal) return; // Ð? browser t? validate required

        const today     = new Date(); today.setHours(0, 0, 0, 0);
        const startDate = new Date(startDateVal);
        const endDate   = new Date(endDateVal);

        // Ngày b?t d?u ph?i t? hôm nay tr? di (ch? ki?m tra khi t?o m?i)
        const isNewCoupon = !document.getElementById('couponId').value;
        if (isNewCoupon && startDate < today) {
            alert('Ngày b?t d?u không du?c là ngày trong quá kh?!');
            e.preventDefault();
            return;
        }

        // Ngày k?t thúc ph?i sau ngày b?t d?u
        if (endDate <= startDate) {
            alert('Ngày k?t thúc ph?i sau ngày b?t d?u!');
            e.preventDefault();
            return;
        }
    });
</script>
</body>
</html>
