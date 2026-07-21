/* \u2500\u2500 Admin Dashboard Logic & Charts \u2500\u2500 */

document.addEventListener('DOMContentLoaded', () => {
    // Initialize Lucide Icons
    if (window.lucide) {
        lucide.createIcons();
    }

    let allToursRaw = [];
    const recentToursTbody = document.getElementById('dashboard-recent-tours');
    const departuresTbody = document.getElementById('overview-departures-body');
    let overviewChartInstance = null;

    /* \u2500\u2500 Fetch Tours from Server \u2500\u2500 */
    function fetchDashboardData() {
        // T\u00e1ch 2 endpoint ri\u00eang \u0111\u1ec3 tr\u00e1nh share schema gi\u1eefa 2 consumer:
        //   - /admin/dashboard?ajax=true -> ch\u1ec9 tr\u1ea3 {monthlyRevenue} (chart)
        //   - /admin/tours?ajax=true     -> tr\u1ea3 {tours, monthlyRevenue} (table qu\u1ea3n l\u00fd)
        // Dashboard d\u00f9ng revenue endpoint (lightweight) + tours endpoint cho overview stats.
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
                const enrichedTours = mapToursData(tours);

                renderOverviewStats(enrichedTours, monthlyRev);
                renderOverviewTable(enrichedTours);
                renderOverviewDepartures(enrichedTours);
                initOverviewRevenueChart(monthlyRev);
            })
            .catch(err => {
                console.error('Error fetching dashboard data:', err);
            });
    }

    /* \u2500\u2500 Map Database JSON to local overview variables \u2500\u2500 */
    function mapToursData(data) {
        return data.map(t => {
            let seatsTotal = t.totalSeats || t.maxParticipants || 20;
            let seatsLeft = (t.availableSeats !== undefined && t.availableSeats !== null) ? t.availableSeats : seatsTotal;

            // Image mapping
            let image = '';
            const nameLower = t.tourName.toLowerCase();
            if (nameLower.includes('\u0111\u00e0 n\u1eb5ng') || nameLower.includes('b\u00e0 n\u00e0')) {
                image = '../assets/images/tour_danang.png';
            } else if (nameLower.includes('ph\u00fa qu\u1ed1c')) {
                image = '../assets/images/tour_phuquoc.png';
            } else if (nameLower.includes('h\u1ea1 long')) {
                image = '../assets/images/tour_halong.png';
            } else if (nameLower.includes('h\u1ed9i an')) {
                image = '../assets/images/tour_hoian.png';
            } else if (nameLower.includes('\u0111\u00e0 l\u1ea1t')) {
                image = '../assets/images/tour_dalat.png';
            } else if (nameLower.includes('sa pa') || nameLower.includes('sapa')) {
                image = '../assets/images/tour_sapa.png';
            } else if (nameLower.includes('nha trang')) {
                image = '../assets/images/tour_nhatrang.png';
            } else if (nameLower.includes('h\u00e0 giang')) {
                image = '../assets/images/tour_hagiang.png';
            } else {
                image = '../assets/images/tour_halong.png';
            }

            let rating = t.rating !== undefined ? t.rating : 0.0;
            let reviews = t.reviewsCount !== undefined ? t.reviewsCount : 0;

            return {
                id: t.tourId,
                title: t.tourName,
                location: t.departureCity + ' \u2192 ' + t.destination,
                category: t.categoryId,
                categoryName: t.categoryName,
                difficulty: t.difficultyLevel ? t.difficultyLevel.toLowerCase() : 'easy',
                rating: rating,
                reviews: reviews,
                seatsLeft: seatsLeft,
                seatsTotal: seatsTotal,
                priceVND: t.basePrice,
                status: t.status.toLowerCase(),
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
        document.getElementById('stats-fill-rate').textContent = fillRatePercent + '%';

        // Update card footers dynamically
        const revFooter = document.getElementById('stats-revenue-footer');
        if (revFooter && monthlyRev && monthlyRev.length > 5) {
            const prevMonthRev = monthlyRev[4] || 0;
            if (prevMonthRev > 0) {
                const percentChange = ((currentMonthRev - prevMonthRev) / prevMonthRev * 100).toFixed(1);
                const isUp = currentMonthRev >= prevMonthRev;
                revFooter.innerHTML =
                    '<span class="stat-trend ' + (isUp ? 'up' : 'down') + '">' +
                        '<i data-lucide="' + (isUp ? 'trending-up' : 'trending-down') + '"></i> ' +
                        (isUp ? '+' : '') + percentChange + '%' +
                    '</span>' +
                    '<span>so v\u1edbi th\u00e1ng tr\u01b0\u1edbc</span>';
            } else {
                revFooter.innerHTML =
                    '<span class="stat-trend up"><i data-lucide="trending-up"></i> +0%</span>' +
                    '<span>so v\u1edbi th\u00e1ng tr\u01b0\u1edbc</span>';
            }
        }

        const toursFooter = document.getElementById('stats-tours-footer');
        if (toursFooter) {
            const currentMonthPrefix = new Date().toISOString().substring(0, 7);
            const newToursInMonth = tours.filter(t => t.createdAt && t.createdAt.startsWith(currentMonthPrefix)).length;
            toursFooter.innerHTML =
                '<span class="stat-trend up"><i data-lucide="trending-up"></i> +' + newToursInMonth + ' tour</span>' +
                '<span>m\u1edbi th\u00eam trong th\u00e1ng</span>';
        }

        const seatsFooter = document.getElementById('stats-seats-footer');
        if (seatsFooter) {
            const occupiedSeats = seatsTotal - seatsLeft;
            const occupiedPercent = seatsTotal > 0 ? ((occupiedSeats / seatsTotal) * 100).toFixed(1) : 0;
            seatsFooter.innerHTML =
                '<span class="stat-trend up"><i data-lucide="trending-up"></i> ' + occupiedPercent + '%</span>' +
                '<span>gh\u1ebf \u0111\u00e3 \u0111\u01b0\u1ee3c \u0111\u1eb7t ch\u1ed7</span>';
        }

        const fillFooter = document.getElementById('stats-fill-footer');
        if (fillFooter) {
            fillFooter.innerHTML =
                '<span class="stat-trend up"><i data-lucide="trending-up"></i> ' + fillRatePercent + '%</span>' +
                '<span>t\u1ef7 l\u1ec7 l\u1ea5p \u0111\u1ea7y th\u1ef1c t\u1ebf</span>';
        }

        if (window.lucide) {
            lucide.createIcons();
        }
    }

    // 2. Populate Best Selling / Highest Rated Tours table
    function renderOverviewTable(tours) {
        if (!recentToursTbody) return;
        recentToursTbody.innerHTML = '';

        const topTours = [...tours].sort((a, b) => b.rating - a.rating).slice(0, 4);

        topTours.forEach(tour => {
            const tr = document.createElement('tr');
            const diffLabel = tour.difficulty === 'easy' ? 'D\u1ec5' : tour.difficulty === 'medium' ? 'V\u1eeba' : 'Kh\u00f3';
            const diffClass = tour.difficulty === 'easy' ? 'badge-active' : tour.difficulty === 'medium' ? 'badge-draft' : 'badge-disabled';
            const seatsUsedPct = ((tour.seatsTotal - tour.seatsLeft) / tour.seatsTotal * 100).toFixed(0);
            tr.innerHTML =
                '<td>' +
                    '<div class="tour-cell">' +
                        '<img src="' + tour.image + '" alt="' + tour.title + '" class="tour-cell-img" onerror="this.src=\'../assets/images/tour_halong.png\'">' +
                        '<div class="tour-cell-info">' +
                            '<span class="tour-cell-name">' + tour.title + '</span>' +
                            '<span class="tour-cell-dest">' + tour.location + '</span>' +
                        '</div>' +
                    '</div>' +
                '</td>' +
                '<td><span style="font-weight: 500;">' + tour.categoryName + '</span></td>' +
                '<td><span class="badge ' + diffClass + '">' + diffLabel + '</span></td>' +
                '<td>\u2605 ' + tour.rating.toFixed(1) + ' (' + tour.reviews + ')</td>' +
                '<td>' +
                    '<div class="capacity-cell">' +
                        '<div class="capacity-text-row">' +
                            '<span>C\u00f2n ' + tour.seatsLeft + '/' + tour.seatsTotal + ' ch\u1ed7</span>' +
                        '</div>' +
                        '<div class="progress-bar">' +
                            '<div class="progress-fill ' + (tour.seatsLeft <= 5 ? 'danger' : '') + '" style="width: ' + seatsUsedPct + '%;"></div>' +
                        '</div>' +
                    '</div>' +
                '</td>' +
                '<td style="font-weight: 600; color: var(--warning-amber);">' + formatCurrency(tour.priceVND) + '</td>';
            recentToursTbody.appendChild(tr);
        });
    }

    // 3. Populate Nearest Departure Schedule table
    function renderOverviewDepartures(tours) {
        if (!departuresTbody) return;
        departuresTbody.innerHTML = '';

        const toursWithDepartures = tours.filter(t => t.status === 'active' && t.nextDeparture);
        toursWithDepartures.sort((a, b) => new Date(a.nextDeparture) - new Date(b.nextDeparture));

        const displayTours = toursWithDepartures.length > 0
            ? toursWithDepartures.slice(0, 3)
            : tours.filter(t => t.status === 'active').slice(0, 3);

        displayTours.forEach(tour => {
            const tr = document.createElement('tr');
            const percent = ((tour.seatsTotal - tour.seatsLeft) / tour.seatsTotal * 100).toFixed(0);

            let dateStr = 'Ch\u01b0a c\u00f3 l\u1ecbch';
            if (tour.nextDeparture) {
                const parts = tour.nextDeparture.split('-');
                if (parts.length === 3) {
                    dateStr = parts[2] + '/' + parts[1] + '/' + parts[0];
                }
            }

            tr.innerHTML =
                '<td>' +
                    '<div class="tour-cell">' +
                        '<div class="tour-cell-info">' +
                            '<span class="tour-cell-name" style="font-size:0.85rem;">' + tour.title + '</span>' +
                        '</div>' +
                    '</div>' +
                '</td>' +
                '<td style="font-size:0.8rem; font-weight:500; white-space: nowrap;">' + dateStr + '</td>' +
                '<td>' +
                    '<div class="capacity-cell" style="width: 100px;">' +
                        '<span style="font-size:0.7rem; font-weight:600; color:var(--text-muted);">' + percent + '% \u0110\u00e3 \u0111\u1eb7t</span>' +
                        '<div class="progress-bar" style="height:4px;">' +
                            '<div class="progress-fill ' + (tour.seatsLeft <= 5 ? 'danger' : '') + '" style="width: ' + percent + '%;"></div>' +
                        '</div>' +
                    '</div>' +
                '</td>';
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
            labels.push('Th\u00e1ng ' + (d.getMonth() + 1));
        }

        overviewChartInstance = new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Doanh thu (\u20ab)',
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
        if (val === undefined || val === null) return '0 \u20ab';
        return Number(val).toLocaleString('vi-VN') + ' \u20ab';
    }

    // Toggle profile avatar dropdown
    const profileTrigger = document.getElementById('admin-profile-trigger');
    const avatarMenu = document.getElementById('admin-avatar-menu');
    if (profileTrigger && avatarMenu) {
        profileTrigger.addEventListener('click', (e) => {
            if (e.target.closest('#admin-avatar-menu')) {
                return;
            }
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
