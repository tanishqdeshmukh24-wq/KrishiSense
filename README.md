# KrishiSense

## AI + IoT Based Smart Farming Assistant

**SIH Problem Statement: SIH26180**

KrishiSense is a field-deployable smart farming prototype combining IoT-based soil monitoring, on-device AI-assisted crop-health analysis, a transparent decision engine, and a farmer-facing mobile application.

> **Current MVP:** 1 ESP32 + 1 soil-moisture sensor, Flutter Android app, a 10-class tomato TFLite model, irrigation decision logic, and Python/FastAPI backend integration. Additional sensors, crops and advanced automation are scalable extensions.

## Core Workflow

```text
SENSE → CAPTURE → ANALYZE → PREDICT → RECOMMEND → ACT → VERIFY
```

## Current Working Flows

### IoT / Irrigation

```text
Soil Moisture Sensor
        ↓
      ESP32
        ↓
   FastAPI Backend
        ↓
     Database
        ↓
 Decision Engine
        ↓
 Recommendation / Decision
        ↓
   Farmer App
```

The architecture also supports an irrigation command path:

```text
Decision → Backend → Hardware Integration → ESP32
        → Safe Relay/Controller → Pump
```

Actual pump actuation is treated as a hardware-integration step and must use a safe relay/controller; ESP32 GPIO must never drive a farm mains motor directly.

### AI Crop Analysis

```text
Farmer Camera
      ↓
Flutter App
      ↓
Preprocessing
      ↓
Tomato TFLite Model (on-device)
      ↓
Prediction + Confidence
      ↓
Recommendation / Explanation
      ↓
Flutter App
```

The current AI inference runs locally on the Android device. It does **not** require a backend AI inference call.

## System Architecture

```text
FIELD / IOT
ESP32 + Soil Sensor
        │
        │ sensor readings
        ▼
BACKEND / DATA LAYER
FastAPI + Database
        │
        ├──────────────► Sensor history / node status
        │
        └──────────────► Decision Engine
                              │
                              ▼
                       IRRIGATE / WAIT /
                       INSUFFICIENT_DATA
                              │
                              ▼
                         Farmer App

FARMER CAMERA
      │
      ▼
Flutter App
      │
      ▼
Local TFLite AI
      │
      ▼
Prediction + Confidence
      │
      └──────────────► Farmer App

Optional actuation:
Decision → Backend → Hardware Integration → ESP32
        → Safe Relay/Controller → Pump
```

## Repository Structure

```text
KrishiSense/
├── README.md
├── mobile_app/          # Tanush - farmer-facing application
├── backend/             # Ninad - core backend and database
├── ai/                  # Tanishq - AI/ML
├── decision_engine/     # Tanishq - irrigation/recommendation logic
├── hardware/            # AdiKul - ESP32 and physical integration
├── docs/                # Shared architecture, contracts and testing
└── demo/                # Screenshots, sample data and demo evidence
```

## Team Ownership

| Member | Responsibility |
|---|---|
| AdiKul | ESP32, soil-moisture hardware, hardware communication and hardware-integrated backend |
| Ninad | Core backend, database and general APIs |
| Tanush | Mobile app, UI/UX and backend API consumption |
| Tanishq | AI/ML, crop-health analysis and decision engine |

## Farm Hierarchy

```text
Farmer
  └── Farm
       └── Field
            └── Zone
                 ├── Node 01
                 ├── Node 02
                 └── ... Node N
```

A node is **not tied to one acre**. Nodes are strategically placed by zone. Multiple nodes can belong to a zone, and nodes can be added, removed or reassigned without changing the core application architecture.

## Current MVP

- ESP32 + soil-moisture sensor
- Sensor data transmission to the Python/FastAPI backend
- Node identity, zone mapping and online/offline tracking
- Transparent irrigation decision logic
- Flutter Android farmer application
- On-device tomato disease classification using TFLite
- 10 tomato classes
- Verified TFLite test accuracy: **91.93%** on the held-out test set
- Prediction confidence and advisory result presentation

## Scalable / Future Extensions

- Temperature/humidity, light, pH and EC sensors
- Field-node camera for plant growth/disease monitoring
- Multi-crop AI models
- Weather and climate-risk inputs
- Richer offline synchronization/store-and-forward
- LoRa or other low-power wide-area communication
- Expanded fertilizer, pest and crop-protection recommendations

These are intentionally separated from the current MVP so the repository remains technically honest while preserving the scalable architecture.

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [System Workflow](docs/SYSTEM_WORKFLOW.md)
- [API Contract](docs/API_CONTRACT.md)
- [Hardware](docs/HARDWARE.md)
- [AI Model](docs/AI_MODEL.md)
- [Decision Engine](docs/DECISION_ENGINE.md)
- [Offline Mode](docs/OFFLINE_MODE.md)
- [Testing](docs/TESTING.md)
- [Team Development Contract](docs/TEAM_CONTRACT.md)

## Prototype Principle

Build a small, testable and honest working prototype. Current implementation status and future architecture must always be distinguished. Shared interfaces should be documented before integration changes.
