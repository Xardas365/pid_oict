# Seed 14 — Migrate Vehicle Map To Bloc

Use the project rules in this repository.

Implement only this seed.

Context:

- Stops and departures Bloc migrations are complete.
- Preserve current map behavior.

Scope:

- Create vehicle position domain repository interface and use cases where not
  already present.
- Create vehicle position data datasource and repository implementation using
  the existing Golemio API client and DTO parsing.
- Add a VehicleMap Bloc:
  - initial load,
  - retry,
  - periodic refresh,
  - no overlapping refresh requests,
  - stale warning when refresh fails after a successful position,
  - timer/subscription cancellation in `close`.
- Preserve last known position after refresh failure.
- Keep `flutter_map`; do not change map dependency or tile provider unless a
  clear bug requires it.
- Do not change token handling or endpoint parameters.

Testing:

- Add focused Bloc tests for initial loading, error, retry, periodic refresh,
  stale error after a previous position, and timer cleanup where practical.
- Widget tests must not load real map tiles.
- Tests must not call the real Golemio API.
- Tests must not require `GOLEMIO_API_TOKEN`.

Verification:

```bash
dart format .
flutter analyze
flutter test
```

Also run:

```bash
git diff --stat
git diff --check
git status --short
```

Security:

- No real token.
- No `.env.local`.
- No local machine path.

Recommended commit message:

```text
refactor: migrate vehicle map feature to Bloc
```
