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

            <!-- Check-in Progress Tracker -->
            <div style="background: #f8fafc; border: 1px solid #e2e8f0; padding: 16px 20px; border-radius: 8px; margin-bottom: 24px; font-family: 'Inter', sans-serif;">
                <div style="display: flex; justify-content: space-between; align-items: center; font-weight: 600; color: #334155; font-size: 0.95rem;">
                    <span>Tiến độ điểm danh đoàn:</span>
                    <span>
                        <span id="checked-in-count" style="color: #10b981; font-weight: 700;">${checkedInCount}</span> / <span id="total-count" style="font-weight: 700;">${totalCount}</span> khách hàng
                    </span>
                </div>
                <div style="background: #e2e8f0; border-radius: 9999px; height: 12px; margin-top: 10px; overflow: hidden; width: 100%;">
                    <div id="progress-bar" style="background: #10b981; height: 100%; transition: width 0.3s ease; width: ${totalCount > 0 ? (checkedInCount * 100 / totalCount) : 0}%;"></div>
                </div>
            </div>

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
                                    <th>Thông Tin Liên Hệ</th>
                                    <th style="width: 200px;">Trạng Thái</th>
                                    <th>Ghi Chú</th>
                                    <th style="width: 140px; text-align: center;">Hành Động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="p" items="${participants}" varStatus="status">
                                    <tr style="vertical-align: middle;">
                                        <td style="text-align: center; color: var(--clr-muted);">${status.count}</td>
                                        <td style="font-weight: 500;">
                                            <c:out value="${p.fullName}" />
                                            <c:if test="${p.isLeader}">
                                                <span class="badge-leader"><i class="fa fa-star"></i> Nhóm Trưởng</span>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${p.ageType == 'Adult'}">Người lớn</c:when>
                                                <c:when test="${p.ageType == 'Child'}">Trẻ em</c:when>
                                                <c:when test="${p.ageType == 'Infant'}">Trẻ nhỏ</c:when>
                                                <c:otherwise><c:out value="${p.ageType}" /></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div style="font-size: 0.9rem; color: #334155;"><i class="fa fa-phone" style="width:14px;color:#94a3b8;"></i> <c:out value="${p.phoneNumber}" /></div>
                                            <div style="font-size: 0.8rem; color: #64748b; margin-top: 2px;"><i class="fa fa-envelope" style="width:14px;color:#94a3b8;"></i> <c:out value="${p.email}" /></div>
                                        </td>
                                        
                                        <!-- Cột Trạng Thái -->
                                        <td id="status-cell-${p.participantId}">
                                            <c:choose>
                                                <c:when test="${p.checkedIn}">
                                                    <span class="badge-status checked-in" style="background: #d1fae5; color: #065f46; padding: 4px 8px; border-radius: 6px; font-size: 0.8rem; font-weight: bold; display: inline-flex; align-items: center; gap: 4px;">
                                                        <i class="fa fa-circle-check"></i> Đã check-in (<span class="checkin-time"><fmt:formatDate value="${p.checkInTime}" pattern="HH:mm dd/MM" /></span>)
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-status pending" style="background: #f1f5f9; color: #64748b; padding: 4px 8px; border-radius: 6px; font-size: 0.8rem; font-weight: bold; display: inline-flex; align-items: center; gap: 4px;">
                                                        <i class="fa-regular fa-clock"></i> Chưa điểm danh
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Cột Ghi Chú -->
                                        <td>
                                            <input type="text" class="input-notes" id="notes-${p.participantId}" value="<c:out value="${p.notes}" />" placeholder="Nhập ghi chú..." style="width: 100%; padding: 6px 10px; border: 1px solid #cbd5e1; border-radius: 6px; outline: none; font-size: 0.85rem;" onchange="saveNotes(${p.participantId})">
                                        </td>

                                        <!-- Cột Hành Động -->
                                        <td style="text-align: center;">
                                            <button class="btn btn-toggle-checkin" id="btn-checkin-${p.participantId}" data-id="${p.participantId}" data-checked="${p.checkedIn}" onclick="toggleCheckIn(${p.participantId})" style="padding: 6px 12px; border-radius: 6px; font-weight: bold; font-size: 0.85rem; cursor: pointer; border: none; transition: all 0.2s; background: ${p.checkedIn ? '#ef4444' : '#10b981'}; color: #ffffff; width: 110px;">
                                                <c:choose>
                                                    <c:when test="${p.checkedIn}">Hủy check-in</c:when>
                                                    <c:otherwise>Điểm danh</c:otherwise>
                                                </c:choose>
                                            </button>
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

