<%-- 
    Liên quan đến UCs: Register Account
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
    <title>X&#225;c th&#7921;c t&#224;i kho&#7843;n | TourBuddy</title>
    <!-- Thư viện icon FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Phông chữ Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --clr-primary: #1E7D4B;
            --clr-primary-dark: #155c36;
            --clr-accent: #E67E22;
            --clr-bg: #f8f9fa;
            --clr-card: #ffffff;
            --clr-text: #333333;
            --clr-muted: #6c757d;
            --clr-border: #e0e0e0;
            --clr-error: #dc3545;
            --clr-success: #28a745;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, rgba(30,125,75,0.1) 0%, rgba(230,126,34,0.1) 100%), var(--clr-bg);
            color: var(--clr-text);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .auth-container {
            width: 100%;
            max-width: 450px;
            padding: 20px;
        }

        .auth-card {
            background-color: var(--clr-card);
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
            padding: 40px 30px;
            text-align: center;
        }

        .auth-logo {
            font-size: 2rem;
            font-weight: 700;
            color: var(--clr-primary);
            text-decoration: none;
            display: inline-block;
            margin-bottom: 20px;
        }

        .auth-title {
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 10px;
        }

        .auth-desc {
            color: var(--clr-muted);
            font-size: 0.95rem;
            margin-bottom: 30px;
            line-height: 1.5;
        }

        .form-group {
            margin-bottom: 25px;
            text-align: left;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            font-size: 0.95rem;
        }

        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid var(--clr-border);
            border-radius: 8px;
            font-size: 1.2rem;
            text-align: center;
            letter-spacing: 5px;
            transition: all 0.3s;
        }

        .form-control:focus {
            border-color: var(--clr-primary);
            outline: none;
            box-shadow: 0 0 0 3px rgba(30,125,75,0.2);
        }

        .btn {
            display: inline-block;
            width: 100%;
            padding: 12px 20px;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }

        .btn-primary {
            background-color: var(--clr-primary);
            color: white;
        }

        .btn-primary:hover {
            background-color: var(--clr-primary-dark);
            transform: translateY(-2px);
        }

        .alert {
            padding: 12px 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 0.9rem;
            text-align: left;
        }

        .alert-error {
            background-color: rgba(220, 53, 69, 0.1);
            color: var(--clr-error);
            border: 1px solid rgba(220, 53, 69, 0.2);
        }
    </style>
</head>
<body>
    <div class="auth-container">
        <div class="auth-card">
            <a href="${pageContext.request.contextPath}/home" class="auth-logo">TourBuddy.</a>
            <h1 class="auth-title">X&#225;c th&#7921;c Email</h1>
            <p class="auth-desc">
                Ch&#250;ng t&#244;i &#273;&#227; g&#7917;i m&#7897;t m&#227; x&#225;c nh&#7853;n g&#7891;m 6 ch&#7919; s&#7889; &#273;&#7871;n email <strong>${sessionScope.verify_email}</strong>. 
                Vui l&#242;ng ki&#7875;m tra h&#7897;p th&#432; &#273;&#7871;n (ho&#7863;c th&#432; m&#7909;c Spam) v&#224; nh&#7853;p m&#227; v&#224;o b&#234;n d&#432;&#7899;i.
            </p>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-error">
                    <i class="fa fa-exclamation-circle"></i> ${errorMessage}
                </div>
            </c:if>

            <c:if test="${not empty sessionScope.emailError}">
                <div class="alert alert-error">
                    <i class="fa fa-exclamation-triangle"></i> L&#7895;i h&#7879; th&#7889;ng g&#7917;i mail: ${sessionScope.emailError}
                    <br><small>(Vui l&#242;ng ch&#7909;p l&#7841;i th&#244;ng b&#225;o n&#224;y g&#7917;i cho t&#244;i &#273;&#7875; t&#244;i kh&#7855;c ph&#7909;c!)</small>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/verify" method="POST">
                <div class="form-group">
                    <label class="form-label" for="otp">M&#227; x&#225;c nh&#7853;n (OTP)</label>
                    <input type="text" id="otp" name="otp" class="form-control" placeholder="123456" maxlength="6" required pattern="[0-9]{6}">
                </div>
                <button type="submit" class="btn btn-primary">X&#225;c th&#7921;c t&#224;i kho&#7843;n</button>
            </form>
        </div>
    </div>
</body>
</html>

