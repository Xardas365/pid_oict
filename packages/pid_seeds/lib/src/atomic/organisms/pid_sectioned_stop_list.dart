import 'package:flutter/material.dart';

import '../../models/pid_stop_data.dart';
import '../../tokens/pid_seed_shadows.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../atoms/pid_section_title.dart';
import '../molecules/pid_stop_card.dart';

@immutable
class PidStopListItem {
  const PidStopListItem({
    required this.stop,
    this.semanticLabel,
    this.onTap,
    this.trailingAction,
  });

  final PidStopData stop;
  final String? semanticLabel;
  final VoidCallback? onTap;
  final PidStopCardAction? trailingAction;
}

@immutable
class PidStopListSection {
  const PidStopListSection({
    required this.items,
    this.title,
    this.topPadding = 0,
  });

  final String? title;
  final List<PidStopListItem> items;
  final double topPadding;

  bool get hasTitle {
    final sectionTitle = title;
    return sectionTitle != null && sectionTitle.isNotEmpty;
  }
}

class PidSectionedStopList extends StatelessWidget {
  const PidSectionedStopList({
    super.key,
    required this.sections,
    required this.controller,
    this.isLoadingMore = false,
    this.showBackToTopButton = false,
    this.backToTopTooltip,
    this.onScrollToTop,
  });

  final List<PidStopListSection> sections;
  final ScrollController controller;
  final bool isLoadingMore;
  final bool showBackToTopButton;
  final String? backToTopTooltip;
  final VoidCallback? onScrollToTop;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scrollbar(
          controller: controller,
          interactive: false,
          radius: const Radius.circular(999),
          thickness: 4,
          child: ListView.builder(
            controller: controller,
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: _itemCount,
            itemBuilder: _buildItem,
          ),
        ),
        Positioned(
          right: 0,
          bottom: PidSeedSpacing.md,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: showBackToTopButton && onScrollToTop != null
                ? _BackToTopButton(
                    tooltip: backToTopTooltip,
                    onPressed: onScrollToTop!,
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  int get _itemCount {
    return sections.fold<int>(isLoadingMore ? 1 : 0, (count, section) {
      return count + section.items.length + (section.hasTitle ? 1 : 0);
    });
  }

  Widget _buildItem(BuildContext context, int index) {
    var cursor = 0;

    for (final section in sections) {
      if (section.hasTitle) {
        if (index == cursor) {
          return _SectionHeader(section: section);
        }
        cursor++;
      }

      final localIndex = index - cursor;
      if (localIndex >= 0 && localIndex < section.items.length) {
        return _StopListCard(item: section.items[localIndex]);
      }
      cursor += section.items.length;
    }

    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: PidSeedSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return const SizedBox.shrink();
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.section});

  final PidStopListSection section;

  @override
  Widget build(BuildContext context) {
    final title = section.title;

    if (title == null || title.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: section.topPadding, bottom: 8),
      child: PidSectionTitle(title: title),
    );
  }
}

class _StopListCard extends StatelessWidget {
  const _StopListCard({required this.item});

  final PidStopListItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PidStopCard(
        stop: item.stop,
        semanticLabel: item.semanticLabel,
        onTap: item.onTap,
        trailingAction: item.trailingAction,
      ),
    );
  }
}

class _BackToTopButton extends StatelessWidget {
  const _BackToTopButton({required this.onPressed, this.tooltip});

  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: PidSeedShadows.card,
      ),
      child: IconButton.filled(
        key: const ValueKey('stops-back-to-top'),
        onPressed: onPressed,
        icon: const Icon(Icons.keyboard_arrow_up_rounded),
      ),
    );

    final tooltip = this.tooltip;
    if (tooltip == null || tooltip.isEmpty) {
      return button;
    }

    return Tooltip(
      message: tooltip,
      child: button,
    );
  }
}
