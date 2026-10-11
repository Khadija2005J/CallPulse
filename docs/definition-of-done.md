# CallPulse — Definition of Done

- **Version:** 1.0
- **Date:** 2026-10-11 (Day 5, Sprint 0)
- **Author:** Khadija
- **Sources:** [requirements specification v1.0](cahier-des-charges.md), [Product Backlog](backlog.md)

> A story is **Done** only when every applicable item below is checked. A story that is not fully done is not counted in the sprint velocity, goes back to the backlog, and can be re-estimated. There is no "almost done".

Because I work alone (CT-04), these checks replace a code review by someone else. Most of them are automated. The others are ticked by hand in the pull request template.

## 1. When each check applies

Some checks need a tool that is built during the project. A check becomes mandatory in the sprint where its tool is delivered, and stays mandatory afterwards.

| Check | Tool | Mandatory from |
|-------|------|----------------|
| Commit messages follow Conventional Commits | commitlint + husky | Sprint 0 (Day 5) |
| Change merged through a pull request | protection of `main` | Sprint 0 (Day 5) |
| Build, unit tests, lint, no compiler warnings | Jenkins CI v1 (US-51) | S1 |
| Architecture tests (layers) | NetArchTest (US-48) | S1 |
| No secret in the repository | gitleaks (US-51) | S1 |
| Integration tests on PostgreSQL | Testcontainers (US-54) | S1 |
| `docker compose up` healthy from a fresh clone | Docker Compose (US-50) | S1 |
| SonarQube quality gate and Domain coverage | SonarQube (US-52) | S4 |
| No critical vulnerability in images | Trivy (US-53) | S4 |
| Automatic deployment to the test environment | Jenkins + Helm (US-68) | S5 |

Before a tool exists, its check is done by hand when possible. For example, Domain coverage is measured locally with Coverlet before S4.

## 2. Story level

### 2.1 Code and design

- [ ] The work was done on a `feature/*` branch and merged into `main` through a pull request (GitHub Flow).
- [ ] Every commit message follows Conventional Commits, and commitlint accepts it.
- [ ] The layer rules are respected: the architecture tests pass (BNF-14).
- [ ] There is no lint error and no compiler warning: `npm run lint` and `dotnet build -warnaserror` (BNF-23).
- [ ] No secret is in the code or in the history: the gitleaks stage passes (BNF-08).
- [ ] Every new structuring technical choice is recorded in an ADR in `docs/adr/` (BNF-16).
- [ ] Every new API route declares its allowed roles, and the role × route test matrix covers it (BNF-07).

### 2.2 Tests

- [ ] Each of the 3 acceptance criteria of the story is covered by at least one automated test that passes. The test name refers to the criterion, for example `US12_AC2_OnCallAgent_RequestsBreak_IsRefusedWithAppelEnCours`.
- [ ] Every business rule (RG) touched by the story has a unit test in the Domain layer, with an injectable clock when durations are involved.
- [ ] Domain line coverage stays above 70 % (BNF-15), and coverage of new code is at least 70 % (BNF-22).
- [ ] Every test suite of the pipeline passes. No test is disabled or skipped to make the pipeline green.

### 2.3 Pipeline and deployment

- [ ] The Jenkins pipeline is green on the pull request and finishes in less than 10 minutes (BNF-29).
- [ ] The SonarQube quality gate passes (BNF-22), from S4.
- [ ] Trivy finds no CRITICAL vulnerability in the images (BNF-09), from S4.
- [ ] After the merge, the new version is deployed to the test environment and is healthy less than 15 minutes after the push (BNF-29), from S5.

### 2.4 User interface (when the story changes a screen)

- [ ] Every visible label is in French and comes from the label resource file (BNF-25).
- [ ] The screen was checked by hand on the latest Chrome, Edge and Firefox at 1366 × 768, and the result is noted in the pull request (BNF-24). This manual check replaces Playwright, which is Could.

### 2.5 Documentation and tracking

- [ ] The pull request is linked to the story's issue (`Closes #n`), and the issue is in the **Done** column of the board.
- [ ] `README.md` is updated if the way to install, run or deploy the application changed.
- [ ] If the story required a requirement change, the specification is updated and the change is recorded in its change log (section 12).

## 3. Sprint level

- [ ] Every story counted as done meets section 2.
- [ ] `docker compose up` works on a fresh clone, with every service healthy in less than 3 minutes (BNF-17), from S1.
- [ ] There is no open bug that blocks a Must story.
- [ ] The working stories are demonstrated at the end of the sprint.
- [ ] The velocity (points actually done) is recorded in the journal, for the recalibration planned after S1.
- [ ] The journal contains the sprint review and a short retrospective (what went well, what to improve).
- [ ] `main` is tagged at the end of the sprint (`sprint-1`, `sprint-2`, …).

## 4. Release level (end of S6)

- [ ] Every global acceptance criterion of the specification (section 10) is checked.
- [ ] A rollback was tested: v2 deployed, then `helm rollback` to v1, healthy in less than 5 minutes (BNF-30).
- [ ] The SLA alerts and the API-down alert were triggered once on purpose and received (BNF-21, BNF-27).
- [ ] `README.md` explains installation, local run, deployment, rollback and the response to each alert (LIV-11).
- [ ] The final version is tagged (`v1.0.0`).

## 5. Definition of Ready (before a story enters a sprint)

A story can be planned in a sprint only if:

- [ ] It follows the "As a … I want … so that …" format and cites its source requirements.
- [ ] It has 3 Given / When / Then acceptance criteria, including at least one error or edge case.
- [ ] It is estimated at 8 points or less.
- [ ] The stories it depends on are done, or planned earlier in the same sprint.
- [ ] Any open question about its requirements is resolved in the specification.
