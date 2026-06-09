<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guide Dashboard — TourBuddy</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/tourbuddy.css?v=1.4">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .dashboard-wrapper { max-width: 1200px; margin: 100px auto 40px; padding: 0 20px; }
        .table-custom { width: 100%; border-collapse: collapse; margin-top: 15px; }
        .table-custom th, .table-custom td { padding: 14px 16px; border-bottom: 1px solid var(--clr-border); text-align: left; font-size: 0.95rem; }
        .table-custom th { background-color: rgba(0,0,0,0.02); font-weight: 600; color: var(--clr-text); }
        .table-custom tr:hover { background-color: rgba(0,0,0,0.01); }
        .status-badge { padding: 6px 12px; border-radius: 99px; font-size: 0.85rem; font-weight: 600; display: inline-block; text-align: center; }
        /* Cập nhật class css theo trạng thái chuẩn trong DB */
        .status-preparing { background-color: rgba(243, 156, 18, 0.15); color: #d68910; }
        .status-completed { background-color: rgba(39, 174, 96, 0.15); color: #229954; }
        .status-ongoing { background-color: rgba(41, 128, 185, 0.15); color: #2471a3; }
        .status-default { background-color: rgba(127, 140, 141, 0.15); color: #7f8c8d; }
    </style>
</head>
<body>

<nav class="navbar">
  <a href="#" class="logo" id="nav-logo">
    <div class="logo-icon">T</div>
    <span>TourBuddy (Guide)</span>
  </a>
  <div class="navbar-nav">
    <a href="${pageContext.request.contextPath}/guide/dashboard" class="active">Lịch Dẫn Đoàn</a>
    <a href="${pageContext.request.contextPath}/guide/profile">Hồ Sơ</a>
    <a href="${pageContext.request.contextPath}/logout" style="color:var(--clr-error)">
      <i class="fa fa-right-from-bracket"></i> Đăng xuất
    </a>
  </div>
</nav>

<div class="dashboard-wrapper">
    <div class="profile-header fade-up" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; padding: 20px 24px;">
        <div class="profile-info">
            <h2 style="font-size: 1.5rem; margin-bottom: 5px;">Xin chào, ${sessionScope.sessionUser.fullName}</h2>
            <p style="color: var(--clr-muted); font-size: 0.9rem;">Chào mừng bạn quay lại bảng điều khiển Hướng dẫn viên.</p>
        </div>
        <div class="profile-actions">
             <a href="${pageContext.request.contextPath}/guide/profile" class="role-badge" style="background: var(--clr-primary-l); color: var(--clr-primary); padding: 8px 16px; border-radius: 20px; font-weight: bold; text-decoration: none; display: inline-block; transition: 0.2s;"><i class="fa fa-id-badge"></i> Hướng Dẫn Viên</a>
        </div>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-error fade-up">
            <i class="fa fa-circle-exclamation"></i> ${errorMessage}
        </div>
    </c:if>

    <div class="card fade-up" style="animation-delay: 0.1s;">
        <div class="card-header">
            <h3><i class="fa fa-calendar-days" style="margin-right:8px;color:var(--clr-primary)"></i> Tour Đã Phân Công</h3>
        </div>
        <div class="card-body" style="padding: 0;">
            <c:choose>
                <c:when test="${empty assignments}">
                    <div class="empty-state" style="text-align:center; padding: 40px 20px;">
                        <i class="fa fa-box-open" style="font-size: 3rem; color: var(--clr-border); margin-bottom: 16px;"></i>
                        <p style="color: var(--clr-muted); font-size: 0.95rem;">Bạn chưa được phân công dẫn tour nào.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="overflow-x: auto;">
                        <table class="table-custom">
                            <thead>
                                <tr>
                                    <th>Tên Tour</th>
                                    <th>Điểm Đến</th>
                                    <th>Ngày Khởi Hành</th>
                                    <th>Ngày Về</th>
                                    <th>Trạng Thái Vận Hành</th>
                                    <th style="text-align: right; padding-right: 24px;">Hành Động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="assignment" items="${assignments}">
                                    <tr>
                                        <td style="font-weight: 500;"><c:out value="${assignment.schedule.tour.tourName}" /></td>
                                        <td><c:out value="${assignment.schedule.tour.destination}" /></td>
                                        <td><fmt:formatDate value="${assignment.schedule.departureDate}" pattern="dd/MM/yyyy" /></td>
                                        <td><fmt:formatDate value="${assignment.schedule.returnDate}" pattern="dd/MM/yyyy" /></td>
                                        <td>
                                            <%-- Đổi biến check trạng thái khớp với dữ liệu 'Preparing' / 'OnGoing' / 'Completed' từ DB --%>
                                            <c:set var="tourStatus" value="${assignment.schedule.status}" />
                                            <c:choose>
                                                <c:when test="${tourStatus == 'Preparing'}">
                                                    <span class="status-badge status-preparing">Sắp khởi hành</span>
                                                </c:when>
                                                <c:when test="${tourStatus == 'OnGoing'}">
                                                    <span class="status-badge status-ongoing">Đang diễn ra</span>
                                                </c:when>
                                                <c:when test="${tourStatus == 'Completed'}">
                                                    <span class="status-badge status-completed">Đã hoàn thành</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge status-default"><c:out value="${empty tourStatus ? 'Chưa bắt đầu' : tourStatus}" /></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: right; padding-right: 24px;">
                                            <%-- Sửa lại cách lấy ID lịch trình: assignment.schedule.scheduleId --%>
                                            <a href="${pageContext.request.contextPath}/guide/dashboard?action=participants&scheduleId=${assignment.schedule.scheduleId}" class="btn btn-outline btn-sm">
                                                <i class="fa fa-users"></i> Danh sách đoàn
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

</body>
</html>