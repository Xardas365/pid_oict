# Seed 17 — Parser Diagnostics

Use the project rules in this repository.

Implement only this seed.

Context:

- Debug HTTP logging and local sample tooling exist.
- Developers need to understand why API records are skipped during parsing.

Scope:

- Add safe parser/repository diagnostics for skipped records.
- Keep diagnostics debug-only and bounded.
- Report, where practical:
  - endpoint or feature,
  - raw record count,
  - valid record count,
  - skipped record count,
  - first few skip reasons.
- Do not expose raw tokens.
- Do not turn parser failures into crashes for optional fields.
- Do not change endpoint parameters.
- Preserve existing user-facing behavior.

Testing:

- Add tests for diagnostic summaries using local fixture maps.
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
chore: add parser diagnostics for skipped records
```
