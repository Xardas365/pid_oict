import 'package:flutter/material.dart';

import '../../tokens/pid_seed_colors.dart';
import '../../tokens/pid_seed_radius.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../../tokens/pid_seed_typography.dart';
import 'pid_icon_button.dart';

class PidSearchField extends StatelessWidget {
  const PidSearchField({
    super.key,
    this.controller,
    this.hintText = 'Vyhledat zastávku...',
    this.onChanged,
    this.onSubmitted,
    this.onFilterPressed,
    this.autofocus = false,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterPressed;
  final bool autofocus;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: hintText,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        enabled: enabled,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:
              PidSeedTypography.body.copyWith(color: PidSeedColors.textMuted),
          prefixIcon:
              const Icon(Icons.search_rounded, color: PidSeedColors.textMuted),
          suffixIcon: onFilterPressed == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: PidSeedSpacing.sm),
                  child: PidIconButton(
                    icon: Icons.tune_rounded,
                    tooltip: 'Filtrovat',
                    semanticLabel: 'Filtrovat zastávky',
                    onPressed: onFilterPressed,
                    size: 36,
                    iconSize: 20,
                    borderRadius: PidSeedRadius.chip,
                  ),
                ),
          suffixIconConstraints:
              const BoxConstraints(minWidth: 52, minHeight: 42),
        ),
      ),
    );
  }
}
