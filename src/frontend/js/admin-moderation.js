document.addEventListener("DOMContentLoaded", () => {
    const tabs = document.querySelectorAll(".mod-tab");
    const panels = document.querySelectorAll(".tab-panel");
    const reasonModal = document.getElementById("reason-modal");
    const btnCloseModal = document.getElementById("btn-close-modal");
    const btnCancelModal = document.getElementById("btn-cancel-modal");
    const btnConfirmHide = document.getElementById("btn-confirm-hide");
    const selectReason = document.getElementById("moderation-reason");
    const inputCustomReason = document.getElementById("moderation-reason-custom");
    const filterCheckbox = document.getElementById("filter-flagged-only");

    let currentModeration = {
        entityType: "",
        entityId: null
    };

    // Toggle custom reason input field
    selectReason.addEventListener("change", () => {
        if (selectReason.value === "Kh\u00e1c") {
            inputCustomReason.style.display = "block";
            inputCustomReason.value = "";
        } else {
            inputCustomReason.style.display = "none";
        }
    });

    // Toast helper
    function showToast(message, type = 'success') {
        let container = document.getElementById('toastContainer');
        if (!container) {
            container = document.createElement('div');
            container.id = 'toastContainer';
            container.className = 'toast-container';
            document.body.appendChild(container);
        }
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        
        let icon = 'check-circle';
        if (type === 'error') icon = 'alert-triangle';
        else if (type === 'warning') icon = 'alert-circle';
        
        toast.innerHTML = `<i data-lucide="${icon}"></i> <span>${message}</span>`;
        container.appendChild(toast);
        
        if (window.lucide) {
            window.lucide.createIcons();
        }
        
        setTimeout(() => {
            toast.style.animation = 'slideOut 0.3s ease forwards';
            setTimeout(() => toast.remove(), 300);
        }, 3000);
    }

    // Format date string
    function formatDate(timeString) {
        if (!timeString) return "-";
        const date = new Date(timeString);
        return String(date.getDate()).padStart(2, '0') + '/' + 
               String(date.getMonth() + 1).padStart(2, '0') + '/' + 
               date.getFullYear() + ' ' + 
               String(date.getHours()).padStart(2, '0') + ':' + 
               String(date.getMinutes()).padStart(2, '0');
    }

    // Filter flagged content only client-side
    function applyFlaggedFilter() {
        const checked = filterCheckbox.checked;
        const tabPanels = document.querySelectorAll(".tab-panel");
        tabPanels.forEach(panel => {
            const rows = panel.querySelectorAll("tbody tr");
            rows.forEach(row => {
                if (row.cells.length === 1) return; // Skip spinner or empty row
                const isFlaggedRow = row.querySelector(".status-flagged") !== null;
                if (checked) {
                    if (isFlaggedRow) {
                        row.style.display = "";
                    } else {
                        row.style.display = "none";
                    }
                } else {
                    row.style.display = "";
                }
            });
        });
    }

    filterCheckbox.addEventListener("change", applyFlaggedFilter);

    // API calls to load content
    function loadData(tabId) {
        const contextPath = window.contextPath || '';
        let type = "";
        let tbody = null;

        if (tabId === "tab-reviews") {
            type = "reviews";
            tbody = document.getElementById("reviews-tbody");
        } else if (tabId === "tab-posts") {
            type = "posts";
            tbody = document.getElementById("posts-tbody");
        } else if (tabId === "tab-comments") {
            type = "comments";
            tbody = document.getElementById("comments-tbody");
        } else if (tabId === "tab-history") {
            type = "history";
            tbody = document.getElementById("history-tbody");
        }

        if (!tbody) return;
        tbody.innerHTML = `<tr><td colspan="10" style="text-align:center; padding: 20px; color:#64748b;"><i class="fa fa-spinner fa-spin"></i> \u0110ang t\u1ea3i d\u1eef li\u1ec7u...</td></tr>`;

        fetch(`${contextPath}/admin/moderation?ajax=true&type=${type}`)
            .then(res => {
                if (!res.ok) throw new Error("Kh\u00f4ng th\u1ec3 t\u1ea3i danh s\u00e1ch");
                return res.json();
            })
            .then(data => {
                tbody.innerHTML = "";
                if (data.length === 0) {
                    let colSpan = tabId === "tab-history" ? 8 : 8;
                    tbody.innerHTML = `<tr><td colspan="${colSpan}" style="text-align:center; padding: 20px; color:#94a3b8;">Kh\u00f4ng t\u00ecm th\u1ea5y d\u1eef li\u1ec7u n\u00e0o.</td></tr>`;
                    return;
                }

                if (type === "reviews") {
                    renderReviews(data, tbody);
                } else if (type === "posts") {
                    renderPosts(data, tbody);
                } else if (type === "comments") {
                    renderComments(data, tbody);
                } else if (type === "history") {
                    renderHistory(data, tbody);
                }

                applyFlaggedFilter();
            })
            .catch(err => {
                console.error(err);
                tbody.innerHTML = `<tr><td colspan="10" style="text-align:center; padding: 20px; color:#ef4444;">L\u1ed7i k\u1ebft n\u1ed1i c\u01a1 s\u1edf d\u1eef li\u1ec7u.</td></tr>`;
            });
    }

    // Render HTML functions
    function renderReviews(data, tbody) {
        data.forEach(r => {
            const tr = document.createElement("tr");
            tr.style.borderBottom = "1px solid #e2e8f0";
            
            const badgeClass = r.isVisible ? "status-active" : "status-hidden";
            const badgeText = r.isVisible ? "\u0110ang hi\u1ec3n th\u1ecb" : "\u0110\u00e3 \u1ea9n";
            
            const flaggedBadge = r.isFlagged ? `<span class="status-badge status-flagged" style="margin-left: 6px;"><i class="fa-solid fa-flag"></i> B\u1ecb b\u00e1o c\u00e1o</span>` : "";
            
            let actionBtn = r.isVisible 
                ? `<button class="btn-hide" data-id="${r.reviewId}" data-type="Review" style="background:#ef4444; border:none; color:white; padding: 6px 12px; border-radius:6px; cursor:pointer; font-weight:600;">\u1ea8n</button>`
                : `<button class="btn-restore" data-id="${r.reviewId}" data-type="Review" style="background:#10b981; border:none; color:white; padding: 6px 12px; border-radius:6px; cursor:pointer; font-weight:600;">Kh\u00f4i ph\u1ee5c</button>`;

            if (r.isVisible && r.isFlagged) {
                actionBtn += ` <button class="btn-dismiss-flag" data-id="${r.reviewId}" data-type="Review" style="background:#64748b; border:none; color:white; padding: 6px 12px; border-radius:6px; cursor:pointer; font-weight:600; margin-left:4px;">B\u1ecf qua</button>`;
            }

            tr.innerHTML = `
                <td style="padding:12px; font-weight:600;">#${r.reviewId}</td>
                <td style="padding:12px; max-width: 150px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;" title="${r.tourName}">${r.tourName}</td>
                <td style="padding:12px; font-weight:500;">${r.authorName}</td>
                <td style="padding:12px; color:#f59e0b; font-weight:bold;"><i class="fa fa-star"></i> ${r.rating}</td>
                <td class="content-cell" style="padding:12px;" title="${r.content || ''}">${r.content || '<i>Kh\u00f4ng c\u00f3 n\u1ed9i dung</i>'}</td>
                <td style="padding:12px; color:#64748b;">${formatDate(r.createdAt)}</td>
                <td style="padding:12px;"><span class="status-badge ${badgeClass}">${badgeText}</span>${flaggedBadge}</td>
                <td style="padding:12px; text-align:center;">${actionBtn}</td>
            `;
            tbody.appendChild(tr);
        });
        bindActionEvents();
    }

    function renderPosts(data, tbody) {
        data.forEach(p => {
            const tr = document.createElement("tr");
            tr.style.borderBottom = "1px solid #e2e8f0";
            
            const badgeClass = p.isVisible ? "status-active" : "status-hidden";
            const badgeText = p.isVisible ? "\u0110ang hi\u1ec3n th\u1ecb" : "\u0110\u00e3 \u1ea9n";
            
            const flaggedBadge = p.isFlagged ? `<span class="status-badge status-flagged" style="margin-left: 6px;"><i class="fa-solid fa-flag"></i> B\u1ecb b\u00e1o c\u00e1o</span>` : "";
            
            let actionBtn = p.isVisible 
                ? `<button class="btn-hide" data-id="${p.postId}" data-type="CommunityPost" style="background:#ef4444; border:none; color:white; padding: 6px 12px; border-radius:6px; cursor:pointer; font-weight:600;">\u1ea8n</button>`
                : `<button class="btn-restore" data-id="${p.postId}" data-type="CommunityPost" style="background:#10b981; border:none; color:white; padding: 6px 12px; border-radius:6px; cursor:pointer; font-weight:600;">Kh\u00f4i ph\u1ee5c</button>`;

            if (p.isVisible && p.isFlagged) {
                actionBtn += ` <button class="btn-dismiss-flag" data-id="${p.postId}" data-type="CommunityPost" style="background:#64748b; border:none; color:white; padding: 6px 12px; border-radius:6px; cursor:pointer; font-weight:600; margin-left:4px;">B\u1ecf qua</button>`;
            }

            tr.innerHTML = `
                <td style="padding:12px; font-weight:600;">#${p.postId}</td>
                <td style="padding:12px; font-weight:500; max-width: 150px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;" title="${p.title || ''}">${p.title || '<i>Kh\u00f4ng ti\u00eau \u0111\u1ec1</i>'}</td>
                <td style="padding:12px;">${p.authorName}</td>
                <td class="content-cell" style="padding:12px;" title="${p.content}">${p.content}</td>
                <td style="padding:12px; color:#64748b;">${formatDate(p.createdAt)}</td>
                <td style="padding:12px;"><span class="status-badge ${badgeClass}">${badgeText}</span>${flaggedBadge}</td>
                <td style="padding:12px; text-align:center;">${actionBtn}</td>
            `;
            tbody.appendChild(tr);
        });
        bindActionEvents();
    }

    function renderComments(data, tbody) {
        data.forEach(c => {
            const tr = document.createElement("tr");
            tr.style.borderBottom = "1px solid #e2e8f0";
            
            const badgeClass = c.isVisible ? "status-active" : "status-hidden";
            const badgeText = c.isVisible ? "\u0110ang hi\u1ec3n th\u1ecb" : "\u0110\u00e3 \u1ea9n";
            
            const flaggedBadge = c.isFlagged ? `<span class="status-badge status-flagged" style="margin-left: 6px;"><i class="fa-solid fa-flag"></i> B\u1ecb b\u00e1o c\u00e1o</span>` : "";
            
            let actionBtn = c.isVisible 
                ? `<button class="btn-hide" data-id="${c.commentId}" data-type="Comment" style="background:#ef4444; border:none; color:white; padding: 6px 12px; border-radius:6px; cursor:pointer; font-weight:600;">\u1ea8n</button>`
                : `<button class="btn-restore" data-id="${c.commentId}" data-type="Comment" style="background:#10b981; border:none; color:white; padding: 6px 12px; border-radius:6px; cursor:pointer; font-weight:600;">Kh\u00f4i ph\u1ee5c</button>`;

            if (c.isVisible && c.isFlagged) {
                actionBtn += ` <button class="btn-dismiss-flag" data-id="${c.commentId}" data-type="Comment" style="background:#64748b; border:none; color:white; padding: 6px 12px; border-radius:6px; cursor:pointer; font-weight:600; margin-left:4px;">B\u1ecf qua</button>`;
            }

            tr.innerHTML = `
                <td style="padding:12px; font-weight:600;">#${c.commentId}</td>
                <td style="padding:12px; max-width: 150px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;" title="${c.postTitle}">${c.postTitle}</td>
                <td style="padding:12px;">${c.authorName}</td>
                <td class="content-cell" style="padding:12px;" title="${c.content}">${c.content}</td>
                <td style="padding:12px; color:#64748b;">${formatDate(c.createdAt)}</td>
                <td style="padding:12px;"><span class="status-badge ${badgeClass}">${badgeText}</span>${flaggedBadge}</td>
                <td style="padding:12px; text-align:center;">${actionBtn}</td>
            `;
            tbody.appendChild(tr);
        });
        bindActionEvents();
    }

    function renderHistory(data, tbody) {
        data.forEach(h => {
            const tr = document.createElement("tr");
            tr.style.borderBottom = "1px solid #e2e8f0";
            
            const isHide = h.action === "Hide";
            const actionBadgeColor = isHide ? "background:#fee2e2; color:#991b1b;" : "background:#d1fae5; color:#065f46;";
            const actionText = isHide ? "\u1ea8n n\u1ed9i dung" : "Kh\u00f4i ph\u1ee5c";

            let actionBtnHtml = "-";
            if (isHide && !h.isEntityVisible) {
                actionBtnHtml = `<button class="btn-restore" data-id="${h.entityId}" data-type="${h.entityType}" style="background:#10b981; border:none; color:white; padding: 6px 12px; border-radius:6px; cursor:pointer; font-weight:600;">Kh\u00f4i ph\u1ee5c</button>`;
            } else if (isHide && h.isEntityVisible) {
                actionBtnHtml = `<span style="color:#64748b; font-size:0.85rem; font-style:italic;">\u0110\u00e3 kh\u00f4i ph\u1ee5c</span>`;
            }

            tr.innerHTML = `
                <td style="padding:12px; font-weight:600;">#${h.moderationId}</td>
                <td style="padding:12px;">
                    <span style="background:#e0f2fe; color:#0369a1; padding: 2px 6px; border-radius:4px; font-size:0.75rem;">${h.entityType}</span>
                </td>
                <td style="padding:12px; font-weight:500;">#${h.entityId}</td>
                <td style="padding:12px;">
                    <span style="${actionBadgeColor} padding: 4px 8px; border-radius:6px; font-size:0.75rem; font-weight:600;">${actionText}</span>
                </td>
                <td style="padding:12px; color:#334155; font-style:italic;">"${h.reason || 'Kh\u00f4ng ghi l\u00fd do'}"</td>
                <td style="padding:12px; font-weight:500;">${h.moderatedByName}</td>
                <td style="padding:12px; color:#64748b;">${formatDate(h.moderatedAt)}</td>
                <td style="padding:12px; text-align:center;">${actionBtnHtml}</td>
            `;
            tbody.appendChild(tr);
        });
        bindActionEvents();
    }

    // Modal and submission triggers
    function bindActionEvents() {
        // Hide triggers modal
        const hideBtns = document.querySelectorAll(".btn-hide");
        hideBtns.forEach(btn => {
            btn.addEventListener("click", () => {
                currentModeration.entityType = btn.getAttribute("data-type");
                currentModeration.entityId = btn.getAttribute("data-id");

                // Reset modal fields
                selectReason.value = selectReason.options[0].value;
                inputCustomReason.style.display = "none";
                inputCustomReason.value = "";

                reasonModal.classList.add("active");
            });
        });

        // Restore triggers immediate AJAX POST
        const restoreBtns = document.querySelectorAll(".btn-restore");
        restoreBtns.forEach(btn => {
            btn.addEventListener("click", () => {
                const entityType = btn.getAttribute("data-type");
                const entityId = btn.getAttribute("data-id");
                
                executeModeration(entityType, entityId, "Restore", "Kh\u00f4i ph\u1ee5c hi\u1ec3n th\u1ecb");
            });
        });

        // Dismiss Flag triggers immediate AJAX POST
        const dismissBtns = document.querySelectorAll(".btn-dismiss-flag");
        dismissBtns.forEach(btn => {
            btn.addEventListener("click", () => {
                const entityType = btn.getAttribute("data-type");
                const entityId = btn.getAttribute("data-id");
                
                executeDismissFlag(entityType, entityId);
            });
        });
    }

    // Close Modal helpers
    function closeModal() {
        reasonModal.classList.remove("active");
    }

    btnCloseModal.addEventListener("click", closeModal);
    btnCancelModal.addEventListener("click", closeModal);
    window.addEventListener("click", (e) => {
        if (e.target === reasonModal) closeModal();
    });

    // Confirm hide button click
    btnConfirmHide.addEventListener("click", () => {
        let reason = selectReason.value;
        if (reason === "Kh\u00e1c") {
            reason = inputCustomReason.value.trim();
            if (!reason) {
                showToast("Vui l\u00f2ng \u0111i\u1ec1n chi ti\u1ebft l\u00fd do \u1ea9n!", "warning");
                return;
            }
        }
        
        closeModal();
        executeModeration(currentModeration.entityType, currentModeration.entityId, "Hide", reason);
    });

    // AJAX POST logic
    function executeModeration(entityType, entityId, action, reason) {
        const contextPath = window.contextPath || '';
        
        const params = new URLSearchParams();
        params.append("entityType", entityType);
        params.append("entityId", entityId);
        params.append("action", action);
        params.append("reason", reason);

        fetch(`${contextPath}/admin/moderation`, {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: params
        })
        .then(res => {
            if (!res.ok) throw new Error("Thao t\u00e1c ki\u1ec3m duy\u1ec7t th\u1ea5t b\u1ea1i");
            return res.json();
        })
        .then(data => {
            if (data.status === "success") {
                showToast(data.message, "success");
                
                // Reload current active tab
                const activeTab = document.querySelector(".mod-tab.active");
                if (activeTab) {
                    loadData(activeTab.getAttribute("data-target"));
                }
            } else {
                showToast(data.message, "error");
            }
        })
        .catch(err => {
            console.error(err);
            showToast("L\u1ed7i h\u1ec7 th\u1ed1ng khi g\u1eedi y\u00eau c\u1ea7u ki\u1ec3m duy\u1ec7t!", "error");
        });
    }

    // AJAX POST for dismissing flag
    function executeDismissFlag(entityType, entityId) {
        const contextPath = window.contextPath || '';
        
        const params = new URLSearchParams();
        params.append("entityType", entityType);
        params.append("entityId", entityId);
        params.append("action", "DismissFlag");

        fetch(`${contextPath}/admin/moderation`, {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: params
        })
        .then(res => {
            if (!res.ok) throw new Error("B\u1ecf qua c\u1ea3nh b\u00e1o th\u1ea5t b\u1ea1i");
            return res.json();
        })
        .then(data => {
            if (data.status === "success") {
                showToast(data.message, "success");
                const activeTab = document.querySelector(".mod-tab.active");
                if (activeTab) {
                    loadData(activeTab.getAttribute("data-target"));
                }
            } else {
                showToast(data.message, "error");
            }
        })
        .catch(err => {
            console.error(err);
            showToast("L\u1ed7i h\u1ec7 th\u1ed1ng khi g\u1eedi y\u00eau c\u1ea7u g\u1ee1 c\u1edd b\u00e1o c\u00e1o!", "error");
        });
    }

    // Tabs switching click listener
    tabs.forEach(tab => {
        tab.addEventListener("click", () => {
            tabs.forEach(t => t.classList.remove("active"));
            panels.forEach(p => p.classList.remove("active"));

            tab.classList.add("active");
            const target = tab.getAttribute("data-target");
            const panel = document.getElementById(target);
            if (panel) {
                panel.classList.add("active");
            }

            loadData(target);
        });
    });

    // Initialize Page
    loadData("tab-reviews");
});
