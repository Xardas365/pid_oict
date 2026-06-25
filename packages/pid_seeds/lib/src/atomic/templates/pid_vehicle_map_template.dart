import 'package:flutter/material.dart';

import '../../../i18n/pid_seed_strings.g.dart';
import '../../models/pid_navigation_tab.dart';
import '../../models/pid_vehicle_position_data.dart';
import '../../tokens/pid_seed_colors.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../../tokens/pid_seed_typography.dart';
import '../../utils/pid_transport_type.dart';
import '../atoms/pid_icon_button.dart';
import '../atoms/pid_map_marker.dart';
import '../molecules/pid_bottom_navigation.dart';
import '../molecules/pid_map_control_button.dart';
import '../organisms/pid_map_preview.dart';
import '../organisms/pid_vehicle_map_panel.dart';

class PidVehicleMapTemplate extends StatelessWidget {
  const PidVehicleMapTemplate({
    super.key,
    required PidVehiclePositionData vehicle,
    this.mapContent,
    this.showDefaultMarker = true,
    this.onBack,
    this.onLocatePressed,
    this.onRefresh,
    this.selectedTab = PidNavigationTab.map,
    this.onTabSelected,
  })  : _vehicle = vehicle,
        screenTitle = null,
        screenBackTooltip = null,
        screenContent = null;

  const PidVehicleMapTemplate.screen({
    super.key,
    required String title,
    required Widget content,
    String? backTooltip,
    this.onBack,
  })  : _vehicle = null,
        mapContent = null,
        showDefaultMarker = true,
        onLocatePressed = null,
        onRefresh = null,
        selectedTab = PidNavigationTab.map,
        onTabSelected = null,
        screenTitle = title,
        screenBackTooltip = backTooltip,
        screenContent = content;

  final PidVehiclePositionData? _vehicle;
  final Widget? mapContent;
  final bool showDefaultMarker;
  final VoidCallback? onBack;
  final VoidCallback? onLocatePressed;
  final VoidCallback? onRefresh;
  final PidNavigationTab selectedTab;
  final ValueChanged<PidNavigationTab>? onTabSelected;
  final String? screenTitle;
  final String? screenBackTooltip;
  final Widget? screenContent;

  PidVehiclePositionData get vehicle => _vehicle!;

  @override
  Widget build(BuildContext context) {
    final screenContent = this.screenContent;
    if (screenContent != null) {
      return Scaffold(
        appBar: AppBar(
          leading: onBack == null
              ? null
              : IconButton(
                  tooltip:
                      screenBackTooltip ?? t.templates.vehicleMap.backTooltip,
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
          title: Text(screenTitle ?? ''),
        ),
        body: SafeArea(child: screenContent),
      );
    }

    final vehicle = this.vehicle;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: mapContent ??
                PidMapPreview(
                    vehicle: vehicle, showVehicleMarker: showDefaultMarker),
          ),
          if (mapContent != null && showDefaultMarker)
            Center(
              child: PidVehicleMapMarker(
                lineLabel: vehicle.lineLabel,
                backgroundColor: vehicle.transportType.foreground,
              ),
            ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(PidSeedSpacing.screen),
              child: Row(
                children: [
                  PidIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: t.templates.vehicleMap.backTooltip,
                    semanticLabel: t.templates.vehicleMap.backSemantic,
                    onPressed: onBack,
                    backgroundColor: PidSeedColors.surface,
                    foregroundColor: PidSeedColors.textPrimary,
                  ),
                  const SizedBox(width: PidSeedSpacing.md),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PidSeedSpacing.lg,
                        vertical: PidSeedSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: PidSeedColors.surface,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(22),
                        ),
                        border: Border.all(color: PidSeedColors.border),
                      ),
                      child: Text(
                        t.templates.vehicleMap.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PidSeedTypography.bodyStrong,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: PidSeedSpacing.screen,
            top: 150,
            child: Column(
              children: [
                PidMapControlButton(
                  icon: Icons.my_location_rounded,
                  tooltip: t.templates.vehicleMap.centerTooltip,
                  onPressed: onLocatePressed,
                ),
                const SizedBox(height: PidSeedSpacing.sm),
                PidMapControlButton(
                  icon: Icons.refresh_rounded,
                  tooltip: t.templates.vehicleMap.refreshTooltip,
                  onPressed: onRefresh,
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PidVehicleMapPanel(
              vehicle: vehicle,
              onRefresh: onRefresh,
            ),
          ),
        ],
      ),
      bottomNavigationBar: PidBottomNavigation(
        selectedTab: selectedTab,
        onTabSelected: onTabSelected,
      ),
    );
  }
}
