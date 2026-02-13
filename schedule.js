// Read schedule from localStorage and render timeline + chart

function loadSchedule() {
    const raw = localStorage.getItem('lastSchedule');
    if (!raw) {
        document.getElementById('timeline').innerHTML = '<p style="padding:12px; color:#9ca3af;">No schedule found. Return to the main page and run optimization first.</p>';
        return;
    }

    const data = JSON.parse(raw);
    const schedule = data.schedule || [];
    const rate = data.electricity_rate || 0.12;

    renderTimeAxis();
    renderTimelineBlocks(schedule);
    renderDetails(schedule, rate);
    renderPowerChart(schedule);
}

function renderTimeAxis() {
    const axis = document.getElementById('timeAxis');
    axis.innerHTML = '';
    // show labels every 2 hours to avoid clutter
    for (let h = 0; h <= 24; h += 2) {
        const left = (h / 24) * 100;
        const label = document.createElement('div');
        label.className = 'time-label';
        label.style.left = left + '%';
        label.textContent = (h % 24) + ':00';
        axis.appendChild(label);
    }
}

function renderTimelineBlocks(schedule) {
    const container = document.getElementById('timeline');
    container.innerHTML = '';
    // Layout: place blocks according to start & duration. If overlap occurs, stagger rows (max 4 rows)
    const rows = [[], [], [], []];
    schedule.forEach((item) => {
        const start = item.start_time; // hours
        const duration = item.duration / 60.0; // hours
        const leftPct = (start / 24) * 100;
        const widthPct = Math.max((duration / 24) * 100, 1.5);

        // find a row where this block doesn't overlap existing blocks
        let placedRow = 0;
        for (let r = 0; r < rows.length; r++) {
            const row = rows[r];
            const overlap = row.some(b => !(b.end <= start || b.start >= (start + duration)));
            if (!overlap) { placedRow = r; row.push({ start, end: start + duration }); break; }
        }

        const top = 8 + placedRow * 44;

        const block = document.createElement('div');
        block.className = 'timeline-block';
        // priority class
        const pr = (item.priority || 'medium').toLowerCase();
        block.classList.add(pr === 'high' ? 'priority-high' : pr === 'low' ? 'priority-low' : 'priority-medium');

        block.style.left = leftPct + '%';
        block.style.top = top + 'px';
        block.style.width = `calc(${widthPct}% - 6px)`;
        block.style.minWidth = '80px';

        const meta = `${formatTime(item.start_time)} - ${formatTime(item.end_time)} • ${item.power}W • ${item.duration} min`;
        block.innerHTML = `<div class="tb-title">${item.name}</div><div class="tb-meta">${meta}</div>`;
        // native tooltip for full details
        block.title = `${item.name}\n${meta}`;
        container.appendChild(block);
    });
}

function formatTime(t) {
    const hh = Math.floor(t);
    const mm = Math.round((t % 1) * 60);
    return String(hh).padStart(2, '0') + ':' + String(mm).padStart(2, '0');
}

function renderDetails(schedule, rate) {
    const list = document.getElementById('detailsList');
    list.innerHTML = '';

    let totalCost = 0;
    schedule.forEach((it) => {
        const cost = (it.power * it.duration / 60 / 1000 * rate);
        totalCost += cost;

        const node = document.createElement('div');
        node.className = 'appliance-item';
        node.innerHTML = `
            <h4>${it.name}</h4>
            <div class="appliance-detail"><strong>Power:</strong> ${it.power} W</div>
            <div class="appliance-detail"><strong>Duration:</strong> ${it.duration} mins</div>
            <div class="appliance-detail"><strong>Time:</strong> ${formatTime(it.start_time)} - ${formatTime(it.end_time)}</div>
            <div class="appliance-detail"><strong>Est. Cost:</strong> $${cost.toFixed(2)}</div>
        `;
        list.appendChild(node);
    });

    const summary = document.createElement('div');
    summary.style.marginTop = '10px';
    summary.innerHTML = `<strong>Total Estimated Cost:</strong> $${totalCost.toFixed(2)}`;
    list.prepend(summary);
}

function renderPowerChart(schedule) {
    // Build hourly power usage array (24 hours)
    const hourly = new Array(24).fill(0);
    schedule.forEach((it) => {
        const start = it.start_time;
        const end = it.end_time;
        // iterate in 0.5h steps to distribute
        for (let t = start; t < end; t += 1) {
            const hour = Math.floor(t) % 24;
            hourly[hour] += it.power;
        }
    });

    const ctx = document.getElementById('powerChart').getContext('2d');
    const labels = Array.from({length:24}, (_,i) => i + ':00');

    // Destroy existing chart if present
    if (window._powerChart) window._powerChart.destroy();

    window._powerChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Power (W)',
                data: hourly,
                backgroundColor: 'rgba(37,99,235,0.7)'
            }]
        },
        options: {
            responsive: true,
            plugins: {
                title: { display: true, text: 'Hourly Power Usage' },
                legend: { display: false },
                tooltip: { callbacks: { label: (ctx) => `${ctx.parsed.y} W` } }
            },
            scales: {
                x: { ticks: { maxRotation: 0 }, title: { display: true, text: 'Hour of Day' } },
                y: { beginAtZero: true, title: { display: true, text: 'Power (W)' }, suggestedMax: Math.max(1000, Math.ceil(Math.max(...hourly)/500)*500) }
            }
        }
    });
}

function goBack() {
    window.location.href = 'index.html';
}

function downloadSchedule() {
    const raw = localStorage.getItem('lastSchedule');
    if (!raw) return alert('No schedule available');
    const blob = new Blob([raw], {type: 'application/json'});
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'schedule.json';
    a.click();
    URL.revokeObjectURL(url);
}

// Initialize
window.addEventListener('DOMContentLoaded', loadSchedule);
