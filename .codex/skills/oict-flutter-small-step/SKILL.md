---
name: oict-flutter-small-step
description: Use this skill when implementing one small approved step in the OICT PID Flutter project. Keeps changes focused and runs relevant code generation, formatting, analysis, and tests when applicable.
---

# OICT Flutter Small Step Skill

Use this skill to implement exactly one approved task.

Before editing:

* read `AGENTS.md`,
* read `README.md` if it exists,
* read the relevant files under `.agents/context/`,
* inspect only relevant source files,
* identify the smallest safe change.

Rules:

* implement only the requested step,
* do not add unrelated features,
* do not add dependencies unless justified,
* do not hardcode or commit a Golemio API token,
* do not log secrets,
* do not use a generated or third-party Golemio Dart API client,
* do not edit generated files manually,
* keep widgets small,
* keep state focused and easy to inspect,
* keep API DTOs, domain models, and UI widgets separated where useful,
* handle loading, error, and empty states for user-facing API data,
* preserve the existing architecture unless a small improvement is clearly justified.

After implementation, run the relevant checks for the kind of change.

If model files, generated annotations, or JSON mapping changed and the project uses code generation, run code generation first:

```bash
dart run build_runner build
```

Then run the relevant verification commands:

```bash
dart format .
flutter analyze
flutter test
```

For these commands, request escalated execution immediately on Windows. Do not try a sandboxed run first.

For documentation-only or agent-instruction-only changes, full Flutter checks are usually not required. Explain skipped checks.
