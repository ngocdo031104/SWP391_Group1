<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Gửi Thông Báo - Staff Dashboard</title>
    <!-- Include Bootstrap or CSS framework here. I'm using generic styles to ensure it looks okay -->
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #f4f7f6; margin: 0; padding: 20px; }
        .container { max-width: 800px; margin: auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        h1 { color: #1E7D4B; text-align: center; }
        .form-group { margin-bottom: 20px; }
        label { display: block; font-weight: bold; margin-bottom: 5px; }
        input[type="text"], input[type="datetime-local"], select, textarea { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 5px; box-sizing: border-box; }
        textarea { resize: vertical; height: 150px; }
        select[multiple] { height: 150px; }
        .btn-submit { background-color: #1E7D4B; color: white; border: none; padding: 12px 20px; cursor: pointer; border-radius: 5px; font-size: 16px; width: 100%; }
        .btn-submit:hover { background-color: #145A32; }
        .alert { padding: 15px; margin-bottom: 20px; border-radius: 5px; }
        .alert-success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-danger { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .alert-warning { background-color: #fff3cd; color: #856404; border: 1px solid #ffeeba; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Gửi Thông Báo Khách Hàng</h1>
        
        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>
        <c:if test="${not empty success}">
            <div class="alert alert-success">${success}</div>
        </c:if>
        <c:if test="${not empty warning}">
            <div class="alert alert-warning">${warning}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/staff/send-notification" method="POST">
            <div class="form-group">
                <label for="userIds">Chọn Khách Hàng (giữ Ctrl để chọn nhiều):</label>
                <select name="userIds" id="userIds" multiple required>
                    <c:forEach var="customer" items="${customers}">
                        <option value="${customer.userId}">${customer.fullName} (${customer.email})</option>
                    </c:forEach>
                </select>
            </div>
            
            <div class="form-group">
                <label for="title">Tiêu đề thông báo:</label>
                <input type="text" name="title" id="title" required placeholder="Nhập tiêu đề...">
            </div>
            
            <div class="form-group">
                <label for="content">Nội dung:</label>
                <textarea name="content" id="content" required placeholder="Nhập nội dung thông báo..."></textarea>
            </div>
            
            <div class="form-group">
                <label for="category">Thể loại:</label>
                <select name="category" id="category" required>
                    <option value="System Announcement">Thông báo hệ thống</option>
                    <option value="Booking">Đặt chỗ</option>
                    <option value="Payment">Thanh toán</option>
                    <option value="Tour Update">Cập nhật Tour</option>
                    <option value="Promotion">Khuyến mãi</option>
                    <option value="Account Activity">Hoạt động tài khoản</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="channel">Kênh gửi:</label>
                <select name="channel" id="channel" required>
                    <option value="SYSTEM">Chỉ Hệ Thống</option>
                    <option value="EMAIL">Chỉ Email</option>
                    <option value="BOTH" selected>Hệ Thống & Email</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="scheduledAt">Lên lịch gửi (để trống nếu muốn gửi ngay):</label>
                <input type="datetime-local" name="scheduledAt" id="scheduledAt">
            </div>
            
            <button type="submit" class="btn-submit">Gửi Thông Báo</button>
        </form>
        
        <div style="margin-top: 20px; text-align: center;">
            <a href="${pageContext.request.contextPath}/" style="color: #666; text-decoration: none;">&larr; Quay lại trang chủ</a>
        </div>
    </div>
</body>
</html>
