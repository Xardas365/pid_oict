# OICT PID Flutter project rules

These files are project instructions for Codex or another coding agent working on the OICT Praha Flutter assignment.

Copy the contents of this directory into the root of the Flutter repository:

```text
AGENTS.md
.agents/context/assignment.md
.agents/context/api.md
.agents/context/architecture.md
.agents/context/readme-requirements.md
.agents/context/verification.md
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

The rules are documentation and agent-instruction files only. Adding them does not require `flutter analyze` or `flutter test`. Run Flutter checks when implementation code changes.

## Intended workflow

1. Let the agent read `AGENTS.md` first.
2. Start with `.agents/seeds/00-bootstrap-audit.md`.
3. Continue with exactly one seed prompt per Codex turn.
4. Require a short plan, a focused diff, and relevant checks.
5. Before submission, run `.agents/seeds/10-final-check.md` or the final-check skill.

## Project scope

The app displays PID stops, departure boards, and a vehicle position map using the Golemio API. The implementation must keep the API token outside the repository and pass it through runtime or build configuration.
