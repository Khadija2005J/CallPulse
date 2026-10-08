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

## Day 2 — 2026-10-08 (Sprint 0, pre-project)

### Done

- Wrote `docs/cahier-des-charges.md` part 1 (in French): context, objectives (OBJ-01..06, OBJ-T01..06), scope and assumptions, 40 functional requirements (BF) and 26 non-functional requirements (BNF). Sections 6 to 10 are placeholders for Day 3.
- MoSCoW mix: 23 Must, 10 Should, 5 Could, 2 Won't.
- Added a traceability table: every business objective is covered by at least one BF.
- Review: all IDs unique, every BNF has a numeric threshold and a verification method.
- Aligned `VISION.md`: dashboard latency target 1 s (was 2 s), statistics per period added to the MVP scope.

### Decisions

- Dashboard latency < 1 s (p95); API p95 < 300 ms at nominal load (100 agents, 5 supervisors, 2 calls/s).
- 500 simulated users is a 5× headroom test with p95 < 500 ms and < 1% errors.
- Routing strategy per queue is a Must (justifies the Strategy pattern): "longest idle agent" (default) and "round robin"; "most skilled agent" is a Could.
- SLA colors are a Must: orange band = up to N points below target, N configurable per queue (default 5).
- Won't: manual call reassignment (BF-21), CSV export (BF-38).
- Call history retention: 90 days. User interface in French. The traffic generator is controlled by the Administrator.

### Difficulties

- Gaps between the Day 2 brief and `VISION.md` (1 s vs 2 s, 500 users vs 100 agents, statistics per period). Solved by explicit decisions instead of silent fixes.
- Turning vague wishes into measurable requirements: each BNF needed a number and a test.

### Tomorrow — Day 3

- Requirements document, part 2: actors in detail and business rules (agent status transitions, routing algorithm, exact SLA definition), constraints, deliverables, global acceptance criteria.
