# DoorBox API Documentation

**Base URL:** `http://YOUR_SERVER_IP:8000`

---

## 📤 Push Sensor Data (For Raspberry Pi)

### POST `/api/sensor/push`

Allows Raspberry Pi to push sensor data to the backend.

**Request Body:**
```json
{
  "hardwareid": "pi_001",
  "boxstate": "0",
  "packagestate": "1",
  "alarmstate": "0",
  "firmwareversion": "1.0.0",
  "ondemandphoto": "0",
  "ondemandvideo": "0"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Data stored for device pi_001",
  "device_id": "pi_001",
  "timestamp": "2026-02-14T10:30:00.123456"
}
```

---

## 📥 Get Device Data (For Frontend)

### GET `/api/device/{device_id}/ui`

Get formatted device data for UI display.

**Example:** `GET /api/device/pi_001/ui`

**Response:**
```json
{
  "online": true,
  "device_id": "pi_001",
  "box_locked": true,
  "package_state": 1,
  "alarm_active": false,
  "firmware_version": "1.0.0",
  "last_seen": "2026-02-14T10:30:00.123456",
  "photo_enabled": false,
  "video_enabled": false
}
```

**Fields:**
- `online`: Boolean - Whether device has sent data
- `device_id`: String - Device identifier
- `box_locked`: Boolean - true if locked (boxstate="0")
- `package_state`: Number - 0=empty, 1=package present
- `alarm_active`: Boolean - Whether alarm is triggered
- `firmware_version`: String - Firmware version
- `last_seen`: String - ISO timestamp of last update
- `photo_enabled`: Boolean - Photo capture enabled
- `video_enabled`: Boolean - Video capture enabled

---

### GET `/api/device/{device_id}/raw`

Get raw sensor data without formatting.

**Example:** `GET /api/device/pi_001/raw`

**Response:**
```json
{
  "hardwareid": "pi_001",
  "currentdatetime": "2026-02-14T10:30:00.123456",
  "boxstate": "0",
  "packagestate": "1",
  "alarmstate": "0",
  "firmwareversion": "1.0.0",
  "ondemandphoto": "0",
  "ondemandvideo": "0"
}
```

---

### GET `/api/devices`

Get list of all device IDs that have sent data.

**Response:**
```json
["pi_001", "pi_002", "pi_003"]
```

---

## Frontend Integration Examples

### JavaScript/React Example

```javascript
// Fetch device status
async function getDeviceStatus(deviceId) {
  const response = await fetch(`http://YOUR_SERVER_IP:8000/api/device/${deviceId}/ui`);
  const data = await response.json();
  
  if (data.online) {
    console.log(`Box is ${data.box_locked ? 'locked' : 'unlocked'}`);
    console.log(`Package: ${data.package_state === 1 ? 'Present' : 'Empty'}`);
  } else {
    console.log('Device offline');
  }
  
  return data;
}

// Get all devices
async function getAllDevices() {
  const response = await fetch('http://YOUR_SERVER_IP:8000/api/devices');
  const devices = await response.json();
  return devices;
}
```

### Using Axios (React/Vue)

```javascript
import axios from 'axios';

const API_BASE_URL = 'http://YOUR_SERVER_IP:8000';

// Get device UI data
const getDevice = async (deviceId) => {
  try {
    const { data } = await axios.get(`${API_BASE_URL}/api/device/${deviceId}/ui`);
    return data;
  } catch (error) {
    console.error('Error fetching device:', error);
  }
};

// Get all devices
const getDevices = async () => {
  const { data } = await axios.get(`${API_BASE_URL}/api/devices`);
  return data;
};
```

---

## Notes for Frontend Developer

1. **CORS:** If frontend is on different domain, you may need to enable CORS in the backend
2. **Polling:** Consider polling `/api/device/{id}/ui` every 2-5 seconds for live updates
3. **WebSocket:** For real-time updates, consider adding WebSocket support later
4. **Error Handling:** Check `online: false` to detect offline devices
5. **Device Discovery:** Use `/api/devices` to get list of available devices

---

## Server Information

- **Backend Port:** 8000
- **Data Storage:** In-memory (resets on restart)
- **Data Sources:** MQTT + REST API
