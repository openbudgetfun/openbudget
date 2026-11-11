---
openbudget_scripts: feat
---

# Make the Seeker dev runner safe to start and stop

`devenv shell dev:seeker` now discovers the attached Android device (or uses `SEEKER_DEVICE_ID` when several are ready), starts the local stack, and probes the API port from the phone before choosing Tailscale, LAN, or USB forwarding. The runner lives in `openbudget_scripts`, so its address selection, device selection, endpoint fallback, stale-state cleanup, PID ownership checks, and early launch failures are unit tested.

- An explicit `OPENBUDGET_API_URL` is preserved and must be reachable from the device.
- Stale PID files, stale FIFOs, and stale flags are cleared before a new launch, and a failed Flutter launch prints the tail of its log before cleaning up.
- `dev:seeker:stop` stops only the Flutter runner and FIFO holder it can verify, removes only the `adb reverse` rules it recorded, and leaves shared Postgres, Redis, and Serverpod processes alone.
- Hot reload and hot restart write through a timeout-guarded control pipe, so a FIFO with no reader reports an error instead of hanging.
