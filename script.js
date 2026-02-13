// Global state
let appliances = [];
const API_URL = 'http://localhost:5000/api';

// DOM Elements
const applianceForm = document.getElementById('applianceForm');
const appliancesList = document.getElementById('appliancesList');
const optimizeBtn = document.getElementById('optimizeBtn');
const resultsContainer = document.getElementById('resultsContainer');
const optimizationResults = document.getElementById('optimizationResults');
const summaryStats = document.getElementById('summaryStats');
const loadingSpinner = document.getElementById('loadingSpinner');
const errorToast = document.getElementById('errorToast');
const successToast = document.getElementById('successToast');

// Event Listeners
applianceForm.addEventListener('submit', handleAddAppliance);
optimizeBtn.addEventListener('click', handleOptimize);

/**
 * Handle adding a new appliance
 */
function handleAddAppliance(e) {
    e.preventDefault();

    const appliance = {
        id: Date.now(),
        name: document.getElementById('applianceName').value.trim(),
        power: parseFloat(document.getElementById('power').value),
        duration: parseFloat(document.getElementById('duration').value),
        priority: document.getElementById('priority').value,
        deadline: parseFloat(document.getElementById('deadline').value)
    };

    if (!appliance.name || appliance.power <= 0 || appliance.duration <= 0) {
        showErrorToast('Please fill all required fields with valid values');
        return;
    }

    appliances.push(appliance);
    applianceForm.reset();
    renderAppliancesList();
    showSuccessToast(`${appliance.name} added successfully!`);
    updateOptimizeButton();
}

/**
 * Render appliances list
 */
function renderAppliancesList() {
    if (appliances.length === 0) {
        appliancesList.innerHTML = '<p class="empty-state">No appliances added yet. Add an appliance to get started!</p>';
        return;
    }

    appliancesList.innerHTML = appliances.map(appliance => `
        <div class="appliance-item">
            <h4>${appliance.name}</h4>
            <div class="appliance-detail"><strong>Power:</strong> ${appliance.power} W</div>
            <div class="appliance-detail"><strong>Duration:</strong> ${appliance.duration} mins</div>
            <div class="appliance-detail"><strong>Deadline:</strong> ${appliance.deadline}:00</div>
            <span class="priority-badge ${appliance.priority}">${appliance.priority.toUpperCase()}</span>
            <button class="btn btn-remove" onclick="removeAppliance(${appliance.id})">Remove</button>
        </div>
    `).join('');
}

/**
 * Remove an appliance
 */
function removeAppliance(id) {
    appliances = appliances.filter(app => app.id !== id);
    renderAppliancesList();
    updateOptimizeButton();
    resultsContainer.classList.add('hidden');
    showSuccessToast('Appliance removed');
}

/**
 * Update optimize button state
 */
function updateOptimizeButton() {
    optimizeBtn.disabled = appliances.length === 0;
}

/**
 * Handle optimize scheduling
 */
async function handleOptimize() {
    if (appliances.length === 0) {
        showErrorToast('Please add at least one appliance');
        return;
    }

    const maxPower = parseFloat(document.getElementById('maxPower').value);
    const maxCost = parseFloat(document.getElementById('maxCost').value);
    const electricityRate = parseFloat(document.getElementById('electricityRate').value);
    const timeWindowStart = parseInt(document.getElementById('timeWindowStart').value);
    const timeWindowEnd = parseInt(document.getElementById('timeWindowEnd').value);
    const maxConcurrent = parseInt(document.getElementById('maxConcurrent').value);
    const nightUsageAllowed = document.getElementById('nightUsageAllowed').value === 'true';

    if (maxPower <= 0 || maxCost <= 0 || electricityRate <= 0) {
        showErrorToast('Please set valid system constraints');
        return;
    }

    // Validate time window
    if (!(timeWindowStart >= 0 && timeWindowStart < 24 && timeWindowEnd > 0 && timeWindowEnd <= 24 && timeWindowStart < timeWindowEnd)) {
        showErrorToast('Please provide a valid global time window (start < end, 0-24)');
        return;
    }

    if (!(maxConcurrent >= 1)) {
        showErrorToast('Max concurrent devices must be at least 1');
        return;
    }

    showLoadingSpinner(true);
    optimizeBtn.disabled = true;

    try {
        console.log('Sending optimization request', { appliances, constraints: { maxPower, maxCost, electricityRate } });
        const response = await fetch(`${API_URL}/optimize`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                appliances: appliances,
                constraints: {
                    max_power: maxPower,
                    max_cost: maxCost,
                    electricity_rate: electricityRate,
                    time_window_start: timeWindowStart,
                    time_window_end: timeWindowEnd,
                    max_concurrent: maxConcurrent,
                    night_usage_allowed: nightUsageAllowed
                }
            })
        });

        let result = null;
        try {
            result = await response.json();
        } catch (err) {
            console.error('Failed to parse JSON from server', err);
            showErrorToast('Server returned invalid response. Check backend logs.');
            return;
        }

        if (!response.ok) {
            const msg = result && result.message ? result.message : `Server error: ${response.status}`;
            console.error('Server error', response.status, msg);
            showErrorToast(msg);
            return;
        }

        if (!result.success) {
            console.warn('Optimization failed:', result.message);
            showErrorToast(result.message || 'Optimization failed - no feasible schedule');
            return;
        }

        const payload = result.data;
        if (!payload || !payload.schedule || payload.schedule.length === 0) {
            showErrorToast('No feasible schedule found. Try relaxing constraints (increase power/cost or extend deadlines).');
            return;
        }

        try {
            localStorage.setItem('lastSchedule', JSON.stringify(payload));
        } catch (e) {
            console.warn('Could not save to localStorage', e);
        }

        // Inform user if a greedy fallback was used for speed
        if (payload.solver && payload.solver === 'greedy') {
            showSuccessToast('Optimization completed using fast fallback (greedy) for many devices. Redirecting...');
        } else {
            showSuccessToast('Scheduling optimized successfully! Redirecting to schedule...');
        }
        setTimeout(() => {
            window.location.href = 'schedule.html';
        }, 800);

    } catch (error) {
        console.error('Error during optimization request:', error);
        const msg = error && error.message ? error.message : 'Failed to connect to optimization service. Make sure the backend is running.';
        showErrorToast(msg);
    } finally {
        showLoadingSpinner(false);
        optimizeBtn.disabled = false;
    }
}

