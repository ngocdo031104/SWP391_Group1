<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt"  prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hồ Sơ Hướng Dẫn Viên — TourBuddy</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/tourbuddy.css?v=1.4">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <style>
    :root {
        --clr-guide-primary: #2c3e50;
        --clr-guide-accent: #3498db;
    }
    
    .guide-profile-wrapper { max-width: 1100px; margin: 100px auto 40px; padding: 0 20px; }
    
    /* Cover and Header */
    .profile-cover {
        height: 200px;
        background: linear-gradient(135deg, var(--clr-guide-primary) 0%, #1a252f 100%);
        border-radius: 12px 12px 0 0;
        position: relative;
    }
    .profile-header-card {
        background: white;
        border-radius: 0 0 12px 12px;
        padding: 0 30px 30px 30px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        display: flex;
        flex-wrap: wrap;
        align-items: flex-end;
        position: relative;
        margin-bottom: 30px;
    }
    .avatar-container {
        margin-top: -60px;
        margin-right: 24px;
        position: relative;
    }
    .avatar-img {
        width: 140px; height: 140px;
        border-radius: 50%;
        border: 4px solid white;
        object-fit: cover;
        box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        background: #f0f0f0;
        display: flex; justify-content: center; align-items: center;
        font-size: 3rem; color: #999;
    }
    .avatar-edit-btn {
        position: absolute;
        bottom: 5px; right: 5px;
        background: var(--clr-guide-accent);
        color: white;
        border: none; border-radius: 50%;
        width: 36px; height: 36px;
        cursor: pointer;
        display: flex; align-items: center; justify-content: center;
        box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        transition: 0.2s;
    }
    .avatar-edit-btn:hover { background: #2980b9; transform: scale(1.05); }
    
    .profile-title-area {
        flex: 1;
        padding-bottom: 10px;
        min-width: 300px;
    }
    .profile-name { font-size: 2rem; font-weight: 700; color: #333; margin: 0 0 5px 0; }
    .profile-badges { display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 10px; }
    
    .badge { padding: 4px 12px; border-radius: 20px; font-size: 0.85rem; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; }
    .badge-role { background: rgba(52, 152, 219, 0.15); color: #2980b9; }
    .badge-empcode { background: rgba(44, 62, 80, 0.1); color: #2c3e50; }
    .badge-status { background: rgba(39, 174, 96, 0.15); color: #27ae60; }
    .badge-status-inactive { background: rgba(231, 76, 60, 0.15); color: #c0392b; }
    
    /* Stats */
    .stats-container {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 20px;
        margin-bottom: 30px;
    }
    .stat-card {
        background: white; border-radius: 12px; padding: 20px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.03);
        display: flex; align-items: center; gap: 16px;
        border-left: 4px solid var(--clr-guide-accent);
    }
    .stat-icon {
        width: 50px; height: 50px; border-radius: 12px;
        background: rgba(52, 152, 219, 0.1);
        color: var(--clr-guide-accent);
        display: flex; align-items: center; justify-content: center;
        font-size: 1.5rem;
    }
    .stat-info h4 { margin: 0; font-size: 0.9rem; color: #7f8c8d; font-weight: 500; }
    .stat-info .value { margin: 0; font-size: 1.6rem; font-weight: 700; color: #2c3e50; }

    /* Tabs Layout */
    .main-content {
        display: flex; gap: 30px;
        flex-direction: column;
    }
    @media(min-width: 768px) {
        .main-content { flex-direction: row; align-items: flex-start; }
    }
    
    .nav-sidebar {
        flex: 0 0 250px;
        background: white; border-radius: 12px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.03);
        overflow: hidden;
    }
    .nav-btn {
        width: 100%; text-align: left; background: none; border: none;
        padding: 16px 20px; font-size: 1rem; color: #555;
        cursor: pointer; transition: 0.2s;
        display: flex; align-items: center; gap: 12px;
        border-left: 3px solid transparent;
    }
    .nav-btn:hover { background: #f8f9fa; }
    .nav-btn.active { background: rgba(52, 152, 219, 0.05); color: var(--clr-guide-accent); border-left-color: var(--clr-guide-accent); font-weight: 600; }
    
    .tab-panels { flex: 1; }
    .tab-pane { display: none; background: white; border-radius: 12px; padding: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.03); animation: fadeIn 0.3s; }
    .tab-pane.active { display: block; }
    
    @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

    .section-title { font-size: 1.3rem; color: var(--clr-guide-primary); margin-top: 0; margin-bottom: 24px; padding-bottom: 12px; border-bottom: 1px solid #eee; display: flex; align-items: center; gap: 10px; }

    /* Forms */
    .form-grid-2 { display: grid; grid-template-columns: 1fr; gap: 20px; }
    @media(min-width: 600px) { .form-grid-2 { grid-template-columns: 1fr 1fr; } }
    
    .form-group label { display: block; margin-bottom: 6px; font-weight: 500; font-size: 0.9rem; color: #555; }
    .form-control { width: 100%; padding: 10px 14px; border: 1px solid #ddd; border-radius: 6px; font-size: 0.95rem; transition: 0.2s; }
    .form-control:focus { border-color: var(--clr-guide-accent); box-shadow: 0 0 0 3px rgba(52,152,219,0.1); outline: none; }
    .form-control[readonly], .form-control[disabled] { background-color: #f8f9fa; cursor: not-allowed; }
    
    textarea.form-control { resize: vertical; min-height: 100px; }

    .btn-submit { background: var(--clr-guide-accent); color: white; border: none; padding: 12px 24px; border-radius: 6px; font-size: 1rem; font-weight: 600; cursor: pointer; transition: 0.2s; display: inline-flex; align-items: center; gap: 8px; }
    .btn-submit:hover { background: #2980b9; }

    .alert { padding: 12px 16px; border-radius: 6px; margin-bottom: 20px; font-size: 0.95rem; display: flex; align-items: center; gap: 10px; }
    .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
    .alert-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
  </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar">
  <a href="${pageContext.request.contextPath}/guide/dashboard" class="logo" id="nav-logo">
    <div class="logo-icon" style="background:var(--clr-guide-accent);">T</div>
    <span>TourBuddy (Guide)</span>
  </a>
  <div class="navbar-nav">
    <a href="${pageContext.request.contextPath}/guide/dashboard">Lịch Dẫn Đoàn</a>
    <a href="${pageContext.request.contextPath}/guide/profile" class="active">Hồ Sơ</a>
    <a href="${pageContext.request.contextPath}/logout" style="color:var(--clr-error)">
      <i class="fa fa-right-from-bracket"></i> Đăng xuất
    </a>
  </div>
</nav>

<div class="guide-profile-wrapper">
    
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success">
            <i class="fa fa-circle-check"></i> ${successMessage}
        </div>
    </c:if>
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-error">
            <i class="fa fa-circle-exclamation"></i> ${errorMessage}
        </div>
    </c:if>

    <!-- 1. Profile Header Section -->
    <div class="profile-cover"></div>
    <div class="profile-header-card">
        <div class="avatar-container">
            <c:choose>
                <c:when test="${not empty user.profile.avatarUrl}">
                    <img class="avatar-img" src="${user.profile.avatarUrl}" alt="Avatar">
                </c:when>
                <c:otherwise>
                    <div class="avatar-img">${user.fullName.substring(0,1).toUpperCase()}</div>
                </c:otherwise>
            </c:choose>
            <button class="avatar-edit-btn" onclick="document.getElementById('avatarInput').click()" title="Thay đổi Avatar">
                <i class="fa fa-camera"></i>
            </button>
            <form action="${pageContext.request.contextPath}/guide/profile/update" method="post" enctype="multipart/form-data" id="avatarForm" style="display:none;">
                <input type="hidden" name="action" value="updateAvatar">
                <input type="file" id="avatarInput" name="avatar" accept="image/*" onchange="document.getElementById('avatarForm').submit();">
            </form>
        </div>
        
        <div class="profile-title-area">
            <h1 class="profile-name">${user.fullName}</h1>
            <div class="profile-badges">
                <span class="badge badge-role"><i class="fa fa-id-badge"></i> Hướng Dẫn Viên</span>
                <span class="badge badge-empcode"><i class="fa fa-hashtag"></i> ${employeeCode}</span>
                <c:choose>
                    <c:when test="${guideProfile.isActive}">
                        <span class="badge badge-status"><i class="fa fa-circle-check"></i> Đang hoạt động</span>
                    </c:when>
                    <c:otherwise>
                        <span class="badge badge-status-inactive"><i class="fa fa-ban"></i> Ngưng hoạt động</span>
                    </c:otherwise>
                </c:choose>
            </div>
            <div style="color: #666; font-size: 0.95rem;">
                <span style="margin-right: 15px;"><i class="fa fa-star" style="color:#f1c40f;"></i> <fmt:formatNumber value="${guideProfile.rating}" maxFractionDigits="1"/> / 5.0 Đánh giá</span>
                <span><i class="fa fa-route" style="color:#7f8c8d;"></i> Đã dẫn ${guideProfile.totalToursLed} đoàn</span>
            </div>
        </div>
    </div>

    <!-- 4. Performance Summary Section -->
    <div class="stats-container">
        <div class="stat-card">
            <div class="stat-icon"><i class="fa fa-clipboard-list"></i></div>
            <div class="stat-info">
                <h4>Tổng Tour Phân Công</h4>
                <p class="value">${totalAssigned}</p>
            </div>
        </div>
        <div class="stat-card" style="border-left-color: #27ae60;">
            <div class="stat-icon" style="background: rgba(39, 174, 96, 0.1); color: #27ae60;"><i class="fa fa-check-circle"></i></div>
            <div class="stat-info">
                <h4>Tour Đã Hoàn Thành</h4>
                <p class="value">${totalCompleted}</p>
            </div>
        </div>
        <div class="stat-card" style="border-left-color: #f39c12;">
            <div class="stat-icon" style="background: rgba(243, 156, 18, 0.1); color: #f39c12;"><i class="fa fa-calendar-alt"></i></div>
            <div class="stat-info">
                <h4>Tour Sắp Tới</h4>
                <p class="value">${totalUpcoming}</p>
            </div>
        </div>
        <div class="stat-card" style="border-left-color: #f1c40f;">
            <div class="stat-icon" style="background: rgba(241, 196, 15, 0.1); color: #f1c40f;"><i class="fa fa-star"></i></div>
            <div class="stat-info">
                <h4>Điểm Đánh Giá</h4>
                <p class="value"><fmt:formatNumber value="${guideProfile.rating}" maxFractionDigits="1"/></p>
            </div>
        </div>
    </div>

    <div class="main-content">
        <!-- Sidebar -->
        <div class="nav-sidebar">
            <button class="nav-btn active" onclick="switchTab('personal', this)"><i class="fa fa-user fa-fw"></i> Thông tin cá nhân</button>
            <button class="nav-btn" onclick="switchTab('professional', this)"><i class="fa fa-briefcase fa-fw"></i> Hồ sơ nghề nghiệp</button>
            <button class="nav-btn" onclick="switchTab('security', this)"><i class="fa fa-shield-halved fa-fw"></i> Bảo mật tài khoản</button>
        </div>

        <!-- Panels -->
        <div class="tab-panels">
            
            <!-- 2. Personal Information Section -->
            <div class="tab-pane active" id="tab-personal">
                <h2 class="section-title"><i class="fa fa-address-card"></i> Thông Tin Cá Nhân</h2>
                <form action="${pageContext.request.contextPath}/guide/profile/update" method="post">
                    <input type="hidden" name="action" value="updatePersonalInfo">
                    
                    <div class="form-grid-2">
                        <div class="form-group">
                            <label>Họ và Tên *</label>
                            <input type="text" name="fullName" class="form-control" value="${user.fullName}" required>
                        </div>
                        <div class="form-group">
                            <label>Email (Chỉ đọc)</label>
                            <input type="email" class="form-control" value="${user.email}" readonly>
                        </div>
                        <div class="form-group">
                            <label>Số điện thoại</label>
                            <input type="tel" name="phone" class="form-control" value="${user.phoneNumber}" pattern="[0-9]{10}" title="Nhập số điện thoại 10 số">
                        </div>
                        <div class="form-group">
                            <label>Ngày sinh</label>
                            <input type="date" name="dob" class="form-control" value="${user.profile.dateOfBirth}">
                        </div>
                        <div class="form-group">
                            <label>Giới tính</label>
                            <select name="gender" class="form-control">
                                <option value="">-- Chọn --</option>
                                <option value="Male" ${user.profile.gender == 'Male' ? 'selected' : ''}>Nam</option>
                                <option value="Female" ${user.profile.gender == 'Female' ? 'selected' : ''}>Nữ</option>
                                <option value="Other" ${user.profile.gender == 'Other' ? 'selected' : ''}>Khác</option>
                            </select>
                        </div>
                        <div class="form-group" style="grid-column: 1 / -1;">
                            <label>Địa chỉ</label>
                            <input type="text" name="address" class="form-control" value="${user.profile.address}">
                        </div>
                    </div>
                    
                    <div style="margin-top: 20px; text-align: right;">
                        <button type="submit" class="btn-submit"><i class="fa fa-save"></i> Lưu Thay Đổi</button>
                    </div>
                </form>
            </div>

            <!-- 3. Professional Information Section -->
            <div class="tab-pane" id="tab-professional">
                <h2 class="section-title"><i class="fa fa-id-badge"></i> Hồ Sơ Nghề Nghiệp</h2>
                <form action="${pageContext.request.contextPath}/guide/profile/update" method="post">
                    <input type="hidden" name="action" value="updateProfessionalInfo">
                    
                    <div class="form-grid-2">
                        <div class="form-group">
                            <label>Mã Nhân Viên (Chỉ đọc)</label>
                            <input type="text" class="form-control" value="${employeeCode}" readonly>
                        </div>
                        <div class="form-group">
                            <label>Số năm kinh nghiệm</label>
                            <input type="number" name="yearsOfExperience" class="form-control" min="0" value="${guideProfile.yearsOfExperience}">
                        </div>
                        <div class="form-group" style="grid-column: 1 / -1;">
                            <label>Ngoại ngữ (Cách nhau bằng dấu phẩy)</label>
                            <input type="text" name="languages" class="form-control" value="${guideProfile.languages}" placeholder="Ví dụ: Tiếng Anh, Tiếng Pháp">
                        </div>
                        <div class="form-group" style="grid-column: 1 / -1;">
                            <label>Chứng chỉ chuyên môn</label>
                            <input type="text" name="certifications" class="form-control" value="${guideProfile.certifications}" placeholder="Ví dụ: Thẻ HDV Quốc tế...">
                        </div>
                        <div class="form-group" style="grid-column: 1 / -1;">
                            <label>Giới thiệu bản thân (Tối đa 1000 ký tự)</label>
                            <textarea name="biography" class="form-control" maxlength="1000" rows="5" placeholder="Giới thiệu về kinh nghiệm, phong cách dẫn tour...">${guideProfile.bio}</textarea>
                        </div>
                    </div>
                    
                    <div style="margin-top: 20px; text-align: right;">
                        <button type="submit" class="btn-submit"><i class="fa fa-save"></i> Cập Nhật Hồ Sơ</button>
                    </div>
                </form>
            </div>

            <!-- 5. Account Security Section -->
            <div class="tab-pane" id="tab-security">
                <h2 class="section-title"><i class="fa fa-lock"></i> Đổi Mật Khẩu</h2>
                <form action="${pageContext.request.contextPath}/guide/profile/update" method="post">
                    <input type="hidden" name="action" value="changePassword">
                    
                    <div class="form-group" style="max-width: 400px; margin-bottom: 15px;">
                        <label>Mật khẩu hiện tại *</label>
                        <input type="password" name="currentPassword" class="form-control" required>
                    </div>
                    <div class="form-group" style="max-width: 400px; margin-bottom: 15px;">
                        <label>Mật khẩu mới *</label>
                        <input type="password" name="newPassword" class="form-control" required minlength="8" placeholder="Tối thiểu 8 ký tự, có chữ và số">
                    </div>
                    <div class="form-group" style="max-width: 400px; margin-bottom: 20px;">
                        <label>Xác nhận mật khẩu mới *</label>
                        <input type="password" name="confirmNewPassword" class="form-control" required>
                    </div>
                    
                    <button type="submit" class="btn-submit"><i class="fa fa-key"></i> Đổi Mật Khẩu</button>
                </form>
            </div>

        </div>
    </div>
</div>

<script>
    function switchTab(tabId, btnElement) {
        // Remove active class from all buttons and panes
        document.querySelectorAll('.nav-btn').forEach(btn => btn.classList.remove('active'));
        document.querySelectorAll('.tab-pane').forEach(pane => pane.classList.remove('active'));
        
        // Add active class to selected
        btnElement.classList.add('active');
        document.getElementById('tab-' + tabId).classList.add('active');
    }
</script>

</body>
</html>
