<%-- 
    Liên quan đến UCs: Monitor Fraudulent Transactions
    Tác giả: Đỗ Vũ Minh Ngọc
    MSSV: HE182479
--%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gi&#225;m S&#225;t Gian L&#7853;n &#8212; TourBuddy Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <link href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.3" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/tb-ui.css?v=1.0">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-space-overrides.css?v=1.0">
    <style>
        .badge-review { background-color: #ffc107; color: #212529; }
        .badge-suspicious { background-color: #dc3545; }
        .badge-cleared { background-color: #28a745; }
        
        .filter-row { margin-bottom: 20px; }
        .empty-state { text-align: center; padding: 40px; color: #6c757d; }
    </style>
</head>
<body class="dashboard-body tb-cosmic">
    <div class="dashboard-wrapper">
        <!-- Thanh menu bên trái (Sidebar) -->
        <c:set var="activePage" value="fraud-monitor" scope="request" />
        <jsp:include page="/admin/sidebar.jsp" />

        <!-- Vùng nội dung chính -->
        <main class="main-content theme-light">
            <header class="top-header" style="margin-bottom: 24px;">
                <div>
                    <h1 style="font-size: 24px; color: #f8fafc; margin: 0 0 8px 0;">Gi&#225;m s&#225;t Gian l&#7853;n (Fraud Monitoring)</h1>
                    <p style="color: #9fa9cb; margin: 0; font-size: 14px;">Gi&#225;m s&#225;t th&#7911; c&#244;ng c&#225;c giao d&#7883;ch &#273;&#225;ng ng&#7901;.</p>
                </div>
            </header>

            <div class="container-fluid px-0">
                <!-- Thống kê tóm tắt -->
                <div class="row mb-4">
                    <div class="col-md-2">
                        <div class="card shadow-sm text-center py-3" style="border-radius: 12px; border-left: 4px solid var(--gray-500);">
                            <div class="text-muted small text-uppercase fw-bold mb-1">T&#7893;ng Thanh To&#225;n</div>
                            <h3 class="mb-0 text-light"><fmt:formatNumber value="${stats.total}" pattern="#,###"/></h3>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="card shadow-sm text-center py-3" style="border-radius: 12px; border-left: 4px solid var(--danger);">
                            <div class="text-muted small text-uppercase fw-bold mb-1">&#272;&#225;ng ng&#7901;</div>
                            <h3 class="mb-0 text-danger"><fmt:formatNumber value="${stats.suspicious}" pattern="#,###"/></h3>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="card shadow-sm text-center py-3" style="border-radius: 12px; border-left: 4px solid var(--warning);">
                            <div class="text-muted small text-uppercase fw-bold mb-1">Tr&#249;ng l&#7863;p</div>
                            <h3 class="mb-0 text-warning"><fmt:formatNumber value="${stats.duplicate}" pattern="#,###"/></h3>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card shadow-sm text-center py-3" style="border-radius: 12px; border-left: 4px solid var(--info);">
                            <div class="text-muted small text-uppercase fw-bold mb-1">L&#7879;ch s&#7889; ti&#7873;n</div>
                            <h3 class="mb-0 text-info"><fmt:formatNumber value="${stats.mismatch}" pattern="#,###"/></h3>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card shadow-sm text-center py-3" style="border-radius: 12px; border-left: 4px solid var(--success);">
                            <div class="text-muted small text-uppercase fw-bold mb-1">TT Th&#224;nh C&#244;ng</div>
                            <h3 class="mb-0 text-success"><fmt:formatNumber value="${stats.successCount}" pattern="#,###"/></h3>
                        </div>
                    </div>
                </div>

                <!-- Bộ lọc dữ liệu -->
                <div class="card mb-4 shadow-sm" style="border: 1px solid var(--gray-200); border-radius: 12px;">
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/admin/fraud-monitor" method="GET">
                            <div class="row filter-row g-3">
                                <div class="col-md-2">
                                    <label class="form-label">T&#7915; Ng&#224;y</label>
                                    <input type="date" class="form-control" name="dateFrom" value="<c:out value="${dateFrom}"/>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">&#272;&#7871;n Ng&#224;y</label>
                                    <input type="date" class="form-control" name="dateTo" value="<c:out value="${dateTo}"/>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">M&#227; &#272;&#7863;t Tour (Booking ID)</label>
                                    <input type="number" class="form-control" name="bookingId" placeholder="M&#227; s&#7889;..." value="<c:out value="${bookingId}"/>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">M&#227; Giao D&#7883;ch (Txn Ref)</label>
                                    <input type="text" class="form-control" name="transactionRef" placeholder="M&#227; GD..." value="<c:out value="${transactionRef}"/>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">C&#7893;ng TT (Gateway)</label>
                                    <input type="text" class="form-control" name="gateway" placeholder="N&#7897;i dung..." value="<c:out value="${gateway}"/>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Tr&#7841;ng th&#225;i GD</label>
                                    <select class="form-select" name="paymentStatus">
                                        <option value="">T&#7845;t c&#7843;</option>
                                        <option value="Success" <c:if test="${paymentStatus == 'Success'}">selected</c:if>>Th&#224;nh c&#244;ng (Success)</option>
                                        <option value="Pending" <c:if test="${paymentStatus == 'Pending'}">selected</c:if>>Ch&#7901; x&#7917; l&#253; (Pending)</option>
                                        <option value="Failed" <c:if test="${paymentStatus == 'Failed'}">selected</c:if>>Th&#7845;t b&#7841;i (Failed)</option>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Ki&#7875;m duy&#7879;t</label>
                                    <select class="form-select" name="reviewStatus">
                                        <option value="">T&#7845;t c&#7843;</option>
                                        <option value="Normal" <c:if test="${reviewStatus == 'Normal'}">selected</c:if>>B&#236;nh th&#432;&#7901;ng</option>
                                        <option value="Under Review" <c:if test="${reviewStatus == 'Under Review'}">selected</c:if>>&#272;ang xem x&#233;t</option>
                                        <option value="Suspicious" <c:if test="${reviewStatus == 'Suspicious'}">selected</c:if>>&#272;&#225;ng ng&#7901;</option>
                                        <option value="Cleared" <c:if test="${reviewStatus == 'Cleared'}">selected</c:if>>&#272;&#227; x&#243;a &#225;n</option>
                                    </select>
                                </div>
                                <div class="col-md-2 d-flex align-items-end">
                                    <button type="submit" class="btn btn-primary me-2"><i class="fas fa-search"></i> T&#236;m ki&#7871;m</button>
                                    <a href="${pageContext.request.contextPath}/admin/fraud-monitor" class="btn btn-outline-secondary text-secondary border-secondary"><i class="fas fa-undo"></i> &#272;&#7863;t l&#7841;i</a>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Bảng dữ liệu chính -->
                <div class="card shadow-sm" style="border: 1px solid var(--gray-200); border-radius: 12px; overflow: hidden;">
                    <div class="card-body p-0">
                        <div class="table-responsive" style="max-height: 500px; overflow-y: auto;">
                            <table class="table table-hover mb-0">
                                <thead class="table-light" style="position: sticky; top: 0; z-index: 10;">
                                    <tr>
                                        <th style="white-space: nowrap;">Th&#7901;i gian TT</th>
                                        <th style="white-space: nowrap;">M&#227; Giao D&#7883;ch</th>
                                        <th style="white-space: nowrap;">Booking</th>
                                        <th style="white-space: nowrap;">Kh&#225;ch h&#224;ng</th>
                                        <th style="white-space: nowrap;">S&#7889; ti&#7873;n TT</th>
                                        <th style="white-space: nowrap;">S&#7889; ti&#7873;n c&#7847;n TT</th>
                                        <th style="white-space: nowrap;">Tr&#7841;ng th&#225;i</th>
                                        <th style="white-space: nowrap;">L&#253; do Gian l&#7853;n</th>
                                        <th style="white-space: nowrap;">Ki&#7875;m duy&#7879;t</th>
                                        <th style="white-space: nowrap;">Thao t&#225;c</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty transactions}">
                                            <c:forEach var="txn" items="${transactions}">
                                                <tr>
                                                    <td><fmt:formatDate value="${txn.paidAt}" pattern="yyyy-MM-dd HH:mm" /></td>
                                                    <td><c:out value="${txn.transactionRef}" /></td>
                                                    <td>
                                                        <c:if test="${txn.bookingId > 0}">
                                                            <a href="${pageContext.request.contextPath}/admin/booking-detail?id=${txn.bookingId}" class="text-decoration-none fw-bold" style="color: var(--primary);">
                                                                <fmt:formatNumber value="${txn.bookingId}" pattern="BK-000000"/>
                                                            </a>
                                                        </c:if>
                                                    </td>
                                                    <td><c:out value="${txn.customerName}" /></td>
                                                    <td><fmt:formatNumber value="${txn.amount}" pattern="#,###" /> <c:out value="${txn.currency}" /></td>
                                                    <td><fmt:formatNumber value="${txn.expectedAmount}" pattern="#,###" /> <c:out value="${txn.currency}" /></td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${txn.paymentStatus == 'Success'}"><span class="badge bg-success">Success</span></c:when>
                                                            <c:when test="${txn.paymentStatus == 'Pending'}"><span class="badge bg-warning text-dark">Pending</span></c:when>
                                                            <c:when test="${txn.paymentStatus == 'Failed'}"><span class="badge bg-danger">Failed</span></c:when>
                                                            <c:otherwise><span class="badge bg-secondary"><c:out value="${txn.paymentStatus}" /></span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-truncate text-danger fw-bold" style="max-width: 200px; cursor: pointer;" 
                                                        data-bs-toggle="tooltip" data-bs-placement="left" 
                                                        title="<c:out value='${txn.fraudReason}'/>">
                                                        <c:out value="${txn.fraudReason}" />
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${txn.reviewStatus == 'Under Review'}"><span class="badge badge-review">Under Review</span></c:when>
                                                            <c:when test="${txn.reviewStatus == 'Suspicious'}"><span class="badge badge-suspicious">Suspicious</span></c:when>
                                                            <c:when test="${txn.reviewStatus == 'Cleared'}"><span class="badge badge-cleared">Cleared</span></c:when>
                                                            <c:otherwise><span class="badge badge-normal">Normal</span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <button type="button" class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#actionModal${txn.paymentId}">
                                                            <i class="fas fa-edit"></i>
                                                        </button>
                                                    </td>
                                                </tr>

                                                <!-- Action Modal -->
                                                <div class="modal fade" id="actionModal${txn.paymentId}" tabindex="-1" aria-hidden="true">
                                                    <div class="modal-dialog">
                                                        <div class="modal-content">
                                                            <form action="${pageContext.request.contextPath}/admin/fraud-monitor" method="POST">
                                                                <div class="modal-header">
                                                                    <h5 class="modal-title">Ki&#7875;m duy&#7879;t Giao d&#7883;ch #${txn.paymentId}</h5>
                                                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="&#272;&#243;ng"></button>
                                                                </div>
                                                                <div class="modal-body">
                                                                    <input type="hidden" name="action" value="updateStatus">
                                                                    <input type="hidden" name="paymentId" value="${txn.paymentId}">
                                                                    
                                                                    <div class="mb-3">
                                                                        <strong>M&#227; GD:</strong> <c:out value="${txn.transactionRef}" />
                                                                    </div>
                                                                    <div class="mb-3">
                                                                        <strong>Ph&#7843;n h&#7891;i c&#7893;ng TT:</strong> <br>
                                                                        <small class="text-muted"><c:out value="${txn.gatewayResponse}" /></small>
                                                                    </div>
                                                                    <div class="mb-3">
                                                                        <strong>L&#253; do gian l&#7853;n:</strong> <br>
                                                                        <span class="text-danger"><c:out value="${txn.fraudReason}" /></span>
                                                                    </div>
                                                                    
                                                                    <hr>
                                                                    <div class="mb-3">
                                                                        <label class="form-label">&#272;&#7893;i Tr&#7841;ng th&#225;i</label>
                                                                        <select class="form-select" name="newStatus" required>
                                                                            <option value="Normal" <c:if test="${txn.reviewStatus == 'Normal'}">selected</c:if>>B&#236;nh th&#432;&#7901;ng</option>
                                                                            <option value="Under Review" <c:if test="${txn.reviewStatus == 'Under Review'}">selected</c:if>>&#272;ang xem x&#233;t</option>
                                                                            <option value="Suspicious" <c:if test="${txn.reviewStatus == 'Suspicious'}">selected</c:if>>&#272;&#225;ng ng&#7901;</option>
                                                                            <option value="Cleared" <c:if test="${txn.reviewStatus == 'Cleared'}">selected</c:if>>&#272;&#227; x&#243;a &#225;n</option>
                                                                        </select>
                                                                    </div>
                                                                    <div class="mb-3">
                                                                        <label class="form-label">Ghi ch&#250; (Comment)</label>
                                                                        <textarea class="form-control" name="comment" rows="2" placeholder="Th&#234;m ghi ch&#250; cho l&#7847;n ki&#7875;m duy&#7879;t n&#224;y..."></textarea>
                                                                    </div>
                                                                </div>
                                                                <div class="modal-footer">
                                                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">&#272;&#243;ng</button>
                                                                    <button type="submit" class="btn btn-primary">L&#432;u thay &#273;&#7893;i</button>
                                                                </div>
                                                             </form>
                                                         </div>
                                                     </div>
                                                 </div>
                                             </c:forEach>
                                         </c:when>
                                         <c:otherwise>
                                             <tr>
                                                 <td colspan="10" class="empty-state">
                                                     <i class="fas fa-shield-alt fa-3x mb-3 text-muted"></i>
                                                     <h5>Kh&#244;ng t&#236;m th&#7845;y giao d&#7883;ch gian l&#7853;n n&#224;o.</h5>
                                                     <p>Vui l&#242;ng th&#7917; thay &#273;&#7893;i c&#225;c b&#7897; l&#7885;c.</p>
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
                                 Hi&#7875;n th&#7883; <c:out value="${transactions.size()}" /> tr&#234;n <c:out value="${totalRecords}" /> b&#7843;n ghi
                             </div>
                             <nav aria-label="Page navigation">
                                 <ul class="pagination mb-0">
                                     <li class="page-item <c:if test='${currentPage == 1}'>disabled</c:if>">
                                         <a class="page-link" href="?page=${currentPage - 1}&dateFrom=${dateFrom}&dateTo=${dateTo}&bookingId=${bookingId}&transactionRef=${transactionRef}&gateway=${gateway}&paymentStatus=${paymentStatus}&reviewStatus=${reviewStatus}">Tr&#432;&#7899;c</a>
                                     </li>
                                     
                                     <c:forEach begin="1" end="${totalPages}" var="i">
                                         <li class="page-item <c:if test='${currentPage == i}'>active</c:if>">
                                             <a class="page-link" href="?page=${i}&dateFrom=${dateFrom}&dateTo=${dateTo}&bookingId=${bookingId}&transactionRef=${transactionRef}&gateway=${gateway}&paymentStatus=${paymentStatus}&reviewStatus=${reviewStatus}">${i}</a>
                                         </li>
                                     </c:forEach>
                                     
                                     <li class="page-item <c:if test='${currentPage == totalPages}'>disabled</c:if>">
                                         <a class="page-link" href="?page=${currentPage + 1}&dateFrom=${dateFrom}&dateTo=${dateTo}&bookingId=${bookingId}&transactionRef=${transactionRef}&gateway=${gateway}&paymentStatus=${paymentStatus}&reviewStatus=${reviewStatus}">Sau</a>
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
    <script src="${pageContext.request.contextPath}/js/tb-ui.js?v=1.0"></script>
    <script src="${pageContext.request.contextPath}/js/admin-dashboard.js?v=<%= System.currentTimeMillis() %>" charset="UTF-8"></script>
     <script>
         // Initialize Bootstrap tooltips
         document.addEventListener('DOMContentLoaded', function () {
             var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
             var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                 return new bootstrap.Tooltip(tooltipTriggerEl);
             });
         });
     </script>
     <script>if (window.lucide) { lucide.createIcons(); }</script>
 </body>
 </html>

