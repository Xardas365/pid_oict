# Seed 09 — README

Use the project rules in this repository.

First read:

- `AGENTS.md`
- `.agents/context/readme-requirements.md`
- `.agents/context/assignment.md`
- `.agents/context/api.md`
- `.agents/context/verification.md`
- current implementation files
- `pubspec.yaml`

Task:

Create or update the final project README so it matches the actual implementation.

README must include:

1. Project purpose.
2. Flutter version used or tested.
3. Requirements/prerequisites.
4. Dependency installation.
5. How to get or provide the Golemio API token.
6. Run command using `--dart-define=GOLEMIO_API_TOKEN=...`.
7. Build command using `--dart-define=GOLEMIO_API_TOKEN=...`.
8. Test command.
9. Explanation that the token is not committed to the repository.
10. List of used dependencies and why they are used.
11. Implemented assignment requirements.
12. Known limitations and consciously simplified parts.
13. Troubleshooting for:
    - missing token,
    - unauthorized/invalid token,
    - network issue,
    - map tile issue,
    - no vehicle position.

Keep README practical and concise. Do not document features that are not implemented.

Run documentation-relevant checks only. For README-only changes, full Flutter checks are usually not required; explain any skipped checks.

Output:

- changed files,
- README sections added/updated,
- checks run or skipped with reason.
