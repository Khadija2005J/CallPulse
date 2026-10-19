# CallPulse — Sprint Plan

- **Version:** 0.1
- **Date:** 2026-10-19 (Day 5, Sprint 0)
- **Author:** Khadija
- **Sources:** [product backlog](backlog.md) (sections 3 and 6.2), [Definition of Done](definition-of-done.md), [ADR-001](adr/001-choix-techniques.md)

> The backlog decides **which** stories go in which sprint. This document decides **when** each sprint runs and **how** Sprint 1 is carried out (goal, order, tasks). The plans for Sprints 2 to 6 are added at each sprint planning, after the previous sprint's review.

---

## 1. Rules

| Topic | Rule |
|-------|------|
| Sprint length | 2 weeks, Monday to Friday of the following week. S6 lasts 1 week. |
| Capacity | 28 points per sprint (S6: 14), with 1 point ≈ 1 hour of focused work, so about 14 hours per week. Recalibrated after S1 with the measured velocity (backlog section 1). |
| Entry | A story enters a sprint only if it meets the Definition of Ready (DoD section 5). |
| Exit | A story counts in the velocity only if it meets the Definition of Done (DoD section 2). An unfinished story goes back to the backlog. |
| Tracking | One GitHub issue per story, with its tasks as a checklist. The issue moves across the Projects board columns (Todo, In progress, Done). |
| Work flow | One branch per story (`feature/us-xx-short-name`), one pull request per story, with `Closes #n` (GitHub Flow, `CONTRIBUTING.md`). |

### Events (solo developer)

| Event | When | Output |
|-------|------|--------|
| Sprint planning | First Monday of the sprint | Sprint goal, stories and tasks in this document; issues created on the board |
| Daily check | Each working session | Board up to date; any blocker noted in the journal |
| Sprint review | Last Friday of the sprint | Demo of the done stories; velocity recorded in the journal |
| Retrospective | Last Friday, after the review | What went well and what to improve, in the journal |
| Sprint tag | After the review | Tag `sprint-n` on `main` (DoD section 3) |

---

## 2. Calendar

| Sprint | Backlog weeks | Dates | Capacity | Planned | Theme (backlog section 6.2) | End tag |
|--------|---------------|-------|---------:|--------:|-----------------------------|---------|
| S0 | 1 | 2026-10-08 → 2026-10-23 | — | — | Vision, specification, backlog, DoD, GitHub setup | `spec-v1.0` (done) |
| S1 | 2-3 | 2026-10-26 → 2026-11-06 | 28 | 27 | Skeletons, Docker Compose, CI, authentication | `sprint-1` |
| S2 | 4-5 | 2026-11-09 → 2026-11-20 | 28 | 27 | Users, reference data, agent statuses, call lifecycle | `sprint-2` |
| S3 | 6-7 | 2026-11-23 → 2026-12-04 | 28 | 28 | Call generator, routing core, real-time hub | `sprint-3` |
| S4 | 8-9 | 2026-12-07 → 2026-12-18 | 28 | 27 | Dashboard, SLA, history and statistics, SonarQube, Trivy | `sprint-4` |
| S5 | 10-11 | 2026-12-21 → 2027-01-01 | 28 | 27 | Kubernetes, Helm, monitoring, k6, Should stories | `sprint-5` |
| S6 | 12 | 2027-01-04 → 2027-01-08 | 14 | 13 | Production deployment with rollback, last Should stories | `v1.0.0` |

Sprint 0 is longer than one week because it started on a Thursday and runs until the GitHub setup of Day 5 is finished (board, commit conventions, protection of `main`), so that the Sprint 0 checks of the DoD are in place before the first line of code.

**Open point:** S5 covers the end-of-year holidays (2026-12-25 and 2027-01-01). Decide at S4 review whether S5 keeps 28 points, is reduced, or is shifted by one week.

---

## 3. Sprint 1 — 2026-10-26 → 2026-11-06

### 3.1 Goal

> **A fresh clone starts with `docker compose up`, every push is built and tested by Jenkins, and a user can log in and reach only the screens of their role.**

### 3.2 Stories (27 points)

| Order | ID | Title | Points | Depends on | Week |
|------:|----|-------|-------:|------------|-----:|
| 1 | US-48 | Layered backend skeleton with architecture tests | 3 | — | 1 |
| 2 | US-49 | Frontend skeleton (Vite, ESLint, French labels) | 2 | — | 1 |
| 3 | US-51 | Jenkins CI v1 (build, tests, lint, gitleaks) | 5 | US-48, US-49 | 1 |
| 4 | US-54 | Integration tests with Testcontainers | 2 | US-48, US-51 | 1 |
| 5 | US-60 | Structured logs with correlation ID | 2 | US-48 | 2 |
| 6 | US-50 | Docker Compose environment | 5 | US-48, US-49 | 2 |
| 7 | US-01 | Log in with email and password | 5 | US-48, US-49, US-54 | 2 |
| 8 | US-03 | Protect every route with JWT and roles (RBAC) | 3 | US-01 | 2 |
| | | **Total** | **27** | | |

Week 1: 12 points. Week 2: 15 points. Free: 1 point.

**Why this order:** the two skeletons come first because everything else builds on them. Jenkins comes right after, so that every later story is checked by the pipeline from its first pull request. Authentication comes last because it needs the database (Testcontainers) and both skeletons.

### 3.3 Tasks

