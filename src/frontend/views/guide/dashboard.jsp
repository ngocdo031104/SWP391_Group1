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
        
        /* CSS status styles */
        .status-preparing { background-color: rgba(243, 156, 18, 0.15); color: #d68910; }
        .status-scheduled { background-color: rgba(52, 152, 219, 0.15); color: #2980b9; }
        .status-inprogress { background-color: rgba(155, 89, 182, 0.15); color: #8e44ad; }
        .status-completed { background-color: rgba(39, 174, 96, 0.15); color: #229954; }
        .status-cancelled { background-color: rgba(231, 76, 60, 0.15); color: #c0392b; }
        .status-default { background-color: rgba(127, 140, 141, 0.15); color: #7f8c8d; }

        /* Operation Update Buttons */
        .btn-update-status {
            background-color: #f1f5f9;
            color: #475569;
            border: 1px solid #cbd5e1;
            padding: 6px 12px;
            border-radius: 6px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-family: 'Outfit', sans-serif;
            font-size: 0.85rem;
        }

        .btn-update-status:hover {
            background-color: #2563eb;
            color: #ffffff;
            border-color: #2563eb;
        }

        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.4);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }

        .modal.active {
            display: flex;
        }

        .modal-content {
            background: #ffffff;
            padding: 24px;
            border-radius: 12px;
            width: 100%;
            max-width: 480px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
            animation: slideDown 0.3s ease;
            position: relative;
        }

        @keyframes slideDown {
            from { transform: translateY(-20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 12px;
        }

        .modal-header h4 {
            margin: 0;
            font-size: 1.2rem;
            color: #1e293b;
            font-family: 'Outfit', sans-serif;
            font-weight: 700;
        }

        .modal-close {
            background: none;
            border: none;
            font-size: 1.5rem;
            color: #94a3b8;
            cursor: pointer;
            transition: color 0.2s;
        }

        .modal-close:hover {
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

        .form-select, .form-textarea {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            outline: none;
            font-family: 'Inter', sans-serif;
            font-size: 0.9rem;
            transition: border-color 0.2s;
        }

        .form-select:focus, .form-textarea:focus {
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

<nav class="navbar">
  <a href="${pageContext.request.contextPath}/home" class="logo" id="nav-logo">
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
                                    <th style="text-align: center; width: 320px;">Hành Động</th>
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
                                            <c:set var="tourStatus" value="${assignment.schedule.status}" />
                                            <c:choose>
                                                <c:when test="${tourStatus == 'Preparing'}">
                                                    <span class="status-badge status-preparing">Chuẩn bị</span>
                                                </c:when>
                                                <c:when test="${tourStatus == 'Scheduled'}">
                                                    <span class="status-badge status-scheduled">Đã lên lịch</span>
                                                </c:when>
                                                <c:when test="${tourStatus == 'InProgress'}">
                                                    <span class="status-badge status-inprogress">Đang đi</span>
                                                </c:when>
                                                <c:when test="${tourStatus == 'Completed'}">
                                                    <span class="status-badge status-completed">Hoàn thành</span>
                                                </c:when>
                                                <c:when test="${tourStatus == 'Cancelled'}">
                                                    <span class="status-badge status-cancelled">Đã hủy</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge status-default"><c:out value="${empty tourStatus ? 'Chuẩn bị' : tourStatus}" /></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: center; display: flex; gap: 8px; justify-content: center; align-items: center; height: 100%; padding-top: 12px; padding-bottom: 12px;">
                                            <a href="${pageContext.request.contextPath}/guide/dashboard?action=participants&scheduleId=${assignment.schedule.scheduleId}" class="btn btn-outline btn-sm" style="padding: 6px 12px; font-size: 0.85rem; font-weight: 600;">
                                                <i class="fa fa-users"></i> Danh sách đoàn
                                            </a>
                                            <a href="${pageContext.request.contextPath}/guide/dashboard?action=incidents&scheduleId=${assignment.schedule.scheduleId}" class="btn btn-outline btn-sm" style="padding: 6px 12px; font-size: 0.85rem; font-weight: 600; border-color: #ef4444; color: #ef4444; background-color: transparent;">
                                                <i class="fa fa-triangle-exclamation"></i> Sự cố
                                            </a>
                                            <a href="${pageContext.request.contextPath}/guide/dashboard?action=operationLogs&scheduleId=${assignment.schedule.scheduleId}" class="btn btn-outline btn-sm" style="padding: 6px 12px; font-size: 0.85rem; font-weight: 600; border-color: #64748b; color: #64748b; background-color: transparent;">
                                                <i class="fa fa-clock-rotate-left"></i> Nhật ký
                                            </a>
                                            <button class="btn-update-status" onclick="openStatusModal(${assignment.schedule.scheduleId}, '${tourStatus}')">
                                                <i class="fa fa-edit"></i> Trạng thái
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

<!-- Modal cập nhật trạng thái -->
<div class="modal" id="status-modal">
    <div class="modal-content">
        <div class="modal-header">
            <h4>Cập nhật tiến độ Tour</h4>
            <button class="modal-close" onclick="closeStatusModal()">&times;</button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="modal-schedule-id">
            
            <div class="form-group">
                <label for="modal-status-select">Trạng thái vận hành *</label>
                <select id="modal-status-select" class="form-select">
                    <option value="Preparing">Preparing (Chuẩn bị)</option>
                    <option value="Scheduled">Scheduled (Đã lên lịch)</option>
                    <option value="InProgress">InProgress (Đang đi)</option>
                    <option value="Completed">Completed (Hoàn thành)</option>
                    <option value="Cancelled">Cancelled (Đã hủy)</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="modal-notes-textarea">Ghi chú vận hành / Lý do</label>
                <textarea id="modal-notes-textarea" class="form-textarea" rows="4" placeholder="Nhập diễn biến sự cố, lý do hủy đoàn hoặc ghi chú hoạt động..."></textarea>
            </div>
            
            <div class="form-actions">
                <button class="btn btn-outline btn-sm" onclick="closeStatusModal()" style="font-weight: 600;">Hủy bỏ</button>
                <button class="btn btn-primary btn-sm" onclick="submitStatusUpdate()" style="font-weight: 600;">Xác nhận</button>
            </div>
        </div>
    </div>
</div>

<script>
    function openStatusModal(scheduleId, currentStatus) {
        document.getElementById('modal-schedule-id').value = scheduleId;
        document.getElementById('modal-status-select').value = currentStatus || 'Preparing';
        document.getElementById('modal-notes-textarea').value = '';
        document.getElementById('status-modal').classList.add('active');
    }

    function closeStatusModal() {
        document.getElementById('status-modal').classList.remove('active');
    }

    function submitStatusUpdate() {
        const scheduleId = document.getElementById('modal-schedule-id').value;
        const newStatus = document.getElementById('modal-status-select').value;
        const notes = document.getElementById('modal-notes-textarea').value;

        const params = new URLSearchParams();
        params.append("action", "updateStatus");
        params.append("scheduleId", scheduleId);
        params.append("newStatus", newStatus);
        params.append("notes", notes);

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
                closeStatusModal();
                window.location.reload();
            } else {
                alert(data.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert('Lỗi hệ thống khi cập nhật trạng thái!');
        });
    }
</script>

</body>
</html>