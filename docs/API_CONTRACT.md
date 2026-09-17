# KrishiSense API Contract

This document defines the shared interfaces between the mobile app, backend, AI/decision components and hardware integration.

## Health
`GET /health`

Response:
```json
{"status":"ok"}
```

## Authentication
`POST /auth/register` with JSON body `name`, `email`, `password`.

`POST /auth/login` with `email` and `password`.

Response:
```json
{"access_token":"<JWT>","token_type":"bearer"}
```

Protected routes use `Authorization: Bearer <JWT>`.

`GET /auth/me` returns the authenticated user.

## Farms, fields and zones
`POST /farms`, `GET /farms`

`POST /farms/{farm_id}/fields`, `GET /farms/{farm_id}/fields`

`POST /farms/{farm_id}/fields/{field_id}/zones`, `GET /farms/{farm_id}/fields/{field_id}/zones`

Ownership is checked through `User → Farm → Field → Zone`.

## Crops
`POST /crops`

```json
{"zone_id":"<uuid>","name":"Tomato","growth_stage":"Vegetative"}
```

`PUT /crops/{crop_id}` and `GET /crops` are available. Crop names are data, not hardcoded constants.

## Nodes
`POST /nodes`

```json
{
  "node_id":"NODE_001",
  "device_id":"ESP32-001",
  "farm_id":"<uuid>",
  "field_id":"<uuid>",
  "zone_id":"<uuid>"
}
```

`GET /nodes` and `GET /nodes/{node_id}`.

Node status uses `last_seen` and the configurable `NODE_OFFLINE_TIMEOUT_SECONDS` timeout.

## Sensor readings
`POST /sensor/readings`

```json
{
  "node_id":"NODE_001",
  "zone_id":"<uuid>",
  "soil_moisture":24.5,
  "timestamp":"2026-09-14T10:30:00"
}
```

The backend validates node existence, node/zone relationship, soil-moisture range `0..100`, and timestamp format. A valid reading updates `last_seen` and marks the node online.

`GET /sensor/readings/{node_id}` returns stored readings newest first.

## AI results
`POST /ai/results`

```json
{
  "zone_id":"<uuid>",
  "prediction":"Early Blight",
  "confidence":0.87,
  "explanation":"AI-assisted visual analysis.",
  "recommendation":"Inspect the affected plant."
}
```

`GET /ai/results` retrieves stored results. The AI model itself is owned by Tanishq.

## Recommendations
`POST /recommendations`

```json
{
  "zone_id":"<uuid>",
  "type":"IRRIGATION",
  "priority":"HIGH",
  "message":"Soil moisture is below the configured threshold.",
  "source":"DECISION_ENGINE"
}
```

`GET /recommendations` retrieves stored recommendations.

## Alerts
`POST /alerts`

```json
{
  "zone_id":"<uuid>",
  "type":"LOW_SOIL_MOISTURE",
  "message":"Soil moisture alert.",
  "severity":"HIGH"
}
```

`GET /alerts` retrieves alerts visible to the authenticated farmer.

## Decision-engine boundary
`POST /decision-engine/evaluate` defines the integration boundary and accepts zone/sensor/crop context. The core backend does not implement agronomic decision logic. The external engine returns one of:

- `IRRIGATE`
- `WAIT`
- `INSUFFICIENT_DATA`

## Hardware boundary
The decision engine and mobile app do not call ESP32 directly. The intended path is:

```text
Decision Engine → Backend → Hardware Integration → ESP32
```

Hardware communication and safe execution remain owned by AdiKul.
