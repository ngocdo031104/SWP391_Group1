/**
 * \u2500\u2500 Admin Analytics JS Controller \u2500\u2500
 * Uses Chart.js for premium glassmorphic dashboard visualization.
 */
document.addEventListener("DOMContentLoaded", () => {
    // Initialize Lucide icons
    if (typeof lucide !== "undefined") {
        lucide.createIcons();
    }

    // Chart instances storage to destroy/recreate on updates
    const charts = {};

    // Base Context Path
    const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf("/admin/analytics"));

    // DOM Elements
    const tabButtons = document.querySelectorAll(".tab-btn");
    const tabPanes = document.querySelectorAll(".tab-pane");
    const btnSaveSnapshot = document.getElementById("btn-save-snapshot");
    const snapshotTypeSelect = document.getElementById("snapshot-type");
    const modalOverlay = document.getElementById("report-modal");
    const modalBody = document.getElementById("modal-body-content");
    const modalCloseBtn = document.getElementById("modal-close-btn");

    // Currency Formatter
    const formatCurrency = (val) => {
        return new Intl.NumberFormat("vi-VN", { style: "currency", currency: "VND" }).format(val);
    };

    // Tab Switching Logic
    tabButtons.forEach(btn => {
        btn.addEventListener("click", () => {
            const targetTab = btn.getAttribute("data-tab");
            
            tabButtons.forEach(b => b.classList.remove("active"));
            tabPanes.forEach(p => p.classList.remove("active"));

            btn.classList.add("active");
            document.getElementById(targetTab).classList.add("active");

            // Load tab specific data
            loadTabData(targetTab);
        });
    });

    // Load initial tab
    loadTabData("tab-revenue");

    // Fetch and Load Tab Data Function
    function loadTabData(tabId) {
        if (tabId === "tab-revenue") {
            fetchAnalytics("revenue", data => {
                renderRevenueDashboard(data);
            });
        } else if (tabId === "tab-bookings") {
            fetchAnalytics("bookings", data => {
                renderBookingsDashboard(data);
            });
        } else if (tabId === "tab-performance") {
            fetchAnalytics("performance", data => {
                renderPerformanceDashboard(data);
            });
        } else if (tabId === "tab-guides") {
            fetchAnalytics("guides", data => {
                renderGuidesDashboard(data);
            });
        } else if (tabId === "tab-reports") {
            fetchAnalytics("reports", data => {
                renderReportsDashboard(data);
            });
        }
    }

    // Async Fetch Wrapper
    function fetchAnalytics(type, callback) {
        fetch(`${contextPath}/admin/analytics?ajax=true&type=${type}`)
            .then(res => {
                if (!res.ok) throw new Error("M\u1ea5t k\u1ebft n\u1ed1i m\u00e1y ch\u1ee7");
                return res.json();
            })
            .then(data => {
                if (data.error) {
                    alert("L\u1ed7i t\u1ea3i d\u1eef li\u1ec7u: " + data.error);
                } else {
                    callback(data);
                }
            })
            .catch(err => {
                console.error(err);
                alert("Kh\u00f4ng th\u1ec3 t\u1ea3i th\u00f4ng tin th\u1ed1ng k\u00ea: " + err.message);
            });
    }

    // --- TAB 1: REVENUE ---
    function renderRevenueDashboard(data) {
        // Compute total revenue, average revenue, top category
        let totalRev = 0;
        let categoriesList = data.category || [];
        let monthlyList = data.monthly || [];
        let toursList = data.tours || [];

        monthlyList.forEach(item => totalRev += item.revenue);
        document.getElementById("kpi-total-revenue").innerText = formatCurrency(totalRev);
        
        const avgRev = monthlyList.length > 0 ? totalRev / monthlyList.length : 0;
        document.getElementById("kpi-avg-revenue").innerText = formatCurrency(avgRev);
        
        const topCatName = categoriesList.length > 0 ? categoriesList[0].category : "N/A";
        document.getElementById("kpi-top-category").innerText = topCatName;

        // 1. Tinh toan Xu huong Doanh thu gan day (So sanh thang cuoi cung vs thang ke cuoi)
        const revTrendEl = document.getElementById("kpi-revenue-trend");
        const revTrendText = document.getElementById("kpi-revenue-trend-text");
        if (monthlyList.length >= 2) {
            const lastMonthRev = monthlyList[monthlyList.length - 1].revenue;
            const prevMonthRev = monthlyList[monthlyList.length - 2].revenue;
            if (prevMonthRev > 0) {
                const percentage = ((lastMonthRev - prevMonthRev) / prevMonthRev) * 100;
                const formattedPercent = percentage.toFixed(1);
                if (percentage >= 0) {
                    revTrendEl.className = "kpi-trend up";
                    revTrendEl.innerHTML = `<i data-lucide="arrow-up-right"></i> +${formattedPercent}% so v\u1edbi th\u00e1ng tr\u01b0\u1edbc`;
                } else {
                    revTrendEl.className = "kpi-trend down";
                    revTrendEl.innerHTML = `<i data-lucide="arrow-down-right"></i> ${formattedPercent}% so v\u1edbi th\u00e1ng tr\u01b0\u1edbc`;
                }
            } else {
                revTrendEl.className = "kpi-trend up";
                revTrendText.innerText = "T\u0103ng tr\u01b0\u1edfng m\u1edbi";
            }
        } else {
            revTrendEl.className = "kpi-trend up";
            revTrendText.innerText = "Thi\u1ebfu d\u1eef li\u1ec7u so s\u00e1nh";
        }

        // 2. Tinh toan Xu huong Doanh thu trung binh thang (So sanh thang cuoi vs Doanh thu TB)
        const avgTrendEl = document.getElementById("kpi-avg-trend");
        const avgTrendText = document.getElementById("kpi-avg-trend-text");
        if (monthlyList.length > 0 && avgRev > 0) {
            const lastMonthRev = monthlyList[monthlyList.length - 1].revenue;
            const dev = ((lastMonthRev - avgRev) / avgRev) * 100;
            if (Math.abs(dev) < 10) {
                avgTrendEl.className = "kpi-trend up";
                avgTrendEl.innerHTML = `<i data-lucide="arrow-up-right"></i> \u1ed4n \u0111\u1ecbnh (\u0111\u1ed9 l\u1ec7ch ${dev.toFixed(1)}%)`;
            } else if (dev >= 10) {
                avgTrendEl.className = "kpi-trend up";
                avgTrendEl.innerHTML = `<i data-lucide="arrow-up-right"></i> T\u0103ng tr\u01b0\u1edfng (+${dev.toFixed(1)}%)`;
            } else {
                avgTrendEl.className = "kpi-trend down";
                avgTrendEl.innerHTML = `<i data-lucide="arrow-down-right"></i> Suy gi\u1ea3m (${dev.toFixed(1)}%)`;
            }
        } else {
            avgTrendEl.className = "kpi-trend up";
            avgTrendText.innerText = "\u1ed4n \u0111\u1ecbnh";
        }

        // 3. Tinh toan Hieu suat cua danh muc dan dau (Ty trong tren tong doanh thu)
        const catTrendEl = document.getElementById("kpi-category-trend");
        const catTrendText = document.getElementById("kpi-category-trend-text");
        if (categoriesList.length > 0 && totalRev > 0) {
            const topCatRev = categoriesList[0].revenue;
            const ratio = (topCatRev / totalRev) * 100;
            catTrendEl.className = "kpi-trend up";
            catTrendEl.innerHTML = `Chi\u1ebfm ${ratio.toFixed(1)}% c\u01a1 c\u1ea5u doanh thu`;
        } else {
            catTrendEl.className = "kpi-trend up";
            catTrendText.innerText = "Hi\u1ec7u su\u1ea5t cao nh\u1ea5t";
        }

        if (typeof lucide !== "undefined") {
            lucide.createIcons({ attrs: { class: "lucide-icon" } });
        }

        // Chart 1: Monthly Line Chart
        const months = monthlyList.map(item => item.month);
        const revenues = monthlyList.map(item => item.revenue);

        destroyChart("chart-monthly-revenue");
        const ctxLine = document.getElementById("chart-monthly-revenue").getContext("2d");
        const gradLine = ctxLine.createLinearGradient(0, 0, 0, 300);
        gradLine.addColorStop(0, "rgba(99, 102, 241, 0.4)");
        gradLine.addColorStop(1, "rgba(99, 102, 241, 0.0)");

        charts["chart-monthly-revenue"] = new Chart(ctxLine, {
            type: "line",
            data: {
                labels: months,
                datasets: [{
                    label: "Doanh thu (VND)",
                    data: revenues,
                    borderColor: "#6366f1",
                    backgroundColor: gradLine,
                    fill: true,
                    tension: 0.4,
                    borderWidth: 3
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: {
                        ticks: { color: "#94a3b8" },
                        grid: { color: "rgba(255,255,255,0.05)" }
                    },
                    x: {
                        ticks: { color: "#94a3b8" },
                        grid: { display: false }
                    }
                }
            }
        });

        // Chart 2: Category Doughnut Chart
        const catLabels = categoriesList.map(item => item.category);
        const catRevenues = categoriesList.map(item => item.revenue);

        destroyChart("chart-category-revenue");
        const ctxPie = document.getElementById("chart-category-revenue").getContext("2d");
        charts["chart-category-revenue"] = new Chart(ctxPie, {
            type: "doughnut",
            data: {
                labels: catLabels,
                datasets: [{
                    data: catRevenues,
                    backgroundColor: ["#4f46e5", "#10b981", "#f59e0b", "#ef4444", "#8b5cf6", "#ec4899"],
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: "right",
                        labels: { color: "#f8fafc" }
                    }
                }
            }
        });

        // Chart 3: Top Tours Bar Chart
        const tourLabels = toursList.map(item => item.tourName.substring(0, 20) + "...");
        const tourRevenues = toursList.map(item => item.revenue);

        destroyChart("chart-tour-revenue");
        const ctxBar = document.getElementById("chart-tour-revenue").getContext("2d");
        charts["chart-tour-revenue"] = new Chart(ctxBar, {
            type: "bar",
            data: {
                labels: tourLabels,
                datasets: [{
                    label: "Doanh thu",
                    data: tourRevenues,
                    backgroundColor: "#10b981",
                    borderRadius: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: {
                        ticks: { color: "#94a3b8" },
                        grid: { color: "rgba(255,255,255,0.05)" }
                    },
                    x: {
                        ticks: { color: "#94a3b8" },
                        grid: { display: false }
                    }
                }
            }
        });
    }

    // --- TAB 2: BOOKINGS ---
    function renderBookingsDashboard(data) {
        let trendsList = data.trends || [];
        let distList = data.distribution || [];

        // KPI calculations
        let totalB = 0;
        let completedB = 0;
        let pendingB = 0;
        distList.forEach(item => {
            totalB += item.count;
            if (item.status === "Completed") completedB += item.count;
            if (item.status === "PendingPayment" || item.status === "PendingApproval") pendingB += item.count;
        });

        document.getElementById("kpi-total-bookings").innerText = totalB;
        document.getElementById("kpi-completed-bookings").innerText = completedB;
        document.getElementById("kpi-pending-bookings").innerText = pendingB;

        // Chart 1: Trends Line Chart
        const trendDates = trendsList.map(item => item.date);
        const trendCounts = trendsList.map(item => item.count);

        destroyChart("chart-booking-trends");
        const ctxTrend = document.getElementById("chart-booking-trends").getContext("2d");
        const gradTrend = ctxTrend.createLinearGradient(0, 0, 0, 300);
        gradTrend.addColorStop(0, "rgba(16, 185, 129, 0.4)");
        gradTrend.addColorStop(1, "rgba(16, 185, 129, 0.0)");

        charts["chart-booking-trends"] = new Chart(ctxTrend, {
            type: "line",
            data: {
                labels: trendDates,
                datasets: [{
                    label: "S\u1ed1 l\u01b0\u1ee3t \u0111\u1eb7t ch\u1ed7",
                    data: trendCounts,
                    borderColor: "#10b981",
                    backgroundColor: gradTrend,
                    fill: true,
                    tension: 0.3,
                    borderWidth: 3
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: {
                        ticks: { color: "#94a3b8", stepSize: 1 },
                        grid: { color: "rgba(255,255,255,0.05)" }
                    },
                    x: {
                        ticks: { color: "#94a3b8" },
                        grid: { display: false }
                    }
                }
            }
        });

        // Chart 2: Doughnut Status
        const statusLabels = distList.map(item => item.status);
        const statusCounts = distList.map(item => item.count);

        destroyChart("chart-booking-status");
        const ctxStatus = document.getElementById("chart-booking-status").getContext("2d");
        charts["chart-booking-status"] = new Chart(ctxStatus, {
            type: "doughnut",
            data: {
                labels: statusLabels,
                datasets: [{
                    data: statusCounts,
                    backgroundColor: ["#f59e0b", "#6366f1", "#10b981", "#ef4444", "#64748b", "#ec4899"],
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: "right",
                        labels: { color: "#f8fafc" }
                    }
                }
            }
        });
    }

    // --- TAB 3: PERFORMANCE ---
    function renderPerformanceDashboard(data) {
        const tbody = document.getElementById("tour-performance-tbody");
        tbody.innerHTML = "";

        data.forEach(item => {
            const tr = document.createElement("tr");
            tr.innerHTML = `
                <td style="font-weight: 600;">#${item.tourId}</td>
                <td style="max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${item.tourName}</td>
                <td>${item.totalBookings}</td>
                <td>${formatCurrency(item.totalRevenue)}</td>
                <td>
                    <div style="display: flex; align-items: center; gap: 4px;">
                        <i data-lucide="star" style="width: 14px; fill: #fbbf24; stroke: #fbbf24;"></i>
                        <span>${item.avgRating.toFixed(1)}</span>
                    </div>
                </td>
                <td>
                    <div class="progress-bar-container" style="background: rgba(255,255,255,0.05); border-radius: 4px; height: 8px; width: 100px; position: relative; overflow: hidden;">
                        <div style="width: ${item.avgOccupancyRate}%; background: var(--success-green); height: 100%;"></div>
                    </div>
                    <span style="font-size: 0.75rem; color: var(--text-gray); margin-top: 4px; display: block;">${item.avgOccupancyRate.toFixed(1)}%</span>
                </td>
            `;
            tbody.appendChild(tr);
        });

        if (typeof lucide !== "undefined") {
            lucide.createIcons({ attrs: { class: "lucide-icon" } });
        }
    }

    // --- TAB 4: GUIDES ---
    function renderGuidesDashboard(data) {
        const tbody = document.getElementById("guide-activity-tbody");
        tbody.innerHTML = "";

        data.forEach(item => {
            const tr = document.createElement("tr");
            tr.innerHTML = `
                <td style="font-weight: 600;">#${item.userId}</td>
                <td>${item.fullName}</td>
                <td>${item.yearsOfExperience} n\u0103m</td>
                <td>
                    <div style="display: flex; align-items: center; gap: 4px;">
                        <i data-lucide="star" style="width: 14px; fill: #fbbf24; stroke: #fbbf24;"></i>
                        <span>${item.rating.toFixed(1)}</span>
                    </div>
                </td>
                <td>${item.totalToursLed} / ${item.assignedToursCount}</td>
                <td>${item.specialization || "T\u1ed5ng h\u1ee3p"}</td>
                <td>
                    <span class="badge-status ${item.isActive ? 'confirmed' : 'cancelled'}">
                        ${item.isActive ? '\u0110ang Ho\u1ea1t \u0110\u1ed9ng' : 'T\u1ea1m Kh\u00f3a'}
                    </span>
                </td>
            `;
            tbody.appendChild(tr);
        });

        if (typeof lucide !== "undefined") {
            lucide.createIcons({ attrs: { class: "lucide-icon" } });
        }
    }

    // --- TAB 5: REPORTS / SNAPSHOTS ---
    function renderReportsDashboard(data) {
        const tbody = document.getElementById("reports-snapshot-tbody");
        tbody.innerHTML = "";

        data.forEach(item => {
            const tr = document.createElement("tr");
            tr.innerHTML = `
                <td>#${item.reportId}</td>
                <td><span class="badge-status completed">${item.reportType}</span></td>
                <td>${item.periodStart} \u0111\u1ebfn ${item.periodEnd}</td>
                <td>${item.generatedByName || 'H\u1ec7 th\u1ed1ng'}</td>
                <td>${item.generatedAt}</td>
                <td>
                    <button class="btn-action btn-primary view-report-btn" data-id="${item.reportId}">
                        <i data-lucide="eye" style="width: 14px; height: 14px; display: inline-block; vertical-align: middle;"></i> Xem
                    </button>
                    <button class="btn-action download-csv-report-btn" data-id="${item.reportId}">
                        T\u1ea3i CSV
                    </button>
                </td>
            `;
            tbody.appendChild(tr);
        });

        if (typeof lucide !== "undefined") {
            lucide.createIcons({ attrs: { class: "lucide-icon" } });
        }

        // Attach action handlers
        document.querySelectorAll(".view-report-btn").forEach(btn => {
            btn.addEventListener("click", () => {
                const reportId = btn.getAttribute("data-id");
                showReportDetail(reportId);
            });
        });

        document.querySelectorAll(".download-csv-report-btn").forEach(btn => {
            btn.addEventListener("click", () => {
                const reportId = btn.getAttribute("data-id");
                downloadSavedReportCSV(reportId);
            });
        });
    }

    // Save Snapshot Handler
    if (btnSaveSnapshot) {
        btnSaveSnapshot.addEventListener("click", () => {
            const reportType = snapshotTypeSelect.value;
            showConfirmation(
                `B\u1ea1n c\u00f3 ch\u1eafc ch\u1eafn mu\u1ed1n ch\u1ee5p v\u00e0 l\u01b0u l\u1ea1i snapshot b\u00e1o c\u00e1o lo\u1ea1i <strong>${reportType}</strong> t\u1ea1i th\u1eddi \u0111i\u1ec3m n\u00e0y kh\u00f4ng?`,
                () => {
                    executeSaveSnapshot(reportType);
                }
            );
        });
    }

    function executeSaveSnapshot(reportType) {
        btnSaveSnapshot.disabled = true;
        btnSaveSnapshot.innerText = "\u0110ang l\u01b0u...";

        fetch(`${contextPath}/admin/analytics?action=saveSnapshot`, {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: `reportType=${reportType}`
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                alert("\u0110\u00e3 ch\u1ee5p v\u00e0 l\u01b0u b\u00e1o c\u00e1o th\u00e0nh c\u00f4ng!");
                // Refresh snapshots if current tab is snapshots
                const activeTab = document.querySelector(".tab-btn.active").getAttribute("data-tab");
                if (activeTab === "tab-reports") {
                    loadTabData("tab-reports");
                }
            } else {
                alert("L\u01b0u b\u00e1o c\u00e1o th\u1ea5t b\u1ea1i: " + data.message);
            }
        })
        .catch(err => {
            console.error(err);
            alert("L\u1ed7i k\u1ebft n\u1ed1i khi l\u01b0u b\u00e1o c\u00e1o.");
        })
        .finally(() => {
            btnSaveSnapshot.disabled = false;
            btnSaveSnapshot.innerText = "Ch\u1ee5p Snapshot";
        });
    }

    // Report Detail Modals Viewer
    function showReportDetail(reportId) {
        fetch(`${contextPath}/admin/analytics?ajax=true&type=reportDetail&reportId=${reportId}`)
            .then(res => res.json())
            .then(report => {
                modalBody.innerHTML = `
                    <div style="margin-bottom: 15px;">
                        <p><strong>M\u00e3 B\u00e1o c\u00e1o:</strong> #${report.reportId}</p>
                        <p><strong>Lo\u1ea1i B\u00e1o c\u00e1o:</strong> ${report.reportType}</p>
                        <p><strong>Kho\u1ea3ng th\u1eddi gian:</strong> ${report.periodStart} \u0111\u1ebfn ${report.periodEnd}</p>
                        <p><strong>Th\u1eddi gian ch\u1ee5p:</strong> ${report.generatedAt}</p>
                        <p><strong>Ng\u01b0\u1eddi th\u1ef1c hi\u1ec7n:</strong> ${report.generatedByName || 'H\u1ec7 th\u1ed1ng'}</p>
                    </div>
                    <div style="background: rgba(15,23,42,0.6); padding: 15px; border-radius: 8px; max-height: 300px; overflow-y: auto;">
                        <pre style="color: var(--success-green); font-family: monospace; font-size: 0.85rem; white-space: pre-wrap; word-wrap: break-word;">${JSON.stringify(JSON.parse(report.data), null, 2)}</pre>
                    </div>
                `;
                modalOverlay.classList.add("active");
            })
            .catch(err => {
                console.error(err);
                alert("Kh\u00f4ng th\u1ec3 t\u1ea3i chi ti\u1ebft b\u00e1o c\u00e1o: " + err.message);
            });
    }

    // Export Saved Report to CSV
    function downloadSavedReportCSV(reportId) {
        fetch(`${contextPath}/admin/analytics?ajax=true&type=reportDetail&reportId=${reportId}`)
            .then(res => res.json())
            .then(report => {
                const rawObj = JSON.parse(report.data);
                let csvContent = "data:text/csv;charset=utf-8,\uFEFF";
                
                // Convert JSON arrays/objects to flat CSV
                if (Array.isArray(rawObj)) {
                    if (rawObj.length > 0) {
                        const keys = Object.keys(rawObj[0]);
                        csvContent += keys.join(",") + "\n";
                        rawObj.forEach(row => {
                            csvContent += keys.map(k => `"${String(row[k] || '').replace(/"/g, '""')}"`).join(",") + "\n";
                        });
                    }
                } else {
                    // It is a grouped metrics object (e.g. monthly revenue, top categories, etc.)
                    Object.keys(rawObj).forEach(key => {
                        csvContent += `\n--- ${key.toUpperCase()} ---\n`;
                        const subArr = rawObj[key];
                        if (Array.isArray(subArr) && subArr.length > 0) {
                            const keys = Object.keys(subArr[0]);
                            csvContent += keys.join(",") + "\n";
                            subArr.forEach(row => {
                                csvContent += keys.map(k => `"${String(row[k] || '').replace(/"/g, '""')}"`).join(",") + "\n";
                            });
                        } else {
                            csvContent += `D\u1eef li\u1ec7u r\u1ed7ng ho\u1eb7c kh\u00f4ng c\u00f3 d\u1ea1ng b\u1ea3ng\n`;
                        }
                    });
                }

                const encodedUri = encodeURI(csvContent);
                const link = document.createElement("a");
                link.setAttribute("href", encodedUri);
                link.setAttribute("download", `snapshot_${report.reportType}_${report.reportId}.csv`);
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            })
            .catch(err => {
                alert("Xu\u1ea5t CSV th\u1ea5t b\u1ea1i: " + err.message);
            });
    }

    // Custom Confirmation Modal Helper
    function showConfirmation(message, onConfirm) {
        const confirmModal = document.getElementById("confirm-modal");
        const bodyContent = document.getElementById("confirm-body-content");
        const btnOk = document.getElementById("confirm-ok-btn");
        const btnCancel = document.getElementById("confirm-cancel-btn");
        const btnClose = document.getElementById("confirm-close-btn");

        bodyContent.innerHTML = message;
        confirmModal.classList.add("active");

        const clearListeners = () => {
            const newBtnOk = btnOk.cloneNode(true);
            const newBtnCancel = btnCancel.cloneNode(true);
            const newBtnClose = btnClose.cloneNode(true);
            btnOk.parentNode.replaceChild(newBtnOk, btnOk);
            btnCancel.parentNode.replaceChild(newBtnCancel, btnCancel);
            btnClose.parentNode.replaceChild(newBtnClose, btnClose);
            
            // Re-attach standard close
            document.getElementById("confirm-cancel-btn").addEventListener("click", () => confirmModal.classList.remove("active"));
            document.getElementById("confirm-close-btn").addEventListener("click", () => confirmModal.classList.remove("active"));
        };

        clearListeners();

        // Get the newly cloned ok button
        const activeOk = document.getElementById("confirm-ok-btn");
        activeOk.addEventListener("click", () => {
            confirmModal.classList.remove("active");
            onConfirm();
        });
    }

    // Confirmation wrapper for Export (Handles unloaded tab data)
    window.confirmExport = function(tableId, filename) {
        showConfirmation(
            "B\u1ea1n c\u00f3 ch\u1eafc mu\u1ed1n xu\u1ea5t d\u1eef li\u1ec7u n\u00e0y kh\u00f4ng? D\u1eef li\u1ec7u s\u1ebd \u0111\u01b0\u1ee3c k\u1ebft xu\u1ea5t d\u01b0\u1edbi d\u1ea1ng CSV v\u00e0 t\u1ea3i v\u1ec1 m\u00e1y t\u00ednh c\u1ee7a b\u1ea1n.",
            () => {
                const table = document.getElementById(tableId);
                if (table) {
                    const tbody = table.querySelector("tbody");
                    // N\u1ebfu tbody ch\u01b0a \u0111\u01b0\u1ee3c load d\u1eef li\u1ec7u (ch\u01b0a c\u00f3 d\u00f2ng n\u00e0o)
                    if (!tbody || tbody.children.length === 0) {
                        let type = "";
                        if (tableId === "tour-performance-table") type = "performance";
                        else if (tableId === "guide-activity-table") type = "guides";

                        if (type) {
                            fetchAnalytics(type, data => {
                                if (type === "performance") {
                                    renderPerformanceDashboard(data);
                                } else if (type === "guides") {
                                    renderGuidesDashboard(data);
                                }
                                // Xu\u1ea5t sau khi d\u1eef li\u1ec7u \u0111\u00e3 \u0111\u01b0\u1ee3c render th\u00e0nh c\u00f4ng v\u00e0o DOM
                                setTimeout(() => {
                                    window.exportTableToCSV(tableId, filename);
                                }, 150);
                            });
                            return;
                        }
                    }
                }
                window.exportTableToCSV(tableId, filename);
            }
        );
    };

    // Client Side CSV Export for Active Tables
    window.exportTableToCSV = function(tableId, filename) {
        const table = document.getElementById(tableId);
        if (!table) return;

        let csv = [];
        const rows = table.querySelectorAll("tr");
        for (let i = 0; i < rows.length; i++) {
            const row = [], cols = rows[i].querySelectorAll("td, th");
            for (let j = 0; j < cols.length; j++) {
                // Remove whitespace and clean text
                let data = cols[j].innerText.replace(/(\r\n|\n|\r)/gm, "").replace(/(\s\s+)/gm, " ");
                // Escape double quotes
                data = data.replace(/"/g, '""');
                row.push('"' + data + '"');
            }
            csv.push(row.join(","));
        }

        const csvString = "\uFEFF" + csv.join("\n");
        const blob = new Blob([csvString], { type: "text/csv;charset=utf-8;" });
        const link = document.createElement("a");
        if (link.download !== undefined) {
            const url = URL.createObjectURL(blob);
            link.setAttribute("href", url);
            link.setAttribute("download", filename);
            link.style.visibility = 'hidden';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }
    };

    // Close Modal Event Handler
    if (modalCloseBtn) {
        modalCloseBtn.addEventListener("click", () => {
            modalOverlay.classList.remove("active");
        });
    }

    // Click outside modal content closes modal
    window.addEventListener("click", (e) => {
        if (e.target === modalOverlay) {
            modalOverlay.classList.remove("active");
        }
    });

    // Helper functions
    function destroyChart(id) {
        if (charts[id]) {
            charts[id].destroy();
            delete charts[id];
        }
    }
});
