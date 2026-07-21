&#65279;<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>T&#7841;o M&#7853;t Kh&#7849;u M&#7899;i &#8212; TourBuddy</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/tourbuddy.css?v=1.4">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <style>
    .strength-bar { display: flex; gap: 4px; margin-top: 8px; }
    .strength-bar div { flex: 1; height: 4px; border-radius: 99px; background: var(--clr-border); transition: 0.3s; }
  </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar">
  <a href="${pageContext.request.contextPath}/home" class="logo" id="nav-logo">
    <div class="logo-icon">T</div>
    <span>TourBuddy</span>
  </a>
  <div class="navbar-nav">
    <a href="${pageContext.request.contextPath}/home">Trang Ch&#7911;</a>
    <a href="${pageContext.request.contextPath}/login">&#272;&#259;ng Nh&#7853;p</a>
  </div>
</nav>

<!-- Auth Layout -->
<div class="auth-wrapper" style="padding-top:68px">

  <!-- Left Hero -->
  <div class="auth-hero">
    <div class="auth-hero-content">
      <h1>B&#7843;o m&#7853;t<br><em>T&#224;i kho&#7843;n</em></h1>
      <p>T&#7841;o m&#7897;t m&#7853;t kh&#7849;u m&#7899;i m&#7841;nh m&#7869; v&#224; d&#7877; nh&#7899; &#273;&#7875; b&#7843;o v&#7879; t&#224;i kho&#7843;n TourBuddy c&#7911;a b&#7841;n.</p>
    </div>
  </div>

  <!-- Right Form Panel -->
  <div class="auth-panel">
    <div class="auth-form-wrap fade-up">

      <h2 class="auth-title fade-up fade-up-1">T&#7841;o m&#7853;t kh&#7849;u m&#7899;i</h2>
      <p class="auth-subtitle fade-up fade-up-2">
        Vui l&#242;ng nh&#7853;p m&#7853;t kh&#7849;u m&#7899;i c&#7911;a b&#7841;n b&#234;n d&#432;&#7899;i. M&#7853;t kh&#7849;u ph&#7843;i c&#243; &#237;t nh&#7845;t 8 k&#253; t&#7921;.
      </p>

      <!-- Server messages -->
      <c:if test="${not empty errorMessage}">
        <div class="alert alert-error fade-up">
          <i class="fa fa-circle-exclamation"></i> ${errorMessage}
        </div>
      </c:if>

      <!-- Reset Password Form -->
      <form action="${pageContext.request.contextPath}/reset-password" method="post" class="fade-up fade-up-3" id="resetForm" novalidate>
        
        <input type="hidden" name="token" value="${token}">

        <div class="form-group">
          <label class="form-label" for="newPassword">M&#7853;t kh&#7849;u m&#7899;i</label>
          <div class="input-icon-wrap">
            <i class="fa fa-lock icon"></i>
            <input type="password" id="newPassword" name="newPassword"
                   class="form-control"
                   placeholder="T&#7889;i thi&#7875;u 8 k&#253; t&#7921;"
                   required minlength="8"
                   oninput="checkStrength(this.value)">
            <button type="button" class="toggle-pwd" onclick="togglePwd('newPassword','toggleIcon1')" aria-label="Hi&#7879;n m&#7853;t kh&#7849;u">
              <i id="toggleIcon1" class="fa fa-eye"></i>
            </button>
          </div>
          <div class="strength-bar">
            <div id="ps1"></div>
            <div id="ps2"></div>
            <div id="ps3"></div>
            <div id="ps4"></div>
          </div>
        </div>

        <div class="form-group">
          <label class="form-label" for="confirmPassword">X&#225;c nh&#7853;n m&#7853;t kh&#7849;u</label>
          <div class="input-icon-wrap">
            <i class="fa fa-lock icon"></i>
            <input type="password" id="confirmPassword" name="confirmPassword"
                   class="form-control"
                   placeholder="&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;"
                   required>
            <button type="button" class="toggle-pwd" onclick="togglePwd('confirmPassword','toggleIcon2')" aria-label="Hi&#7879;n m&#7853;t kh&#7849;u">
              <i id="toggleIcon2" class="fa fa-eye"></i>
            </button>
          </div>
          <span class="form-error" id="pwdMatchErr" style="display:none"><i class="fa fa-triangle-exclamation"></i> M&#7853;t kh&#7849;u kh&#244;ng kh&#7899;p</span>
        </div>

        <button type="submit" class="btn btn-primary btn-block btn-lg" id="submitBtn">
          <i class="fa fa-check-circle"></i> &#272;&#7893;i M&#7853;t Kh&#7849;u
        </button>

      </form>

    </div>
  </div>
</div>

<script>
function togglePwd(inputId, iconId) {
  const input = document.getElementById(inputId);
  const icon  = document.getElementById(iconId);
  if (input.type === 'password') {
    input.type = 'text';
    icon.classList.replace('fa-eye','fa-eye-slash');
  } else {
    input.type = 'password';
    icon.classList.replace('fa-eye-slash','fa-eye');
  }
}

function checkStrength(pwd) {
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

// Client-side validation
document.getElementById('resetForm').addEventListener('submit', function(e) {
  const newPwd = document.getElementById('newPassword').value;
  const confPwd = document.getElementById('confirmPassword').value;
  let valid = true;

  if (!newPwd || newPwd.length < 8) {
    document.getElementById('newPassword').classList.add('is-invalid');
    valid = false;
  }
  if (newPwd !== confPwd) {
    document.getElementById('pwdMatchErr').style.display = 'block';
    document.getElementById('confirmPassword').classList.add('is-invalid');
    valid = false;
  } else {
    document.getElementById('pwdMatchErr').style.display = 'none';
  }
  
  if (!valid) {
    e.preventDefault();
    return;
  }

  const btn = document.getElementById('submitBtn');
  btn.disabled = true;
  btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> \u0110ang x\u1eed l\u00fd...';
});

// Clear invalid state on input
['newPassword','confirmPassword'].forEach(id => {
  document.getElementById(id).addEventListener('input', function() {
    this.classList.remove('is-invalid');
    if(id === 'confirmPassword') document.getElementById('pwdMatchErr').style.display = 'none';
  });
});
</script>
</body>
</html>
