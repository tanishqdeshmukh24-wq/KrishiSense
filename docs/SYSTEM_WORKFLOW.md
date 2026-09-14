# KrishiSense System Workflow

## Overall

```text
SENSE → CAPTURE → ANALYZE → PREDICT → RECOMMEND → ACT → VERIFY
```

## IoT workflow

```text
Soil Moisture Sensor
        ↓
      ESP32
        ↓
Hardware Integration
        ↓
     Backend
        ↓
    Database
        ↓
 Decision Engine
        ↓
 Recommendation
        ↓
   Mobile App
```

## AI workflow

```text
Farmer captures crop/leaf image
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

## Optional actuation workflow

```text
Decision Engine
      ↓
    Backend
      ↓
Hardware Integration
      ↓
     ESP32
      ↓
Safe Relay/Controller
      ↓
     Pump
      ↓
Verification/Status
      ↓
    Backend
```

## Prototype demonstration

The primary demonstrable pipeline is one physical ESP32 with one soil-moisture sensor. The software architecture is multi-node and zone-based.
