# CallPulse — Project Journal

## Day 1 — 2026-10-08 (Sprint 0, pre-project)

### Done

- Initialized the Git repository in the project folder on branch `main`.
- Added `.gitignore` (OS files, editors, secrets such as `.env` and `*.pem`) and `.gitattributes` (LF line endings).
- Wrote a provisional `README.md`.
- Wrote `VISION.md`: problem, solution, learning objectives, yes/no success indicators, MVP scope, assumptions, future evolutions and three personas (Sara, Yassine, Karim).
- Wrote `docs/adr/001-choix-techniques.md` with the initial technical choices, trade-offs and consequences.
- Made one Conventional Commit per step.

### Difficulties

- `git rev-parse --show-toplevel` returned `C:/Users/pc` instead of the project folder: a stray Git repository exists at the root of my user profile (0 commits, no remote). I created a dedicated repository in `CallPulse` instead of committing into the parent one. The parent `.git` still needs to be cleaned up.
- The default branch was `master`. I used `git init -b main` to start on `main`.

### To do

- Write the "Why" column of ADR-001 myself.

### Tomorrow — Day 2

- Requirements document, part 1.
