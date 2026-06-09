<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh Sách Khách Hàng — TourBuddy</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/tourbuddy.css?v=1.4">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .dashboard-wrapper { max-width: 1200px; margin: 100px auto 40px; padding: 0 20px; }
        .tour-info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; background: rgba(0,0,0,0.02); padding: 20px; border-radius: 8px; margin-bottom: 20px; border: 1px solid var(--clr-border); }
        .info-item { display: flex; flex-direction: column; }
        .info-label { font-size: 0.85rem; color: var(--clr-muted); margin-bottom: 4px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
        .info-value { font-size: 1.05rem; font-weight: 500; color: var(--clr-text); }
        .table-custom { width: 100%; border-collapse: collapse; }
        .table-custom th, .table-custom td { padding: 14px 16px; border-bottom: 1px solid var(--clr-border); text-align: left; font-size: 0.95rem; }
        .table-custom th { background-color: rgba(0,0,0,0.02); font-weight: 600; color: var(--clr-text); }
        .table-custom tr:hover { background-color: rgba(0,0,0,0.01); }
        .badge-leader { background-color: rgba(231, 76, 60, 0.15); color: #e74c3c; padding: 4px 10px; border-radius: 99px; font-size: 0.8rem; font-weight: bold; margin-left: 8px; display: inline-flex; align-items: center; gap: 4px; }
    </style>
</head>
<body>

<!-- Navbar -->
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
    <div style="margin-bottom: 20px;">
        <a href="${pageContext.request.contextPath}/guide/dashboard" class="btn btn-outline btn-sm">
            <i class="fa fa-arrow-left"></i> Quay lại
        </a>
    </div>

    <div class="card fade-up">
        <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
            <h3><i class="fa fa-users" style="margin-right:8px;color:var(--clr-primary)"></i> Danh Sách Khách Hàng</h3>
        </div>
        <div class="card-body">
            
            <c:if test="${not empty assignment}">
                <div class="tour-info-grid">
                    <div class="info-item">
                        <span class="info-label">Tên Tour</span>
                        <span class="info-value"><c:out value="${assignment.schedule.tour.tourName}" /></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Điểm Đến</span>
                        <span class="info-value"><c:out value="${assignment.schedule.tour.destination}" /></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Ngày Khởi Hành</span>
                        <span class="info-value"><fmt:formatDate value="${assignment.schedule.departureDate}" pattern="dd/MM/yyyy" /></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Trạng Thái Tour</span>
                        <span class="info-value" style="font-weight:bold; color:var(--clr-primary)"><c:out value="${assignment.schedule.tourStatus}" /></span>
                    </div>
                </div>
            </c:if>

            <c:choose>
                <c:when test="${empty participants}">
                    <div class="empty-state" style="text-align:center; padding: 40px 20px;">
                        <i class="fa fa-clipboard-user" style="font-size: 3rem; color: var(--clr-border); margin-bottom: 16px;"></i>
                        <p style="color: var(--clr-muted); font-size: 0.95rem;">Hiện chưa có khách hàng nào được xác nhận cho chuyến đi này.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="overflow-x: auto; border: 1px solid var(--clr-border); border-radius: 8px;">
                        <table class="table-custom">
                            <thead>
                                <tr>
                                    <th style="width: 50px; text-align: center;">STT</th>
                                    <th>Họ và Tên</th>
                                    <th>Loại Khách</th>
                                    <th>Số Điện Thoại</th>
                                    <th>Email</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="participant" items="${participants}" varStatus="status">
                                    <tr>
                                        <td style="text-align: center; color: var(--clr-muted);">${status.count}</td>
                                        <td style="font-weight: 500;">
                                            <c:out value="${participant.fullName}" />
                                            <c:if test="${participant.isLeader}">
                                                <span class="badge-leader"><i class="fa fa-star"></i> Nhóm Trưởng</span>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${participant.ageType == 'Adult'}">Người lớn</c:when>
                                                <c:when test="${participant.ageType == 'Child'}">Trẻ em</c:when>
                                                <c:when test="${participant.ageType == 'Infant'}">Trẻ nhỏ</c:when>
                                                <c:otherwise><c:out value="${participant.ageType}" /></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><c:out value="${participant.phoneNumber}" /></td>
                                        <td><c:out value="${participant.email}" /></td>
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
