<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt"  prefix="fmt" %>
<c:if test="${empty sessionUser}">
    <c:redirect url="/login" />
</c:if>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhật Ký Phân Công HDV — TourBuddy Enterprise</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.1">
    <style>
        /* ── ASSIGNMENTS PAGE — SPACE GLASSMORPHISM THEME ── */
        .filter-section {
            background: rgba(22, 25, 50, 0.55);
            backdrop-filter: blur(14px);
            -webkit-backdrop-filter: blur(14px);
            border: 1px solid rgba(139, 92, 246, 0.2);
            padding: 16px 24px;
            border-radius: 14px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
            margin-bottom: 24px;
            display: flex; align-items: center;
            justify-content: space-between;
            gap: 16px; flex-wrap: wrap;
        }
        .search-container { position: relative; flex: 1; max-width: 400px; }
        .search-container i {
            position: absolute; left: 12px; top: 50%;
            transform: translateY(-50%); color: #707ea8; font-size: 1rem;
        }
        .search-input {
            width: 100%; padding: 10px 12px 10px 38px;
            background: rgba(255,255,255,0.04);
            border: 1px solid rgba(139,92,246,0.25);
            border-radius: 8px; outline: none;
            font-family: 'Inter', sans-serif; font-size: 0.9rem;
            transition: all 0.2s; color: #f8fafc;
        }
        .search-input:focus { border-color: #8b5cf6; box-shadow: 0 0 0 3px rgba(139,92,246,0.2); }
        .search-input::placeholder { color: #707ea8; }

        .badge-operation {
            background: rgba(34,211,238,0.15); color: #22d3ee;
            border: 1px solid rgba(34,211,238,0.25);
            font-weight: 600; padding: 4px 8px;
            border-radius: 6px; font-size: 0.75rem; display: inline-block;
        }
        .notes-text { max-width: 250px; word-wrap: break-word; font-style: italic; color: #9fa9cb; }

        .btn-unassign-guide {
            background: rgba(239,68,68,0.12); color: #f87171;
            border: 1px solid rgba(239,68,68,0.3);
            padding: 6px 12px; border-radius: 6px; font-weight: 600;
            cursor: pointer; transition: all 0.2s;
            display: inline-flex; align-items: center; gap: 4px;
            font-family: 'Outfit', sans-serif; font-size: 0.8rem;
        }
        .btn-unassign-guide:hover { background: rgba(239,68,68,0.25); color: #fca5a5; }

        .pagination-container {
            display: flex; align-items: center; justify-content: space-between;
            margin-top: 24px; padding-top: 16px;
            border-top: 1px solid rgba(139,92,246,0.15);
            flex-wrap: wrap; gap: 16px;
        }
        .pagination-info { color: #9fa9cb; font-size: 0.85rem; }
        .pagination-buttons { display: flex; gap: 6px; }
        .page-link {
            padding: 8px 14px; border: 1px solid rgba(139,92,246,0.2);
            border-radius: 6px; color: #9fa9cb; font-weight: 600; font-size: 0.85rem;
            text-decoration: none; background: rgba(255,255,255,0.03); transition: all 0.2s;
        }
        .page-link:hover { border-color: rgba(95,59,246,0.5); color: #f8fafc; background: rgba(95,59,246,0.15); }
        .page-link.active { background: linear-gradient(135deg,#5f3bf6,#8b5cf6); color: #fff; border-color: transparent; box-shadow: 0 4px 12px rgba(95,59,246,0.4); }
        .page-link.disabled { pointer-events: none; color: #4a5578; background: rgba(255,255,255,0.02); border-color: rgba(139,92,246,0.1); }
    </style>
    <script>window.contextPath = '${pageContext.request.contextPath}';</script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-space-overrides.css?v=1.0">
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <!-- ── Left Sidebar ── -->
    <c:set var="activePage" value="assignments" scope="request" />
    <jsp:include page="sidebar.jsp" />

    <!-- ── Main Content Area ── -->
    <main class="main-content">
        <!-- Top Header -->
        <header class="top-header">
            <div>
                <h1>Nhật Ký Phân Công HDV</h1>
                <p style="color: #9fa9cb; font-size: 0.9rem; margin-top: 4px;">Xem lịch sử và chỉ dẫn điều phối hướng dẫn viên cho các lịch khởi hành</p>
            </div>
            <jsp:include page="admin-header-right.jsp" />
        </header>

        <!-- Filter & Search Bar -->
        <div class="filter-section">
            <div class="search-container">
                <i class="fa-solid fa-magnifying-glass"></i>
                <input type="text" id="search-input" class="search-input" value="${search}" placeholder="Tìm theo tên tour hoặc hướng dẫn viên...">
            </div>
            <div style="color: #9fa9cb; font-size: 0.85rem; font-weight: 500;">
                Tổng số bản ghi: <span style="font-weight: 700; color: #f8fafc;">${totalCount}</span>
            </div>
        </div>

        <!-- Table Card -->
        <div class="card" style="padding: 24px;">
            <div style="overflow-x: auto;">
                <table class="booking-table" style="width: 100%; border-collapse: collapse;">
                    <thead>
                        <tr>
                            <th style="width: 80px;">ID</th>
                            <th>Tên Tour</th>
                            <th style="width: 130px;">Ngày Khởi Hành</th>
                            <th>Hướng Dẫn Viên</th>
                            <th>Người Phân Công</th>
                            <th>Chỉ dẫn / Ghi chú</th>
                            <th style="width: 150px;">Thời Gian Phân Công</th>
                            <th style="width: 140px; text-align: center;">Hành động</th>
                        </tr>
                    </thead>
                    <tbody id="assignments-tbody">
                        <c:choose>
                            <c:when test="${not empty assignments}">
                                <c:forEach var="a" items="${assignments}">
                                    <tr data-tour="${a.schedule.tour.tourName}" data-guide="${a.guide.fullName}">
                                        <td style="font-weight: 600;">#${a.assignmentId}</td>
                                        <td style="font-weight: 500; max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${a.schedule.tour.tourName}">
                                            ${a.schedule.tour.tourName}
                                        </td>
                                        <td><fmt:formatDate value="${a.schedule.departureDate}" pattern="dd/MM/yyyy" /></td>
                                        <td>
                                            <span class="badge-operation"><i class="fa-solid fa-user-tie"></i> ${a.guide.fullName}</span>
                                        </td>
                                        <td>${not empty a.assignedByName ? a.assignedByName : 'Hệ thống'}</td>
                                        <td>
                                            <div class="notes-text" title="${a.notes}">
                                                ${not empty a.notes ? a.notes : '<span style="color:#4a5578;">Không có ghi chú</span>'}
                                            </div>
                                        </td>
                                        <td style="font-size: 0.85rem;">
                                            <fmt:formatDate value="${a.assignedAt}" pattern="dd/MM/yyyy HH:mm" />
                                        </td>
                                        <td style="text-align: center;">
                                            <button class="btn-unassign-guide"
                                                    data-schedule-id="${a.scheduleId}"
                                                    data-guide-id="${a.guideId}"
                                                    data-tour-name="${a.schedule.tour.tourName}"
                                                    data-guide-name="${a.guide.fullName}">
                                                <i class="fa-solid fa-user-xmark"></i> Hủy phân công
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="8" class="empty-state">
                                        <i class="fa-solid fa-clipboard-list" style="font-size: 2rem; margin-bottom: 8px; display: block;"></i>
                                        Chưa có lịch sử phân công hướng dẫn viên nào.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <!-- Server-side Pagination -->
            <c:if test="${totalPages > 1}">
                <div class="pagination-container">
                    <div class="pagination-info">
                        Trang <span style="font-weight: 700; color: #f8fafc;">${currentPage}</span> / <span style="font-weight: 700; color: #f8fafc;">${totalPages}</span>
                    </div>
                    <div class="pagination-buttons">
                        <a href="?page=${currentPage - 1}&size=${pageSize}&search=${search}"
                           class="page-link ${currentPage == 1 ? 'disabled' : ''}">
                            <i class="fa-solid fa-angle-left"></i> Trước
                        </a>
                        <c:forEach var="p" begin="1" end="${totalPages}">
                            <a href="?page=${p}&size=${pageSize}&search=${search}"
                               class="page-link ${p == currentPage ? 'active' : ''}">${p}</a>
                        </c:forEach>
                        <a href="?page=${currentPage + 1}&size=${pageSize}&search=${search}"
                           class="page-link ${currentPage == totalPages ? 'disabled' : ''}">
                            Sau <i class="fa-solid fa-angle-right"></i>
                        </a>
                    </div>
                </div>
            </c:if>
        </div>
    </main>
</div>

<script src="${pageContext.request.contextPath}/js/admin-assignment.js?v=1.3"></script>
<script>if (window.lucide) { window.lucide.createIcons(); }</script>
</body>
</html>
