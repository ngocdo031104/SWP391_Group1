<%-- 
    Liên quan đến UCs: Manage User Profile
    Tác giả: Đỗ Vũ Minh Ngọc
    MSSV: HE182479
--%>
&#65279;<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<%-- 
    Document   : profile.jsp
    Purpose    : Hi&#7875;n th&#7883; v&#224; qu&#7843;n l&#253; th&#244;ng tin h&#7891; s&#417; ng&#432;&#7901;i d&#249;ng, l&#7883;ch s&#7917; ho&#7841;t &#273;&#7897;ng, b&#7843;o m&#7853;t v&#224; c&#224;i &#273;&#7863;t th&#244;ng b&#225;o.
--%>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt"  prefix="fmt" %>
<%
    request.setAttribute("extraCss", "assets/css/tourbuddy.css?v=" + System.currentTimeMillis());
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

  <!-- &#7842;nh b&#236;a trang c&#225; nh&#226;n -->
  <div class="profile-cover"></div>

  <div class="profile-body">

    <!-- Ph&#7847;n &#273;&#7847;u trang h&#7891; s&#417; -->
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
                title="Thay &#7843;nh &#273;&#7841;i di&#7879;n">
          <i class="fa fa-camera"></i>
        </button>
      </div>

      <div class="profile-info">
        <h2>${not empty sessionUser.fullName ? sessionUser.fullName : 'Ng&#432;&#7901;i d&#249;ng TourBuddy'}</h2>
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
          <i class="fa fa-share-nodes"></i> Chia s&#7867;
        </button>
        <a href="${pageContext.request.contextPath}/customer/booking/history" class="btn btn-primary btn-sm">
          <i class="fa fa-suitcase"></i> L&#7883;ch s&#7917; Tour
        </a>
      </div>
    </div>

    <!-- Th&#7889;ng k&#234; ho&#7841;t &#273;&#7897;ng -->
    <div class="stats-row fade-up" style="animation-delay:.1s;margin-top:24px">
      <div class="stat-card">
        <div class="stat-value">${not empty totalBookings ? totalBookings : 0}</div>
        <div class="stat-label">Tour &#273;&#227; &#273;&#7863;t</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">${not empty totalReviews ? totalReviews : 0}</div>
        <div class="stat-label">&#272;&#225;nh gi&#225;</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">${not empty totalFavorites ? totalFavorites : 0}</div>
        <div class="stat-label">Tour y&#234;u th&#237;ch</div>
      </div>
    </div>

    <!-- Ti&#7871;n &#273;&#7897; ho&#224;n thi&#7879;n h&#7891; s&#417; -->
    <div class="profile-completion card fade-up" style="padding:16px 20px;margin-bottom:0">
      <p>&#272;&#7897; ho&#224;n thi&#7879;n h&#7891; s&#417;: <strong id="pct">0%</strong></p>
      <div class="progress-bar-wrap">
        <div class="progress-bar" id="progressBar" style="width:0%"></div>
      </div>
    </div>

    <!-- Hi&#7875;n th&#7883; th&#244;ng b&#225;o l&#7895;i t&#7915; Server -->
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
        <i class="fa fa-user"></i> Th&#244;ng tin c&#225; nh&#226;n
      </button>
      <button class="tab-btn" onclick="switchTab('security',this)">
        <i class="fa fa-shield-halved"></i> B&#7843;o m&#7853;t
      </button>
      <button class="tab-btn" onclick="switchTab('preferences',this)">
        <i class="fa fa-sliders"></i> S&#7903; th&#237;ch du l&#7883;ch
      </button>
      <button class="tab-btn" onclick="switchTab('notifications',this)">
        <i class="fa fa-bell"></i> Th&#244;ng b&#225;o
      </button>
      <button class="tab-btn" onclick="switchTab('activity',this)">
        <i class="fa fa-clock-rotate-left"></i> Ho&#7841;t &#273;&#7897;ng
      </button>
    </div>

    <!-- &#9472;&#9472; TAB 1: Personal Info &#9472;&#9472; -->
    <div class="tab-content active fade-up" id="tab-info">
      <form action="${pageContext.request.contextPath}/profile/update"
            method="post" enctype="multipart/form-data" id="profileForm">
        <input type="hidden" name="action" value="updateInfo">
        <input type="file" id="avatarInput" name="avatar" hidden accept="image/*"
               onchange="previewAvatar(this)">

        <div class="card">
          <div class="card-header">
            <h3><i class="fa fa-id-card" style="margin-right:8px;color:var(--clr-primary)"></i>
              Th&#244;ng tin c&#417; b&#7843;n</h3>
          </div>
          <div class="card-body">
            <div class="form-grid">

              <div class="form-group">
                <label class="form-label" for="fullName">H&#7885; v&#224; t&#234;n *</label>
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
                <span class="form-hint">Email kh&#244;ng th&#7875; thay &#273;&#7893;i</span>
              </div>

              <div class="form-group">
                <label class="form-label" for="phone">S&#7889; &#273;i&#7879;n tho&#7841;i</label>
                <div class="input-icon-wrap">
                  <i class="fa fa-phone icon"></i>
                  <input type="tel" id="phone" name="phone"
                         class="form-control"
                         value="${not empty sessionUser.phoneNumber ? sessionUser.phoneNumber : ''}"
                         pattern="0[0-9]{9}" maxlength="10" title="S&#7889; &#273;i&#7879;n tho&#7841;i g&#7891;m 10 ch&#7919; s&#7889; v&#224; b&#7855;t &#273;&#7847;u b&#7857;ng 0" oninput="calcCompletion()">
                </div>
              </div>

              <div class="form-group">
                <label class="form-label" for="dob">Ng&#224;y sinh</label>
                <div class="input-icon-wrap">
                  <i class="fa fa-calendar icon"></i>
                  <input type="date" id="dob" name="dob"
                         class="form-control"
                         value="${not empty sessionUser.profile.dateOfBirth ? sessionUser.profile.dateOfBirth : ''}"
                         oninput="calcCompletion()">
                </div>
              </div>

              <div class="form-group">
                <label class="form-label" for="gender">Gi&#7899;i t&#237;nh</label>
                <select id="gender" name="gender" class="form-control" oninput="calcCompletion()">
                  <option value="">-- Ch&#7885;n --</option>
                  <option value="Male"   ${sessionUser.profile.gender eq 'Male'   ? 'selected':''}>Nam</option>
                  <option value="Female" ${sessionUser.profile.gender eq 'Female' ? 'selected':''}>N&#7919;</option>
                  <option value="Other"  ${sessionUser.profile.gender eq 'Other'  ? 'selected':''}>Kh&#225;c</option>
                </select>
              </div>

              <div class="form-group full">
                <label class="form-label" for="address">&#272;&#7883;a ch&#7881;</label>
                <div class="input-icon-wrap">
                  <i class="fa fa-location-dot icon"></i>
                  <input type="text" id="address" name="address"
                         class="form-control"
                         value="${not empty sessionUser.profile.address ? sessionUser.profile.address : ''}"
                         placeholder="S&#7889; nh&#224;, &#273;&#432;&#7901;ng, qu&#7853;n, t&#7881;nh/th&#224;nh ph&#7889;"
                         maxlength="255" oninput="calcCompletion()">
                </div>
              </div>

              <div class="form-group full">
                <label class="form-label" for="bio">Ti&#7875;u s&#7917;</label>
                <textarea id="bio" name="biography"
                          class="form-control" rows="4"
                          placeholder="Gi&#7899;i thi&#7879;u b&#7843;n th&#226;n, phong c&#225;ch du l&#7883;ch y&#234;u th&#237;ch..."
                          maxlength="1000" oninput="calcCompletion()"
                          style="resize:vertical">${not empty sessionUser.profile.biography ? sessionUser.profile.biography : ''}</textarea>
                <span class="form-hint" id="bioCount">0 / 1000 k&#253; t&#7921;</span>
              </div>

            </div>

            <div class="save-bar">
              <button type="button" class="btn btn-ghost" onclick="resetForm()">
                H&#7911;y thay &#273;&#7893;i
              </button>
              <button type="submit" class="btn btn-primary" id="saveInfoBtn">
                <i class="fa fa-floppy-disk"></i> L&#432;u th&#244;ng tin
              </button>
            </div>
          </div>
        </div>
      </form>
    </div>

    <!-- &#9472;&#9472; TAB 2: Security &#9472;&#9472; -->
    <div class="tab-content" id="tab-security">
      <div class="card">
        <div class="card-header">
          <h3><i class="fa fa-lock" style="margin-right:8px;color:var(--clr-primary)"></i>
            &#272;&#7893;i m&#7853;t kh&#7849;u</h3>
        </div>
        <div class="card-body">
          <form action="${pageContext.request.contextPath}/profile/update"
                method="post" id="pwdForm">
            <input type="hidden" name="action" value="changePassword">

            <div class="form-group" style="max-width:440px">
              <label class="form-label" for="currentPwd">M&#7853;t kh&#7849;u hi&#7879;n t&#7841;i *</label>
              <div class="input-icon-wrap">
                <i class="fa fa-lock icon"></i>
                <input type="password" id="currentPwd" name="currentPassword"
                       class="form-control" required placeholder="&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;">
                <button type="button" class="toggle-pwd"
                        onclick="togglePwd('currentPwd','tci')"><i id="tci" class="fa fa-eye"></i></button>
              </div>
            </div>

            <div class="form-group" style="max-width:440px">
              <label class="form-label" for="newPwd">M&#7853;t kh&#7849;u m&#7899;i *</label>
              <div class="input-icon-wrap">
                <i class="fa fa-key icon"></i>
                <input type="password" id="newPwd" name="newPassword"
                       class="form-control" required minlength="8"
                       placeholder="T&#7889;i thi&#7875;u 8 k&#253; t&#7921;"
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
              <label class="form-label" for="confirmPwd">X&#225;c nh&#7853;n m&#7853;t kh&#7849;u m&#7899;i *</label>
              <div class="input-icon-wrap">
                <i class="fa fa-key icon"></i>
                <input type="password" id="confirmPwd" name="confirmNewPassword"
                       class="form-control" required placeholder="&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;">
                <button type="button" class="toggle-pwd"
                        onclick="togglePwd('confirmPwd','tci2')"><i id="tci2" class="fa fa-eye"></i></button>
              </div>
              <span class="form-error" id="pwdMatchErr" style="display:none">M&#7853;t kh&#7849;u kh&#244;ng kh&#7899;p</span>
            </div>

            <button type="submit" class="btn btn-primary" id="savePwdBtn">
              <i class="fa fa-shield-halved"></i> C&#7853;p nh&#7853;t m&#7853;t kh&#7849;u
            </button>
          </form>

          <hr style="border:none;border-top:1px solid var(--clr-border);margin:28px 0">

          <div>
            <h4 style="font-size:.95rem;font-weight:600;margin-bottom:4px">Phi&#234;n &#273;&#259;ng nh&#7853;p</h4>
            <p style="font-size:.85rem;color:var(--clr-muted);margin-bottom:16px">
              &#272;&#259;ng xu&#7845;t kh&#7887;i t&#7845;t c&#7843; thi&#7871;t b&#7883; kh&#225;c &#273;&#7875; b&#7843;o v&#7879; t&#224;i kho&#7843;n.
            </p>
            <a href="${pageContext.request.contextPath}/logout?all=true"
               class="btn btn-outline btn-sm" style="color:var(--clr-error);border-color:var(--clr-error)">
              <i class="fa fa-right-from-bracket"></i> &#272;&#259;ng xu&#7845;t m&#7885;i n&#417;i
            </a>
          </div>
        </div>
      </div>
    </div>

    <!-- &#9472;&#9472; TAB 3: Preferences &#9472;&#9472; -->
    <div class="tab-content" id="tab-preferences">
        <form action="${pageContext.request.contextPath}/profile/update" method="post" id="prefForm" onsubmit="syncTagsBeforeSubmit()">
          <input type="hidden" name="action" value="updatePreferences">
          <div class="card">
            <div class="card-header">
              <h3><i class="fa fa-heart" style="margin-right:8px;color:var(--clr-accent)"></i>
                S&#7903; th&#237;ch & T&#236;m b&#7841;n &#273;&#7891;ng h&#224;nh</h3>
            </div>
            <div class="card-body">
              <div class="form-grid">
                
                <div class="form-group full">
                  <label class="form-label">&#272;i&#7875;m &#273;&#7871;n y&#234;u th&#237;ch (Tags)</label>
                  <input type="text" name="destination" class="form-control" value="${myPref.destination}" placeholder="VD: Vietnam, Thailand, Japan...">
                </div>

                <div class="form-group">
                  <label class="form-label">Phong c&#225;ch du l&#7883;ch</label>
                  <select name="travelStyle" class="form-control">
                    <option value="Explorer" ${myPref.travelStyle == 'Explorer' ? 'selected' : ''}>Kh&#225;m ph&#225; (Explorer)</option>
                    <option value="Relaxed" ${myPref.travelStyle == 'Relaxed' ? 'selected' : ''}>Ngh&#7881; d&#432;&#7905;ng (Relaxed)</option>
                    <option value="Balanced" ${myPref.travelStyle == 'Balanced' ? 'selected' : ''}>C&#226;n b&#7857;ng (Balanced)</option>
                    <option value="Luxury" ${myPref.travelStyle == 'Luxury' ? 'selected' : ''}>Sang tr&#7885;ng (Luxury)</option>
                    <option value="Backpacking" ${myPref.travelStyle == 'Backpacking' ? 'selected' : ''}>Ph&#432;&#7907;t (Backpacking)</option>
                  </select>
                </div>
                
                <div class="form-group">
                  <label class="form-label">T&#7847;n su&#7845;t du l&#7883;ch</label>
                  <select name="travelFrequency" class="form-control">
                    <option value="Rarely" ${myPref.travelFrequency == 'Rarely' ? 'selected' : ''}>Hi&#7871;m khi (1-2 l&#7847;n/n&#259;m)</option>
                    <option value="Occasionally" ${myPref.travelFrequency == 'Occasionally' ? 'selected' : ''}>Th&#7881;nh tho&#7843;ng (3-5 l&#7847;n/n&#259;m)</option>
                    <option value="Frequently" ${myPref.travelFrequency == 'Frequently' ? 'selected' : ''}>Th&#432;&#7901;ng xuy&#234;n (M&#7895;i th&#225;ng)</option>
                  </select>
                </div>

                <div class="form-group">
                  <label class="form-label">Th&#7901;i gian chuy&#7871;n &#273;i &#432;u ti&#234;n</label>
                  <select name="tripDuration" class="form-control">
                    <option value="1-3 days" ${myPref.tripDuration == '1-3 days' ? 'selected' : ''}>1-3 ng&#224;y (Ng&#7855;n ng&#224;y)</option>
                    <option value="1 week" ${myPref.tripDuration == '1 week' ? 'selected' : ''}>1 tu&#7847;n</option>
                    <option value="2+ weeks" ${myPref.tripDuration == '2+ weeks' ? 'selected' : ''}>H&#417;n 2 tu&#7847;n</option>
                  </select>
                </div>

                <div class="form-group">
                  <label class="form-label">Ng&#244;n ng&#7919;</label>
                  <select name="languages" class="form-control">
                    <option value="Ti&#7871;ng Vi&#7879;t" ${myPref.languages == 'Ti&#7871;ng Vi&#7879;t' ? 'selected' : ''}>Ti&#7871;ng Vi&#7879;t</option>
                    <option value="English" ${myPref.languages == 'English' ? 'selected' : ''}>Ti&#7871;ng Anh</option>
                    <option value="Bilingual" ${myPref.languages == 'Bilingual' ? 'selected' : ''}>Song ng&#7919; (Anh-Vi&#7879;t)</option>
                  </select>
                </div>

                <div class="form-group">
                  <label class="form-label">Th&#243;i quen h&#250;t thu&#7889;c</label>
                  <select name="smokingPreference" class="form-control">
                    <option value="Non-smoker" ${myPref.smokingPreference == 'Non-smoker' ? 'selected' : ''}>Kh&#244;ng h&#250;t thu&#7889;c</option>
                    <option value="Smoker" ${myPref.smokingPreference == 'Smoker' ? 'selected' : ''}>C&#243; h&#250;t thu&#7889;c</option>
                    <option value="Don't care" ${myPref.smokingPreference == "Don't care" ? 'selected' : ''}>Kh&#244;ng quan t&#226;m</option>
                  </select>
                </div>

                <div class="form-group">
                  <label class="form-label">Th&#243;i quen u&#7889;ng r&#432;&#7907;u bia</label>
                  <select name="drinkingPreference" class="form-control">
                    <option value="Non-drinker" ${myPref.drinkingPreference == 'Non-drinker' ? 'selected' : ''}>Kh&#244;ng u&#7889;ng</option>
                    <option value="Social drinker" ${myPref.drinkingPreference == 'Social drinker' ? 'selected' : ''}>U&#7889;ng x&#227; giao</option>
                    <option value="Don't care" ${myPref.drinkingPreference == "Don't care" ? 'selected' : ''}>Kh&#244;ng quan t&#226;m</option>
                  </select>
                </div>

                <div class="form-group">
                  <label class="form-label">&#272;&#7897; tu&#7893;i b&#7841;n &#273;&#7891;ng h&#224;nh &#432;u ti&#234;n</label>
                  <select name="targetAgeMax" class="form-control">
                    <option value="0" ${myPref.targetAgeMax == 0 ? 'selected' : ''}>B&#7845;t k&#7923; &#273;&#7897; tu&#7893;i n&#224;o</option>
                    <option value="25" ${myPref.targetAgeMax == 25 ? 'selected' : ''}>18 - 25 tu&#7893;i</option>
                    <option value="35" ${myPref.targetAgeMax == 35 ? 'selected' : ''}>26 - 35 tu&#7893;i</option>
                    <option value="50" ${myPref.targetAgeMax == 50 ? 'selected' : ''}>36 - 50 tu&#7893;i</option>
                  </select>
                </div>

                <div class="form-group">
                  <label class="form-label">Gi&#7899;i t&#237;nh b&#7841;n &#273;&#7891;ng h&#224;nh</label>
                  <select name="gender" class="form-control">
                    <option value="All" ${myPref.targetGender == 'All' ? 'selected' : ''}>T&#7845;t c&#7843;</option>
                    <option value="Male" ${myPref.targetGender == 'Male' ? 'selected' : ''}>Nam</option>
                    <option value="Female" ${myPref.targetGender == 'Female' ? 'selected' : ''}>N&#7919;</option>
                  </select>
                </div>

                <div class="form-group full">
                  <label class="form-label">S&#7903; th&#237;ch du l&#7883;ch (Ch&#7885;n nhi&#7873;u)</label>
                  <input type="hidden" name="tags" id="travelTagsInput" value="${myPref.tags}">
                  <div class="tag-group">
                    <c:set var="travelTagsMap" value="Beach:Bi&#7875;n,Mountains:N&#250;i,Culture:V&#259;n h&#243;a,Food:&#7848;m th&#7921;c,Shopping:Mua s&#7855;m,Adventure:Phi&#234;u l&#432;u,Photography:Nhi&#7871;p &#7843;nh,Nightlife:&#272;&#7901;i s&#7889;ng v&#7873; &#273;&#234;m,Nature:Thi&#234;n nhi&#234;n" />
                    <c:forEach var="pair" items="${travelTagsMap.split(',')}">
                      <c:set var="item" value="${pair.split(':')}" />
                      <span class="tag" data-input="travelTagsInput" data-val="${item[0]}" onclick="toggleMultiTag(this)"><i class="fa fa-check"></i>${item[1]}</span>
                    </c:forEach>
                  </div>
                </div>

                <div class="form-group full">
                  <label class="form-label">Ho&#7841;t &#273;&#7897;ng &#432;a th&#237;ch (Ch&#7885;n nhi&#7873;u)</label>
                  <input type="hidden" name="activityPreferences" id="activityTagsInput" value="${myPref.activityPreferences}">
                  <div class="tag-group">
                    <c:set var="actTagsMap" value="Hiking:&#272;i b&#7897; &#273;&#432;&#7901;ng d&#224;i,Camping:C&#7855;m tr&#7841;i,Sightseeing:Ng&#7855;m c&#7843;nh,Local Experiences:Tr&#7843;i nghi&#7879;m &#273;&#7883;a ph&#432;&#417;ng,Water Sports:Th&#7875; thao d&#432;&#7899;i n&#432;&#7899;c,Museums:B&#7843;o t&#224;ng" />
                    <c:forEach var="pair" items="${actTagsMap.split(',')}">
                      <c:set var="item" value="${pair.split(':')}" />
                      <span class="tag" data-input="activityTagsInput" data-val="${item[0]}" onclick="toggleMultiTag(this)"><i class="fa fa-check"></i>${item[1]}</span>
                    </c:forEach>
                  </div>
                </div>

              </div>
              
              <div class="save-bar" style="margin-top: 24px;">
                <button type="button" class="btn btn-ghost" onclick="resetForm()">
                  H&#7911;y thay &#273;&#7893;i
                </button>
                <button type="submit" class="btn btn-primary">
                  <i class="fa fa-floppy-disk"></i> L&#432;u S&#7903; Th&#237;ch
                </button>
              </div>

            </div>
          </div>
        </form>
    </div>

    <!-- &#9472;&#9472; TAB 4: Notifications &#9472;&#9472; -->
    <div class="tab-content" id="tab-notifications">
      <form action="${pageContext.request.contextPath}/profile/update"
            method="post">
        <input type="hidden" name="action" value="updateNotifications">
        <div class="card">
          <div class="card-header">
            <h3><i class="fa fa-bell" style="margin-right:8px;color:var(--clr-primary)"></i>
              C&#224;i &#273;&#7863;t th&#244;ng b&#225;o</h3>
          </div>
          <div class="card-body">
            <c:forEach var="notifType" items="${[
              ['notif_booking',  'C&#7853;p nh&#7853;t booking', 'Nh&#7853;n th&#244;ng b&#225;o khi booking &#273;&#432;&#7907;c x&#225;c nh&#7853;n, h&#7911;y ho&#7863;c thay &#273;&#7893;i'],
              ['notif_payment',  'Thanh to&#225;n',       'Nh&#7853;n th&#244;ng b&#225;o v&#7873; giao d&#7883;ch thanh to&#225;n'],
              ['notif_review',   '&#272;&#225;nh gi&#225; tour',    'Nh&#7853;n th&#244;ng b&#225;o khi c&#243; ph&#7843;n h&#7891;i v&#7873; &#273;&#225;nh gi&#225; c&#7911;a b&#7841;n'],
              ['notif_promo',    'Khuy&#7871;n m&#227;i',       'Nh&#7853;n th&#244;ng b&#225;o v&#7873; tour &#432;u &#273;&#227;i v&#224; m&#227; gi&#7843;m gi&#225;'],
              ['notif_buddy',    'Buddy & Chat',     'Nh&#7853;n th&#244;ng b&#225;o khi c&#243; l&#7901;i m&#7901;i k&#7871;t b&#7841;n &#273;&#7891;ng h&#224;nh'],
              ['notif_system',   'H&#7879; th&#7889;ng',         'Th&#244;ng b&#225;o b&#7843;o tr&#236; v&#224; c&#7853;p nh&#7853;t h&#7879; th&#7889;ng']
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
              <i class="fa fa-floppy-disk"></i> L&#432;u c&#224;i &#273;&#7863;t
            </button>
          </div>
        </div>
      </form>
    </div>

    <!-- &#9472;&#9472; TAB 5: Activity &#9472;&#9472; -->
    <div class="tab-content" id="tab-activity">
      <div class="card">
        <div class="card-header">
          <h3><i class="fa fa-clock-rotate-left" style="margin-right:8px;color:var(--clr-primary)"></i>
            Ho&#7841;t &#273;&#7897;ng g&#7847;n &#273;&#226;y</h3>
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
                      <c:when test="${log.type eq 'WISHLIST'}"><i class="fa fa-heart" style="color: var(--danger);"></i></c:when>
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
                <p style="color: var(--clr-muted); font-size: 0.9rem;">B&#7841;n ch&#432;a c&#243; ho&#7841;t &#273;&#7897;ng n&#224;o g&#7847;n &#273;&#226;y.</p>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>

  </div><!-- /profile-body -->
