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
    <title>Thư Viện Media — TourBuddy Enterprise</title>
    <!-- Outfit & Inter Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons & FontAwesome CDNs -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-media.css?v=1.2">
</head>
<body class="dashboard-body">

<div class="dashboard-wrapper">
    <c:set var="activePage" value="media" scope="request" />
    <jsp:include page="sidebar.jsp" />

    <!-- ── Main Content Area ── -->
    <main class="main-content">
        <!-- Top Header -->
        <header class="top-header">
            <h1>Quản lý Thư viện Media</h1>
            <div class="header-right">
                <div class="header-search">
                    <i data-lucide="search"></i>
                    <input type="text" placeholder="Tìm kiếm nhanh...">
                </div>
                
                <div class="profile-user" style="cursor: pointer;">
                    <div class="profile-meta" style="text-align: right; margin-right: 5px;">
                        <span class="name">${not empty sessionUser.fullName ? sessionUser.fullName : 'Sarah Jenkins'}</span>
                        <span class="role">Quản trị viên</span>
                    </div>
                    <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80" alt="Avatar">
                </div>
            </div>
        </header>

        <!-- Selector and Action bar -->
        <div class="control-bar">
            <div class="selector-group">
                <span class="control-label">Chọn Tour:</span>
                <select class="custom-select" id="tour-selector" onchange="loadMedia(this.value)">
                    <option value="">-- Chọn Tour để xem ảnh/video --</option>
                    <c:forEach var="t" items="${tours}">
                        <option value="${t.tourId}">${t.tourName}</option>
                    </c:forEach>
                </select>
            </div>
            <button class="btn-primary" onclick="openAddMediaModal()">
                <i data-lucide="plus"></i> Thêm Media Asset
            </button>
        </div>

        <!-- Media Grid Container -->
        <div class="media-grid" id="media-grid-container">
            <div class="empty-state" style="grid-column: 1 / -1;">
                <i data-lucide="image" style="width: 48px; height: 48px;"></i>
                <h4>Chưa chọn Tour</h4>
                <p>Vui lòng chọn một tour ở trên để hiển thị thư viện hình ảnh và video của tour đó.</p>
            </div>
        </div>
    </main>
</div>

<!-- ── MODAL 1: MEDIA FORM (ADD/EDIT) ── -->
<div class="modal-backdrop" id="media-modal">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 id="media-modal-title">Thêm Media Asset</h3>
            <button class="modal-close" onclick="closeModal('media-modal')">
                <i data-lucide="x"></i>
            </button>
        </div>
        <form id="media-form" onsubmit="saveMedia(event)" enctype="multipart/form-data">
            <input type="hidden" name="action" id="media-action" value="addMedia">
            <input type="hidden" name="mediaId" id="form-media-id" value="">
            <input type="hidden" name="tourId" id="form-media-tour-id" value="">
            <div class="modal-body">
                <div class="form-grid">
                    <div class="form-group form-grid-full">
                        <label>Nguồn phương tiện</label>
                        <select name="mediaSource" id="form-media-source" class="form-control" onchange="toggleMediaSource()">
                            <option value="url">Đường dẫn URL (External Link)</option>
                            <option value="local">Tải ảnh từ thiết bị (Local File)</option>
                        </select>
                    </div>
                    <div class="form-group form-grid-full" id="group-media-url">
                        <label>Đường dẫn Media URL *</label>
                        <input type="text" name="mediaUrl" id="form-media-url" class="form-control" placeholder="Nhập URL (https://...) hoặc đường dẫn nội bộ (ví dụ: assets/images/tour_sapa.png)" required>
                    </div>
                    <div class="form-group form-grid-full" id="group-media-file" style="display: none;">
                        <label>Chọn tệp từ thiết bị *</label>
                        <input type="file" name="mediaFile" id="form-media-file" class="form-control" accept="image/*,video/*">
                    </div>
                    <div class="form-group">
                        <label>Loại Phương Tiện</label>
                        <select name="mediaType" id="form-media-type" class="form-control">
                            <option value="Image">Image (Hình ảnh)</option>
                            <option value="Video">Video (Phim/Đoạn phim)</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Thứ tự hiển thị (Sort Order)</label>
                        <input type="number" name="sortOrder" id="form-media-sort" class="form-control" min="0" value="0">
                    </div>
                    <div class="form-group">
                        <label>Trạng Thái Hiển Thị</label>
                        <select name="isVisible" id="form-media-visible" class="form-control">
                            <option value="true">Hiển thị công khai (Visible)</option>
                            <option value="false">Ẩn tạm thời (Hidden)</option>
                        </select>
                    </div>
                    <div class="form-group form-grid-full">
                        <label>Mô tả ngắn / Chú thích ảnh (Caption)</label>
                        <textarea name="caption" id="form-media-caption" class="form-control" rows="3" placeholder="Viết mô tả ngắn gọn cho hình ảnh/video này..."></textarea>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-secondary" onclick="closeModal('media-modal')">Hủy bỏ</button>
                <button type="submit" class="btn-primary">Lưu Media</button>
            </div>
        </form>
    </div>