<script>
    function toggleCheckIn(participantId) {
        const btn = document.getElementById(`btn-checkin-${participantId}`);
        const isChecked = btn.getAttribute("data-checked") === "true";
        const newChecked = !isChecked;
        const notes = document.getElementById(`notes-${participantId}`).value;
        const scheduleId = ${assignment.scheduleId};
        
        const params = new URLSearchParams();
        params.append("action", "checkin");
        params.append("scheduleId", scheduleId);
        params.append("participantId", participantId);
        params.append("checkedIn", newChecked);
        params.append("notes", notes);
        
        fetch(`${pageContext.request.contextPath}/guide/dashboard`, {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: params
        })
        .then(res => res.json())
        .then(data => {
            if (data.status === "success") {
                btn.setAttribute("data-checked", newChecked ? "true" : "false");
                btn.innerText = newChecked ? "Hủy check-in" : "Điểm danh";
                btn.style.background = newChecked ? "#ef4444" : "#10b981";
                
                const statusCell = document.getElementById(`status-cell-${participantId}`);
                if (newChecked) {
                    statusCell.innerHTML = `
                        <span class="badge-status checked-in" style="background: #d1fae5; color: #065f46; padding: 4px 8px; border-radius: 6px; font-size: 0.8rem; font-weight: bold; display: inline-flex; align-items: center; gap: 4px;">
                            <i class="fa fa-circle-check"></i> Đã check-in (` + data.checkInTime + `)
                        </span>
                    `;
                } else {
                    statusCell.innerHTML = `
                        <span class="badge-status pending" style="background: #f1f5f9; color: #64748b; padding: 4px 8px; border-radius: 6px; font-size: 0.8rem; font-weight: bold; display: inline-flex; align-items: center; gap: 4px;">
                            <i class="fa-regular fa-clock"></i> Chưa điểm danh
                        </span>
                    `;
                }
                updateProgress();
            } else {
                alert(data.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert("Lỗi kết nối khi thực hiện điểm danh!");
        });
    }

    function saveNotes(participantId) {
        const notes = document.getElementById(`notes-${participantId}`).value;
        const scheduleId = ${assignment.scheduleId};
        
        const params = new URLSearchParams();
        params.append("action", "updateNotes");
        params.append("scheduleId", scheduleId);
        params.append("participantId", participantId);
        params.append("notes", notes);
        
        fetch(`${pageContext.request.contextPath}/guide/dashboard`, {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: params
        })
        .then(res => res.json())
        .then(data => {
            if (data.status !== "success") {
                alert(data.message);
            }
        })
        .catch(err => {
            console.error(err);
        });
    }

    function updateProgress() {
        const buttons = document.querySelectorAll(".btn-toggle-checkin");
        let total = buttons.length;
        let checked = 0;
        buttons.forEach(btn => {
            if (btn.getAttribute("data-checked") === "true") {
                checked++;
            }
        });
        
        document.getElementById("checked-in-count").innerText = checked;
        document.getElementById("total-count").innerText = total;
        const pct = total > 0 ? (checked * 100 / total) : 0;
        document.getElementById("progress-bar").style.width = pct + "%";
    }
</script>

</body>
</html>
