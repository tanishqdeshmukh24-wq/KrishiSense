# KrishiSense Decision Engine

## MVP Goal
Provide a transparent irrigation recommendation primarily from soil-moisture data.

## Inputs
Required for MVP:
- soil_moisture

Optional/future inputs:
- crop
- growth_stage
- recent readings
- rain/weather information

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

## Important
Thresholds are configurable prototype values and are not universal agricultural prescriptions. Production deployment should use crop/soil-specific agronomic calibration.

The decision engine returns a recommendation. It does not directly control ESP32 or a pump.
