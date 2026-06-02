<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Đăng Nhập — TourBuddy</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/tourbuddy.css?v=1.3">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
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
    <a href="${pageContext.request.contextPath}/login" class="active">Đăng Nhập</a>
  </div>
</nav>

<!-- Auth Layout -->
<div class="auth-wrapper" style="padding-top:68px">

  <!-- Left Hero -->
  <div class="auth-hero">
    <div class="auth-hero-content">
      <h1>Khám phá <em>thế giới</em><br>cùng TourBuddy</h1>
      <p>Hàng trăm hành trình đang chờ bạn. Đăng nhập để bắt đầu chuyến phiêu lưu tiếp theo.</p>
      <div class="auth-hero-badges">
        <span><i class="fa fa-map-marker-alt"></i> 50+ Điểm đến</span>
        <span><i class="fa fa-star"></i> 4.8 / 5 Rating</span>
        <span><i class="fa fa-users"></i> 10,000+ Khách hàng</span>
      </div>
    </div>
  </div>

  <!-- Right Form Panel -->
  <div class="auth-panel">
    <div class="auth-form-wrap fade-up">

      <h2 class="auth-title fade-up fade-up-1">Chào mừng trở lại</h2>
      <p class="auth-subtitle fade-up fade-up-2">
        Chưa có tài khoản?
        <a href="${pageContext.request.contextPath}/register">Đăng ký ngay</a>
      </p>

      <!-- Server messages -->
      <c:if test="${not empty errorMessage}">
        <div class="alert alert-error fade-up">
          <i class="fa fa-circle-exclamation"></i> ${errorMessage}
        </div>
      </c:if>
      <c:if test="${not empty successMessage}">
        <div class="alert alert-success fade-up">
          <i class="fa fa-circle-check"></i> ${successMessage}
        </div>
      </c:if>

      <!-- Login Form -->
      <form action="${pageContext.request.contextPath}/login" method="post" class="fade-up fade-up-3" id="loginForm" novalidate>

        <div class="form-group">
          <label class="form-label" for="email">Email</label>
          <div class="input-icon-wrap">
            <i class="fa fa-envelope icon"></i>
            <input type="email" id="email" name="email"
                   class="form-control ${not empty emailError ? 'is-invalid' : ''}"
                   placeholder="you@example.com"
                   value="${not empty param.email ? param.email : ''}"
                   required autocomplete="email">
          </div>
          <c:if test="${not empty emailError}">
            <span class="form-error"><i class="fa fa-triangle-exclamation"></i> ${emailError}</span>
          </c:if>
        </div>

        <div class="form-group">
          <label class="form-label" for="password">
            Mật khẩu
            <a href="${pageContext.request.contextPath}/forgot-password"
               style="float:right;text-transform:none;font-weight:400;font-size:.8rem;color:var(--clr-accent)">
              Quên mật khẩu?
            </a>
          </label>
          <div class="input-icon-wrap">
            <i class="fa fa-lock icon"></i>
            <input type="password" id="password" name="password"
                   class="form-control ${not empty passwordError ? 'is-invalid' : ''}"
                   placeholder="••••••••"
                   required autocomplete="current-password">
            <button type="button" class="toggle-pwd" onclick="togglePwd('password','toggleIcon1')" aria-label="Hiện mật khẩu">
              <i id="toggleIcon1" class="fa fa-eye"></i>
            </button>
          </div>
          <c:if test="${not empty passwordError}">
            <span class="form-error"><i class="fa fa-triangle-exclamation"></i> ${passwordError}</span>
          </c:if>
        </div>

        <div class="form-group">
          <div class="form-check">
            <input type="checkbox" id="rememberMe" name="rememberMe"
                   ${not empty param.rememberMe ? 'checked' : ''}>
            <label class="form-check-label" for="rememberMe">Ghi nhớ đăng nhập trong 30 ngày</label>
          </div>
        </div>

        <button type="submit" class="btn btn-primary btn-block btn-lg" id="loginBtn">
          <i class="fa fa-right-to-bracket"></i> Đăng Nhập
        </button>

      </form>

      <div class="divider fade-up fade-up-4">hoặc tiếp tục với</div>

      <div style="display:flex;gap:10px" class="fade-up fade-up-4">
        <button class="btn btn-outline btn-block" onclick="alert('Tính năng Google đang phát triển')">
          <i class="fa-brands fa-google"></i> Google
        </button>
        <button class="btn btn-outline btn-block" onclick="alert('Tính năng Facebook đang phát triển')">
          <i class="fa-brands fa-facebook"></i> Facebook
        </button>
      </div>

      <div class="auth-footer-links">
        <a href="#">Điều khoản dịch vụ</a><span>·</span>
        <a href="#">Chính sách bảo mật</a><span>·</span>
        <a href="#">Hỗ trợ</a>
      </div>

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

// Client-side validation
document.getElementById('loginForm').addEventListener('submit', function(e) {
  const email = document.getElementById('email').value.trim();
  const pwd   = document.getElementById('password').value;
  let valid = true;

  if (!email || !/\S+@\S+\.\S+/.test(email)) {
    document.getElementById('email').classList.add('is-invalid');
    valid = false;
  }
  if (!pwd || pwd.length < 6) {
    document.getElementById('password').classList.add('is-invalid');
    valid = false;
  }
  if (!valid) {
    e.preventDefault();
    return;
  }

  const btn = document.getElementById('loginBtn');
  btn.disabled = true;
  btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Đang xử lý...';
});

// Clear invalid state on input
['email','password'].forEach(id => {
  document.getElementById(id).addEventListener('input', function() {
    this.classList.remove('is-invalid');
  });
});
</script>
</body>
</html>

