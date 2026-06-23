<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:if test="${empty sessionUser || (sessionUser.roleId ne 1 && userRole ne 'Admin')}">
    <c:redirect url="/login" />
</c:if>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Phân Quyền & Vai Trò — TourBuddy Enterprise</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=1.6">
    <style>
        .permission-badge { display: inline-block; background: #eef2ff; padding: 4px 8px; margin: 3px; border-radius: 4px; font-size: 12px; color: #4f46e5; border: 1px solid #c7d2fe; transition: all 0.2s; }
        .permission-badge:hover { background: #4f46e5 !important; color: #ffffff !important; border-color: #4f46e5; }
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); }
        .modal-content { background-color: #fff; margin: 5% auto; padding: 25px; border-radius: 12px; width: 60%; box-shadow: 0 10px 25px rgba(0,0,0,0.2); max-height: 85vh; overflow-y: auto; }
        .modal-content.small { width: 40%; }
        .close { color: #aaa; float: right; font-size: 28px; font-weight: bold; cursor: pointer; }
        .close:hover { color: black; }
        .grid-container { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 12px; margin-top: 15px; }
        .perm-label { cursor: pointer; padding: 10px; border: 1px solid #eaeaea; border-radius: 6px; display: flex; align-items: center; gap: 8px; transition: all 0.2s; }
        .perm-label:hover { background-color: #f8fafc; border-color: var(--primary-color); }
        .perm-label input { width: 16px; height: 16px; accent-color: var(--primary-color); }
        .matrix-label { padding: 4px; transition: all 0.2s; border-radius: 4px; }
        .matrix-label:hover { background-color: #f1f5f9; }
        .matrix-label:hover .perm-text { color: #0f172a !important; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: 500; }
        .form-group input, .form-group textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px; font-family: 'Inter', sans-serif; }
    </style>
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
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
            <li>
                <a href="${pageContext.request.contextPath}/admin/users">
                    <i data-lucide="users"></i>
                    <span>Quản Lý Người Dùng</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/users?action=history">
                    <i data-lucide="history"></i>
                    <span>Lịch Sử Quản Trị</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/tours">
                    <i data-lucide="compass"></i>
                    <span>Quản Lý Tour</span>
                </a>
            </li>
            <li><a href="#"><i data-lucide="calendar"></i><span>Lịch Trình & Giá</span></a></li>
            <li><a href="#"><i data-lucide="image"></i><span>Thư Viện Media</span></a></li>
            <li><a href="#"><i data-lucide="bar-chart-3"></i><span>Thống Kê Chi Tiết</span></a></li>
            <li><a href="#"><i data-lucide="file-text"></i><span>Báo Cáo Doanh Thu</span></a></li>
            <li><a href="#"><i data-lucide="trending-up"></i><span>Dự Báo & Xu Hướng</span></a></li>
            <li class="active">
                <a href="${pageContext.request.contextPath}/admin/roles">
                    <i data-lucide="shield-check"></i>
                    <span>Phân Quyền</span>
                </a>
            </li>
            <li><a href="#"><i data-lucide="settings"></i><span>Cấu Hình</span></a></li>
        </ul>
        
        <div class="sidebar-footer">
            <a href="${pageContext.request.contextPath}/logout" style="color: var(--error-red); margin-top: 5px;">
                <i data-lucide="log-out"></i><span>Đăng Xuất</span>
            </a>
        </div>
    </aside>

    <main class="main-content">
        <header class="top-header">
            <h1>Phân Quyền Hệ Thống</h1>
            <div class="header-right">
                <div class="header-search">
                    <i data-lucide="search"></i>
                    <input type="text" id="searchInput" placeholder="Tìm kiếm vai trò...">
                </div>
                <div class="profile-user dropdown-trigger" style="cursor: pointer; position: relative;">
                    <div class="profile-meta" style="text-align: right; margin-right: 5px;">
                        <span class="name">${not empty sessionUser.fullName ? sessionUser.fullName : 'Admin'}</span>
                        <span class="role">Quản trị viên</span>
                    </div>
                    <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80" alt="Avatar">
                </div>
            </div>
        </header>

        <section class="view-panel active">
            <c:if test="${not empty sessionScope.errorMsg}">
                <div style="background: #fdeaea; color: #d32f2f; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
                    <i data-lucide="alert-circle" style="vertical-align: middle; margin-right: 5px;"></i>
                    ${sessionScope.errorMsg}
                </div>
                <c:remove var="errorMsg" scope="session"/>
            </c:if>

            <div class="content-card">
                <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                    <h3 class="card-title">Danh Sách Vai Trò (Roles)</h3>
                    <button class="btn btn-primary" onclick="openRoleModal('create')">
                        <i data-lucide="plus"></i> Tạo Vai Trò Mới
                    </button>
                </div>
                <div class="card-body table-responsive" style="padding: 0;">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Tên Vai Trò</th>
                                <th>Mô Tả</th>
                                <th>Quyền Hạn Hiện Tại</th>
                                <th style="width: 250px;">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody id="rolesTableBody">
                            <c:forEach var="role" items="${roles}">
                                <tr>
                                    <td>#${role.roleId}</td>
                                    <td><strong>${role.roleName}</strong></td>
                                    <td>${role.description}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${empty role.permissions}">
                                                <span style="color: #999; font-size: 13px;">Chưa gán quyền</span>
                                            </c:when>
                                            <c:otherwise>
                                                <details style="cursor: pointer; outline: none;">
                                                    <summary style="font-weight: 500; color: #4f46e5; font-size: 13px; margin-bottom: 5px;">Xem danh sách quyền hạn</summary>
                                                    <div style="margin-top: 5px; max-height: 150px; overflow-y: auto; padding-right: 5px;">
                                                        <c:forEach var="p" items="${role.permissions}">
                                                            <span class="permission-badge">${p.moduleName}: ${p.action}</span>
                                                        </c:forEach>
                                                    </div>
                                                </details>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div style="display: flex; gap: 5px;">
                                            <button class="btn btn-secondary btn-sm" onclick="openPermModal(${role.roleId}, '${role.roleName}')" title="Phân quyền">
                                                <i data-lucide="shield"></i> Quyền
                                            </button>
                                            <button class="btn btn-secondary btn-sm" onclick="openRoleModal('edit', ${role.roleId}, '${role.roleName}', '${role.description}')" title="Sửa">
                                                <i data-lucide="edit"></i>
                                            </button>
                                            <c:if test="${role.roleId != 1 && role.roleId != 4}">
                                                <form action="${pageContext.request.contextPath}/admin/roles" method="post" style="display:inline;" onsubmit="return confirm('Bạn có chắc muốn xóa vai trò này?');">
                                                    <input type="hidden" name="action" value="deleteRole">
                                                    <input type="hidden" name="roleId" value="${role.roleId}">
                                                    <button type="submit" class="btn btn-sm" style="background:#fff0f0; color:#dc2626; border:1px solid #fecaca;" title="Xóa">
                                                        <i data-lucide="trash-2"></i>
                                                    </button>
                                                </form>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>
    </main>
</div>

<div id="permModal" class="modal">
    <div class="modal-content" style="width: 70%;">
        <span class="close" onclick="closeModal('permModal')">&times;</span>
        <h3 id="permModalTitle" style="margin-top: 0; margin-bottom: 15px; color: var(--text-dark); font-family: 'Outfit', sans-serif;">Cập Nhật Quyền Hạn (Ma Trận)</h3>
        
        <form id="permissionForm" onsubmit="submitPermissions(event)">
            <input type="hidden" id="permRoleIdInput" name="roleId" value="">
            
            <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
                <table class="admin-table" style="width: 100%; border-collapse: collapse;">
                    <thead style="position: sticky; top: 0; background: #f8fafc; z-index: 1;">
                        <tr>
                            <th style="border-bottom: 2px solid #ddd; padding: 10px;">Module</th>
                            <th style="border-bottom: 2px solid #ddd; padding: 10px; text-align: center;">Tất Cả</th>
                            <th style="border-bottom: 2px solid #ddd; padding: 10px; text-align: center;">Read</th>
                            <th style="border-bottom: 2px solid #ddd; padding: 10px; text-align: center;">Create</th>
                            <th style="border-bottom: 2px solid #ddd; padding: 10px; text-align: center;">Update</th>
                            <th style="border-bottom: 2px solid #ddd; padding: 10px; text-align: center;">Delete</th>
                            <th style="border-bottom: 2px solid #ddd; padding: 10px; text-align: center;">Other (Approve, Export...)</th>
                        </tr>
                    </thead>
                    <tbody id="matrixBody">
                        </tbody>
                </table>
            </div>
            
            <div id="ajaxMsg" style="margin-top: 10px; display: none; padding: 10px; border-radius: 4px;"></div>

            <div style="text-align: right; margin-top: 25px; padding-top: 15px; border-top: 1px solid #eaeaea;">
                <button type="button" class="btn btn-secondary" onclick="closeModal('permModal')" style="margin-right: 10px;">Đóng</button>
                <button type="submit" class="btn btn-primary" id="savePermBtn"><i data-lucide="save" style="width: 16px; height: 16px; margin-right: 5px;"></i> Lưu Quyền</button>
            </div>
        </form>
    </div>
</div>

<div id="roleModal" class="modal">
    <div class="modal-content small">
        <span class="close" onclick="closeModal('roleModal')">&times;</span>
        <h3 id="roleModalTitle" style="margin-top: 0; margin-bottom: 15px; color: var(--text-dark); font-family: 'Outfit', sans-serif;">Tạo Vai Trò</h3>
        
        <form action="${pageContext.request.contextPath}/admin/roles" method="post">
            <input type="hidden" name="action" id="roleActionInput" value="createRole">
            <input type="hidden" id="roleIdInput" name="roleId" value="">
            
            <div class="form-group">
                <label>Tên Vai Trò (Role Name) *</label>
                <input type="text" id="roleNameInput" name="roleName" required placeholder="VD: Marketing Manager">
            </div>
            
            <div class="form-group">
                <label>Mô Tả (Description)</label>
                <textarea id="roleDescInput" name="description" rows="3" placeholder="Mô tả chức năng của vai trò..."></textarea>
            </div>
            
            <div style="text-align: right; margin-top: 20px;">
                <button type="button" class="btn btn-secondary" onclick="closeModal('roleModal')" style="margin-right: 10px;">Hủy</button>
                <button type="submit" class="btn btn-primary"><i data-lucide="save" style="width: 16px; height: 16px; margin-right: 5px;"></i> Lưu Thông Tin</button>
            </div>
        </form>
    </div>
</div>

<script>
    // Khởi tạo các biểu tượng Lucide ban đầu
    lucide.createIcons();
    
    // SỬA LỖI: Bỏ chữ "ge" thừa ở đây
    const allPermissions = [
        <c:forEach var="p" items="${allPermissions}">
            { id: ${p.permissionId}, module: "${p.moduleName}", action: "${p.action}" },
        </c:forEach>
    ];

    // Group permissions by Module
    const modules = {};
    allPermissions.forEach(p => {
        if(!modules[p.module]) modules[p.module] = [];
        modules[p.module].push(p);
    });

    const rolePermissionsMap = {
        <c:forEach var="role" items="${roles}">
            "${role.roleId}": [
                <c:forEach var="p" items="${role.permissions}">
                    ${p.permissionId},
                </c:forEach>
            ],
        </c:forEach>
    };

    function renderMatrix(roleId) {
        const tbody = document.getElementById('matrixBody');
        tbody.innerHTML = '';
        const rolePerms = rolePermissionsMap[roleId] || [];

        for (const mod in modules) {
            const perms = modules[mod];
            
            let readBox = '', createBox = '', updateBox = '', deleteBox = '', otherBox = '';
            perms.forEach(p => {
                const isChecked = rolePerms.includes(p.id) ? 'checked' : '';
                const cb = `<label class="matrix-label" style="display:block; margin: 3px 0; cursor: pointer; color: #334155;"><input type="checkbox" name="permissions[]" value="\${p.id}" class="chk-mod-\${mod}" \${isChecked}> <span class="perm-text" style="color: #334155 !important;">\${p.action}</span></label>`;
                
                if(p.action.toUpperCase() === 'READ') readBox += cb;
                else if(p.action.toUpperCase() === 'CREATE') createBox += cb;
                else if(p.action.toUpperCase() === 'UPDATE') updateBox += cb;
                else if(p.action.toUpperCase() === 'DELETE') deleteBox += cb;
                else otherBox += cb;
            });

            const row = `
                <tr style="border-bottom: 1px solid #eee;">
                    <td style="padding: 10px;"><strong>\${mod}</strong></td>
                    <td style="padding: 10px; text-align: center;"><input type="checkbox" onchange="toggleModule('\${mod}', this.checked)"></td>
                    <td style="padding: 10px; text-align: left; vertical-align: top;">\${readBox}</td>
                    <td style="padding: 10px; text-align: left; vertical-align: top;">\${createBox}</td>
                    <td style="padding: 10px; text-align: left; vertical-align: top;">\${updateBox}</td>
                    <td style="padding: 10px; text-align: left; vertical-align: top;">\${deleteBox}</td>
                    <td style="padding: 10px; text-align: left; vertical-align: top;">\${otherBox}</td>
                </tr>
            `;
            tbody.innerHTML += row;
        }
    }

    function toggleModule(mod, checked) {
        document.querySelectorAll(`.chk-mod-\${mod}`).forEach(cb => {
            cb.checked = checked;
        });
    }

    function openPermModal(roleId, roleName) {
        document.getElementById('permModalTitle').innerText = 'Cập Nhật Quyền Hạn (Ma Trận): ' + roleName;
        document.getElementById('permRoleIdInput').value = roleId;
        
        document.getElementById('ajaxMsg').style.display = 'none';
        renderMatrix(roleId);
        
        document.getElementById('permModal').style.display = 'block';
    }

    // AJAX Submission
    function submitPermissions(e) {
        e.preventDefault();
        const btn = document.getElementById('savePermBtn');
        const msgDiv = document.getElementById('ajaxMsg');
        
        btn.disabled = true;
        btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Đang lưu...';
        
        const form = document.getElementById('permissionForm');
        const formData = new FormData(form);
        const urlParams = new URLSearchParams(formData).toString();

        fetch('${pageContext.request.contextPath}/admin/permissions/update', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: urlParams
        })
        .then(response => response.json())
        .then(data => {
            msgDiv.style.display = 'block';
            if(data.success) {
                msgDiv.style.background = '#d1e7dd';
                msgDiv.style.color = '#0f5132';
                msgDiv.innerText = data.message;
                setTimeout(() => window.location.reload(), 1000);
            } else {
                msgDiv.style.background = '#f8d7da';
                msgDiv.style.color = '#842029';
                msgDiv.innerText = "Lỗi: " + data.message;
                btn.disabled = false;
                btn.innerHTML = '<i data-lucide="save" style="width: 16px; height: 16px; margin-right: 5px;"></i> Lưu Quyền';
                lucide.createIcons(); // Tối ưu: Gọi lại hàm render để load lại icon Lucide
            }
        })
        .catch(err => {
            msgDiv.style.display = 'block';
            msgDiv.style.background = '#f8d7da';
            msgDiv.style.color = '#842029';
            msgDiv.innerText = "Đã xảy ra lỗi mạng!";
            btn.disabled = false;
            btn.innerHTML = '<i data-lucide="save" style="width: 16px; height: 16px; margin-right: 5px;"></i> Lưu Quyền';
            lucide.createIcons(); // Tối ưu: Gọi lại hàm render để load lại icon Lucide
        });
    }

    function openRoleModal(mode, id = '', name = '', desc = '') {
        if(mode === 'create') {
            document.getElementById('roleModalTitle').innerText = 'Tạo Vai Trò Mới';
            document.getElementById('roleActionInput').value = 'createRole';
            document.getElementById('roleIdInput').value = '';
            document.getElementById('roleNameInput').value = '';
            document.getElementById('roleDescInput').value = '';
        } else {
            document.getElementById('roleModalTitle').innerText = 'Sửa Vai Trò';
            document.getElementById('roleActionInput').value = 'updateRole';
            document.getElementById('roleIdInput').value = id;
            document.getElementById('roleNameInput').value = name;
            document.getElementById('roleDescInput').value = desc;
        }
        document.getElementById('roleModal').style.display = 'block';
    }

    function closeModal(id) {
        document.getElementById(id).style.display = 'none';
    }

    // Table filtering logic
    document.getElementById('searchInput').addEventListener('keyup', function() {
        var searchValue = this.value.toLowerCase();
        var tableBody = document.getElementById('rolesTableBody');
        var rows = tableBody.getElementsByTagName('tr');

        for (var i = 0; i < rows.length; i++) {
            var rowText = rows[i].textContent.toLowerCase();
            if (rowText.includes(searchValue)) {
                rows[i].style.display = '';
            } else {
                rows[i].style.display = 'none';
            }
        }
    });
</script>
</body>
</html>