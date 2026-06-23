import 'package:flutter/material.dart';

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
  });

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
        const PidHomeHeader(
          title: 'Zastávky PID',
          subtitle: 'Najděte zastávku a pokračujte na aktuální odjezdy',
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
          title: 'Nejbližší zastávky',
          actionLabel: 'Filtrovat',
          onActionPressed: onFilterPressed,
        ),
        const SizedBox(height: PidSeedSpacing.md),
        if (errorMessage != null)
          PidFeedbackState(
            icon: Icons.wifi_off_rounded,
            title: 'Nepodařilo se načíst zastávky',
            message: errorMessage!,
            actionLabel: onRefresh == null ? null : 'Zkusit znovu',
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
}
