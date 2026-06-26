import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pid_seeds/pid_seeds.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/domain/pid_line_classifier.dart';
import '../../../core/domain/pid_line_type.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/presentation/pid_line_type_label_mapper.dart';
import '../../../core/presentation/pid_transport_visuals.dart';
import '../../../shared/utils/app_error_messages.dart';
import '../../../shared/utils/date_time_formatters.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/live_relative_time_text.dart';
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
const _vehicleMapFitMinZoom = 13.0;
const _vehicleMapFitMaxZoom = 16.5;
const _vehicleMapFitPadding = EdgeInsets.fromLTRB(56, 72, 56, 210);
const _vehicleMapBackgroundColor = Color(0xFFE7EEF4);
const _vehicleMapStaticBackgroundKey = Key('vehicle-map-static-background');
const _vehicleMapLookBehindDistance = 900.0;
const _vehicleMapLookAheadDistance = 2600.0;
const _vehicleMapStopLookAheadDistance = 5000.0;
const _vehicleMapRoutePointsBefore = 6;
const _vehicleMapRoutePointsAfter = 12;
const _vehicleMapNearbyStopLimit = 4;
const _vehicleMapMarkerWidth = 50.0;
const _vehicleMapMarkerHeight = 56.0;
const _vehicleMapMarkerBodySize = 46.0;
const _vehicleMapMarkerKey = Key('vehicle-map-marker');
const Key _vehicleMapPanelKey = ValueKey('vehicle-map-info-panel');
const Key _mapAttributionKey = ValueKey('vehicle-map-attribution');

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusVehicleAndRoute();
        }
      });
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
        minZoom: _vehicleMapFitMinZoom,
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
            backgroundColor: _vehicleMapBackgroundColor,
            onMapReady: _handleMapReady,
            onPositionChanged: _handlePositionChanged,
          ),
          children: [
            if (widget.showMapTiles)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'pid_oict',
                tileDisplay: const TileDisplay.fadeIn(
                  duration: Duration(milliseconds: 120),
                ),
              )
            else
              const Positioned.fill(
                child: ColoredBox(
                  key: _vehicleMapStaticBackgroundKey,
                  color: _vehicleMapBackgroundColor,
                ),
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
                  width: _vehicleMapMarkerWidth,
                  height: _vehicleMapMarkerHeight,
                  alignment: Alignment.topCenter,
                  child: _VehicleMapMarker(
                    label: routeStyle.routeLabel,
                    style: routeStyle,
                  ),
                ),
              ],
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
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _MapAttribution(),
                const SizedBox(height: 8),
                _VehiclePositionCard(
                  args: widget.args,
                  position: position,
                  staleError: widget.staleError,
                  style: routeStyle,
                ),
              ],
            ),
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
          strokeWidth: 3.5,
          borderColor: Colors.white.withValues(alpha: 0.82),
          borderStrokeWidth: 1.2,
        ),
      );
    }

    if (segments.remaining.length >= 2) {
      polylines.add(
        Polyline(
          points: segments.remaining,
          color: style.remainingRouteColor,
          strokeWidth: 6.8,
          borderColor: Colors.white.withValues(alpha: 0.9),
          borderStrokeWidth: 2.8,
        ),
      );
    }

    if (segments.fullRoute.length >= 2) {
      polylines.add(
        Polyline(
          points: segments.fullRoute,
          color: style.remainingRouteColor,
          strokeWidth: 5.5,
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
    final markerStyles = _RouteStopMarkerStyles.from(context, position, style);

    return CircleLayer(
      circles: [
        for (final stop in position.stopTimes)
          _circleMarkerForStop(
            stop: stop,
            style: markerStyles.styleFor(stop),
          ),
      ],
    );
  }
}

CircleMarker<Object> _circleMarkerForStop({
  required VehicleRouteStop stop,
  required _RouteStopMarkerStyle style,
}) {
  final sequence = stop.stopSequence?.toString() ?? 'unknown';

  return CircleMarker<Object>(
    key: ValueKey('vehicle-route-stop-${style.kind.name}-$sequence'),
    point: LatLng(stop.latitude, stop.longitude),
    radius: style.radius,
    color: style.fillColor,
    borderColor: style.borderColor,
    borderStrokeWidth: style.borderStrokeWidth,
  );
}

enum _RouteStopMarkerKind { traveled, current, next, destination, upcoming }

class _RouteStopMarkerStyles {
  const _RouteStopMarkerStyles({
    required this.position,
    required this.routeStyle,
    required this.colorScheme,
    required this.nextStopSequence,
    required this.destinationStopSequence,
    required this.nextShapeDistance,
    required this.destinationShapeDistance,
  });

  factory _RouteStopMarkerStyles.from(
    BuildContext context,
    VehiclePosition position,
    _VehicleRouteStyle routeStyle,
  ) {
    return _RouteStopMarkerStyles(
      position: position,
      routeStyle: routeStyle,
      colorScheme: Theme.of(context).colorScheme,
      nextStopSequence: _nextStopSequence(position),
      destinationStopSequence: _destinationStopSequence(position.stopTimes),
      nextShapeDistance: _nextStopShapeDistance(position),
      destinationShapeDistance: _destinationShapeDistance(position.stopTimes),
    );
  }

  final VehiclePosition position;
  final _VehicleRouteStyle routeStyle;
  final ColorScheme colorScheme;
  final int? nextStopSequence;
  final int? destinationStopSequence;
  final double? nextShapeDistance;
  final double? destinationShapeDistance;

  _RouteStopMarkerStyle styleFor(VehicleRouteStop stop) {
    final kind = _kindFor(stop);
    final activeColor = routeStyle.remainingRouteColor;

    return switch (kind) {
      _RouteStopMarkerKind.current => _RouteStopMarkerStyle(
        kind: kind,
        radius: 7,
        fillColor: activeColor,
        borderColor: Colors.white,
        borderStrokeWidth: 3,
      ),
      _RouteStopMarkerKind.next => _RouteStopMarkerStyle(
        kind: kind,
        radius: 5.8,
        fillColor: activeColor.withValues(alpha: 0.9),
        borderColor: Colors.white,
        borderStrokeWidth: 2,
      ),
      _RouteStopMarkerKind.destination => _RouteStopMarkerStyle(
        kind: kind,
        radius: 6.2,
        fillColor: colorScheme.surface.withValues(alpha: 0.95),
        borderColor: activeColor,
        borderStrokeWidth: 3,
      ),
      _RouteStopMarkerKind.traveled => _RouteStopMarkerStyle(
        kind: kind,
        radius: 2.8,
        fillColor: colorScheme.outline.withValues(alpha: 0.62),
        borderColor: Colors.white.withValues(alpha: 0.8),
        borderStrokeWidth: 1.4,
      ),
      _RouteStopMarkerKind.upcoming => _RouteStopMarkerStyle(
        kind: kind,
        radius: 3.6,
        fillColor: colorScheme.surface.withValues(alpha: 0.9),
        borderColor: activeColor.withValues(alpha: 0.72),
        borderStrokeWidth: 1.6,
      ),
    };
  }

  _RouteStopMarkerKind _kindFor(VehicleRouteStop stop) {
    final stopSequence = stop.stopSequence;
    final shapeDistance = stop.shapeDistTraveled;
    final lastStopSequence = position.lastStopSequence;
    final traveledDistance = position.shapeDistTraveled;

    if (lastStopSequence != null && stopSequence == lastStopSequence) {
      return _RouteStopMarkerKind.current;
    }

    if (_matchesStop(
      stopSequence,
      shapeDistance,
      nextStopSequence,
      nextShapeDistance,
    )) {
      return _RouteStopMarkerKind.next;
    }

    if (_matchesStop(
      stopSequence,
      shapeDistance,
      destinationStopSequence,
      destinationShapeDistance,
    )) {
      return _RouteStopMarkerKind.destination;
    }

    if ((lastStopSequence != null &&
            stopSequence != null &&
            stopSequence < lastStopSequence) ||
        (traveledDistance != null &&
            shapeDistance != null &&
            shapeDistance < traveledDistance)) {
      return _RouteStopMarkerKind.traveled;
    }

    return _RouteStopMarkerKind.upcoming;
  }
}

class _RouteStopMarkerStyle {
  const _RouteStopMarkerStyle({
    required this.kind,
    required this.radius,
    required this.fillColor,
    required this.borderColor,
    required this.borderStrokeWidth,
  });

  final _RouteStopMarkerKind kind;
  final double radius;
  final Color fillColor;
  final Color borderColor;
  final double borderStrokeWidth;
}

bool _matchesStop(
  int? stopSequence,
  double? shapeDistance,
  int? targetSequence,
  double? targetShapeDistance,
) {
  if (targetSequence != null && stopSequence == targetSequence) {
    return true;
  }

  return targetSequence == null &&
      targetShapeDistance != null &&
      shapeDistance == targetShapeDistance;
}

int? _nextStopSequence(VehiclePosition position) {
  final lastStopSequence = position.lastStopSequence;
  final candidates =
      position.stopTimes
          .map((stop) => stop.stopSequence)
          .whereType<int>()
          .where(
            (sequence) =>
                lastStopSequence == null || sequence > lastStopSequence,
          )
          .toList(growable: false)
        ..sort();

  return candidates.isEmpty ? null : candidates.first;
}

double? _nextStopShapeDistance(VehiclePosition position) {
  final traveledDistance = position.shapeDistTraveled;
  if (traveledDistance == null) {
    return null;
  }

  final candidates =
      position.stopTimes
          .map((stop) => stop.shapeDistTraveled)
          .whereType<double>()
          .where((distance) => distance > traveledDistance)
          .toList(growable: false)
        ..sort();

  return candidates.isEmpty ? null : candidates.first;
}

int? _destinationStopSequence(List<VehicleRouteStop> stops) {
  final sequences =
      stops
          .map((stop) => stop.stopSequence)
          .whereType<int>()
          .toList(growable: false)
        ..sort();

  return sequences.isEmpty ? null : sequences.last;
}

double? _destinationShapeDistance(List<VehicleRouteStop> stops) {
  final distances =
      stops
          .map((stop) => stop.shapeDistTraveled)
          .whereType<double>()
          .toList(growable: false)
        ..sort();

  return distances.isEmpty ? null : distances.last;
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
      child: SizedBox(
        width: _vehicleMapMarkerWidth,
        height: _vehicleMapMarkerHeight,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              bottom: 0,
              child: _VehicleMarkerPointer(style: style),
            ),
            Positioned(
              top: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: style.markerBackgroundColor,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x44000000),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: SizedBox.square(
                  dimension: _vehicleMapMarkerBodySize,
                  child: Center(
                    child: label == null
                        ? Icon(
                            style.fallbackIcon,
                            color: style.markerForegroundColor,
                            size: 22,
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                label,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: style.markerForegroundColor,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0,
                                    ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleMarkerPointer extends StatelessWidget {
  const _VehicleMarkerPointer({required this.style});

  final _VehicleRouteStyle style;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(18, 14),
      painter: _VehicleMarkerPointerPainter(
        fillColor: style.markerBackgroundColor,
      ),
    );
  }
}

class _VehicleMarkerPointerPainter extends CustomPainter {
  const _VehicleMarkerPointerPainter({required this.fillColor});

  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = ui.Path()
      ..moveTo(1, 1)
      ..lineTo(size.width - 1, 1)
      ..lineTo(size.width / 2, size.height - 1)
      ..close();

    canvas
      ..drawPath(
        path,
        ui.Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeJoin = ui.StrokeJoin.round,
      )
      ..drawPath(
        path,
        ui.Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill,
      );
  }

  @override
  bool shouldRepaint(covariant _VehicleMarkerPointerPainter oldDelegate) {
    return fillColor != oldDelegate.fillColor;
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
    final title =
        _routeTitle(args, position) ??
        _headsign(args, position) ??
        _routeLabel(args, position) ??
        context.t.vehicleMap.title;
    final routeLabel = style.routeLabel;
    final primaryTitle = routeLabel == null
        ? title
        : _headsign(args, position) ?? title;
    final delay = formatRealtimeDelayLabel(position.delaySeconds);
    final nextStopText = _nextStopText(context, position);
    final metadata = _metadataLabels(context, args, position, routeLabel);
    final subtleInfoStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );

    return DecoratedBox(
      key: _vehicleMapPanelKey,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (routeLabel != null) ...[
                  _RouteBadge(label: routeLabel, style: style),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        primaryTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 3,
                        children: [
                          _InfoPill(text: delay),
                          if (lastUpdated != null)
                            LiveRelativeTimeText.vehicleLastUpdated(
                              timestamp: lastUpdated,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: subtleInfoStyle,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (nextStopText != null) ...[
              const SizedBox(height: 6),
              _InlineInfo(
                icon: Icons.flag_outlined,
                text: nextStopText,
              ),
            ],
            if (metadata.isNotEmpty) ...[
              const SizedBox(height: 6),
              _MetadataSummary(labels: metadata),
            ],
            if (staleError != null) ...[
              const SizedBox(height: 8),
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
        width: 46,
        height: 38,
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _InlineInfo extends StatelessWidget {
  const _InlineInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetadataSummary extends StatelessWidget {
  const _MetadataSummary({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Text(
      labels.join(' · '),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

String? _nextStopText(BuildContext context, VehiclePosition position) {
  final stop = _nextStop(position);
  if (stop == null) {
    return null;
  }

  final time =
      stop.realtimeArrivalTime ??
      stop.arrivalTime ??
      stop.realtimeDepartureTime ??
      stop.departureTime;
  if (time != null) {
    return context.t.vehicleMap.nextStopAt(
      stop: stop.name,
      time: formatClockTime(time),
    );
  }

  return context.t.vehicleMap.nextStop(stop: stop.name);
}

VehicleRouteStop? _nextStop(VehiclePosition position) {
  final lastStopSequence = position.lastStopSequence;
  if (lastStopSequence != null) {
    final candidates =
        position.stopTimes
            .where(
              (stop) =>
                  stop.stopSequence != null &&
                  stop.stopSequence! > lastStopSequence,
            )
            .toList(growable: false)
          ..sort((first, second) {
            return first.stopSequence!.compareTo(second.stopSequence!);
          });

    if (candidates.isNotEmpty) {
      return candidates.first;
    }
  }

  final traveledDistance = position.shapeDistTraveled;
  if (traveledDistance == null) {
    return null;
  }

  final candidates =
      position.stopTimes
          .where(
            (stop) =>
                stop.shapeDistTraveled != null &&
                stop.shapeDistTraveled! > traveledDistance,
          )
          .toList(growable: false)
        ..sort((first, second) {
          return first.shapeDistTraveled!.compareTo(second.shapeDistTraveled!);
        });

  return candidates.isEmpty ? null : candidates.first;
}

List<String> _metadataLabels(
  BuildContext context,
  VehicleMapArgs args,
  VehiclePosition position,
  String? routeLabel,
) {
  final descriptor = position.vehicleDescriptor;
  final lineType = _lineType(args, position, routeLabel);
  final labels = <String>[
    PidLineTypeLabelMapper(context.t).labelFor(lineType),
  ];
  final operator = _trimOrNull(descriptor?.operator);
  if (operator != null) {
    labels.add(context.t.vehicleMap.operatorName(name: operator));
  }
  if (descriptor?.isWheelchairAccessible == true) {
    labels.add(context.t.vehicleMap.wheelchairAccessible);
  }
  if (descriptor?.isAirConditioned == true) {
    labels.add(context.t.vehicleMap.airConditioned);
  }
  if (descriptor?.hasUsbChargers == true) {
    labels.add(context.t.vehicleMap.usbChargers);
  }

  return labels;
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
      traveledRouteColor: const Color(0xFF64748B).withValues(alpha: 0.72),
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

  final previousRoutePointIndex = routePoints.lastIndexWhere(
    (point) => point.shapeDistTraveled! <= traveledDistance,
  );
  final nextRoutePointIndex = routePoints.indexWhere(
    (point) => point.shapeDistTraveled! > traveledDistance,
  );
  final vehiclePoint = _vehiclePoint(position);

  final traveled = previousRoutePointIndex >= 0
      ? _uniqueCoordinates([
          ...routePoints
              .take(previousRoutePointIndex + 1)
              .map(_routePointToLatLng),
          vehiclePoint,
        ])
      : const <LatLng>[];
  final remaining = nextRoutePointIndex >= 0
      ? _uniqueCoordinates([
          vehiclePoint,
          ...routePoints.skip(nextRoutePointIndex).map(_routePointToLatLng),
        ])
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

List<LatLng> _focusCoordinates(VehiclePosition position) {
  return _uniqueCoordinates([
    _vehiclePoint(position),
    ..._nearbyRouteCoordinates(position),
    ..._nearbyStopCoordinates(position),
  ]);
}

/// Exposes the map camera focus target set for deterministic widget tests.
@visibleForTesting
List<LatLng> vehicleMapFocusCoordinatesForTesting(VehiclePosition position) {
  return _focusCoordinates(position);
}

List<LatLng> _nearbyRouteCoordinates(VehiclePosition position) {
  final routePoints = _sortedRoutePoints(position.routePoints);
  if (routePoints.isEmpty) {
    return const <LatLng>[];
  }

  final traveledDistance = position.shapeDistTraveled;
  final routeHasDistances = routePoints.every(
    (point) => point.shapeDistTraveled != null,
  );

  if (traveledDistance != null && routeHasDistances) {
    final startDistance = traveledDistance - _vehicleMapLookBehindDistance;
    final endDistance = traveledDistance + _vehicleMapLookAheadDistance;
    final nearbyPoints = routePoints
        .where(
          (point) =>
              point.shapeDistTraveled! >= startDistance &&
              point.shapeDistTraveled! <= endDistance,
        )
        .toList(growable: false);

    if (nearbyPoints.isNotEmpty) {
      return nearbyPoints.map(_routePointToLatLng).toList(growable: false);
    }
  }

  final vehiclePoint = _vehiclePoint(position);
  final closestIndex = _closestRoutePointIndex(routePoints, vehiclePoint);
  final startIndex = (closestIndex - _vehicleMapRoutePointsBefore).clamp(
    0,
    routePoints.length,
  );
  final endIndex = (closestIndex + _vehicleMapRoutePointsAfter + 1).clamp(
    0,
    routePoints.length,
  );

  return routePoints
      .sublist(startIndex, endIndex)
      .map(_routePointToLatLng)
      .toList(growable: false);
}

List<LatLng> _nearbyStopCoordinates(VehiclePosition position) {
  if (position.stopTimes.isEmpty) {
    return const <LatLng>[];
  }

  final lastStopSequence = position.lastStopSequence;
  final traveledDistance = position.shapeDistTraveled;
  if (lastStopSequence != null) {
    final upcomingStops =
        position.stopTimes
            .where(
              (stop) =>
                  stop.stopSequence != null &&
                  stop.stopSequence! > lastStopSequence &&
                  _isFocusableUpcomingStop(stop, traveledDistance),
            )
            .toList(growable: false)
          ..sort((first, second) {
            return first.stopSequence!.compareTo(second.stopSequence!);
          });

    if (upcomingStops.isNotEmpty) {
      return upcomingStops
          .take(_vehicleMapNearbyStopLimit)
          .map((stop) => LatLng(stop.latitude, stop.longitude))
          .toList(growable: false);
    }
  }

  if (traveledDistance == null) {
    return const <LatLng>[];
  }

  final nearbyStops =
      position.stopTimes
          .where(
            (stop) =>
                stop.shapeDistTraveled != null &&
                stop.shapeDistTraveled! >= traveledDistance &&
                stop.shapeDistTraveled! <=
                    traveledDistance + _vehicleMapLookAheadDistance,
          )
          .toList(growable: false)
        ..sort(
          (first, second) =>
              first.shapeDistTraveled!.compareTo(second.shapeDistTraveled!),
        );

  return nearbyStops
      .take(_vehicleMapNearbyStopLimit)
      .map((stop) => LatLng(stop.latitude, stop.longitude))
      .toList(growable: false);
}

bool _isFocusableUpcomingStop(
  VehicleRouteStop stop,
  double? traveledDistance,
) {
  final stopDistance = stop.shapeDistTraveled;
  if (traveledDistance == null || stopDistance == null) {
    return true;
  }

  return stopDistance <= traveledDistance + _vehicleMapStopLookAheadDistance;
}

int _closestRoutePointIndex(List<VehicleRoutePoint> points, LatLng vehicle) {
  var closestIndex = 0;
  var closestDistance = double.infinity;

  for (var index = 0; index < points.length; index++) {
    final point = points[index];
    final latitudeDelta = point.latitude - vehicle.latitude;
    final longitudeDelta = point.longitude - vehicle.longitude;
    final distance =
        (latitudeDelta * latitudeDelta) + (longitudeDelta * longitudeDelta);

    if (distance < closestDistance) {
      closestDistance = distance;
      closestIndex = index;
    }
  }

  return closestIndex;
}

List<LatLng> _uniqueCoordinates(List<LatLng> coordinates) {
  final seen = <String>{};
  final unique = <LatLng>[];

  for (final coordinate in coordinates) {
    final key = '${coordinate.latitude}:${coordinate.longitude}';
    if (seen.add(key)) {
      unique.add(coordinate);
    }
  }

  return unique;
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
      key: _mapAttributionKey,
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
