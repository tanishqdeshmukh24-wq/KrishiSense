# KrishiSense Decision Engine

## MVP Goal

Provide a transparent irrigation recommendation primarily from the latest soil-moisture reading.

The Decision Engine converts field data into a decision; it does not directly control farm hardware.

## Inputs

### Current MVP
- soil_moisture

### Supported / extensible context
- crop
- growth_stage
- recent readings
- rain/weather information when available

Additional context can be introduced without changing the core decision boundary.

## Outputs

```text
IRRIGATE
WAIT
INSUFFICIENT_DATA
```

Example:

```json
{
  "decision": "IRRIGATE",
  "priority": "HIGH",
  "reason": "Soil moisture is below the configured threshold."
}
```

## Decision Boundary

```text
Sensor Data
    ↓
Backend
    ↓
Decision Engine
    ↓
Recommendation
    ↓
Mobile App
```

For irrigation actuation:

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

The Decision Engine must never call the ESP32 or pump directly.

## Thresholds

Thresholds are **configurable prototype values**, not universal agronomic prescriptions. Production deployment should use crop-, soil-, irrigation-system- and region-specific agronomic calibration.

## Safety / Reliability

- Missing or invalid sensor data must not produce a confident irrigation command.
- Stale readings should be handled explicitly by the backend/application.
- Hardware execution requires a safe controller and appropriate electrical isolation.
- Recommendations should be explainable through the returned reason.

## Future Extensions

The engine can later incorporate crop stage, weather/rainfall, multiple sensor readings, risk conditions and richer crop-management rules. Such additions should remain transparent and testable.

## Ownership

Tanishq owns the decision-engine logic. Ninad owns the backend API/integration layer. Tanush consumes the decision result in Flutter.
