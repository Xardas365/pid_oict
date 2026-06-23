import 'package:flutter/material.dart';

import '../../models/pid_departure_data.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../molecules/pid_departure_tile.dart';
import '../molecules/pid_feedback_state.dart';

class PidDepartureList extends StatelessWidget {
  const PidDepartureList({
    super.key,
    required this.departures,
    this.isLoading = false,
    this.emptyTitle = 'Žádné aktuální odjezdy',
    this.emptyMessage = 'Zkuste obnovit data nebo vybrat jiný směr.',
    this.onShowVehicle,
  });

  final List<PidDepartureData> departures;
  final bool isLoading;
  final String emptyTitle;
  final String emptyMessage;
  final ValueChanged<PidDepartureData>? onShowVehicle;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const PidLoadingState(label: 'Načítání odjezdů...');
    if (departures.isEmpty) {
      return PidFeedbackState(
        icon: Icons.departure_board_outlined,
        title: emptyTitle,
        message: emptyMessage,
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
