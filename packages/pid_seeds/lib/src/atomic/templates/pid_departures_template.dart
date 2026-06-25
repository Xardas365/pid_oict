import 'package:flutter/material.dart';

import '../../../i18n/pid_seed_strings.g.dart';
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
  })  : screenTitle = null,
        screenBackTooltip = null,
        screenStopHeader = null,
        screenFilterRow = null,
        screenLastUpdatedRow = null,
        screenContent = null;

  const PidDeparturesTemplate.screen({
    super.key,
    required String title,
    required Widget stopHeader,
    required Widget content,
    String? backTooltip,
    this.onBack,
    Widget? filterRow,
    Widget? lastUpdatedRow,
  })  : stopName = '',
        stopSubtitle = null,
        departures = const <PidDepartureData>[],
        updatedText = '',
        selectedFilter = '',
        filters = const <PidFilterChipData>[],
        isLoading = false,
        errorMessage = null,
        onRefresh = null,
        onFilterSelected = null,
        onShowVehicle = null,
        selectedTab = PidNavigationTab.departures,
        onTabSelected = null,
        screenTitle = title,
        screenBackTooltip = backTooltip,
        screenStopHeader = stopHeader,
        screenFilterRow = filterRow,
        screenLastUpdatedRow = lastUpdatedRow,
        screenContent = content;

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
  final String? screenTitle;
  final String? screenBackTooltip;
  final Widget? screenStopHeader;
  final Widget? screenFilterRow;
  final Widget? screenLastUpdatedRow;
  final Widget? screenContent;

  @override
  Widget build(BuildContext context) {
    final screenContent = this.screenContent;
    if (screenContent != null) {
      return _buildScreenTemplate(screenContent);
    }

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
              tooltip: t.templates.departures.backTooltip,
              semanticLabel: t.templates.departures.backSemantic,
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
          subtitle: t.templates.departures.pullToRefresh,
          onRefresh: onRefresh == null
              ? null
              : () {
                  onRefresh!();
                },
        ),
        const SizedBox(height: PidSeedSpacing.xl),
        PidSectionTitle(title: t.templates.departures.directionAndPlatform),
        const SizedBox(height: PidSeedSpacing.sm),
        PidFilterChips(
          filters: filters,
          selectedValue: selectedFilter,
          onSelected: onFilterSelected,
        ),
        const SizedBox(height: PidSeedSpacing.xl),
        PidSectionTitle(
          title: t.templates.departures.nearestDepartures,
          trailing: Text(
            t.templates.departures.connectionCount(count: departures.length),
            style: PidSeedTypography.label,
          ),
        ),
        const SizedBox(height: PidSeedSpacing.md),
        if (errorMessage != null)
          PidFeedbackState(
            icon: Icons.wifi_off_rounded,
            title: t.templates.departures.loadFailed,
            message: errorMessage!,
            actionLabel:
                onRefresh == null ? null : t.templates.departures.refresh,
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

  Widget _buildScreenTemplate(Widget content) {
    final stopHeader = screenStopHeader;
    final filterRow = screenFilterRow;
    final lastUpdatedRow = screenLastUpdatedRow;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: screenBackTooltip,
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(screenTitle ?? ''),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (stopHeader != null) stopHeader,
            if (filterRow != null) filterRow,
            if (lastUpdatedRow != null) lastUpdatedRow,
            Expanded(child: content),
          ],
        ),
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
      child: Text(
        t.templates.departures.mapHint,
        style: PidSeedTypography.caption,
      ),
    );
  }
}
