import json, urllib.request, time

url = 'http://localhost:5000/api/optimize'
# create 8 appliances to test performance
appliances = []
for i in range(8):
    appliances.append({
        'name': f'Device{i+1}',
        'power': 1000 + (i%3)*500,
        'duration': 60 + (i%4)*30,
        'priority': ['low','medium','high'][i%3],
        'deadline': 24 - (i%5)
    })

payload = {'appliances': appliances, 'constraints': {'max_power': 5000, 'max_cost': 200, 'electricity_rate': 0.12}}
req = urllib.request.Request(url, data=json.dumps(payload).encode('utf-8'), headers={'Content-Type':'application/json'})
start = time.time()
with urllib.request.urlopen(req, timeout=20) as resp:
    data = resp.read().decode('utf-8')
    elapsed = time.time() - start
    print('Elapsed:', elapsed)
    print(data)
