<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>

<c:if test="${empty sessionScope.sessionUser
    || (sessionScope.sessionUser.role.roleName ne 'Staff'
    && sessionScope.sessionUser.role.roleName ne 'Admin')}">
    <c:redirect url="/login"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gửi Thông Báo — TourBuddy Staff</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=1.6">
    <style>
        :root {
            --primary: #2563EB; --primary-light: #EFF6FF;
            --success: #10B981; --success-light: #D1FAE5;
            --warning: #F59E0B; --warning-light: #FEF3C7;
            --danger: #EF4444;  --danger-light: #FEE2E2;
            --gray-50: #F8FAFC; --gray-100: #F1F5F9; --gray-200: #E2E8F0;
            --gray-500: #64748B; --gray-700: #334155; --gray-900: #0F172A;
        }
        body.dashboard-body { background: var(--gray-50); font-family: 'Inter', sans-serif; }

        .form-card {
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            border: 1px solid var(--gray-100);
            padding: 32px;
            max-width: 760px;
        }
        .form-group { margin-bottom: 20px; }
        .form-group label {
            display: block; font-size: 13px; font-weight: 600;
            color: var(--gray-700); margin-bottom: 8px;
        }
        .form-control {
            width: 100%; box-sizing: border-box;
            padding: 10px 14px; border: 1px solid var(--gray-200);
            border-radius: 8px; font-family: inherit; font-size: 14px;
            outline: none; transition: all .2s;
            background: var(--gray-50); color: var(--gray-900);
        }
        .form-control:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-light); background: #fff; }
        select.form-control { appearance: none; cursor: pointer; }
        textarea.form-control { resize: none; height: 130px; }
        select[multiple].form-control { height: 140px; }

        .btn-submit {
            background: var(--primary); color: white;
            border: none; padding: 12px 28px; border-radius: 10px;
            font-size: 15px; font-weight: 600; cursor: pointer;
            display: inline-flex; align-items: center; gap: 8px;
            transition: all .2s;
        }
        .btn-submit:hover { background: #1D4ED8; transform: translateY(-1px); box-shadow: 0 6px 14px rgba(37,99,235,.3); }

        .btn-secondary {
            background: white; color: var(--gray-700);
            border: 1px solid var(--gray-200); padding: 12px 20px;
            border-radius: 10px; font-size: 14px; font-weight: 600;
            cursor: pointer; text-decoration: none;
            display: inline-flex; align-items: center; gap: 6px;
            transition: all .2s;
        }
        .btn-secondary:hover { background: var(--gray-50); border-color: var(--gray-400); }

        .alert { padding: 14px 18px; margin-bottom: 20px; border-radius: 10px; font-size: 14px; font-weight: 500; display: flex; align-items: center; gap: 10px; }
        .alert-success { background: var(--success-light); color: #065F46; border: 1px solid #A7F3D0; }
        .alert-danger  { background: var(--danger-light);  color: #991B1B; border: 1px solid #FCA5A5; }
        .alert-warning { background: var(--warning-light); color: #92400E; border: 1px solid #FDE68A; }

        .form-hint { font-size: 12px; color: var(--gray-500); margin-top: 5px; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
    </style>
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <c:set var="activePage" value="staff-notification" scope="request"/>
    <%@ include file="/admin/staff-sidebar.jsp" %>

    <main class="main-content">
        <div class="content-area" style="padding: 28px 36px;">
            <div class="page-header" style="margin-bottom: 28px; display: flex; align-items: center; justify-content: space-between;">
                <div>
                    <h1 style="margin:0;font-size:24px;font-weight:700;color:var(--gray-900);">Gửi Thông Báo</h1>
                    <p style="margin:4px 0 0;color:var(--gray-500);font-size:14px;">Gửi thông báo in-app hoặc email đến khách hàng</p>
                </div>
                <a href="${pageContext.request.contextPath}/staff/bookings" class="btn-secondary">
                    <i data-lucide="arrow-left" style="width:15px;height:15px;"></i> Quay lại Booking
                </a>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger"><i data-lucide="x-circle" style="width:16px;height:16px;flex-shrink:0;"></i> ${error}</div>
            </c:if>
            <c:if test="${not empty success}">
                <div class="alert alert-success"><i data-lucide="check-circle" style="width:16px;height:16px;flex-shrink:0;"></i> ${success}</div>
            </c:if>
            <c:if test="${not empty warning}">
                <div class="alert alert-warning"><i data-lucide="alert-triangle" style="width:16px;height:16px;flex-shrink:0;"></i> ${warning}</div>
            </c:if>

            <div class="form-card">
                <form action="${pageContext.request.contextPath}/staff/send-notification" method="POST">

                    <div class="form-group">
                        <label for="userIds">Chọn Khách Hàng</label>
                        <select name="userIds" id="userIds" multiple required class="form-control">
                            <c:forEach var="customer" items="${customers}">
                                <option value="${customer.userId}">${customer.fullName} (${customer.email})</option>
                            </c:forEach>
                        </select>
                        <p class="form-hint">Giữ <kbd>Ctrl</kbd> (hoặc <kbd>⌘</kbd> trên Mac) để chọn nhiều khách hàng.</p>
                    </div>

                    <div class="form-group">
                        <label for="title">Tiêu Đề Thông Báo *</label>
                        <input type="text" name="title" id="title" required class="form-control" placeholder="Nhập tiêu đề thông báo...">
                    </div>

                    <div class="form-group">
                        <label for="content">Nội Dung *</label>
                        <textarea name="content" id="content" required class="form-control" placeholder="Nhập nội dung thông báo..."></textarea>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="category">Thể Loại</label>
                            <select name="category" id="category" required class="form-control">
                                <option value="System Announcement">Thông báo hệ thống</option>
                                <option value="Booking">Đặt chỗ</option>
                                <option value="Payment">Thanh toán</option>
                                <option value="Tour Update">Cập nhật Tour</option>
                                <option value="Promotion">Khuyến mãi</option>
                                <option value="Account Activity">Hoạt động tài khoản</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="channel">Kênh Gửi</label>
                            <select name="channel" id="channel" required class="form-control">
                                <option value="SYSTEM">Chỉ Hệ Thống</option>
                                <option value="EMAIL">Chỉ Email</option>
                                <option value="BOTH" selected>Hệ Thống &amp; Email</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="scheduledAt">Lên Lịch Gửi <span style="font-weight:400;color:var(--gray-500);">(để trống nếu muốn gửi ngay)</span></label>
                        <input type="datetime-local" name="scheduledAt" id="scheduledAt" class="form-control">
                    </div>

                    <div style="display:flex;gap:12px;margin-top:8px;">
                        <button type="submit" class="btn-submit">
                            <i data-lucide="send" style="width:16px;height:16px;"></i> Gửi Thông Báo
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>
</div>

<script>lucide.createIcons();</script>
</body>
</html>
