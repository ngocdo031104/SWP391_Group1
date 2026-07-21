document.addEventListener("DOMContentLoaded", () => {
    // Kh\u1edfi t\u1ea1o bi\u1ec3u t\u01b0\u1ee3ng Lucide
    if (window.lucide) {
        window.lucide.createIcons();
    }

    const searchInput = document.getElementById("search-input");
    const unassignBtns = document.querySelectorAll(".btn-unassign-guide");

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

    // 1. X\u1eed l\u00fd h\u00e0nh \u0111\u1ed9ng H\u1ee7y ph\u00e2n c\u00f4ng
    unassignBtns.forEach(btn => {
        btn.addEventListener("click", () => {
            const scheduleId = btn.getAttribute("data-schedule-id");
            const guideId = btn.getAttribute("data-guide-id");
            const tourName = btn.getAttribute("data-tour-name");
            const guideName = btn.getAttribute("data-guide-name");

            if (confirm(`B\u1ea1n c\u00f3 ch\u1eafc ch\u1eafn mu\u1ed1n h\u1ee7y ph\u00e2n c\u00f4ng H\u01b0\u1edbng d\u1eabn vi\u00ean ${guideName} cho tour "${tourName}" kh\u00f4ng?`)) {
                executeUnassign(scheduleId, guideId);
            }
        });
    });

    function executeUnassign(scheduleId, guideId) {
        const contextPath = window.contextPath || '';
        const params = new URLSearchParams();
        params.append("action", "unassign");
        params.append("scheduleId", scheduleId);
        params.append("guideId", guideId);

        fetch(`${contextPath}/admin/assignments`, {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: params
        })
        .then(res => {
            if (!res.ok) throw new Error("Y\u00eau c\u1ea7u h\u1ee7y ph\u00e2n c\u00f4ng th\u1ea5t b\u1ea1i");
            return res.json();
        })
        .then(data => {
            if (data.status === "success") {
                alert(data.message); // S\u1eed d\u1ee5ng alert \u0111\u1ed3ng b\u1ed9 tr\u01b0\u1edbc khi reload
                window.location.reload();
            } else {
                alert(data.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert("L\u1ed7i h\u1ec7 th\u1ed1ng khi g\u1eedi y\u00eau c\u1ea7u h\u1ee7y ph\u00e2n c\u00f4ng!");
        });
    }

    // 2. X\u1eed l\u00fd T\u00ecm ki\u1ebfm server-side c\u00f3 Debounce
    let searchTimeout = null;
    if (searchInput) {
        // \u0110\u01b0a con tr\u1ecf chu\u1ed9t v\u1ec1 cu\u1ed1i input khi load trang
        const val = searchInput.value;
        searchInput.focus();
        searchInput.value = '';
        searchInput.value = val;

        searchInput.addEventListener("input", function() {
            clearTimeout(searchTimeout);
            const query = this.value.trim();
            searchTimeout = setTimeout(() => {
                const contextPath = window.contextPath || '';
                window.location.href = `${contextPath}/admin/assignments?search=${encodeURIComponent(query)}`;
            }, 600); // \u0110\u1ee3i 600ms sau khi ng\u01b0\u1eddi d\u00f9ng d\u1eebng g\u00f5 \u0111\u1ec3 submit l\u00ean server
        });
    }
});
