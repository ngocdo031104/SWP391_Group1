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
    <!-- Outfit & Inter Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons & FontAwesome CDNs -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=1.6">
    
    <style>
        .filter-section {
            background: #ffffff;
            padding: 16px 24px;
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            flex-wrap: wrap;
        }
        
        .search-container {
            position: relative;
            flex: 1;
            max-width: 400px;
        }
        
        .search-container i {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
            font-size: 1rem;
        }
        
        .search-input {
            width: 100%;
            padding: 10px 12px 10px 38px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            outline: none;
            font-family: 'Inter', sans-serif;
            font-size: 0.9rem;
            transition: all 0.2s;
        }
        
        .search-input:focus {
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
        }
        
        .badge-operation {
            background: #e0f2fe;
            color: #0369a1;
            font-weight: 600;
            padding: 4px 8px;
            border-radius: 6px;
            font-size: 0.75rem;
            display: inline-block;
        }

        .notes-text {
            max-width: 250px;
            word-wrap: break-word;
            font-style: italic;
            color: #475569;
        }
    </style>
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
                <p style="color: #64748b; font-size: 0.9rem; margin-top: 4px;">Xem lịch sử và chỉ dẫn điều phối hướng dẫn viên cho các lịch khởi hành</p>
            </div>
            <jsp:include page="admin-header-right.jsp" />
        </header>

        <!-- Filter & Search Bar -->
        <div class="filter-section">
            <div class="search-container">
                <i class="fa-solid fa-magnifying-glass"></i>
                <input type="text" id="search-input" class="search-input" placeholder="Tìm theo tên tour hoặc hướng dẫn viên...">
            </div>
            <div style="color: #64748b; font-size: 0.85rem; font-weight: 500;">
                Tổng số bản ghi: <span id="record-count" style="font-weight: 700; color: #1e293b;">0</span>
            </div>
        </div>

        <!-- Table Card -->
        <div class="card" style="padding: 24px;">
            <div style="overflow-x: auto;">
                <table class="booking-table" style="width: 100%; border-collapse: collapse;">
                    <thead>
                        <tr style="border-bottom: 2px solid #e2e8f0; background: #f8fafc; text-align: left;">
                            <th style="padding: 12px; width: 80px;">ID</th>
                            <th style="padding: 12px;">Tên Tour</th>
                            <th style="padding: 12px; width: 140px;">Ngày Khởi Hành</th>
                            <th style="padding: 12px;">Hướng Dẫn Viên</th>
                            <th style="padding: 12px;">Người Phân Công</th>
                            <th style="padding: 12px;">Chỉ dẫn / Ghi chú</th>
                            <th style="padding: 12px; width: 160px;">Thời Gian Phân Công</th>
                        </tr>
                    </thead>
                    <tbody id="assignments-tbody">
                        <c:choose>
                            <c:when test="${not empty assignments}">
                                <c:forEach var="a" items="${assignments}">
                                    <tr style="border-bottom: 1px solid #e2e8f0;" 
                                        data-tour="${a.schedule.tour.tourName}" 
                                        data-guide="${a.guide.fullName}">
                                        <td style="padding: 12px; font-weight: 600;">#${a.assignmentId}</td>
                                        <td style="padding: 12px; font-weight: 500; max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${a.schedule.tour.tourName}">
                                            ${a.schedule.tour.tourName}
                                        </td>
                                        <td style="padding: 12px; color: #334155;">
                                            <fmt:formatDate value="${a.schedule.departureDate}" pattern="dd/MM/yyyy" />
                                        </td>
                                        <td style="padding: 12px;">
                                            <span class="badge-operation"><i class="fa-solid fa-user-tie"></i> ${a.guide.fullName}</span>
                                        </td>
                                        <td style="padding: 12px; font-weight: 500; color: #475569;">
                                            ${not empty a.assignedByName ? a.assignedByName : 'Hệ thống'}
                                        </td>
                                        <td style="padding: 12px;">
                                            <div class="notes-text" title="${a.notes}">
                                                ${not empty a.notes ? a.notes : '<span style="color:#cbd5e1;">Không có ghi chú</span>'}
                                            </div>
                                        </td>
                                        <td style="padding: 12px; color: #64748b; font-size: 0.85rem;">
                                            <fmt:formatDate value="${a.assignedAt}" pattern="dd/MM/yyyy HH:mm" />
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" style="text-align: center; padding: 40px; color: #94a3b8;">
                                        <i class="fa-solid fa-clipboard-list" style="font-size: 2rem; margin-bottom: 8px; display: block;"></i>
                                        Chưa có lịch sử phân công hướng dẫn viên nào.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>

<script>
    document.addEventListener("DOMContentLoaded", () => {
        // Initialize Lucide Icons
        if (window.lucide) {
            window.lucide.createIcons();
        }
        
        const searchInput = document.getElementById("search-input");
        const recordCount = document.getElementById("record-count");
        const rows = document.querySelectorAll("#assignments-tbody tr");
        
        function updateCount() {
            let visibleCount = 0;
            rows.forEach(row => {
                // Skip placeholder row if no assignments
                if (row.cells.length === 1) return;
                if (row.style.display !== "none") {
                    visibleCount++;
                }
            });
            recordCount.innerText = visibleCount;
        }

        if (searchInput) {
            searchInput.addEventListener("input", function() {
                const query = this.value.toLowerCase().trim();
                rows.forEach(row => {
                    if (row.cells.length === 1) return; // Skip no data row
                    const tourName = row.getAttribute("data-tour") ? row.getAttribute("data-tour").toLowerCase() : "";
                    const guideName = row.getAttribute("data-guide") ? row.getAttribute("data-guide").toLowerCase() : "";
                    
                    if (tourName.includes(query) || guideName.includes(query)) {
                        row.style.display = "";
                    } else {
                        row.style.display = "none";
                    }
                });
                updateCount();
            });
        }
        
        updateCount();
    });
</script>
</body>
</html>
