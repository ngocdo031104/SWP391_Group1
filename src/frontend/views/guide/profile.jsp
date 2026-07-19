<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt"  prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>H&#7891; S&#417; H&#432;&#7899;ng D&#7851;n Vi&#234;n &#8212; TourBuddy</title>
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
    /* Guide Notification Bell */
    .guide-notif-bell {
        position: relative; color: var(--clr-muted); cursor: pointer;
        transition: color 0.2s; display: inline-flex; align-items: center;
        font-size: 1.1rem; text-decoration: none;
    }
    .guide-notif-bell:hover { color: var(--clr-primary); }
    .guide-notif-bell .notif-badge {
        position: absolute; top: -6px; right: -8px;
        background: #ef4444; color: white;
        font-size: 0.6rem; font-weight: 700;
        min-width: 16px; height: 16px; border-radius: 50%;
        display: none; align-items: center; justify-content: center;
        padding: 0 3px; border: 2px solid #fff;
        box-shadow: 0 1px 4px rgba(0,0,0,0.15);
    }
  </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar">
  <a href="${pageContext.request.contextPath}/guide/dashboard" class="logo" id="nav-logo">
    <div class="logo-icon" style="background:var(--clr-guide-accent);">T</div>
    <span>TourBuddy (Guide)</span>
  </a>
  <div class="navbar-nav" style="display:flex;align-items:center;gap:20px;">
    <a href="${pageContext.request.contextPath}/guide/dashboard">L&#7883;ch D&#7851;n &#272;o&#224;n</a>
    <a href="${pageContext.request.contextPath}/guide/profile" class="active">H&#7891; S&#417;</a>
    <a href="${pageContext.request.contextPath}/customer/notifications" class="guide-notif-bell" id="guide-notif-btn" title="Th&#244;ng b&#225;o">
      <i class="fa-regular fa-bell"></i>
      <span class="notif-badge" id="guide-notif-count"></span>
    </a>
    <a href="${pageContext.request.contextPath}/logout" style="color:var(--clr-error)">
      <i class="fa fa-right-from-bracket"></i> &#272;&#259;ng xu&#7845;t
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
            <button class="avatar-edit-btn" onclick="document.getElementById('avatarInput').click()" title="Thay &#273;&#7893;i Avatar">
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
                <span class="badge badge-role"><i class="fa fa-id-badge"></i> H&#432;&#7899;ng D&#7851;n Vi&#234;n</span>
                <span class="badge badge-empcode"><i class="fa fa-hashtag"></i> ${employeeCode}</span>
                <c:choose>
                    <c:when test="${guideProfile.isActive}">
                        <span class="badge badge-status"><i class="fa fa-circle-check"></i> &#272;ang ho&#7841;t &#273;&#7897;ng</span>
                    </c:when>
                    <c:otherwise>
                        <span class="badge badge-status-inactive"><i class="fa fa-ban"></i> Ng&#432;ng ho&#7841;t &#273;&#7897;ng</span>
                    </c:otherwise>
                </c:choose>
            </div>
            <div style="color: #666; font-size: 0.95rem;">
                <span style="margin-right: 15px;"><i class="fa fa-star" style="color:#f1c40f;"></i> <fmt:formatNumber value="${guideProfile.rating}" maxFractionDigits="1"/> / 5.0 &#272;&#225;nh gi&#225;</span>
                <span><i class="fa fa-route" style="color:#7f8c8d;"></i> &#272;&#227; d&#7851;n ${guideProfile.totalToursLed} &#273;o&#224;n</span>
            </div>
        </div>
    </div>

    <!-- 4. Performance Summary Section -->
    <div class="stats-container">
        <div class="stat-card">
            <div class="stat-icon"><i class="fa fa-clipboard-list"></i></div>
            <div class="stat-info">
                <h4>T&#7893;ng Tour Ph&#226;n C&#244;ng</h4>
                <p class="value">${totalAssigned}</p>
            </div>
        </div>
        <div class="stat-card" style="border-left-color: #27ae60;">
            <div class="stat-icon" style="background: rgba(39, 174, 96, 0.1); color: #27ae60;"><i class="fa fa-check-circle"></i></div>
            <div class="stat-info">
                <h4>Tour &#272;&#227; Ho&#224;n Th&#224;nh</h4>
                <p class="value">${totalCompleted}</p>
            </div>
        </div>
        <div class="stat-card" style="border-left-color: #f39c12;">
            <div class="stat-icon" style="background: rgba(243, 156, 18, 0.1); color: #f39c12;"><i class="fa fa-calendar-alt"></i></div>
            <div class="stat-info">
                <h4>Tour S&#7855;p T&#7899;i</h4>
                <p class="value">${totalUpcoming}</p>
            </div>
        </div>
        <div class="stat-card" style="border-left-color: #f1c40f;">
            <div class="stat-icon" style="background: rgba(241, 196, 15, 0.1); color: #f1c40f;"><i class="fa fa-star"></i></div>
            <div class="stat-info">
                <h4>&#272;i&#7875;m &#272;&#225;nh Gi&#225;</h4>
                <p class="value"><fmt:formatNumber value="${guideProfile.rating}" maxFractionDigits="1"/></p>
            </div>
        </div>
    </div>

    <div class="main-content">
        <!-- Sidebar -->
        <div class="nav-sidebar">
            <button class="nav-btn active" onclick="switchTab('personal', this)"><i class="fa fa-user fa-fw"></i> Th&#244;ng tin c&#225; nh&#226;n</button>
            <button class="nav-btn" onclick="switchTab('professional', this)"><i class="fa fa-briefcase fa-fw"></i> H&#7891; s&#417; ngh&#7873; nghi&#7879;p</button>
            <button class="nav-btn" onclick="switchTab('security', this)"><i class="fa fa-shield-halved fa-fw"></i> B&#7843;o m&#7853;t t&#224;i kho&#7843;n</button>
        </div>

        <!-- Panels -->
        <div class="tab-panels">
            
            <!-- 2. Personal Information Section -->
            <div class="tab-pane active" id="tab-personal">
                <h2 class="section-title"><i class="fa fa-address-card"></i> Th&#244;ng Tin C&#225; Nh&#226;n</h2>
                <form action="${pageContext.request.contextPath}/guide/profile/update" method="post">
                    <input type="hidden" name="action" value="updatePersonalInfo">
                    
                    <div class="form-grid-2">
                        <div class="form-group">
                            <label>H&#7885; v&#224; T&#234;n *</label>
                            <input type="text" name="fullName" class="form-control" value="${user.fullName}" required>
                        </div>
                        <div class="form-group">
                            <label>Email (Ch&#7881; &#273;&#7885;c)</label>
                            <input type="email" class="form-control" value="${user.email}" readonly>
                        </div>
                        <div class="form-group">
                            <label>S&#7889; &#273;i&#7879;n tho&#7841;i</label>
                            <input type="tel" name="phone" class="form-control" value="${user.phoneNumber}" pattern="[0-9]{10}" title="Nh&#7853;p s&#7889; &#273;i&#7879;n tho&#7841;i 10 s&#7889;">
                        </div>
                        <div class="form-group">
                            <label>Ng&#224;y sinh</label>
                            <input type="date" name="dob" class="form-control" value="${user.profile.dateOfBirth}">
                        </div>
                        <div class="form-group">
                            <label>Gi&#7899;i t&#237;nh</label>
                            <select name="gender" class="form-control">
                                <option value="">-- Ch&#7885;n --</option>
                                <option value="Male" ${user.profile.gender == 'Male' ? 'selected' : ''}>Nam</option>
                                <option value="Female" ${user.profile.gender == 'Female' ? 'selected' : ''}>N&#7919;</option>
                                <option value="Other" ${user.profile.gender == 'Other' ? 'selected' : ''}>Kh&#225;c</option>
                            </select>
                        </div>
                        <div class="form-group" style="grid-column: 1 / -1;">
                            <label>&#272;&#7883;a ch&#7881;</label>
                            <input type="text" name="address" class="form-control" value="${user.profile.address}">
                        </div>
                    </div>
                    
                    <div style="margin-top: 20px; text-align: right;">
                        <button type="submit" class="btn-submit"><i class="fa fa-save"></i> L&#432;u Thay &#272;&#7893;i</button>
                    </div>
                </form>
            </div>

            <!-- 3. Professional Information Section -->
            <div class="tab-pane" id="tab-professional">
                <h2 class="section-title"><i class="fa fa-id-badge"></i> H&#7891; S&#417; Ngh&#7873; Nghi&#7879;p</h2>
                <form action="${pageContext.request.contextPath}/guide/profile/update" method="post">
                    <input type="hidden" name="action" value="updateProfessionalInfo">
                    
                    <div class="form-grid-2">
                        <div class="form-group">
                            <label>M&#227; Nh&#226;n Vi&#234;n (Ch&#7881; &#273;&#7885;c)</label>
                            <input type="text" class="form-control" value="${employeeCode}" readonly>
                        </div>
                        <div class="form-group">
                            <label>S&#7889; n&#259;m kinh nghi&#7879;m</label>
                            <input type="number" name="yearsOfExperience" class="form-control" min="0" value="${guideProfile.yearsOfExperience}">
                        </div>
                        <div class="form-group" style="grid-column: 1 / -1;">
                            <label>Ngo&#7841;i ng&#7919; (C&#225;ch nhau b&#7857;ng d&#7845;u ph&#7849;y)</label>
                            <input type="text" name="languages" class="form-control" value="${guideProfile.languages}" placeholder="V&#237; d&#7909;: Ti&#7871;ng Anh, Ti&#7871;ng Ph&#225;p">
                        </div>
                        <div class="form-group" style="grid-column: 1 / -1;">
                            <label>Ch&#7913;ng ch&#7881; chuy&#234;n m&#244;n</label>
                            <input type="text" name="certifications" class="form-control" value="${guideProfile.certifications}" placeholder="V&#237; d&#7909;: Th&#7867; HDV Qu&#7889;c t&#7871;...">
                        </div>
                        <div class="form-group" style="grid-column: 1 / -1;">
                            <label>Gi&#7899;i thi&#7879;u b&#7843;n th&#226;n (T&#7889;i &#273;a 1000 k&#253; t&#7921;)</label>
                            <textarea name="biography" class="form-control" maxlength="1000" rows="5" placeholder="Gi&#7899;i thi&#7879;u v&#7873; kinh nghi&#7879;m, phong c&#225;ch d&#7851;n tour...">${guideProfile.bio}</textarea>
                        </div>
                    </div>
                    
                    <div style="margin-top: 20px; text-align: right;">
                        <button type="submit" class="btn-submit"><i class="fa fa-save"></i> C&#7853;p Nh&#7853;t H&#7891; S&#417;</button>
                    </div>
                </form>
            </div>

            <!-- 5. Account Security Section -->
            <div class="tab-pane" id="tab-security">
                <h2 class="section-title"><i class="fa fa-lock"></i> &#272;&#7893;i M&#7853;t Kh&#7849;u</h2>
                <form action="${pageContext.request.contextPath}/guide/profile/update" method="post">
                    <input type="hidden" name="action" value="changePassword">
                    
                    <div class="form-group" style="max-width: 400px; margin-bottom: 15px;">
                        <label>M&#7853;t kh&#7849;u hi&#7879;n t&#7841;i *</label>
                        <input type="password" name="currentPassword" class="form-control" required>
                    </div>
                    <div class="form-group" style="max-width: 400px; margin-bottom: 15px;">
                        <label>M&#7853;t kh&#7849;u m&#7899;i *</label>
                        <input type="password" name="newPassword" class="form-control" required minlength="8" placeholder="T&#7889;i thi&#7875;u 8 k&#253; t&#7921;, c&#243; ch&#7919; v&#224; s&#7889;">
                    </div>
                    <div class="form-group" style="max-width: 400px; margin-bottom: 20px;">
                        <label>X&#225;c nh&#7853;n m&#7853;t kh&#7849;u m&#7899;i *</label>
                        <input type="password" name="confirmNewPassword" class="form-control" required>
                    </div>
                    
                    <button type="submit" class="btn-submit"><i class="fa fa-key"></i> &#272;&#7893;i M&#7853;t Kh&#7849;u</button>
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

<script>
    (function() {
        var badge = document.getElementById('guide-notif-count');
        if (!badge) return;
        var ctx = '${pageContext.request.contextPath}';
        fetch(ctx + '/api/header-counts?t=' + Date.now())
            .then(function(r) { return r.json(); })
            .then(function(data) {
                var count = data.unreadNotifications || 0;
                if (count > 0) {
                    badge.textContent = count > 99 ? '99+' : count;
                    badge.style.display = 'flex';
                }
            })
            .catch(function(e) { console.error('Notification badge error', e); });
    })();
</script>

</body>
</html>
