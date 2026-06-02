<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt"  prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hồ Sơ — TourBuddy</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/tourbuddy.css?v=1.3">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <style>
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
  </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar">
  <a class="navbar-brand" href="${pageContext.request.contextPath}/home">
    <i class="fa-solid fa-compass"></i>
    Tour<span class="logo-dot">Buddy</span>
  </a>
  <div class="navbar-nav">
    <a href="${pageContext.request.contextPath}/home">Trang Chủ</a>
    <a href="${pageContext.request.contextPath}/tours">Tours</a>
    <a href="${pageContext.request.contextPath}/bookings">Booking</a>
    <a href="${pageContext.request.contextPath}/profile" class="active">Hồ Sơ</a>
    <a href="${pageContext.request.contextPath}/logout" style="color:var(--clr-error)">
      <i class="fa fa-right-from-bracket"></i>
    </a>
  </div>
</nav>

<div class="profile-wrapper">

  <!-- Cover Photo -->
  <div class="profile-cover"></div>

  <div class="profile-body">

    <!-- Profile Header -->
    <div class="profile-header fade-up">
      <div class="avatar-wrap">
        <c:choose>
          <c:when test="${not empty sessionUser.profile.avatarURL}">
            <img class="avatar"
                 src="${sessionUser.profile.avatarURL}"
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
        <a href="${pageContext.request.contextPath}/bookings" class="btn btn-primary btn-sm">
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
                         pattern="[0-9]{9,11}" maxlength="11" oninput="calcCompletion()">
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
      <form action="${pageContext.request.contextPath}/profile/update"
            method="post">
        <input type="hidden" name="action" value="updatePreferences">

        <div class="card">
          <div class="card-header">
            <h3><i class="fa fa-heart" style="margin-right:8px;color:var(--clr-accent)"></i>
              Sở thích du lịch</h3>
          </div>
          <div class="card-body">
            <div class="form-group">
              <label class="form-label">Loại hình du lịch yêu thích</label>
              <div class="tag-group" id="interestTags">
                <span class="tag" data-val="beach"    onclick="toggleTag(this)">🏖️ Biển & Đảo</span>
                <span class="tag" data-val="mountain" onclick="toggleTag(this)">⛰️ Núi & Trekking</span>
                <span class="tag" data-val="culture"  onclick="toggleTag(this)">🏛️ Văn hóa & Lịch sử</span>
                <span class="tag" data-val="food"     onclick="toggleTag(this)">🍜 Ẩm thực</span>
                <span class="tag" data-val="city"     onclick="toggleTag(this)">🌆 Đô thị</span>
                <span class="tag" data-val="adventure"onclick="toggleTag(this)">🪂 Mạo hiểm</span>
                <span class="tag" data-val="eco"      onclick="toggleTag(this)">🌿 Sinh thái</span>
                <span class="tag" data-val="luxury"   onclick="toggleTag(this)">💎 Nghỉ dưỡng cao cấp</span>
                <span class="tag" data-val="family"   onclick="toggleTag(this)">👨‍👩‍👧 Gia đình</span>
                <span class="tag" data-val="solo"     onclick="toggleTag(this)">🎒 Du lịch một mình</span>
              </div>
              <input type="hidden" name="travelInterests" id="interestInput"
                     value="${sessionUser.profile.travelInterests}">
            </div>

            <div class="form-group">
              <label class="form-label" for="budgetRange">Ngân sách tour ưa thích (VNĐ/người)</label>
              <select id="budgetRange" name="budgetRange" class="form-control" style="max-width:320px">
                <option value="">-- Chọn mức ngân sách --</option>
                <option value="under1m">Dưới 1 triệu</option>
                <option value="1m-3m">1 – 3 triệu</option>
                <option value="3m-7m">3 – 7 triệu</option>
                <option value="7m-15m">7 – 15 triệu</option>
                <option value="above15m">Trên 15 triệu</option>
              </select>
            </div>

            <div class="form-group">
              <label class="form-label" for="travelStyle">Phong cách di chuyển</label>
              <select id="travelStyle" name="travelStyle" class="form-control" style="max-width:320px">
                <option value="">-- Chọn --</option>
                <option value="backpacker">Bụi / Backpacker</option>
                <option value="comfort">Thoải mái / Tiện nghi</option>
                <option value="luxury">Sang trọng / Cao cấp</option>
                <option value="flexible">Linh hoạt</option>
              </select>
            </div>

            <button type="submit" class="btn btn-primary">
              <i class="fa fa-floppy-disk"></i> Lưu sở thích
            </button>
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
              <!-- Demo data khi chưa có log thật -->
              <div class="activity-item">
                <div class="activity-icon booking"><i class="fa fa-suitcase"></i></div>
                <div class="activity-info">
                  <p>Đặt tour <strong>Vịnh Hạ Long 3N2Đ</strong> thành công</p>
                  <time>Hôm nay, 10:24</time>
                </div>
              </div>
              <div class="activity-item">
                <div class="activity-icon payment"><i class="fa fa-credit-card"></i></div>
                <div class="activity-info">
                  <p>Thanh toán <strong>3,500,000đ</strong> qua VNPay</p>
                  <time>Hôm nay, 10:26</time>
                </div>
              </div>
              <div class="activity-item">
                <div class="activity-icon login"><i class="fa fa-right-to-bracket"></i></div>
                <div class="activity-info">
                  <p>Đăng nhập từ thiết bị mới · Chrome / Windows</p>
                  <time>Hôm qua, 08:15</time>
                </div>
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

/* ── Interest tags ── */
const savedInterests = (document.getElementById('interestInput').value || '').split(',');
document.querySelectorAll('.tag[data-val]').forEach(tag => {
  if (savedInterests.includes(tag.dataset.val)) tag.classList.add('selected');
});

function toggleTag(el) {
  el.classList.toggle('selected');
  const selected = [...document.querySelectorAll('.tag.selected')].map(t => t.dataset.val);
  document.getElementById('interestInput').value = selected.join(',');
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
</body>
</html>
