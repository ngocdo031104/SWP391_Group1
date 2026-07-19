&#65279;<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>403 Forbidden - Truy C&#7853;p B&#7883; T&#7915; Ch&#7889;i</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #f8fafc; color: #334155; text-align: center; padding-top: 100px; }
        .error-code { font-size: 100px; font-weight: bold; color: #dc2626; margin: 0; line-height: 1; }
        .error-message { font-size: 24px; font-weight: 600; margin-top: 10px; }
        .error-desc { color: #64748b; margin-top: 10px; max-width: 500px; margin-left: auto; margin-right: auto; }
        .back-btn { display: inline-block; margin-top: 30px; background: #0f172a; color: white; padding: 10px 25px; text-decoration: none; border-radius: 6px; font-weight: 500; }
        .back-btn:hover { background: #1e293b; }
    </style>
</head>
<body>
    <h1 class="error-code">403</h1>
    <div class="error-message">TRUY C&#7852;P B&#7882; T&#7914; CH&#7888;I</div>
    <p class="error-desc">B&#7841;n kh&#244;ng c&#243; quy&#7873;n truy c&#7853;p v&#224;o ch&#7913;c n&#259;ng n&#224;y. Vui l&#242;ng li&#234;n h&#7879; Qu&#7843;n tr&#7883; vi&#234;n h&#7879; th&#7889;ng (Super Admin) n&#7871;u b&#7841;n cho r&#7857;ng &#273;&#226;y l&#224; m&#7897;t l&#7895;i.</p>
    <a href="${pageContext.request.contextPath}/home" class="back-btn">Quay V&#7873; Trang Ch&#7911;</a>
</body>
</html>
