<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>403 Forbidden - Truy Cập Bị Từ Chối</title>
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
    <div class="error-message">TRUY CẬP BỊ TỪ CHỐI</div>
    <p class="error-desc">Bạn không có quyền truy cập vào chức năng này. Vui lòng liên hệ Quản trị viên hệ thống (Super Admin) nếu bạn cho rằng đây là một lỗi.</p>
    <a href="${pageContext.request.contextPath}/home" class="back-btn">Quay Về Trang Chủ</a>
</body>
</html>
