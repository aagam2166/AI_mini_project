import json
import urllib.request

url = 'http://localhost:5000/api/optimize'
payload = {
    'appliances': [
        {'name': 'Test Device', 'power': 1000, 'duration': 60, 'priority': 'medium', 'deadline': 24}
    ],
    'constraints': {'max_power': 5000, 'max_cost': 50, 'electricity_rate': 0.12}
}

req = urllib.request.Request(url, data=json.dumps(payload).encode('utf-8'), headers={'Content-Type':'application/json'})
with urllib.request.urlopen(req, timeout=10) as resp:
    data = resp.read().decode('utf-8')
    print(data)
