# Seed prompts — OICT PID Flutter

This folder contains ready-to-paste Codex prompts for the project.

Use them one at a time. Do not ask Codex to execute all seeds in one run.
Each seed assumes the agent first reads `AGENTS.md` and the relevant files under `.agents/context/`.

Recommended order:

1. `00-bootstrap-audit.md`
2. `01-api-config-client.md`
3. `02-models-parsing.md`
4. `03-repositories.md`
5. `04-stops-screen.md`
6. `05-departures-screen.md`
7. `06-vehicle-map-screen.md`
8. `07-ux-polish.md`
9. `08-tests.md`
10. `09-readme.md`
11. `10-final-check.md`

The seeds are intentionally small. If Codex finds an unexpected repository state,
it should stop, report it, and propose the smallest safe next step.
