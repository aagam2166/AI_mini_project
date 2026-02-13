// Dashboard JS: render overview charts and today's schedule from lastSchedule

function loadDashboard() {
    const raw = localStorage.getItem('lastSchedule');
    let schedule = [];
    let rate = 0.12;
    if (raw) {
        const data = JSON.parse(raw);
        schedule = data.schedule || [];
        rate = data.electricity_rate || rate;
    }

    renderOverviewChart(schedule);
    renderAnalyticsChart(schedule);
    renderTodaySchedule(schedule, rate);
}

function renderOverviewChart(schedule) {
    const hourly = new Array(24).fill(0);
    schedule.forEach((it) => {
        for (let t = Math.floor(it.start_time); t < Math.ceil(it.end_time); t++) {
            const hour = t % 24;
            hourly[hour] += it.power;
        }
    });

    const ctx = document.getElementById('powerOverview').getContext('2d');
    if (window._overview) window._overview.destroy();
    window._overview = new Chart(ctx, {
        type: 'line',
        data: { labels: Array.from({length:24}, (_,i)=>i+':00'), datasets: [{ label: 'Power (W)', data: hourly, borderColor: '#60a5fa', backgroundColor: 'rgba(96,165,250,0.15)', fill: true }]},
        options: { plugins:{legend:{display:false}}, scales:{y:{beginAtZero:true}} }
    });
}

function renderAnalyticsChart(schedule) {
    // sample analytics: cost comparison baseline vs optimized
    const baseline = Math.max(5, schedule.reduce((s, it)=>s + (it.power*it.duration/60/1000*0.18), 0));
    const optimized = Math.max(2, schedule.reduce((s, it)=>s + (it.power*it.duration/60/1000*0.12), 0));

    const ctx = document.getElementById('analyticsChart').getContext('2d');
    if (window._analytics) window._analytics.destroy();
    window._analytics = new Chart(ctx, {
        type: 'bar',
        data: { labels:['Baseline','Optimized'], datasets:[{ label:'Cost ($)', data:[baseline.toFixed(2), optimized.toFixed(2)], backgroundColor:['#fb7185','#60a5fa'] }]},
        options: { plugins:{legend:{display:false}} }
    });
}

function renderTodaySchedule(schedule, rate) {
    const tbody = document.querySelector('#todaySchedule tbody');
    tbody.innerHTML = '';
    if (!schedule || schedule.length === 0) {
        const tr = document.createElement('tr');
        tr.innerHTML = '<td colspan="5" style="color:#9ca3af;padding:12px;">No scheduled appliances</td>';
        tbody.appendChild(tr);
        return;
    }

    schedule.forEach((it) => {
        const cost = (it.power * it.duration / 60 / 1000 * rate).toFixed(2);
        const tr = document.createElement('tr');
        tr.innerHTML = `<td>${it.name}</td><td>${formatTime(it.start_time)}</td><td>${formatTime(it.end_time)}</td><td>${(it.power/1000).toFixed(2)} kW</td><td>$${cost}</td>`;
        tbody.appendChild(tr);
    });
}

function formatTime(t) {
    const hh = Math.floor(t);
    const mm = Math.round((t % 1) * 60);
    return String(hh).padStart(2,'0') + ':' + String(mm).padStart(2,'0');
}

function goToOptimize() {
    window.location.href = 'index.html';
}

window.addEventListener('DOMContentLoaded', loadDashboard);
