<%-- 
    Li&#234;n quan &#273;&#7871;n UCs: Admin Management
    T&#225;c gi&#7843;: &#272;&#7895; V&#361; Minh Ng&#7885;c
    MSSV: HE182479
--%>
<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nh&#7853;t K&#253; Ki&#7875;m To&#225;n T&#224;i Ch&#237;nh &#8212; TourBuddy Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.3" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/tb-ui.css?v=1.0">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-space-overrides.css?v=1.0">
    <style>
        .badge-review { background-color: #ffc107; color: #212529; }
        .badge-suspicious { background-color: #dc3545; }
        .badge-cleared { background-color: #28a745; }
        .badge-info { background-color: #17a2b8; }
        
        .filter-row { margin-bottom: 20px; }
        .empty-state { text-align: center; padding: 40px; color: #6c757d; }
    </style>
</head>
<body class="dashboard-body tb-cosmic">
    <div class="dashboard-wrapper">
        <!-- Thanh menu b&#234;n tr&#225;i (Sidebar) -->
        <c:set var="activePage" value="financial-audit" scope="request" />
        <jsp:include page="/admin/sidebar.jsp" />

        <!-- V&#249;ng n&#7897;i dung ch&#237;nh -->
        <main class="main-content theme-light">
            <header class="top-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <h1 style="font-size: 24px; color: #f8fafc; margin: 0 0 8px 0;">Ki&#7875;m To&#225;n T&#224;i Ch&#237;nh</h1>
                    <p style="color: #9fa9cb; margin: 0; font-size: 14px;">Xem l&#7841;i l&#7883;ch s&#7917; giao d&#7883;ch v&#224; nh&#7853;t k&#253; thanh to&#225;n.</p>
                </div>
                <div class="header-actions" style="display: flex; gap: 8px;">
                    <button class="btn btn-outline-secondary" onclick="exportTable('csv')"><i class="fas fa-file-csv"></i> Xu&#7845;t CSV</button>
                    <button class="btn btn-outline-success" onclick="exportTable('excel')"><i class="fas fa-file-excel"></i> Xu&#7845;t Excel</button>
                    <button class="btn btn-outline-danger" onclick="exportTable('pdf')"><i class="fas fa-file-pdf"></i> Xu&#7845;t PDF</button>
                </div>
            </header>

            <div class="container-fluid px-0">
                <!-- Th&#7889;ng k&#234; t&#243;m t&#7855;t -->
                <div class="row mb-4">
                    <div class="col-md-3">
                        <div class="card shadow-sm text-center py-3" style="border-radius: 12px; border-left: 4px solid var(--gray-500);">
                            <div class="small text-uppercase fw-bold mb-1" style="color: #9fa9cb !important;">T&#7893;ng giao d&#7883;ch</div>
                            <h3 class="mb-0" style="color: #ffffff !important; font-weight: 700;"><fmt:formatNumber value="${stats.total}" pattern="#,###"/></h3>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card shadow-sm text-center py-3" style="border-radius: 12px; border-left: 4px solid var(--success);">
                            <div class="small text-uppercase fw-bold mb-1" style="color: #9fa9cb !important;">Th&#224;nh c&#244;ng</div>
                            <h3 class="mb-0" style="color: #ffffff !important; font-weight: 700;"><fmt:formatNumber value="${stats.success}" pattern="#,###"/></h3>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card shadow-sm text-center py-3" style="border-radius: 12px; border-left: 4px solid var(--danger);">
                            <div class="small text-uppercase fw-bold mb-1" style="color: #9fa9cb !important;">Th&#7845;t b&#7841;i</div>
                            <h3 class="mb-0" style="color: #ffffff !important; font-weight: 700;"><fmt:formatNumber value="${stats.failed}" pattern="#,###"/></h3>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card shadow-sm text-center py-3" style="border-radius: 12px; border-left: 4px solid var(--primary);">
                            <div class="small text-uppercase fw-bold mb-1" style="color: #9fa9cb !important;">T&#7893;ng doanh thu</div>
                            <h3 class="mb-0" style="color: #ffffff !important; font-weight: 700;"><fmt:formatNumber value="${stats.totalAmount}" pattern="#,###"/> <small class="fs-6" style="color: #cbd5e1 !important;">VND</small></h3>
                        </div>
                    </div>
                </div>

                <!-- B&#7897; l&#7885;c d&#7919; li&#7879;u -->
                <div class="card mb-4 shadow-sm" style="border: 1px solid var(--gray-200); border-radius: 12px;">
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/admin/financial-audit" method="GET">
                            <div class="row filter-row g-3">
                                <div class="col-md-2">
                                    <label class="form-label">T&#7915; ng&#224;y</label>
                                    <input type="date" class="form-control" name="dateFrom" value="<c:out value="${dateFrom}"/>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">&#272;&#7871;n ng&#224;y</label>
                                    <input type="date" class="form-control" name="dateTo" value="<c:out value="${dateTo}"/>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Ng&#432;&#7901;i th&#7921;c hi&#7879;n</label>
                                    <input type="text" class="form-control" name="operator" placeholder="T&#234;n..." value="<c:out value="${operator}"/>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Tr&#7841;ng th&#225;i</label>
                                    <select class="form-select" name="status">
                                        <option value="">T&#7845;t c&#7843;</option>
                                        <option value="Success" <c:if test="${status == 'Success'}">selected</c:if>>Th&#224;nh c&#244;ng</option>
                                        <option value="Pending" <c:if test="${status == 'Pending'}">selected</c:if>>&#272;ang x&#7917; l&#253;</option>
                                        <option value="Failed" <c:if test="${status == 'Failed'}">selected</c:if>>Th&#7845;t b&#7841;i</option>
                                        <option value="Refunded" <c:if test="${status == 'Refunded'}">selected</c:if>>Ho&#224;n ti&#7873;n</option>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">M&#227; giao d&#7883;ch</label>
                                    <input type="text" class="form-control" name="transactionRef" placeholder="M&#227; GD..." value="<c:out value="${transactionRef}"/>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">&#272;&#7889;i so&#225;t</label>
                                    <select class="form-select" name="discrepancy">
                                        <option value="">T&#7845;t c&#7843;</option>
                                        <option value="yes" <c:if test="${discrepancy == 'yes'}">selected</c:if>>L&#7879;ch s&#7893; (L&#7895;i)</option>
                                        <option value="no" <c:if test="${discrepancy == 'no'}">selected</c:if>>Kh&#7899;p s&#7893; (B&#236;nh th&#432;&#7901;ng)</option>
                                    </select>
                                </div>
                                <div class="col-md-2 d-flex align-items-end">
                                    <button type="submit" class="btn btn-primary me-2"><i class="fas fa-search"></i> L&#7885;c</button>
                                    <a href="${pageContext.request.contextPath}/admin/financial-audit" class="btn btn-outline-secondary text-secondary border-secondary"><i class="fas fa-undo"></i> &#272;&#7863;t l&#7841;i</a>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- B&#7843;ng d&#7919; li&#7879;u ch&#237;nh -->
                <div class="card shadow-sm" style="border: 1px solid var(--gray-200); border-radius: 12px; overflow: hidden;">
                    <div class="card-body p-0">
                        <div class="table-responsive" style="max-height: 500px; overflow-y: auto;">
                            <table class="table table-hover mb-0">
                                <thead class="table-light" style="position: sticky; top: 0; z-index: 10;">
                                    <tr>
                                        <th style="white-space: nowrap;">Th&#7901;i gian</th>
                                        <th style="white-space: nowrap;">Ng&#432;&#7901;i th&#7921;c hi&#7879;n</th>
                                        <th style="white-space: nowrap;">Lo&#7841;i h&#224;nh &#273;&#7897;ng</th>
                                        <th style="white-space: nowrap;">M&#227; GD</th>
                                        <th style="white-space: nowrap;">Booking ID</th>
                                        <th style="white-space: nowrap;">S&#7889; ti&#7873;n</th>
                                        <th style="white-space: nowrap;">Tr&#7841;ng th&#225;i</th>
                                        <th style="white-space: nowrap;">&#272;&#7889;i so&#225;t</th>
                                        <th style="white-space: nowrap;">M&#244; t&#7843;</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty logs}">
                                            <c:forEach var="log" items="${logs}">
                                                <tr <c:if test="${log.isDiscrepancy}">style="background-color: rgba(255, 193, 7, 0.15);"</c:if>>
                                                    <td><fmt:formatDate value="${log.createdAt}" pattern="yyyy-MM-dd HH:mm" /></td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty log.operatorName}">
                                                                <c:out value="${log.operatorName}" />
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted">System/Unknown</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${log.actionType == 'Process Payment'}"><span class="badge badge-info"><i class="fas fa-money-bill-wave me-1"></i> <c:out value="${log.actionType}" /></span></c:when>
                                                            <c:when test="${log.actionType == 'Refund'}"><span class="badge badge-warning"><i class="fas fa-undo me-1"></i> <c:out value="${log.actionType}" /></span></c:when>
                                                            <c:when test="${log.actionType == 'Cancel'}"><span class="badge badge-danger"><i class="fas fa-times-circle me-1"></i> <c:out value="${log.actionType}" /></span></c:when>
                                                            <c:otherwise><span class="badge badge-info"><i class="fas fa-file-invoice me-1"></i> <c:out value="${log.actionType}" /></span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty log.transactionRef}">
                                                                <c:out value="${log.transactionRef}" />
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted">N/A</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:if test="${log.bookingId > 0}">
                                                            <a href="${pageContext.request.contextPath}/admin/booking-detail?id=${log.bookingId}" class="text-decoration-none fw-bold" style="color: var(--primary);">
                                                                <fmt:formatNumber value="${log.bookingId}" pattern="BK-000000"/>
                                                            </a>
                                                        </c:if>
                                                    </td>
                                                    <td>
                                                        <c:if test="${not empty log.amount}">
                                                            <fmt:formatNumber value="${log.amount}" pattern="#,###" /> <c:out value="${log.currency}" />
                                                        </c:if>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${log.paymentStatus == 'Success'}"><span class="badge badge-success">Th&#224;nh c&#244;ng</span></c:when>
                                                            <c:when test="${log.paymentStatus == 'Pending'}"><span class="badge badge-warning">&#272;ang x&#7917; l&#253;</span></c:when>
                                                            <c:when test="${log.paymentStatus == 'Failed'}"><span class="badge badge-danger">Th&#7845;t b&#7841;i</span></c:when>
                                                            <c:when test="${log.paymentStatus == 'Refunded'}"><span class="badge badge-info">Ho&#224;n ti&#7873;n</span></c:when>
                                                            <c:otherwise><span class="badge bg-secondary"><c:out value="${log.paymentStatus}" /></span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${log.isDiscrepancy}">
                                                                <span class="badge badge-danger"><i class="fas fa-exclamation-triangle me-1"></i> <c:out value="${log.discrepancyReason}" /></span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge badge-success"><i class="fas fa-check-circle me-1"></i> Kh&#7899;p s&#7893;</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<c:out value="${log.description}" />">
                                                        <c:out value="${log.description}" />
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="9" class="empty-state">
                                                    <i class="fas fa-file-invoice-dollar fa-3x mb-3 text-muted"></i>
                                                    <h5>Kh&#244;ng t&#236;m th&#7845;y d&#7919; li&#7879;u ki&#7875;m to&#225;n n&#224;o.</h5>
                                                    <p>Vui l&#242;ng th&#7917; &#273;i&#7873;u ch&#7881;nh b&#7897; l&#7885;c t&#236;m ki&#7871;m.</p>
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    
                    <!-- Pagination -->
                    <c:if test="${totalPages > 1}">
                        <div class="card-footer bg-white d-flex justify-content-between align-items-center">
                             <div>
                                 Hi&#7875;n th&#7883; <c:out value="${logs.size()}" /> / <c:out value="${totalRecords}" /> b&#7843;n ghi
                             </div>
                             <nav aria-label="Page navigation">
                                 <ul class="pagination mb-0">
                                     <li class="page-item <c:if test='${currentPage == 1}'>disabled</c:if>">
                                         <a class="page-link" href="?page=${currentPage - 1}&dateFrom=${dateFrom}&dateTo=${dateTo}&operator=${operator}&status=${status}&transactionRef=${transactionRef}">Tr&#432;&#7899;c</a>
                                     </li>
                                     
                                     <c:forEach begin="1" end="${totalPages}" var="i">
                                         <li class="page-item <c:if test='${currentPage == i}'>active</c:if>">
                                             <a class="page-link" href="?page=${i}&dateFrom=${dateFrom}&dateTo=${dateTo}&operator=${operator}&status=${status}&transactionRef=${transactionRef}">${i}</a>
                                         </li>
                                     </c:forEach>
                                     
                                     <li class="page-item <c:if test='${currentPage == totalPages}'>disabled</c:if>">
                                         <a class="page-link" href="?page=${currentPage + 1}&dateFrom=${dateFrom}&dateTo=${dateTo}&operator=${operator}&status=${status}&transactionRef=${transactionRef}">Sau</a>
                                     </li>
                                 </ul>
                             </nav>
                        </div>
                    </c:if>
                </div>
            </div>
        </main>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/admin-dashboard.js?v=<%= System.currentTimeMillis() %>" charset="UTF-8"></script>
    <script>
        // Initialize Bootstrap tooltips
        document.addEventListener('DOMContentLoaded', function () {
            var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
            var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });
        });

        // Export functionality
        function exportTable(type) {
            const table = document.querySelector('.table');
            if (!table) return;
            
            let filename = 'Nhat_Ky_Kiem_Toan_' + new Date().toISOString().split('T')[0];
            
            if (type === 'csv') {
                exportCSV(table, filename + '.csv');
            } else if (type === 'excel') {
                exportExcel(table, filename + '.xls');
            } else if (type === 'pdf') {
                exportPDF(table, filename + '.pdf');
            }
        }
        
        function getTableData(table, isExcel = false) {
            let data = [];
            const rows = table.querySelectorAll('tr');
            for (let i = 0; i < rows.length; i++) {
                let row = [], cols = rows[i].querySelectorAll('td, th');
                for (let j = 0; j < cols.length; j++) {
                    let text = cols[j].innerText.replace(/(\r\n|\n|\r)/gm, " ").trim();
                    
                    if (isExcel) {
                        row.push(text);
                    } else {
                        text = text.replace(/"/g, '""');
                        if (i > 0 && (j === 0 || j === 3 || j === 4)) {
                            row.push('="' + text + '"');
                        } else {
                            row.push('"' + text + '"');
                        }
                    }
                }
                data.push(row);
            }
            return data;
        }

        function exportCSV(table, filename) {
            let csv = [];
            let data = getTableData(table, false);
            for (let i = 0; i < data.length; i++) {
                csv.push(data[i].join(","));
            }
            downloadFile(csv.join("\n"), filename, 'text/csv');
        }

        function exportExcel(table, filename) {
            let data = getTableData(table, true);
            let html = "<table border='1'>";
            for (let i = 0; i < data.length; i++) {
                html += "<tr>";
                for (let j = 0; j < data[i].length; j++) {
                    let cellTag = i === 0 ? "th" : "td";
                    html += "<" + cellTag + " style=\"mso-number-format:'\\@';\">" + data[i][j] + "</" + cellTag + ">";
                }
                html += "</tr>";
            }
            html += "</table>";
            
            const ctxPath = '${pageContext.request.contextPath}';
            let excelFile = "<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:x='urn:schemas-microsoft-com:office:excel' xmlns='http://www.w3.org/TR/REC-html40'>";
            excelFile += "<head><meta charset='utf-8'>";
            excelFile += "<link rel='stylesheet' href='" + ctxPath + "/css/admin-space-overrides.css?v=1.0'>";
            excelFile += "</head>";
            excelFile += "<body>" + html + "</body></html>";
            
            downloadFile(excelFile, filename, 'application/vnd.ms-excel');
        }

        function exportPDF(table, filename) {
            if (!window.html2pdf) {
                alert('Th\u01b0 vi\u1ec7n PDF \u0111ang t\u1ea3i, vui l\u00f2ng th\u1eed l\u1ea1i!');
                return;
            }
            
            let container = document.createElement('div');
            container.innerHTML = '<h2 style="text-align:center; font-family: sans-serif; margin-bottom: 20px;">Nh\u1eadt K\u00fd Ki\u1ec3m To\u00e1n T\u00e0i Ch\u00ednh</h2>' + table.outerHTML;
            container.style.padding = '20px';
            container.style.backgroundColor = 'white';
            container.style.fontFamily = 'sans-serif';
            
            let opt = {
              margin:       0.5,
              filename:     filename,
              image:        { type: 'jpeg', quality: 0.98 },
              html2canvas:  { scale: 2 },
              jsPDF:        { unit: 'in', format: 'letter', orientation: 'landscape' }
            };
            
            html2pdf().set(opt).from(container).save();
        }
        
        function downloadFile(content, filename, mimeType) {
            let blob = new Blob(['\ufeff' + content], { type: mimeType + ';charset=utf-8;' });
            let link = document.createElement("a");
            if (link.download !== undefined) {
                let url = URL.createObjectURL(blob);
                link.setAttribute("href", url);
                link.setAttribute("download", filename);
                link.style.visibility = 'hidden';
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            }
        }
    </script>
    <script src="${pageContext.request.contextPath}/js/tb-ui.js?v=1.0"></script>
    <script>if (window.lucide) { lucide.createIcons(); }</script>
</body>
</html>
