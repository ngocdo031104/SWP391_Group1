<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
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
    <title>Ki?m Duy?t N?i Dung — TourBuddy Enterprise</title>
    <!-- Outfit & Inter Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons & FontAwesome CDNs -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.1">
    
    <style>
        /* -- MODERATION PAGE — SPACE GLASSMORPHISM THEME -- */
        .moderation-tabs {
            display: flex; gap: 12px;
            border-bottom: 1px solid rgba(139,92,246,0.2);
            padding-bottom: 12px; margin-bottom: 24px; margin-top: 24px;
        }
        .mod-tab {
            padding: 10px 20px; font-family: 'Outfit', sans-serif; font-weight: 600; font-size: 0.95rem;
            color: #9fa9cb; background: none; border: none; cursor: pointer;
            border-radius: 8px; transition: all 0.2s; display: inline-flex; align-items: center; gap: 8px;
        }
        .mod-tab:hover { color: #f8fafc; background: rgba(139,92,246,0.1); }
        .mod-tab.active { color: #818cf8; background: rgba(95,59,246,0.15); }

        .tab-panel { display: none; }
        .tab-panel.active { display: block; }

        .status-badge { padding: 4px 8px; border-radius: 6px; font-size: 0.75rem; font-weight: 600; display: inline-block; }
        .status-active { background: rgba(16,185,129,0.15); color: #34d399; border: 1px solid rgba(16,185,129,0.25); }
        .status-hidden { background: rgba(239,68,68,0.12); color: #f87171; border: 1px solid rgba(239,68,68,0.2); }
        .status-flagged { background: rgba(234,88,12,0.15); color: #fb923c; border: 1px solid rgba(234,88,12,0.25); }

        .content-cell { max-width: 320px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .content-cell:hover { white-space: normal; word-break: break-all; }

        /* Modal */
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(5,5,20,0.75); z-index: 1000; justify-content: center; align-items: center; backdrop-filter: blur(8px); }
        .modal.active { display: flex; }
        .modal-content {
            background: rgba(15,17,35,0.98); backdrop-filter: blur(20px);
            border: 1px solid rgba(139,92,246,0.3); border-radius: 16px; width: 500px; max-width: 90%;
            box-shadow: 0 25px 60px rgba(0,0,0,0.6), 0 0 40px rgba(139,92,246,0.15); overflow: hidden;
            color: #f8fafc;
        }
        .modal-header {
            padding: 20px; border-bottom: 1px solid rgba(139,92,246,0.2);
            display: flex; justify-content: space-between; align-items: center;
            background: linear-gradient(135deg, rgba(95,59,246,0.15), rgba(139,92,246,0.15));
        }
        .modal-header h3 { margin: 0; font-size: 1.2rem; font-family: 'Outfit', sans-serif; color: #f8fafc; }
        .modal-close { background: none; border: none; font-size: 1.5rem; cursor: pointer; color: #9fa9cb; transition: color 0.2s; }
        .modal-close:hover { color: #f8fafc; }
        .modal-body { padding: 20px; }

        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: #9fa9cb; font-size: 0.85rem; }
        .form-control {
            width: 100%; padding: 10px 14px;
            background: rgba(255,255,255,0.04); border: 1px solid rgba(139,92,246,0.25);
            border-radius: 8px; font-size: 0.95rem; outline: none; transition: border-color 0.2s; color: #f8fafc;
        }
        .form-control:focus { border-color: #8b5cf6; box-shadow: 0 0 0 3px rgba(139,92,246,0.2); }
        .form-control option { background: #0f1123; color: #f8fafc; }
        .modal-footer {
            padding: 16px 20px; background: rgba(10,11,24,0.5);
            border-top: 1px solid rgba(139,92,246,0.2); display: flex; justify-content: flex-end; gap: 12px;
        }
        .btn-cancel {
            background: rgba(255,255,255,0.05); border: 1px solid rgba(139,92,246,0.3);
            padding: 8px 16px; border-radius: 8px; color: #9fa9cb; font-weight: 600; cursor: pointer; transition: all 0.2s;
        }
        .btn-cancel:hover { background: rgba(139,92,246,0.1); color: #f8fafc; }
        .btn-submit {
            background: linear-gradient(135deg, rgba(239,68,68,0.85), rgba(220,38,38,0.85));
            border: none; padding: 8px 16px; border-radius: 8px; color: #fff; font-weight: 600; cursor: pointer;
            box-shadow: 0 4px 12px rgba(239,68,68,0.3); transition: opacity 0.2s;
        }
        .btn-submit:hover { opacity: 0.9; }
        .toast-container { position: fixed; bottom: 24px; right: 24px; z-index: 10000; }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-space-overrides.css?v=1.0">
</head>
<body class="dashboard-body tb-cosmic">

<div class="dashboard-wrapper">
    <!-- -- Left Sidebar -- -->
    <c:set var="activePage" value="moderation" scope="request" />
    <jsp:include page="sidebar.jsp" />

    <!-- -- Main Content Area -- -->
    <main class="main-content">
        <!-- Top Header -->
        <header class="top-header">
            <h1>Ki?m Duy?t N?i Dung</h1>
            <jsp:include page="admin-header-right.jsp" />
        </header>

        <!-- Tab Buttons -->
        <div class="moderation-tabs">
            <button class="mod-tab active" data-target="tab-reviews">
                <i data-lucide="star"></i> Ðánh Giá Tour
            </button>
            <button class="mod-tab" data-target="tab-posts">
                <i data-lucide="file-text"></i> Bài Vi?t C?ng Ð?ng
            </button>
            <button class="mod-tab" data-target="tab-comments">
                <i data-lucide="message-square"></i> Bình Lu?n
            </button>
            <button class="mod-tab" data-target="tab-history">
                <i data-lucide="history"></i> L?ch S? Ki?m Duy?t
            </button>
        </div>
        <!-- Filter Flagged Content -->
        <div style="margin-bottom: 16px; background: rgba(22, 25, 50, 0.55); backdrop-filter: blur(14px); -webkit-backdrop-filter: blur(14px); padding: 12px 18px; border-radius: 8px; border: 1px solid rgba(139, 92, 246, 0.2); display: inline-flex; align-items: center; gap: 10px;">
            <input type="checkbox" id="filter-flagged-only" style="width: 18px; height: 18px; cursor: pointer; accent-color: #8b5cf6;">
            <label for="filter-flagged-only" style="font-weight: 600; color: #9fa9cb; cursor: pointer; font-size: 0.95rem; user-select: none;">
                <span style="color: #fb923c; display: inline-flex; align-items: center; gap: 6px;"><i class="fa-solid fa-flag"></i> Ch? hi?n th? n?i dung b? ngu?i dùng báo cáo vi ph?m (Flagged)</span>
            </label>
        </div>
        
        <!-- -- TAB 1: REVIEWS -- -->
        <div class="tab-panel active" id="tab-reviews">
            <div class="card" style="padding: 24px;">
                <div style="overflow-x: auto;">
                    <table class="booking-table" style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Tour</th>
                                <th>Tác gi?</th>
                                <th>Sao</th>
                                <th>N?i dung dánh giá</th>
                                <th>Ngày vi?t</th>
                                <th>Tr?ng thái</th>
                                <th style="text-align: center;">Hành d?ng</th>
                            </tr>
                        </thead>
                        <tbody id="reviews-tbody">
                            <!-- JS loaded -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- -- TAB 2: POSTS -- -->
        <div class="tab-panel" id="tab-posts">
            <div class="card" style="padding: 24px;">
                <div style="overflow-x: auto;">
                    <table class="booking-table" style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Tiêu d?</th>
                                <th>Tác gi?</th>
                                <th>N?i dung bài vi?t</th>
                                <th>Ngày dang</th>
                                <th>Tr?ng thái</th>
                                <th style="text-align: center;">Hành d?ng</th>
                            </tr>
                        </thead>
                        <tbody id="posts-tbody">
                            <!-- JS loaded -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- -- TAB 3: COMMENTS -- -->
        <div class="tab-panel" id="tab-comments">
            <div class="card" style="padding: 24px;">
                <div style="overflow-x: auto;">
                    <table class="booking-table" style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Bài vi?t g?c</th>
                                <th>Tác gi?</th>
                                <th>N?i dung bình lu?n</th>
                                <th>Ngày vi?t</th>
                                <th>Tr?ng thái</th>
                                <th style="text-align: center;">Hành d?ng</th>
                            </tr>
                        </thead>
                        <tbody id="comments-tbody">
                            <!-- JS loaded -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- -- TAB 4: HISTORY -- -->
        <div class="tab-panel" id="tab-history">
            <div class="card" style="padding: 24px;">
                <div style="overflow-x: auto;">
                    <table class="booking-table" style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr>
                                <th>ID Log</th>
                                <th>Lo?i n?i dung</th>
                                <th>ID n?i dung</th>
                                <th>Thao tác</th>
                                <th>Lý do ki?m duy?t</th>
                                <th>Ngu?i th?c hi?n</th>
                                <th>Th?i gian</th>
                                <th style="text-align: center;">Hành d?ng</th>
                            </tr>
                        </thead>
                        <tbody id="history-tbody">
                            <!-- JS loaded -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</div>

<!-- Reason input modal for hiding content -->
<div class="modal" id="reason-modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3>Xác nh?n ?n n?i dung</h3>
            <button class="modal-close" id="btn-close-modal">&times;</button>
        </div>
        <div class="modal-body">
            <div class="form-group">
                <label for="moderation-reason">Lý do ?n n?i dung</label>
                <select id="moderation-reason" class="form-control" style="margin-bottom: 12px;">
                    <option value="Spam / N?i dung qu?ng cáo trái phép">Spam / N?i dung qu?ng cáo trái phép</option>
                    <option value="Ngôn t? kích d?ng thù d?ch / Nh?y c?m / Xúc ph?m">Ngôn t? kích d?ng thù d?ch / Nh?y c?m / Xúc ph?m</option>
                    <option value="Thông tin sai l?ch / Gây hi?u l?m">Thông tin sai l?ch / Gây hi?u l?m</option>
                    <option value="Vi ph?m chính sách c?ng d?ng">Vi ph?m chính sách c?ng d?ng</option>
                    <option value="Khác">Lý do khác...</option>
                </select>
                <input type="text" id="moderation-reason-custom" class="form-control" placeholder="Nh?p chi ti?t lý do ?n..." style="display: none;">
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn-cancel" id="btn-cancel-modal">H?y b?</button>
            <button class="btn-submit" id="btn-confirm-hide">?n n?i dung</button>
        </div>
    </div>
</div>

<div id="toastContainer" class="toast-container"></div>

<script>
    window.contextPath = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/js/admin-moderation.js?v=1.0" charset="UTF-8"></script>
<script>
    if (window.lucide) {
        window.lucide.createIcons();
    }
</script>
</body>
</html>
