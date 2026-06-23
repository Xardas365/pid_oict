import 'package:flutter/material.dart';

import '../../../i18n/pid_seed_strings.g.dart';
import '../../models/pid_departure_data.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../molecules/pid_departure_tile.dart';
import '../molecules/pid_feedback_state.dart';

class PidDepartureList extends StatelessWidget {
  const PidDepartureList({
    super.key,
    required this.departures,
    this.isLoading = false,
    this.emptyTitle,
    this.emptyMessage,
    this.onShowVehicle,
  });

  final List<PidDepartureData> departures;
  final bool isLoading;
  final String? emptyTitle;
  final String? emptyMessage;
  final ValueChanged<PidDepartureData>? onShowVehicle;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return PidLoadingState(label: t.loading.departures);
    if (departures.isEmpty) {
      return PidFeedbackState(
        icon: Icons.departure_board_outlined,
        title: emptyTitle ?? t.feedback.departuresEmptyTitle,
        message: emptyMessage ?? t.feedback.departuresEmptyMessage,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: departures.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: PidSeedSpacing.cardGap),
      itemBuilder: (context, index) {
        final departure = departures[index];
        return PidDepartureTile(
          departure: departure,
          onShowVehicle:
              onShowVehicle == null ? null : () => onShowVehicle!(departure),
        );
      },
    );
  }
}
