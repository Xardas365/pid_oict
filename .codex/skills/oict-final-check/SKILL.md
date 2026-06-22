---
name: oict-final-check
description: Use this skill before submitting the OICT PID Flutter assignment. Performs strict final readiness review without editing files.
---

# OICT Final Check Skill

Use this skill before sending the repository.

Do not edit files.

Read:

* `AGENTS.md`
* `.agents/context/assignment.md`
* `.agents/context/api.md`
* `.agents/context/architecture.md`
* `.agents/context/verification.md`
* `.agents/context/readme-requirements.md`
* `README.md`
* `pubspec.yaml`
* relevant source files under `lib/`
* relevant tests under `test/`

Check:

* mandatory assignment coverage,
* README accuracy,
* dependency justification,
* generated files if code generation is used,
* tests,
* formatting,
* Flutter analysis,
* no real API token,
* no secrets,
* no local machine paths,
* no irrelevant TODOs,
* no debug prints,
* no AI leftovers,
* no generated files edited manually.

For final code-submission validation, run or request these commands if possible:

```bash
dart run build_runner build
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Run `dart run build_runner build` only if code generation is used by the project.

For these commands, request escalated execution immediately on Windows. Do not try a sandboxed run first.

Because this is a no-edit final check, report any file changes produced by code generation or formatting as a validation issue instead of silently accepting them.

For documentation-only or agent-instruction-only changes, full Flutter checks are usually not required. Explain skipped checks.
