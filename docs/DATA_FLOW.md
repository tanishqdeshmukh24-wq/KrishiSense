# KrishiSense Data Flow

## Current backend ownership
Ninad owns the core API, persistence and authorization layer. AdiKul owns hardware-facing communication. Tanishq owns AI/ML and decision-engine logic. Tanush consumes the public API from the mobile application.

## Implemented sensor flow

```text
ESP32
  ↓
Hardware integration
  ↓
POST /sensor/readings
  ↓
Backend validation
  ↓
SQLite database
  ├── sensor_readings
  └── sensor_nodes.last_seen / status
  ↓
GET /sensor/readings/{node_id}
  ↓
Mobile app
```

## Implemented farmer hierarchy

```text
User
 ↓
Farm
 ↓
Field
 ↓
Zone
 ├── Crop
 └── SensorNode
```

Ownership is enforced through the farm owner for core farmer-facing routes.

## AI boundary

```text
Mobile image / AI request
        ↓
Backend API
        ↓
AI implementation owned by Tanishq
        ↓
POST /ai/results
        ↓
Database
        ↓
Mobile app
```

The core backend stores and serves AI results; it does not implement the model.

## Decision-engine boundary

```text
Backend data context
        ↓
Decision Engine owned by Tanishq
        ↓
IRRIGATE / WAIT / INSUFFICIENT_DATA
        ↓
Backend recommendation storage
        ↓
Mobile app
```

The `/decision-engine/evaluate` route defines the backend integration boundary. The actual agronomic decision logic is intentionally not implemented in the core backend.

## Hardware boundary

```text
Decision / command
        ↓
Backend
        ↓
Hardware integration owned by AdiKul
        ↓
ESP32 / safe controller
```

The backend does not duplicate ESP32 communication.
