<%-- 
    Document   : profile.jsp
    Purpose    : Hiển thị và quản lý thông tin hồ sơ người dùng, lịch sử hoạt động, bảo mật và cài đặt thông báo.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt"  prefix="fmt" %>
<%
    request.setAttribute("extraCss", "assets/css/tourbuddy.css");
    request.setAttribute("bodyClass", "profile-page");
%>
<jsp:include page="/common/header.jsp" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <style>
    /* Override navbar from transparent/white to dark text for profile page */
    .header { background-color: rgba(255,255,255,0.95) !important; box-shadow: 0 1px 4px rgba(0,0,0,.06) !important; }
    .header .logo { color: var(--clr-primary) !important; }
    .header .nav-link { color: var(--clr-muted) !important; }
    .header .nav-link:hover { color: var(--clr-accent) !important; }
    .header .notification-bell { color: var(--clr-text) !important; }
    .header .user-avatar { border-color: var(--clr-primary) !important; }
    .header .nav-search { opacity: 1 !important; visibility: visible !important; transform: translateY(0) !important; }
    .header .mobile-nav-toggle { color: var(--clr-text) !important; }

    .activity-item {
      display: flex; gap: 14px; align-items: flex-start;
      padding: 14px 0; border-bottom: 1px solid var(--clr-border);
    }
    .activity-item:last-child { border-bottom: none; }
    .activity-icon {
      width: 38px; height: 38px; border-radius: 50%; flex-shrink: 0;
      display: flex; align-items: center; justify-content: center;
      font-size: .9rem;
    }
    .activity-icon.booking  { background: var(--clr-primary-l); color: var(--clr-primary); }
    .activity-icon.payment  { background: rgba(34, 197, 94, 0.12);  color: var(--clr-success); }
    .activity-icon.review   { background: var(--clr-accent-l);  color: var(--clr-accent); }
    .activity-icon.login    { background: rgba(100, 116, 139, 0.12);color: var(--clr-muted); }
    .activity-info { flex: 1; }
    .activity-info p { font-size: .875rem; color: var(--clr-text); margin-bottom: 2px; }
    .activity-info time { font-size: .78rem; color: var(--clr-muted); }

    .change-pwd-toggle { cursor: pointer; color: var(--clr-accent); font-size: .85rem; }
    .pwd-section { display: none; padding-top: 16px; }
    .pwd-section.open { display: block; }

    .upload-zone {
      border: 2px dashed var(--clr-border); border-radius: var(--radius-md);
      padding: 32px; text-align: center; cursor: pointer;
      transition: all var(--transition);
    }
    .upload-zone:hover { border-color: var(--clr-primary); background: var(--clr-primary-l); }
    .upload-zone i { font-size: 2rem; color: var(--clr-muted); margin-bottom: 10px; }
    .upload-zone p { font-size: .875rem; color: var(--clr-muted); }

    .save-bar {
      position: sticky; bottom: 0;
      background: rgba(255,255,255,.95); backdrop-filter: blur(8px);
      border-top: 1px solid var(--clr-border);
      padding: 14px 24px;
      display: flex; justify-content: flex-end; gap: 12px;
      margin: 0 -24px -24px;
      border-radius: 0 0 var(--radius-md) var(--radius-md);
    }

    .notification-row {
      display: flex; align-items: center; justify-content: space-between;
      padding: 14px 0; border-bottom: 1px solid var(--clr-border);
    }
    .notification-row:last-child { border-bottom: none; }
    .toggle-switch {
      position: relative; width: 44px; height: 24px;
    }
    .toggle-switch input { display: none; }
    .toggle-switch .slider {
      position: absolute; inset: 0;
      background: var(--clr-border); border-radius: 99px;
      cursor: pointer; transition: .3s;
    }
    .toggle-switch .slider::before {
      content: ''; position: absolute;
      width: 18px; height: 18px; border-radius: 50%;
      background: #fff; top: 3px; left: 3px;
      transition: .3s; box-shadow: 0 1px 3px rgba(0,0,0,.2);
    }
    .toggle-switch input:checked + .slider { background: var(--clr-primary); }
    .toggle-switch input:checked + .slider::before { transform: translateX(20px); }

    .tag-group { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 8px; }
    .tag { 
      padding: 6px 14px; border: 1px solid var(--clr-border); 
      border-radius: 99px; cursor: pointer; transition: 0.2s;
      font-size: 0.85rem; color: var(--clr-text); user-select: none;
      display: inline-flex; align-items: center;
    }
    .tag i { display: none; margin-right: 6px; font-size: 0.8rem; }
    .tag:hover { border-color: var(--clr-primary); background: #f8fafc; }
    .tag.selected { 
      background: var(--clr-primary-l); border-color: var(--clr-primary);
      color: var(--clr-primary); font-weight: 600;
      box-shadow: 0 2px 8px rgba(91, 33, 182, 0.15);
    }
    .tag.selected i { display: inline-block; }
  </style>

<div class="profile-wrapper">

  <!-- Cover Photo -->
  <div class="profile-cover"></div>

  <div class="profile-body">

    <!-- Profile Header -->
    <div class="profile-header fade-up">
      <div class="avatar-wrap">
        <c:choose>
          <c:when test="${not empty sessionUser.profile.avatarUrl}">
            <img class="avatar"
                 src="${sessionUser.profile.avatarUrl}"
                 alt="${sessionUser.fullName}">
          </c:when>
          <c:otherwise>
            <div class="avatar-fallback">
              ${sessionUser.fullName.substring(0,1).toUpperCase()}
            </div>
          </c:otherwise>
        </c:choose>
        <button class="avatar-edit-btn" onclick="document.getElementById('avatarInput').click()"
                title="Thay ảnh đại diện">
          <i class="fa fa-camera"></i>
        </button>
      </div>

      <div class="profile-info">
        <h2>${not empty sessionUser.fullName ? sessionUser.fullName : 'Người dùng TourBuddy'}</h2>
        <span class="role-badge">${sessionUser.role.roleName}</span>
        <div class="meta">
          <i class="fa fa-envelope" style="margin-right:6px;opacity:.6"></i>${sessionUser.email}
          <c:if test="${not empty sessionUser.phoneNumber}">
            &nbsp;&nbsp;<i class="fa fa-phone" style="margin-right:6px;opacity:.6"></i>${sessionUser.phoneNumber}
          </c:if>
          &nbsp;&nbsp;<i class="fa fa-calendar-check" style="margin-right:6px;opacity:.6"></i>
          Tham gia <fmt:formatDate value="${sessionUser.createdAt}" pattern="MM/yyyy"/>
        </div>
      </div>

      <div class="profile-actions">
        <button class="btn btn-outline btn-sm" onclick="shareProfile()">
          <i class="fa fa-share-nodes"></i> Chia sẻ
        </button>
        <a href="${pageContext.request.contextPath}/customer/booking/history" class="btn btn-primary btn-sm">
          <i class="fa fa-suitcase"></i> Lịch sử Tour
        </a>
      </div>
    </div>

    <!-- Stats -->
    <div class="stats-row fade-up" style="animation-delay:.1s;margin-top:24px">
      <div class="stat-card">
        <div class="stat-value">${not empty totalBookings ? totalBookings : 0}</div>
        <div class="stat-label">Tour đã đặt</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">${not empty totalReviews ? totalReviews : 0}</div>
        <div class="stat-label">Đánh giá</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">${not empty totalFavorites ? totalFavorites : 0}</div>
        <div class="stat-label">Tour yêu thích</div>
      </div>
    </div>

    <!-- Profile Completion -->
    <div class="profile-completion card fade-up" style="padding:16px 20px;margin-bottom:0">
      <p>Độ hoàn thiện hồ sơ: <strong id="pct">0%</strong></p>
      <div class="progress-bar-wrap">
        <div class="progress-bar" id="progressBar" style="width:0%"></div>
      </div>
    </div>

    <!-- Server messages -->
    <c:if test="${not empty successMessage}">
      <div class="alert alert-success fade-up" style="margin-top:16px">
        <i class="fa fa-circle-check"></i> ${successMessage}
      </div>
    </c:if>
    <c:if test="${not empty errorMessage}">
      <div class="alert alert-error fade-up" style="margin-top:16px">
        <i class="fa fa-circle-exclamation"></i> ${errorMessage}
      </div>
    </c:if>

    <!-- Tabs -->
    <div class="profile-tabs fade-up" style="animation-delay:.15s">
      <button class="tab-btn active" onclick="switchTab('info',this)">
        <i class="fa fa-user"></i> Thông tin cá nhân
      </button>
      <button class="tab-btn" onclick="switchTab('security',this)">
        <i class="fa fa-shield-halved"></i> Bảo mật
      </button>
      <button class="tab-btn" onclick="switchTab('preferences',this)">
        <i class="fa fa-sliders"></i> Sở thích du lịch
      </button>
      <button class="tab-btn" onclick="switchTab('notifications',this)">
        <i class="fa fa-bell"></i> Thông báo
      </button>
      <button class="tab-btn" onclick="switchTab('activity',this)">
        <i class="fa fa-clock-rotate-left"></i> Hoạt động
      </button>
    </div>

    <!-- ── TAB 1: Personal Info ── -->
    <div class="tab-content active fade-up" id="tab-info">
      <form action="${pageContext.request.contextPath}/profile/update"
            method="post" enctype="multipart/form-data" id="profileForm">
        <input type="hidden" name="action" value="updateInfo">
        <input type="file" id="avatarInput" name="avatar" hidden accept="image/*"
               onchange="previewAvatar(this)">

        <div class="card">
          <div class="card-header">
            <h3><i class="fa fa-id-card" style="margin-right:8px;color:var(--clr-primary)"></i>
              Thông tin cơ bản</h3>
          </div>
          <div class="card-body">
            <div class="form-grid">

              <div class="form-group">
                <label class="form-label" for="fullName">Họ và tên *</label>
                <div class="input-icon-wrap">
                  <i class="fa fa-user icon"></i>
                  <input type="text" id="fullName" name="fullName"
                         class="form-control ${not empty nameError ? 'is-invalid' : ''}"
                         value="${not empty sessionUser.fullName ? sessionUser.fullName : ''}"
                         required maxlength="100" oninput="calcCompletion()">
                </div>
              </div>

              <div class="form-group">
                <label class="form-label" for="email">Email</label>
                <div class="input-icon-wrap">
                  <i class="fa fa-envelope icon"></i>
                  <input type="email" id="email" class="form-control"
                         value="${sessionUser.email}" disabled
                         style="background:#f3f3f3;cursor:not-allowed">
                </div>
                <span class="form-hint">Email không thể thay đổi</span>
              </div>

              <div class="form-group">
                <label class="form-label" for="phone">Số điện thoại</label>
                <div class="input-icon-wrap">
                  <i class="fa fa-phone icon"></i>
                  <input type="tel" id="phone" name="phone"
                         class="form-control"
                         value="${not empty sessionUser.phoneNumber ? sessionUser.phoneNumber : ''}"
                         pattern="0[0-9]{9}" maxlength="10" title="Số điện thoại gồm 10 chữ số và bắt đầu bằng 0" oninput="calcCompletion()">
                </div>
              </div>

              <div class="form-group">
                <label class="form-label" for="dob">Ngày sinh</label>
                <div class="input-icon-wrap">
                  <i class="fa fa-calendar icon"></i>
                  <input type="date" id="dob" name="dob"
                         class="form-control"
                         value="${not empty sessionUser.profile.dateOfBirth ? sessionUser.profile.dateOfBirth : ''}"
                         oninput="calcCompletion()">
                </div>
              </div>

              <div class="form-group">
                <label class="form-label" for="gender">Giới tính</label>
                <select id="gender" name="gender" class="form-control" oninput="calcCompletion()">
                  <option value="">-- Chọn --</option>
                  <option value="Male"   ${sessionUser.profile.gender eq 'Male'   ? 'selected':''}>Nam</option>
                  <option value="Female" ${sessionUser.profile.gender eq 'Female' ? 'selected':''}>Nữ</option>
                  <option value="Other"  ${sessionUser.profile.gender eq 'Other'  ? 'selected':''}>Khác</option>
                </select>
              </div>

              <div class="form-group full">
                <label class="form-label" for="address">Địa chỉ</label>
                <div class="input-icon-wrap">
                  <i class="fa fa-location-dot icon"></i>
                  <input type="text" id="address" name="address"
                         class="form-control"
                         value="${not empty sessionUser.profile.address ? sessionUser.profile.address : ''}"
                         placeholder="Số nhà, đường, quận, tỉnh/thành phố"
                         maxlength="255" oninput="calcCompletion()">
                </div>
              </div>

              <div class="form-group full">
                <label class="form-label" for="bio">Tiểu sử</label>
                <textarea id="bio" name="biography"
                          class="form-control" rows="4"
                          placeholder="Giới thiệu bản thân, phong cách du lịch yêu thích..."
                          maxlength="1000" oninput="calcCompletion()"
                          style="resize:vertical">${not empty sessionUser.profile.biography ? sessionUser.profile.biography : ''}</textarea>
                <span class="form-hint" id="bioCount">0 / 1000 ký tự</span>
              </div>

            </div>

            <div class="save-bar">
              <button type="button" class="btn btn-ghost" onclick="resetForm()">
                Hủy thay đổi
              </button>
              <button type="submit" class="btn btn-primary" id="saveInfoBtn">
                <i class="fa fa-floppy-disk"></i> Lưu thông tin
              </button>
            </div>
          </div>
        </div>
      </form>
    </div>

    <!-- ── TAB 2: Security ── -->
    <div class="tab-content" id="tab-security">
      <div class="card">
        <div class="card-header">
          <h3><i class="fa fa-lock" style="margin-right:8px;color:var(--clr-primary)"></i>
            Đổi mật khẩu</h3>
        </div>
        <div class="card-body">
          <form action="${pageContext.request.contextPath}/profile/update"
                method="post" id="pwdForm">
            <input type="hidden" name="action" value="changePassword">

            <div class="form-group" style="max-width:440px">
              <label class="form-label" for="currentPwd">Mật khẩu hiện tại *</label>
              <div class="input-icon-wrap">
                <i class="fa fa-lock icon"></i>
                <input type="password" id="currentPwd" name="currentPassword"
                       class="form-control" required placeholder="••••••••">
                <button type="button" class="toggle-pwd"
                        onclick="togglePwd('currentPwd','tci')"><i id="tci" class="fa fa-eye"></i></button>
              </div>
            </div>

            <div class="form-group" style="max-width:440px">
              <label class="form-label" for="newPwd">Mật khẩu mới *</label>
              <div class="input-icon-wrap">
                <i class="fa fa-key icon"></i>
                <input type="password" id="newPwd" name="newPassword"
                       class="form-control" required minlength="8"
                       placeholder="Tối thiểu 8 ký tự"
                       oninput="checkStrengthProfile(this.value)">
                <button type="button" class="toggle-pwd"
                        onclick="togglePwd('newPwd','tni')"><i id="tni" class="fa fa-eye"></i></button>
              </div>
              <div class="strength-bar" style="display:flex;gap:4px;margin-top:8px">
                <div style="flex:1;height:4px;border-radius:99px;background:var(--clr-border)" id="ps1"></div>
                <div style="flex:1;height:4px;border-radius:99px;background:var(--clr-border)" id="ps2"></div>
                <div style="flex:1;height:4px;border-radius:99px;background:var(--clr-border)" id="ps3"></div>
                <div style="flex:1;height:4px;border-radius:99px;background:var(--clr-border)" id="ps4"></div>
              </div>
            </div>

            <div class="form-group" style="max-width:440px">
              <label class="form-label" for="confirmPwd">Xác nhận mật khẩu mới *</label>
              <div class="input-icon-wrap">
                <i class="fa fa-key icon"></i>
                <input type="password" id="confirmPwd" name="confirmNewPassword"
                       class="form-control" required placeholder="••••••••">
                <button type="button" class="toggle-pwd"
                        onclick="togglePwd('confirmPwd','tci2')"><i id="tci2" class="fa fa-eye"></i></button>
              </div>
              <span class="form-error" id="pwdMatchErr" style="display:none">Mật khẩu không khớp</span>
            </div>

            <button type="submit" class="btn btn-primary" id="savePwdBtn">
              <i class="fa fa-shield-halved"></i> Cập nhật mật khẩu
            </button>
          </form>

          <hr style="border:none;border-top:1px solid var(--clr-border);margin:28px 0">

          <div>
            <h4 style="font-size:.95rem;font-weight:600;margin-bottom:4px">Phiên đăng nhập</h4>
            <p style="font-size:.85rem;color:var(--clr-muted);margin-bottom:16px">
              Đăng xuất khỏi tất cả thiết bị khác để bảo vệ tài khoản.
            </p>
            <a href="${pageContext.request.contextPath}/logout?all=true"
               class="btn btn-outline btn-sm" style="color:var(--clr-error);border-color:var(--clr-error)">
              <i class="fa fa-right-from-bracket"></i> Đăng xuất mọi nơi
            </a>
          </div>
        </div>
      </div>
    </div>

    <!-- ── TAB 3: Preferences ── -->
    <div class="tab-content" id="tab-preferences">
        <form action="${pageContext.request.contextPath}/profile/update" method="post" id="prefForm" onsubmit="syncTagsBeforeSubmit()">
          <input type="hidden" name="action" value="updatePreferences">
          <div class="card">
            <div class="card-header">
              <h3><i class="fa fa-heart" style="margin-right:8px;color:var(--clr-accent)"></i>
                Sở thích & Tìm bạn đồng hành</h3>
            </div>
            <div class="card-body">
              <div class="form-grid">
                
                <div class="form-group full">
                  <label class="form-label">Điểm đến yêu thích (Tags)</label>
                  <input type="text" name="destination" class="form-control" value="${myPref.destination}" placeholder="VD: Vietnam, Thailand, Japan...">
                </div>

                <div class="form-group">
                  <label class="form-label">Phong cách du lịch</label>
                  <select name="travelStyle" class="form-control">
                    <option value="Explorer" ${myPref.travelStyle == 'Explorer' ? 'selected' : ''}>Khám phá (Explorer)</option>
                    <option value="Relaxed" ${myPref.travelStyle == 'Relaxed' ? 'selected' : ''}>Nghỉ dưỡng (Relaxed)</option>
                    <option value="Balanced" ${myPref.travelStyle == 'Balanced' ? 'selected' : ''}>Cân bằng (Balanced)</option>
                    <option value="Luxury" ${myPref.travelStyle == 'Luxury' ? 'selected' : ''}>Sang trọng (Luxury)</option>
                    <option value="Backpacking" ${myPref.travelStyle == 'Backpacking' ? 'selected' : ''}>Phượt (Backpacking)</option>
                  </select>
                </div>
                
                <div class="form-group">
                  <label class="form-label">Tần suất du lịch</label>
                  <select name="travelFrequency" class="form-control">
                    <option value="Rarely" ${myPref.travelFrequency == 'Rarely' ? 'selected' : ''}>Hiếm khi (1-2 lần/năm)</option>
                    <option value="Occasionally" ${myPref.travelFrequency == 'Occasionally' ? 'selected' : ''}>Thỉnh thoảng (3-5 lần/năm)</option>
                    <option value="Frequently" ${myPref.travelFrequency == 'Frequently' ? 'selected' : ''}>Thường xuyên (Mỗi tháng)</option>
                  </select>
                </div>

                <div class="form-group">
                  <label class="form-label">Thời gian chuyến đi ưu tiên</label>
                  <select name="tripDuration" class="form-control">
                    <option value="1-3 days" ${myPref.tripDuration == '1-3 days' ? 'selected' : ''}>1-3 ngày (Ngắn ngày)</option>
                    <option value="1 week" ${myPref.tripDuration == '1 week' ? 'selected' : ''}>1 tuần</option>
                    <option value="2+ weeks" ${myPref.tripDuration == '2+ weeks' ? 'selected' : ''}>Hơn 2 tuần</option>
                  </select>
                </div>

                <div class="form-group">
                  <label class="form-label">Ngôn ngữ</label>
                  <select name="languages" class="form-control">
                    <option value="Tiếng Việt" ${myPref.languages == 'Tiếng Việt' ? 'selected' : ''}>Tiếng Việt</option>
                    <option value="English" ${myPref.languages == 'English' ? 'selected' : ''}>Tiếng Anh</option>
                    <option value="Bilingual" ${myPref.languages == 'Bilingual' ? 'selected' : ''}>Song ngữ (Anh-Việt)</option>
                  </select>
                </div>

                <div class="form-group">
                  <label class="form-label">Thói quen hút thuốc</label>
                  <select name="smokingPreference" class="form-control">
                    <option value="Non-smoker" ${myPref.smokingPreference == 'Non-smoker' ? 'selected' : ''}>Không hút thuốc</option>
                    <option value="Smoker" ${myPref.smokingPreference == 'Smoker' ? 'selected' : ''}>Có hút thuốc</option>
                    <option value="Don't care" ${myPref.smokingPreference == "Don't care" ? 'selected' : ''}>Không quan tâm</option>
                  </select>
                </div>

                <div class="form-group">
                  <label class="form-label">Thói quen uống rượu bia</label>
                  <select name="drinkingPreference" class="form-control">
                    <option value="Non-drinker" ${myPref.drinkingPreference == 'Non-drinker' ? 'selected' : ''}>Không uống</option>
                    <option value="Social drinker" ${myPref.drinkingPreference == 'Social drinker' ? 'selected' : ''}>Uống xã giao</option>
                    <option value="Don't care" ${myPref.drinkingPreference == "Don't care" ? 'selected' : ''}>Không quan tâm</option>
                  </select>
                </div>

                <div class="form-group">
                  <label class="form-label">Độ tuổi bạn đồng hành ưu tiên</label>
                  <select name="targetAgeMax" class="form-control">
                    <option value="0" ${myPref.targetAgeMax == 0 ? 'selected' : ''}>Bất kỳ độ tuổi nào</option>
                    <option value="25" ${myPref.targetAgeMax == 25 ? 'selected' : ''}>18 - 25 tuổi</option>
                    <option value="35" ${myPref.targetAgeMax == 35 ? 'selected' : ''}>26 - 35 tuổi</option>
                    <option value="50" ${myPref.targetAgeMax == 50 ? 'selected' : ''}>36 - 50 tuổi</option>
                  </select>
                </div>

                <div class="form-group">
                  <label class="form-label">Giới tính bạn đồng hành</label>
                  <select name="gender" class="form-control">
                    <option value="All" ${myPref.targetGender == 'All' ? 'selected' : ''}>Tất cả</option>
                    <option value="Male" ${myPref.targetGender == 'Male' ? 'selected' : ''}>Nam</option>
                    <option value="Female" ${myPref.targetGender == 'Female' ? 'selected' : ''}>Nữ</option>
                  </select>
                </div>

                <div class="form-group full">
                  <label class="form-label">Sở thích du lịch (Chọn nhiều)</label>
                  <input type="hidden" name="tags" id="travelTagsInput" value="${myPref.tags}">
                  <div class="tag-group">
                    <c:set var="travelTagsMap" value="Beach:Biển,Mountains:Núi,Culture:Văn hóa,Food:Ẩm thực,Shopping:Mua sắm,Adventure:Phiêu lưu,Photography:Nhiếp ảnh,Nightlife:Đời sống về đêm,Nature:Thiên nhiên" />
                    <c:forEach var="pair" items="${travelTagsMap.split(',')}">
                      <c:set var="item" value="${pair.split(':')}" />
                      <span class="tag" data-input="travelTagsInput" data-val="${item[0]}" onclick="toggleMultiTag(this)"><i class="fa fa-check"></i>${item[1]}</span>
                    </c:forEach>
                  </div>
                </div>

                <div class="form-group full">
                  <label class="form-label">Hoạt động ưa thích (Chọn nhiều)</label>
                  <input type="hidden" name="activityPreferences" id="activityTagsInput" value="${myPref.activityPreferences}">
                  <div class="tag-group">
                    <c:set var="actTagsMap" value="Hiking:Đi bộ đường dài,Camping:Cắm trại,Sightseeing:Ngắm cảnh,Local Experiences:Trải nghiệm địa phương,Water Sports:Thể thao dưới nước,Museums:Bảo tàng" />
                    <c:forEach var="pair" items="${actTagsMap.split(',')}">
                      <c:set var="item" value="${pair.split(':')}" />
                      <span class="tag" data-input="activityTagsInput" data-val="${item[0]}" onclick="toggleMultiTag(this)"><i class="fa fa-check"></i>${item[1]}</span>
                    </c:forEach>
                  </div>
                </div>

              </div>
              
              <div class="save-bar" style="margin-top: 24px;">
                <button type="button" class="btn btn-ghost" onclick="resetForm()">
                  Hủy thay đổi
                </button>
                <button type="submit" class="btn btn-primary">
                  <i class="fa fa-floppy-disk"></i> Lưu Sở Thích
                </button>
              </div>

            </div>
          </div>
        </form>
    </div>

    <!-- ── TAB 4: Notifications ── -->
    <div class="tab-content" id="tab-notifications">
      <form action="${pageContext.request.contextPath}/profile/update"
            method="post">
        <input type="hidden" name="action" value="updateNotifications">
        <div class="card">
          <div class="card-header">
            <h3><i class="fa fa-bell" style="margin-right:8px;color:var(--clr-primary)"></i>
              Cài đặt thông báo</h3>
          </div>
          <div class="card-body">
            <c:forEach var="notifType" items="${[
              ['notif_booking',  'Cập nhật booking', 'Nhận thông báo khi booking được xác nhận, hủy hoặc thay đổi'],
              ['notif_payment',  'Thanh toán',       'Nhận thông báo về giao dịch thanh toán'],
              ['notif_review',   'Đánh giá tour',    'Nhận thông báo khi có phản hồi về đánh giá của bạn'],
              ['notif_promo',    'Khuyến mãi',       'Nhận thông báo về tour ưu đãi và mã giảm giá'],
              ['notif_buddy',    'Buddy & Chat',     'Nhận thông báo khi có lời mời kết bạn đồng hành'],
              ['notif_system',   'Hệ thống',         'Thông báo bảo trì và cập nhật hệ thống']
            ]}">
              <div class="notification-row">
                <div>
                  <p style="font-size:.875rem;font-weight:500">${notifType[1]}</p>
                  <p style="font-size:.8rem;color:var(--clr-muted)">${notifType[2]}</p>
                </div>
                <label class="toggle-switch">
                  <input type="checkbox" name="${notifType[0]}" value="1" checked>
                  <span class="slider"></span>
                </label>
              </div>
            </c:forEach>

            <button type="submit" class="btn btn-primary" style="margin-top:16px">
              <i class="fa fa-floppy-disk"></i> Lưu cài đặt
            </button>
          </div>
        </div>
      </form>
    </div>

    <!-- ── TAB 5: Activity ── -->
    <div class="tab-content" id="tab-activity">
      <div class="card">
        <div class="card-header">
          <h3><i class="fa fa-clock-rotate-left" style="margin-right:8px;color:var(--clr-primary)"></i>
            Hoạt động gần đây</h3>
        </div>
        <div class="card-body">
          <c:choose>
            <c:when test="${not empty activityLogs}">
              <c:forEach var="log" items="${activityLogs}">
                <div class="activity-item">
                  <div class="activity-icon ${log.type.toLowerCase()}">
                    <c:choose>
                      <c:when test="${log.type eq 'BOOKING'}"><i class="fa fa-suitcase"></i></c:when>
                      <c:when test="${log.type eq 'PAYMENT'}"><i class="fa fa-credit-card"></i></c:when>
                      <c:when test="${log.type eq 'REVIEW'}"><i class="fa fa-star"></i></c:when>
                      <c:otherwise><i class="fa fa-right-to-bracket"></i></c:otherwise>
                    </c:choose>
                  </div>
                  <div class="activity-info">
                    <p>${log.action}</p>
                    <time><fmt:formatDate value="${log.createdAt}" pattern="dd/MM/yyyy HH:mm"/></time>
                  </div>
                </div>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <div class="empty-state" style="text-align:center; padding: 40px 20px;">
                <i class="fa fa-ghost" style="font-size: 3rem; color: var(--clr-border); margin-bottom: 16px;"></i>
                <p style="color: var(--clr-muted); font-size: 0.9rem;">Bạn chưa có hoạt động nào gần đây.</p>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>

  </div><!-- /profile-body -->
