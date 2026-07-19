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
    <title>D&#7921; B&#225;o &amp; Xu H&#432;&#7899;ng &#151; TourBuddy Enterprise</title>
    <!-- Outfit & Inter Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons & FontAwesome CDNs -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.3">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        /* -- FORECAST PAGE &#151; SPACE GLASSMORPHISM THEME -- */
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
    <main class="main-content theme-light">
        <!-- Top Header -->
        <header class="top-header">
            <h1>D&#7921; B&#225;o &amp; Ph&#226;n T&#237;ch Xu H&#432;&#7899;ng</h1>
            <jsp:include page="admin-header-right.jsp" />
        </header>

        <!-- KPI Grid -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-header">
                    <span class="stat-title">&#272;&#7897; tin c&#7853;y m&#244; h&#236;nh</span>
                    <div class="stat-icon blue"><i data-lucide="shield-check"></i></div>
                </div>
                <span class="stat-value" id="kpi-confidence">85.0%</span>
                <div class="stat-footer"><span>D&#7921;a tr&#234;n h&#7879; s&#7889; x&#225;c &#273;&#7883;nh R&#178;</span></div>
            </div>
            <div class="stat-card">
                <div class="stat-header">
                    <span class="stat-title">D&#7921; b&#225;o doanh thu th&#225;ng t&#7899;i</span>
                    <div class="stat-icon green"><i data-lucide="line-chart"></i></div>
                </div>
                <span class="stat-value" id="kpi-revenue">&#272;&#259;ng t&#237;nh...</span>
                <div class="stat-footer"><span>H&#7891;i quy tuy&#7871;n t&#237;nh 6 th&#225;ng</span></div>
            </div>
            <div class="stat-card">
                <div class="stat-header">
                    <span class="stat-title">Tour nhu c&#7847;u cao nh&#7845;t</span>
                    <div class="stat-icon orange"><i data-lucide="flame"></i></div>
                </div>
                <span class="stat-value" id="kpi-demand" style="font-size: 1.15rem; font-weight: 800; line-height: 2.2rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; display: block;">&#272;&#259;ng qu&#233;t...</span>
                <div class="stat-footer"><span>Qu&#233;t l&#7893;p &#273;&#7847;y &amp; l&#432;&#7907;t &#273;&#7863;t ch&#7895;</span></div>
            </div>
        </div>

        <!-- Main Forecast Grid -->
        <div class="forecast-grid">
            
            <!-- Left Side: Interactive Chart & Control Panel -->
            <div>
                <!-- Control Panel -->
                <div class="control-card">
                    <h3><i data-lucide="sliders-horizontal" style="width:18px;height:18px;vertical-align:middle;margin-right:8px;"></i> B&#7899; &#272;i&#7873;u Khi&#7875;n D&#7921; B&#225;o Th&#7889;ng K&#234;</h3>
                    <form id="forecast-form">
                        <div class="form-group">
                            <label for="forecast-type">Ch&#7885;n Ch&#7881; S&#7889; C&#7847;n D&#7921; B&#225;o</label>
                            <select id="forecast-type" class="form-control">
                                <option value="Revenue">D&#7921; b&#225;o Doanh Thu (H&#7891;i quy tuy&#7871;n t&#237;nh y=ax+b)</option>
                                <option value="BookingTrend">D&#7921; b&#225;o L&#432;&#7907;t &#272;&#7863;t Tour (H&#7891;i quy tuy&#7871;n t&#237;nh y=ax+b)</option>
                                <option value="Demand">D&#7921; b&#225;o Nhu C&#7847;u C&#225;c Tour Hot (Moving Average)</option>
                            </select>
                        </div>
                        <button type="button" id="btn-run-forecast" class="btn-forecast">
                            <i data-lucide="play-circle"></i> Ch&#7841;y M&#244; h&#236;nh D&#7921; b&#225;o (Generate Forecast)
                        </button>
                    </form>
                </div>

                <!-- Chart Card -->
                <div class="card" style="padding: 24px;">
                    <div class="card-header" style="padding: 0; margin-bottom: 20px;">
                        <h3 id="chart-title">Bi&#7875;u &#273;&#7891; Xu H&#432;&#7899;ng &amp; D&#7921; b&#225;o</h3>
                    </div>
                    <div class="card-body" style="padding: 0; position: relative; height: 350px;">
                        <canvas id="forecastChart"></canvas>
                    </div>
                </div>
            </div>

            <!-- Right Side: Log History -->
            <div class="card" style="padding: 24px; display: flex; flex-direction: column;">
                <div class="card-header" style="padding: 0; margin-bottom: 20px;">
                    <h3 style="font-family: 'Outfit', sans-serif; font-size: 1.1rem;">L&#7883;ch s&#7917; ch&#7841;y m&#244; h&#236;nh</h3>
                </div>
                <div style="overflow-x: auto; flex-grow: 1;">
                    <table class="booking-table" style="width: 100%; border-collapse: collapse; font-size: 0.85rem;">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Lo&#7841;i</th>
                                <th>&#272;&#7897; tin c&#7853;y</th>
                                <th>Ng&#224;y ch&#7841;y</th>
                                <th>H&#192;NH &#272;&#7896;NG</th>
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
                                            Ch&#432;a c&#243; snapshot d&#7921; b&#225;o n&#224;o &#273;&#432;&#7901;c l&#432;u.
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
            <h3 id="modal-title">Chi ti&#7871;t Snapshot D&#7921; B&#225;o</h3>
            <button class="modal-close" id="btn-close-modal">&times;</button>
        </div>
        <div class="modal-body">
            <div style="margin-bottom: 16px;">
                <strong>Lo&#7841;i d&#7921; b&#225;o:</strong> <span id="modal-type" style="margin-right: 20px;">-</span>
                <strong>&#272;&#7897; tin c&#7853;y:</strong> <span id="modal-confidence">-</span>
            </div>
            <div style="margin-bottom: 12px;">
                <strong style="display: block; margin-bottom: 6px; color: #9fa9cb;">D&#7919; li&#7879;u l&#7883;ch s&#7917; &#273;&#7847;u v&#224;o (InputData):</strong>
                <pre class="json-block" id="modal-input-json"></pre>
            </div>
            <div>
                <strong style="display: block; margin-bottom: 6px; color: #9fa9cb;">K&#7871;t qu&#7843; d&#7921; &#273;o&#225;n &#273;&#7847;u ra (ResultData):</strong>
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
