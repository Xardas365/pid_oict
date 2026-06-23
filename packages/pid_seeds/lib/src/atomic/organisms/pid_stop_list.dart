import 'package:flutter/material.dart';

import '../../models/pid_stop_data.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../molecules/pid_feedback_state.dart';
import '../molecules/pid_stop_card.dart';

class PidStopList extends StatelessWidget {
  const PidStopList({
    super.key,
    required this.stops,
    this.isLoading = false,
    this.emptyTitle = 'Žádné zastávky',
    this.emptyMessage = 'Zkuste upravit vyhledávání nebo filtr.',
    this.onStopSelected,
  });

  final List<PidStopData> stops;
  final bool isLoading;
  final String emptyTitle;
  final String emptyMessage;
  final ValueChanged<PidStopData>? onStopSelected;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const PidLoadingState(label: 'Načítání zastávek...');
    if (stops.isEmpty) {
      return PidFeedbackState(
        icon: Icons.location_off_outlined,
        title: emptyTitle,
        message: emptyMessage,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stops.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: PidSeedSpacing.cardGap),
      itemBuilder: (context, index) {
        final stop = stops[index];
        return PidStopCard(
          stop: stop,
          onTap: onStopSelected == null ? null : () => onStopSelected!(stop),
        );
      },
    );
  }
}