Estimates are in hours (1 point ≈ 1 hour). Each story's tasks add up to its points.

#### US-48 — Layered backend skeleton (3 h)

| ID | Task | Est. |
|----|------|-----:|
| T-48.1 | Create the solution: Domain, Application, Infrastructure, Api and test projects | 0.5 |
| T-48.2 | `Directory.Build.props`: warnings as errors, nullable enabled, `dotnet build -warnaserror` passes | 0.5 |
| T-48.3 | First domain model sketch and API contract conventions (routes, error format) | 0.5 |
| T-48.4 | `/health/live` and `/health/ready` (503 when the database is down) | 0.5 |
| T-48.5 | NetArchTest project: Domain must not reference Infrastructure (and a failing case checked once) | 1 |

#### US-49 — Frontend skeleton (2 h)

| ID | Task | Est. |
|----|------|-----:|
| T-49.1 | Vite + React + TypeScript project in `frontend/` | 0.25 |
| T-49.2 | ESLint and Prettier; `npm run lint` fails on a deliberate error | 0.5 |
| T-49.3 | Vitest with one first test | 0.25 |
| T-49.4 | Single French label file (BNF-25) | 0.5 |
| T-49.5 | Router and base layout | 0.5 |

#### US-51 — Jenkins CI v1 (5 h)

| ID | Task | Est. |
|----|------|-----:|
| T-51.1 | Jenkins in Docker with configuration as code (JCasC) | 1.5 |
| T-51.2 | Declarative multibranch `Jenkinsfile`: backend build and tests, frontend lint, build and tests | 1.5 |
| T-51.3 | Publish test reports; check that a failing test turns the pipeline red | 0.5 |
| T-51.4 | gitleaks stage; check with a fake secret on a test branch | 1 |
| T-51.5 | Stage timings and repository polling (pull request run < 10 min) | 0.5 |

#### US-54 — Integration tests with Testcontainers (2 h)

| ID | Task | Est. |
|----|------|-----:|
| T-54.1 | PostgreSQL Testcontainers fixture; clear failure when Docker is missing | 0.75 |
| T-54.2 | `WebApplicationFactory` wired to the container | 0.5 |
| T-54.3 | UTC tests: Asia/Tokyo session, no `timestamp without time zone` column | 0.5 |
| T-54.4 | Run the integration tests in Jenkins (Docker access for the agent) | 0.25 |

#### US-60 — Structured logs with correlation ID (2 h)

| ID | Task | Est. |
|----|------|-----:|
| T-60.1 | Serilog with a JSON formatter (timestamp, level, message, correlation ID) | 0.5 |
| T-60.2 | Correlation middleware: reuse `X-Correlation-ID` or generate one and return it | 0.75 |
| T-60.3 | Redaction test: no password and no JWT in the logs of a login request | 0.75 |

#### US-50 — Docker Compose environment (5 h)

| ID | Task | Est. |
|----|------|-----:|
| T-50.1 | Multi-stage, non-root Dockerfile for the API | 1 |
| T-50.2 | Multi-stage, non-root Dockerfile for the frontend | 0.75 |
| T-50.3 | `docker-compose.yml`: API, frontend, PostgreSQL, health checks, `depends_on: service_healthy`, `restart: unless-stopped` | 1.5 |
| T-50.4 | Automatic EF Core migrations at start-up; `.env.example` with defaults | 0.75 |
| T-50.5 | Fresh-clone check (< 3 min, `docker kill` recovery < 30 s) and README section | 1 |

The call generator service named in US-50 does not exist before US-17 (S3). In S1 the stack is API, frontend and database; the generator is added to Compose in US-17.

#### US-01 — Log in with email and password (5 h)

| ID | Task | Est. |
|----|------|-----:|
| T-01.1 | ASP.NET Core Identity on PostgreSQL (PBKDF2 hash) and first migration | 1.5 |
| T-01.2 | Login endpoint issuing a JWT (≤ 60 min), same 401 message for unknown email and wrong password | 1 |
| T-01.3 | Login page using the French labels; redirect to the role's screen | 1.5 |
| T-01.4 | Integration tests: 401, token lifetime, no plain password in the table | 1 |

#### US-03 — Protect every route with JWT and roles (3 h)

| ID | Task | Est. |
|----|------|-----:|
| T-03.1 | Authorization policies per role; anonymous only for login and health probes | 1 |
| T-03.2 | React route guard and access-denied page | 1 |
| T-03.3 | Parameterized role × route test from specification section 6.2; a route without a role fails | 1 |

### 3.4 Risks for Sprint 1

| Risk | Effect | Response |
|------|--------|----------|
| Jenkins setup (JCasC, Docker access) takes longer than 5 h | Week 1 slips | Time-box it; if it overruns, keep the stages and move polling or timings to the free point |
| Domain model and API contract design is only counted inside US-48 | Velocity looks lower | Accepted (backlog section 6.3); the S1 velocity will show it |
| Must set is 84 % of total capacity | Little margin for S2 to S6 | If S1 velocity < 28, discuss US-31, US-02 and US-43 first (backlog section 6.3) |

### 3.5 Sprint 1 done when

- All 8 stories meet the DoD, or the unfinished ones are back in the backlog.
- The sprint-level checks of the DoD (section 3) are met: `docker compose up` on a fresh clone in < 3 min, demo, velocity and retrospective in the journal, tag `sprint-1`.
