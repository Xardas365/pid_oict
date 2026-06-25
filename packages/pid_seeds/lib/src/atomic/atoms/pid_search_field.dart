import 'package:flutter/material.dart';

import '../../../i18n/pid_seed_strings.g.dart';
import '../../tokens/pid_seed_colors.dart';
import '../../tokens/pid_seed_radius.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../../tokens/pid_seed_typography.dart';
import 'pid_icon_button.dart';

class PidSearchField extends StatefulWidget {
  const PidSearchField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onFilterPressed,
    this.autofocus = false,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterPressed;
  final bool autofocus;
  final bool enabled;

  @override
  State<PidSearchField> createState() => _PidSearchFieldState();
}

class _PidSearchFieldState extends State<PidSearchField> {
  TextEditingController? _internalController;

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    _internalController =
        widget.controller == null ? TextEditingController() : null;
    _effectiveController.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(PidSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller == widget.controller) {
      return;
    }

    final oldController = oldWidget.controller ?? _internalController;
    oldController?.removeListener(_handleControllerChanged);

    if (oldWidget.controller == null && widget.controller != null) {
      _internalController?.dispose();
      _internalController = null;
    } else if (oldWidget.controller != null && widget.controller == null) {
      _internalController = TextEditingController();
    }

    _effectiveController.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_handleControllerChanged);
    _internalController?.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _clearSearch() {
    final controller = _effectiveController;
    if (controller.text.isEmpty) {
      return;
    }

    controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHintText = widget.hintText ?? t.search.hint;
    final hasText = _effectiveController.text.isNotEmpty;
    final showClearButton = widget.enabled && hasText;
    final showFilterButton = widget.onFilterPressed != null;
    final suffixActions = <Widget>[
      if (showClearButton)
        IconButton(
          tooltip: t.search.clearTooltip,
          onPressed: _clearSearch,
          icon: const Icon(Icons.clear_rounded),
          color: PidSeedColors.textMuted,
          iconSize: 20,
        ),
      if (showClearButton && showFilterButton)
        const SizedBox(width: PidSeedSpacing.xs),
      if (showFilterButton)
        PidIconButton(
          icon: Icons.tune_rounded,
          tooltip: t.search.filterTooltip,
          semanticLabel: t.search.filterSemantic,
          onPressed: widget.onFilterPressed,
          size: 36,
          iconSize: 20,
          borderRadius: PidSeedRadius.chip,
        ),
    ];

    return Semantics(
      textField: true,
      label: effectiveHintText,
      child: TextField(
        controller: _effectiveController,
        autofocus: widget.autofocus,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: effectiveHintText,
          hintStyle:
              PidSeedTypography.body.copyWith(color: PidSeedColors.textMuted),
          prefixIcon:
              const Icon(Icons.search_rounded, color: PidSeedColors.textMuted),
          suffixIcon: suffixActions.isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: PidSeedSpacing.sm),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: suffixActions,
                  ),
                ),
          suffixIconConstraints: const BoxConstraints(minHeight: 42),
        ),
      ),
    );
  }
}
