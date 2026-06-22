---
name: oict-assignment-review
description: Use this skill when reviewing, planning, or preparing final submission for the OICT PID Flutter assignment. Checks mandatory requirements, API handling, token safety, map polling, README accuracy, tests, and submission readiness.
---

# OICT Assignment Review Skill

Use this skill for review, planning, or submission preparation.

Read these files first:

* `AGENTS.md`
* `.agents/context/assignment.md`
* `.agents/context/api.md`
* `.agents/context/architecture.md`
* `.agents/context/verification.md`
* `.agents/context/readme-requirements.md`
* `README.md`
* `pubspec.yaml`
* relevant files under `lib/`
* relevant tests under `test/`

## Review scope

Check the implementation against mandatory assignment requirements, especially:

* stop list screen,
* stop search/filtering by name,
* departure board screen for selected stop,
* pull-to-refresh on departures,
* map action for departures with vehicle ID,
* vehicle map screen,
* marker for current vehicle position,
* periodic vehicle position refresh,
* timer/subscription cleanup,
* Golemio API token passed through configuration,
* `x-access-token` header,
* no hardcoded token,
* README with setup, run, build, token, and test instructions.

## Technical review

Check:

* own Golemio API layer,
* exact endpoint query parameter assumptions,
* safe JSON parsing,
* GeoJSON coordinate order conversion,
* loading/error/empty states,
* user-friendly errors,
* last known vehicle position preservation on refresh failure,
* dependency minimalism,
* state-management consistency,
* tests that run offline,
* generated files if code generation is used,
* no secrets, local paths, debug prints, or irrelevant TODOs.

## Output format

Return:

1. Critical issues blocking submission
2. Important issues to fix
3. Nice-to-have improvements
4. Requirement checklist table
5. README mismatches
6. Suggested next commit
7. Readiness score from 1 to 10

Do not edit files unless explicitly asked.

When asked to fix something, keep the fix small and focused.
