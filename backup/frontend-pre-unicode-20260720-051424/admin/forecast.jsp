<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
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
    <title>D? Báo &amp; Xu Hu?ng — TourBuddy Enterprise</title>
    <!-- Outfit & Inter Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons & FontAwesome CDNs -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.1">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        /* -- FORECAST PAGE — SPACE GLASSMORPHISM THEME -- */
        .forecast-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 24px;
            margin-top: 24px;
        }
        @media (max-width: 1024px) { .forecast-grid { grid-template-columns: 1fr; } }

        .control-card {
            background: rgba(22, 25, 50, 0.58);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid rgba(139, 92, 246, 0.2);
            border-radius: 14px;
            padding: 24px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.35);
            margin-bottom: 24px;
            color: #f8fafc;
            transition: transform 0.25s ease, box-shadow 0.25s ease;
        }
        .control-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 40px rgba(0,0,0,0.45), 0 0 20px rgba(139,92,246,0.1);
        }
        .control-card h3 { font-family: 'Outfit', sans-serif; margin-top: 0; margin-bottom: 20px; font-size: 1.1rem; color: #f8fafc; }

        .form-group { margin-bottom: 16px; }
        .form-group label {
            display: block; margin-bottom: 8px; font-weight: 600;
            color: #9fa9cb; font-size: 0.82rem; text-transform: uppercase; letter-spacing: 0.4px;
        }
        .form-control {
            width: 100%; padding: 10px 14px;
            background: rgba(255,255,255,0.04);
            border: 1px solid rgba(139,92,246,0.25);
            border-radius: 8px; font-size: 0.95rem; outline: none;
            transition: border-color 0.2s; color: #f8fafc;
        }
        .form-control:focus { border-color: #8b5cf6; box-shadow: 0 0 0 3px rgba(139,92,246,0.2); }
        .form-control option { background: #0f1123; color: #f8fafc; }

        .btn-forecast {
            width: 100%;
            background: linear-gradient(135deg, #5f3bf6, #8b5cf6);
            color: #ffffff; border: none; padding: 12px; border-radius: 10px;
            font-weight: 700; cursor: pointer; display: inline-flex;
            align-items: center; justify-content: center; gap: 8px;
            transition: all 0.25s; font-family: 'Outfit', sans-serif;
            box-shadow: 0 4px 15px rgba(95,59,246,0.4); letter-spacing: 0.3px;
        }
        .btn-forecast:hover { opacity: 0.9; transform: translateY(-1px); box-shadow: 0 6px 20px rgba(95,59,246,0.55); }
        .btn-forecast:disabled { background: rgba(148,163,184,0.2); cursor: not-allowed; box-shadow: none; color: #707ea8; }

        /* Modal */
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(5,5,20,0.75); z-index: 1000; justify-content: center; align-items: center; backdrop-filter: blur(8px); }
        .modal.active { display: flex; }
        .modal-content {
            background: rgba(15,17,35,0.98);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(139,92,246,0.3);
            border-radius: 16px; width: 650px; max-width: 90%; max-height: 80vh;
            overflow-y: auto; box-shadow: 0 25px 60px rgba(0,0,0,0.6), 0 0 40px rgba(139,92,246,0.15);
            color: #f8fafc;
        }
        .modal-header {
            padding: 20px;
            border-bottom: 1px solid rgba(139,92,246,0.2);
            display: flex; justify-content: space-between; align-items: center;
            background: linear-gradient(135deg, rgba(95,59,246,0.15), rgba(139,92,246,0.15));
        }
        .modal-header h3 { margin: 0; font-size: 1.2rem; font-family: 'Outfit', sans-serif; color: #f8fafc; }
        .modal-close { background: none; border: none; font-size: 1.5rem; cursor: pointer; color: #9fa9cb; transition: color 0.2s; }
        .modal-close:hover { color: #f8fafc; }
        .modal-body { padding: 20px; }

        /* "Xem JSON" button */
        .btn-detail-json {
            background: rgba(37,99,235,0.1) !important;
            border: 1px solid rgba(37,99,235,0.3) !important;
            color: #818cf8 !important;
            cursor: pointer; font-weight: 600; padding: 4px 10px !important;
            border-radius: 6px; transition: all 0.2s;
        }
        .btn-detail-json:hover { background: rgba(37,99,235,0.2) !important; color: #a5b4fc !important; }

        /* JSON block */
        .json-block {
            background: rgba(10,11,24,0.9);
            color: #38bdf8; padding: 16px; border-radius: 10px;
            font-family: 'Courier New', Courier, monospace; font-size: 0.85rem;
            white-space: pre-wrap; overflow-x: auto; max-height: 350px;
            border: 1px solid rgba(56,189,248,0.2);
        }

        .toast-container { position: fixed; bottom: 24px; right: 24px; z-index: 10000; }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-space-overrides.css?v=1.0">
</head>
<body class="dashboard-body tb-cosmic">

<div class="dashboard-wrapper">
    <!-- -- Left Sidebar -- -->
    <c:set var="activePage" value="forecast" scope="request" />
    <jsp:include page="sidebar.jsp" />

    <!-- -- Main Content Area -- -->
    <main class="main-content">
        <!-- Top Header -->
        <header class="top-header">
            <h1>D? Báo &amp; Phân Tích Xu Hu?ng</h1>
            <jsp:include page="admin-header-right.jsp" />
        </header>

        <!-- KPI Grid -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-header">
                    <span class="stat-title">Ð? tin c?y mô hình</span>
                    <div class="stat-icon blue"><i data-lucide="shield-check"></i></div>
                </div>
                <span class="stat-value" id="kpi-confidence">85.0%</span>
                <div class="stat-footer"><span>D?a trên h? s? xác d?nh R²</span></div>
            </div>
            <div class="stat-card">
                <div class="stat-header">
                    <span class="stat-title">D? báo doanh thu tháng t?i</span>
                    <div class="stat-icon green"><i data-lucide="line-chart"></i></div>
                </div>
                <span class="stat-value" id="kpi-revenue">Ðang tính...</span>
                <div class="stat-footer"><span>H?i quy tuy?n tính 6 tháng</span></div>
            </div>
            <div class="stat-card">
                <div class="stat-header">
                    <span class="stat-title">Tour nhu c?u cao nh?t</span>
                    <div class="stat-icon orange"><i data-lucide="flame"></i></div>
                </div>
                <span class="stat-value" id="kpi-demand" style="font-size: 1.15rem; font-weight: 800; line-height: 2.2rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; display: block;">Ðang quét...</span>
                <div class="stat-footer"><span>Quét l?p d?y &amp; lu?t d?t ch?</span></div>
            </div>
        </div>

        <!-- Main Forecast Grid -->
        <div class="forecast-grid">
            
            <!-- Left Side: Interactive Chart & Control Panel -->
            <div>
                <!-- Control Panel -->
                <div class="control-card">
                    <h3><i data-lucide="sliders-horizontal" style="width:18px;height:18px;vertical-align:middle;margin-right:8px;"></i> B? Ði?u Khi?n D? Báo Th?ng Kê</h3>
                    <form id="forecast-form">
                        <div class="form-group">
                            <label for="forecast-type">Ch?n Ch? S? C?n D? Báo</label>
                            <select id="forecast-type" class="form-control">
                                <option value="Revenue">D? báo Doanh Thu (H?i quy tuy?n tính y=ax+b)</option>
                                <option value="BookingTrend">D? báo Lu?t Ð?t Tour (H?i quy tuy?n tính y=ax+b)</option>
                                <option value="Demand">D? báo Nhu C?u Các Tour Hot (Moving Average)</option>
                            </select>
                        </div>
                        <button type="button" id="btn-run-forecast" class="btn-forecast">
                            <i data-lucide="play-circle"></i> Ch?y Mô hình D? báo (Generate Forecast)
                        </button>
                    </form>
                </div>

                <!-- Chart Card -->
                <div class="card" style="padding: 24px;">
                    <div class="card-header" style="padding: 0; margin-bottom: 20px;">
                        <h3 id="chart-title">Bi?u d? Xu hu?ng &amp; D? báo</h3>
                    </div>
                    <div class="card-body" style="padding: 0; position: relative; height: 350px;">
                        <canvas id="forecastChart"></canvas>
                    </div>
                </div>
            </div>

            <!-- Right Side: Log History -->
            <div class="card" style="padding: 24px; display: flex; flex-direction: column;">
                <div class="card-header" style="padding: 0; margin-bottom: 20px;">
                    <h3 style="font-family: 'Outfit', sans-serif; font-size: 1.1rem;">L?ch s? ch?y mô hình</h3>
                </div>
                <div style="overflow-x: auto; flex-grow: 1;">
                    <table class="booking-table" style="width: 100%; border-collapse: collapse; font-size: 0.85rem;">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Lo?i</th>
                                <th>Ð? tin c?y</th>
                                <th>Ngày ch?y</th>
                                <th>Hành d?ng</th>
                            </tr>
                        </thead>
                        <tbody id="history-tbody">
                            <c:choose>
                                <c:when test="${not empty predictionsHistory}">
                                    <c:forEach var="pr" items="${predictionsHistory}">
                                        <tr>
                                            <td style="font-weight: 600;">#${pr.predictionId}</td>
                                            <td>
                                                <span class="status-badge role-guide">${pr.predictionType}</span>
                                            </td>
                                            <td style="font-weight: 600;">
                                                <fmt:formatNumber value="${pr.confidence}" maxFractionDigits="1"/>%
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${pr.generatedAt}" pattern="dd/MM/yyyy"/>
                                            </td>
                                            <td>
                                                <button class="btn-detail-json" 
                                                        data-type="${pr.predictionType}"
                                                        data-confidence="${pr.confidence}%"
                                                        data-input='<c:out value="${pr.inputData}"/>' 
                                                        data-result='<c:out value="${pr.resultData}"/>'>
                                                    Xem JSON
                                                </button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="5" class="empty-state">
                                            Chua có snapshot d? báo nào du?c luu.
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
            <h3 id="modal-title">Chi ti?t Snapshot D? Báo</h3>
            <button class="modal-close" id="btn-close-modal">&times;</button>
        </div>
        <div class="modal-body">
            <div style="margin-bottom: 16px;">
                <strong>Lo?i d? báo:</strong> <span id="modal-type" style="margin-right: 20px;">-</span>
                <strong>Ð? tin c?y:</strong> <span id="modal-confidence">-</span>
            </div>
            <div style="margin-bottom: 12px;">
                <strong style="display: block; margin-bottom: 6px; color: #9fa9cb;">D? li?u l?ch s? d?u vào (InputData):</strong>
                <pre class="json-block" id="modal-input-json"></pre>
            </div>
            <div>
                <strong style="display: block; margin-bottom: 6px; color: #9fa9cb;">K?t qu? d? doán d?u ra (ResultData):</strong>
                <pre class="json-block" id="modal-result-json"></pre>
            </div>
        </div>
    </div>
</div>

<div id="toastContainer" class="toast-container"></div>

<script>
    window.contextPath = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/js/admin-forecast.js?v=1.1" charset="UTF-8"></script>
<script>
    if (window.lucide) { window.lucide.createIcons(); }
</script>
</body>
</html>
