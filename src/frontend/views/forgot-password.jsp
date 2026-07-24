<%-- 
    Liên quan đến UCs: Recover Password
    Tác giả: Đỗ Vũ Minh Ngọc
    MSSV: HE182479
--%>
&#65279;<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Kh&#244;i ph&#7909;c m&#7853;t kh&#7849;u &#8212; TourBuddy</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/tourbuddy.css?v=1.4">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>

<!-- Thanh &#273;i&#7873;u h&#432;&#7899;ng (Navbar) -->
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

<!-- B&#7889; c&#7909;c trang x&#225;c th&#7921;c -->
<div class="auth-wrapper" style="padding-top:68px">

  <!-- C&#7897;t tr&#225;i: H&#236;nh &#7843;nh gi&#7899;i thi&#7879;u -->
  <div class="auth-hero">
    <div class="auth-hero-content">
      <h1>Kh&#244;i ph&#7909;c<br><em>T&#224;i kho&#7843;n</em></h1>
      <p>&#272;&#7915;ng lo l&#7855;ng, ch&#250;ng t&#244;i s&#7869; gi&#250;p b&#7841;n l&#7845;y l&#7841;i quy&#7873;n truy c&#7853;p v&#224;o t&#224;i kho&#7843;n TourBuddy c&#7911;a m&#236;nh.</p>
    </div>
  </div>

  <!-- C&#7897;t ph&#7843;i: Khung nh&#7853;p li&#7879;u -->
  <div class="auth-panel">
    <div class="auth-form-wrap fade-up">

      <h2 class="auth-title fade-up fade-up-1">Qu&#234;n m&#7853;t kh&#7849;u?</h2>
      <p class="auth-subtitle fade-up fade-up-2">
        Vui l&#242;ng nh&#7853;p &#273;&#7883;a ch&#7881; email &#273;&#227; &#273;&#259;ng k&#253; c&#7911;a b&#7841;n. Ch&#250;ng t&#244;i s&#7869; g&#7917;i m&#7897;t li&#234;n k&#7871;t &#273;&#7875; &#273;&#7863;t l&#7841;i m&#7853;t kh&#7849;u.
      </p>

      <!-- Hi&#7875;n th&#7883; th&#244;ng b&#225;o l&#7895;i t&#7915; Server -->
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
          <label class="form-label" for="email">Email &#273;&#227; &#273;&#259;ng k&#253;</label>
          <div class="input-icon-wrap">
            <i class="fa fa-envelope icon"></i>
            <input type="email" id="email" name="email"
                   class="form-control"
                   placeholder="you@example.com"
                   required autocomplete="email">
          </div>
        </div>

        <button type="submit" class="btn btn-primary btn-block btn-lg" id="submitBtn">
          <i class="fa fa-paper-plane"></i> G&#7917;i Y&#234;u C&#7847;u Kh&#244;i Ph&#7909;c
        </button>

      </form>

      <div class="divider fade-up fade-up-4">ho&#7863;c</div>

      <div class="fade-up fade-up-4" style="text-align:center">
        <a href="${pageContext.request.contextPath}/login" style="font-weight: 500; color: var(--clr-primary);">
          <i class="fa fa-arrow-left"></i> Quay l&#7841;i &#272;&#259;ng Nh&#7853;p
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
  btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> \u0110ang g\u1eedi...';
});

// Clear invalid state on input
document.getElementById('email').addEventListener('input', function() {
  this.classList.remove('is-invalid');
});
</script>
</body>
</html>

