# Seed 11 — Bloc/Clean Architecture Foundation

Use the project rules in this repository.

Implement only this seed. Do not migrate feature screens yet.

Context:

- Seeds `00` through `10` are the completed MVP baseline.
- The new post-MVP direction is Flutter Bloc + pragmatic Clean Architecture.
- Current behavior must remain unchanged.

Scope:

- Add only the dependencies required for the architecture foundation:
  - `flutter_bloc`
  - Dio if it is not already present.
- Do not add Freezed, `json_serializable`, or `build_runner` in this foundation
  seed. Add model code generation only in a later task when it removes real
  boilerplate and the generated files are committed intentionally.
- Do not add Riverpod, Provider, GetX, service locator packages, or a generated
  Golemio API client.
- Create the minimal target folders for:
  - domain repository interfaces,
  - use cases,
  - data datasources,
  - data repository implementations,
  - presentation Bloc/Cubit folders.
- Add explicit app-level provider composition if useful, using
  `RepositoryProvider` and `BlocProvider`.
- Keep constructor injection.
- Keep handwritten models/states unless a later task explicitly adopts code
  generation.
- Do not migrate stops, departures, or map screen state in this seed.
- Do not change endpoint parameters or token handling.

Testing:

- Update tests only if app composition changes require it.
- Tests must not call the real Golemio API.
- Tests must not require `GOLEMIO_API_TOKEN`.
- Tests must not load real map tiles.

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
chore: add Bloc clean architecture foundation
```
