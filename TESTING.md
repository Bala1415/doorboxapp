# Quick API Test Commands

## Test the sensor push API

### Using curl (Windows PowerShell)
```powershell
curl -X POST http://localhost:8000/api/sensor/push `
-H "Content-Type: application/json" `
-d '{\"hardwareid\":\"pi_test\",\"boxstate\":\"0\",\"packagestate\":\"1\",\"alarmstate\":\"0\"}'
```

### Using curl (Linux/Mac)
```bash
curl -X POST http://localhost:8000/api/sensor/push \
-H "Content-Type: application/json" \
-d '{"hardwareid":"pi_test","boxstate":"0","packagestate":"1","alarmstate":"0"}'
```

### Using Python
```python
import requests

data = {
    "hardwareid": "pi_test",
    "boxstate": "0",
    "packagestate": "1",
    "alarmstate": "0",
    "firmwareversion": "1.0.0"
}

response = requests.post("http://localhost:8000/api/sensor/push", json=data)
print(response.json())
```

## Test retrieve data API

### Get device UI data
```bash
curl http://localhost:8000/api/device/pi_test/ui
```

### Get raw device data
```bash
curl http://localhost:8000/api/device/pi_test/raw
```

### Get all devices
```bash
curl http://localhost:8000/api/devices
```

## For Frontend Developer

Replace `localhost` with your actual server IP address when testing from a different machine.

Example with server IP:
```javascript
fetch('http://192.168.1.100:8000/api/device/pi_001/ui')
  .then(res => res.json())
  .then(data => console.log(data));
```
