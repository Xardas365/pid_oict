# Seed 01 — API configuration and Golemio client

Use the project rules in this repository.

First read:

- `AGENTS.md`
- `.agents/context/api.md`
- `.agents/context/architecture.md`
- `.agents/context/verification.md`
- current `pubspec.yaml`
- relevant files under `lib/`

Task:

Implement the smallest safe API infrastructure for Golemio.

Requirements:

1. Add only the dependencies needed for HTTP communication. Keep dependencies minimal and justify each addition.
2. Create configuration for `GOLEMIO_API_TOKEN` using `String.fromEnvironment`.
3. Do not hardcode a real token.
4. Do not commit a token.
5. Create a central `GolemioApiClient` with:
   - base URL `https://api.golemio.cz`,
   - `x-access-token` header,
   - request timeout,
   - JSON decoding,
   - HTTP status handling,
   - normalized app errors.
6. Missing token must produce a controlled error, not a crash.
7. Unauthorized responses must be distinguishable from generic network failures.
8. Do not implement endpoint repositories or UI in this step.

Suggested locations:

```text
lib/src/core/config/app_config.dart
lib/src/core/network/golemio_api_client.dart
lib/src/core/errors/app_exception.dart
```

Run:

```bash
dart format .
flutter analyze
flutter test
```

Output:

- changed files,
- dependency additions and why,
- checks run and results,
- any remaining assumptions.
