# Seed 00 — Bootstrap audit

Use the project rules in this repository.

First read:

- `AGENTS.md`
- `.agents/context/assignment.md`
- `.agents/context/api.md`
- `.agents/context/architecture.md`
- `.agents/context/verification.md`
- `.agents/context/readme-requirements.md`
- `README.md`, if it exists
- `pubspec.yaml`, if it exists

Project context:

This is an OICT Praha / Golemio PID Flutter project for Prague Integrated Transport stops, departure boards, and vehicle positions.

Mandatory app scope:

- stops list from `GET https://api.golemio.cz/v2/gtfs/stops`
- local stop search by name
- departures from `GET https://api.golemio.cz/v2/public/departureboards`
- vehicle map from `GET https://api.golemio.cz/v2/vehiclepositions/{gtfsTripId}`
- API token through `--dart-define=GOLEMIO_API_TOKEN=...`
- `x-access-token` header
- no hardcoded or committed real token

Task:

1. Audit the repository.
2. Verify that the project rules match the OICT/Golemio assignment.
3. If you find leftovers from another assignment, report them and propose a fix. Do not implement those unrelated requirements.
4. Check whether a Flutter project already exists.
5. If it does not exist, create a clean Flutter project.
6. If it exists, preserve its base and only prepare the minimal structure needed for the next steps.
7. Prepare or verify this structure:

```text
lib/
  main.dart
  src/
    core/
      config/
      network/
      errors/
    features/
      stops/
        data/
        domain/
        presentation/
      departures/
        data/
        domain/
        presentation/
      vehicle_map/
        data/
        domain/
        presentation/
    shared/
      widgets/
      utils/

test/
```

Do not implement API calls, screens, map, business logic, or new dependencies in this step.

Run the relevant checks:

```bash
dart format .
flutter analyze
```

If `flutter test` is not useful yet because there are no meaningful tests, skip it and explain why.

Output:

- repository state,
- rule inconsistencies or risks,
- changed files,
- checks run and results,
- recommended next step.