</div><!-- /profile-wrapper -->

<script>
/* ── Tabs ── */
function switchTab(name, btn) {
  document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
  document.getElementById('tab-' + name).classList.add('active');
  btn.classList.add('active');
}

/* Restore active tab if provided by server */
const serverActiveTab = "${activeTab}";
if (serverActiveTab) {
  const targetBtn = document.querySelector('.tab-btn[onclick*="' + serverActiveTab + '"]');
  if (targetBtn) switchTab(serverActiveTab, targetBtn);
}

/* ── Avatar preview ── */
function previewAvatar(input) {
  if (!input.files[0]) return;
  const reader = new FileReader();
  reader.onload = e => {
    const wrap = document.querySelector('.avatar-wrap');
    let img = wrap.querySelector('.avatar');
    if (!img) {
      const fallback = wrap.querySelector('.avatar-fallback');
      if (fallback) {
        img = document.createElement('img');
        img.className = 'avatar';
        img.alt = 'Avatar';
        fallback.replaceWith(img);
      }
    }
    if (img) img.src = e.target.result;
  };
  reader.readAsDataURL(input.files[0]);
  // Auto-submit avatar form
  const form = document.getElementById('profileForm');
  form.querySelector('[name=action]').value = 'updateAvatar';
  form.submit();
}

