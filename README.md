# KrishiSense

## AI + IoT Based Smart Farming Assistant

**SIH Problem Statement: SIH26180**

KrishiSense is a field-deployable smart farming prototype combining IoT-based soil monitoring, AI-assisted crop-health analysis, and a transparent decision engine to provide timely and actionable recommendations to farmers.

> **Prototype status:** The current physical prototype uses **1 ESP32 + 1 soil-moisture sensor**. Other sensors and advanced capabilities are future extensions and are not claimed as currently implemented.

## Core Workflow

```text
SENSE → CAPTURE → ANALYZE → PREDICT → RECOMMEND → ACT → VERIFY
```

## Working Prototype Flows

### IoT / Irrigation

```text
Soil Moisture Sensor
        ↓
      ESP32
        ↓
Hardware Integration
        ↓
     Backend
        ↓
  Database / Data
        ↓
 Decision Engine
        ↓
Irrigation Recommendation
        ↓
   Mobile App
```

### AI Crop Analysis

```text
Crop/Leaf Image
      ↓
 Mobile App
      ↓
   Backend
      ↓
  AI Model
      ↓
Prediction + Confidence
      ↓
Recommendation
      ↓
 Mobile App
```

## System Architecture

```text
                         FARMER
                           │
                           ▼
                  ┌─────────────────┐
                  │   MOBILE APP    │
                  │     Tanush      │
                  └────────┬────────┘
                           │ REST / HTTPS
                           ▼
                  ┌─────────────────┐
                  │     BACKEND     │
                  │     Ninad       │
                  │ API + Database  │
                  └───────┬─┬───────┘
                          │ │
              ┌───────────┘ └────────────┐
              ▼                          ▼
      ┌─────────────────┐        ┌─────────────────┐
      │ AI + DECISION   │        │    HARDWARE     │
      │     Tanishq     │        │     AdiKul      │
      └─────────────────┘        └────────┬────────┘
                                         ▼
                                  ┌─────────────┐
                                  │    ESP32    │
                                  └──────┬──────┘
                                         ▼
                                Soil Moisture Sensor
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
                 └── ...
```

A node is **not tied to one acre**. Nodes can be strategically placed by zone, and the software supports adding, removing or reassigning nodes without changing the core application architecture.

## Current MVP

- ESP32 + soil-moisture sensor prototype
- Sensor data transmission to backend
- Dynamic node/zone data model
- Node online/offline tracking
- Irrigation decision based primarily on soil moisture
- Farmer mobile dashboard
- AI-assisted crop-image analysis prototype
- Recommendation and alert interfaces

## Future Extensions

Temperature/humidity, light, pH, EC, weather services, LoRa communication, expanded crop-health/pest analysis, richer offline synchronization and larger deployments can be added later.

These are **future extensions**, not claims about the current physical prototype.

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

Build a small, testable and honest working prototype. Do not claim unimplemented functionality. Components must integrate through the shared contracts in `docs/`.
