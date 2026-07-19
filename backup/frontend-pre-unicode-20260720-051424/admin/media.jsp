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
    <title>Thu Vi?n Media — TourBuddy Enterprise</title>
    <!-- Outfit & Inter Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons & FontAwesome CDNs -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.1">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-media.css?v=1.2">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-space-overrides.css?v=1.0">
</head>
<body class="dashboard-body tb-cosmic">

<div class="dashboard-wrapper">
    <c:set var="activePage" value="media" scope="request" />
    <jsp:include page="sidebar.jsp" />

    <!-- -- Main Content Area -- -->
    <main class="main-content">
        <!-- Top Header -->
        <header class="top-header">
            <h1>Qu?n lý Thu vi?n Media</h1>
            <div class="header-right">
                <div class="header-search">
                    <i data-lucide="search"></i>
                    <input type="text" placeholder="Tìm ki?m nhanh...">
                </div>
                
                <div class="profile-user" style="cursor: pointer;">
                    <div class="profile-meta" style="text-align: right; margin-right: 5px;">
                        <span class="name">${not empty sessionUser.fullName ? sessionUser.fullName : 'Sarah Jenkins'}</span>
                        <span class="role">Qu?n tr? viên</span>
                    </div>
                    <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80" alt="Avatar">
                </div>
            </div>
        </header>

        <!-- Selector and Action bar -->
        <div class="control-bar">
            <div class="selector-group">
                <span class="control-label">Ch?n Tour:</span>
                <select class="custom-select" id="tour-selector" onchange="loadMedia(this.value)">
                    <option value="">-- Ch?n Tour d? xem ?nh/video --</option>
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
                <h4>Chua ch?n Tour</h4>
                <p>Vui lòng ch?n m?t tour ? trên d? hi?n th? thu vi?n hình ?nh và video c?a tour dó.</p>
            </div>
        </div>
    </main>
</div>

<!-- -- MODAL 1: MEDIA FORM (ADD/EDIT) -- -->
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
                        <label>Ngu?n phuong ti?n</label>
                        <select name="mediaSource" id="form-media-source" class="form-control" onchange="toggleMediaSource()">
                            <option value="url">Ðu?ng d?n URL (External Link)</option>
                            <option value="local">T?i ?nh t? thi?t b? (Local File)</option>
                        </select>
                    </div>
                    <div class="form-group form-grid-full" id="group-media-url">
                        <label>Ðu?ng d?n Media URL *</label>
                        <input type="text" name="mediaUrl" id="form-media-url" class="form-control" placeholder="Nh?p URL (https://...) ho?c du?ng d?n n?i b? (ví d?: assets/images/tour_sapa.png)" required>
                    </div>
                    <div class="form-group form-grid-full" id="group-media-file" style="display: none;">
                        <label>Ch?n t?p t? thi?t b? *</label>
                        <input type="file" name="mediaFile" id="form-media-file" class="form-control" accept="image/*,video/*">
                    </div>
                    <div class="form-group">
                        <label>Lo?i Phuong Ti?n</label>
                        <select name="mediaType" id="form-media-type" class="form-control">
                            <option value="Image">Image (Hình ?nh)</option>
                            <option value="Video">Video (Phim/Ðo?n phim)</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Th? t? hi?n th? (Sort Order)</label>
                        <input type="number" name="sortOrder" id="form-media-sort" class="form-control" min="0" value="0">
                    </div>
                    <div class="form-group">
                        <label>Tr?ng Thái Hi?n Th?</label>
                        <select name="isVisible" id="form-media-visible" class="form-control">
                            <option value="true">Hi?n th? công khai (Visible)</option>
                            <option value="false">?n t?m th?i (Hidden)</option>
                        </select>
                    </div>
                    <div class="form-group form-grid-full">
                        <label>Mô t? ng?n / Chú thích ?nh (Caption)</label>
                        <textarea name="caption" id="form-media-caption" class="form-control" rows="3" placeholder="Vi?t mô t? ng?n g?n cho hình ?nh/video này..."></textarea>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-secondary" onclick="closeModal('media-modal')">H?y b?</button>
                <button type="submit" class="btn-primary">Luu Media</button>
            </div>
        </form>
    </div>
