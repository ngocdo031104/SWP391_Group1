<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%-- Dương làm đoạn này
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
    <title>Quản Lý Coupon — TourBuddy Enterprise</title>
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=1.8">
    <style>
        /* Tùy chỉnh modal và bảng cho phù hợp với theme */
        .admin-dashboard-page { padding: 20px; }
        .dataTables_wrapper { background: #fff; padding: 20px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); margin-top: 20px; }
        .action-btn { background: none; border: none; cursor: pointer; color: var(--primary-color); }
        .action-btn:hover { color: var(--primary-hover); }
        .badge-active { background: #d1fae5; color: #065f46; padding: 4px 8px; border-radius: 4px; font-size: 0.85rem; }
        .badge-inactive { background: #fee2e2; color: #991b1b; padding: 4px 8px; border-radius: 4px; font-size: 0.85rem; }
        /* Fix: Tiêu đề header khu vực nội dung - chữ rõ ràng */
        .dashboard-header h2 { color: #ffffff !important; }
        .dashboard-header p { color: #ffffff !important; }
        /* Fix: Modal header nền tím - chữ trắng rõ */
        .modal-header { background: #4f46e5; color: #fff !important; }
        .modal-title { font-family: 'Outfit', sans-serif; font-weight: 600; color: #fff !important; }
        .btn-close { filter: invert(1); }
        /* Fix: Nội dung modal - nền trắng, chữ đen rõ */
        .modal-content { color: #1a202c; background-color: #ffffff; }
        .modal-body { background-color: #ffffff; }
        .modal-footer { background-color: #f9fafb; border-top: 1px solid #e5e7eb; }
        .modal-content .form-label { font-weight: 500; color: #374151; }
        .modal-content .form-control, .modal-content .form-select { color: #1a202c; background-color: #fff; border-color: #d1d5db; }
        .modal-content .form-control:focus, .modal-content .form-select:focus { border-color: #4f46e5; box-shadow: 0 0 0 0.25rem rgba(79, 70, 229, 0.25); }
        /* Fix: Nút Hủy - màu xám rõ ràng, không bị chìm */
        .modal-footer .btn-secondary { background-color: #6b7280 !important; border-color: #6b7280 !important; color: #ffffff !important; }
        .modal-footer .btn-secondary:hover { background-color: #4b5563 !important; border-color: #4b5563 !important; }
    </style>
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <!-- ── Left Sidebar ── -->
    <c:set var="activePage" value="coupons" scope="request" />
    <jsp:include page="sidebar.jsp" />

    <!-- ── Main Content Area ── -->
    <main class="main-content">
        <!-- Top Header -->
        <header class="top-header">
            <h1>Quản lý Coupon</h1>
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
                        <span class="name">${not empty sessionUser.fullName ? sessionUser.fullName : 'Admin User'}</span>
                        <span class="role">${(sessionUser.roleId eq 1 || userRole eq 'Admin') ? 'Quản trị viên' : 'Nhân viên'}</span>
                    </div>
                    <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80" alt="Avatar">
                </div>
            </div>
        </header>

        <!-- Main Content Inner Wrapper -->
        <div class="admin-dashboard-page">
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    ${sessionScope.successMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="successMessage" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    ${sessionScope.errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="errorMessage" scope="session"/>
            </c:if>

            <!-- Header Title & Add New Button -->
            <div class="dashboard-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">
                <div>
                    <h2 style="font-family: 'Outfit', sans-serif; font-size: 1.5rem; font-weight: 700; margin: 0; color: var(--text-light);">Danh Sách Mã Giảm Giá</h2>
                    <p style="color: var(--text-muted); margin-top: 0.25rem; font-size: 0.9rem;">Thêm, sửa, và cấu hình mã giảm giá</p>
                </div>
                <button class="btn btn-primary" onclick="openCouponModal()">
                    <i data-lucide="plus-circle" style="width: 18px; height: 18px; display: inline-block;"></i>
                    <span>Thêm Coupon</span>
                </button>
            </div>

            <!-- Custom Filters & Search -->
            <div class="row mb-3" style="background: #fff; padding: 15px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
                <div class="col-md-3">
                    <label class="form-label" style="font-weight: 500; color: #4a5568; font-size: 0.9rem;">Tìm kiếm mã/giá trị</label>
                    <input type="text" id="customSearch" class="form-control" placeholder="Nhập từ khóa...">
                </div>
                <div class="col-md-3">
                    <label class="form-label" style="font-weight: 500; color: #4a5568; font-size: 0.9rem;">Lọc theo loại giảm giá</label>
                    <select id="filterType" class="form-select">
                        <option value="">-- Tất cả --</option>
                        <option value="Phần Trăm (%)">Phần Trăm (%)</option>
                        <option value="Cố Định (VNĐ)">Cố Định (VNĐ)</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label" style="font-weight: 500; color: #4a5568; font-size: 0.9rem;">Lọc theo trạng thái</label>
                    <select id="filterStatus" class="form-select">
                        <option value="">-- Tất cả --</option>
                        <option value="Hoạt động">Hoạt động</option>
                        <option value="Tạm dừng">Tạm dừng</option>
                    </select>
                </div>
                <div class="col-md-3 d-flex align-items-end">
                    <button class="btn btn-outline-secondary w-100" id="resetFilters">
                        <i data-lucide="refresh-cw" style="width: 16px; height: 16px;"></i> Đặt lại bộ lọc
                    </button>
                </div>
            </div>

            <!-- Table -->
            <table id="couponTable" class="table table-striped" style="width:100%">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Mã</th>
                        <th>Loại Giảm</th>
                        <th>Giá Trị</th>
                        <th>Giảm Tối Đa</th>
                        <th>Đơn Tối Thiểu</th>
                        <th>Đã Dùng / Tối Đa</th>
                        <th>Ngày Bắt Đầu</th>
                        <th>Ngày Kết Thúc</th>
                        <th>Trạng Thái</th>
                        <th>Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="c" items="${coupons}">
                        <tr>
                            <td>${c.couponId}</td>
                            <td><strong>${c.couponCode}</strong></td>
                            <td>${c.discountType == 'Percentage' ? 'Phần Trăm (%)' : 'Cố Định (VNĐ)'}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${c.discountType == 'Percentage'}">${c.discountValue}%</c:when>
                                    <c:otherwise><fmt:formatNumber value="${c.discountValue}" type="number" groupingUsed="true"/> ₫</c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${c.maxDiscountAmount != null}"><fmt:formatNumber value="${c.maxDiscountAmount}" type="number" groupingUsed="true"/> ₫</c:when>
                                    <c:otherwise>Không giới hạn</c:otherwise>
                                </c:choose>
                            </td>
                            <td><fmt:formatNumber value="${c.minOrderAmount}" type="number" groupingUsed="true"/> ₫</td>
                            <td>${c.usedCount} / ${c.maxUses != null ? c.maxUses : '∞'}</td>
                            <td><fmt:formatDate value="${c.startDate}" pattern="dd/MM/yyyy"/></td>
                            <td><fmt:formatDate value="${c.endDate}" pattern="dd/MM/yyyy"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${c.isActive}">
                                        <span class="badge-active">Hoạt động</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-inactive">Tạm dừng</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div style="display: flex; gap: 10px;">
                                    <button class="action-btn" title="Chỉnh sửa" onclick="editCoupon(${c.couponId}, '${c.couponCode}', '${c.discountType}', ${c.discountValue}, ${c.minOrderAmount}, '${c.maxDiscountAmount != null ? c.maxDiscountAmount : ''}', '${c.maxUses != null ? c.maxUses : ''}', '${c.startDate}', '${c.endDate}', ${c.isActive})">
                                        <i data-lucide="edit"></i>
                                    </button>
                                    <form action="${pageContext.request.contextPath}/admin/coupons/toggle" method="post" style="display:inline;">
                                        <input type="hidden" name="couponId" value="${c.couponId}">
                                        <input type="hidden" name="status" value="${!c.isActive}">
                                        <button type="submit" class="action-btn" title="${c.isActive ? 'Tạm dừng' : 'Kích hoạt'}" style="color: ${c.isActive ? '#dc3545' : '#198754'}">
                                            <i data-lucide="${c.isActive ? 'power-off' : 'power'}"></i>
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
            <h5 class="modal-title" id="couponModalLabel">Thêm Coupon Mới</h5>
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
                <label for="discountType" class="form-label">Loại Giảm Giá</label>
                <select class="form-select" id="discountType" name="discountType">
                    <option value="Percentage">Phần Trăm (%)</option>
                    <option value="FixedAmount">Số Tiền Cố Định (VNĐ)</option>
                </select>
            </div>
            <div class="mb-3">
                <label for="discountValue" class="form-label">Giá Trị Giảm</label>
                <input type="number" class="form-control" id="discountValue" name="discountValue" step="0.01" required>
            </div>
            <div class="mb-3">
                <label for="minOrderAmount" class="form-label">Giá Trị Đơn Tối Thiểu (VNĐ)</label>
                <input type="number" class="form-control" id="minOrderAmount" name="minOrderAmount" step="1" required>
            </div>
            <div class="mb-3" id="maxDiscountContainer">
                <label for="maxDiscountAmount" class="form-label">Giảm Tối Đa (VNĐ) <span class="text-danger">*</span></label>
                <input type="number" class="form-control" id="maxDiscountAmount" name="maxDiscountAmount" step="1">
            </div>
            <div class="mb-3">
                <label for="maxUses" class="form-label">Số Lượng Tối Đa (Để trống = Vô hạn)</label>
                <input type="number" class="form-control" id="maxUses" name="maxUses" step="1">
            </div>
            <div class="row mb-3">
                <div class="col-6">
                    <label for="startDate" class="form-label">Ngày Bắt Đầu</label>
                    <input type="date" class="form-control" id="startDate" name="startDate" required>
                </div>
                <div class="col-6">
                    <label for="endDate" class="form-label">Ngày Kết Thúc</label>
                    <input type="date" class="form-control" id="endDate" name="endDate" required>
                </div>
            </div>
            <div class="form-check form-switch mb-3">
              <input class="form-check-input" type="checkbox" id="isActive" name="isActive" checked>
              <label class="form-check-label" for="isActive">Kích hoạt ngay</label>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
            <button type="submit" class="btn btn-primary">Lưu Coupon</button>
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
            pageLength: 10,       // Cố định 10 dòng mỗi trang, không cho đổi
            order: [[7, 'asc']],  // Mặc định sắp xếp theo Ngày Bắt Đầu
            dom: 'rt<"row"<"col-sm-12 d-flex justify-content-center"p>>', // Ẩn info (i), mặc định search (f), length (l). Chỉ giữ table(t) và pagination(p)
            // Chỉ cho phép sắp xếp ở cột Ngày Bắt Đầu (7) và Ngày Kết Thúc (8)
            columnDefs: [
                { orderable: false, targets: [0, 1, 2, 3, 4, 5, 6, 9, 10] },
                { orderable: true,  targets: [7, 8] }
            ]
        });

        // Dương làm phần này: Áp dụng bộ lọc tùy chỉnh theo loại giảm và trạng thái
        // Bảng sau khi thêm cột "Giảm Tối Đa":
        // 0=ID, 1=Mã, 2=Loại Giảm, 3=Giá Trị, 4=Giảm Tối Đa, 5=Đơn Tối Thiểu,
        // 6=Đã Dùng/Tối Đa, 7=Ngày Bắt Đầu, 8=Ngày Kết Thúc, 9=Trạng Thái, 10=Thao Tác
        // Dương làm phần này: Áp dụng tìm kiếm và bộ lọc tùy chỉnh
        $('#customSearch').on('keyup change', function() {
            table.search(this.value).draw();
        });

        $('#filterType').on('change', function() {
            table.column(2).search(this.value).draw();
        });

        $('#filterStatus').on('change', function() {
            table.column(9).search(this.value).draw(); // Cột 9 là Trạng Thái
        });

        $('#resetFilters').on('click', function() {
            $('#customSearch').val('');
            $('#filterType').val('');
            $('#filterStatus').val('');
            table.search('').columns().search('').draw();
        });
    });

    const couponModal = new bootstrap.Modal(document.getElementById('couponModal'));

    // Dương làm đoạn này: Khởi tạo modal thêm mới coupon (mặc định chưa kích hoạt)
    function openCouponModal() {
        document.getElementById('couponModalLabel').innerText = "Thêm Coupon Mới";
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

    function editCoupon(id, code, type, value, minOrder, maxDiscount, maxUses, start, end, isActive) {
        document.getElementById('couponModalLabel').innerText = "Cập Nhật Coupon";
        document.getElementById('couponId').value = id;
        document.getElementById('couponCode').value = code;
        document.getElementById('discountType').value = type;
        document.getElementById('discountValue').value = value;
        document.getElementById('minOrderAmount').value = minOrder;
        document.getElementById('maxDiscountAmount').value = maxDiscount;
        document.getElementById('maxUses').value = maxUses;
        
        // Convert date format from dd/MM/yyyy to yyyy-MM-dd for input[type=date]
        const startParts = start.split('/');
        const endParts = end.split('/');
        if(startParts.length === 3) document.getElementById('startDate').value = startParts[2] + '-' + startParts[1] + '-' + startParts[0];
        if(endParts.length === 3) document.getElementById('endDate').value = endParts[2] + '-' + endParts[1] + '-' + endParts[0];

        document.getElementById('isActive').checked = isActive;
        toggleMaxDiscountVisibility();
        couponModal.show();
    }

    // Dương làm phần này: Tự động ẩn/hiện và bắt buộc nhập trường giảm tối đa tùy theo loại giảm giá
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

    // Kiểm tra trùng mã coupon qua AJAX — hiển thị lỗi inline ngay dưới input
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
                    errEl.textContent = 'Mã coupon "' + code.trim() + '" đã tồn tại. Vui lòng dùng mã khác.';
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

    // Reset lỗi khi mở modal
    const _origOpenCouponModal = openCouponModal;
    openCouponModal = function() {
        _origOpenCouponModal();
        document.getElementById('couponCodeError').style.display = 'none';
        document.getElementById('couponCode').classList.remove('is-invalid');
        _couponCodeDuplicate = false;
    };
    const _origEditCoupon = editCoupon;
    editCoupon = function(id, code, type, value, minOrder, maxDiscount, maxUses, start, end, isActive) {
        _origEditCoupon(id, code, type, value, minOrder, maxDiscount, maxUses, start, end, isActive);
        document.getElementById('couponCodeError').style.display = 'none';
        document.getElementById('couponCode').classList.remove('is-invalid');
        _couponCodeDuplicate = false;
    };

    // Dương làm phần này: Validate ngày bắt đầu và kết thúc trước khi submit form
    document.querySelector('#couponModal form').addEventListener('submit', function(e) {
        // Chặn submit nếu mã coupon đang bị trùng
        if (_couponCodeDuplicate) {
            e.preventDefault();
            document.getElementById('couponCode').focus();
            return;
        }

        const startDateVal = document.getElementById('startDate').value;
        const endDateVal   = document.getElementById('endDate').value;

        if (!startDateVal || !endDateVal) return; // Để browser tự validate required

        const today     = new Date(); today.setHours(0, 0, 0, 0);
        const startDate = new Date(startDateVal);
        const endDate   = new Date(endDateVal);

        // Ngày bắt đầu phải từ hôm nay trở đi (chỉ kiểm tra khi tạo mới)
        const isNewCoupon = !document.getElementById('couponId').value;
        if (isNewCoupon && startDate < today) {
            alert('Ngày bắt đầu không được là ngày trong quá khứ!');
            e.preventDefault();
            return;
        }

        // Ngày kết thúc phải sau ngày bắt đầu
        if (endDate <= startDate) {
            alert('Ngày kết thúc phải sau ngày bắt đầu!');
            e.preventDefault();
            return;
        }
    });
</script>
</body>
</html>
