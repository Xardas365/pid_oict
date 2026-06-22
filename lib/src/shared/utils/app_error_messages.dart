import '../../core/errors/app_exception.dart';

String userMessageForAppError(
  Object? error, {
  required String fallbackMessage,
  String? invalidDataMessage,
}) {
  if (error is! AppException) {
    return fallbackMessage;
  }

  return switch (error.type) {
    AppExceptionType.missingToken =>
      'Chybi Golemio API token. Spustte aplikaci s '
          '--dart-define=GOLEMIO_API_TOKEN=vas_token.',
    AppExceptionType.unauthorized =>
      'Golemio API token je neplatny nebo nema opravneni. Zkontrolujte token.',
    AppExceptionType.network =>
      'Nepodarilo se pripojit ke Golemio API. Zkontrolujte pripojeni k internetu.',
    AppExceptionType.timeout =>
      'Golemio API neodpovedelo vcas. Zkuste to prosim znovu.',
    AppExceptionType.emptyResponse => 'Golemio API vratilo prazdnou odpoved.',
    AppExceptionType.invalidJson =>
      'Golemio API vratilo odpoved, kterou se nepodarilo precist.',
    AppExceptionType.invalidData =>
      invalidDataMessage ??
          'Golemio API vratilo nekompletni nebo neplatna data.',
    AppExceptionType.badRequest =>
      'Golemio API pozadavek nebyl prijat. Zkuste akci zopakovat.',
    AppExceptionType.notFound =>
      'Pozadovana data nebyla v Golemio API nalezena.',
    AppExceptionType.server =>
      'Golemio API je docasne nedostupne. Zkuste to prosim pozdeji.',
    AppExceptionType.unexpectedStatus =>
      'Golemio API vratilo neocekavanou odpoved.',
  };
}

String staleDataWarning(Object? error) {
  final message = userMessageForAppError(
    error,
    fallbackMessage: 'Aktualizace se nepodarila.',
  );

  return 'Zobrazuji posledni znamou polohu. $message';
}