</div>

<!-- -- MODAL 2: LIGHTBOX PLAYBACK PREVIEW -- -->
<div class="lightbox-backdrop" id="lightbox-modal">
    <div class="lightbox-content">
        <button class="lightbox-close" onclick="closeLightbox()">
            <i data-lucide="x"></i>
        </button>
        <div id="lightbox-container">
            <!-- N?p th? img ho?c iframe d?ng -->
        </div>
        <div class="lightbox-caption" id="lightbox-caption-text">Mô t? chi ti?t ?nh</div>
    </div>
</div>

<!-- JS Controller Logic -->
<script>
    let currentMediaList = []; // Luu tr? list media dang xem d? h? tr? d?i th? t? s?p x?p nhanh

    document.addEventListener("DOMContentLoaded", function() {
        lucide.createIcons();
    });

    function openModal(modalId) {
        document.getElementById(modalId).classList.add("open");
    }
    function closeModal(modalId) {
        document.getElementById(modalId).classList.remove("open");
    }

    // -- LIGHTBOX CONTROLS --
    function openLightbox(mediaUrl, mediaType, caption) {
        const container = document.getElementById("lightbox-container");
        const captionText = document.getElementById("lightbox-caption-text");
        
        container.innerHTML = '';
        captionText.innerText = caption || 'Không có mô t?';

        if (mediaType === 'Image') {
            container.innerHTML = '<img src="' + mediaUrl + '" alt="Preview Image" class="lightbox-media">';
        } else {
            // Ki?m tra xem là link file MP4 tr?c ti?p hay YouTube
            if (mediaUrl.includes('youtube.com') || mediaUrl.includes('youtu.be') || mediaUrl.includes('embed')) {
                // Chu?n hóa link YouTube sang link nhúng iframe
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
                    embedUrl = 'https://www.youtube.com/embed/' + videoId;
                } else if (mediaUrl.includes('youtu.be/')) {
                    const videoId = mediaUrl.split('youtu.be/')[1].split('?')[0];
                    embedUrl = 'https://www.youtube.com/embed/' + videoId;
                }
                container.innerHTML = '<iframe class="lightbox-iframe" src="' + embedUrl + '" allowfullscreen></iframe>';
            } else {
                container.innerHTML = '<video src="' + mediaUrl + '" controls autoplay class="lightbox-media"></video>';
            }
        }

        document.getElementById("lightbox-modal").classList.add("open");
        lucide.createIcons();
    }

    function closeLightbox() {
        document.getElementById("lightbox-modal").classList.remove("open");
        document.getElementById("lightbox-container").innerHTML = ''; // D?ng nh?c/video khi t?t lightbox
    }

    // -- AJAX LOADING MEDIA ASSETS --
    function loadMedia(tourId) {
        const grid = document.getElementById("media-grid-container");
        if (!tourId) {
            grid.innerHTML = `
                <div class="empty-state" style="grid-column: 1 / -1;">
                    <i data-lucide="image" style="width: 48px; height: 48px;"></i>
                    <h4>Chua ch?n Tour</h4>
                    <p>Vui lòng ch?n m?t tour ? trên d? hi?n th? thu vi?n hình ?nh và video c?a tour dó.</p>
                </div>`;
            lucide.createIcons();
            currentMediaList = [];
            return;
        }

        grid.innerHTML = `
            <div style="grid-column: 1 / -1; text-align: center; padding: 4rem 0; color: var(--text-gray);">
                <i class="fa-solid fa-circle-notch fa-spin fa-2xl" style="color: #8b5cf6; margin-bottom: 1rem;"></i>
                <p>Ðang t?i thu vi?n hình ?nh & video...</p>
            </div>`;

        fetch(`?ajax=true&action=getMedia&tourId=\${tourId}`)
            .then(res => res.json())
            .then(mediaList => {
                currentMediaList = mediaList;
                if (mediaList.length === 0) {
                    grid.innerHTML = `
                        <div class="empty-state" style="grid-column: 1 / -1;">
                            <i data-lucide="image-off" style="width: 48px; height: 48px;"></i>
                            <h4>Chua có hình ?nh hay video</h4>
                            <p>Tour này chua có tu li?u truy?n thông nào. Click "Thêm Media Asset" d? t?i lên ?nh d?u tiên.</p>
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
                                        \${m.caption || 'Xem ?nh/video l?n'}
                                    </div>
                                    
                                    <div class="overlay-footer">
                                        <div class="sort-controls">
                                            <button class="btn-sort" title="Di chuy?n lên" onclick="shiftOrder(\${idx}, -1)" \${idx === 0 ? 'disabled style="opacity:0.3;"' : ''}>
                                                <i data-lucide="arrow-left" style="width:14px; height:14px;"></i>
                                            </button>
                                            <button class="btn-sort" title="Di chuy?n xu?ng" onclick="shiftOrder(\${idx}, 1)" \${idx === mediaList.length - 1 ? 'disabled style="opacity:0.3;"' : ''}>
                                                <i data-lucide="arrow-right" style="width:14px; height:14px;"></i>
                                            </button>
                                        </div>
                                        
                                        <div class="action-btn-group">
                                            <button class="btn-icon edit" title="S?a thông tin" onclick="openEditMediaModal(\${JSON.stringify(m).replace(/"/g, '&quot;')})">
                                                <i data-lucide="edit-3" style="width:16px; height:16px;"></i>
                                            </button>
                                            <button class="btn-icon" title="?n/Hi?n" onclick="toggleVisibility(\${m.mediaId}, \${!m.isVisible})" \${visibilityColor}>
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
                        Có l?i x?y ra khi t?i danh sách phuong ti?n truy?n thông. Vui lòng th? l?i.
                    </div>`;
            });
    }

    function openAddMediaModal() {
        const tourId = document.getElementById("tour-selector").value;
        if (!tourId) {
            alert("Vui lòng ch?n m?t Tour tru?c khi thêm hình ?nh/video!");
            return;
        }

        document.getElementById("media-form").reset();
        document.getElementById("media-modal-title").innerText = "Thêm Media Asset";
        document.getElementById("media-action").value = "addMedia";
        document.getElementById("form-media-id").value = "";
        document.getElementById("form-media-tour-id").value = tourId;
        
        // Gán sortOrder m?c d?nh b?ng s? lu?ng hi?n t?i
        document.getElementById("form-media-sort").value = currentMediaList.length;

        document.getElementById("form-media-source").value = "url";
        toggleMediaSource();

        openModal("media-modal");
    }

    function openEditMediaModal(m) {
        document.getElementById("media-modal-title").innerText = "S?a Media Asset";
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
            alert("L?i k?t n?i máy ch?.");
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
            alert("L?i k?t n?i khi thay d?i tr?ng thái hi?n th?.");
        });
    }

    // Hoán d?i nhanh v? trí (SortOrder) c?a 2 card k? c?n
    function shiftOrder(currentIndex, direction) {
        const targetIndex = currentIndex + direction;
        if (targetIndex < 0 || targetIndex >= currentMediaList.length) return;

        const currentMedia = currentMediaList[currentIndex];
        const targetMedia = currentMediaList[targetIndex];

        // Hoán d?i sortOrder t?m th?i
        const tempOrder = currentMedia.sortOrder;
        currentMedia.sortOrder = targetMedia.sortOrder;
        targetMedia.sortOrder = tempOrder;

        // G?i AJAX c?p nh?t sortOrder c? 2
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
            alert("L?i k?t n?i khi thay d?i th? t? s?p x?p.");
        });
    }

    function deleteMedia(mediaId) {
        if (!confirm("B?n có ch?c ch?n mu?n xóa ?nh/video tu li?u này kh?i Tour?")) {
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
            alert("L?i h? th?ng khi xóa phuong ti?n.");
        });
    }
</script>
</body>
</html>
