<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhật Ký Sự Cố — TourBuddy</title>
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

        /* Severity styling */
        .badge-severity { padding: 4px 8px; border-radius: 6px; font-size: 0.8rem; font-weight: bold; display: inline-flex; align-items: center; gap: 4px; }
        .severity-low { background: #e2e8f0; color: #475569; }
        .severity-medium { background: #fef3c7; color: #d97706; }
        .severity-high { background: #ffedd5; color: #ea580c; }
        .severity-critical { background: #fee2e2; color: #dc2626; }

        /* Status styling */
        .badge-status { padding: 4px 8px; border-radius: 6px; font-size: 0.8rem; font-weight: bold; display: inline-flex; align-items: center; gap: 4px; }
        .status-open { background: #fee2e2; color: #dc2626; }
        .status-inprogress { background: #e0f2fe; color: #0284c7; }
        .status-resolved { background: #d1fae5; color: #059669; }
        .status-closed { background: #f1f5f9; color: #64748b; }

        /* Incident Modal Styles */
        .incident-modal {
            display: none;
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.4);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }

        .incident-modal.active {
            display: flex;
        }

        .incident-modal-content {
            background: #ffffff;
            padding: 24px;
            border-radius: 12px;
            width: 100%;
            max-width: 500px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
            animation: slideDown 0.3s ease;
        }

        @keyframes slideDown {
            from { transform: translateY(-20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        .incident-modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 12px;
        }

        .incident-modal-header h4 {
            margin: 0;
            font-size: 1.2rem;
            color: #1e293b;
            font-family: 'Outfit', sans-serif;
            font-weight: 700;
        }

        .incident-modal-close {
            background: none;
            border: none;
            font-size: 1.5rem;
            color: #94a3b8;
            cursor: pointer;
        }

        .incident-modal-close:hover {
            color: #475569;
        }

        .form-group {
            margin-bottom: 16px;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .form-group label {
            font-weight: 600;
            color: #475569;
            font-size: 0.9rem;
        }

        .form-input, .form-select, .form-textarea {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            outline: none;
            font-family: 'Inter', sans-serif;
            font-size: 0.9rem;
        }

        .form-input:focus, .form-select:focus, .form-textarea:focus {
            border-color: #2563eb;
        }

        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            margin-top: 24px;
            border-top: 1px solid #e2e8f0;
            padding-top: 16px;
        }
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
    <div style="margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center;">
        <a href="${pageContext.request.contextPath}/guide/dashboard" class="btn btn-outline btn-sm">
            <i class="fa fa-arrow-left"></i> Quay lại
        </a>
        <button class="btn btn-primary btn-sm" onclick="openIncidentModal()" style="font-weight: 600;">
            <i class="fa fa-plus"></i> Báo Cáo Sự Cố Mới
        </button>
    </div>

    <div class="card fade-up">
        <div class="card-header">
            <h3><i class="fa fa-triangle-exclamation" style="margin-right:8px;color:var(--clr-primary)"></i> Nhật Ký Sự Cố Tour</h3>
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
                <c:when test="${empty incidents}">
                    <div class="empty-state" style="text-align:center; padding: 40px 20px;">
                        <i class="fa fa-shield" style="font-size: 3rem; color: var(--clr-border); margin-bottom: 16px;"></i>
                        <p style="color: var(--clr-muted); font-size: 0.95rem;">Chuyến đi này hiện tại chưa ghi nhận sự cố nào phát sinh.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="overflow-x: auto; border: 1px solid var(--clr-border); border-radius: 8px;">
                        <table class="table-custom">
                            <thead>
                                <tr>
                                    <th style="width: 80px; text-align: center;">Mã sự cố</th>
                                    <th>Tiêu Đề</th>
                                    <th>Thời Gian Báo Cáo</th>
                                    <th style="width: 140px;">Mức Độ</th>
                                    <th style="width: 140px;">Trạng Thái</th>
                                    <th>Mô Tả Chi Tiết</th>
                                    <th style="width: 140px; text-align: center;">Hành Động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="inc" items="${incidents}">
                                    <tr>
                                        <td style="text-align: center; color: var(--clr-muted); font-weight: bold;">#<c:out value="${inc.incidentId}" /></td>
                                        <td style="font-weight: 600; color: #1e293b;"><c:out value="${inc.title}" /></td>
                                        <td><fmt:formatDate value="${inc.createdAt}" pattern="HH:mm dd/MM/yyyy" /></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${inc.severity == 'Low'}">
                                                    <span class="badge-severity severity-low">Thấp</span>
                                                </c:when>
                                                <c:when test="${inc.severity == 'Medium'}">
                                                    <span class="badge-severity severity-medium">Trung bình</span>
                                                </c:when>
                                                <c:when test="${inc.severity == 'High'}">
                                                    <span class="badge-severity severity-high">Cao</span>
                                                </c:when>
                                                <c:when test="${inc.severity == 'Critical'}">
                                                    <span class="badge-severity severity-critical"><i class="fa fa-triangle-exclamation"></i> Nghiêm trọng</span>
                                                </c:when>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${inc.status == 'Open'}">
                                                    <span class="badge-status status-open">Đang mở</span>
                                                </c:when>
                                                <c:when test="${inc.status == 'InProgress'}">
                                                    <span class="badge-status status-inprogress">Đang xử lý</span>
                                                </c:when>
                                                <c:when test="${inc.status == 'Resolved'}">
                                                    <span class="badge-status status-resolved">Đã giải quyết</span>
                                                </c:when>
                                                <c:when test="${inc.status == 'Closed'}">
                                                    <span class="badge-status status-closed">Đã đóng</span>
                                                </c:when>
                                            </c:choose>
                                        </td>
                                        <td style="color: #475569; font-size: 0.9rem;"><c:out value="${inc.description}" /></td>
                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${inc.status == 'Open' || inc.status == 'InProgress'}">
                                                    <button class="btn btn-outline btn-sm" onclick="resolveIncident(${inc.incidentId})" style="padding: 6px 12px; font-size: 0.8rem; border-color: #10b981; color: #10b981; font-weight: bold; background: transparent; cursor: pointer;">
                                                        <i class="fa fa-check"></i> Giải quyết
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: #94a3b8; font-size: 0.85rem;"><i class="fa fa-circle-check"></i> Hoàn tất</span>
                                                </c:otherwise>
                                            </c:choose>
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

<!-- Modal báo cáo sự cố mới -->
<div class="incident-modal" id="incident-modal">
    <div class="incident-modal-content">
        <div class="incident-modal-header">
            <h4>Báo cáo sự cố mới</h4>
            <button class="incident-modal-close" onclick="closeIncidentModal()">&times;</button>
        </div>
        <div class="incident-modal-body">
            <div class="form-group">
                <label for="incident-title">Tiêu đề sự cố *</label>
                <input type="text" id="incident-title" class="form-input" placeholder="Ví dụ: Hỏng xe di chuyển, Khách đi lạc...">
            </div>

            <div class="form-group">
                <label for="incident-severity">Mức độ ảnh hưởng *</label>
                <select id="incident-severity" class="form-select">
                    <option value="Low">Low (Thấp - Không ảnh hưởng nhiều)</option>
                    <option value="Medium" selected>Medium (Trung bình - Ảnh hưởng lịch trình nhẹ)</option>
                    <option value="High">High (Cao - Cần can thiệp gấp)</option>
                    <option value="Critical">Critical (Nghiêm trọng - Nguy hiểm tính mạng/tài sản)</option>
                </select>
            </div>

            <div class="form-group">
                <label for="incident-desc">Mô tả chi tiết sự cố *</label>
                <textarea id="incident-desc" class="form-textarea" rows="4" placeholder="Mô tả diễn biến cụ thể, vị trí xảy ra, số người ảnh hưởng..."></textarea>
            </div>

            <div class="form-actions">
                <button class="btn btn-outline btn-sm" onclick="closeIncidentModal()" style="font-weight: 600;">Hủy bỏ</button>
                <button class="btn btn-primary btn-sm" onclick="submitIncident()" style="font-weight: 600;">Gửi báo cáo</button>
            </div>
        </div>
    </div>
</div>

<script>
    function openIncidentModal() {
        document.getElementById('incident-title').value = '';
        document.getElementById('incident-severity').value = 'Medium';
        document.getElementById('incident-desc').value = '';
        document.getElementById('incident-modal').classList.add('active');
    }

    function closeIncidentModal() {
        document.getElementById('incident-modal').classList.remove('active');
    }

    function submitIncident() {
        const title = document.getElementById('incident-title').value;
        const severity = document.getElementById('incident-severity').value;
        const description = document.getElementById('incident-desc').value;
        const scheduleId = ${assignment.scheduleId};

        if (!title.trim() || !description.trim()) {
            alert('Vui lòng điền đầy đủ tiêu đề và mô tả sự cố!');
            return;
        }

        const params = new URLSearchParams();
        params.append("action", "reportIncident");
        params.append("scheduleId", scheduleId);
        params.append("title", title);
        params.append("severity", severity);
        params.append("description", description);

        fetch('${pageContext.request.contextPath}/guide/dashboard', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: params
        })
        .then(res => res.json())
        .then(data => {
            if (data.status === 'success') {
                alert(data.message);
                closeIncidentModal();
                window.location.reload();
            } else {
                alert(data.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert('Lỗi hệ thống khi báo cáo sự cố!');
        });
    }

    function resolveIncident(incidentId) {
        if (!confirm('Bạn có chắc chắn muốn đánh dấu sự cố này đã được giải quyết?')) {
            return;
        }

        const params = new URLSearchParams();
        params.append("action", "updateIncidentStatus");
        params.append("incidentId", incidentId);
        params.append("status", "Resolved");

        fetch('${pageContext.request.contextPath}/guide/dashboard', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: params
        })
        .then(res => res.json())
        .then(data => {
            if (data.status === 'success') {
                alert(data.message);
                window.location.reload();
            } else {
                alert(data.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert('Lỗi hệ thống khi cập nhật trạng thái sự cố!');
        });
    }
</script>

</body>
</html>
