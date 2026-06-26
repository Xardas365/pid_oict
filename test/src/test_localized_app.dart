import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pid_oict/i18n/strings.g.dart';
import 'package:pid_seeds/i18n/pid_seed_strings.g.dart' as pid_seed_strings;
import 'package:pid_seeds/pid_seeds.dart';

Widget localizedTestApp({
  required Widget home,
  AppLocale locale = AppLocale.cs,
  TargetPlatform? platform,
}) {
  LocaleSettings.setLocaleSync(locale);
  pid_seed_strings.LocaleSettings.setLocaleRawSync(locale.languageCode);

  return TranslationProvider(
    child: Builder(
      builder: (context) {
        final theme = PidSeedsTheme.light();

        return MaterialApp(
          theme: platform == null ? theme : theme.copyWith(platform: platform),
          locale: TranslationProvider.of(context).flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: home,
        );
      },
    ),
  );
}
