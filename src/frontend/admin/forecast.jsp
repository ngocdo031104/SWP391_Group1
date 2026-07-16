<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt"  prefix="fmt" %>
<c:if test="${empty sessionUser || (sessionUser.roleId ne 1 && userRole ne 'Admin')}">
    <c:redirect url="/login" />
</c:if>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dự Báo & Xu Hướng — TourBuddy Enterprise</title>
    <!-- Outfit & Inter Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons & FontAwesome CDNs -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=1.6">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    
    <style>
        .forecast-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 24px;
            margin-top: 24px;
        }
        @media (max-width: 1024px) {
            .forecast-grid {
                grid-template-columns: 1fr;
            }
        }
        .control-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 24px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            margin-bottom: 24px;
        }
        .form-group {
            margin-bottom: 16px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #334155;
            font-size: 0.9rem;
        }
        .form-control {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 0.95rem;
            outline: none;
            transition: border-color 0.2s;
        }
        .form-control:focus {
            border-color: #2563eb;
        }
        .btn-forecast {
            width: 100%;
            background: linear-gradient(135deg, #2563eb, #1d4ed8);
            color: #ffffff;
            border: none;
            padding: 12px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            transition: opacity 0.2s;
        }
        .btn-forecast:hover {
            opacity: 0.9;
        }
        .btn-forecast:disabled {
            background: #94a3b8;
            cursor: not-allowed;
        }
        
        /* Modal Design */
        .modal {
            display: none;
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 1000;
            justify-content: center;
            align-items: center;
            backdrop-filter: blur(4px);
        }
        .modal.active {
            display: flex;
        }
        .modal-content {
            background: #ffffff;
            border-radius: 12px;
            width: 650px;
            max-width: 90%;
            max-height: 80vh;
            overflow-y: auto;
            box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);
            border: 1px solid #e2e8f0;
        }
        .modal-header {
            padding: 20px;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .modal-header h3 {
            margin: 0;
            font-size: 1.25rem;
            font-family: 'Outfit', sans-serif;
            color: #1e293b;
        }
        .modal-close {
            background: none;
            border: none;
            font-size: 1.5rem;
            cursor: pointer;
            color: #64748b;
        }
        .modal-body {
            padding: 20px;
        }
        .json-block {
            background: #0f172a;
            color: #38bdf8;
            padding: 16px;
            border-radius: 8px;
            font-family: 'Courier New', Courier, monospace;
            font-size: 0.85rem;
            white-space: pre-wrap;
            overflow-x: auto;
            max-height: 350px;
        }
        .toast-container {
            position: fixed;
            bottom: 24px;
            right: 24px;
            z-index: 10000;
        }
    </style>
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <!-- ── Left Sidebar ── -->
    <c:set var="activePage" value="forecast" scope="request" />
    <jsp:include page="sidebar.jsp" />

    <!-- ── Main Content Area ── -->
    <main class="main-content">
        <!-- Top Header -->
        <header class="top-header">
            <h1>Dự Báo & Phân Tích Xu Hướng</h1>
            <jsp:include page="admin-header-right.jsp" />
        </header>

        <!-- KPI Grid -->
        <div class="stats-grid">
            <!-- 1. Accuracy -->
            <div class="stat-card">
                <div class="stat-header">
                    <span class="stat-title">Độ tin cậy mô hình</span>
                    <div class="stat-icon blue"><i data-lucide="shield-check"></i></div>
                </div>
                <span class="stat-value" id="kpi-confidence">85.0%</span>
                <div class="stat-footer">
                    <span>Dựa trên hệ số xác định R²</span>
                </div>
            </div>
            
            <!-- 2. Revenue Target -->
            <div class="stat-card">
                <div class="stat-header">
                    <span class="stat-title">Dự báo doanh thu tháng tới</span>
                    <div class="stat-icon green"><i data-lucide="line-chart"></i></div>
                </div>
                <span class="stat-value" id="kpi-revenue">Đang tính...</span>
                <div class="stat-footer">
                    <span>Hồi quy tuyến tính 6 tháng</span>
                </div>
            </div>
            
            <!-- 3. Demand Rate -->
            <div class="stat-card">
                <div class="stat-header">
                    <span class="stat-title">Tour nhu cầu cao nhất</span>
                    <div class="stat-icon orange"><i data-lucide="flame"></i></div>
                </div>
                <span class="stat-value" id="kpi-demand" style="font-size: 1.15rem; font-weight: 800; line-height: 2.2rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; display: block;">Đang quét...</span>
                <div class="stat-footer">
                    <span>Quét lấp đầy & lượt đặt chỗ</span>
                </div>
            </div>
        </div>

        <!-- Main Forecast Grid -->
        <div class="forecast-grid">
            
            <!-- Left Side: Interactive Chart & Control Panel -->
            <div>
                <!-- Control Panel -->
                <div class="control-card">
                    <h3 style="font-family: 'Outfit', sans-serif; margin-top: 0; margin-bottom: 20px; font-size: 1.15rem; color: #1e293b;">
                        Bộ Điều Khiển Dự Báo Thống Kê
                    </h3>
                    <form id="forecast-form">
                        <div class="form-group">
                            <label for="forecast-type">Chọn Chỉ Số Cần Dự Báo</label>
                            <select id="forecast-type" class="form-control">
                                <option value="Revenue">Dự báo Doanh Thu (Hồi quy tuyến tính $y=ax+b$)</option>
                                <option value="BookingTrend">Dự báo Lượt Đặt Tour (Hồi quy tuyến tính $y=ax+b$)</option>
                                <option value="Demand">Dự báo Nhu Cầu Các Tour Hot (Moving Average)</option>
                            </select>
                        </div>
                        <button type="button" id="btn-run-forecast" class="btn-forecast">
                            <i data-lucide="play-circle"></i> Chạy Mô hình Dự báo (Generate Forecast)
                        </button>
                    </form>
                </div>

                <!-- Chart Card -->
                <div class="card" style="padding: 24px;">
                    <div class="card-header" style="padding: 0; margin-bottom: 20px;">
                        <h3 id="chart-title">Biểu đồ Xu hướng & Dự báo</h3>
                    </div>
                    <div class="card-body" style="padding: 0; position: relative; height: 350px;">
                        <canvas id="forecastChart"></canvas>
                    </div>
                </div>
            </div>

            <!-- Right Side: Log History -->
            <div class="card" style="padding: 24px; display: flex; flex-direction: column;">
                <div class="card-header" style="padding: 0; margin-bottom: 20px;">
                    <h3 style="font-family: 'Outfit', sans-serif; font-size: 1.1rem;">Lịch sử chạy mô hình</h3>
                </div>
                <div style="overflow-x: auto; flex-grow: 1;">
                    <table class="booking-table" style="width: 100%; border-collapse: collapse; font-size: 0.85rem;">
                        <thead>
                            <tr style="border-bottom: 2px solid #e2e8f0; background: #f8fafc; text-align: left;">
                                <th style="padding: 10px;">ID</th>
                                <th style="padding: 10px;">Loại</th>
                                <th style="padding: 10px;">Độ tin cậy</th>
                                <th style="padding: 10px;">Ngày chạy</th>
                                <th style="padding: 10px;">Hành động</th>
                            </tr>
                        </thead>
                        <tbody id="history-tbody">
                            <c:choose>
                                <c:when test="${not empty predictionsHistory}">
                                    <c:forEach var="pr" items="${predictionsHistory}">
                                        <tr style="border-bottom: 1px solid #e2e8f0;">
                                            <td style="padding: 10px; font-weight: 600;">#${pr.predictionId}</td>
                                            <td style="padding: 10px;">
                                                <span class="status-badge" style="background:#e0f2fe; color:#0369a1; padding: 2px 6px; border-radius: 4px; font-size: 0.75rem;">
                                                    ${pr.predictionType}
                                                </span>
                                            </td>
                                            <td style="padding: 10px; font-weight: 600;">
                                                <fmt:formatNumber value="${pr.confidence}" maxFractionDigits="1"/>%
                                            </td>
                                            <td style="padding: 10px; color:#64748b;">
                                                <fmt:formatDate value="${pr.generatedAt}" pattern="dd/MM/yyyy"/>
                                            </td>
                                            <td style="padding: 10px;">
                                                <button class="btn-detail-json" 
                                                        data-type="${pr.predictionType}"
                                                        data-confidence="${pr.confidence}%"
                                                        data-input='<c:out value="${pr.inputData}"/>' 
                                                        data-result='<c:out value="${pr.resultData}"/>'
                                                        style="background:none; border:none; color:#2563eb; cursor:pointer; font-weight:600; padding:0;">
                                                    Xem JSON
                                                </button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="5" style="text-align: center; padding: 20px; color: #94a3b8;">
                                            Chưa có snapshot dự báo nào được lưu.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
            
        </div>
    </main>
</div>

<!-- Details Modal -->
<div class="modal" id="json-modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="modal-title">Chi tiết Snapshot Dự Báo</h3>
            <button class="modal-close" id="btn-close-modal">&times;</button>
        </div>
        <div class="modal-body">
            <div style="margin-bottom: 16px;">
                <strong>Loại dự báo:</strong> <span id="modal-type" style="margin-right: 20px;">-</span>
                <strong>Độ tin cậy:</strong> <span id="modal-confidence">-</span>
            </div>
            <div style="margin-bottom: 12px;">
                <strong style="display: block; margin-bottom: 6px;">Dữ liệu lịch sử đầu vào (InputData):</strong>
                <pre class="json-block" id="modal-input-json"></pre>
            </div>
            <div>
                <strong style="display: block; margin-bottom: 6px;">Kết quả dự đoán đầu ra (ResultData):</strong>
                <pre class="json-block" id="modal-result-json"></pre>
            </div>
        </div>
    </div>
</div>

<div id="toastContainer" class="toast-container"></div>

<!-- Custom Page Script -->
<script>
    // Pass context path to static js
    window.contextPath = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/js/admin-forecast.js?v=1.1" charset="UTF-8"></script>
<script>
    if (window.lucide) {
        window.lucide.createIcons();
    }
</script>
</body>
</html>
