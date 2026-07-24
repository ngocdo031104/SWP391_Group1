<%-- 
    Liên quan đến UCs: Authenticate User
    Tác giả: Đỗ Vũ Minh Ngọc
    MSSV: HE182479
--%>
&#65279;<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<%-- 
    Document   : login.jsp
    Purpose    : Trang &#273;&#259;ng nh&#7853;p v&#224;o h&#7879; th&#7889;ng TourBuddy. Hi&#7875;n th&#7883; form &#273;&#259;ng nh&#7853;p v&#224; x&#7917; l&#253; th&#244;ng b&#225;o l&#7895;i.
--%>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>&#272;&#259;ng Nh&#7853;p &#8212; TourBuddy</title>
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
    <a href="${pageContext.request.contextPath}/tourdiscovery">Tours</a>
    <a href="${pageContext.request.contextPath}/login" class="active">&#272;&#259;ng Nh&#7853;p</a>
  </div>
</nav>

<!-- B&#7889; c&#7909;c trang x&#225;c th&#7921;c -->
<div class="auth-wrapper" style="padding-top:68px">

  <!-- C&#7897;t tr&#225;i: H&#236;nh &#7843;nh gi&#7899;i thi&#7879;u -->
  <div class="auth-hero">
    <div class="auth-hero-content">
      <h1>Kh&#225;m ph&#225; <em>th&#7871; gi&#7899;i</em><br>c&#249;ng TourBuddy</h1>
      <p>H&#224;ng tr&#259;m h&#224;nh tr&#236;nh &#273;ang ch&#7901; b&#7841;n. &#272;&#259;ng nh&#7853;p &#273;&#7875; b&#7855;t &#273;&#7847;u chuy&#7871;n phi&#234;u l&#432;u ti&#7871;p theo.</p>
      <div class="auth-hero-badges">
        <span><i class="fa fa-map-marker-alt"></i> 50+ &#272;i&#7875;m &#273;&#7871;n</span>
        <span><i class="fa fa-star"></i> 4.8 / 5 Rating</span>
        <span><i class="fa fa-users"></i> 10,000+ Kh&#225;ch h&#224;ng</span>
      </div>
    </div>
  </div>

  <!-- C&#7897;t ph&#7843;i: Khung nh&#7853;p li&#7879;u -->
  <div class="auth-panel">
    <div class="auth-form-wrap fade-up">

      <h2 class="auth-title fade-up fade-up-1">Ch&#224;o m&#7915;ng tr&#7903; l&#7841;i</h2>
      <p class="auth-subtitle fade-up fade-up-2">
        Ch&#432;a c&#243; t&#224;i kho&#7843;n?
        <a href="${pageContext.request.contextPath}/register">&#272;&#259;ng k&#253; ngay</a>
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
            M&#7853;t kh&#7849;u
            <a href="${pageContext.request.contextPath}/forgot-password"
               style="float:right;text-transform:none;font-weight:400;font-size:.8rem;color:var(--clr-accent)">
              Qu&#234;n m&#7853;t kh&#7849;u?
            </a>
          </label>
          <div class="input-icon-wrap">
            <i class="fa fa-lock icon"></i>
            <input type="password" id="password" name="password"
                   class="form-control ${not empty passwordError ? 'is-invalid' : ''}"
                   placeholder="&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;"
                   required autocomplete="current-password">
            <button type="button" class="toggle-pwd" onclick="togglePwd('password','toggleIcon1')" aria-label="Hi&#7879;n m&#7853;t kh&#7849;u">
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
            <label class="form-check-label" for="rememberMe">Ghi nh&#7899; &#273;&#259;ng nh&#7853;p trong 30 ng&#224;y</label>
          </div>
        </div>

        <button type="submit" class="btn btn-primary btn-block btn-lg" id="loginBtn">
          <i class="fa fa-right-to-bracket"></i> &#272;&#259;ng Nh&#7853;p
        </button>

      </form>

      <div class="divider fade-up fade-up-4">ho&#7863;c ti&#7871;p t&#7909;c v&#7899;i</div>

      <div style="display:flex;gap:10px" class="fade-up fade-up-4">
        <button type="button" class="btn btn-outline btn-block" onclick="window.location.href='https://accounts.google.com/o/oauth2/auth?scope=email%20profile&redirect_uri=http://localhost:9999/TourBuddy/google-callback&response_type=code&client_id=125212965450-ksqfbqjnltlv8nqbc3ok0gtetc5551gr.apps.googleusercontent.com'">
          <i class="fa-brands fa-google"></i> Google
        </button>
      </div>

      <div class="auth-footer-links">
        <a href="${pageContext.request.contextPath}/terms">&#272;i&#7873;u kho&#7843;n d&#7883;ch v&#7909;</a><span>&#183;</span>
        <a href="${pageContext.request.contextPath}/privacy">Ch&#237;nh s&#225;ch b&#7843;o m&#7853;t</a><span>&#183;</span>
        <a href="${pageContext.request.contextPath}/help">H&#7895; tr&#7907;</a>
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
  btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> \u0110ang x\u1eed l\u00fd...';
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


