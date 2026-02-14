"""
Raspberry Pi Sensor Data Pusher
Example script to send sensor data to DoorBox backend
"""

import requests
import time
import json
from datetime import datetime

# Configuration
API_URL = "http://YOUR_SERVER_IP:8000/api/sensor/push"  # Replace with your server IP
DEVICE_ID = "pi_001"  # Unique ID for this Pi
SEND_INTERVAL = 5  # Send data every 5 seconds

def read_sensors():
    """
    Read sensor data from GPIO pins or sensors
    Replace this with your actual sensor reading logic
    """
    # Example: Reading from GPIO or sensor libraries
    # import RPi.GPIO as GPIO
    
    # Simulated sensor data (replace with actual sensor reading)
    sensor_data = {
        "hardwareid": DEVICE_ID,
        "boxstate": "0",  # 0 = locked, 1 = unlocked
        "packagestate": "1",  # 0 = empty, 1 = package present
        "alarmstate": "0",  # 0 = no alarm, 1 = alarm triggered
        "firmwareversion": "1.0.0",
        "ondemandphoto": "0",
        "ondemandvideo": "0"
    }
    
    return sensor_data


def push_to_server(data):
    """Send sensor data to backend API"""
    try:
        response = requests.post(API_URL, json=data, timeout=5)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Data sent successfully at {result['timestamp']}")
            return True
        else:
            print(f"❌ Server error: {response.status_code}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to server")
        return False
    except requests.exceptions.Timeout:
        print("❌ Request timeout")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False


def main():
    """Main loop - read sensors and push data"""
    print(f"🚀 Starting sensor data pusher for device: {DEVICE_ID}")
    print(f"📡 Sending data to: {API_URL}")
    print(f"⏱️  Interval: {SEND_INTERVAL} seconds\n")
    
    while True:
        try:
            # Read sensor data
            sensor_data = read_sensors()
            
            # Add timestamp
            sensor_data['currentdatetime'] = datetime.now().isoformat()
            
            # Print what we're sending
            print(f"📤 Sending: {json.dumps(sensor_data, indent=2)}")
            
            # Push to server
            push_to_server(sensor_data)
            
            # Wait before next reading
            print(f"⏳ Waiting {SEND_INTERVAL} seconds...\n")
            time.sleep(SEND_INTERVAL)
            
        except KeyboardInterrupt:
            print("\n👋 Stopping sensor pusher...")
            break
        except Exception as e:
            print(f"❌ Unexpected error: {e}")
            time.sleep(SEND_INTERVAL)


if __name__ == "__main__":
    main()
