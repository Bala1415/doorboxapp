import json
import threading
import paho.mqtt.client as mqtt
from fastapi import FastAPI
from pydantic import BaseModel
from datetime import datetime
import uvicorn

app = FastAPI()

latest_device_data = {}

# EIOT MQTT CONFIG
MQTT_BROKER = "34.118.207.145"
MQTT_PORT = 5000
MQTT_TOPIC = "hwsave_92250815"


def on_connect(client, userdata, flags, rc):
    print("✅ Connected to EIOT MQTT broker")
    client.subscribe(MQTT_TOPIC)


def on_message(client, userdata, msg):
    payload = msg.payload.decode()
    print(f"📥 MQTT message received: {payload}")  # <--- Add this line
    try:
        data = json.loads(payload)
        device_id = data.get("hardwareid")

        if device_id:
            latest_device_data[device_id] = data
            print(f"📩 Device {device_id} updated")
    except Exception as e:
        print("❌ Invalid JSON:", e)

def start_mqtt():
    client = mqtt.Client()
    client.on_connect = on_connect
    client.on_message = on_message
    client.connect(MQTT_BROKER, MQTT_PORT)
    client.loop_forever()


# -------- API ROUTES --------

@app.get("/api/device/{device_id}/ui")
def device_ui(device_id: str):
    data = latest_device_data.get(device_id)

    if not data:
        return {"online": False}

    return {
        "online": True,
        "device_id": device_id,
        "box_locked": data.get("boxstate") == "0",
        "package_state": int(data.get("packagestate", 0)),
        "alarm_active": data.get("alarmstate") != "0",
        "firmware_version": data.get("firmwareversion"),
        "last_seen": data.get("currentdatetime"),
        "photo_enabled": data.get("ondemandphoto") == "1",
        "video_enabled": data.get("ondemandvideo") == "1",
    }


@app.get("/api/device/{device_id}/raw")
def device_raw(device_id: str):
    return latest_device_data.get(device_id, {})


@app.get("/api/devices")
def all_devices():
    return list(latest_device_data.keys())


# -------- SENSOR PUSH API (FOR RASPBERRY PI) --------

class SensorData(BaseModel):
    hardwareid: str
    boxstate: str = None
    packagestate: str = None
    alarmstate: str = None
    firmwareversion: str = None
    ondemandphoto: str = None
    ondemandvideo: str = None
    custom_data: dict = None


@app.post("/api/sensor/push")
def push_sensor_data(data: SensorData):
    """
    API endpoint for Raspberry Pi to push sensor data
    
    Example usage from Raspberry Pi (Python):
    ```python
    import requests
    
    sensor_data = {
        "hardwareid": "pi_001",
        "boxstate": "0",  # 0=locked, 1=unlocked
        "packagestate": "1",  # 0=empty, 1=package present
        "alarmstate": "0",
        "firmwareversion": "1.0.0"
    }
    
    response = requests.post("http://YOUR_SERVER_IP:8000/api/sensor/push", json=sensor_data)
    print(response.json())
    ```
    
    Example usage from Raspberry Pi (curl):
    ```bash
    curl -X POST http://YOUR_SERVER_IP:8000/api/sensor/push \\
         -H "Content-Type: application/json" \\
         -d '{"hardwareid":"pi_001","boxstate":"0","packagestate":"1"}'
    ```
    """
    device_id = data.hardwareid
    
    # Create payload matching MQTT format
    payload = {
        "hardwareid": device_id,
        "currentdatetime": datetime.now().isoformat(),
        "boxstate": data.boxstate,
        "packagestate": data.packagestate,
        "alarmstate": data.alarmstate,
        "firmwareversion": data.firmwareversion,
        "ondemandphoto": data.ondemandphoto,
        "ondemandvideo": data.ondemandvideo
    }
    
    # Add any custom data fields
    if data.custom_data:
        payload.update(data.custom_data)
    
    # Remove None values
    payload = {k: v for k, v in payload.items() if v is not None}
    
    # Store in memory (same as MQTT data)
    latest_device_data[device_id] = payload
    
    print(f"📊 Sensor data pushed from Pi: {device_id}")
    
    return {
        "success": True,
        "message": f"Data stored for device {device_id}",
        "device_id": device_id,
        "timestamp": payload["currentdatetime"]
    }


@app.on_event("startup")
def list_routes():
    print("\n📌 REGISTERED ROUTES:")
    for route in app.routes:
        print(route.path)
    print("📌 END ROUTES\n")

# -------- START --------

if __name__ == "__main__":
    threading.Thread(target=start_mqtt, daemon=True).start()
    uvicorn.run(app, host="0.0.0.0", port=8000)
