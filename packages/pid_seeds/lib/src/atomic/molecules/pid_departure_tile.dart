import 'package:flutter/material.dart';

import '../../../i18n/pid_seed_strings.g.dart';
import '../../models/pid_departure_data.dart';
import '../../tokens/pid_seed_colors.dart';
import '../../tokens/pid_seed_radius.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../../tokens/pid_seed_typography.dart';
import '../../utils/pid_transport_type.dart';
import '../atoms/pid_badge.dart';
import '../atoms/pid_icon_button.dart';
import '../atoms/pid_line_badge.dart';

class PidDepartureTile extends StatelessWidget {
  const PidDepartureTile({
    super.key,
    required this.departure,
    this.onShowVehicle,
  });

  final PidDepartureData departure;
  final VoidCallback? onShowVehicle;

  @override
  Widget build(BuildContext context) {
    final hasVehicle =
        departure.vehicleId != null && departure.vehicleId!.trim().isNotEmpty;

    return Semantics(
      button: hasVehicle,
      label: t.departureTile.semanticLabel(
        line: departure.lineLabel,
        destination: departure.destination,
      ),
      child: Material(
        color: PidSeedColors.surface,
        borderRadius: PidSeedRadius.card,
        child: Container(
          padding: const EdgeInsets.all(PidSeedSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: PidSeedRadius.card,
            border: Border.all(color: PidSeedColors.border),
          ),
          child: Row(
            children: [
              PidLineBadge(
                label: departure.lineLabel,
                transportType: departure.transportType,
                isWarning: departure.isDelayed,
              ),
              const SizedBox(width: PidSeedSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      departure.destination,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PidSeedTypography.cardTitle.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: PidSeedSpacing.xs),
                    Text(
                      [
                        departure.platformText,
                        departure.transportType.labelCs.toLowerCase()
                      ]
                          .whereType<String>()
                          .where((item) => item.isNotEmpty)
                          .join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PidSeedTypography.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: PidSeedSpacing.md),
              if (departure.isDelayed)
                PidBadge(
                  label: departure.delayText!,
                  backgroundColor: PidSeedColors.amberSoft,
                  foregroundColor: PidSeedColors.amberDark,
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      departure.remainingTimeText,
                      style:
                          PidSeedTypography.sectionTitle.copyWith(fontSize: 19),
                    ),
                    Text(
                      t.departureTile.minutesUnit,
                      style: PidSeedTypography.caption,
                    ),
                  ],
                ),
              const SizedBox(width: PidSeedSpacing.md),
              PidIconButton(
                icon: Icons.near_me_outlined,
                tooltip: hasVehicle
                    ? t.departureTile.showVehicleTooltip
                    : t.departureTile.vehicleUnavailable,
                semanticLabel: hasVehicle
                    ? t.departureTile.showVehicleSemantic
                    : t.departureTile.vehicleUnavailable,
                onPressed: hasVehicle ? onShowVehicle : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
