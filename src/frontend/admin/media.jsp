<%-- 
    Màn hình 22: Manage Tour Media - Quản lý hình ảnh & media của tour
    Tác giả: Dương Quang Sơn
    MSSV: HE186525
    Ngày tạo: 2026-07-21
--%>
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
    <title>Th&#432; Vi&#7879;n Media &#151; TourBuddy Enterprise</title>
    <!-- Outfit & Inter Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <!-- Lucide Icons & FontAwesome CDNs -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.3">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-media.css?v=1.2">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-space-overrides.css?v=1.0">
</head>
<body class="dashboard-body tb-cosmic">

<div class="dashboard-wrapper">
    <c:set var="activePage" value="media" scope="request" />
    <jsp:include page="sidebar.jsp" />

    <!-- -- Main Content Area -- -->
    <main class="main-content theme-light">
        <!-- Top Header -->
        <header class="top-header">
            <h1>Qu&#7843;n l&#253; Th&#432; vi&#7879;n Media</h1>
            <div class="header-right">
                <div class="header-search">
                    <i data-lucide="search"></i>
                    <input type="text" placeholder="T&#236;m ki&#7871;m nhanh...">
                </div>
                
                <div class="profile-user" style="cursor: pointer;">
                    <div class="profile-meta" style="text-align: right; margin-right: 5px;">
                        <span class="name">${not empty sessionUser.fullName ? sessionUser.fullName : 'Sarah Jenkins'}</span>
                        <span class="role">Qu&#7843;n tr&#7883; vi&#234;n</span>
                    </div>
                    <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80" alt="Avatar">
                </div>
            </div>
        </header>

        <!-- Selector and Action bar -->
        <div class="control-bar">
            <div class="selector-group">
                <span class="control-label">Ch&#7885;n Tour:</span>
                <select class="custom-select" id="tour-selector" onchange="loadMedia(this.value)">
                    <option value="">-- Ch&#7885;n Tour &#273;&#7875; xem &#7843;nh/video --</option>
                    <c:forEach var="t" items="${tours}">
                        <option value="${t.tourId}">${t.tourName}</option>
                    </c:forEach>
                </select>
            </div>
            <button class="btn-primary" onclick="openAddMediaModal()">
                <i data-lucide="plus"></i> Th&#234;m Media Asset
            </button>
        </div>

        <!-- Media Grid Container -->
        <div class="media-grid" id="media-grid-container">
            <div class="empty-state" style="grid-column: 1 / -1;">
                <i data-lucide="image" style="width: 48px; height: 48px;"></i>
                <h4>Ch&#432;a ch&#7885;n Tour</h4>
                <p>Vui l&#242;ng ch&#7885;n m&#7897;t tour &#7903; tr&#234;n &#273;&#7875; hi&#7875;n th&#7883; th&#432; vi&#7879;n h&#236;nh &#7843;nh v&#224; video c&#7911;a tour &#273;&#243;.</p>
            </div>
        </div>
    </main>
</div>

