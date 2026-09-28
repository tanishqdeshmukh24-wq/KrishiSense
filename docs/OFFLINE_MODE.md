# KrishiSense Offline / Low-Connectivity Design

KrishiSense is designed for agricultural environments where connectivity may be intermittent. The repository distinguishes **implemented offline capability** from planned synchronization features.

## Implemented Today

### On-device AI

The tomato TFLite model runs locally inside the Flutter application.

```text
Camera → Flutter → TFLite
```

Therefore, the current AI inference path does not require an internet connection or backend AI service.

### IoT Connectivity

The ESP32 currently communicates with the FastAPI backend over Wi-Fi. If connectivity is unavailable, backend delivery cannot occur until communication is restored.

The application should show unavailable/stale sensor information rather than inventing readings.

## Planned / Expandable Synchronization

A richer low-connectivity implementation can add local buffering and store-and-forward:

```text
Offline sensor/data
       ↓
Local buffer
       ↓
Connectivity restored
       ↓
Synchronization
       ↓
Backend
```

This should only be marked as fully implemented after it is tested end-to-end.

## Design Principle

Offline AI and offline data synchronization are separate capabilities. KrishiSense currently has **local AI inference**; broader offline synchronization remains an area for continued development.
