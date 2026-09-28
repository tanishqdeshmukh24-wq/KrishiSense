# KrishiSense System Architecture

## Purpose

This document is the architecture source of truth for KrishiSense. It separates the **current MVP implementation** from the **scalable/future architecture** so the system can continue evolving after SIH submission without making the repository misleading.

## High-Level Architecture

```text
┌──────────────────────┐
│ FIELD / IOT LAYER    │
│ ESP32 + Soil Sensor  │
└──────────┬───────────┘
           │ Sensor Data
           ▼
┌──────────────────────┐
│ BACKEND / DATA LAYER │
│ FastAPI + Database   │
│ Auth + Node Mgmt     │
└───────┬────────┬─────┘
        │        │
        │        └──────────────────────┐
        │                               │
        ▼                               ▼
┌───────────────────┐          ┌────────────────────┐
│ DECISION ENGINE   │          │ FARMER APP         │
│ Sensor/context    │          │ Flutter            │
│ Rule-based logic  │          │ Field + AI UI      │
└─────────┬─────────┘          └─────────┬──────────┘
          │                              │
          │ Decision                     │ Camera Image
          ▼                              ▼
┌───────────────────┐          ┌────────────────────┐
│ RECOMMENDATION    │          │ LOCAL TFLITE AI    │
│ IRRIGATE / WAIT / │          │ Tomato classifier  │
│ INSUFFICIENT_DATA │          │ On-device inference│
└─────────┬─────────┘          └─────────┬──────────┘
          │                              │
          └──────────────┬───────────────┘
                         ▼
                Farmer action / feedback
                         │
                         ▼
                    New field data
```

## Current MVP

The current physical and software prototype consists of:

- **Hardware:** 1 ESP32 + 1 soil-moisture sensor.
- **Mobile:** Flutter Android application.
- **AI:** MobileNetV2-based 10-class tomato classifier exported to TFLite.
- **Decision Engine:** transparent soil-moisture-based irrigation logic.
- **Backend:** Python/FastAPI APIs and database for sensor/data integration.
- **Connectivity:** ESP32 uses Wi-Fi for backend communication; AI inference runs locally on the phone.

## Non-Negotiable Boundaries

1. The mobile app does not communicate directly with the ESP32.
2. Current AI inference runs locally in Flutter/TFLite and does not require a backend AI inference request.
3. AI does not directly control a pump.
4. The Decision Engine does not directly communicate with the ESP32.
5. The backend is the integration layer for sensor data, decisions and hardware-facing commands.
6. There is one shared backend and one shared API contract.
7. The physical MVP is one ESP32 + one soil-moisture sensor.
8. Software must support multiple dynamically registered nodes and zones.
9. Future sensors/features must not be presented as currently implemented.

## Farm Hierarchy

```text
Farmer → Farm → Field → Zone → Sensor Node
```

A zone may contain multiple nodes. A node is not equivalent to an acre. Node placement is a deployment decision based on field/zone conditions.

## Main Data Flows

### Sensor Flow

```text
Soil Sensor → ESP32 → Wi-Fi → FastAPI → Database
```

### Irrigation Decision Flow

```text
Latest Sensor Data
        ↓
Backend
        ↓
Decision Engine
        ↓
IRRIGATE / WAIT / INSUFFICIENT_DATA
        ↓
Recommendation / Farmer App
```

### AI Flow — Current MVP

```text
Farmer Camera
      ↓
Flutter App
      ↓
Preprocessing
      ↓
TFLite Model
      ↓
Prediction + Confidence
      ↓
Farmer App / Recommendation
```

### Optional Actuation Flow

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

The ESP32 must not directly drive farm mains equipment from a GPIO pin.

## Scalable Architecture

The architecture can later add:

- additional environmental sensors
- field-node cameras
- multi-crop models
- weather/climate-risk data
- richer offline synchronization
- LoRa/other low-power communication
- expanded recommendation and automation modules

These extensions use the same Farm → Field → Zone → Node hierarchy and shared backend contract.

## Design Principle

Every component should be independently testable. When a dependency is unavailable, use a mock that follows the shared contract rather than creating a parallel architecture.
