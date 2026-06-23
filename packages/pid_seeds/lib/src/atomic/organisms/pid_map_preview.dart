import 'package:flutter/material.dart';

import '../../models/pid_vehicle_position_data.dart';
import '../../tokens/pid_seed_colors.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../../utils/pid_transport_type.dart';
import '../atoms/pid_map_marker.dart';

class PidMapPreview extends StatelessWidget {
  const PidMapPreview({
    super.key,
    this.vehicle,
    this.showVehicleMarker = true,
  });

  final PidVehiclePositionData? vehicle;
  final bool showVehicleMarker;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: PidSeedColors.mapGradient),
      child: CustomPaint(
        painter: _PidMapPreviewPainter(),
        child: Stack(
          children: [
            if (showVehicleMarker && vehicle != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: PidSeedSpacing.xxl),
                  child: PidVehicleMapMarker(
                    lineLabel: vehicle!.lineLabel,
                    backgroundColor: vehicle!.transportType.foreground,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PidMapPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = PidSeedColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final routePaint = Paint()
      ..color = PidSeedColors.primary.withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    final softRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final path1 = Path()
      ..moveTo(-20, size.height * 0.22)
      ..cubicTo(size.width * 0.22, size.height * 0.12, size.width * 0.30,
          size.height * 0.40, size.width * 0.55, size.height * 0.34)
      ..cubicTo(size.width * 0.76, size.height * 0.29, size.width * 0.88,
          size.height * 0.42, size.width + 20, size.height * 0.34);

    final path2 = Path()
      ..moveTo(size.width * 0.18, -20)
      ..cubicTo(size.width * 0.28, size.height * 0.24, size.width * 0.10,
          size.height * 0.52, size.width * 0.33, size.height * 0.75)
      ..cubicTo(size.width * 0.50, size.height * 0.92, size.width * 0.76,
          size.height * 0.80, size.width * 0.98, size.height + 20);

    final path3 = Path()
      ..moveTo(-20, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.36, size.height * 0.64,
          size.width * 0.58, size.height * 0.82)
      ..quadraticBezierTo(
          size.width * 0.78, size.height, size.width + 20, size.height * 0.86);

    canvas.drawPath(path1, roadPaint);
    canvas.drawPath(path1, softRoadPaint);
    canvas.drawPath(path2, roadPaint);
    canvas.drawPath(path2, softRoadPaint);
    canvas.drawPath(path3, roadPaint);
    canvas.drawPath(path3, softRoadPaint);
    canvas.drawPath(path2, routePaint);

    final stationPaint = Paint()..color = PidSeedColors.surface;
    final stationBorderPaint = Paint()
      ..color = PidSeedColors.primaryBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final stations = <Offset>[
      Offset(size.width * 0.22, size.height * 0.20),
      Offset(size.width * 0.34, size.height * 0.46),
      Offset(size.width * 0.52, size.height * 0.62),
      Offset(size.width * 0.74, size.height * 0.78),
    ];

    for (final station in stations) {
      canvas.drawCircle(station, 8, stationPaint);
      canvas.drawCircle(station, 8, stationBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PidMapPreviewPainter oldDelegate) => false;
}
