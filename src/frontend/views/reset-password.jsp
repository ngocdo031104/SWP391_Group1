<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tạo Mật Khẩu Mới — TourBuddy</title>
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
    <a href="${pageContext.request.contextPath}/home">Trang Chủ</a>
    <a href="${pageContext.request.contextPath}/login">Đăng Nhập</a>
  </div>
</nav>

<!-- Auth Layout -->
<div class="auth-wrapper" style="padding-top:68px">

  <!-- Left Hero -->
  <div class="auth-hero">
    <div class="auth-hero-content">
      <h1>Bảo mật<br><em>Tài khoản</em></h1>
      <p>Tạo một mật khẩu mới mạnh mẽ và dễ nhớ để bảo vệ tài khoản TourBuddy của bạn.</p>
    </div>
  </div>

  <!-- Right Form Panel -->
  <div class="auth-panel">
    <div class="auth-form-wrap fade-up">

      <h2 class="auth-title fade-up fade-up-1">Tạo mật khẩu mới</h2>
      <p class="auth-subtitle fade-up fade-up-2">
        Vui lòng nhập mật khẩu mới của bạn bên dưới. Mật khẩu phải có ít nhất 8 ký tự.
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
          <label class="form-label" for="newPassword">Mật khẩu mới</label>
          <div class="input-icon-wrap">
            <i class="fa fa-lock icon"></i>
            <input type="password" id="newPassword" name="newPassword"
                   class="form-control"
                   placeholder="Tối thiểu 8 ký tự"
                   required minlength="8"
                   oninput="checkStrength(this.value)">
            <button type="button" class="toggle-pwd" onclick="togglePwd('newPassword','toggleIcon1')" aria-label="Hiện mật khẩu">
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
          <label class="form-label" for="confirmPassword">Xác nhận mật khẩu</label>
          <div class="input-icon-wrap">
            <i class="fa fa-lock icon"></i>
            <input type="password" id="confirmPassword" name="confirmPassword"
                   class="form-control"
                   placeholder="••••••••"
                   required>
            <button type="button" class="toggle-pwd" onclick="togglePwd('confirmPassword','toggleIcon2')" aria-label="Hiện mật khẩu">
              <i id="toggleIcon2" class="fa fa-eye"></i>
            </button>
          </div>
          <span class="form-error" id="pwdMatchErr" style="display:none"><i class="fa fa-triangle-exclamation"></i> Mật khẩu không khớp</span>
        </div>

        <button type="submit" class="btn btn-primary btn-block btn-lg" id="submitBtn">
          <i class="fa fa-check-circle"></i> Đổi Mật Khẩu
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
  btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Đang xử lý...';
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
