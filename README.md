# CSP-Based Smart Home Energy Management System

A constraint satisfaction problem (CSP) based solution for optimizing smart home appliance usage under power, time, and cost limitations.

## 📋 Features

- **User-Friendly Interface**: Add appliances with power consumption, duration, deadlines, and priority levels
- **CSP Optimization**: Uses constraint satisfaction to find optimal scheduling
- **Real-Time Scheduling**: Shows exact time windows for appliance usage
- **Cost Estimation**: Calculates energy costs based on electricity rates
- **Smart Constraints**:
  - Power limit (avoid overloading circuits)
  - Cost budget (stay within energy spending limits)
  - Deadline constraints (appliances must finish by specified time)
  - Priority-based scheduling

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- Node.js/npm (optional, for development)

### Installation

1. **Clone/Download the project**
```bash
cd "c:\Users\ASUS\AI PROJECT"
```

2. **Install Python dependencies**
```bash
pip install -r requirements.txt
```

3. **Start the backend server**
```bash
python app.py
```
The server will start on `http://localhost:5000`

4. **Open the frontend**
Open `index.html` in your web browser
- Right-click on `index.html` → Open with → Your browser
- Or use a local server: `python -m http.server 8000`

## 📖 Usage Guide

### Adding Appliances

1. Enter appliance details:
   - **Name**: Device name (e.g., "Washing Machine")
   - **Power Consumption**: Watts (e.g., 2000 W)
   - **Duration**: Minutes (e.g., 60 min)
   - **Priority**: Low, Medium, or High
   - **Deadline**: Hour by which appliance must finish (0-24)

2. Click **"+ Add Appliance"** to add to the list

3. Repeat for each appliance

### Setting System Constraints

Before optimizing, configure your system limits:
- **Max Power Available**: Maximum simultaneous power draw (Watts)
- **Max Cost Budget**: Total budget for electricity ($)
- **Electricity Rate**: Cost per kilowatt-hour ($/kWh)

### Optimizing Schedule

1. After adding appliances, click **"🚀 Optimize Scheduling"**
2. View the results showing:
   - Optimal time windows for each appliance
   - Estimated costs
   - Total power consumption
   - Summary statistics

## 🔧 Technical Architecture

### Frontend (HTML/CSS/JavaScript)
- Responsive UI with real-time form validation
- API communication with backend
- Visual feedback with loading states and notifications

### Backend (Python Flask)
- REST API for optimization requests
- CSP solver using `python-constraint` library
- Constraint validation and scheduling algorithm
- CORS enabled for frontend communication

### Constraints Implemented

```
maximize(feasibility) subject to:
1. Power Constraint: sum(power_i * t_i) ≤ max_power for all time t
2. Deadline Constraint: start_time_i + duration_i ≤ deadline_i
3. Cost Constraint: sum(cost_i) ≤ max_budget
4. No Overlap: Appliances can share time if total power allows
```

## 📊 Example Scenario

**System Configuration:**
- Max Power: 5000 W
- Max Cost: $50
- Electricity Rate: $0.12/kWh

**Appliances:**
1. Washing Machine: 2000W, 60 min, deadline 12:00 (High priority)
2. Dishwasher: 1800W, 90 min, deadline 18:00 (Medium priority)
3. Air Conditioner: 3500W, 480 min, deadline 24:00 (Low priority)

**Result:**
- Washing Machine: 06:00 - 07:00
- Dishwasher: 16:00 - 17:30
- Air Conditioner: 12:00 - 20:00

## 🛠️ Customization

### Modify Time Slots
In `app.py`, adjust interval in `_generate_time_slots()`:
```python
slots = []
current = 0.0
while current < 24.0:
    slots.append(current)
    current += 0.25  # Change interval (0.25 = 15 min slots)
```

### Add New Constraints
In `EnergyScheduler` class:
```python
def _check_custom_constraint(self, *start_times):
    # Your constraint logic
    return True
```

## 📝 API Reference

### POST /api/optimize
Optimize appliance scheduling

**Request:**
```json
{
  "appliances": [
    {
      "name": "Washing Machine",
      "power": 2000,
      "duration": 60,
      "priority": "high",
      "deadline": 12
    }
  ],
  "constraints": {
    "max_power": 5000,
    "max_cost": 50,
    "electricity_rate": 0.12
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "schedule": [
      {
        "name": "Washing Machine",
        "power": 2000,
        "duration": 60,
        "start_time": 6.0,
        "end_time": 7.0,
        "priority": "high",
        "cost": 0.12
      }
    ],
    "total_cost": 0.12,
    "total_power": 2000,
    "electricity_rate": 0.12,
    "feasible": true
  }
}
```

## 🐛 Troubleshooting

### Backend not connecting
- Ensure Flask server is running on http://localhost:5000
- Check if port 5000 is available (not used by another application)
- Verify CORS is enabled

### No feasible schedule found
- Increase max power limit
- Increase cost budget
- Extend appliance deadlines
- Reduce appliance durations or power consumption

### Installation issues
```bash
# Clear pip cache and reinstall
pip cache purge
pip install -r requirements.txt --no-cache-dir
```

## 📚 Research Paper Context

This system implements CSP-based optimization as described in:
"Integrated Optimization of Smart Home Appliances with Cost-effective Energy Management System"

Key innovations:
- Multi-constraint satisfaction
- Priority-aware scheduling
- Real-time cost estimation
- Deadline compliance verification

## 📄 License

Open source for educational and research purposes

## 👨‍💻 Author

Smart Home Energy Management Project Team

## 📧 Support

For issues or suggestions, refer to the documentation or check the console for error messages.

---

**Last Updated:** February 2026
