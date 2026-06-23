import 'package:flutter/material.dart';

import '../../models/pid_navigation_tab.dart';
import '../../tokens/pid_seed_colors.dart';
import '../../tokens/pid_seed_radius.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../../tokens/pid_seed_typography.dart';

typedef PidNavigationTabLabelBuilder = String Function(PidNavigationTab tab);

class PidBottomNavigation extends StatelessWidget {
  const PidBottomNavigation({
    super.key,
    required this.selectedTab,
    this.labelBuilder,
    this.onTabSelected,
  });

  final PidNavigationTab selectedTab;
  final PidNavigationTabLabelBuilder? labelBuilder;
  final ValueChanged<PidNavigationTab>? onTabSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: PidSeedSpacing.bottomNavHeight,
        decoration: const BoxDecoration(
          color: PidSeedColors.surface,
          border: Border(top: BorderSide(color: PidSeedColors.border)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: PidNavigationTab.values.map(_buildItem).toList(),
        ),
      ),
    );
  }

  Widget _buildItem(PidNavigationTab tab) {
    final isSelected = tab == selectedTab;
    final foreground =
        isSelected ? PidSeedColors.primary : PidSeedColors.textMuted;
    final label = labelBuilder?.call(tab) ?? tab.labelCs;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        borderRadius: PidSeedRadius.navPill,
        onTap: onTabSelected == null ? null : () => onTabSelected!(tab),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: PidSeedSpacing.lg, vertical: PidSeedSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: isSelected ? 90 : 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isSelected
                      ? PidSeedColors.primarySoft
                      : Colors.transparent,
                  borderRadius: PidSeedRadius.navPill,
                ),
                child: Icon(tab.icon, color: foreground),
              ),
              const SizedBox(height: PidSeedSpacing.xs),
              Text(
                label,
                style: PidSeedTypography.caption.copyWith(
                  color: foreground,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
