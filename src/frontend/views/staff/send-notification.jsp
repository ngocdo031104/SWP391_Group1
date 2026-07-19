<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
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
    <title>G&#7917;i Th&#244;ng B&#225;o &#8212; TourBuddy Staff</title>
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
                    <h1 style="margin:0;font-size:24px;font-weight:700;color:var(--gray-900);">G&#7917;i Th&#244;ng B&#225;o</h1>
                    <p style="margin:4px 0 0;color:var(--gray-500);font-size:14px;">G&#7917;i th&#244;ng b&#225;o in-app ho&#7863;c email &#273;&#7871;n kh&#225;ch h&#224;ng</p>
                </div>
                <a href="${pageContext.request.contextPath}/staff/bookings" class="btn-secondary">
                    <i data-lucide="arrow-left" style="width:15px;height:15px;"></i> Quay l&#7841;i Booking
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
                        <label for="userIds">Ch&#7885;n Kh&#225;ch H&#224;ng</label>
                        <select name="userIds" id="userIds" multiple required class="form-control">
                            <c:forEach var="customer" items="${customers}">
                                <option value="${customer.userId}">${customer.fullName} (${customer.email})</option>
                            </c:forEach>
                        </select>
                        <p class="form-hint">Gi&#7919; <kbd>Ctrl</kbd> (ho&#7863;c <kbd>&#8984;</kbd> tr&#234;n Mac) &#273;&#7875; ch&#7885;n nhi&#7873;u kh&#225;ch h&#224;ng.</p>
                    </div>

                    <div class="form-group">
                        <label for="title">Ti&#234;u &#272;&#7873; Th&#244;ng B&#225;o *</label>
                        <input type="text" name="title" id="title" required class="form-control" placeholder="Nh&#7853;p ti&#234;u &#273;&#7873; th&#244;ng b&#225;o...">
                    </div>

                    <div class="form-group">
                        <label for="content">N&#7897;i Dung *</label>
                        <textarea name="content" id="content" required class="form-control" placeholder="Nh&#7853;p n&#7897;i dung th&#244;ng b&#225;o..."></textarea>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="category">Th&#7875; Lo&#7841;i</label>
                            <select name="category" id="category" required class="form-control">
                                <option value="System Announcement">Th&#244;ng b&#225;o h&#7879; th&#7889;ng</option>
                                <option value="Booking">&#272;&#7863;t ch&#7895;</option>
                                <option value="Payment">Thanh to&#225;n</option>
                                <option value="Tour Update">C&#7853;p nh&#7853;t Tour</option>
                                <option value="Promotion">Khuy&#7871;n m&#227;i</option>
                                <option value="Account Activity">Ho&#7841;t &#273;&#7897;ng t&#224;i kho&#7843;n</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="channel">K&#234;nh G&#7917;i</label>
                            <select name="channel" id="channel" required class="form-control">
                                <option value="SYSTEM">Ch&#7881; H&#7879; Th&#7889;ng</option>
                                <option value="EMAIL">Ch&#7881; Email</option>
                                <option value="BOTH" selected>H&#7879; Th&#7889;ng &amp; Email</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="scheduledAt">L&#234;n L&#7883;ch G&#7917;i <span style="font-weight:400;color:var(--gray-500);">(&#273;&#7875; tr&#7889;ng n&#7871;u mu&#7889;n g&#7917;i ngay)</span></label>
                        <input type="datetime-local" name="scheduledAt" id="scheduledAt" class="form-control">
                    </div>

                    <div style="display:flex;gap:12px;margin-top:8px;">
                        <button type="submit" class="btn-submit">
                            <i data-lucide="send" style="width:16px;height:16px;"></i> G&#7917;i Th&#244;ng B&#225;o
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
