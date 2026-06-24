# PID Transport Images

This folder is reserved for small transport type images used by
`pid_transport_visuals.dart`.

Expected files:

- `metro.png`
- `tram.png`
- `bus.png`
- `trolleybus.png`
- `train.png`
- `ferry.png`
- `funicular.png`
- `replacement.png`
- `night.png`
- `special.png`

Image requirements:

- square image,
- recommended size: 64x64 px or 96x96 px,
- transparent background,
- PNG by default; WebP is acceptable only if the constants are updated in the
  same change,
- one image per transport mode or service type,
- filenames must match the constants in `PidTransportAssetPaths`.

The app currently uses Material Icon fallbacks by default, so these images can
be added later without changing the domain classification logic.
