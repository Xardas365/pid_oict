import 'package:flutter/material.dart';

import '../../tokens/pid_seed_typography.dart';

enum PidTextVariant {
  heroTitle,
  screenTitle,
  sectionTitle,
  cardTitle,
  body,
  bodyStrong,
  caption,
  label
}

class PidText extends StatelessWidget {
  const PidText(
    this.data, {
    super.key,
    this.variant = PidTextVariant.body,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  });

  final String data;
  final PidTextVariant variant;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;

  TextStyle get _style => switch (variant) {
        PidTextVariant.heroTitle => PidSeedTypography.heroTitle,
        PidTextVariant.screenTitle => PidSeedTypography.screenTitle,
        PidTextVariant.sectionTitle => PidSeedTypography.sectionTitle,
        PidTextVariant.cardTitle => PidSeedTypography.cardTitle,
        PidTextVariant.body => PidSeedTypography.body,
        PidTextVariant.bodyStrong => PidSeedTypography.bodyStrong,
        PidTextVariant.caption => PidSeedTypography.caption,
        PidTextVariant.label => PidSeedTypography.label,
      };

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      semanticsLabel: semanticsLabel,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: _style.copyWith(color: color),
    );
  }
}
