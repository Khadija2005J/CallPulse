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

- ~~Write the "Why" column of ADR-001 myself.~~ Done on Day 2.

### Tomorrow — Day 2

- Requirements document, part 1.

## Day 2 — 2026-10-08 (Sprint 0, pre-project)

### Done

- Wrote `docs/cahier-des-charges.md` part 1 (in French): context, objectives (OBJ-01..06, OBJ-T01..06), scope and assumptions, 40 functional requirements (BF) and 26 non-functional requirements (BNF). Sections 6 to 10 are placeholders for Day 3.
- MoSCoW mix: 23 Must, 10 Should, 5 Could, 2 Won't.
- Added a traceability table: every business objective is covered by at least one BF.
- Review: all IDs unique, every BNF has a numeric threshold and a verification method.
- Aligned `VISION.md`: dashboard latency target 1 s (was 2 s), statistics per period added to the MVP scope.
- Completed the "Why" column of ADR-001 (12 rationales linked to project constraints and requirements).

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

## Day 3 — 2026-10-09 (Sprint 0, pre-project)

### Done

- Wrote `docs/cahier-des-charges.md` part 2 (in French, like part 1): actors and rights matrix (section 6), 36 business rules RG-01..RG-36 (section 7), constraints CT-01..09, deliverables LIV-01..12, global acceptance criteria as yes/no checkboxes (sections 8 to 10).
- Single table of reference parameters (section 7.1): every default value (T = 20 s, O = 80 %, N = 10 points, P = 120 s, F = 30 min, R = 1 s) is defined once and referenced by symbol.
- Full agent status transition table (4 × 4, no undefined cell) with error codes and an explicit evaluation order.
- SLA worked example: 38 / 50 = 76 % → orange, plus boundary cases (80 % green, 70 % orange, 68 % red, exactly 20.0 s out of threshold, no calls → N/A).
- Consistency review: 13 open points recorded in section 11 instead of being silently fixed.

### Decisions

- Document language stays French (consistent with part 1 and BF/BNF wording).
- Orange band default changed from 5 to 10 points (BF-30 updated).
- Routing strategies stay as in BF-19: "longest idle" (default) and "round robin"; skill matching is an eligibility filter, not a strategy.
- Each queue is linked to one team; only that team's agents are eligible (BF-13 updated).
- Supervisor can force Available / On break / Offline, never "On call", and cannot bring an agent out of Offline.
- Supervisor sees all teams; Administrator has read-only access to dashboard and statistics; agents do not see their own statistics (Could candidate).
- SLA: abandoned calls count as failures (denominator = answered + abandoned); "under 20 s" is strict; colour and alerts use the daily rate, the 30-min window is informative.
- Patience: 120 s default, configurable per queue.
- "Wrap-up" status and "VIP" marker: Could, not implemented.
- Dispatch is event-driven with a 1 s safety cycle, because a pure 1 s poll would break BNF-03 (< 500 ms).

### Difficulties

- The Day 3 brief contradicted part 1 on several points (document language, orange band 5 vs 10, routing strategies, queue–team link). Solved by explicit decisions before writing.
- Making every rule unit-testable: UI behaviour was moved out of the rules, and an injectable clock is assumed for durations.

### Tomorrow — Day 4

- Product Backlog: epics, user stories with acceptance criteria, MoSCoW priorities.
- Turn the open points of section 11 into backlog items or decisions (missing BF for queue priority and SLA window, API-down alert BNF, time zone, queue deletion).
