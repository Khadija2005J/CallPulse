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

### Addendum — review fixes (same day)

Two review passes on part 2, committed as `docs: fix review findings in requirements specification` and `docs: close traceability gaps in requirements specification`.

Decisions taken:

- **Event-driven assignment:** dispatch runs when a call is queued or an agent becomes available, with the 1 s tick only as a safety net; no double assignment under concurrency (RG-37, concurrency test). BNF-03 now defines how the 500 ms is measured.
- **Unified alert levels:** one table in section 7.6. Green: no alert. Orange: badge, Alertmanager `warning` after 5 min. Red: badge plus notification, Alertmanager `critical`. BF-31 and BNF-21 point to it.
- **Soft delete of queues:** deletion refused (HTTP 409) while calls are Waiting, Assigned or InProgress; otherwise the queue is deactivated, its history kept, and it accepts no new calls.
- **No retroactive SLA recalculation:** changing T affects only later calls; changing the window F changes the displayed rate at once; changing O or N changes only the level and alerts. Every SLA parameter change is audited (BF-43).
- **Results recorded at answer or abandon:** each call stores "within / outside threshold" with the T in force at that moment, never recomputed.
- **Time zone as a deployment setting:** timestamps stored in UTC (`timestamptz`, BNF-28); the SLA day uses the center's time zone (default Europe/Paris), not editable in the app.

Traceability: every RG and every acceptance criterion now cites a BF or BNF (47 BF, 29 BNF, 44 RG). Remaining TODO: the CI/CD duration `X minutes` in BNF-29.

### Tomorrow — Day 4

- Product Backlog: epics, user stories with acceptance criteria, MoSCoW priorities.
- Turn the open points of section 11 into backlog items or decisions (missing BF for queue priority and SLA window, API-down alert BNF, time zone, queue deletion).

## Day 4 — 2026-10-11 (Sprint 0, pre-project)

### Done

- Wrote `docs/backlog.md`: 8 epics, 68 user stories, each with 3 Given/When/Then acceptance criteria (at least one error or edge case), a Fibonacci estimate, a MoSCoW priority, a target sprint and its source requirements.
- Traceability: every BF and BNF maps to stories, and all 44 RG are covered. Gaps are listed instead of hidden: BF-21 and BF-38 (Won't), BNF-16 (no story, goes to the Definition of Done), and stories with no BF/BNF source (US-63, US-64, US-66, US-67).
- Balance check: the first draft had 179 Must + Should points for a capacity of 154, Must at 86 %, and S2/S3/S4 overloaded. The problems were reported and then decided, not fixed silently.
- Aligned the specification (version 0.3, separate commit): BF-19 split into BF-19 (default strategy, Must) and BF-48 (round robin, Should), BF-44 Could, rights matrix updated, BNF-10/26 Should, BNF-29 fixed, section 11 points 20 to 24.

### Decisions

- Estimation: 1 point ≈ 1 hour of focused work and 28 points per 2-week sprint (154 in total). To be reviewed after Sprint 1 with the measured velocity.
- Reference story: US-07 "Manage teams and skills" (3 pts, plain CRUD) instead of US-11, which depends on the status state machine.
- Never cut: Docker, Jenkins, basic Kubernetes, Prometheus/Grafana. Cut first: ArgoCD, Loki, Playwright (now Could), then ZAP, purge and HTTPS (Should, in Overflow). Round robin stays Should and is cut last, because it demonstrates the Strategy pattern.
- Production deployment and rollback stay Must. HTTPS with cert-manager is a separate Should story.
- The administrator's read-only dashboard (BF-44) becomes Could.
- BNF-29: 15 min from push to deployed on the test environment, 10 min for pull-request builds, and k6 runs nightly without blocking pushes. A new Must story (US-68) makes Jenkins deploy with Helm, so ArgoCD is not needed for this target.
- Result: Must 129, Should 41 (20 planned, 21 in Overflow), sprints within capacity (149 / 154 planned).

### Difficulties

- The specification's own Must set is about 84 % of capacity. The 70 % target cannot be reached without cutting core MVP functions, so this is an accepted risk to review after Sprint 1.
- The cut-first items (round robin, Loki, ArgoCD, Playwright) contradicted Must requirements in the specification. Solved by updating the specification instead of letting the two documents disagree.

### Open points

- Add `/metrics` (internal port) to the BNF-05 exceptions before S5.
- Define the occupancy formula (BF-35) in section 7 before S4.
- Decide whether production/rollback and HTTPS need their own BNF.

### Tomorrow — Day 5

- Sprint breakdown of S1 into tasks.
- Definition of Done (including an ADR for each structuring choice, BNF-16, and a manual browser check, BNF-24).
- GitHub repository and project board.
- Branching strategy and commit conventions.
