# PID Transport Images

This folder contains the final 24x24 SVG pictograms used by
`pid_transport_visuals.dart`.

Asset mapping:

- `travel-metro.svg`: metro
- `travel-tram.svg`: tram and special tram lines
- `travel-bus.svg`: city, regional, and school bus lines
- `travel-trolley.svg`: trolleybus
- `travel-train.svg`: S/R/interregional/tourist trains
- `travel-cableway.svg`: funicular / cableway
- `travel-ferry.svg`: ferry
- `travel-night.svg`: night tram and night bus services

Replacement services currently reuse the icon of the affected transport mode:

- metro replacement uses `travel-metro.svg`
- tram replacement uses `travel-tram.svg`
- bus replacement uses `travel-bus.svg`
- train replacement uses `travel-train.svg`

Unknown and special-only line types intentionally use the Material Icon
fallback from `PidTransportIcon`.
