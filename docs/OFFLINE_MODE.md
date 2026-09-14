# KrishiSense Offline / Low-Connectivity Design

KrishiSense is intended for poor-connectivity environments. The prototype should distinguish between implemented and planned offline features.

## Current principle
- ESP32 detects network loss and retries communication.
- Backend accepts readings when connectivity is available.
- Mobile app should show stale/unavailable data clearly rather than inventing values.

## Planned synchronization

```text
Offline reading/data
      ↓
Local storage/buffer
      ↓
Connectivity restored
      ↓
Synchronization
      ↓
Backend
```

Complete offline synchronization and offline AI should only be marked implemented after they are actually tested.
