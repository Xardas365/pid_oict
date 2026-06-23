# Seed 18 — UI Seeds Package

Use the project rules in this repository.

Implement only this seed.

Context:

- The app has Bloc/Clean Architecture and diagnostics.
- Future UI work should happen through small, repeatable prompts.

Scope:

- Add or update documentation-only seed prompts for focused UI polish tasks:
  - stops list polish,
  - departures readability,
  - vehicle map status and stale-state polish,
  - empty/error/loading state polish,
  - accessibility and text scaling review.
- Keep prompts specific to the OICT/Golemio PID app.
- Do not change production Dart code in this seed.
- Do not add dependencies.
- Do not include fake production data.
- Do not mention unrelated assignments.

Testing:

- No production Dart behavior should change in this seed.
- Still run the standard verification commands to keep the repository in a
  known-good state.

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
docs: add UI polish seed package
```
