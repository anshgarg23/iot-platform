import paho.mqtt.client as mqtt
import psycopg2
import json
from datetime import datetime

# --- Database connection ---
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "database": "iotdb",
    "user": "admin",
    "password": "admin123"
}

# --- MQTT Settings ---
MQTT_BROKER = "localhost"
MQTT_PORT = 1883
MQTT_TOPIC = "iot/sensors/#"  # # means listen to ALL sensor topics

# --- Connect to PostgreSQL ---
def get_db_connection():
    return psycopg2.connect(**DB_CONFIG)

# --- Called when connected to EMQX ---
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("✅ Connected to EMQX broker!")
        client.subscribe(MQTT_TOPIC)
        print(f"📡 Listening on topic: {MQTT_TOPIC}")
    else:
        print(f"❌ Connection failed with code {rc}")

# --- Called when a message arrives ---
def on_message(client, userdata, msg):
    try:
        # Decode the message
        payload = json.loads(msg.payload.decode())
        print(f"📨 Received on '{msg.topic}': {payload}")

        tag_id = payload.get("tag_id")
        value  = payload.get("value")

        if tag_id is None or value is None:
            print("⚠️  Missing tag_id or value, skipping...")
            return

        # Save to database
        conn = get_db_connection()
        cur  = conn.cursor()
        cur.execute(
            "INSERT INTO telemetry (tag_id, value, recorded_at) VALUES (%s, %s, %s)",
            (tag_id, value, datetime.utcnow())
        )
        conn.commit()
        cur.close()
        conn.close()
        print(f"✅ Saved to DB — tag_id={tag_id}, value={value}")

    except Exception as e:
        print(f"❌ Error: {e}")

# --- Start the subscriber ---
client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

print("🔌 Connecting to EMQX...")
client.connect(MQTT_BROKER, MQTT_PORT, 60)
client.loop_forever()  # Keep running and listening