</div>

<!-- ── MODAL 2: LIGHTBOX PLAYBACK PREVIEW ── -->
<div class="lightbox-backdrop" id="lightbox-modal">
    <div class="lightbox-content">
        <button class="lightbox-close" onclick="closeLightbox()">
            <i data-lucide="x"></i>
        </button>
        <div id="lightbox-container">
            <!-- Nạp thẻ img hoặc iframe động -->
        </div>
        <div class="lightbox-caption" id="lightbox-caption-text">Mô tả chi tiết ảnh</div>
    </div>
</div>

<!-- JS Controller Logic -->
<script>
    let currentMediaList = []; // Lưu trữ list media đang xem để hỗ trợ đổi thứ tự sắp xếp nhanh

    document.addEventListener("DOMContentLoaded", function() {
        lucide.createIcons();
    });

    function openModal(modalId) {
        document.getElementById(modalId).classList.add("open");
    }
    function closeModal(modalId) {
        document.getElementById(modalId).classList.remove("open");
    }

    // ── LIGHTBOX CONTROLS ──
    function openLightbox(mediaUrl, mediaType, caption) {
        const container = document.getElementById("lightbox-container");
        const captionText = document.getElementById("lightbox-caption-text");
        
        container.innerHTML = '';
        captionText.innerText = caption || 'Không có mô tả';

        if (mediaType === 'Image') {
            container.innerHTML = `<img src="${mediaUrl}" alt="Preview Image" class="lightbox-media">`;
        } else {
            // Kiểm tra xem là link file MP4 trực tiếp hay YouTube
            if (mediaUrl.includes('youtube.com') || mediaUrl.includes('youtu.be') || mediaUrl.includes('embed')) {
                // Chuẩn hóa link YouTube sang link nhúng iframe
                let embedUrl = mediaUrl;
                if (mediaUrl.includes('watch?v=')) {
                    let videoId = '';
                    const urlParts = mediaUrl.split('?');
                    if (urlParts.length > 1) {
                        const searchParams = new URLSearchParams(urlParts[1]);
                        videoId = searchParams.get('v') || '';
                    }
                    if (!videoId) {
                        videoId = mediaUrl.split('v=')[1].split('&')[0];
                    }
                    embedUrl = `https://www.youtube.com/embed/${videoId}`;
                } else if (mediaUrl.includes('youtu.be/')) {
                    const videoId = mediaUrl.split('youtu.be/')[1].split('?')[0];
                    embedUrl = `https://www.youtube.com/embed/${videoId}`;
                }
                container.innerHTML = `<iframe class="lightbox-iframe" src="${embedUrl}" allowfullscreen></iframe>`;
            } else {
                container.innerHTML = `<video src="${mediaUrl}" controls autoplay class="lightbox-media"></video>`;
            }
        }

        document.getElementById("lightbox-modal").classList.add("open");
        lucide.createIcons();
    }

    function closeLightbox() {
        document.getElementById("lightbox-modal").classList.remove("open");
        document.getElementById("lightbox-container").innerHTML = ''; // Dừng nhạc/video khi tắt lightbox
    }

    // ── AJAX LOADING MEDIA ASSETS ──
    function loadMedia(tourId) {
        const grid = document.getElementById("media-grid-container");
        if (!tourId) {
            grid.innerHTML = `
                <div class="empty-state" style="grid-column: 1 / -1;">
                    <i data-lucide="image" style="width: 48px; height: 48px;"></i>
                    <h4>Chưa chọn Tour</h4>
                    <p>Vui lòng chọn một tour ở trên để hiển thị thư viện hình ảnh và video của tour đó.</p>
                </div>`;
            lucide.createIcons();
            currentMediaList = [];
            return;
        }

        grid.innerHTML = `
            <div style="grid-column: 1 / -1; text-align: center; padding: 4rem 0; color: var(--text-gray);">
                <i class="fa-solid fa-circle-notch fa-spin fa-2xl" style="color: #8b5cf6; margin-bottom: 1rem;"></i>
                <p>Đang tải thư viện hình ảnh & video...</p>
            </div>`;

        fetch(`?ajax=true&action=getMedia&tourId=\${tourId}`)
            .then(res => res.json())
            .then(mediaList => {
                currentMediaList = mediaList;
                if (mediaList.length === 0) {
                    grid.innerHTML = `
                        <div class="empty-state" style="grid-column: 1 / -1;">
                            <i data-lucide="image-off" style="width: 48px; height: 48px;"></i>
                            <h4>Chưa có hình ảnh hay video</h4>
                            <p>Tour này chưa có tư liệu truyền thông nào. Click "Thêm Media Asset" để tải lên ảnh đầu tiên.</p>
                        </div>`;
                    lucide.createIcons();
                    return;
                }

                let html = '';
                mediaList.forEach((m, idx) => {
                    const isImg = m.mediaType === 'Image';
                    const hiddenClass = m.isVisible ? '' : 'style="opacity: 0.65;"';
                    const visibilityIcon = m.isVisible ? 'eye' : 'eye-off';
                    const visibilityColor = m.isVisible ? '' : 'style="color: var(--error-red);"';

                    let displayUrl = m.mediaUrl;
                    if (displayUrl && !displayUrl.startsWith('http') && !displayUrl.startsWith('/')) {
                        displayUrl = '${pageContext.request.contextPath}/' + displayUrl;
                    }

                    // Thumbnail image
                    let previewHtml = '';
                    if (isImg) {
                        previewHtml = `<img src="\${displayUrl}" alt="Media Preview" class="media-preview" onerror="this.src='https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=300'">`;
                    } else {
                        // Video placeholder
                        previewHtml = `
                            <div class="video-overlay-icon"><i data-lucide="play" fill="#fff"></i></div>
                            <img src="https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=300" alt="Video Placeholder" class="media-preview" style="filter: brightness(0.45);">
                        `;
                    }

                    html += `
                        <div class="media-card" \${hiddenClass}>
                            <div class="media-container">
                                \${previewHtml}
                                
                                <!-- Hover Overlay controls -->
                                <div class="media-card-overlay">
                                    <div class="overlay-header">
                                        <span class="media-type-badge">\${m.mediaType}</span>
                                        <span class="control-label" style="font-size: 0.8rem; font-weight: 700;">#\${m.sortOrder}</span>
                                    </div>
                                    
                                    <div class="media-caption-text" onclick="openLightbox('\${displayUrl}', '\${m.mediaType}', '\${m.caption}')">
                                        \${m.caption || 'Xem ảnh/video lớn'}
                                    </div>
                                    
                                    <div class="overlay-footer">
                                        <div class="sort-controls">
                                            <button class="btn-sort" title="Di chuyển lên" onclick="shiftOrder(\${idx}, -1)" \${idx === 0 ? 'disabled style="opacity:0.3;"' : ''}>
                                                <i data-lucide="arrow-left" style="width:14px; height:14px;"></i>
                                            </button>
                                            <button class="btn-sort" title="Di chuyển xuống" onclick="shiftOrder(\${idx}, 1)" \${idx === mediaList.length - 1 ? 'disabled style="opacity:0.3;"' : ''}>
                                                <i data-lucide="arrow-right" style="width:14px; height:14px;"></i>
                                            </button>
                                        </div>
                                        
                                        <div class="action-btn-group">
                                            <button class="btn-icon edit" title="Sửa thông tin" onclick="openEditMediaModal(\${JSON.stringify(m).replace(/"/g, '&quot;')})">
                                                <i data-lucide="edit-3" style="width:16px; height:16px;"></i>
                                            </button>
                                            <button class="btn-icon" title="Ẩn/Hiện" onclick="toggleVisibility(\${m.mediaId}, \${!m.isVisible})" \${visibilityColor}>
                                                <i data-lucide="\${visibilityIcon}" style="width:16px; height:16px;"></i>
                                            </button>
                                            <button class="btn-icon delete" title="Xóa" onclick="deleteMedia(\${m.mediaId})">
                                                <i data-lucide="trash-2" style="width:16px; height:16px;"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="media-history-info">
                                <span><i data-lucide="user" style="width:12px; height:12px;"></i> \${m.uploaderName}</span>
                                <span><i data-lucide="clock" style="width:12px; height:12px;"></i> \${m.uploadedStr}</span>
                            </div>
                        </div>`;
                });
                grid.innerHTML = html;
                lucide.createIcons();
            })
            .catch(err => {
                console.error(err);
                grid.innerHTML = `
                    <div style="grid-column: 1 / -1; text-align: center; color: var(--error-red); padding: 3rem;">
                        Có lỗi xảy ra khi tải danh sách phương tiện truyền thông. Vui lòng thử lại.
                    </div>`;
            });
    }

    function openAddMediaModal() {
        const tourId = document.getElementById("tour-selector").value;
        if (!tourId) {
            alert("Vui lòng chọn một Tour trước khi thêm hình ảnh/video!");
            return;
        }

        document.getElementById("media-form").reset();
        document.getElementById("media-modal-title").innerText = "Thêm Media Asset";
        document.getElementById("media-action").value = "addMedia";
        document.getElementById("form-media-id").value = "";
        document.getElementById("form-media-tour-id").value = tourId;
        
        // Gán sortOrder mặc định bằng số lượng hiện tại
        document.getElementById("form-media-sort").value = currentMediaList.length;

        document.getElementById("form-media-source").value = "url";
        toggleMediaSource();

        openModal("media-modal");
    }

    function openEditMediaModal(m) {
        document.getElementById("media-modal-title").innerText = "Sửa Media Asset";
        document.getElementById("media-action").value = "editMedia";
        document.getElementById("form-media-id").value = m.mediaId;
        document.getElementById("form-media-tour-id").value = m.tourId;
        
        document.getElementById("form-media-url").value = m.mediaUrl;
        document.getElementById("form-media-type").value = m.mediaType;
        document.getElementById("form-media-sort").value = m.sortOrder;
        document.getElementById("form-media-visible").value = m.isVisible ? "true" : "false";
        document.getElementById("form-media-caption").value = m.caption || "";

        document.getElementById("form-media-source").value = "url";
        toggleMediaSource();

        openModal("media-modal");
    }

    function toggleMediaSource() {
        const source = document.getElementById("form-media-source").value;
        const groupUrl = document.getElementById("group-media-url");
        const groupFile = document.getElementById("group-media-file");
        const inputUrl = document.getElementById("form-media-url");
        const inputFile = document.getElementById("form-media-file");
        const isEdit = document.getElementById("media-action").value === "editMedia";
        
        if (source === "local") {
            groupUrl.style.display = "none";
            inputUrl.removeAttribute("required");
            groupFile.style.display = "block";
            if (!isEdit) {
                inputFile.setAttribute("required", "required");
            } else {
                inputFile.removeAttribute("required");
            }
        } else {
            groupUrl.style.display = "block";
            inputUrl.setAttribute("required", "required");
            groupFile.style.display = "none";
            inputFile.removeAttribute("required");
        }
    }

    function saveMedia(e) {
        e.preventDefault();
        const form = document.getElementById("media-form");
        const formData = new FormData(form);

        fetch("", {
            method: "POST",
            body: formData
        })
        .then(res => res.json())
        .then(res => {
            if (res.status === "success") {
                alert(res.message);
                closeModal("media-modal");
                loadMedia(document.getElementById("tour-selector").value);
            } else {
                alert(res.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert("Lỗi kết nối máy chủ.");
        });
    }

    function toggleVisibility(mediaId, isVisible) {
        fetch("", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: `action=toggleVisibility&mediaId=\${mediaId}&isVisible=\${isVisible}`
        })
        .then(res => res.json())
        .then(res => {
            if (res.status === "success") {
                loadMedia(document.getElementById("tour-selector").value);
            } else {
                alert(res.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert("Lỗi kết nối khi thay đổi trạng thái hiển thị.");
        });
    }

    // Hoán đổi nhanh vị trí (SortOrder) của 2 card kế cận
    function shiftOrder(currentIndex, direction) {
        const targetIndex = currentIndex + direction;
        if (targetIndex < 0 || targetIndex >= currentMediaList.length) return;

        const currentMedia = currentMediaList[currentIndex];
        const targetMedia = currentMediaList[targetIndex];

        // Hoán đổi sortOrder tạm thời
        const tempOrder = currentMedia.sortOrder;
        currentMedia.sortOrder = targetMedia.sortOrder;
        targetMedia.sortOrder = tempOrder;

        // Gọi AJAX cập nhật sortOrder cả 2
        Promise.all([
            fetch("", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: `action=updateSortOrder&mediaId=\${currentMedia.mediaId}&sortOrder=\${currentMedia.sortOrder}`
            }).then(r => r.json()),
            fetch("", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: `action=updateSortOrder&mediaId=\${targetMedia.mediaId}&sortOrder=\${targetMedia.sortOrder}`
            }).then(r => r.json())
        ])
        .then(results => {
            loadMedia(document.getElementById("tour-selector").value);
        })
        .catch(err => {
            console.error(err);
            alert("Lỗi kết nối khi thay đổi thứ tự sắp xếp.");
        });
    }

    function deleteMedia(mediaId) {
        if (!confirm("Bạn có chắc chắn muốn xóa ảnh/video tư liệu này khỏi Tour?")) {
            return;
        }

        fetch("", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: `action=deleteMedia&mediaId=\${mediaId}`
        })
        .then(res => res.json())
        .then(res => {
            if (res.status === "success") {
                alert(res.message);
                loadMedia(document.getElementById("tour-selector").value);
            } else {
                alert(res.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert("Lỗi hệ thống khi xóa phương tiện.");
        });
    }
</script>
</body>
</html>
