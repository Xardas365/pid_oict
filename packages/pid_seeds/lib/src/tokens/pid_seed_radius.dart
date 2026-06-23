import 'package:flutter/material.dart';

/// Border radius tokens for the design system.
class PidSeedRadius {
  const PidSeedRadius._();

  static const double xsValue = 8;
  static const double smValue = 12;
  static const double mdValue = 16;
  static const double lgValue = 20;
  static const double xlValue = 24;
  static const double xxlValue = 28;

  static const BorderRadius xs = BorderRadius.all(Radius.circular(xsValue));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(smValue));
  static const BorderRadius md = BorderRadius.all(Radius.circular(mdValue));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(lgValue));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(xlValue));
  static const BorderRadius xxl = BorderRadius.all(Radius.circular(xxlValue));

  static const BorderRadius chip = BorderRadius.all(Radius.circular(17));
  static const BorderRadius search = BorderRadius.all(Radius.circular(20));
  static const BorderRadius card = lg;
  static const BorderRadius hero = xxl;
  static const BorderRadius navPill = BorderRadius.all(Radius.circular(23));
}
