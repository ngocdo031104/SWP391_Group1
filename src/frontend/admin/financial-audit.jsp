<<<<<<< HEAD
﻿<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%-- Lưu contextPath vào biến JS để sử dụng bên trong các chuỗi JS (tránh lỗi EL bị chèn giữa string) --%>
<c:set var="cp" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhật Ký Kiểm Toán Tài Chính — TourBuddy Admin</title>
    
    <!-- Use exactly the same structure/CSS as users.jsp -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.1" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-space-overrides.css?v=1.0">
    
    <style>
        .badge-success { background-color: #28a745; }
        .badge-warning { background-color: #ffc107; color: #212529; }
        .badge-danger { background-color: #dc3545; }
        .badge-info { background-color: #17a2b8; }
        
        .filter-row { margin-bottom: 20px; }
        .empty-state { text-align: center; padding: 40px; color: #6c757d; }
    </style>
</head>
<body class="dashboard-body">
    <div class="dashboard-wrapper">
        <!-- Sidebar -->
        <c:set var="activePage" value="financial-audit" scope="request" />
        <jsp:include page="/admin/sidebar.jsp" />

        <!-- Main Content Area -->
        <main class="main-content">
            <header class="top-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <h1 style="font-size: 24px; color: var(--gray-900); margin: 0 0 8px 0;">Kiá»ƒm ToĂ¡n TĂ i ChĂ­nh</h1>
                    <p style="color: var(--gray-500); margin: 0; font-size: 14px;">Xem láº¡i lá»‹ch sá»­ giao dá»‹ch vĂ  nháº­t kĂ½ thanh toĂ¡n.</p>
                </div>
                <div class="header-actions" style="display: flex; gap: 8px;">
                    <button class="btn btn-outline-secondary" onclick="exportTable('csv')"><i class="fas fa-file-csv"></i> Xuáº¥t CSV</button>
                    <button class="btn btn-outline-success" onclick="exportTable('excel')"><i class="fas fa-file-excel"></i> Xuáº¥t Excel</button>
                    <button class="btn btn-outline-danger" onclick="exportTable('pdf')"><i class="fas fa-file-pdf"></i> Xuáº¥t PDF</button>
                </div>
            </header>

            <div class="container-fluid px-0">
                <!-- Summary Stats -->
                <div class="row mb-4">
                    <div class="col-md-3">
                        <div class="card shadow-sm text-center py-3" style="border-radius: 12px; border-left: 4px solid var(--gray-500);">
                            <div class="text-muted small text-uppercase fw-bold mb-1">Tá»•ng giao dá»‹ch</div>
                            <h3 class="mb-0 text-dark"><fmt:formatNumber value="${stats.total}" pattern="#,###"/></h3>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card shadow-sm text-center py-3" style="border-radius: 12px; border-left: 4px solid var(--success);">
                            <div class="text-muted small text-uppercase fw-bold mb-1">ThĂ nh cĂ´ng</div>
                            <h3 class="mb-0 text-success"><fmt:formatNumber value="${stats.success}" pattern="#,###"/></h3>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card shadow-sm text-center py-3" style="border-radius: 12px; border-left: 4px solid var(--danger);">
                            <div class="text-muted small text-uppercase fw-bold mb-1">Tháº¥t báº¡i</div>
                            <h3 class="mb-0 text-danger"><fmt:formatNumber value="${stats.failed}" pattern="#,###"/></h3>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card shadow-sm text-center py-3" style="border-radius: 12px; border-left: 4px solid var(--primary);">
                            <div class="text-muted small text-uppercase fw-bold mb-1">Tá»•ng doanh thu</div>
                            <h3 class="mb-0 text-primary"><fmt:formatNumber value="${stats.totalAmount}" pattern="#,###"/> <small class="text-muted fs-6">VND</small></h3>
                        </div>
                    </div>
                </div>

                <!-- Filters -->
                <div class="card mb-4 shadow-sm" style="border: 1px solid var(--gray-200); border-radius: 12px;">
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/admin/financial-audit" method="GET">
                            <div class="row filter-row g-3">
                                <div class="col-md-2">
                                    <label class="form-label">Tá»« ngĂ y</label>
                                    <input type="date" class="form-control" name="dateFrom" value="<c:out value="${dateFrom}"/>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Äáº¿n ngĂ y</label>
                                    <input type="date" class="form-control" name="dateTo" value="<c:out value="${dateTo}"/>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">NgÆ°á»i thá»±c hiá»‡n</label>
                                    <input type="text" class="form-control" name="operator" placeholder="TĂªn..." value="<c:out value="${operator}"/>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Tráº¡ng thĂ¡i</label>
                                    <select class="form-select" name="status">
                                        <option value="">Táº¥t cáº£</option>
                                        <option value="Success" <c:if test="${status == 'Success'}">selected</c:if>>ThĂ nh cĂ´ng</option>
                                        <option value="Pending" <c:if test="${status == 'Pending'}">selected</c:if>>Äang xá»­ lĂ½</option>
                                        <option value="Failed" <c:if test="${status == 'Failed'}">selected</c:if>>Tháº¥t báº¡i</option>
                                        <option value="Refunded" <c:if test="${status == 'Refunded'}">selected</c:if>>HoĂ n tiá»n</option>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">MĂ£ giao dá»‹ch</label>
                                    <input type="text" class="form-control" name="transactionRef" placeholder="MĂ£ GD..." value="<c:out value="${transactionRef}"/>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Äá»‘i soĂ¡t</label>
                                    <select class="form-select" name="discrepancy">
                                        <option value="">Táº¥t cáº£</option>
                                        <option value="yes" <c:if test="${discrepancy == 'yes'}">selected</c:if>>Lá»‡ch sá»• (Lá»—i)</option>
                                        <option value="no" <c:if test="${discrepancy == 'no'}">selected</c:if>>Khá»›p sá»• (BĂ¬nh thÆ°á»ng)</option>
                                    </select>
                                </div>
                                <div class="col-md-2 d-flex align-items-end">
                                    <button type="submit" class="btn btn-primary me-2"><i class="fas fa-search"></i> Lá»c</button>
                                    <a href="${pageContext.request.contextPath}/admin/financial-audit" class="btn btn-outline-secondary text-secondary border-secondary"><i class="fas fa-undo"></i> Äáº·t láº¡i</a>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                                <!-- Table -->
                <div class="card shadow-sm" style="border: 1px solid var(--gray-200); border-radius: 12px; overflow: hidden;">
                    <div class="card-body p-0">
                        <div class="table-responsive" style="max-height: 500px; overflow-y: auto;">
                            <table class="table table-hover mb-0">
                                <thead class="table-light" style="position: sticky; top: 0; z-index: 10;">
                                    <tr>
                                        <th style="white-space: nowrap;">Thá»i gian</th>
                                        <th style="white-space: nowrap;">NgÆ°á»i thá»±c hiá»‡n</th>
                                        <th style="white-space: nowrap;">Loáº¡i hĂ nh Ä‘á»™ng</th>
                                        <th style="white-space: nowrap;">MĂ£ GD</th>
                                        <th style="white-space: nowrap;">Booking ID</th>
                                        <th style="white-space: nowrap;">Sá»‘ tiá»n</th>
                                        <th style="white-space: nowrap;">Tráº¡ng thĂ¡i</th>
                                        <th style="white-space: nowrap;">Äá»‘i soĂ¡t</th>
                                        <th style="white-space: nowrap;">MĂ´ táº£</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty logs}">
                                            <c:forEach var="log" items="${logs}">
                                                <tr <c:if test="${log.isDiscrepancy}">style="background-color: #fff3cd;"</c:if>>
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
                                                            <c:when test="${log.paymentStatus == 'Success'}"><span class="badge badge-success">ThĂ nh cĂ´ng</span></c:when>
                                                            <c:when test="${log.paymentStatus == 'Pending'}"><span class="badge badge-warning">Äang xá»­ lĂ½</span></c:when>
                                                            <c:when test="${log.paymentStatus == 'Failed'}"><span class="badge badge-danger">Tháº¥t báº¡i</span></c:when>
                                                            <c:when test="${log.paymentStatus == 'Refunded'}"><span class="badge badge-info">HoĂ n tiá»n</span></c:when>
                                                            <c:otherwise><span class="badge bg-secondary"><c:out value="${log.paymentStatus}" /></span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${log.isDiscrepancy}">
                                                                <span class="badge badge-danger"><i class="fas fa-exclamation-triangle me-1"></i> <c:out value="${log.discrepancyReason}" /></span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge badge-success"><i class="fas fa-check-circle me-1"></i> Khá»›p sá»•</span>
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
                                                <td colspan="8" class="empty-state">
                                                    <i class="fas fa-file-invoice-dollar fa-3x mb-3 text-muted"></i>
                                                    <h5>KhĂ´ng tĂ¬m tháº¥y dá»¯ liá»‡u kiá»ƒm toĂ¡n nĂ o.</h5>
                                                    <p>Vui lĂ²ng thá»­ Ä‘iá»u chá»‰nh bá»™ lá»c tĂ¬m kiáº¿m.</p>
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
                                                Hiá»ƒn thá»‹ <c:out value="${logs.size()}" /> / <c:out value="${totalRecords}" /> báº£n ghi
                            </div>
                            <nav aria-label="Page navigation">
                                <ul class="pagination mb-0">
                                    <li class="page-item <c:if test='${currentPage == 1}'>disabled</c:if>">
                                        <a class="page-link" href="?page=${currentPage - 1}&dateFrom=${dateFrom}&dateTo=${dateTo}&operator=${operator}&status=${status}&transactionRef=${transactionRef}">TrÆ°á»›c</a>
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
        </main>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/admin-dashboard.js"></script>
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
                        // For Excel, we just need the raw text. We will wrap in <td> with mso-number-format later
                        row.push(text);
                    } else {
                        // For CSV, escape quotes
                        text = text.replace(/"/g, '""');
                        // Use ="..." for Time, Txn Ref, and Booking ID to prevent Excel from auto-formatting them as numbers/dates when opening CSV
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
                    // mso-number-format:'\@' forces Excel to treat the cell strictly as Text
                    html += "<" + cellTag + " style=\"mso-number-format:'\\@';\">" + data[i][j] + "</" + cellTag + ">";
                }
                html += "</tr>";
            }
            html += "</table>";
            
            // Lưu contextPath ra biến JS để nối chuỗi an toàn — tránh lỗi JSP EL bị chèn giữa string JS.
            const ctxPath = '<c:out value="${cp}"/>';
            let excelFile = "<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:x='urn:schemas-microsoft-com:office:excel' xmlns='http://www.w3.org/TR/REC-html40'>";
            excelFile += "<head><meta charset='utf-8'>";
            excelFile += "<link rel='stylesheet' href='" + ctxPath + "/css/admin-space-overrides.css?v=1.0'>";
            excelFile += "</head>";
            excelFile += "<body>" + html + "</body></html>";
            
            downloadFile(excelFile, filename, 'application/vnd.ms-excel');
        }

        function exportPDF(table, filename) {
            if (!window.html2pdf) {
                alert('ThÆ° viá»‡n PDF Ä‘ang táº£i, vui lĂ²ng thá»­ láº¡i!');
                return;
            }
            
            // Create a styled container for PDF
            let container = document.createElement('div');
            container.innerHTML = '<h2 style="text-align:center; font-family: sans-serif; margin-bottom: 20px;">Nháº­t KĂ½ Kiá»ƒm ToĂ¡n TĂ i ChĂ­nh</h2>' + table.outerHTML;
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
            let blob = new Blob(['\ufeff' + content], { type: mimeType + ';charset=utf-8;' }); // BOM for Excel
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
    <script>if (window.lucide) { lucide.createIcons(); }</script>
</body>
</html>

