# KrishiSense Hardware

## Current Prototype
- ESP32
- Soil-moisture sensor

## Data Flow

```text
Soil → Soil Moisture Sensor → ESP32 → Wi-Fi → Backend
```

## Node Identity
Each physical device is represented as a software node with a unique `node_id`/`device_id`.

Prototype example: `NODE_001`.

The architecture supports multiple nodes assigned to different zones.

## Safety Boundary
ESP32 GPIO must not directly drive a farm mains motor. Any pump demonstration must use an appropriate relay/controller, electrical isolation and a safe prototype setup.

## Future Hardware
Temperature/humidity, light, pH, EC, LoRa and other sensors can be added without changing the high-level architecture.
