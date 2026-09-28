# KrishiSense Hardware

## Current Prototype

- ESP32
- Capacitive soil-moisture sensor

The current physical prototype uses one sensor node. The software architecture is designed to support multiple nodes.

## Current Data Flow

```text
Soil
  ↓
Soil Moisture Sensor
  ↓
ESP32
  ↓
Wi-Fi
  ↓
FastAPI Backend
  ↓
Database
```

## Node Identity

Each physical device is represented as a software node with a unique `node_id` / `device_id`.

Current prototype node:

```text
node_id: FS001
```

Nodes are assigned to zones. Multiple nodes can be associated with a zone when required; a node is not equivalent to an acre.

## Current Prototype Calibration

The current prototype calibration observed:

- Dry reference ADC: **4095**
- Wet reference ADC: **1176**

The exact calibration should be refined for the final physical sensor and deployment conditions.

## Hardware Integration Boundary

```text
Decision
   ↓
Backend
   ↓
Hardware Integration
   ↓
ESP32
   ↓
Safe Relay / Controller
   ↓
Pump
```

The ESP32 GPIO must **not** directly drive a farm mains motor. Any pump demonstration must use an appropriate relay/controller, electrical isolation and a safe prototype setup.

## Future Hardware

Temperature/humidity, light, pH, EC, field cameras, LoRa and other sensors can be added without changing the high-level Farm → Field → Zone → Node architecture.
