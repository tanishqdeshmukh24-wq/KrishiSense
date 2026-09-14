# KrishiSense API Contract

This document defines the shared interfaces between the mobile app, backend, AI/decision components and hardware integration. Do not create conflicting endpoints without agreement.

## Base
The backend owns the public API. Exact host/port is environment-specific.

## Health
`GET /health`

Response:
```json
{"status":"ok"}
```

## Sensor Reading
`POST /sensor/readings`

Request:
```json
{
  "node_id": "NODE_001",
  "zone_id": "ZONE_001",
  "soil_moisture": 24.5,
  "timestamp": "2026-09-14T10:30:00"
}
```

The backend validates the node/zone relationship and stores the reading.

## Sensor History
`GET /sensor/readings/{node_id}`

Returns stored readings ordered by timestamp.

## Nodes
`POST /nodes`

Minimum conceptual fields:
- node_id
- device_id
- farm_id
- field_id
- zone_id

`GET /nodes`

`GET /nodes/{node_id}`

A node also exposes status/last_seen information.

## Node Heartbeat
The ESP32 periodically reports that it is alive. The backend updates `last_seen` and derives online/offline status using a configurable timeout.

## AI Analysis
The mobile app sends an image through the backend. The AI component returns a result conceptually shaped as:

```json
{
  "prediction": "Example Class",
  "confidence": 0.87,
  "explanation": "AI-assisted visual analysis.",
  "recommendation": "Inspect the affected plant and follow appropriate crop-management guidance."
}
```

AI results are advisory, not guaranteed diagnosis.

## Decision Engine
Backend sends available zone/crop/sensor context to the decision engine.

Expected result:

```json
{
  "decision": "IRRIGATE",
  "priority": "HIGH",
  "reason": "Soil moisture is below the configured threshold."
}
```

Valid decisions:
- `IRRIGATE`
- `WAIT`
- `INSUFFICIENT_DATA`

## Recommendations
Recommendations are stored by the backend and served to the mobile app. Example:

```json
{
  "zone_id": "ZONE_001",
  "type": "IRRIGATION",
  "priority": "HIGH",
  "message": "Soil moisture is below the configured threshold.",
  "source": "DECISION_ENGINE"
}
```

## Hardware Command Boundary
The decision engine never calls ESP32 directly.

```text
Decision Engine → Backend → Hardware Integration → ESP32
```

An irrigation command may conceptually contain:

```json
{
  "command": "IRRIGATE",
  "zone_id": "ZONE_001"
}
```

Hardware integration owns validation, acknowledgement, timeout and safe execution.

## Error Principles
APIs should return clear validation/authentication/server errors. Clients must handle missing data, network failure and stale readings.

## Contract Rule
If an endpoint or payload needs to change, update this document and coordinate the affected component owners before implementing the change.