/* ── Profile completion ── */
const fields = ['fullName','phone','dob','gender','address','bio'];
function calcCompletion() {
  const filled = fields.filter(id => {
    const el = document.getElementById(id);
    return el && el.value && el.value.trim().length > 0;
  }).length;
  const pct = Math.round((filled / fields.length) * 100);
  document.getElementById('progressBar').style.width = pct + '%';
  document.getElementById('pct').textContent = pct + '%';

  // Bio counter
  const bio = document.getElementById('bio');
  if (bio) document.getElementById('bioCount').textContent = bio.value.length + ' / 1000 ký tự';
}
calcCompletion();

/* ── Tags Initialization ── */
var tagInputs = document.querySelectorAll('input[type="hidden"][id$="TagsInput"]');
for (var i = 0; i < tagInputs.length; i++) {
  var input = tagInputs[i];
  var savedVals = (input.value || '').split(',');
  for(var k=0; k<savedVals.length; k++) savedVals[k] = savedVals[k].trim();
  
  var tags = document.querySelectorAll('.tag[data-input="' + input.id + '"]');
  for (var j = 0; j < tags.length; j++) {
    var tag = tags[j];
    if (savedVals.indexOf(tag.dataset.val) !== -1) {
      tag.classList.add('selected');
    }
  }
}

