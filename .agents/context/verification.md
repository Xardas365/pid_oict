# Verification Context — OICT PID Flutter

## Standard checks

For code changes, run the relevant checks before finishing:

```bash
dart format .
flutter analyze
flutter test
```

If model files, generated annotations, or JSON mapping changed and the project uses code generation, run code generation first:

```bash
dart run build_runner build
```

For documentation-only or agent-instruction-only changes, full Flutter checks are usually not required. If a relevant check is skipped, explain why in the final response.

## Windows execution guidance

For Flutter/Dart verification commands in this project, request escalated execution immediately on Windows because sandboxed runs can hang or be unreliable.

Do not attempt a sandboxed run first for:

* `dart format .`
* `dart format --set-exit-if-changed .`
* `flutter analyze`
* `flutter test`
* `flutter pub get`
* `dart run build_runner build`
* `flutter build ...`

Use this justification:

* `Flutter/Dart tooling hangs or is unreliable in the Windows sandbox for this project.`

If a command fails, report the exact command and output.

## Code generation

Never edit generated files manually:

* `*.freezed.dart`
* `*.g.dart`

When code generation is used and source model files change, run:

```bash
dart run build_runner build
```

Then run formatting, analysis, and tests.

## Testing guidance

Add tests where they provide value. At minimum, the assignment should include at least one unit or widget test.

Recommended useful tests:

* stop DTO/domain parsing,
* departure DTO/domain parsing,
* vehicle position parsing,
* GeoJSON coordinate order conversion,
* stop name filtering,
* API client error handling,
* repository behavior with mocked API responses,
* departure screen pull-to-refresh behavior if practical,
* vehicle polling logic if practical without fragile timers.

Tests must not call the real Golemio API and must not require a real API token.

## GitHub Actions

If adding CI, keep it simple:

* checkout,
* setup Flutter,
* `flutter pub get`,
* `dart format --set-exit-if-changed .`,
* `flutter analyze`,
* `flutter test`.

Do not add complex release or build pipelines.

## Final readiness checklist

Before considering the assignment complete, verify:

* Stop list screen works.
* Stop search/filtering works.
* Stop tap opens the departure board.
* Departure board loads data for the selected stop.
* Departure board has pull-to-refresh.
* Departure rows show basic readable data.
* Map action is available only when a usable vehicle ID exists.
* Vehicle map loads a marker for a valid vehicle position.
* Vehicle map refreshes periodically.
* Vehicle map polling is cancelled on dispose.
* Last known vehicle position is preserved on refresh failure.
* API token is not hardcoded or committed.
* Missing token and invalid token are handled gracefully.
* Loading, empty, and error states exist on all relevant screens.
* Coordinates are converted correctly.
* Tests do not call the real API.
* Generated files are up to date if code generation is used.
* No generated files were edited manually.
* `dart format .` was run for code changes.
* `flutter analyze` passes or failures are explained.
* `flutter test` passes or failures are explained.
* README is complete and matches the implementation.
* No irrelevant TODOs, debug prints, local paths, or AI leftovers remain.