/**
 * Display optimization results
 */
function displayOptimizationResults(data) {
    resultsContainer.classList.remove('hidden');

    let html = '';
    let totalPower = 0;
    let totalCost = 0;
    let totalTime = 0;

    if (data.schedule && data.schedule.length > 0) {
        data.schedule.forEach((item, index) => {
            const startHour = Math.floor(item.start_time);
            const startMin = Math.round((item.start_time % 1) * 60);
            const endHour = Math.floor(item.end_time);
            const endMin = Math.round((item.end_time % 1) * 60);

            const cost = (item.power * item.duration / 60 / 1000 * data.electricity_rate).toFixed(2);

            html += `
                <div class="schedule-item">
                    <h4>${index + 1}. ${item.name}</h4>
                    <div class="schedule-detail">
                        <span><strong>Power:</strong></span>
                        <span>${item.power} W</span>
                    </div>
                    <div class="schedule-detail">
                        <span><strong>Duration:</strong></span>
                        <span>${item.duration} minutes</span>
                    </div>
                    <div class="schedule-detail">
                        <span><strong>Estimated Cost:</strong></span>
                        <span>$${cost}</span>
                    </div>
                    <div class="time-window">
                        ⏰ Optimal Time: ${String(startHour).padStart(2, '0')}:${String(startMin).padStart(2, '0')} - ${String(endHour).padStart(2, '0')}:${String(endMin).padStart(2, '0')}
                    </div>
                </div>
            `;

            totalPower += item.power;
            totalCost += parseFloat(cost);
            totalTime += item.duration;
        });

        optimizationResults.innerHTML = html;

        // Update summary stats
        summaryStats.classList.remove('hidden');
        document.getElementById('totalPower').textContent = totalPower.toLocaleString();
        document.getElementById('totalCost').textContent = '$' + totalCost.toFixed(2);
        document.getElementById('totalTime').textContent = (totalTime / 60).toFixed(1) + 'h';
    } else {
        optimizationResults.innerHTML = `
            <div style="padding: 20px; text-align: center; color: #ef4444;">
                <p><strong>⚠️ No feasible schedule found</strong></p>
                <p>The constraints cannot be satisfied with the current appliances and limitations.</p>
                <p style="margin-top: 10px; font-size: 0.9em;">Try:</p>
                <ul style="text-align: left; display: inline-block;">
                    <li>Increasing power limit</li>
                    <li>Increasing cost budget</li>
                    <li>Extending deadlines</li>
                </ul>
            </div>
        `;
        summaryStats.classList.add('hidden');
    }
}

/**
 * Show loading spinner
 */
function showLoadingSpinner(show) {
    if (show) {
        loadingSpinner.classList.remove('hidden');
    } else {
        loadingSpinner.classList.add('hidden');
    }
}

/**
 * Show error toast
 */
function showErrorToast(message) {
    errorToast.textContent = message;
    errorToast.classList.remove('hidden');
    setTimeout(() => {
        errorToast.classList.add('hidden');
    }, 4000);
}

/**
 * Show success toast
 */
function showSuccessToast(message) {
    successToast.textContent = message;
    successToast.classList.remove('hidden');
    setTimeout(() => {
        successToast.classList.add('hidden');
    }, 3000);
}

// Initialize
updateOptimizeButton();
