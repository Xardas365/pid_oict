# Seed 10 — Final check before submission

Use the project rules in this repository.

Do not edit files unless explicitly asked after the review.

First read:

- `AGENTS.md`
- `.agents/context/assignment.md`
- `.agents/context/api.md`
- `.agents/context/architecture.md`
- `.agents/context/verification.md`
- `.agents/context/readme-requirements.md`
- `README.md`
- `pubspec.yaml`
- relevant files under `lib/`
- relevant tests under `test/`

Task:

Perform a strict final readiness review.

Check:

1. Stop list screen works.
2. Stop search works.
3. Departures screen works for selected stop.
4. Pull-to-refresh exists on departures.
5. Map action appears only when a usable vehicle ID exists.
6. Vehicle map screen works.
7. Vehicle marker uses correct coordinate order.
8. Vehicle position refresh is periodic.
9. Timer is cancelled in `dispose`.
10. Last known vehicle position is preserved after refresh failure.
11. Missing token is handled.
12. Unauthorized token is handled.
13. Loading, error, and empty states exist.
14. At least one useful unit or widget test exists.
15. Tests do not call real API.
16. No real token is committed.
17. No local machine paths are committed.
18. No irrelevant TODOs, debug prints, or AI leftovers remain.
19. README matches the actual implementation.
20. Dependencies are justified and minimal.

Run final checks if possible:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

If generated models are used, run first:

```bash
dart run build_runner build
```

Output format:

1. Critical issues blocking submission.
2. Important issues to fix.
3. Nice-to-have improvements.
4. Requirement checklist table.
5. README mismatches.
6. Verification command results.
7. Suggested next commit.
8. Readiness score from 1 to 10.
