<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fraud Monitoring - TourBuddy Admin</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/admin-dashboard.css" rel="stylesheet">
    
    <style>
        .badge-normal { background-color: #6c757d; }
        .badge-review { background-color: #ffc107; color: #212529; }
        .badge-suspicious { background-color: #dc3545; }
        .badge-cleared { background-color: #28a745; }
        
        .filter-row { margin-bottom: 20px; }
        .empty-state { text-align: center; padding: 40px; color: #6c757d; }
    </style>
</head>
<body class="dashboard-body">
    <div class="dashboard-wrapper">
        <!-- Sidebar -->
        <c:set var="activePage" value="fraud-monitor" scope="request" />
        <jsp:include page="/admin/sidebar.jsp" />

        <!-- Main Content Area -->
        <main class="main-content">
            <header class="top-header" style="margin-bottom: 24px;">
                <div>
                    <h1 style="font-size: 24px; color: var(--gray-900); margin: 0 0 8px 0;">Giám sát Gian lận (Fraud Monitoring)</h1>
                    <p style="color: var(--gray-500); margin: 0; font-size: 14px;">Giám sát thủ công các giao dịch đáng ngờ.</p>
                </div>
            </header>

            <div class="container-fluid px-0">
                <!-- Summary Stats -->
                <div class="row mb-4">
                    <div class="col-md-2">
                        <div class="card shadow-sm text-center py-3" style="border-radius: 12px; border-left: 4px solid var(--gray-500);">
                            <div class="text-muted small text-uppercase fw-bold mb-1">Tổng Thanh Toán</div>
                            <h3 class="mb-0 text-dark"><fmt:formatNumber value="${stats.total}" pattern="#,###"/></h3>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="card shadow-sm text-center py-3" style="border-radius: 12px; border-left: 4px solid var(--danger);">
                            <div class="text-muted small text-uppercase fw-bold mb-1">Đáng ngờ</div>
                            <h3 class="mb-0 text-danger"><fmt:formatNumber value="${stats.suspicious}" pattern="#,###"/></h3>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="card shadow-sm text-center py-3" style="border-radius: 12px; border-left: 4px solid var(--warning);">
                            <div class="text-muted small text-uppercase fw-bold mb-1">Trùng lặp</div>
                            <h3 class="mb-0 text-warning"><fmt:formatNumber value="${stats.duplicate}" pattern="#,###"/></h3>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card shadow-sm text-center py-3" style="border-radius: 12px; border-left: 4px solid var(--info);">
                            <div class="text-muted small text-uppercase fw-bold mb-1">Lệch số tiền</div>
                            <h3 class="mb-0 text-info"><fmt:formatNumber value="${stats.mismatch}" pattern="#,###"/></h3>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card shadow-sm text-center py-3" style="border-radius: 12px; border-left: 4px solid var(--success);">
                            <div class="text-muted small text-uppercase fw-bold mb-1">TT Thành Công</div>
                            <h3 class="mb-0 text-success"><fmt:formatNumber value="${stats.successCount}" pattern="#,###"/></h3>
                        </div>
                    </div>
                </div>

                <!-- Filters -->
                <div class="card mb-4 shadow-sm" style="border: 1px solid var(--gray-200); border-radius: 12px;">
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/admin/fraud-monitor" method="GET">
                            <div class="row filter-row g-3">
                                <div class="col-md-2">
                                    <label class="form-label">Từ Ngày</label>
                                    <input type="date" class="form-control" name="dateFrom" value="<c:out value="${dateFrom}"/>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Đến Ngày</label>
                                    <input type="date" class="form-control" name="dateTo" value="<c:out value="${dateTo}"/>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Mã Đặt Tour (Booking ID)</label>
                                    <input type="number" class="form-control" name="bookingId" placeholder="Mã số..." value="<c:out value="${bookingId}"/>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Mã Giao Dịch (Txn Ref)</label>
                                    <input type="text" class="form-control" name="transactionRef" placeholder="Mã GD..." value="<c:out value="${transactionRef}"/>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Cổng TT (Gateway)</label>
                                    <input type="text" class="form-control" name="gateway" placeholder="Nội dung..." value="<c:out value="${gateway}"/>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Trạng thái GD</label>
                                    <select class="form-select" name="paymentStatus">
                                        <option value="">Tất cả</option>
                                        <option value="Success" <c:if test="${paymentStatus == 'Success'}">selected</c:if>>Thành công (Success)</option>
                                        <option value="Pending" <c:if test="${paymentStatus == 'Pending'}">selected</c:if>>Chờ xử lý (Pending)</option>
                                        <option value="Failed" <c:if test="${paymentStatus == 'Failed'}">selected</c:if>>Thất bại (Failed)</option>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Kiểm duyệt</label>
                                    <select class="form-select" name="reviewStatus">
                                        <option value="">Tất cả</option>
                                        <option value="Normal" <c:if test="${reviewStatus == 'Normal'}">selected</c:if>>Bình thường</option>
                                        <option value="Under Review" <c:if test="${reviewStatus == 'Under Review'}">selected</c:if>>Đang xem xét</option>
                                        <option value="Suspicious" <c:if test="${reviewStatus == 'Suspicious'}">selected</c:if>>Đáng ngờ</option>
                                        <option value="Cleared" <c:if test="${reviewStatus == 'Cleared'}">selected</c:if>>Đã xóa án</option>
                                    </select>
                                </div>
                                <div class="col-md-2 d-flex align-items-end">
                                    <button type="submit" class="btn btn-primary me-2"><i class="fas fa-search"></i> Tìm kiếm</button>
                                    <a href="${pageContext.request.contextPath}/admin/fraud-monitor" class="btn btn-outline-secondary text-secondary border-secondary"><i class="fas fa-undo"></i> Đặt lại</a>
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
                                        <th style="white-space: nowrap;">Thời gian TT</th>
                                        <th style="white-space: nowrap;">Mã Giao Dịch</th>
                                        <th style="white-space: nowrap;">Booking</th>
                                        <th style="white-space: nowrap;">Khách hàng</th>
                                        <th style="white-space: nowrap;">Số tiền TT</th>
                                        <th style="white-space: nowrap;">Số tiền cần TT</th>
                                        <th style="white-space: nowrap;">Trạng thái</th>
                                        <th style="white-space: nowrap;">Lý do Gian lận</th>
                                        <th style="white-space: nowrap;">Kiểm duyệt</th>
                                        <th style="white-space: nowrap;">Thao tác</th>
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
                                                                    <h5 class="modal-title">Kiểm duyệt Giao dịch #${txn.paymentId}</h5>
                                                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                                                                </div>
                                                                <div class="modal-body">
                                                                    <input type="hidden" name="action" value="updateStatus">
                                                                    <input type="hidden" name="paymentId" value="${txn.paymentId}">
                                                                    
                                                                    <div class="mb-3">
                                                                        <strong>Mã GD:</strong> <c:out value="${txn.transactionRef}" />
                                                                    </div>
                                                                    <div class="mb-3">
                                                                        <strong>Phản hồi cổng TT:</strong> <br>
                                                                        <small class="text-muted"><c:out value="${txn.gatewayResponse}" /></small>
                                                                    </div>
                                                                    <div class="mb-3">
                                                                        <strong>Lý do gian lận:</strong> <br>
                                                                        <span class="text-danger"><c:out value="${txn.fraudReason}" /></span>
                                                                    </div>
                                                                    
                                                                    <hr>
                                                                    <div class="mb-3">
                                                                        <label class="form-label">Đổi Trạng thái</label>
                                                                        <select class="form-select" name="newStatus" required>
                                                                            <option value="Normal" <c:if test="${txn.reviewStatus == 'Normal'}">selected</c:if>>Bình thường</option>
                                                                            <option value="Under Review" <c:if test="${txn.reviewStatus == 'Under Review'}">selected</c:if>>Đang xem xét</option>
                                                                            <option value="Suspicious" <c:if test="${txn.reviewStatus == 'Suspicious'}">selected</c:if>>Đáng ngờ</option>
                                                                            <option value="Cleared" <c:if test="${txn.reviewStatus == 'Cleared'}">selected</c:if>>Đã xóa án</option>
                                                                        </select>
                                                                    </div>
                                                                    <div class="mb-3">
                                                                        <label class="form-label">Ghi chú (Comment)</label>
                                                                        <textarea class="form-control" name="comment" rows="2" placeholder="Thêm ghi chú cho lần kiểm duyệt này..."></textarea>
                                                                    </div>
                                                                </div>
                                                                <div class="modal-footer">
                                                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                                                                    <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
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
                                                    <h5>Không tìm thấy giao dịch gian lận nào.</h5>
                                                    <p>Vui lòng thử thay đổi các bộ lọc.</p>
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
                                Hiển thị <c:out value="${transactions.size()}" /> trên <c:out value="${totalRecords}" /> bản ghi
                            </div>
                            <nav aria-label="Page navigation">
                                <ul class="pagination mb-0">
                                    <li class="page-item <c:if test='${currentPage == 1}'>disabled</c:if>">
                                        <a class="page-link" href="?page=${currentPage - 1}&dateFrom=${dateFrom}&dateTo=${dateTo}&bookingId=${bookingId}&transactionRef=${transactionRef}&gateway=${gateway}&paymentStatus=${paymentStatus}&reviewStatus=${reviewStatus}">Trước</a>
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
    <script src="${pageContext.request.contextPath}/js/admin-dashboard.js"></script>
    <script>
        // Initialize Bootstrap tooltips
        document.addEventListener('DOMContentLoaded', function () {
            var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
            var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });
        });
    </script>
</body>
</html>
