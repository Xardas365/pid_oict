# Seed prompts — OICT PID Flutter

This folder contains ready-to-paste Codex prompts for the project.

Use them one at a time. Do not ask Codex to execute all seeds in one run.
Each seed assumes the agent first reads `AGENTS.md` and the relevant files under `.agents/context/`.

Completed MVP baseline:

- `00-bootstrap-audit.md`
- `01-api-config-client.md`
- `02-models-parsing.md`
- `03-repositories.md`
- `04-stops-screen.md`
- `05-departures-screen.md`
- `06-vehicle-map-screen.md`
- `07-ux-polish.md`
- `08-tests.md`
- `09-readme.md`
- `10-final-check.md`

Post-MVP senior hardening order:

- `11-architecture-bloc-clean-foundation.md`
- `12-migrate-stops-to-bloc.md`
- `13-migrate-departures-to-bloc.md`
- `14-migrate-vehicle-map-to-bloc.md`
- `15-debug-http-logging.md`
- `16-api-sample-tooling.md`
- `17-parser-diagnostics.md`
- `18-ui-seeds-package.md`
- `19-ci-and-final-hardening.md`

The seeds are intentionally small. If Codex finds an unexpected repository state,
it should stop, report it, and propose the smallest safe next step.
