# Codex Project Guide — OICT PID Flutter

This is the main project-level instruction file for coding agents working in this repository.

## First read

For every task, start with:

* `AGENTS.md`

Then read only the context files relevant to the request:

* `.agents/context/assignment.md` for product requirements and UX acceptance criteria.
* `.agents/context/api.md` for Golemio endpoints, API token handling, parsing, and error rules.
* `.agents/context/architecture.md` for dependencies, folder structure, state management, DTO/domain separation, and generated files.
* `.agents/context/verification.md` for formatting, analysis, tests, code generation, and final readiness checks.
* `.agents/context/readme-requirements.md` for README expectations.

## Operating rules

* Keep the assignment small, clear, and reviewable.
* Mandatory requirements come before optional polish.
* Implement only the requested step.
* Prefer existing project patterns over introducing a new architecture.
* Use exactly one state-management approach. Simple Flutter state is acceptable for this assignment; Riverpod is acceptable only if it is already used or clearly justified.
* Keep dependencies minimal and justify each addition.
* Create the app's own API layer. Do not use a generated or third-party Dart client for Golemio.
* Never hardcode or commit a real Golemio API token.
* Do not log secrets. Technical logs are allowed only in debug mode.
* Do not edit generated files manually.
* Do not silently skip assignment requirements. If something is incomplete, report it clearly.
* Avoid speculative endpoint behavior. Verify Golemio query parameters and response fields before implementing API-specific logic.


## Seed prompts

Ready-to-paste prompts live in `.agents/seeds/`. Use them one at a time.

Recommended first seed:

* `.agents/seeds/00-bootstrap-audit.md`

Then continue with the next numbered seed only after the previous step is stable.

## Recommended workflow for non-trivial changes

1. Inspect only relevant files.
2. State a short implementation plan when useful.
3. Implement the smallest safe change.
4. Run the relevant checks from `.agents/context/verification.md`.
5. Summarize changed files, checks, and any known limitations.

## Command execution

For Flutter/Dart verification commands in this project, request escalated execution immediately on Windows because sandboxed runs can hang or be unreliable.

Do not attempt a sandboxed run first for these commands:

* `dart format .`
* `dart format --set-exit-if-changed .`
* `flutter analyze`
* `flutter test`
* `dart run build_runner build` when code generation is required
* `flutter pub get` when dependencies changed
* `flutter build ...` when a build check is explicitly requested

Use this escalation justification:

* `Flutter/Dart tooling hangs or is unreliable in the Windows sandbox for this project.`

If a command fails or times out with escalated execution, stop and report the exact command and output. Do not retry the same command in the sandbox.

For documentation-only or agent-instruction-only changes, Flutter checks are usually unnecessary. Explain skipped checks in the final response.

## Repository hygiene

Before final submission, verify:

* no real API token is present,
* no local machine paths are committed,
* no irrelevant TODOs or debug prints remain,
* no generated files were edited manually,
* README matches the actual implementation,
* the app can be run with a token passed through configuration.
