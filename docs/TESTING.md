# KrishiSense Testing Plan

## MVP End-to-End Tests

| Test | Expected result |
|---|---|
| ESP32 boots | Startup succeeds |
| Soil sensor changes with soil condition | Reading changes |
| ESP32 sends reading | Backend receives payload |
| Backend stores reading | Reading is retrievable |
| Node heartbeat | `last_seen` updates |
| Stale heartbeat | Node becomes offline |
| Low moisture | Decision = `IRRIGATE` |
| Normal moisture | Decision = `WAIT` |
| Missing/invalid moisture | Decision = `INSUFFICIENT_DATA` or validation error |
| TFLite image inference | Prediction + confidence returned locally |
| Keras/TFLite parity | Predictions match on the validation test procedure |
| Mobile API failure | Clear error/stale state shown |

## Verified AI Evidence

The current tomato TFLite model has been verified against the held-out test set:

- Test images: **1,821**
- TFLite test accuracy: **91.93%**
- Keras vs TFLite prediction match: **100%**

The model should still be treated as advisory because held-out dataset accuracy does not guarantee equal real-world field performance.

## Hardware Evidence

Current hardware/backend testing has demonstrated:

```text
Soil Sensor → ESP32 → Wi-Fi → FastAPI → Database
```

Prototype node: `FS001`.

## Evidence

Store useful screenshots, sample payloads and demo evidence under `demo/`.

## Rule

Only mark a feature as implemented after it has been tested. Simulated/mock features must be clearly labelled. Future architecture may be documented, but it must not be presented as current implementation.
