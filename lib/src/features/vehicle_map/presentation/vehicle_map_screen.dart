import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pid_seeds/pid_seeds.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/domain/pid_line_classifier.dart';
import '../../../core/domain/pid_line_type.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/presentation/pid_transport_visuals.dart';
import '../../../shared/utils/app_error_messages.dart';
import '../../../shared/utils/date_time_formatters.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/loading_state_view.dart';
import '../domain/vehicle_position.dart';
import 'bloc/vehicle_map_bloc.dart';
import 'bloc/vehicle_map_event.dart';
import 'bloc/vehicle_map_state.dart';
import 'vehicle_map_args.dart';

class VehicleMapScreen extends StatelessWidget {
  const VehicleMapScreen({
    required this.args,
    super.key,
    this.showMapTiles = true,
    this.onBack,
  });

  final VehicleMapArgs args;
  final bool showMapTiles;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return PidVehicleMapTemplate.screen(
      title: args.title ?? context.t.vehicleMap.title,
      backTooltip: context.t.vehicleMap.backToDepartures,
      onBack: onBack ?? () => Navigator.of(context).maybePop(),
      content: BlocBuilder<VehicleMapBloc, VehicleMapState>(
        builder: _buildBody,
      ),
    );
  }

  Widget _buildBody(BuildContext context, VehicleMapState state) {
    if (state.status == VehicleMapStatus.loading && state.position == null) {
      return LoadingStateView(message: context.t.vehicleMap.loading);
    }

    final position = state.position;
    if (position == null) {
      final strings = context.t;
      if (state.status == VehicleMapStatus.error) {
        return ErrorStateView(
          message: userMessageForAppError(
            state.error,
            fallbackMessage: strings.vehicleMap.loadFailed,
          ),
          onRetry: () {
            context.read<VehicleMapBloc>().add(const VehicleMapRetried());
          },
        );
      }

      return EmptyStateView(
        message: userMessageForAppError(
          state.error,
          fallbackMessage: strings.vehicleMap.loadFailed,
          invalidDataMessage: strings.vehicleMap.invalidData,
        ),
        icon: Icons.location_off_outlined,
        onRetry: () {
          context.read<VehicleMapBloc>().add(const VehicleMapRetried());
        },
      );
    }

    return _MapState(
      args: args,
      position: position,
      staleError: state.staleError,
      isRefreshing: state.isRefreshing,
      showMapTiles: showMapTiles,
    );
  }
}

const _vehicleMapZoom = 15.0;
const _vehicleMapFitMaxZoom = 16.0;
const _vehicleMapFitPadding = EdgeInsets.fromLTRB(48, 48, 48, 220);
const _vehicleMapMarkerKey = Key('vehicle-map-marker');

class _MapState extends StatefulWidget {
  const _MapState({
    required this.args,
    required this.position,
    required this.staleError,
    required this.isRefreshing,
    required this.showMapTiles,
  });

  final VehicleMapArgs args;
  final VehiclePosition position;
  final AppFailure? staleError;
  final bool isRefreshing;
  final bool showMapTiles;

  @override
  State<_MapState> createState() => _MapStateState();
}

class _MapStateState extends State<_MapState> {
  final MapController _mapController = MapController();
  var _isMapReady = false;
  var _autoFollow = true;

