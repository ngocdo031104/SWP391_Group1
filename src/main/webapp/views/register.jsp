<%-- 
    Document   : register.jsp
    Purpose    : Trang đăng ký tài khoản cho người dùng mới (Customer). Cung cấp form nhập liệu có xác thực phía client.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Đăng Ký — TourBuddy</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/tourbuddy.css?v=1.4">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <style>
    /* Password strength indicator */
    .strength-bar { display: flex; gap: 4px; margin-top: 8px; }
    .strength-seg {
      flex: 1; height: 4px; border-radius: 99px;
      background: var(--clr-border); transition: background .3s;
    }
    .strength-label { font-size: .75rem; margin-top: 4px; color: var(--clr-muted); }

    /* Step indicator */
    .step-indicator {
      display: flex; align-items: center; gap: 0;
      margin-bottom: 28px;
    }
    .step-dot {
      width: 30px; height: 30px; border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      font-size: .8rem; font-weight: 600;
      background: var(--clr-border); color: var(--clr-muted);
      transition: all .3s; flex-shrink: 0;
    }
    .step-dot.active { background: var(--clr-primary); color: #fff; }
    .step-dot.done   { background: var(--clr-success);  color: #fff; }
    .step-line { flex: 1; height: 2px; background: var(--clr-border); }
    .step-line.done { background: var(--clr-success); }
    .step-name { font-size: .72rem; color: var(--clr-muted); text-align: center; margin-top: 4px; }

    .step-block { display: none; }
    .step-block.active { display: block; }

    /* Role cards */
    .role-cards { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 8px; }
    .role-card {
      border: 1.5px solid var(--clr-border); border-radius: var(--radius-md);
      padding: 16px 14px; text-align: center; cursor: pointer;
      transition: all var(--transition);
    }
    .role-card input { display: none; }
    .role-card:has(input:checked),
    .role-card.selected {
      border-color: var(--clr-primary);
      background: var(--clr-primary-l);
    }
    .role-card i { font-size: 1.6rem; color: var(--clr-primary); margin-bottom: 8px; display: block; }
    .role-card strong { display: block; font-size: .875rem; color: var(--clr-text); }
    .role-card span   { font-size: .75rem; color: var(--clr-muted); }
  </style>
</head>
<body>

<nav class="navbar">
  <a href="${pageContext.request.contextPath}/home" class="logo" id="nav-logo">
    <div class="logo-icon">T</div>
    <span>TourBuddy</span>
  </a>
  <div class="navbar-nav">
    <a href="${pageContext.request.contextPath}/home">Trang Chủ</a>
    <a href="${pageContext.request.contextPath}/login">Đăng Nhập</a>
    <a href="${pageContext.request.contextPath}/register" class="active">Đăng Ký</a>
  </div>
</nav>

<div class="auth-wrapper" style="padding-top:68px">

  <!-- Left Hero -->
  <div class="auth-hero">
    <div class="auth-hero-content">
      <h1>Tham gia cộng đồng <em>du lịch</em></h1>
      <p>Tạo tài khoản miễn phí, kết nối với bạn đồng hành và đặt tour chỉ trong vài phút.</p>
      <div class="auth-hero-badges">
        <span><i class="fa fa-shield-halved"></i> Thanh toán an toàn</span>
        <span><i class="fa fa-headset"></i> Hỗ trợ 24/7</span>
        <span><i class="fa fa-ticket"></i> Hoàn tiền dễ dàng</span>
      </div>
    </div>
  </div>

  <!-- Right Panel -->
  <div class="auth-panel" style="align-items:flex-start;padding-top:52px">
    <div class="auth-form-wrap fade-up" style="max-width:460px">

      <h2 class="auth-title fade-up fade-up-1">Tạo tài khoản</h2>
      <p class="auth-subtitle fade-up fade-up-2">
        Đã có tài khoản? <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
      </p>

      <c:if test="${not empty errorMessage}">
        <div class="alert alert-error">
          <i class="fa fa-circle-exclamation"></i> ${errorMessage}
        </div>
      </c:if>

      <!-- Step Indicator -->
      <div class="step-indicator fade-up fade-up-2">
        <div>
          <div class="step-dot active" id="sd1">1</div>
          <div class="step-name">Tài khoản</div>
        </div>
        <div class="step-line" id="sl1"></div>
        <div>
          <div class="step-dot" id="sd2">2</div>
          <div class="step-name">Thông tin</div>
        </div>
        <div class="step-line" id="sl2"></div>
        <div>
          <div class="step-dot" id="sd3">3</div>
          <div class="step-name">Xác nhận</div>
        </div>
      </div>

      <form action="${pageContext.request.contextPath}/register"
      method="post"
      id="regForm">

        <!-- STEP 1: Account -->
        <div class="step-block active fade-up fade-up-3" id="step1">

          <div class="form-group">
            <label class="form-label" for="email">Email *</label>
            <div class="input-icon-wrap">
              <i class="fa fa-envelope icon"></i>
              <input type="email" id="email" name="email"
                     class="form-control ${not empty emailError ? 'is-invalid' : ''}"
                     placeholder="you@example.com"
                     value="${not empty param.email ? param.email : ''}"
                     required autocomplete="email">
            </div>
            <c:if test="${not empty emailError}">
              <span class="form-error">${emailError}</span>
            </c:if>
          </div>

          <div class="form-group">
            <label class="form-label" for="password">Mật khẩu *</label>
            <div class="input-icon-wrap">
              <i class="fa fa-lock icon"></i>
              <input type="password" id="password" name="password"
                     class="form-control ${not empty passwordError ? 'is-invalid' : ''}"
                     placeholder="Tối thiểu 8 ký tự"
                     required minlength="8" autocomplete="new-password"
                     oninput="checkStrength(this.value)">
              <button type="button" class="toggle-pwd"
                      onclick="togglePwd('password','ti1')"><i id="ti1" class="fa fa-eye"></i></button>
            </div>
            <!-- Strength bar -->
            <div class="strength-bar">
              <div class="strength-seg" id="seg1"></div>
              <div class="strength-seg" id="seg2"></div>
              <div class="strength-seg" id="seg3"></div>
              <div class="strength-seg" id="seg4"></div>
            </div>
            <div class="strength-label" id="strengthLabel">Nhập mật khẩu để kiểm tra độ mạnh</div>
            <span class="form-error" id="pwdError" style="display:none; margin-top:4px;"></span>
          </div>

          <div class="form-group">
            <label class="form-label" for="confirmPassword">Xác nhận mật khẩu *</label>
            <div class="input-icon-wrap">
              <i class="fa fa-lock icon"></i>
              <input type="password" id="confirmPassword" name="confirmPassword"
                     class="form-control"
                     placeholder="Nhập lại mật khẩu"
                     required autocomplete="new-password">
              <button type="button" class="toggle-pwd"
                      onclick="togglePwd('confirmPassword','ti2')"><i id="ti2" class="fa fa-eye"></i></button>
            </div>
            <span class="form-error" id="confirmError" style="display:none">Mật khẩu không khớp</span>
          </div>

          <button type="button" class="btn btn-primary btn-block" onclick="nextStep(1)">
            Tiếp theo <i class="fa fa-arrow-right"></i>
          </button>
        </div>

        <!-- STEP 2: Personal Info -->
        <div class="step-block" id="step2">

          <div class="form-grid">
            <div class="form-group">
              <label class="form-label" for="fullName">Họ và tên *</label>
              <div class="input-icon-wrap">
                <i class="fa fa-user icon"></i>
                <input type="text" id="fullName" name="fullName"
                       class="form-control ${not empty nameError ? 'is-invalid' : ''}"
                       placeholder="Nguyễn Văn A"
                       value="${not empty param.fullName ? param.fullName : ''}"
                       required maxlength="100">
              </div>
            </div>
            <div class="form-group">
              <label class="form-label" for="phone">Số điện thoại</label>
              <div class="input-icon-wrap">
                <i class="fa fa-phone icon"></i>
                <input type="tel" id="phone" name="phone"
       class="form-control ${not empty phoneError ? 'is-invalid' : ''}"
       placeholder="09xxxxxxxx"
       value="${not empty param.phone ? param.phone : ''}"
       required
       pattern="0[0-9]{9}"
       maxlength="10">
                <c:if test="${not empty phoneError}">
    <span class="form-error">${phoneError}</span>
</c:if>
              </div>
            </div>
            <div class="form-group">
              <label class="form-label" for="dob">Ngày sinh</label>
              <div class="input-icon-wrap">
                <i class="fa fa-calendar icon"></i>
                <input type="date" id="dob" name="dob"
       class="form-control ${not empty dobError ? 'is-invalid' : ''}"
       value="${not empty param.dob ? param.dob : ''}"
       required>
                <c:if test="${not empty dobError}">
    <span class="form-error">${dobError}</span>
</c:if>
              </div>
            </div>
            <div class="form-group">
              <label class="form-label" for="gender">Giới tính</label>
              <select id="gender"
        name="gender"
        class="form-control ${not empty genderError ? 'is-invalid' : ''}"
        required>
                  <c:if test="${not empty genderError}">
    <span class="form-error">${genderError}</span>
</c:if>
                <option value="">-- Chọn --</option>
                <option value="Male"   ${param.gender eq 'Male'   ? 'selected' : ''}>Nam</option>
                <option value="Female" ${param.gender eq 'Female' ? 'selected' : ''}>Nữ</option>
                <option value="Other"  ${param.gender eq 'Other'  ? 'selected' : ''}>Khác</option>
              </select>
            </div>
          </div>

          <div style="display:flex;gap:10px;margin-top:8px">
            <button type="button" class="btn btn-outline btn-block" onclick="prevStep(2)">
              <i class="fa fa-arrow-left"></i> Quay lại
            </button>
            <button type="button" class="btn btn-primary btn-block" onclick="nextStep(2)">
              Tiếp theo <i class="fa fa-arrow-right"></i>
            </button>
          </div>
        </div>

        <!-- STEP 3: Role -->
        <div class="step-block" id="step3">

          <input type="hidden" name="role" value="Customer">

          <div class="form-group">
            <div class="form-check">
              <input type="checkbox" id="agreeTerms" name="agreeTerms" required>
              <label class="form-check-label" for="agreeTerms">
                Tôi đồng ý với <a href="#">Điều khoản dịch vụ</a>
                và <a href="#">Chính sách bảo mật</a> của TourBuddy
              </label>
            </div>
            <span class="form-error" id="termsError" style="display:none">
              Vui lòng đồng ý điều khoản để tiếp tục
            </span>
          </div>

          <div style="display:flex;gap:10px">
            <button type="button" class="btn btn-outline btn-block" onclick="prevStep(3)">
              <i class="fa fa-arrow-left"></i> Quay lại
            </button>
            <button type="submit" class="btn btn-accent btn-block" id="submitBtn">
              <i class="fa fa-check-circle"></i> Tạo tài khoản
            </button>
          </div>
        </div>

      </form>

      <div class="auth-footer-links" style="margin-top:20px">
        <a href="#">Điều khoản dịch vụ</a><span>·</span>
        <a href="#">Bảo mật</a><span>·</span>
        <a href="#">Hỗ trợ</a>
      </div>

    </div>
  </div>
</div>

<script>
/* ── Step navigation ── */
let currentStep = 1;

function nextStep(from) {
  if (from === 1 && !validateStep1()) return;
  if (from === 2 && !validateStep2()) return;

  document.getElementById('step' + from).classList.remove('active');
  document.getElementById('sd' + from).classList.replace('active','done');
  document.getElementById('sd' + from).textContent = '✓';
  if (from < 3) document.getElementById('sl' + from).classList.add('done');

  currentStep = from + 1;
  document.getElementById('step' + currentStep).classList.add('active');
  document.getElementById('sd' + currentStep).classList.add('active');
}

function prevStep(from) {
  document.getElementById('step' + from).classList.remove('active');
  document.getElementById('sd' + from).classList.remove('active');

  currentStep = from - 1;
  const prev = document.getElementById('sd' + currentStep);
  prev.classList.remove('done');
  prev.classList.add('active');
  prev.textContent = currentStep;
  if (from > 1) document.getElementById('sl' + (from-1)).classList.remove('done');
  document.getElementById('step' + currentStep).classList.add('active');
}

/* ── Validation ── */
function validateStep1() {
  let ok = true;
  const email = document.getElementById('email');
  const pwd   = document.getElementById('password');
  const cpwd  = document.getElementById('confirmPassword');

  if (!email.value || !/\S+@\S+\.\S+/.test(email.value)) {
    email.classList.add('is-invalid'); ok = false;
  } else { email.classList.remove('is-invalid'); }

  if (!pwd.value || pwd.value.length < 8 || !/[A-Za-z]/.test(pwd.value) || !/[0-9]/.test(pwd.value)) {
    pwd.classList.add('is-invalid');
    const pwdErr = document.getElementById('pwdError');
    pwdErr.style.display = 'block';
    if (!pwd.value || pwd.value.length < 8) {
      pwdErr.textContent = 'Mật khẩu phải có ít nhất 8 ký tự';
    } else {
      pwdErr.textContent = 'Mật khẩu phải chứa ít nhất 1 chữ cái và 1 chữ số';
    }
    ok = false;
  } else { 
    pwd.classList.remove('is-invalid'); 
    document.getElementById('pwdError').style.display = 'none';
  }

  if (cpwd.value !== pwd.value) {
    cpwd.classList.add('is-invalid');
    document.getElementById('confirmError').style.display = 'block';
    ok = false;
  } else {
    cpwd.classList.remove('is-invalid');
    document.getElementById('confirmError').style.display = 'none';
  }
  return ok;
}

function validateStep2() {

    let ok = true;

    const name = document.getElementById('fullName');
    const phone = document.getElementById('phone');
    const dob = document.getElementById('dob');
    const gender = document.getElementById('gender');

    if (!name.value.trim() || name.value.trim().length < 2) {
        name.classList.add('is-invalid');
        ok = false;
    } else if (!/^[\p{L} .'-]+$/u.test(name.value.trim())) {
        name.classList.add('is-invalid');
        ok = false;
    } else {
        name.classList.remove('is-invalid');
    }

    if (!phone.value.trim()) {
        phone.classList.add('is-invalid');
        ok = false;
    } else if (!/^0\d{9}$/.test(phone.value)) {
        phone.classList.add('is-invalid');
        ok = false;
    } else {
        phone.classList.remove('is-invalid');
    }

    if (!dob.value) {
        dob.classList.add('is-invalid');
        ok = false;
    } else {
        dob.classList.remove('is-invalid');
    }

    if (!gender.value) {
        gender.classList.add('is-invalid');
        ok = false;
    } else {
        gender.classList.remove('is-invalid');
    }

    return ok;
}

/* ── Password strength ── */
function checkStrength(pwd) {
  const segs  = [1,2,3,4].map(i => document.getElementById('seg' + i));
  const label = document.getElementById('strengthLabel');
  const colors = ['#C0392B','#E67E22','#F1C40F','#1E7D4B'];
  const labels = ['Rất yếu','Yếu','Trung bình','Mạnh'];

  let score = 0;
  if (pwd.length >= 8)               score++;
  if (/[A-Z]/.test(pwd))             score++;
  if (/[0-9]/.test(pwd))             score++;
  if (/[^A-Za-z0-9]/.test(pwd))      score++;

  segs.forEach((s,i) => {
    s.style.background = i < score ? colors[Math.min(score-1,3)] : 'var(--clr-border)';
  });
  label.textContent = pwd.length ? labels[Math.min(score-1,3)] || 'Rất yếu' : 'Nhập mật khẩu để kiểm tra độ mạnh';
  label.style.color = score ? colors[Math.min(score-1,3)] : 'var(--clr-muted)';
}

/* ── Toggle password visibility ── */
function togglePwd(inputId, iconId) {
  const input = document.getElementById(inputId);
  const icon  = document.getElementById(iconId);
  input.type = input.type === 'password' ? 'text' : 'password';
  icon.classList.toggle('fa-eye');
  icon.classList.toggle('fa-eye-slash');
}

document.getElementById('dob').max = new Date().toISOString().split("T")[0];

/* ── Final submit ── */
document.getElementById('regForm').addEventListener('submit', function(e) {

    if (!validateStep1()) {
        e.preventDefault();
        return;
    }

    if (!validateStep2()) {
        e.preventDefault();
        return;
    }

    if (!document.getElementById('agreeTerms').checked) {
        document.getElementById('termsError').style.display = 'block';
        e.preventDefault();
        return;
    }

    document.getElementById('termsError').style.display = 'none';

    const btn = document.getElementById('submitBtn');
    setTimeout(() => {
        btn.disabled = true;
        btn.innerHTML =
            '<i class="fa fa-spinner fa-spin"></i> Đang tạo tài khoản...';
    }, 10);
});
</script>
</body>
</html>
