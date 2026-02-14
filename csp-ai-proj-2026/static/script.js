let mainChart = null;
let historyChart = null;

// ================= HISTORY STORAGE =================
let historyData = JSON.parse(localStorage.getItem("shems_history")) || [];

// --- NAVIGATION ---
function showSection(id) {
    document.querySelectorAll('.view-section').forEach(s => s.classList.add('hidden'));
    document.getElementById(`section-${id}`).classList.remove('hidden');
    document.querySelectorAll('.nav-btn').forEach(b => b.classList.remove('active'));
    document.getElementById(`nav-${id}`).classList.add('active');

    if (id === "history") renderHistory(); // auto refresh
}

// --- DATA FETCHING & RENDERING ---
async function fetchApps() {
    const res = await fetch('/api/appliances');
    const apps = await res.json();
    const tbody = document.getElementById('app-list');
    tbody.innerHTML = '';

    apps.forEach(app => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td style="font-weight:700; color:var(--primary)">${app.name}</td>
            <td>${app.power} kW</td>
            <td>${app.duration} mins</td>
            <td><span class="priority-pill prio-${app.priority}">${getPrioLabel(app.priority)}</span></td>
            <td>${formatTime(app.earliest_start)} - ${formatTime(app.latest_end)}</td>
            <td><button class="del-btn" onclick="deleteApp('${app.id}')"><i data-lucide="trash-2"></i></button></td>
        `;
        tbody.appendChild(tr);
    });
    lucide.createIcons();
}

function getPrioLabel(p) {
    if (p >= 5) return 'Critical';
    if (p >= 4) return 'High';
    if (p >= 3) return 'Standard';
    return 'Low';
}

function formatTime(m) {
    return `${Math.floor(m / 60).toString().padStart(2, '0')}:${(m % 60).toString().padStart(2, '0')}`;
}

// --- CRUD OPERATIONS ---
async function deleteApp(id) {
    if (!confirm('Permanently remove this device-pulse?')) return;
    try {
        const res = await fetch(`/api/appliances/${id}`, { method: 'DELETE' });
        if (res.ok) {
            await fetchApps();
            runBatchTest();
        } else {
            const err = await res.json();
            alert(err.detail);
        }
    } catch (e) { console.error(e); }
}

async function addApp(e) {
    e.preventDefault();
    const overlay = document.getElementById('modal-overlay');
    const btn = e.target.querySelector('button[type="submit"]');
    const originalText = btn.innerHTML;

    btn.innerHTML = '<i data-lucide="loader" class="spin"></i> Binding...';
    lucide.createIcons();

    try {
        const app = {
            id: Date.now().toString(),
            name: document.getElementById('in_name').value,
            power: parseFloat(document.getElementById('in_pwr').value),
            duration: parseInt(document.getElementById('in_dur').value),
            earliest_start: timeToMins(document.getElementById('in_start').value),
            latest_end: timeToMins(document.getElementById('in_end').value),
            priority: parseInt(document.getElementById('in_prio').value)
        };
        const res = await fetch('/api/appliances', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(app)
        });

        if (res.ok) {
            overlay.classList.add('hidden');
            document.getElementById('app-form').reset();
            await fetchApps();
            runBatchTest();
        } else {
            const err = await res.json();
            alert("Error: " + err.detail);
        }
    } catch (e) {
        alert("Sync failed. Check connection.");
    } finally {
        btn.innerHTML = originalText;
        lucide.createIcons();
    }
}

function timeToMins(t) {
    const [h, m] = t.split(':').map(Number);
    return h * 60 + m;
}

// ================= OPTIMIZATION PULSE =================
async function runBatchTest() {
    const btn = document.getElementById('optimize-btn');
    if (!btn) return;

    const original = btn.innerHTML;
    btn.innerHTML = '<i data-lucide="loader" class="spin"></i> Syncing...';
    lucide.createIcons();

    try {
        const res = await fetch('/api/optimize', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });

        const data = await res.json();

        if (data.status === "Success") {

            const cost = parseFloat(data.summary.total_cost);
            const solar = parseFloat(data.summary.solar_savings);
            const battery = parseFloat(data.summary.battery_impact);

            document.getElementById('res-cost').textContent = '₹' + cost;
            document.getElementById('res-solar').textContent = solar + ' kWh';
            document.getElementById('res-batt').textContent = battery + ' kWh';

            renderTimetable(data.schedule);
            updateMainChart(data.time_series);

            saveHistory(cost, solar, battery); // ⭐ NEW

            const adviceContainer = document.getElementById('suggestions-container');
            adviceContainer.innerHTML = data.suggestions.map(s => `
                <div class="suggestion-item">
                    <i data-lucide="leaf"></i>
                    <span>${s}</span>
                </div>
            `).join('');

            lucide.createIcons();

        } else {
            alert("Constraint Error: " + data.suggestions[0]);
        }

    } catch (e) {
        console.error(e);
    }
    finally {
        btn.innerHTML = original;
        lucide.createIcons();
    }
}

// ================= TIMETABLE =================
function renderTimetable(schedule) {
    const list = document.getElementById('timetable-list');
    if (!list) return;

    list.innerHTML = schedule.map(item => `
        <tr style="animation: fadeIn 0.5s ease forwards">
            <td style="font-weight:800; color:var(--primary)">${item.name}</td>
            <td style="color:var(--leaf); font-weight:700;">${formatTime(item.start)} - ${formatTime(item.end)}</td>
            <td style="font-size:0.85rem; max-width:250px; line-height:1.4;">${item.why}</td>
            <td style="font-weight:900; color:var(--moss)">₹${item.saving.toFixed(2)} Saved</td>
            <td><span class="solar-badge">✓ Eco Match</span></td>
        </tr>
    `).join('');
}

// ================= MAIN CHART =================
function updateMainChart(ts) {
    const ctx = document.getElementById('mainChart').getContext('2d');
    if (mainChart) mainChart.destroy();

    mainChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: ts.map(s => s.time),
            datasets: [
                { label: 'Grid', data: ts.map(s => s.grid), borderColor: '#4338ca', backgroundColor: 'rgba(67, 56, 202, 0.1)', fill: true, tension: 0.4, pointRadius: 0 },
                { label: 'Solar', data: ts.map(s => s.solar), borderColor: '#f59e0b', backgroundColor: 'rgba(245, 158, 11, 0.1)', fill: true, tension: 0.4, pointRadius: 0 },
                { label: 'Battery', data: ts.map(s => s.battery), borderColor: '#10b981', backgroundColor: 'rgba(16, 185, 129, 0.1)', fill: true, tension: 0.4, pointRadius: 0 },
                { label: 'Demand', data: ts.map(s => s.load), borderColor: '#1b4332', borderDash: [5, 5], fill: false, tension: 0.1, pointRadius: 0 }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                x: { ticks: { maxTicksLimit: 12, color: '#1b4332' }, grid: { display: false } },
                y: { ticks: { color: '#1b4332' }, grid: { color: 'rgba(0,0,0,0.03)' } }
            },
            plugins: { legend: { display: false } }
        }
    });
}

// ================= HISTORY FUNCTIONS =================

function saveHistory(cost, solar, battery) {

    const entry = {
        date: new Date().toLocaleString(),
        cost,
        solar,
        battery,
        saving: (solar + battery) * 8   // estimated ₹ saving
    };

    historyData.push(entry);

    localStorage.setItem("shems_history", JSON.stringify(historyData));

    renderHistory();
}

function renderHistory() {

    const table = document.getElementById("history-table");
    if (!table) return;

    table.innerHTML = "";

    historyData.forEach(item => {
        table.innerHTML += `
            <tr>
                <td>${item.date}</td>
                <td>₹${item.cost.toFixed(2)}</td>
                <td>${item.solar.toFixed(2)} kWh</td>
                <td>${item.battery.toFixed(2)} kWh</td>
                <td style="font-weight:700;color:var(--leaf)">₹${item.saving.toFixed(2)}</td>
            </tr>
        `;
    });

    renderHistoryChart();
}

function renderHistoryChart() {

    const canvas = document.getElementById("historyChart");
    if (!canvas) return;

    const ctx = canvas.getContext("2d");

    const labels = historyData.map(h => h.date);
    const savings = historyData.map(h => h.saving);

    if (historyChart) historyChart.destroy();

    historyChart = new Chart(ctx, {
        type: "line",
        data: {
            labels,
            datasets: [{
                label: "Savings ₹",
                data: savings,
                borderColor: "#10b981",
                backgroundColor: "rgba(16,185,129,0.15)",
                fill: true,
                tension: 0.4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false
        }
    });
}

// ================= RESET =================
async function resetDefaults() {
    if (!confirm('Restore professional simulation set? This will clear your custom devices.')) return;
    try {
        const res = await fetch('/api/reset', { method: 'POST' });
        if (res.ok) location.reload();
    } catch (e) { console.error(e); }
}

// ================= MODAL =================
const overlay = document.getElementById('modal-overlay');
const closeBtn = document.getElementById('close-btn');
const cancelBtn = document.getElementById('cancel-btn');
const addBtn = document.getElementById('add-btn');

function hideModal() {
    overlay.classList.add('hidden');
}

if (closeBtn) closeBtn.onclick = hideModal;
if (cancelBtn) cancelBtn.onclick = hideModal;
if (addBtn) addBtn.onclick = () => overlay.classList.remove('hidden');

overlay.onclick = (e) => {
    if (e.target === overlay) hideModal();
};

document.getElementById('app-form').onsubmit = addApp;
document.getElementById('optimize-btn').onclick = runBatchTest;

// ================= INIT =================
window.onload = async () => {
    await fetchApps();
    runBatchTest();
    renderHistory();
};
