document.addEventListener("DOMContentLoaded", () => {
    const forecastTypeSelect = document.getElementById("forecast-type");
    const btnRunForecast = document.getElementById("btn-run-forecast");
    const historyTbody = document.getElementById("history-tbody");
    
    // KPI elements
    const kpiConfidence = document.getElementById("kpi-confidence");
    const kpiRevenue = document.getElementById("kpi-revenue");
    const kpiDemand = document.getElementById("kpi-demand");
    
    // Modal elements
    const jsonModal = document.getElementById("json-modal");
    const btnCloseModal = document.getElementById("btn-close-modal");
    const modalTitle = document.getElementById("modal-title");
    const modalType = document.getElementById("modal-type");
    const modalConfidence = document.getElementById("modal-confidence");
    const modalInputJson = document.getElementById("modal-input-json");
    const modalResultJson = document.getElementById("modal-result-json");

    let forecastChart = null;

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

    // Format Currency Helper
    function formatVND(value) {
        return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND', maximumFractionDigits: 0 }).format(value);
    }

    // Load calculations and render charts
    function loadForecastData(type) {
        const contextPath = window.contextPath || '';
        fetch(`${contextPath}/admin/forecast?ajax=true&action=getCalculations&type=${type}`)
            .then(res => {
                if (!res.ok) throw new Error("Kh\u00f4ng th\u1ec3 n\u1ea1p d\u1eef li\u1ec7u d\u1ef1 b\u00e1o");
                return res.json();
            })
            .then(data => {
                // Update KPI for confidence
                if (data.confidence) {
                    kpiConfidence.innerText = data.confidence.toFixed(1) + "%";
                }
                
                // Set page KPIs
                updatePageKPIs(type, data);
                
                // Plot Chart
                renderForecastChart(type, data);
            })
            .catch(err => {
                console.error(err);
                showToast("L\u1ed7i n\u1ea1p d\u1eef li\u1ec7u bi\u1ec3u \u0111\u1ed3 d\u1ef1 b\u00e1o", "error");
            });
    }

    // Helper to calculate general target KPI values
    function updatePageKPIs(type, data) {
        const contextPath = window.contextPath || '';
        
        // 1. Target Revenue KPI: Get projected revenue for next month
        fetch(`${contextPath}/admin/forecast?ajax=true&action=getCalculations&type=Revenue`)
            .then(res => res.json())
            .then(revData => {
                if (revData.forecast && revData.forecast.length > 0) {
                    kpiRevenue.innerText = formatVND(revData.forecast[0].value);
                } else {
                    kpiRevenue.innerText = "Li\u00ean h\u1ec7 Admin";
                }
            }).catch(e => console.error(e));

        // 2. High Demand KPI: Top tour with highest demand next month
        fetch(`${contextPath}/admin/forecast?ajax=true&action=getCalculations&type=Demand`)
            .then(res => res.json())
            .then(demData => {
                if (demData.projected_demand && demData.projected_demand.length > 0) {
                    // Sort to find the highest projected booking tour
                    const sorted = [...demData.projected_demand].sort((a, b) => b.projectedBookings - a.projectedBookings);
                    kpiDemand.innerText = sorted[0].tourName;
                    kpiDemand.title = sorted[0].tourName;
                } else {
                    kpiDemand.innerText = "Ch\u01b0a x\u00e1c \u0111\u1ecbnh";
                }
            }).catch(e => console.error(e));
    }

    // Draw Chart.js Graph
    function renderForecastChart(type, data) {
        const ctx = document.getElementById("forecastChart").getContext("2d");
        
        if (forecastChart) {
            forecastChart.destroy();
        }

        const chartTitleEl = document.getElementById("chart-title");

        if (type === "Revenue" || type === "BookingTrend") {
            chartTitleEl.innerText = type === "Revenue" 
                ? "D\u1ef1 B\u00e1o Doanh Thu 3 Th\u00e1ng T\u1edbi (\u0111\u01a1n v\u1ecb: VN\u0110)" 
                : "D\u1ef1 B\u00e1o L\u01b0\u1ee3t \u0110\u1eb7t Tour 3 Th\u00e1ng T\u1edbi (\u0111\u01a1n v\u1ecb: l\u01b0\u1ee3t)";

            const histLabels = data.historical.map(h => h.month);
            const foreLabels = data.forecast.map(f => f.month);
            
            // Unified labels
            const labels = [...histLabels, ...foreLabels];
            
            // Historical Dataset (Ends at last historical month)
            const histData = data.historical.map(h => h.value);
            const histDataset = [...histData];
            for (let i = 0; i < foreLabels.length; i++) {
                histDataset.push(null);
            }

            // Forecast Dataset (Starts at last historical month to connect lines smoothly)
            const foreDataset = [];
            for (let i = 0; i < histData.length - 1; i++) {
                foreDataset.push(null);
            }
            // Insert last historical value to start point of forecast
            foreDataset.push(histData[histData.length - 1]);
            data.forecast.forEach(f => {
                foreDataset.push(f.value);
            });

            forecastChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [
                        {
                            label: 'L\u1ecbch s\u1eed th\u1ef1c t\u1ebf',
                            data: histDataset,
                            borderColor: '#3b82f6',
                            backgroundColor: 'rgba(59, 130, 246, 0.1)',
                            borderWidth: 3,
                            tension: 0.2,
                            fill: true
                        },
                        {
                            label: 'D\u1ef1 b\u00e1o xu h\u01b0\u1edbng',
                            data: foreDataset,
                            borderColor: '#ef4444',
                            borderDash: [6, 6],
                            backgroundColor: 'transparent',
                            borderWidth: 3,
                            tension: 0.2,
                            fill: false
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: { color: '#f1f5f9' },
                            ticks: {
                                callback: function(value) {
                                    if (type === "Revenue") {
                                        return value >= 1000000 ? (value / 1000000) + " Tr" : value;
                                    }
                                    return value;
                                }
                            }
                        },
                        x: { grid: { display: false } }
                    },
                    plugins: {
                        legend: { position: 'top' }
                    }
                }
            });

        } else if (type === "Demand") {
            chartTitleEl.innerText = "D\u1ef1 B\u00e1o Nhu C\u1ea7u \u0110\u1eb7t Ch\u1ed7 Th\u00e1ng T\u1edbi (Top 5 Tour Hot)";

            const labels = data.historical_top_tours.map(t => t.tourName);
            const histData = data.historical_top_tours.map(t => t.bookings);
            
            // Map projected value matching the order of labels
            const foreData = data.projected_demand.map(t => t.projectedBookings);

            forecastChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: labels.map(l => l.length > 25 ? l.substring(0, 25) + "..." : l),
                    datasets: [
                        {
                            label: 'L\u01b0\u1ee3t \u0111\u1eb7t ch\u1ed7 3 th\u00e1ng qua',
                            data: histData,
                            backgroundColor: '#3b82f6',
                            borderRadius: 6
                        },
                        {
                            label: 'D\u1ef1 ki\u1ebfn th\u00e1ng t\u1edbi (Moving Average)',
                            data: foreData,
                            backgroundColor: '#f59e0b',
                            borderRadius: 6
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: { 
                            beginAtZero: true,
                            grid: { color: '#f1f5f9' }
                        },
                        x: { grid: { display: false } }
                    },
                    plugins: {
                        legend: { position: 'top' }
                    }
                }
            });
        }
    }

    // Refresh history log table via AJAX
    function refreshHistoryTable() {
        const contextPath = window.contextPath || '';
        fetch(`${contextPath}/admin/forecast?ajax=true`)
            .then(res => res.json())
            .then(history => {
                historyTbody.innerHTML = "";
                if (history.length === 0) {
                    historyTbody.innerHTML = `
                        <tr>
                            <td colspan="5" style="text-align: center; padding: 20px; color: #94a3b8;">
                                Ch\u01b0a c\u00f3 snapshot d\u1ef1 b\u00e1o n\u00e0o \u0111\u01b0\u1ee3c l\u01b0u.
                            </td>
                        </tr>`;
                    return;
                }

                history.forEach(pr => {
                    const date = new Date(pr.generatedAt);
                    const formattedDate = String(date.getDate()).padStart(2, '0') + '/' + 
                                          String(date.getMonth() + 1).padStart(2, '0') + '/' + 
                                          date.getFullYear();
                    
                    const tr = document.createElement("tr");
                    tr.style.borderBottom = "1px solid #e2e8f0";
                    tr.innerHTML = `
                        <td style="padding: 10px; font-weight: 600;">#${pr.predictionId}</td>
                        <td style="padding: 10px;">
                            <span class="status-badge" style="background:#e0f2fe; color:#0369a1; padding: 2px 6px; border-radius: 4px; font-size: 0.75rem;">
                                ${pr.predictionType}
                            </span>
                        </td>
                        <td style="padding: 10px; font-weight: 600;">
                            ${pr.confidence.toFixed(1)}%
                        </td>
                        <td style="padding: 10px; color:#64748b;">
                            ${formattedDate}
                        </td>
                        <td style="padding: 10px;">
                            <button class="btn-detail-json" 
                                    data-type="${pr.predictionType}"
                                    data-confidence="${pr.confidence.toFixed(1)}%"
                                    data-input='${pr.inputData}' 
                                    data-result='${pr.resultData}'
                                    style="background:none; border:none; color:#2563eb; cursor:pointer; font-weight:600; padding:0;">
                                Xem JSON
                            </button>
                        </td>`;
                    historyTbody.appendChild(tr);
                });
                
                // Re-bind click event to new buttons
                bindModalEvents();
            })
            .catch(e => console.error(e));
    }

    // Modal details binding
    function bindModalEvents() {
        const detailBtns = document.querySelectorAll(".btn-detail-json");
        detailBtns.forEach(btn => {
            btn.addEventListener("click", () => {
                const type = btn.getAttribute("data-type");
                const confidence = btn.getAttribute("data-confidence");
                const inputDataRaw = btn.getAttribute("data-input");
                const resultDataRaw = btn.getAttribute("data-result");

                modalType.innerText = type;
                modalConfidence.innerText = confidence;

                try {
                    modalInputJson.innerText = JSON.stringify(JSON.parse(inputDataRaw), null, 2);
                    modalResultJson.innerText = JSON.stringify(JSON.parse(resultDataRaw), null, 2);
                } catch (e) {
                    modalInputJson.innerText = inputDataRaw;
                    modalResultJson.innerText = resultDataRaw;
                }

                jsonModal.classList.add("active");
            });
        });
    }

    // Close Modal
    btnCloseModal.addEventListener("click", () => {
        jsonModal.classList.remove("active");
    });
    window.addEventListener("click", (e) => {
        if (e.target === jsonModal) {
            jsonModal.classList.remove("active");
        }
    });

    // Run new forecasting snapshot
    btnRunForecast.addEventListener("click", () => {
        const type = forecastTypeSelect.value;
        btnRunForecast.disabled = true;
        btnRunForecast.innerHTML = `<i class="fa fa-spinner fa-spin"></i> \u0110ang t\u00ednh to\u00e1n...`;

        const contextPath = window.contextPath || '';
        fetch(`${contextPath}/admin/forecast?type=${type}`, {
            method: "POST"
        })
        .then(res => {
            if (!res.ok) throw new Error("Ch\u1ea1y m\u00f4 h\u00ecnh d\u1ef1 b\u00e1o th\u1ea5t b\u1ea1i");
            return res.json();
        })
        .then(data => {
            if (data.status === "success") {
                showToast(data.message, "success");
                // Reload current chart with new projection
                loadForecastData(type);
                // Refresh log history list
                refreshHistoryTable();
            } else {
                showToast(data.message, "error");
            }
        })
        .catch(err => {
            console.error(err);
            showToast("L\u1ed7i trong qu\u00e1 tr\u00ecnh ch\u1ea1y m\u00f4 h\u00ecnh d\u1ef1 b\u00e1o th\u1ed1ng k\u00ea!", "error");
        })
        .finally(() => {
            btnRunForecast.disabled = false;
            btnRunForecast.innerHTML = `<i data-lucide="play-circle"></i> Ch\u1ea1y M\u00f4 h\u00ecnh D\u1ef1 b\u00e1o (Generate Forecast)`;
            if (window.lucide) window.lucide.createIcons();
        });
    });

    // Handle dropdown selection change
    forecastTypeSelect.addEventListener("change", () => {
        loadForecastData(forecastTypeSelect.value);
    });

    // Initialize Page
    loadForecastData("Revenue");
    bindModalEvents();
});
