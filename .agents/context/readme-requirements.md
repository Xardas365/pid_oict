# README Requirements — OICT PID Flutter

README must be concise, practical, and accurate. It must match the actual implementation.

## Required sections

README must contain:

* project purpose,
* Flutter version used,
* setup instructions,
* run instructions,
* build instructions,
* API token setup,
* test instructions,
* code generation instructions if code generation is used,
* list of used dependencies and why they were used,
* implemented mandatory requirements,
* implemented optional/bonus features,
* known limitations,
* notes about consciously simplified or imperfect solutions,
* troubleshooting.

## Required commands

Include commands equivalent to:

```bash
flutter pub get

flutter run \
  --dart-define=GOLEMIO_API_TOKEN=your_token_here

flutter test

flutter build apk \
  --dart-define=GOLEMIO_API_TOKEN=your_token_here
```

If iOS build instructions are included, make it clear that macOS/Xcode is required.

## API token section

Explain:

* the app uses Golemio API,
* the token is passed through `GOLEMIO_API_TOKEN`,
* the token is sent as `x-access-token`,
* the token must not be committed,
* missing or invalid token appears as an in-app error state.

## Code generation section

Include this section only if the project actually uses Freezed, json_serializable, or another generator.

Example wording:

```md
### Code generation

The project uses `freezed` and `json_serializable` for selected immutable models and JSON mapping. Generated files are committed for easier review, but they should not be edited manually.

Run code generation with:

```bash
dart run build_runner build
```
```

If code generation is not used, state that the project uses manual models/parsers to keep the assignment small.

## Troubleshooting

Include practical notes for:

* missing API token,
* unauthorized or invalid API token,
* network failure,
* no departures returned,
* departure without vehicle ID,
* vehicle position unavailable,
* map tile loading problems.

## Verification section

Mention which checks were run before submission:

```bash
dart format .
flutter analyze
flutter test
```

If a check was not run, explain why.
