import 'package:flutter/material.dart';

import '../../../i18n/pid_seed_strings.g.dart';
import '../../models/pid_navigation_tab.dart';
import '../../models/pid_stop_data.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../atoms/pid_search_field.dart';
import '../atoms/pid_section_title.dart';
import '../molecules/pid_bottom_navigation.dart';
import '../molecules/pid_feedback_state.dart';
import '../molecules/pid_filter_chips.dart';
import '../organisms/pid_home_header.dart';
import '../organisms/pid_stop_list.dart';

class PidStopsTemplate extends StatelessWidget {
  const PidStopsTemplate({
    super.key,
    required this.stops,
    required this.selectedFilter,
    required this.filters,
    this.isLoading = false,
    this.errorMessage,
    this.searchController,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onFilterPressed,
    this.onFilterSelected,
    this.onStopSelected,
    this.onRefresh,
    this.selectedTab = PidNavigationTab.stops,
    this.onTabSelected,
  })  : screenTitle = null,
        screenSearch = null,
        screenSearchProgress = null,
        screenStatusBanner = null,
        screenContent = null;

  const PidStopsTemplate.screen({
    super.key,
    required String title,
    required Widget search,
    required Widget content,
    Widget? searchProgress,
    Widget? statusBanner,
  })  : stops = const <PidStopData>[],
        selectedFilter = '',
        filters = const <PidFilterChipData>[],
        isLoading = false,
        errorMessage = null,
        searchController = null,
        onSearchChanged = null,
        onSearchSubmitted = null,
        onFilterPressed = null,
        onFilterSelected = null,
        onStopSelected = null,
        onRefresh = null,
        selectedTab = PidNavigationTab.stops,
        onTabSelected = null,
        screenTitle = title,
        screenSearch = search,
        screenSearchProgress = searchProgress,
        screenStatusBanner = statusBanner,
        screenContent = content;

  final List<PidStopData> stops;
  final String selectedFilter;
  final List<PidFilterChipData> filters;
  final bool isLoading;
  final String? errorMessage;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onFilterPressed;
  final ValueChanged<String>? onFilterSelected;
  final ValueChanged<PidStopData>? onStopSelected;
  final Future<void> Function()? onRefresh;
  final PidNavigationTab selectedTab;
  final ValueChanged<PidNavigationTab>? onTabSelected;
  final String? screenTitle;
  final Widget? screenSearch;
  final Widget? screenSearchProgress;
  final Widget? screenStatusBanner;
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
        PidHomeHeader(
          title: t.templates.stops.title,
          subtitle: t.templates.stops.subtitle,
        ),
        const SizedBox(height: PidSeedSpacing.xl),
        PidSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          onSubmitted: onSearchSubmitted,
          onFilterPressed: onFilterPressed,
        ),
        const SizedBox(height: PidSeedSpacing.lg),
        PidFilterChips(
          filters: filters,
          selectedValue: selectedFilter,
          onSelected: onFilterSelected,
        ),
        const SizedBox(height: PidSeedSpacing.xl),
        PidSectionTitle(
          title: t.templates.stops.nearbyStops,
          actionLabel: t.templates.stops.filterAction,
          onActionPressed: onFilterPressed,
        ),
        const SizedBox(height: PidSeedSpacing.md),
        if (errorMessage != null)
          PidFeedbackState(
            icon: Icons.wifi_off_rounded,
            title: t.templates.stops.loadFailed,
            message: errorMessage!,
            actionLabel: onRefresh == null ? null : t.templates.stops.retry,
            onActionPressed: onRefresh == null
                ? null
                : () {
                    onRefresh!();
                  },
          )
        else
          PidStopList(
            stops: stops,
            isLoading: isLoading,
            onStopSelected: onStopSelected,
          ),
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
    final search = screenSearch;

    return Scaffold(
      appBar: AppBar(title: Text(screenTitle ?? '')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              if (search != null) search,
              if (screenSearchProgress != null) screenSearchProgress!,
              if (screenStatusBanner != null) screenStatusBanner!,
              const SizedBox(height: 16),
              Expanded(child: content),
            ],
          ),
        ),
      ),
    );
  }
}
