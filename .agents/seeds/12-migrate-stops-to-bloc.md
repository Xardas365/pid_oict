# Seed 12 — Migrate Stops To Bloc

Use the project rules in this repository.

Implement only this seed.

Context:

- Seed 11 has introduced the Bloc/Clean Architecture foundation.
- Preserve the current stops UI and behavior.

Scope:

- Create stops domain repository interface and use cases where not already
  present.
- Create stops data datasource and repository implementation using the existing
  Golemio API client and DTO parsing.
- Add a Stops Bloc or Cubit:
  - use Bloc if explicit load/retry/search events improve clarity,
  - use Cubit only if the state/actions remain clearly simpler.
- State must represent loading, data, filtered data/search query, empty, and
  error.
- Search must remain local over the cleaned visible stop list.
- Preserve technical stop filtering behavior and tests.
- Wire the stops screen through `BlocProvider`.
- Do not migrate departures or vehicle map in this seed.
- Do not change token handling or endpoint parameters.

Testing:

- Add focused Bloc/Cubit tests for load, error, retry if practical, search, and
  technical stop filtering.
- Keep existing widget tests working.
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
refactor: migrate stops feature to Bloc
```
