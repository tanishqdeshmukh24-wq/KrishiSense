# KrishiSense Testing Plan

## MVP end-to-end tests

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
| AI image | Prediction + confidence returned |
| Mobile API failure | Clear error/stale state shown |

## Evidence
Store useful screenshots, sample payloads and demo evidence under `demo/`.

## Rule
Only mark a feature as implemented after it has been tested. Simulated/mock features must be clearly labelled.
