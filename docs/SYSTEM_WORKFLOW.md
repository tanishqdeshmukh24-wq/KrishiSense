# KrishiSense System Workflow

## Overall

```text
SENSE → CAPTURE → ANALYZE → PREDICT → RECOMMEND → ACT → VERIFY
```

## IoT / Irrigation Workflow

```text
Soil Moisture Sensor
        ↓
      ESP32
        ↓
      Wi-Fi
        ↓
FastAPI Backend
        ↓
    Database
        ↓
 Decision Engine
        ↓
IRRIGATE / WAIT /
INSUFFICIENT_DATA
        ↓
   Farmer App
```

## AI Workflow — Current MVP

```text
Farmer captures crop/leaf image
        ↓
     Flutter App
        ↓
   Resize / Preprocess
        ↓
  Local TFLite Model
        ↓
Prediction + Confidence
        ↓
Advisory Result
        ↓
     Flutter App
```

The current AI model runs on-device. A backend AI inference service is not required for this path.

## Optional Actuation Workflow

```text
Decision Engine
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
      ↓
Verification / Status
```

## Feedback Loop

```text
New Sensor Reading / New Image
            ↓
       Updated Result
            ↓
       Farmer Action
            ↓
       New Observation
```

This creates the architecture for verification and future improvement without claiming that an automated machine-learning retraining loop is already implemented.

## Prototype Demonstration

The primary physical demonstrable pipeline is one ESP32 with one soil-moisture sensor. The software architecture remains multi-node, zone-based and expandable to additional crops, sensors and field inputs.
