# Seed 15 — Debug HTTP Logging

Use the project rules in this repository.

Implement only this seed.

Context:

- Bloc/Clean migrations are complete or stable enough.
- Developers need to see what Golemio requests and responses look like without
  leaking secrets.

Scope:

- Add safe debug-only HTTP logging to the app-owned Golemio API client.
- Enable logging only in debug mode and/or with an explicit dart define such as
  `GOLEMIO_DEBUG_HTTP=true`.
- Log:
  - method,
  - path and query,
  - status code,
  - request duration,
  - response byte length,
  - bounded response preview when enabled.
- Never log `x-access-token` or the token value.
- Keep response preview small and bounded.
- Do not add logging packages unless there is a strong reason.
- Do not change endpoint parameters or token handling.

Testing:

- Add tests for redaction and logging behavior where practical.
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
- Token must not appear in logs or snapshots.

Recommended commit message:

```text
chore: add safe debug HTTP logging
```
