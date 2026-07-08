<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhật Ký Vận Hành Tour — TourBuddy</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/tourbuddy.css?v=1.4">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .dashboard-wrapper { max-width: 900px; margin: 100px auto 40px; padding: 0 20px; }
        .tour-info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; background: rgba(0,0,0,0.02); padding: 20px; border-radius: 8px; margin-bottom: 24px; border: 1px solid var(--clr-border); }
        .info-item { display: flex; flex-direction: column; }
        .info-label { font-size: 0.85rem; color: var(--clr-muted); margin-bottom: 4px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
        .info-value { font-size: 1.05rem; font-weight: 500; color: var(--clr-text); }

        /* Timeline Styles */
        .timeline-container { position: relative; padding-left: 32px; margin-top: 20px; font-family: 'Inter', sans-serif; }
        .timeline-container::before { content: ''; position: absolute; left: 15px; top: 0; bottom: 0; width: 2px; background-color: #cbd5e1; }
        
        .timeline-item { position: relative; margin-bottom: 28px; }
        .timeline-marker { position: absolute; left: -24px; top: 4px; width: 14px; height: 14px; border-radius: 50%; border: 3px solid #ffffff; background-color: #2563eb; box-shadow: 0 0 0 3px #bfdbfe; }
        .timeline-item:first-child .timeline-marker { background-color: #10b981; box-shadow: 0 0 0 3px #a7f3d0; }
        
        .timeline-content { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 16px; position: relative; }
        .timeline-time { font-size: 0.8rem; color: #64748b; font-weight: 600; margin-bottom: 6px; display: inline-flex; align-items: center; gap: 4px; }
        .timeline-activity { font-size: 0.95rem; font-weight: 500; color: #1e293b; margin-bottom: 6px; }
        .timeline-operator { font-size: 0.82rem; color: #475569; display: inline-flex; align-items: center; gap: 6px; }
        
        .role-badge { padding: 2px 6px; border-radius: 4px; font-size: 0.72rem; font-weight: 700; text-transform: uppercase; }
        .role-admin { background-color: #fee2e2; color: #dc2626; }
        .role-guide { background-color: #e0f2fe; color: #0369a1; }
        .role-staff { background-color: #fef3c7; color: #d97706; }
        .role-default { background-color: #f1f5f9; color: #64748b; }
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
        <div class="card-header">
            <h3><i class="fa fa-clock-rotate-left" style="margin-right:8px;color:var(--clr-primary)"></i> Nhật Ký Vận Hành Đoàn</h3>
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
                        <span class="info-value" style="font-weight:bold; color:var(--clr-primary)"><c:out value="${assignment.schedule.status}" /></span>
                    </div>
                </div>
            </c:if>

            <c:choose>
                <c:when test="${empty logs}">
                    <div class="empty-state" style="text-align:center; padding: 40px 20px;">
                        <i class="fa fa-timeline" style="font-size: 3rem; color: var(--clr-border); margin-bottom: 16px;"></i>
                        <p style="color: var(--clr-muted); font-size: 0.95rem;">Chuyến đi này hiện tại chưa có ghi nhận hoạt động nào.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="timeline-container">
                        <c:forEach var="log" items="${logs}">
                            <div class="timeline-item">
                                <div class="timeline-marker"></div>
                                <div class="timeline-content">
                                    <div class="timeline-time">
                                        <i class="fa-regular fa-clock"></i>
                                        <fmt:formatDate value="${log.createdAt}" pattern="HH:mm:ss - dd/MM/yyyy" />
                                    </div>
                                    <div class="timeline-activity">
                                        <c:out value="${log.activity}" />
                                    </div>
                                    <div class="timeline-operator">
                                        <i class="fa-regular fa-user"></i>
                                        <span>Người thực hiện: <strong><c:out value="${empty log.operatorName ? 'Hệ thống tự động' : log.operatorName}" /></strong></span>
                                        <c:if test="${not empty log.operatorRole}">
                                            <c:choose>
                                                <c:when test="${log.operatorRole == 'Admin'}">
                                                    <span class="role-badge role-admin">Quản trị viên</span>
                                                </c:when>
                                                <c:when test="${log.operatorRole == 'Guide'}">
                                                    <span class="role-badge role-guide">HDV</span>
                                                </c:when>
                                                <c:when test="${log.operatorRole == 'Staff'}">
                                                    <span class="role-badge role-staff">Nhân viên</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="role-badge role-default"><c:out value="${log.operatorRole}" /></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>

        </div>
    </div>
</div>

</body>
</html>