  @override
  void didUpdateWidget(covariant _MapState oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_autoFollow && widget.position != oldWidget.position) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusVehicleAndRoute();
        }
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _handleMapReady() {
    _isMapReady = true;
    if (_autoFollow) {
      _focusVehicleAndRoute();
    }
  }

  void _handlePositionChanged(MapCamera camera, bool hasGesture) {
    if (!hasGesture || !_autoFollow) {
      return;
    }

    setState(() {
      _autoFollow = false;
    });
  }

  void _recenter() {
    setState(() {
      _autoFollow = true;
    });
    _focusVehicleAndRoute();
  }

  void _focusVehicleAndRoute() {
    if (!_isMapReady) {
      return;
    }

    final coordinates = _focusCoordinates(widget.position);
    if (coordinates.length < 2) {
      _mapController.move(_vehiclePoint(widget.position), _vehicleMapZoom);
      return;
    }

    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: coordinates,
        padding: _vehicleMapFitPadding,
        maxZoom: _vehicleMapFitMaxZoom,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final position = widget.position;
    final point = _vehiclePoint(position);
    final routeStyle = _VehicleRouteStyle.from(context, widget.args, position);
    final routeSegments = _vehicleRouteSegments(position);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: point,
            initialZoom: _vehicleMapZoom,
            initialCameraFit: _initialCameraFit(position),
            onMapReady: _handleMapReady,
            onPositionChanged: _handlePositionChanged,
          ),
          children: [
            if (widget.showMapTiles)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'pid_oict',
              )
            else
              const Positioned.fill(
                child: ColoredBox(color: Color(0xFFE7EEF4)),
              ),
            if (routeSegments.hasRoute)
              _RoutePolylineLayer(
                segments: routeSegments,
                style: routeStyle,
              ),
            if (position.stopTimes.isNotEmpty)
              _RouteStopLayer(position: position, style: routeStyle),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 64,
                  height: 64,
                  child: _VehicleMapMarker(
                    label: routeStyle.routeLabel,
                    style: routeStyle,
                  ),
                ),
              ],
            ),
            const Align(
              alignment: Alignment.bottomLeft,
              child: _MapAttribution(),
            ),
          ],
        ),
        if (widget.isRefreshing)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(),
          ),
        Positioned(
          right: 16,
          top: 16,
          child: PidMapControlButton(
            icon: Icons.my_location_rounded,
            tooltip: context.t.vehicleMap.recenterTooltip,
            onPressed: _recenter,
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: _VehiclePositionCard(
            args: widget.args,
            position: position,
            staleError: widget.staleError,
            style: routeStyle,
          ),
        ),
      ],
    );
  }
}

class _RoutePolylineLayer extends StatelessWidget {
  const _RoutePolylineLayer({required this.segments, required this.style});

  final _VehicleRouteSegments segments;
  final _VehicleRouteStyle style;

  @override
  Widget build(BuildContext context) {
    final polylines = <Polyline<Object>>[];

    if (segments.traveled.length >= 2) {
      polylines.add(
        Polyline(
          points: segments.traveled,
          color: style.traveledRouteColor,
          strokeWidth: 5,
          borderColor: Colors.white.withValues(alpha: 0.85),
          borderStrokeWidth: 2,
        ),
      );
    }

    if (segments.remaining.length >= 2) {
      polylines.add(
        Polyline(
          points: segments.remaining,
          color: style.remainingRouteColor,
          strokeWidth: 6,
          borderColor: Colors.white.withValues(alpha: 0.9),
          borderStrokeWidth: 2,
        ),
      );
    }

    if (segments.fullRoute.length >= 2) {
      polylines.add(
        Polyline(
          points: segments.fullRoute,
          color: style.remainingRouteColor,
          strokeWidth: 5,
          borderColor: Colors.white.withValues(alpha: 0.9),
          borderStrokeWidth: 2,
        ),
      );
    }

    return PolylineLayer(polylines: polylines);
  }
}

class _RouteStopLayer extends StatelessWidget {
  const _RouteStopLayer({required this.position, required this.style});

  final VehiclePosition position;
  final _VehicleRouteStyle style;

  @override
  Widget build(BuildContext context) {
    return CircleLayer(
      circles: [
        for (final stop in position.stopTimes)
          CircleMarker(
            point: LatLng(stop.latitude, stop.longitude),
            radius: stop.stopSequence == position.lastStopSequence ? 6 : 4,
            color: stop.stopSequence == position.lastStopSequence
                ? style.remainingRouteColor
                : Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
            borderColor: stop.stopSequence == position.lastStopSequence
                ? Colors.white
                : style.remainingRouteColor.withValues(alpha: 0.7),
            borderStrokeWidth: 2,
          ),
      ],
    );
  }
}

class _VehicleMapMarker extends StatelessWidget {
  const _VehicleMapMarker({required this.label, required this.style});

  final String? label;
  final _VehicleRouteStyle style;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    final semanticLabel = context.t.vehicleMap.vehicleMarkerSemantic(
      line: label ?? context.t.vehicleMap.title,
    );

