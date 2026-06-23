import 'package:flutter/material.dart';

import '../../models/pid_departure_data.dart';
import '../../models/pid_navigation_tab.dart';
import '../../tokens/pid_seed_colors.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../../tokens/pid_seed_typography.dart';
import '../atoms/pid_icon_button.dart';
import '../atoms/pid_section_title.dart';
import '../molecules/pid_bottom_navigation.dart';
import '../molecules/pid_feedback_state.dart';
import '../molecules/pid_filter_chips.dart';
import '../molecules/pid_refresh_status_card.dart';
import '../organisms/pid_departure_list.dart';

class PidDeparturesTemplate extends StatelessWidget {
  const PidDeparturesTemplate({
    super.key,
    required this.stopName,
    required this.departures,
    required this.updatedText,
    required this.selectedFilter,
    required this.filters,
    this.stopSubtitle,
    this.isLoading = false,
    this.errorMessage,
    this.onBack,
    this.onRefresh,
    this.onFilterSelected,
    this.onShowVehicle,
    this.selectedTab = PidNavigationTab.departures,
    this.onTabSelected,
  });

  final String stopName;
  final String? stopSubtitle;
  final List<PidDepartureData> departures;
  final String updatedText;
  final String selectedFilter;
  final List<PidFilterChipData> filters;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onBack;
  final Future<void> Function()? onRefresh;
  final ValueChanged<String>? onFilterSelected;
  final ValueChanged<PidDepartureData>? onShowVehicle;
  final PidNavigationTab selectedTab;
  final ValueChanged<PidNavigationTab>? onTabSelected;

  @override
  Widget build(BuildContext context) {
    final content = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        PidSeedSpacing.screen,
        PidSeedSpacing.lg,
        PidSeedSpacing.screen,
        PidSeedSpacing.xxl,
      ),
      children: [
        Row(
          children: [
            PidIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Zpět na zastávky',
              semanticLabel: 'Zpět na seznam zastávek',
              onPressed: onBack,
              backgroundColor: PidSeedColors.surface,
              foregroundColor: PidSeedColors.textPrimary,
            ),
            const SizedBox(width: PidSeedSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stopName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PidSeedTypography.screenTitle,
                  ),
                  if (stopSubtitle != null) ...[
                    const SizedBox(height: PidSeedSpacing.xs),
                    Text(stopSubtitle!, style: PidSeedTypography.body),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: PidSeedSpacing.xl),
        PidRefreshStatusCard(
          title: updatedText,
          subtitle: 'Potáhněte dolů pro obnovení odjezdů',
          onRefresh: onRefresh == null
              ? null
              : () {
                  onRefresh!();
                },
        ),
        const SizedBox(height: PidSeedSpacing.xl),
        const PidSectionTitle(title: 'Směr a nástupiště'),
        const SizedBox(height: PidSeedSpacing.sm),
        PidFilterChips(
          filters: filters,
          selectedValue: selectedFilter,
          onSelected: onFilterSelected,
        ),
        const SizedBox(height: PidSeedSpacing.xl),
        PidSectionTitle(
          title: 'Nejbližší odjezdy',
          trailing: Text('${departures.length} spoje',
              style: PidSeedTypography.label),
        ),
        const SizedBox(height: PidSeedSpacing.md),
        if (errorMessage != null)
          PidFeedbackState(
            icon: Icons.wifi_off_rounded,
            title: 'Nepodařilo se načíst odjezdy',
            message: errorMessage!,
            actionLabel: onRefresh == null ? null : 'Obnovit',
            onActionPressed: onRefresh == null
                ? null
                : () {
                    onRefresh!();
                  },
          )
        else
          PidDepartureList(
            departures: departures,
            isLoading: isLoading,
            onShowVehicle: onShowVehicle,
          ),
        const SizedBox(height: PidSeedSpacing.xl),
        const _DepartureHint(),
      ],
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: onRefresh == null
            ? content
            : RefreshIndicator(
                onRefresh: onRefresh!,
                child: content,
              ),
      ),
      bottomNavigationBar: PidBottomNavigation(
        selectedTab: selectedTab,
        onTabSelected: onTabSelected,
      ),
    );
  }
}

class _DepartureHint extends StatelessWidget {
  const _DepartureHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: PidSeedSpacing.lg,
        vertical: PidSeedSpacing.md,
      ),
      decoration: BoxDecoration(
        color: PidSeedColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PidSeedColors.border),
      ),
      child: const Text(
        'Ikona mapy u spoje otevře aktuální polohu vozidla',
        style: PidSeedTypography.caption,
      ),
    );
  }
}
