<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.1">
    <style>
        /* ── ROLE MANAGEMENT — SPACE GLASSMORPHISM THEME ── */
        .permission-badge {
            display: inline-block; background: rgba(99,102,241,0.15); padding: 4px 8px; margin: 3px;
            border-radius: 6px; font-size: 12px; color: #818cf8;
            border: 1px solid rgba(99,102,241,0.25); transition: all 0.2s;
        }
        .permission-badge:hover { background: #5f3bf6 !important; color: #fff !important; border-color: #5f3bf6; }
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(5,5,20,0.75); backdrop-filter: blur(8px); }
        .modal-content {
            background: rgba(15,17,35,0.98) !important; margin: 5% auto; padding: 25px;
            border-radius: 14px; width: 60%; box-shadow: 0 25px 60px rgba(0,0,0,0.6), 0 0 40px rgba(139,92,246,0.15);
            max-height: 85vh; overflow-y: auto;
            border: 1px solid rgba(139,92,246,0.3); color: #f8fafc;
        }
        .modal-content.small { width: 40%; }
        .close { color: #9fa9cb; float: right; font-size: 28px; font-weight: bold; cursor: pointer; transition: color 0.2s; }
        .close:hover { color: #f8fafc; }
        .grid-container { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 12px; margin-top: 15px; }
        .perm-label {
            cursor: pointer; padding: 10px;
            border: 1px solid rgba(139,92,246,0.2); border-radius: 6px;
            display: flex; align-items: center; gap: 8px; transition: all 0.2s;
            color: #9fa9cb;
        }
        .perm-label:hover { background: rgba(139,92,246,0.1); border-color: #8b5cf6; color: #f8fafc; }
        .perm-label input { width: 16px; height: 16px; accent-color: #8b5cf6; }
        .matrix-label { padding: 4px; transition: all 0.2s; border-radius: 4px; }
        .matrix-label:hover { background: rgba(139,92,246,0.08); }
        .matrix-label:hover .perm-text { color: #f8fafc !important; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: 500; color: #9fa9cb; }
        .form-group input, .form-group textarea {
            width: 100%; padding: 10px;
            background: rgba(255,255,255,0.04); border: 1px solid rgba(139,92,246,0.25);
            border-radius: 6px; font-family: 'Inter', sans-serif; color: #f8fafc;
        }
    </style>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-space-overrides.css?v=1.0">
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <c:set var="activePage" value="roles" scope="request" />
    <jsp:include page="sidebar.jsp" />

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
            
            <div id="toast-container" style="position: fixed; top: 20px; right: 20px; z-index: 9999; display: flex; flex-direction: column; gap: 10px;"></div>

            <div class="role-management-container" style="display: flex; gap: 30px; margin-top: 20px; align-items: stretch; height: calc(100vh - 120px);">
                
                <!-- Left Panel -->
                <div class="left-panel" style="width: 280px; background: rgba(22, 25, 50, 0.58); backdrop-filter: blur(14px); -webkit-backdrop-filter: blur(14px); border-radius: 16px; padding: 20px; box-shadow: 0 8px 32px rgba(0,0,0,0.3); display: flex; flex-direction: column; border: 1px solid rgba(139, 92, 246, 0.2);">
                    <h3 style="color: #f8fafc; margin-top: 0; margin-bottom: 20px; font-size: 18px; font-weight: 600;">Danh sách vai trò</h3>
                    
                    <div style="position: relative; margin-bottom: 15px;">
                        <i data-lucide="search" style="position: absolute; left: 12px; top: 10px; width: 16px; color: #9ca3af;"></i>
                        <input type="text" id="roleSearch" placeholder="Tìm kiếm vai trò..." class="form-control" style="width: 100%; padding: 10px 10px 10px 35px;" onkeyup="filterRoles()">
                    </div>

                    <div id="roleList" style="display: flex; flex-direction: column; gap: 8px; flex: 1; overflow-y: auto; margin-bottom: 15px; padding-right: 5px;">
                        <c:forEach var="role" items="${roles}">
                            <div class="role-item" data-role-id="${role.roleId}" data-role-name="${role.roleName}" data-role-desc="${role.description}" onclick="selectRole(${role.roleId}, this)" style="padding: 12px 15px; border-radius: 8px; background: rgba(255,255,255,0.03); color: #9fa9cb; cursor: pointer; border: 1px solid transparent; transition: all 0.2s; position: relative;">
                                <div style="font-weight: 600; font-size: 15px;">${role.roleName}</div>
                                <div style="font-size: 12px; color: #64748b; margin-top: 4px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">${empty role.description ? 'Chưa có mô tả' : role.description}</div>
                                <div style="font-size: 11px; color: #94a3b8; margin-top: 6px;"><i data-lucide="users" style="width: 12px; height: 12px; vertical-align: middle;"></i> ${role.userCount} Users</div>
                            </div>
                        </c:forEach>
                    </div>

                    <!-- role-actions: Tạo / Sửa / Xóa vai trò (UC19) -->
                    <div style="margin-top: 12px; padding-top: 12px; border-top: 1px solid rgba(139,92,246,0.15); display: flex; flex-direction: column; gap: 8px;">
                        <button type="button" onclick="openCreateRoleModal()" class="btn-forecast" style="width: 100%; padding: 10px; border-radius: 8px; font-weight: 600; cursor: pointer;">
                            <i data-lucide="plus-circle" style="width: 16px; vertical-align: text-bottom;"></i> Tạo vai trò
                        </button>
                        <button type="button" id="editRoleBtn" onclick="openEditRoleModal()" class="btn-cancel" style="width: 100%; padding: 10px; border-radius: 8px; font-weight: 600; cursor: pointer; border: 1px solid rgba(139,92,246,0.3);">
                            <i data-lucide="edit-3" style="width: 16px; vertical-align: text-bottom;"></i> Sửa vai trò
                        </button>
                        <button type="button" id="deleteRoleBtn" onclick="openDeleteRoleModal()" class="btn-cancel" style="width: 100%; padding: 10px; border-radius: 8px; font-weight: 600; cursor: pointer; background: transparent; color: #EF4444;">
                            <i data-lucide="trash-2" style="width: 16px; vertical-align: text-bottom;"></i> Xóa vai trò
                        </button>
                    </div>
                </div>

                <!-- Right Panel -->
                <div class="right-panel" style="flex: 1; background: rgba(22, 25, 50, 0.58); backdrop-filter: blur(14px); -webkit-backdrop-filter: blur(14px); border-radius: 16px; padding: 25px; box-shadow: 0 8px 32px rgba(0,0,0,0.3); border: 1px solid rgba(139, 92, 246, 0.2); display: flex; flex-direction: column;">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 25px;">
                        <div>
                            <h3 style="color: #f8fafc; margin-top: 0; margin-bottom: 5px; font-size: 20px; font-weight: 600;">Ma trận phân quyền</h3>
                            <p style="color: #9fa9cb; margin: 0; font-size: 14px;">Thiết lập quyền truy cập cho vai trò được chọn</p>
                        </div>
                        <div id="unsavedBadge" style="display: none; background: #fef3c7; color: #d97706; padding: 6px 12px; border-radius: 20px; font-size: 13px; font-weight: 600; align-items: center; gap: 6px;">
                            <span style="font-size: 10px;">●</span> Chưa lưu
                        </div>
                    </div>
                    
                    <form id="permissionForm" onsubmit="submitPermissions(event)" style="display: flex; flex-direction: column; flex: 1; overflow: hidden;">
                        <input type="hidden" id="permRoleIdInput" name="roleId" value="">
                        
                        <div style="flex: 1; overflow-y: auto; padding-right: 5px;">
                            <table style="width: 100%; border-collapse: collapse;">
                                <thead style="position: sticky; top: 0; background: rgba(15,17,35,0.98); z-index: 10; border-bottom: 2px solid rgba(139,92,246,0.25);">
                                    <tr>
                                        <th style="padding: 15px; text-align: left; font-weight: 600; color: #9fa9cb;">Chức năng</th>
                                        <th style="padding: 15px; text-align: center; font-weight: 600; color: #9fa9cb;">
                                            <div style="display: flex; flex-direction: column; align-items: center; gap: 5px;">
                                                Xem
                                                <input type="checkbox" class="custom-checkbox col-select" data-col="read" onchange="toggleColumn('read', this.checked)">
                                            </div>
                                        </th>
                                        <th style="padding: 15px; text-align: center; font-weight: 600; color: #9fa9cb;">
                                            <div style="display: flex; flex-direction: column; align-items: center; gap: 5px;">
                                                Thêm
                                                <input type="checkbox" class="custom-checkbox col-select" data-col="create" onchange="toggleColumn('create', this.checked)">
                                            </div>
                                        </th>
                                        <th style="padding: 15px; text-align: center; font-weight: 600; color: #9fa9cb;">
                                            <div style="display: flex; flex-direction: column; align-items: center; gap: 5px;">
                                                Sửa
                                                <input type="checkbox" class="custom-checkbox col-select" data-col="update" onchange="toggleColumn('update', this.checked)">
                                            </div>
                                        </th>
                                        <th style="padding: 15px; text-align: center; font-weight: 600; color: #9fa9cb;">
                                            <div style="display: flex; flex-direction: column; align-items: center; gap: 5px;">
                                                Xóa
                                                <input type="checkbox" class="custom-checkbox col-select" data-col="delete" onchange="toggleColumn('delete', this.checked)">
                                            </div>
                                        </th>
                                        <th style="padding: 15px; text-align: center; font-weight: 600; color: #9fa9cb;">
                                            <div style="display: flex; flex-direction: column; align-items: center; gap: 5px;">
                                                Khác
                                                <input type="checkbox" class="custom-checkbox col-select" data-col="other" onchange="toggleColumn('other', this.checked)">
                                            </div>
                                        </th>
                                    </tr>
                                </thead>
                                <tbody id="matrixBody">
                                    <!-- Generated by JS -->
                                </tbody>
                            </table>
                        </div>

                        <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid rgba(139,92,246,0.15); display: flex; justify-content: flex-end; gap: 12px; align-items: center;">
                            <span id="unsavedText" style="color: #F59E0B; font-weight: 500; font-size: 14px; display: none; margin-right: 10px;">
                                <i data-lucide="alert-triangle" style="width: 16px; vertical-align: text-bottom;"></i> Bạn có thay đổi chưa được lưu
                            </span>
                            <button type="button" class="btn" id="cancelPermBtn" onclick="discardChanges()" style="background: transparent; color: #EF4444; border: 1px solid transparent; padding: 10px 20px; border-radius: 8px; font-weight: 600; cursor: pointer; transition: background 0.2s;">
                                Hủy thay đổi
                            </button>
                            <button type="button" class="btn" id="resetPermBtn" onclick="restoreDefaults()" class="btn-cancel" style="border: 1px solid rgba(139,92,246,0.3); padding: 10px 20px; border-radius: 8px; font-weight: 600; cursor: pointer;">
                                Khôi phục mặc định
                            </button>
                            <button type="submit" class="btn btn-primary" id="savePermBtn" class="btn-forecast" style="width: auto; padding: 10px 25px;">
                                Lưu thay đổi
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </section>
    </main>
</div>

<!-- Modals -->
<div id="roleModal" class="modal" style="display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(15, 23, 42, 0.5); backdrop-filter: blur(4px);">
    <div class="modal-content" class="modal-content" style="margin: 10% auto; padding: 30px; width: 400px;">
        <h3 id="roleModalTitle" style="margin-top: 0; margin-bottom: 20px; color: #1e293b; font-size: 20px; font-weight: 600;">Tạo Vai Trò</h3>
        
        <form action="${pageContext.request.contextPath}/admin/roles" method="post">
            <input type="hidden" name="action" id="roleActionInput" value="createRole">
            <input type="hidden" id="roleIdInput" name="roleId" value="">
            
            <div style="margin-bottom: 15px;">
                <label style="display: block; margin-bottom: 8px; font-weight: 500; color: #9fa9cb; font-size: 14px;">Tên Vai Trò *</label>
                <input type="text" id="roleNameInput" name="roleName" required placeholder="VD: Content Manager" class="form-control" style="width: 100%;">
            </div>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 8px; font-weight: 500; color: #9fa9cb; font-size: 14px;">Mô Tả</label>
                <textarea id="roleDescInput" name="description" rows="3" placeholder="Mô tả chức năng của vai trò..." class="form-control" style="width: 100%; resize: vertical;"></textarea>
            </div>
            
            <div style="display: flex; justify-content: flex-end; gap: 10px;">
                <button type="button" onclick="closeModal('roleModal')" class="btn-cancel" style="padding: 10px 20px;">Hủy</button>
                <button type="submit" class="btn-forecast" style="width: auto; padding: 10px 20px;">Lưu</button>
            </div>
        </form>
    </div>
</div>

<div id="deleteModal" class="modal" style="display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(15, 23, 42, 0.5); backdrop-filter: blur(4px);">
    <div class="modal-content" class="modal-content" style="margin: 15% auto; padding: 30px; width: 400px; text-align: center;">
        <div style="width: 50px; height: 50px; border-radius: 50%; background: #fee2e2; color: #ef4444; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px;">
            <i data-lucide="alert-triangle" style="width: 24px; height: 24px;"></i>
        </div>
        <h3 style="margin-top: 0; margin-bottom: 10px; color: #1e293b; font-size: 20px; font-weight: 600;">Xóa vai trò?</h3>
        <p style="color: #64748b; margin-bottom: 25px; font-size: 15px;">Bạn có chắc chắn muốn xóa vai trò này? Hành động này không thể hoàn tác.</p>
        
        <form action="${pageContext.request.contextPath}/admin/roles" method="post" style="display: flex; justify-content: center; gap: 12px;">
            <input type="hidden" name="action" value="deleteRole">
            <input type="hidden" name="roleId" id="deleteRoleIdInput" value="">
            
            <button type="button" onclick="closeModal('deleteModal')" class="btn-cancel" style="flex: 1; padding: 10px;">Hủy</button>
            <button type="submit" class="btn-submit" style="flex: 1; padding: 10px;">Xóa</button>
        </form>
    </div>
</div>

<style>
    /* Custom Scrollbar */
    ::-webkit-scrollbar { width: 6px; height: 6px; }
    ::-webkit-scrollbar-track { background: transparent; }
    ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 4px; }
    ::-webkit-scrollbar-thumb:hover { background: #94a3b8; }

    .role-item.active { background: rgba(95,59,246,0.2) !important; border: 1px solid rgba(139,92,246,0.4) !important; border-left: 4px solid #8b5cf6 !important; color: #f8fafc !important; } /*
        background: #EFF6FF !important;
        border: 1px solid #BFDBFE !important;
        border-left: 4px solid #3B82F6 !important;
        box-shadow: 0 2px 4px rgba(0,0,0,0.02);
    }
    .role-item.active .lucide {
        color: #3B82F6 !important;
    }
    .role-item:hover:not(.active) {
        background: #F1F5F9 !important;
        border-color: #E2E8F0 !important;
    }
    .custom-checkbox {
        width: 18px;
        height: 18px;
        cursor: pointer;
        accent-color: #3B82F6;
        border-radius: 4px;
        transition: all 0.2s;
    }
    .custom-checkbox:hover {
        transform: scale(1.1);
    }
    .btn-ghost:hover {
        background: #f1f5f9 !important;
    }
    td, th { border-bottom: 1px solid #F1F5F9; }
    
    .toast {
        padding: 12px 20px;
        border-radius: 8px;
        color: white;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 10px;
        box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1);
        animation: slideIn 0.3s ease forwards;
        font-size: 14px;
    }
    .toast.success { background: #10B981; }
    .toast.error { background: #EF4444; }
    .toast.warning { background: #F59E0B; }
    
    @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    @keyframes slideOut {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
</style>

<script>
    lucide.createIcons();
    
    // Setup Data
    const allPermissions = [
        <c:forEach var="p" items="${allPermissions}">
            { id: ${p.permissionId}, module: "${p.moduleName}".trim(), action: "${p.action}".trim() },
        </c:forEach>
    ];

    const moduleNames = {
        'Tour Management': 'Quản lý Tour',
        'Booking Management': 'Quản lý Booking',
        'User Management': 'Quản lý Người dùng',
        'Role Management': 'Quản lý Vai trò',
        'Matching Management': 'Quản lý Ghép đôi bạn đồng hành',
        'Request Management': 'Quản lý Yêu cầu kết nối',
        'Review Management': 'Quản lý Đánh giá',
        'Payment Management': 'Quản lý Thanh toán',
        'System Settings': 'Báo cáo hệ thống',
        'Content Management': 'Quản lý Nội dung'
    };

    const displayModules = Object.keys(moduleNames);

    const rolePermissionsMap = {
        <c:forEach var="role" items="${roles}">
            "${role.roleId}": [
                <c:forEach var="p" items="${role.permissions}">
                    ${p.permissionId},
                </c:forEach>
            ],
        </c:forEach>
    };

    let currentRoleId = null;
    let initialPermissions = [];

    // openCreateRoleModal — mở modal tạo vai trò, reset form về chế độ create.
    function openCreateRoleModal() {
        document.getElementById('roleModalTitle').textContent = 'Tạo Vai Trò';
        document.getElementById('roleActionInput').value = 'createRole';
        document.getElementById('roleIdInput').value = '';
        document.getElementById('roleNameInput').value = '';
        document.getElementById('roleDescInput').value = '';
        document.getElementById('roleModal').style.display = 'block';
    }

    // openEditRoleModal — mở modal sửa vai trò dựa trên vai trò đang được chọn trong sidebar.
    function openEditRoleModal() {
        if (!currentRoleId) {
            showToast('warning', 'Vui lòng chọn một vai trò để sửa.');
            return;
        }
        const item = document.querySelector('.role-item.active');
        if (!item) {
            showToast('warning', 'Không tìm thấy thông tin vai trò đang chọn.');
            return;
        }
        document.getElementById('roleModalTitle').textContent = 'Sửa Vai Trò';
        document.getElementById('roleActionInput').value = 'updateRole';
        document.getElementById('roleIdInput').value = item.dataset.roleId || '';
        document.getElementById('roleNameInput').value = item.dataset.roleName || '';
        document.getElementById('roleDescInput').value = item.dataset.roleDesc || '';
        document.getElementById('roleModal').style.display = 'block';
    }

    // openDeleteRoleModal — mở modal xác nhận xóa vai trò đang chọn.
    function openDeleteRoleModal() {
        if (!currentRoleId) {
            showToast('warning', 'Vui lòng chọn một vai trò để xóa.');
            return;
        }
        document.getElementById('deleteRoleIdInput').value = currentRoleId;
        document.getElementById('deleteModal').style.display = 'block';
    }

    function selectRole(roleId, el) {
        if (hasUnsavedChanges()) {
            if (!confirm("Bạn có thay đổi chưa được lưu. Bạn có chắc muốn chuyển đổi vai trò?")) {
                return;
            }
        }
    
        currentRoleId = roleId;
        document.getElementById('permRoleIdInput').value = roleId;
        
        document.querySelectorAll('.role-item').forEach(item => {
            item.classList.remove('active');
        });
        el.classList.add('active');
        
        
        initialPermissions = [...(rolePermissionsMap[roleId] || [])];
        renderMatrix(roleId);
        checkUnsaved();
    }

    function renderMatrix(roleId) {
        const tbody = document.getElementById('matrixBody');
        tbody.innerHTML = '';
        const rolePerms = rolePermissionsMap[roleId] || [];

        displayModules.forEach(mod => {
            const perms = allPermissions.filter(p => p.module === mod);
            if(perms.length === 0) return;

            let readCb = '', createCb = '', updateCb = '', deleteCb = '', otherCb = '';
            
            perms.forEach(p => {
                const isChecked = rolePerms.includes(p.id) ? 'checked' : '';
                const cb = `<input type="checkbox" name="permissions[]" value="\${p.id}" class="custom-checkbox row-mod-\${mod.replace(/\s+/g, '')} col-act-\${p.action.toLowerCase() === 'export' ? 'other' : p.action.toLowerCase()}" \${isChecked} onchange="checkUnsaved()">`;
                
                if(p.action.toUpperCase() === 'READ') readCb = cb;
                else if(p.action.toUpperCase() === 'CREATE') createCb = cb;
                else if(p.action.toUpperCase() === 'UPDATE') updateCb = cb;
                else if(p.action.toUpperCase() === 'DELETE') deleteCb = cb;
                else otherCb += `<div style="display:inline-flex;align-items:center;gap:4px;">\${cb}<span style="font-size:12px;color:#64748b;">\${p.action}</span></div>`;
            });

            const row = `
                <tr>
                    <td style="padding: 15px; font-weight: 500; color: #9fa9cb;">
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <input type="checkbox" class="custom-checkbox" onchange="toggleRow('\${mod.replace(/\s+/g, '')}', this.checked)">
                            \${moduleNames[mod]}
                        </div>
                    </td>
                    <td style="padding: 15px; text-align: center;">\${readCb}</td>
                    <td style="padding: 15px; text-align: center;">\${createCb}</td>
                    <td style="padding: 15px; text-align: center;">\${updateCb}</td>
                    <td style="padding: 15px; text-align: center;">\${deleteCb}</td>
                    <td style="padding: 15px; text-align: center;">\${otherCb}</td>
                </tr>
            `;
            tbody.innerHTML += row;
        });
        
        // Reset column headers
        document.querySelectorAll('.col-select').forEach(cb => cb.checked = false);
    }

    function toggleRow(modClass, isChecked) {
        document.querySelectorAll(`.row-mod-\${modClass}`).forEach(cb => {
            cb.checked = isChecked;
        });
        checkUnsaved();
    }

    function toggleColumn(actClass, isChecked) {
        document.querySelectorAll(`.col-act-\${actClass}`).forEach(cb => {
            cb.checked = isChecked;
        });
        checkUnsaved();
    }

    function hasUnsavedChanges() {
        const form = document.getElementById('permissionForm');
        const formData = new FormData(form);
        const currentPerms = formData.getAll('permissions[]').map(Number);
        
        if (currentPerms.length !== initialPermissions.length) return true;
        
        const sortedCurrent = [...currentPerms].sort();
        const sortedInitial = [...initialPermissions].sort();
        
        for (let i = 0; i < sortedCurrent.length; i++) {
            if (sortedCurrent[i] !== sortedInitial[i]) return true;
        }
        return false;
    }

    function checkUnsaved() {
        const hasChanges = hasUnsavedChanges();
        document.getElementById('unsavedBadge').style.display = hasChanges ? 'flex' : 'none';
        document.getElementById('unsavedText').style.display = hasChanges ? 'inline-block' : 'none';
    }

    function discardChanges() {
        if (!hasUnsavedChanges()) return;
        renderMatrix(currentRoleId);
        checkUnsaved();
    }

    function restoreDefaults() {
        if (confirm("Khôi phục quyền mặc định cho vai trò này? Tất cả dữ liệu chưa lưu sẽ mất.")) {
            document.querySelectorAll('#matrixBody input[type="checkbox"]').forEach(cb => cb.checked = false);
            checkUnsaved();
        }
    }

    // Modal Handlers
    function openRoleModal(mode) {
        const el = document.querySelector('.role-item.active');
        if (mode === 'create') {
            document.getElementById('roleModalTitle').innerText = 'Tạo Vai Trò Mới';
            document.getElementById('roleActionInput').value = 'createRole';
            document.getElementById('roleIdInput').value = '';
            document.getElementById('roleNameInput').value = '';
            document.getElementById('roleDescInput').value = '';
        } else {
            if (!el) return showToast('warning', 'Vui lòng chọn vai trò để sửa');
            document.getElementById('roleModalTitle').innerText = 'Sửa Vai Trò';
            document.getElementById('roleActionInput').value = 'updateRole';
            document.getElementById('roleIdInput').value = el.dataset.roleId;
            document.getElementById('roleNameInput').value = el.dataset.roleName;
            document.getElementById('roleDescInput').value = el.dataset.roleDesc;
        }
        document.getElementById('roleModal').style.display = 'block';
    }

    function confirmDeleteRole() {
        if (!currentRoleId) return showToast('warning', 'Vui lòng chọn vai trò để xóa');
        document.getElementById('deleteRoleIdInput').value = currentRoleId;
        document.getElementById('deleteModal').style.display = 'block';
    }

    function closeModal(id) {
        document.getElementById(id).style.display = 'none';
    }

    function filterRoles() {
        const val = document.getElementById('roleSearch').value.toLowerCase();
        document.querySelectorAll('.role-item').forEach(item => {
            if (item.dataset.roleName.toLowerCase().includes(val)) {
                item.style.display = 'block';
            } else {
                item.style.display = 'none';
            }
        });
    }

    // Toasts
    function showToast(type, msg) {
        const container = document.getElementById('toast-container');
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        
        let icon = 'check-circle';
        if (type === 'error') icon = 'x-circle';
        if (type === 'warning') icon = 'alert-triangle';
        
        toast.innerHTML = `<i data-lucide="${icon}" style="width: 20px;"></i> ${msg}`;
        container.appendChild(toast);
        lucide.createIcons();
        
        setTimeout(() => {
            toast.style.animation = 'slideOut 0.3s ease forwards';
            setTimeout(() => toast.remove(), 300);
        }, 3000);
    }

    // Ajax Submission
    function submitPermissions(e) {
        e.preventDefault();
        if (!currentRoleId) return;
        
        const btn = document.getElementById('savePermBtn');
        btn.disabled = true;
        btn.innerText = 'Đang lưu...';
        
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
            if(data.success) {
                showToast('success', 'Cập nhật phân quyền thành công');
                const newPerms = [];
                formData.getAll('permissions[]').forEach(val => newPerms.push(parseInt(val)));
                rolePermissionsMap[currentRoleId] = newPerms;
                initialPermissions = [...newPerms];
                checkUnsaved();
            } else {
                showToast('error', 'Không thể cập nhật phân quyền: ' + data.message);
            }
        })
        .catch(err => {
            showToast('error', 'Đã xảy ra lỗi mạng!');
        })
        .finally(() => {
            btn.disabled = false;
            btn.innerText = 'Lưu thay đổi';
        });
    }

    window.addEventListener('DOMContentLoaded', () => {
        const firstRole = document.querySelector('.role-item');
        if (firstRole) {
            firstRole.click();
        }
        // Show server message if any
        <c:if test="${not empty sessionScope.errorMsg}">
            showToast('error', '${sessionScope.errorMsg}');
            <c:remove var="errorMsg" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.successMsg}">
            showToast('success', '${sessionScope.successMsg}');
            <c:remove var="successMsg" scope="session"/>
        </c:if>
    });

    // Detect navigation attempts with unsaved changes
    window.addEventListener('beforeunload', (e) => {
        if (hasUnsavedChanges()) {
            e.preventDefault();
            e.returnValue = '';
        }
    });
</script>
</body>
</html>