<!-- -- MODAL 1: MEDIA FORM (ADD/EDIT) -- -->
<div class="modal-backdrop" id="media-modal">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 id="media-modal-title">Th&#234;m Media Asset</h3>
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
                        <label>Ngu&#7891;n ph&#431;&#417;ng ti&#7879;n</label>
                        <select name="mediaSource" id="form-media-source" class="form-control" onchange="toggleMediaSource()">
                            <option value="url">&#272;&#432;&#7901;ng d&#7851;n URL (External Link)</option>
                            <option value="local">T&#7843;i &#7843;nh t&#7913; thi&#7871;t b&#7883; (Local File)</option>
                        </select>
                    </div>
                    <div class="form-group form-grid-full" id="group-media-url">
                        <label>&#272;&#432;&#7901;ng d&#7851;n Media URL *</label>
                        <input type="text" name="mediaUrl" id="form-media-url" class="form-control" placeholder="Nh&#7853;p URL (https://...) ho&#7863;c &#273;&#432;&#7901;ng d&#7851;n n&#7899;i b&#7899; (v&#237; d&#7909;: assets/images/tour_sapa.png)" required>
                    </div>
                    <div class="form-group form-grid-full" id="group-media-file" style="display: none;">
                        <label>Ch&#7885;n t&#7853;p tin t&#7913; thi&#7871;t b&#7883; *</label>
                        <input type="file" name="mediaFile" id="form-media-file" class="form-control" accept="image/*,video/*">
                    </div>
                    <div class="form-group">
                        <label>Lo&#7841;i Ph&#431;&#417;ng Ti&#7879;n</label>
                        <select name="mediaType" id="form-media-type" class="form-control">
                            <option value="Image">Image (H&#236;nh &#7843;nh)</option>
                            <option value="Video">Video (Phim/&#272;o&#7841;n phim)</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Th&#7913; t&#7921; hi&#7875;n th&#7883; (Sort Order)</label>
                        <input type="number" name="sortOrder" id="form-media-sort" class="form-control" min="0" value="0">
                    </div>
                    <div class="form-group">
                        <label>Tr&#7840;ng Th&#193;i Hi&#7875;n Th&#7883;</label>
                        <select name="isVisible" id="form-media-visible" class="form-control">
                            <option value="true">Hi&#7875;n th&#7883; c&#244;ng khai (Visible)</option>
                            <option value="false">&#7848;n t&#7841;m th&#7901;i (Hidden)</option>
                        </select>
                    </div>
                    <div class="form-group form-grid-full">
                        <label>M&#244; t&#7843; ng&#7855;n / Ch&#250; th&#237;ch &#7843;nh (Caption)</label>
                        <textarea name="caption" id="form-media-caption" class="form-control" rows="3" placeholder="Vi&#7871;t m&#244; t&#7843; ng&#7855;n g&#7885;n cho h&#236;nh &#7843;nh/video n&#224;y..."></textarea>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-secondary" onclick="closeModal('media-modal')">H&#7911;y b&#7887;</button>
                <button type="submit" class="btn-primary">L&#432;u Media</button>
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
        <div class="lightbox-caption" id="lightbox-caption-text">M&#244; t&#7843; chi ti&#7871;t &#7843;nh</div>
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
        captionText.innerText = caption || 'Kh\u00f4ng c\u00f3 m\u00f4 t?';

        if (mediaType === 'Image') {
            container.innerHTML = '<img src="' + mediaUrl + '" alt="Preview Image" class="lightbox-media">';
        } else {
            // Ki?m tra xem l\u00e0 link file MP4 tr?c ti?p hay YouTube
            if (mediaUrl.includes('youtube.com') || mediaUrl.includes('youtu.be') || mediaUrl.includes('embed')) {
                // Chu?n h\u00f3a link YouTube sang link nh\u00fang iframe
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
                    <h4>Ch&#432;a ch&#7885;n Tour</h4>
                    <p>Vui l&#242;ng ch&#7885;n m&#7897;t tour &#7903; tr&#234;n &#273;&#7875; hi&#7875;n th&#7883; th&#432; vi&#7879;n h&#236;nh &#7843;nh v&#224; video c&#7911;a tour &#273;&#243;.</p>
                </div>`;
            lucide.createIcons();
            currentMediaList = [];
            return;
        }

        grid.innerHTML = `
            <div style="grid-column: 1 / -1; text-align: center; padding: 4rem 0; color: var(--text-gray);">
                <i class="fa-solid fa-circle-notch fa-spin fa-2xl" style="color: #8b5cf6; margin-bottom: 1rem;"></i>
                <p>&#272;&#259;ng t&#7843;i th&#432; vi&#7879;n h&#236;nh &#7843;nh & video...</p>
            </div>`;

        fetch(`?ajax=true&action=getMedia&tourId=\${tourId}`)
            .then(res => res.json())
            .then(mediaList => {
                currentMediaList = mediaList;
                if (mediaList.length === 0) {
                    grid.innerHTML = `
                        <div class="empty-state" style="grid-column: 1 / -1;">
                            <i data-lucide="image-off" style="width: 48px; height: 48px;"></i>
                            <h4>Ch&#432;a c&#243; h&#236;nh &#7843;nh hay video</h4>
                            <p>Tour n&#224;y ch&#432;a c&#243; t&#432; li&#7879;u truy&#7873;n th&#244;ng n&#224;o. Click "Th&#234;m Media Asset" &#273;&#7875; t&#7843;i l&#234;n &#7843;nh &#273;&#7847;u ti&#234;n.</p>
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
                                        \${m.caption || 'Xem &#7843;nh/video l&#7899;n'}
                                    </div>
                                    
                                    <div class="overlay-footer">
                                        <div class="sort-controls">
                                            <button class="btn-sort" title="Di chuy?n l\u00ean" onclick="shiftOrder(\${idx}, -1)" \${idx === 0 ? 'disabled style="opacity:0.3;"' : ''}>
                                                <i data-lucide="arrow-left" style="width:14px; height:14px;"></i>
                                            </button>
                                            <button class="btn-sort" title="Di chuy?n xu?ng" onclick="shiftOrder(\${idx}, 1)" \${idx === mediaList.length - 1 ? 'disabled style="opacity:0.3;"' : ''}>
                                                <i data-lucide="arrow-right" style="width:14px; height:14px;"></i>
                                            </button>
                                        </div>
                                        
                                        <div class="action-btn-group">
                                            <button class="btn-icon edit" title="S&#7917;a th&#244;ng tin" onclick="openEditMediaModal(\${JSON.stringify(m).replace(/"/g, '&quot;')})">
                                                <i data-lucide="edit-3" style="width:16px; height:16px;"></i>
                                            </button>
                                            <button class="btn-icon" title="&#7848;n/Hi&#7875;n" onclick="toggleVisibility(\${m.mediaId}, \${!m.isVisible})" \${visibilityColor}>
                                                <i data-lucide="\${visibilityIcon}" style="width:16px; height:16px;"></i>
                                            </button>
                                            <button class="btn-icon delete" title="X&#243;a" onclick="deleteMedia(\${m.mediaId})">
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
                        C&#243; l&#7895;i x&#7843;y ra khi t&#7843;i danh s&#225;ch ph&#431;&#417;ng ti&#7879;n truy&#7873;n th&#244;ng. Vui l&#242;ng th&#7917; l&#7841;i.
                    </div>`;
            });
    }

    function openAddMediaModal() {
        const tourId = document.getElementById("tour-selector").value;
        if (!tourId) {
            alert("Vui l&#242;ng ch&#7885;n m&#7897;t Tour tr&#432;&#7899;c khi th&#234;m h&#236;nh &#7843;nh/video!");
            return;
        }

        document.getElementById("media-form").reset();
        document.getElementById("media-modal-title").innerText = "Th\u00eam Media Asset";
        document.getElementById("media-action").value = "addMedia";
        document.getElementById("form-media-id").value = "";
        document.getElementById("form-media-tour-id").value = tourId;
        
        // G\u00e1n sortOrder m?c d?nh b?ng s? lu?ng hi?n t?i
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
            alert("L&#7895;i k&#7871;t n&#7889;i m&#225;y ch&#7911;.");
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
            alert("L&#7895;i k&#7871;t n&#7889;i khi thay &#273;&#7893;i tr&#7840;ng th&#193;i hi&#7875;n th&#7883;.");
        });
    }

    // Ho\u00e1n d?i nhanh v? tr\u00ed (SortOrder) c?a 2 card k? c?n
    function shiftOrder(currentIndex, direction) {
        const targetIndex = currentIndex + direction;
        if (targetIndex < 0 || targetIndex >= currentMediaList.length) return;

        const currentMedia = currentMediaList[currentIndex];
        const targetMedia = currentMediaList[targetIndex];

        // Ho\u00e1n d?i sortOrder t?m th?i
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
            alert("L&#7895;i k&#7871;t n&#7889;i khi thay &#273;&#7893;i th&#7913; t&#7921; s&#7855;p x&#7871;p.");
        });
    }

    function deleteMedia(mediaId) {
        if (!confirm("B&#7841;n c&#243; ch&#7855;c ch&#7855;n mu&#7889;n x&#243;a &#7843;nh/video t&#432; li&#7879;u n&#224;y kh&#7883; Tour?")) {
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
            alert("L&#7895;i h&#7879; th&#7889;ng khi x&#243;a ph&#431;&#417;ng ti&#7879;n.");
        });
    }
</script>
</body>
</html>
