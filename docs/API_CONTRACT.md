# KrishiSense API Contract

This document defines the shared interfaces between the mobile app, backend, decision engine and hardware integration. Do not create conflicting endpoints without agreement.

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
  "node_id": "FS001",
  "zone_id": "ZONE_001",
  "soil_moisture": 24.5,
  "timestamp": "2026-09-14T10:30:00"
}
```

The backend validates the node/zone relationship and stores the reading.

## Latest Sensor Reading

`GET /sensor/readings/{node_id}/latest`

The latest stored reading is returned for mobile/decision use.

Example:

```json
{
  "node_id": "FS001",
  "zone_id": "ZONE_001",
  "soil_moisture": 38.0,
  "timestamp": "2026-09-27T02:43:52"
}
```

Authentication requirements are environment-specific; protected mobile endpoints use the backend's JWT authentication flow.

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

## AI Analysis — Current MVP

AI inference currently runs **inside the Flutter application using TFLite**.

```text
Camera → Flutter → TFLite → Prediction + Confidence
```

The backend is not required to perform the current AI inference. If AI results are persisted or exchanged through backend APIs, those APIs carry the result; they do not replace the on-device inference path.

Conceptual result:

```json
{
  "prediction": "Example Class",
  "confidence": 0.87,
  "explanation": "AI-assisted visual analysis.",
  "recommendation": "Inspect the affected plant and follow appropriate crop-management guidance."
}
```

## Decision Engine

The backend exposes the decision-engine integration.

`POST /decision-engine/evaluate`

Conceptual request:

```json
{
  "zone_id": "ZONE_001",
  "crop": "tomato",
  "growth_stage": "flowering"
}
```

The engine can use the latest stored sensor reading when soil moisture is not explicitly supplied.

Expected result:

```json
{
  "decision": "IRRIGATE",
  "priority": "HIGH",
  "reason": "Soil moisture is below the configured irrigation threshold."
}
```

Valid decisions:

- `IRRIGATE`
- `WAIT`
- `INSUFFICIENT_DATA`

## Recommendations

Recommendations are served to the mobile application through the backend. Example:

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

The decision engine never calls the ESP32 directly.

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

If an endpoint or payload changes, update this document and coordinate the affected component owners before implementation.
