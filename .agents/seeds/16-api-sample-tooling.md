# Seed 16 — API Sample Tooling

Use the project rules in this repository.

Implement only this seed.

Context:

- Safe debug HTTP logging exists.
- Developers need a controlled way to inspect Golemio response shapes locally.

Scope:

- Add local tooling under `tool/` or `scripts/` to fetch sample Golemio
  responses for:
  - stops,
  - departure boards for a provided stop ID,
  - vehicle position for a provided vehicle ID.
- Read token from `.env.local` or a command-line argument. Do not require a
  committed token.
- Write raw samples only to an ignored directory such as
  `.debug/golemio_samples/`.
- Update `.gitignore` so raw samples are never committed.
- Add README developer notes for using the tooling.
- Do not add packages unless absolutely necessary.
- Do not change app runtime behavior.

Testing:

- Add unit tests for argument/env parsing if practical.
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
- No raw `.debug/golemio_samples/` files committed.
- No local machine path.

Recommended commit message:

```text
chore: add local Golemio sample tooling
```
