import 'package:flutter/material.dart';

import '../../tokens/pid_seed_colors.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../../tokens/pid_seed_typography.dart';

class PidFilterChipData {
  const PidFilterChipData({
    required this.value,
    required this.label,
    this.icon,
  });

  final String value;
  final String label;
  final IconData? icon;

  static const List<PidFilterChipData> pidTransportDefaults = [
    PidFilterChipData(value: 'all', label: 'Vše'),
    PidFilterChipData(value: 'tram', label: 'Tram'),
    PidFilterChipData(value: 'bus', label: 'Bus'),
    PidFilterChipData(value: 'metro', label: 'Metro'),
  ];
}

class PidFilterChips extends StatelessWidget {
  const PidFilterChips({
    super.key,
    required this.filters,
    required this.selectedValue,
    this.onSelected,
  });

  final List<PidFilterChipData> filters;
  final String selectedValue;
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in filters) ...[
            ChoiceChip(
              selected: filter.value == selectedValue,
              showCheckmark: false,
              avatar: filter.icon == null
                  ? null
                  : Icon(
                      filter.icon,
                      size: 16,
                      color: filter.value == selectedValue
                          ? Colors.white
                          : PidSeedColors.textSecondary,
                    ),
              label: Text(filter.label),
              labelStyle: PidSeedTypography.label.copyWith(
                color: filter.value == selectedValue
                    ? Colors.white
                    : PidSeedColors.textSecondary,
              ),
              selectedColor: PidSeedColors.primary,
              backgroundColor: PidSeedColors.surface,
              side: BorderSide(
                color: filter.value == selectedValue
                    ? PidSeedColors.primary
                    : PidSeedColors.border,
              ),
              onSelected:
                  onSelected == null ? null : (_) => onSelected!(filter.value),
            ),
            const SizedBox(width: PidSeedSpacing.sm),
          ],
        ],
      ),
    );
  }
}
