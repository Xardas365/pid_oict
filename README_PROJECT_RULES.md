# OICT Praha Flutter PID - Project Rules Pack

This pack contains project instructions for Codex/Codex CLI for the OICT Praha Flutter assignment.

## Files

```text
AGENTS.md
.agents/context/assignment.md
.agents/context/api.md
.agents/context/architecture.md
.agents/context/verification.md
.agents/context/readme-requirements.md
.agents/context/implementation-plan.md
.agents/seeds/README.md
.agents/seeds/00-bootstrap-audit.md
.agents/seeds/01-api-config-client.md
.agents/seeds/02-models-parsing.md
.agents/seeds/03-repositories.md
.agents/seeds/04-stops-screen.md
.agents/seeds/05-departures-screen.md
.agents/seeds/06-vehicle-map-screen.md
.agents/seeds/07-ux-polish.md
.agents/seeds/08-tests.md
.agents/seeds/09-readme.md
.agents/seeds/10-final-check.md
.codex/config.toml
.codex/rules/default.rules
.codex/skills/oict-flutter-small-step/SKILL.md
.codex/skills/oict-assignment-review/SKILL.md
.codex/skills/oict-final-check/SKILL.md
```

## How to use

Copy the files into the root of the Flutter repository.

For a new task, ask Codex to start by reading `AGENTS.md` and only the relevant files under `.agents/context/`.

For implementation phases, use the ready-to-paste prompts in `.agents/seeds/`. Start with `.agents/seeds/00-bootstrap-audit.md`, then continue one seed at a time.

For implementation, work in small phases and run:

```bash
dart format .
flutter analyze
flutter test
```

If a future task adds Freezed/json_serializable or other model generators, run
before checks:

```bash
dart run build_runner build
```

## Notes

The rules are adapted for the Golemio/PID assignment and intentionally avoid carrying over any unrelated domain-specific content from the inspiration files.
