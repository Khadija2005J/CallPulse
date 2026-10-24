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

### Addendum — review fixes (same day)

Review of the specification after the backlog, committed as `docs: align specification and backlog after review`.

Decisions taken:

- **`/metrics` exception:** BNF-05 now exempts `/metrics`. It is exposed on a secondary internal port that the Ingress does not route; Compose does not publish it; in Kubernetes a NetworkPolicy allows only the monitoring namespace. kind's default CNI does not enforce NetworkPolicy, so S5 needs Calico on kind, or k3s.
- **Occupancy formula (RG-45):** instantaneous rate = agents On call / (agents Available + agents On call). Agents On break and Offline are excluded, and the rate shows "N/A" when the denominator is 0. For a single agent it is therefore 100 %, 0 % or N/A. A period-based version computed from the status history is a Could item (BF-49, US-69).
- **Rollback and HTTPS requirements:** BNF-30 (Must): rollback to the previous version in under 5 minutes with `helm rollback`, verified by deploying v2 and then rolling back to v1. BNF-31 (Should): production traffic over HTTPS with a valid certificate. Both are linked to OBJ-T02 and LIV-12, and they are the sources of US-64 and US-67.
- **Outdated text fixed:** section 11 renamed and point 17 closed; deliverables split into MVP and optional (Playwright, ArgoCD, Loki and GitHub Actions moved to LIV-13 to LIV-16, while the Helm chart and Prometheus/Grafana stay MVP); the "push to main" acceptance criterion now relies on Jenkins + Helm (US-68, BNF-29). No global acceptance criterion depends on a Could item.
- **Specification frozen at v1.0:** tag `spec-v1.0`. Any later change goes into the change log (section 12).

Traceability after the fixes: 49 BF, 31 BNF and 45 RG. Only BF-21 and BF-38 (Won't) and BNF-16 (Definition of Done) have no story. The backlog has 69 stories and 206 points, and the sprint plan is unchanged.

### Tomorrow — Day 5

- Sprint breakdown of S1 into tasks.
- Definition of Done (including an ADR for each structuring choice, BNF-16, and a manual browser check, BNF-24).
- GitHub repository and project board.
- Branching strategy and commit conventions.

## Day 5 — 2026-10-11 → 2026-10-19 (Sprint 0, GitHub setup)

Day 5 started on 2026-10-11 and was paused, then finished on 2026-10-19.

### Done

- Public repository `Khadija2005J/CallPulse` created, `main` pushed, tag `spec-v1.0` pushed.
- Wrote `docs/definition-of-done.md` (story, sprint and release levels, Definition of Ready), merged through the first pull request (#1).
- Wrote `docs/sprint-plan.md` (#2): sprint rules and events for a solo developer, calendar S0 to S6, Sprint 1 goal, 8 stories (27 points) in dependency order, each split into tasks estimated in hours.
- GitHub Projects board **CallPulse** (public, linked to the repository): columns Todo / In Progress / Done, custom fields Points, MoSCoW, Epic and Sprint (2-week iterations from 2026-10-26), default workflows (closed or merged → Done).
- Sprint 1 issues #3 to #10, one per story, with acceptance criteria and tasks as a checklist, all fields filled (27 points). Created with GitHub CLI (`gh`), installed for this.
- Wrote `CONTRIBUTING.md` (#11): GitHub Flow, branch names, Conventional Commits, pull request rules, squash merge, tags.
- commitlint 21.2.4 + husky 9.1.7 (#12): a `commit-msg` hook refuses any commit whose message does not follow Conventional Commits. Checked with a bad message, which was refused.
- `.github/CODEOWNERS` and `.github/PULL_REQUEST_TEMPLATE.md` (#13): every pull request starts with "What", `Closes #`, "How it was tested" and the DoD checklist.
- Protection of `main`: pull request required, 0 approvals, rules also apply to admins, no force push, no deletion. Checked with a direct push, which GitHub rejected (`GH006`).

### Decisions

- **Sprint 1 starts on 2026-10-26** (ends 2026-11-06), after the Sprint 0 tooling, so that the Sprint 0 checks of the DoD are active before the first line of code. Sprint 0 therefore runs until 2026-10-23.
- **Jenkins (US-51) is third in Sprint 1**, right after the two skeletons, so that every later story goes through the pipeline from its first pull request.
- **Squash and merge only** (merge commits and rebase disabled in the repository settings): one commit per pull request on `main`, with a Conventional Commits title. Branches are deleted automatically after the merge.
- **0 required approvals**: I cannot approve my own pull requests, so the DoD checklist and a re-read of "Files changed" replace the review.
- **Commit e-mail**: commits use the GitHub noreply address of Khadija2005J. The 20 first commits stay attributed to my other account, because the Gmail address is attached to it.
- **Unknown commit scope = warning only**, so that a new scope does not block a commit; the list is in `commitlint.config.mjs`.
- The repository tooling lives in a root `package.json`; the frontend will have its own in `frontend/`.

### Difficulties

- Commits were shown under my other GitHub account because of the Gmail address. Adding it to Khadija2005J failed ("email is already in use"), so I switched to the noreply address for new commits.
- The first squash merge gave a warning on `git branch -d`: the squash creates a new commit, so Git does not see the branch as merged. Solved with `git branch -D`, now written in `CONTRIBUTING.md`.
- The Epic field was first created with all eight epics in a single option; recreated as eight separate options.
- Creating eight issues by hand was slow, so I installed GitHub CLI. `gh issue create --project` did not add the issues to the board; `gh project item-add` did.
- The protection rule was first saved with 1 required approval, which would have blocked all my pull requests. Changed to 0.

### Open points

- Sprint 5 (2026-12-21 → 2027-01-01) covers the end-of-year holidays: decide at the S4 review whether to reduce or shift it.
- US-50 mentions the call generator, which only exists from US-17 (S3): in S1 Compose runs API, frontend and database.
- Delete the empty "untitled project" on GitHub.

### Next — Sprint 1 (from 2026-10-26)

- Sprint planning: move US-48 (#3) to In Progress, branch `feature/us-48-backend-skeleton`.
- First story pull request using the template and `Closes #3`.
