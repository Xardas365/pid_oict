# Seed 19 — CI And Final Hardening

Use the project rules in this repository.

Implement only this seed.

Context:

- Bloc/Clean Architecture migration and diagnostics are stable.
- This is the final hardening pass before submission or sharing.

Scope:

- Add or verify simple CI if requested by the repository owner:
  - checkout,
  - setup Flutter,
  - `flutter pub get`,
  - `dart format --set-exit-if-changed .`,
  - `flutter analyze`,
  - `flutter test`.
- Run a strict final audit:
  - no real API token,
  - no `.env.local`,
  - no local paths,
  - no old assignment references,
  - no debug logs enabled by default in release,
  - no generated files edited manually,
  - README matches actual behavior.
- Do not add release automation or complex build pipelines unless explicitly
  requested.
- Do not change endpoint parameters without proof from Golemio docs/API.

Testing:

- CI/test changes must not call the real Golemio API.
- Tests must not require `GOLEMIO_API_TOKEN`.
- Widget tests must not load real map tiles.

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
- No raw API sample files.

Recommended commit message:

```text
chore: harden CI and final submission checks
```