</div><!-- /profile-wrapper -->

<script>
/* \u2500\u2500 Tabs \u2500\u2500 */
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

/* \u2500\u2500 Avatar preview \u2500\u2500 */
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

/* \u2500\u2500 Profile completion \u2500\u2500 */
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
  if (bio) document.getElementById('bioCount').textContent = bio.value.length + ' / 1000 k\u00fd t\u1ef1';
}
calcCompletion();

/* \u2500\u2500 Tags Initialization \u2500\u2500 */
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

/* \u2500\u2500 Password strength (profile) \u2500\u2500 */
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

/* \u2500\u2500 Toggle password \u2500\u2500 */
function togglePwd(inputId, iconId) {
  const input = document.getElementById(inputId);
  const icon  = document.getElementById(iconId);
  input.type = input.type === 'password' ? 'text' : 'password';
  icon.classList.toggle('fa-eye');
  icon.classList.toggle('fa-eye-slash');
}

/* \u2500\u2500 Password form submit \u2500\u2500 */
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
  btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> \u0110ang c\u1eadp nh\u1eadt...';
});

/* \u2500\u2500 Profile form submit \u2500\u2500 */
document.getElementById('profileForm').addEventListener('submit', function() {
  const btn = document.getElementById('saveInfoBtn');
  btn.disabled = true;
  btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> \u0110ang l\u01b0u...';
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
    alert('\u0110\u00e3 sao ch\u00e9p link h\u1ed3 s\u01a1!');
  }
}
</script>
<jsp:include page="/common/footer.jsp" />