    return Semantics(
      key: _vehicleMapMarkerKey,
      label: semanticLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.markerBackgroundColor,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: Center(
          child: label == null
              ? Icon(
                  style.fallbackIcon,
                  color: style.markerForegroundColor,
                  size: 28,
                )
              : Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: style.markerForegroundColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}

class _VehiclePositionCard extends StatelessWidget {
  const _VehiclePositionCard({
    required this.args,
    required this.position,
    required this.staleError,
    required this.style,
  });

  final VehicleMapArgs args;
  final VehiclePosition position;
  final AppFailure? staleError;
  final _VehicleRouteStyle style;

  @override
  Widget build(BuildContext context) {
    final lastUpdated = position.lastUpdated;
    final staleError = this.staleError;
    final title = _routeTitle(args, position);
    final routeLabel = style.routeLabel;
    final delay = formatDelaySeconds(position.delaySeconds);
    final vehicleLabel = context.t.vehicleMap.vehicleLabel(
      vehicleId: position.vehicleId,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (routeLabel != null) ...[
                  _RouteBadge(label: routeLabel, style: style),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title ?? vehicleLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          if (delay != null) _InfoPill(text: delay),
                          if (lastUpdated != null)
                            _InfoPill(
                              text: context.t.vehicleMap.lastUpdated(
                                time: formatClockTimeWithSeconds(lastUpdated),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (title != null) ...[
              const SizedBox(height: 8),
              Text(
                vehicleLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (staleError != null) ...[
              const SizedBox(height: 10),
              Text(
                staleDataWarning(staleError),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RouteBadge extends StatelessWidget {
  const _RouteBadge({required this.label, required this.style});

  final String label;
  final _VehicleRouteStyle style;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.markerBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: style.badgeBorderColor),
      ),
      child: SizedBox(
        width: 52,
        height: 44,
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: style.markerForegroundColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _VehicleRouteStyle {
  const _VehicleRouteStyle({
    required this.remainingRouteColor,
    required this.traveledRouteColor,
    required this.markerBackgroundColor,
    required this.markerForegroundColor,
    required this.badgeBorderColor,
    required this.fallbackIcon,
    required this.routeLabel,
  });

  factory _VehicleRouteStyle.from(
    BuildContext context,
    VehicleMapArgs args,
    VehiclePosition position,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final routeLabel = _routeLabel(args, position);
    final lineType = _lineType(args, position, routeLabel);
    final metroColors = routeLabel == null
        ? null
        : PidLineBadgeColorResolver.resolve(
            lineType: lineType,
            routeShortName: routeLabel,
          );
    final modeColor = _colorForMode(colorScheme, lineType.mode);
    final backgroundColor = metroColors?.backgroundColor ?? modeColor;

    return _VehicleRouteStyle(
      remainingRouteColor: backgroundColor,
      traveledRouteColor: colorScheme.outline.withValues(alpha: 0.7),
      markerBackgroundColor: backgroundColor,
      markerForegroundColor: metroColors?.foregroundColor ?? Colors.white,
      badgeBorderColor: metroColors?.borderColor ?? backgroundColor,
      fallbackIcon: lineType.visual.fallbackIcon,
      routeLabel: routeLabel,
    );
  }

  final Color remainingRouteColor;
  final Color traveledRouteColor;
  final Color markerBackgroundColor;
  final Color markerForegroundColor;
  final Color badgeBorderColor;
  final IconData fallbackIcon;
  final String? routeLabel;
}

class _VehicleRouteSegments {
  const _VehicleRouteSegments({
    this.fullRoute = const <LatLng>[],
    this.traveled = const <LatLng>[],
    this.remaining = const <LatLng>[],
  });

  final List<LatLng> fullRoute;
  final List<LatLng> traveled;
  final List<LatLng> remaining;

  bool get hasRoute {
    return fullRoute.length >= 2 ||
        traveled.length >= 2 ||
        remaining.length >= 2;
  }
}

_VehicleRouteSegments _vehicleRouteSegments(VehiclePosition position) {
  final routePoints = _sortedRoutePoints(position.routePoints);
  if (routePoints.length < 2) {
    return const _VehicleRouteSegments();
  }

  final hasDistances = routePoints.every(
    (point) => point.shapeDistTraveled != null,
  );
  final traveledDistance = position.shapeDistTraveled;

  if (!hasDistances || traveledDistance == null) {
    return _VehicleRouteSegments(
      fullRoute: routePoints.map(_routePointToLatLng).toList(growable: false),
    );
  }

  final splitIndex = routePoints.lastIndexWhere(
    (point) => point.shapeDistTraveled! <= traveledDistance,
  );

  final traveled = splitIndex >= 1
      ? routePoints
            .take(splitIndex + 1)
            .map(_routePointToLatLng)
            .toList(growable: false)
      : const <LatLng>[];
  final remainingStartIndex = splitIndex < 0 ? 0 : splitIndex;
  final remaining = routePoints.length - remainingStartIndex >= 2
      ? routePoints
            .skip(remainingStartIndex)
            .map(_routePointToLatLng)
            .toList(growable: false)
      : const <LatLng>[];

  return _VehicleRouteSegments(traveled: traveled, remaining: remaining);
}

List<VehicleRoutePoint> _sortedRoutePoints(List<VehicleRoutePoint> points) {
  if (points.length < 2 ||
      points.any((point) => point.shapeDistTraveled == null)) {
    return points;
  }

  return [...points]..sort(
    (first, second) =>
        first.shapeDistTraveled!.compareTo(second.shapeDistTraveled!),
  );
}

CameraFit? _initialCameraFit(VehiclePosition position) {
  final coordinates = _focusCoordinates(position);
  if (coordinates.length < 2) {
    return null;
  }

  return CameraFit.coordinates(
    coordinates: coordinates,
    padding: _vehicleMapFitPadding,
    maxZoom: _vehicleMapFitMaxZoom,
  );
}

List<LatLng> _focusCoordinates(VehiclePosition position) {
  return [
    _vehiclePoint(position),
    for (final point in position.routePoints) _routePointToLatLng(point),
    for (final stop in position.stopTimes)
      LatLng(stop.latitude, stop.longitude),
  ];
}

LatLng _vehiclePoint(VehiclePosition position) {
  return LatLng(position.latitude, position.longitude);
}

LatLng _routePointToLatLng(VehicleRoutePoint point) {
  return LatLng(point.latitude, point.longitude);
}

String? _routeTitle(VehicleMapArgs args, VehiclePosition position) {
  final route = _routeLabel(args, position);
  final headsign = _headsign(args, position);
  if (route == null || headsign == null) {
    return null;
  }

  return '$route – $headsign';
}

String? _routeLabel(VehicleMapArgs args, VehiclePosition position) {
  return _trimOrNull(args.routeShortName) ??
      _trimOrNull(position.routeShortName);
}

String? _headsign(VehicleMapArgs args, VehiclePosition position) {
  return _trimOrNull(args.headsign) ?? _trimOrNull(position.headsign);
}

PidLineType _lineType(
  VehicleMapArgs args,
  VehiclePosition position,
  String? routeLabel,
) {
  final explicitLineType = args.lineType;
  if (explicitLineType != null) {
    return explicitLineType;
  }

  final routeShortName = routeLabel;
  if (routeShortName == null) {
    return PidLineType.unknown;
  }

  final routeType = args.routeType ?? position.routeType;
  final page = pidLinePageFromGolemioRouteType(routeType);
  if (page == null) {
    return guessFromShortName(routeShortName);
  }

  return fromPidPage(page: page, shortName: routeShortName);
}

Color _colorForMode(ColorScheme colorScheme, PidTransportMode mode) {
  return switch (mode) {
    PidTransportMode.metro => colorScheme.primary,
    PidTransportMode.tram => const Color(0xFFC8102E),
    PidTransportMode.bus => const Color(0xFF2563EB),
    PidTransportMode.trolleybus => const Color(0xFF0F766E),
    PidTransportMode.train => const Color(0xFF7C3AED),
    PidTransportMode.ferry => const Color(0xFF0284C7),
    PidTransportMode.funicular => const Color(0xFFB45309),
    PidTransportMode.unknown => colorScheme.primary,
  };
}

String? _trimOrNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  return trimmed;
}

class _MapAttribution extends StatelessWidget {
  const _MapAttribution();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Text(
          context.t.vehicleMap.attribution,
          style: const TextStyle(fontSize: 11),
        ),
      ),
    );
  }
}
