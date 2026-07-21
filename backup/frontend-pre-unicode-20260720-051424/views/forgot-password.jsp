<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Khôi phục mật khẩu — TourBuddy</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/tourbuddy.css?v=1.4">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
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
      <h1>Khôi phục<br><em>Tài khoản</em></h1>
      <p>Đừng lo lắng, chúng tôi sẽ giúp bạn lấy lại quyền truy cập vào tài khoản TourBuddy của mình.</p>
    </div>
  </div>

  <!-- Right Form Panel -->
  <div class="auth-panel">
    <div class="auth-form-wrap fade-up">

      <h2 class="auth-title fade-up fade-up-1">Quên mật khẩu?</h2>
      <p class="auth-subtitle fade-up fade-up-2">
        Vui lòng nhập địa chỉ email đã đăng ký của bạn. Chúng tôi sẽ gửi một liên kết để đặt lại mật khẩu.
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

      <!-- Forgot Password Form -->
      <form action="${pageContext.request.contextPath}/forgot-password" method="post" class="fade-up fade-up-3" id="forgotForm" novalidate>

        <div class="form-group">
          <label class="form-label" for="email">Email đã đăng ký</label>
          <div class="input-icon-wrap">
            <i class="fa fa-envelope icon"></i>
            <input type="email" id="email" name="email"
                   class="form-control"
                   placeholder="you@example.com"
                   required autocomplete="email">
          </div>
        </div>

        <button type="submit" class="btn btn-primary btn-block btn-lg" id="submitBtn">
          <i class="fa fa-paper-plane"></i> Gửi Yêu Cầu Khôi Phục
        </button>

      </form>

      <div class="divider fade-up fade-up-4">hoặc</div>

      <div class="fade-up fade-up-4" style="text-align:center">
        <a href="${pageContext.request.contextPath}/login" style="font-weight: 500; color: var(--clr-primary);">
          <i class="fa fa-arrow-left"></i> Quay lại Đăng Nhập
        </a>
      </div>

    </div>
  </div>
</div>

<script>
// Client-side validation
document.getElementById('forgotForm').addEventListener('submit', function(e) {
  const email = document.getElementById('email').value.trim();
  let valid = true;

  if (!email || !/\S+@\S+\.\S+/.test(email)) {
    document.getElementById('email').classList.add('is-invalid');
    valid = false;
  }
  if (!valid) {
    e.preventDefault();
    return;
  }

  const btn = document.getElementById('submitBtn');
  btn.disabled = true;
  btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Đang gửi...';
});

// Clear invalid state on input
document.getElementById('email').addEventListener('input', function() {
  this.classList.remove('is-invalid');
});
</script>
</body>
</html>
