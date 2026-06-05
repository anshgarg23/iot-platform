import paho.mqtt.client as mqtt
import json

client = mqtt.Client()
client.connect("localhost", 1883, 60)

message = json.dumps({"tag_id": 1, "value": 85.5})
client.publish("iot/sensors/machine-a", message)
print("✅ Message sent!")
client.disconnect()