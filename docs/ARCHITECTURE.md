# KrishiSense Shared Architecture

## Purpose
This document is the source of truth for the four-person prototype team. Team members must follow this architecture unless a change is explicitly agreed and documented.

## Team Ownership
- **AdiKul:** ESP32, soil-moisture hardware, hardware communication, hardware-integrated backend.
- **Ninad:** Core backend, database, general APIs and data services.
- **Tanush:** Mobile application, UI/UX and API consumption.
- **Tanishq:** AI/ML and decision engine.

## System

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

## Non-negotiable boundaries
1. Mobile App does not communicate directly with ESP32.
2. AI does not directly control a pump.
3. Decision Engine does not directly communicate with ESP32.
4. There is one shared backend, not separate backends.
5. Ninad owns general backend functionality; AdiKul owns hardware-facing backend integration.
6. The physical MVP is one ESP32 + one soil-moisture sensor.
7. The software supports multiple dynamically registered nodes and zones.
8. Unimplemented sensors/features must not be presented as working features.

## Farm Hierarchy

```text
Farmer → Farm → Field → Zone → Sensor Node
```

A zone may contain multiple nodes. Nodes can be added, removed or reassigned.

## Main Data Flows

### Sensor flow
```text
Sensor → ESP32 → Hardware Integration → Backend → Database
```

### Decision flow
```text
Sensor Data → Backend → Decision Engine → Recommendation → Backend → Mobile App
```

### AI flow
```text
Mobile Image → Backend → AI → Prediction + Confidence → Backend → Mobile App
```

### Optional actuation flow
```text
Decision → Backend → Hardware Integration → ESP32 → Safe Controller → Pump
```

## Current Hardware
- ESP32
- Soil-moisture sensor

Temperature, humidity, pH, EC, light, LoRa and other sensors are future extensions.

## Design Principle
Each component must be independently testable. When another component is unavailable, use a mock that follows the shared API contract rather than inventing a different architecture.