function toggleMultiTag(el) {
  el.classList.toggle('selected');
  var inputId = el.dataset.input;
  var selectedTags = document.querySelectorAll('.tag[data-input="' + inputId + '"].selected');
  var vals = [];
  for(var i = 0; i < selectedTags.length; i++) {
     vals.push(selectedTags[i].dataset.val);
  }
  document.getElementById(inputId).value = vals.join(', ');
}

function syncTagsBeforeSubmit() {
  var tagInputs = document.querySelectorAll('input[type="hidden"][id$="TagsInput"]');
  for (var i = 0; i < tagInputs.length; i++) {
    var input = tagInputs[i];
    var selectedTags = document.querySelectorAll('.tag[data-input="' + input.id + '"].selected');
    var vals = [];
    for(var j = 0; j < selectedTags.length; j++) {
       vals.push(selectedTags[j].dataset.val);
    }
    input.value = vals.join(', ');
  }
}

const dobInputProfile = document.getElementById('dob');
if (dobInputProfile) {
  dobInputProfile.max = new Date().toISOString().split("T")[0];
}

/* ── Password strength (profile) ── */
function checkStrengthProfile(pwd) {
  const segs = [1,2,3,4].map(i => document.getElementById('ps' + i));
  const colors = ['#C0392B','#E67E22','#F1C40F','#1E7D4B'];
  let score = 0;
  if (pwd.length >= 8) score++;
  if (/[A-Z]/.test(pwd)) score++;
  if (/[0-9]/.test(pwd)) score++;
  if (/[^A-Za-z0-9]/.test(pwd)) score++;
  segs.forEach((s,i) => {
    s.style.background = i < score ? colors[Math.min(score-1,3)] : 'var(--clr-border)';
  });
}

