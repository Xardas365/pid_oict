import 'package:flutter/material.dart';

import '../../models/pid_vehicle_position_data.dart';
import '../../tokens/pid_seed_colors.dart';
import '../../tokens/pid_seed_radius.dart';
import '../../tokens/pid_seed_shadows.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../../tokens/pid_seed_typography.dart';
import '../atoms/pid_badge.dart';
import '../atoms/pid_line_badge.dart';
import '../atoms/pid_status_dot.dart';

class PidVehicleMapPanel extends StatelessWidget {
  const PidVehicleMapPanel({
    super.key,
    required this.vehicle,
    this.onRefresh,
  });

  final PidVehiclePositionData vehicle;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(PidSeedSpacing.screen),
      padding: const EdgeInsets.all(PidSeedSpacing.lg),
      decoration: BoxDecoration(
        color: PidSeedColors.surface,
        borderRadius: PidSeedRadius.xl,
        boxShadow: PidSeedShadows.card,
        border: Border.all(color: PidSeedColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PidLineBadge(
                label: vehicle.lineLabel,
                transportType: vehicle.transportType,
              ),
              const SizedBox(width: PidSeedSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.destination,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PidSeedTypography.cardTitle,
                    ),
                    const SizedBox(height: PidSeedSpacing.xs),
                    Row(
                      children: [
                        const PidStatusDot(),
                        const SizedBox(width: PidSeedSpacing.xs),
                        Expanded(
                          child: Text(
                            vehicle.lastUpdatedText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PidSeedTypography.caption
                                .copyWith(color: PidSeedColors.tealDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Obnovit polohu',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded,
                    color: PidSeedColors.primary),
              ),
            ],
          ),
          const SizedBox(height: PidSeedSpacing.lg),
          Wrap(
            spacing: PidSeedSpacing.sm,
            runSpacing: PidSeedSpacing.sm,
            children: [
              PidBadge(
                icon: Icons.confirmation_number_outlined,
                label: vehicle.vehicleId,
                backgroundColor: PidSeedColors.primarySoft,
                foregroundColor: PidSeedColors.primary,
              ),
              if (vehicle.speedText != null)
                PidBadge(
                  icon: Icons.speed_rounded,
                  label: vehicle.speedText!,
                  backgroundColor: PidSeedColors.tealSoft,
                  foregroundColor: PidSeedColors.tealDark,
                ),
              if (vehicle.coordinatesText != null)
                PidBadge(
                  icon: Icons.my_location_rounded,
                  label: vehicle.coordinatesText!,
                  backgroundColor: PidSeedColors.background,
                  foregroundColor: PidSeedColors.textSecondary,
                  borderColor: PidSeedColors.border,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
