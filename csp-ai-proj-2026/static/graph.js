let graphChart = null;

async function loadGraph() {
    try {
        // Call same optimize endpoint to retrieve time_series used by dashboard
        const res = await fetch('/api/optimize', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({}) });
        const data = await res.json();
        const ts = data.time_series || data;
        renderGraph(ts);
    } catch (e) {
        console.error('Failed to load graph data', e);
        // fallback: small dummy timeseries
        const ts = Array.from({ length: 24 }, (_, i) => ({ time: `${i}:00`, grid: 0, solar: Math.max(0, Math.sin(i / 24 * Math.PI) * 4), battery: Math.random() * 1.2 - 0.6, load: Math.random() * 2 + 1 }));
        renderGraph(ts);
    }
}

function renderGraph(ts) {
    const ctx = document.getElementById('graphChart').getContext('2d');
    if (graphChart) graphChart.destroy();

    graphChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: ts.map(s => s.time),
            datasets: [
                { id: 'grid', label: 'Grid', data: ts.map(s => s.grid), borderColor: '#4338ca', backgroundColor: 'rgba(67, 56, 202, 0.08)', fill: true, tension: 0.4, pointRadius: 0 },
                { id: 'solar', label: 'Solar', data: ts.map(s => s.solar), borderColor: '#f59e0b', backgroundColor: 'rgba(245, 158, 11, 0.08)', fill: true, tension: 0.4, pointRadius: 0 },
                { id: 'battery', label: 'Battery', data: ts.map(s => s.battery), borderColor: '#10b981', backgroundColor: 'rgba(16, 185, 129, 0.08)', fill: true, tension: 0.4, pointRadius: 0 },
                { id: 'demand', label: 'Demand', data: ts.map(s => s.load), borderColor: '#1b4332', borderDash: [5, 5], fill: false, tension: 0.1, pointRadius: 0 }
            ]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            scales: { x: { ticks: { maxTicksLimit: 12, color: '#1b4332' }, grid: { display: false } }, y: { ticks: { color: '#1b4332' }, grid: { color: 'rgba(0,0,0,0.03)' } } },
            plugins: { legend: { display: true } }
        }
    });

    // wire up buttons
    document.getElementById('btn-grid').onclick = () => showOnly('Grid');
    document.getElementById('btn-solar').onclick = () => showOnly('Solar');
    document.getElementById('btn-battery').onclick = () => showOnly('Battery');
    document.getElementById('btn-demand').onclick = () => showOnly('Demand');
    document.getElementById('btn-reset').onclick = () => showAll();
}

function showOnly(label) {
    if (!graphChart) return;
    graphChart.data.datasets.forEach(ds => ds.hidden = (ds.label !== label));
    graphChart.update();
}

function showAll() {
    if (!graphChart) return;
    graphChart.data.datasets.forEach(ds => ds.hidden = false);
    graphChart.update();
}

window.onload = loadGraph;
