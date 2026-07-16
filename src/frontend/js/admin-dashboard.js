/* ── Admin Dashboard Logic & Charts ── */

document.addEventListener('DOMContentLoaded', () => {
    // Initialize Lucide Icons
    if (window.lucide) {
        lucide.createIcons();
    }

    let allToursRaw = [];
    const recentToursTbody = document.getElementById('dashboard-recent-tours');
    const departuresTbody = document.getElementById('overview-departures-body');
    let overviewChartInstance = null;

    /* ── Fetch Tours from Server ── */
    function fetchDashboardData() {
        // Tách 2 endpoint riêng để tránh share schema giữa 2 consumer:
        //   - /admin/dashboard?ajax=true -> chỉ trả {monthlyRevenue} (chart)
        //   - /admin/tours?ajax=true     -> trả {tours, monthlyRevenue} (table quản lý)
        // Dashboard dùng revenue endpoint (lightweight) + tours endpoint cho overview stats.
        Promise.all([
            fetch('dashboard?ajax=true').then(res => {
                if (!res.ok) throw new Error('Kh\u00f4ng th\u1ec3 k\u1ebft n\u1ed1i \u0111\u1ebfn m\u00e1y ch\u1ee7 (revenue)');
                return res.json();
            }),
            fetch('tours?ajax=true').then(res => {
                if (!res.ok) throw new Error('Kh\u00f4ng th\u1ec3 k\u1ebft n\u1ed1i \u0111\u1ebfn m\u00e1y ch\u1ee7 (tours)');
                return res.json();
            })
        ])
            .then(([revenueData, toursData]) => {
                const tours = Array.isArray(toursData) ? toursData : (toursData.tours || []);
                const monthlyRev = revenueData.monthlyRevenue || toursData.monthlyRevenue || [0, 0, 0, 0, 0, 0];
                allToursRaw = tours;
                // Enrich data with derived properties to match the user's schema & stats formula
                const enrichedTours = mapToursData(tours);

                // Render view elements
                renderOverviewStats(enrichedTours, monthlyRev);
                renderOverviewTable(enrichedTours);
                renderOverviewDepartures(enrichedTours);
                initOverviewRevenueChart(monthlyRev);
            })
            .catch(err => {
                console.error('Error fetching dashboard data:', err);
            });
    }

    /* ── Map Database JSON to local overview variables ── */
    function mapToursData(data) {
        return data.map(t => {
            let seatsTotal = t.totalSeats || t.maxParticipants || 20;
            let seatsLeft = (t.availableSeats !== undefined && t.availableSeats !== null) ? t.availableSeats : seatsTotal;
            
            // Image mapping
            let image = '';
            if (t.tourName.toLowerCase().includes('đà nẵng') || t.tourName.toLowerCase().includes('bà nà')) {
                image = '../assets/images/tour_danang.png';
            } else if (t.tourName.toLowerCase().includes('phú quốc')) {
                image = '../assets/images/tour_phuquoc.png';
            } else if (t.tourName.toLowerCase().includes('hạ long')) {
                image = '../assets/images/tour_halong.png';
            } else if (t.tourName.toLowerCase().includes('hội an')) {
                image = '../assets/images/tour_hoian.png';
            } else if (t.tourName.toLowerCase().includes('đà lạt')) {
                image = '../assets/images/tour_dalat.png';
            } else if (t.tourName.toLowerCase().includes('sa pa') || t.tourName.toLowerCase().includes('sapa')) {
                image = '../assets/images/tour_sapa.png';
            } else if (t.tourName.toLowerCase().includes('nha trang')) {
                image = '../assets/images/tour_nhatrang.png';
            } else if (t.tourName.toLowerCase().includes('hà giang')) {
                image = '../assets/images/tour_hagiang.png';
            } else {
                image = '../assets/images/tour_halong.png';
            }

            let rating = t.rating !== undefined ? t.rating : 0.0;
            let reviews = t.reviewsCount !== undefined ? t.reviewsCount : 0;

            return {
                id: t.tourId,
                title: t.tourName,
                location: t.departureCity + " → " + t.destination,
                category: t.categoryId,
                categoryName: t.categoryName,
                difficulty: t.difficultyLevel ? t.difficultyLevel.toLowerCase() : 'easy',
                rating: rating,
                reviews: reviews,
                seatsLeft: seatsLeft,
                seatsTotal: seatsTotal,
                priceVND: t.basePrice,
                status: t.status.toLowerCase(), // active, draft, disabled
                image: image,
                nextDeparture: t.nextDeparture || ''
            };
        });
    }

    // 1. Calculate and display KPI metrics on stats cards
    function renderOverviewStats(tours, monthlyRev) {
        let totalRevenue = 0;
        let seatsLeft = 0;
        let seatsTotal = 0;
        
        tours.forEach(tour => {
            if (tour.status === 'active') {
                seatsLeft += tour.seatsLeft;
                seatsTotal += tour.seatsTotal;
                const booked = tour.seatsTotal - tour.seatsLeft;
                totalRevenue += booked * tour.priceVND;
            }
        });
        
        const currentMonthRev = (monthlyRev && monthlyRev.length > 5) ? monthlyRev[5] : totalRevenue;
        
        document.getElementById('stats-revenue').textContent = formatCurrency(currentMonthRev);
        document.getElementById('stats-tours-count').textContent = tours.length;
        document.getElementById('stats-seats-left').textContent = seatsLeft;
        
        const fillRatePercent = seatsTotal > 0 ? (((seatsTotal - seatsLeft) / seatsTotal) * 100).toFixed(1) : 0;
        document.getElementById('stats-fill-rate').textContent = `${fillRatePercent}%`;

        // Update card footers dynamically
        const revFooter = document.getElementById('stats-revenue-footer');
        if (revFooter && monthlyRev && monthlyRev.length > 5) {
            const prevMonthRev = monthlyRev[4] || 0;
            if (prevMonthRev > 0) {
                const percentChange = ((currentMonthRev - prevMonthRev) / prevMonthRev * 100).toFixed(1);
                const isUp = currentMonthRev >= prevMonthRev;
                revFooter.innerHTML = `
                    <span class="stat-trend ${isUp ? 'up' : 'down'}">
                        <i data-lucide="${isUp ? 'trending-up' : 'trending-down'}"></i> 
                        ${isUp ? '+' : ''}${percentChange}%
                    </span>
                    <span>so với tháng trước</span>
                `;
            } else {
                revFooter.innerHTML = `
                    <span class="stat-trend up"><i data-lucide="trending-up"></i> +0%</span>
                    <span>so với tháng trước</span>
                `;
            }
        }

        const toursFooter = document.getElementById('stats-tours-footer');
        if (toursFooter) {
            const currentMonthPrefix = new Date().toISOString().substring(0, 7); // e.g. "2026-06"
            const newToursInMonth = tours.filter(t => t.createdAt && t.createdAt.startsWith(currentMonthPrefix)).length;
            toursFooter.innerHTML = `
                <span class="stat-trend up"><i data-lucide="trending-up"></i> +${newToursInMonth} tour</span>
                <span>mới thêm trong tháng</span>
            `;
        }

        const seatsFooter = document.getElementById('stats-seats-footer');
        if (seatsFooter) {
            const occupiedSeats = seatsTotal - seatsLeft;
            const occupiedPercent = seatsTotal > 0 ? ((occupiedSeats / seatsTotal) * 100).toFixed(1) : 0;
            seatsFooter.innerHTML = `
                <span class="stat-trend up"><i data-lucide="trending-up"></i> ${occupiedPercent}%</span>
                <span>ghế đã được đặt chỗ</span>
            `;
        }

        const fillFooter = document.getElementById('stats-fill-footer');
        if (fillFooter) {
            fillFooter.innerHTML = `
                <span class="stat-trend up"><i data-lucide="trending-up"></i> ${fillRatePercent}%</span>
                <span>tỷ lệ lấp đầy thực tế</span>
            `;
        }

        if (window.lucide) {
            lucide.createIcons();
        }
    }

    // 2. Populate Best Selling / Highest Rated Tours table
    function renderOverviewTable(tours) {
        if (!recentToursTbody) return;
        recentToursTbody.innerHTML = '';
        
        // Sort tours by rating descending and take top 4
        const topTours = [...tours].sort((a, b) => b.rating - a.rating).slice(0, 4);
        
        topTours.forEach(tour => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>
                    <div class="tour-cell">
                        <img src="${tour.image}" alt="${tour.title}" class="tour-cell-img" onerror="this.src='../assets/images/tour_halong.png'">
                        <div class="tour-cell-info">
                            <span class="tour-cell-name">${tour.title}</span>
                            <span class="tour-cell-dest">${tour.location}</span>
                        </div>
                    </div>
                </td>
                <td><span style="font-weight: 500;">${tour.categoryName}</span></td>
                <td>
                    <span class="badge ${tour.difficulty === 'easy' ? 'badge-active' : tour.difficulty === 'medium' ? 'badge-draft' : 'badge-disabled'}">
                        ${tour.difficulty === 'easy' ? 'Dễ' : tour.difficulty === 'medium' ? 'Vừa' : 'Khó'}
                    </span>
                </td>
                <td>★ ${tour.rating.toFixed(1)} (${tour.reviews})</td>
                <td>
                    <div class="capacity-cell">
                        <div class="capacity-text-row">
                            <span>Còn ${tour.seatsLeft}/${tour.seatsTotal} chỗ</span>
                        </div>
                        <div class="progress-bar">
                            <div class="progress-fill ${tour.seatsLeft <= 5 ? 'danger' : ''}" style="width: ${((tour.seatsTotal - tour.seatsLeft) / tour.seatsTotal * 100)}%;"></div>
                        </div>
                    </div>
                </td>
                <td style="font-weight: 600; color: var(--warning-amber);">${formatCurrency(tour.priceVND)}</td>
            `;
            recentToursTbody.appendChild(tr);
        });
    }

    // 3. Populate Nearest Departure Schedule table
    function renderOverviewDepartures(tours) {
        if (!departuresTbody) return;
        departuresTbody.innerHTML = '';
        
        // Take active tours that have a departure date and sort by departure date ascending
        const toursWithDepartures = tours.filter(t => t.status === 'active' && t.nextDeparture);
        toursWithDepartures.sort((a, b) => new Date(a.nextDeparture) - new Date(b.nextDeparture));
        
        const displayTours = toursWithDepartures.length > 0 ? toursWithDepartures.slice(0, 3) : tours.filter(t => t.status === 'active').slice(0, 3);
        
        displayTours.forEach(tour => {
            const tr = document.createElement('tr');
            const percent = ((tour.seatsTotal - tour.seatsLeft) / tour.seatsTotal * 100).toFixed(0);
            
            let dateStr = 'Chưa có lịch';
            if (tour.nextDeparture) {
                const parts = tour.nextDeparture.split('-');
                if (parts.length === 3) {
                    dateStr = `${parts[2]}/${parts[1]}/${parts[0]}`;
                }
            }
            
            tr.innerHTML = `
                <td>
                    <div class="tour-cell">
                        <div class="tour-cell-info">
                            <span class="tour-cell-name" style="font-size:0.85rem;">${tour.title}</span>
                        </div>
                    </div>
                </td>
                <td style="font-size:0.8rem; font-weight:500; white-space: nowrap;">${dateStr}</td>
                <td>
                    <div class="capacity-cell" style="width: 100px;">
                        <span style="font-size:0.7rem; font-weight:600; color:var(--text-muted);">${percent}% Đã đặt</span>
                        <div class="progress-bar" style="height:4px;">
                            <div class="progress-fill ${tour.seatsLeft <= 5 ? 'danger' : ''}" style="width: ${percent}%;"></div>
                        </div>
                    </div>
                </td>
            `;
            departuresTbody.appendChild(tr);
        });
    }

    // 4. Initialize overview revenue chart using Chart.js
    function initOverviewRevenueChart(monthlyRev) {
        const ctx = document.getElementById('overview-revenue-chart');
        if (!ctx) return;
        if (overviewChartInstance) {
            overviewChartInstance.destroy();
        }
        
        // Generate last 6 months labels dynamically
        const labels = [];
        const today = new Date();
        for (let i = 5; i >= 0; i--) {
            const d = new Date(today.getFullYear(), today.getMonth() - i, 1);
            labels.push(`Tháng ${d.getMonth() + 1}`);
        }
        
        overviewChartInstance = new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Doanh thu (₫)',
                    data: monthlyRev,
                    borderColor: '#818cf8',
                    backgroundColor: 'rgba(129, 140, 248, 0.1)',
                    borderWidth: 3,
                    fill: true,
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    x: { grid: { color: 'rgba(255, 255, 255, 0.05)' }, ticks: { color: '#94a3b8' } },
                    y: { grid: { color: 'rgba(255, 255, 255, 0.05)' }, ticks: { color: '#94a3b8' } }
                }
            }
        });
    }

    // Helper functions
    function formatCurrency(val) {
        return val.toLocaleString('vi-VN') + ' ₫';
    }

    // Toggle profile avatar dropdown
    const profileTrigger = document.getElementById('admin-profile-trigger');
    const avatarMenu = document.getElementById('admin-avatar-menu');
    if (profileTrigger && avatarMenu) {
        profileTrigger.addEventListener('click', (e) => {
            e.stopPropagation();
            const isOpen = avatarMenu.style.display === 'flex';
            avatarMenu.style.display = isOpen ? 'none' : 'flex';
        });
        document.addEventListener('click', () => {
            avatarMenu.style.display = 'none';
        });
    }

    // First load
    fetchDashboardData();
});