/* ── Toggle password ── */
function togglePwd(inputId, iconId) {
  const input = document.getElementById(inputId);
  const icon  = document.getElementById(iconId);
  input.type = input.type === 'password' ? 'text' : 'password';
  icon.classList.toggle('fa-eye');
  icon.classList.toggle('fa-eye-slash');
}

/* ── Password form submit ── */
document.getElementById('pwdForm').addEventListener('submit', function(e) {
  const np = document.getElementById('newPwd').value;
  const cp = document.getElementById('confirmPwd').value;
  if (np !== cp) {
    document.getElementById('pwdMatchErr').style.display = 'block';
    document.getElementById('confirmPwd').classList.add('is-invalid');
    e.preventDefault(); return;
  }
  document.getElementById('pwdMatchErr').style.display = 'none';
  const btn = document.getElementById('savePwdBtn');
  btn.disabled = true;
  btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Đang cập nhật...';
});

/* ── Profile form submit ── */
document.getElementById('profileForm').addEventListener('submit', function() {
  const btn = document.getElementById('saveInfoBtn');
  btn.disabled = true;
  btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Đang lưu...';
});

function resetForm() {
  document.getElementById('profileForm').reset();
  calcCompletion();
}

function shareProfile() {
  if (navigator.share) {
    navigator.share({ title: 'TourBuddy Profile', url: window.location.href });
  } else {
    navigator.clipboard.writeText(window.location.href);
    alert('Đã sao chép link hồ sơ!');
  }
}
</script>
<jsp:include page="/common/footer.jsp" />
