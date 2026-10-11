# CallPulse — Product Backlog

- **Version:** 0.2 (Day 4 decisions applied; see section 6.3)
- **Date:** 2026-10-11 (Day 4, Sprint 0)
- **Author:** Khadija
- **Sources:** [VISION.md](../VISION.md), [requirements specification](cahier-des-charges.md) (BF, BNF, RG IDs), [ADR-001](adr/001-choix-techniques.md)

> The specification is the reference. Every story cites the BF, BNF or RG it implements. Where this backlog departs from the specification, the departure is listed in section 6.3 or section 5.3. Nothing is changed silently.

**Glossary:** the UI is in French (BNF-25), and this backlog uses English names.

| Backlog term | Specification term |
|--------------|--------------------|
| Available / On call / On break / Offline | Disponible / En communication / En pause / Hors ligne |
| Waiting / Assigned / InProgress / Completed / Abandoned | En attente / Affecté / En cours / Terminé / Abandonné |
| Within threshold | Décroché dans le seuil |
| Error codes `STATUT_IDENTIQUE`, `TRANSITION_INVALIDE`, `APPEL_EN_COURS`, `ACTEUR_NON_AUTORISE`, `FILE_NON_VIDE` | Kept as in the specification (they are API codes) |
| T, O, N, P, F, W, R, Z, PRIO, STRAT | Reference parameters of section 7.1 |

---

## 1. Method

| Topic | Rule |
|-------|------|
| Structure | 8 epics (E1 to E8) split into user stories (US-xx). Each story is small enough to be finished within one sprint. |
| Story format | "As a <role>, I want <goal> so that <benefit>." Roles: Agent, Supervisor, Administrator, System, and Developer/Ops for E8. |
| Acceptance criteria | Exactly 3 per story, in Given / When / Then form. At least one covers an error or edge case. Each criterion maps to one automated test (unit, integration, E2E or pipeline check). |
| Estimation scale | Fibonacci: 1, 2, 3, 5, 8. A story above 8 points must be split. In this draft no story is above 5. |
| Reference story | **US-07 "Manage teams and skills" = 3 points.** Plain CRUD from end to end: one entity and migration, endpoints, one admin screen, unit and integration tests, with no business rule. It replaces US-11, which depends on the status state machine (US-12) and on error-code mapping, so it is not simple enough to be the reference. Other stories are estimated relative to it. |
| Point value | 1 point ≈ 1 hour of focused work (code, tests, pipeline). It excludes learning time, documentation and the journal. |
| Capacity | About 28 points per 2-week sprint. S6 lasts 1 week, so about 14. Total for S1 to S6: **154 points**. Calibration is reviewed after Sprint 1 with the measured velocity. |
| Overflow | Should stories that do not fit in the 154-point capacity have the sprint "Overflow". They are pulled into a sprint only if velocity allows. |
| Planning | S1 (weeks 2-3): design, skeleton, Docker, Jenkins v1. S2 (weeks 4-5): backend core. S3 (weeks 6-7): real time and dashboard. S4 (weeks 8-9): SLA, statistics, quality, CI/CD. S5 (weeks 10-11): Kubernetes, monitoring, security. S6 (week 12): production, GitOps. |
| MoSCoW | **Must**: the MVP fails without it. **Should**: important, delivered if possible. **Could**: only if time remains, with no target sprint. **Could (out of MVP)**: kept as a note and never planned (BF-45, BF-46, BF-47). **Won't**: excluded (BF-21, BF-38) and has no story. By default a story takes the priority of its main source requirement. Exceptions are listed in section 6.3. |
| Cut order if late | Never cut: Docker, Jenkins, basic Kubernetes, Prometheus/Grafana. Cut first: ArgoCD (US-65), Loki (US-61), Playwright (US-56), all now Could. Then: ZAP (US-62), purge (US-46), HTTPS (US-67). Last: round robin (US-22), the second strategy that demonstrates the Strategy pattern. |

## 2. Epics

| Epic | Name | Value | Covered requirements |
|------|------|-------|----------------------|
| E1 | Access and security | Only known users get in, and each one sees only what their role allows. | BF-01 to BF-06, BNF-05, BNF-06, BNF-07 |
| E2 | Reference data | The administrator describes the center (teams, skills, agents, queues), and routing uses that description at once, without a restart. | BF-12, BF-13, BF-14, BF-41 |
| E3 | Agent statuses | Agent statuses are always true, because invalid changes are refused and every change is recorded. | BF-07, BF-08, BF-11, BF-23, BF-27, BF-46, BNF-28 |
| E4 | Calls and routing | Every simulated call goes quickly to a competent agent, and is never assigned twice. | BF-09, BF-15 to BF-20, BF-33, BF-40, BF-47, BF-48, BNF-03 |
| E5 | Real-time supervision | The supervisor sees agents and queues live, without refreshing the page. | BF-10, BF-14, BF-22 to BF-26, BF-44, BNF-13 |
| E6 | SLA and alerts | Service level problems are seen during the day, not after it. | BF-28 to BF-32, BF-42, BF-43 |
| E7 | Statistics and history | Past activity can be analyzed by agent, team, queue and period. | BF-33 to BF-37, BF-39, BF-45, BNF-26 |
| E8 | DevOps platform | Every commit is built, tested, scanned, deployed and observed automatically. | BNF-01, BNF-02, BNF-04, BNF-08 to BNF-12, BNF-14 to BNF-25, BNF-27 to BNF-29, OBJ-T01 to OBJ-T06 |

## 3. Story summary

| ID | Title | Epic | MoSCoW | Points | Sprint |
|----|-------|------|--------|-------:|--------|
| US-01 | Log in with email and password | E1 | Must | 5 | S1 |
| US-02 | Log out (deferred while on call) | E1 | Must | 2 | S3 |
| US-03 | Protect every route with JWT and roles (RBAC) | E1 | Must | 3 | S1 |
| US-04 | Manage user accounts and roles | E1 | Must | 5 | S2 |
| US-05 | Change my own password | E1 | Should | 2 | Overflow |
| US-06 | Lock an account after repeated failures | E1 | Could | 2 | — |
| US-07 | Manage teams and skills (reference story) | E2 | Must | 3 | S2 |
| US-08 | Assign agents to a team and skills | E2 | Must | 3 | S2 |
| US-09 | Manage queues (with soft delete) | E2 | Must | 5 | S2 |
| US-10 | Set queue priority | E2 | Should | 3 | S6 |
| US-11 | Change my own status | E3 | Must | 3 | S2 |
| US-12 | Refuse invalid status transitions | E3 | Must | 3 | S2 |
| US-13 | Record status history | E3 | Must | 2 | S2 |
| US-14 | Force an agent's status | E3 | Should | 3 | S5 |
| US-15 | Give a break reason | E3 | Could | 2 | — |
| US-16 | Wrap-up status after a call | E3 | Could (out of MVP) | 3 | — |
| US-17 | Generate simulated calls | E4 | Must | 5 | S3 |
| US-18 | Control the generator at runtime | E4 | Should | 2 | Overflow |
| US-19 | Call lifecycle | E4 | Must | 3 | S2 |
| US-20 | Skill-based assignment | E4 | Must | 5 | S3 |
| US-21 | Longest-idle strategy (Strategy + Factory) | E4 | Must | 3 | S3 |
| US-22 | Round-robin strategy | E4 | Should | 2 | S5 |
| US-23 | Event-driven dispatch under 500 ms, no double assignment | E4 | Must | 5 | S3 |
| US-24 | Abandon after queue patience | E4 | Should | 3 | S5 |
| US-25 | Most-skilled strategy with skill levels | E4 | Could | 3 | — |
| US-26 | VIP call marker | E4 | Could (out of MVP) | 2 | — |
| US-27 | Authenticated real-time hub | E5 | Must | 3 | S3 |
| US-28 | Agent counters and agent list | E5 | Must | 5 | S3 |
| US-29 | Waiting calls per queue with timer | E5 | Must | 3 | S4 |
| US-30 | See my current call | E5 | Should | 2 | S6 |
| US-31 | Automatic real-time reconnection | E5 | Must | 3 | S4 |
| US-32 | Filter the dashboard by team and queue | E5 | Should | 2 | Overflow |
| US-33 | Read-only dashboard for the administrator | E5 | Could | 2 | — |
| US-34 | Configure SLA per queue | E6 | Must | 2 | S4 |
| US-35 | Compute the daily SLA rate | E6 | Must | 5 | S4 |
| US-36 | Show the SLA level (green, orange, red, N/A) | E6 | Must | 3 | S4 |
| US-37 | Sliding-window SLA rate | E6 | Should | 3 | S6 |
| US-38 | Notify the supervisor on red | E6 | Should | 2 | S5 |
| US-39 | Audit SLA parameter changes | E6 | Should | 2 | S6 |
| US-40 | Daily SLA history | E6 | Could | 2 | — |
| US-41 | Paginated call history | E7 | Must | 3 | S4 |
| US-42 | Filter the call history | E7 | Should | 2 | Overflow |
| US-43 | Agent statistics | E7 | Must | 3 | S4 |
| US-44 | Team and period statistics | E7 | Should | 3 | Overflow |
| US-45 | Trend charts | E7 | Could | 3 | — |
| US-46 | Purge history after 90 days | E7 | Should | 2 | Overflow |
| US-47 | Agent's own statistics | E7 | Could (out of MVP) | 2 | — |
| US-48 | Layered backend skeleton with architecture tests | E8 | Must | 3 | S1 |
| US-49 | Frontend skeleton (Vite, ESLint, French labels) | E8 | Must | 2 | S1 |
| US-50 | Docker Compose environment | E8 | Must | 5 | S1 |
| US-51 | Jenkins CI v1 (build, tests, lint, gitleaks) | E8 | Must | 5 | S1 |
| US-52 | SonarQube quality gate and coverage | E8 | Must | 3 | S4 |
| US-53 | Trivy image scan | E8 | Must | 2 | S4 |
| US-54 | Integration tests with Testcontainers | E8 | Must | 2 | S1 |
| US-55 | k6 load tests in the pipeline | E8 | Must | 3 | S5 |
| US-56 | Playwright end-to-end tests | E8 | Could | 5 | — |
| US-57 | Kubernetes deployment with Helm | E8 | Must | 5 | S5 |
| US-58 | Prometheus metrics and Grafana dashboard | E8 | Must | 3 | S5 |
| US-59 | Alertmanager rules (SLA, API down) | E8 | Must | 3 | S5 |
| US-60 | Structured logs with correlation ID | E8 | Must | 2 | S1 |
| US-61 | Log collection with Loki | E8 | Could | 2 | — |
| US-62 | Security hardening and OWASP ZAP scan | E8 | Should | 3 | Overflow |
| US-63 | Provision the environment with Ansible | E8 | Should | 3 | Overflow |
| US-64 | Production deployment with rollback | E8 | Must | 3 | S6 |
| US-65 | GitOps deployment with ArgoCD | E8 | Could | 3 | — |
| US-66 | GitHub Actions comparison pipeline | E8 | Could | 2 | — |
| US-67 | HTTPS with cert-manager | E8 | Should | 2 | Overflow |
| US-68 | Deploy automatically to the test environment | E8 | Must | 3 | S5 |

## 4. Story details

### E1 — Access and security

#### US-01 — Log in with email and password

As an **Agent, Supervisor or Administrator**, I want to log in with my email and password so that I reach the screen of my role.
**E1 · Must · 5 pts · S1 · Sources:** BF-01, BNF-05, BNF-06

1. **Given** an active account with valid credentials, **when** the user logs in, **then** the API returns a JWT that expires in 60 minutes or less, and the UI opens the screen of the user's role.
2. *(error)* **Given** an unknown email or a wrong password, **when** the user logs in, **then** the API answers 401 with the same generic message in both cases, no token is issued, and the UI shows the message.
3. **Given** a newly created account, **when** the users table is read, **then** the password column contains only a salted hash (ASP.NET Core Identity, PBKDF2) and never the plain password.

**Tasks:** ASP.NET Core Identity setup · login endpoint and JWT issuing · login page · integration tests (401, token lifetime, no plain password).

#### US-02 — Log out (deferred while on call)

As an **Agent**, I want to log out so that I am no longer counted as present, without breaking a call in progress.
**E1 · Must · 2 pts · S3 · Sources:** BF-02, RG-07

1. **Given** an agent who is Available or On break, **when** they log out, **then** the System sets them Offline immediately, and opening a protected page redirects to the login screen.
2. *(edge)* **Given** an agent who is On call, **when** they log out, **then** they stay On call until the call is Completed, and then become Offline instead of Available.
3. **Given** a deferred logout that has just been applied, **when** the status history is read, **then** it contains On call → Offline with the actor System.

**Tasks:** logout endpoint · "pending logout" flag on the agent · frontend token removal and redirect · unit tests on RG-07.

#### US-03 — Protect every route with JWT and roles (RBAC)

As an **Administrator**, I want every API route to require a valid token and an allowed role so that no one reaches data outside their role.
**E1 · Must · 3 pts · S1 · Sources:** BF-04, BNF-05, BNF-07

1. *(error)* **Given** no token or an expired token, **when** any route other than login, `/health/live` and `/health/ready` is called, **then** the API answers 401.
2. *(error)* **Given** an Agent token, **when** the agent opens the supervisor dashboard or an administration route, **then** the API answers 403 and the UI shows an access-denied page.
3. **Given** the rights matrix of specification section 6.2, **when** the automated role × route test runs, **then** 100 % of the routes are covered and each answers 2xx or 403 as expected, and a route without a role declaration fails the test.

**Tasks:** authorization policies per role · route guard in React · parameterized role × route integration test.

#### US-04 — Manage user accounts and roles

As an **Administrator**, I want to create, edit and deactivate accounts and give them a role so that only known staff can use CallPulse.
**E1 · Must · 5 pts · S2 · Sources:** BF-03, RG-02, RG-07

1. **Given** an administrator, **when** they create an account with the role Agent, **then** the account can log in with that role, and the new agent appears Offline (RG-02).
2. *(edge)* **Given** an agent account that is On call, **when** the administrator deactivates it, **then** the agent becomes Offline at the end of the call, and any later login attempt is refused with 401.
3. *(error)* **Given** an email that is already used, **when** the administrator creates an account with it, **then** the API answers 409 and no account is created.

**Tasks:** account CRUD endpoints · role assignment · administration screens · deactivation hook calling the RG-07 logic · tests.

#### US-05 — Change my own password

As a **user (any role)**, I want to change my password so that I can keep my account safe.
**E1 · Should · 2 pts · Overflow · Sources:** BF-05

1. **Given** a logged-in user who gives the correct current password, **when** they set a new password, **then** the old password is refused and the new one is accepted at the next login.
2. *(error)* **Given** a wrong current password, **when** the change is submitted, **then** it is refused and the password stays unchanged.
3. *(error)* **Given** a new password that breaks the Identity password policy, **when** the change is submitted, **then** it is refused with a message in French that explains the rule.

**Tasks:** change-password endpoint · form · integration tests.

#### US-06 — Lock an account after repeated failures

As an **Administrator**, I want an account locked for a while after repeated failed logins so that passwords cannot be guessed by brute force.
**E1 · Could · 2 pts · — · Sources:** BF-06

1. **Given** 5 consecutive failed logins *(proposed value; the specification does not define one)*, **when** the correct password is given during the lockout, **then** the login is refused.
2. **Given** that the lockout (proposed: 15 min) has expired, **when** the correct password is given, **then** the login succeeds and the failure counter is reset.
3. *(edge)* **Given** 4 failures followed by a success, **when** the user fails again, **then** the counter starts again from 1.

**Tasks:** enable Identity lockout options · tests with an injectable clock.

### E2 — Reference data

#### US-07 — Manage teams and skills (reference story)

As an **Administrator**, I want to create and edit teams and skills so that I can describe how my call center is organized.
**E2 · Must · 3 pts · S2 · Sources:** BF-12

1. **Given** an administrator, **when** they create the team "Facturation" and the skill "Billing", **then** both are listed and can be selected for agents and queues.
2. *(error)* **Given** a team or skill name that already exists, **when** the administrator creates it again, **then** the API answers 409 and no duplicate is created.
3. *(error)* **Given** a Supervisor or Agent token, **when** the create endpoint is called, **then** the API answers 403.

**Tasks:** Team and Skill entities, EF Core migration · CRUD endpoints · admin screens · tests.

#### US-08 — Assign agents to a team and skills

As an **Administrator**, I want to put each agent in a team and give them skills so that routing sends them only calls they can handle.
**E2 · Must · 3 pts · S2 · Sources:** BF-12, RG-18, RG-24

1. **Given** a call Waiting in a queue that requires skill S, and an Available agent of the queue's team without S, **when** the administrator adds S to the agent, **then** the call is assigned to that agent by the dispatch the change triggers, without a restart (RG-24).
2. *(edge)* **Given** an Available agent who has skill S but belongs to another team than the queue's, **when** a call arrives in the queue, **then** the call is not assigned to that agent (RG-18).
3. *(edge)* **Given** an agent On call for a queue that requires S, **when** the administrator removes S from the agent, **then** the current call continues, and the agent is no longer eligible for the next calls that require S.

**Tasks:** Agent–Team and Agent–Skill relations · assignment endpoints and screen · "agent configuration changed" domain event · tests.

#### US-09 — Manage queues (with soft delete)

As an **Administrator**, I want to create, edit and delete queues, each linked to a skill and a team, so that calls are grouped by need.
**E2 · Must · 5 pts · S2 · Sources:** BF-13, BF-14, RG-42, RG-43, RG-44

1. **Given** an administrator, **when** they create a queue with a required skill and a team, **then** the queue gets the defaults of section 7.1 (PRIO = 2, STRAT = longest idle, T = 20 s, O = 80 %, N = 10, P = 120 s, F = 30 min), appears on the dashboard, and receives its calls.
2. *(error)* **Given** a queue with a call that is Waiting, Assigned or InProgress, **when** the administrator deletes it, **then** the API answers 409 `FILE_NON_VIDE` and the queue is unchanged (RG-42).
3. **Given** an empty queue, **when** the administrator deletes it, **then** the queue is deactivated, its past calls stay in the history and statistics, and any new call for it is refused (RG-43, RG-44).

**Tasks:** Queue entity with an `IsActive` flag · CRUD endpoints · admin screen · integration test for the 409 · test with at least 3 active queues (BF-14).

#### US-10 — Set queue priority

As an **Administrator**, I want to give each queue a priority from 1 to 3 so that the most important calls are served first.
**E2 · Should · 3 pts · S6 · Sources:** BF-41, RG-26, RG-27, RG-28

1. *(error)* **Given** a priority of 0 or 4, **when** the queue is saved, **then** the API answers 400 and the stored priority is unchanged (RG-26).
2. **Given** one agent eligible for queues of priority 1 and 2, each with one Waiting call, **when** the agent becomes Available, **then** they receive the call of the priority 1 queue (RG-27).
3. *(edge)* **Given** two queues with the same priority and one Waiting call each, **when** an eligible agent becomes Available, **then** they receive the call that has waited longest, and, if both arrived at the same instant, the call of the queue with the smaller ID (RG-28).

**Tasks:** priority field and validation · ordering of waiting calls in the dispatcher · unit tests.

### E3 — Agent statuses

#### US-11 — Change my own status

As an **Agent**, I want to see my status and change it in one click so that I receive calls only when I am ready.
**E3 · Must · 3 pts · S2 · Sources:** BF-07, BF-08, RG-01, RG-02

1. **Given** an agent who has just logged in, **when** the agent screen opens, **then** it shows Offline, the same status that is stored on the server (RG-02).
2. **Given** an agent who is Offline, **when** they click Available, **then** the server stores Available, and the agent screen and the status API both return Available.
3. *(error)* **Given** an agent whose change is refused by the server (for example `APPEL_EN_COURS`), **when** they click On break, **then** the screen keeps the current status and shows the reason in French.

**Tasks:** status change endpoint · agent screen with three buttons · error code to French message mapping · tests.

#### US-12 — Refuse invalid status transitions

As a **Supervisor**, I want invalid status changes to be refused with a precise code so that the statuses I see are always reliable.
**E3 · Must · 3 pts · S2 · Sources:** BF-08, BF-27, RG-03, RG-05, RG-08

1. *(error)* **Given** an Available agent, **when** the agent asks for Available, **then** the change is refused with `STATUT_IDENTIQUE` and the status is unchanged.
2. *(error)* **Given** an agent On call, **when** the agent or a supervisor asks for On break, **then** the change is refused with `APPEL_EN_COURS`, because rule 1 of the evaluation order comes before `TRANSITION_INVALIDE` (RG-05).
3. *(error)* **Given** an Offline agent, **when** a supervisor asks for Available, **then** the change is refused with `ACTEUR_NON_AUTORISE` (RG-08), and **when** the agent asks for On call, **then** it is refused with `TRANSITION_INVALIDE`.

**Tasks:** table-driven state machine in the Domain layer · parameterized unit tests over the 16 cells × actors · evaluation order as a single function.

#### US-13 — Record status history

As a **Supervisor**, I want every accepted status change to be recorded so that time in status and statistics are correct.
**E3 · Must · 2 pts · S2 · Sources:** BF-23, RG-09, RG-10, BNF-28

1. **Given** an accepted change, **when** it is saved, **then** a record holds the agent, the old status, the new status, the actor and a UTC timestamp (`timestamptz`).
2. *(edge)* **Given** a refused change, **when** it is processed, **then** no record is written (RG-09).
3. *(edge)* **Given** an agent Available since 10:00:00 and a `STATUT_IDENTIQUE` refusal at 10:05:00 (injectable clock), **when** time in status is read at 10:05:30, **then** it is 5 min 30 s and not 30 s (RG-10).

**Tasks:** StatusChange entity and migration · write in the same transaction as the change · unit tests with an injectable clock.

#### US-14 — Force an agent's status

As a **Supervisor**, I want to force the status of an agent (for example Offline when they left without logging out) so that the dashboard matches reality.
**E3 · Should · 3 pts · S5 · Sources:** BF-27, RG-08

1. **Given** an Available agent, **when** a supervisor forces Offline, **then** the change is applied, the history records the actor Supervisor, and the agent screen shows a message in less than 1 s.
2. *(error)* **Given** an Offline agent, **when** a supervisor forces Available, **then** it is refused with `ACTEUR_NON_AUTORISE`.
3. *(error)* **Given** an agent On call, **when** a supervisor forces Offline, **then** it is refused with `APPEL_EN_COURS`.

**Tasks:** force endpoint (Supervisor role only) · button on the agent list · push to the agent through the hub · tests.

#### US-15 — Give a break reason

As an **Agent**, I want to give a reason when I go On break so that my supervisor knows why I am away.
**E3 · Could · 2 pts · — · Sources:** BF-11

1. **Given** an agent going On break, **when** they choose "Repas", **then** the reason is stored and shown to the supervisor.
2. *(error)* **Given** an unknown reason code, **when** it is sent, **then** the API answers 400 and the status is unchanged.
3. *(edge)* **Given** an agent On break with a reason, **when** they become Available, **then** the reason is cleared.

**Tasks:** reason list · optional field on the status change · display on the dashboard.

#### US-16 — Wrap-up status after a call

As an **Agent**, I want a short wrap-up time after each call so that I can finish my notes before the next call.
**E3 · Could (out of MVP) · 3 pts · — · Sources:** BF-46

1. **Given** a configured wrap-up time, **when** a call ends, **then** the agent is in wrap-up for that time, and then Available.
2. *(edge)* **Given** an agent in wrap-up, **when** a call arrives, **then** the agent is not eligible.
3. *(edge)* **Given** a deferred logout, **when** the call ends, **then** the agent goes directly to Offline, without wrap-up *(proposed)*.

**Tasks:** not planned; would require a fifth status and a change to the transition table.

### E4 — Calls and routing

#### US-17 — Generate simulated calls

As an **Administrator**, I want a traffic generator with a rate and a mean duration per queue so that the platform can be tested without a real phone system.
**E4 · Must · 5 pts · S3 · Sources:** BF-15, RG-12, RG-44

1. **Given** a rate of 6 calls/min on queue Q, **when** the generator runs for 10 minutes, **then** it creates between 54 and 66 calls, each in Q, with Q's skill, and with an arrival instant equal to its move to Waiting (RG-12).
2. *(error)* **Given** an Agent or Supervisor token, **when** the generator settings are modified, **then** the API answers 403.
3. *(edge)* **Given** a deactivated queue, **when** the generator runs, **then** it creates no call for that queue, and a direct call creation for it is refused (RG-44).

**Tasks:** generator as a hosted background service · per-queue settings (rate, mean duration) · random arrival and duration distribution with a fixed seed in tests · tests.

#### US-18 — Control the generator at runtime

As an **Administrator**, I want to start, stop and change the generator without a restart so that I can play scenarios during a demo.
**E4 · Should · 2 pts · Overflow · Sources:** BF-16

1. **Given** a running generator, **when** the administrator changes the rate, **then** the new rate applies in less than 10 s without a restart.
2. **Given** a running generator, **when** the administrator stops it, **then** no new call is created, and existing calls continue their lifecycle.
3. *(error)* **Given** a negative rate, **when** it is saved, **then** the API answers 400 and the previous settings are kept.

**Tasks:** start, stop and update endpoints · settings reload without restart · admin screen.

#### US-19 — Call lifecycle

As the **System**, I want each call to follow only the allowed states so that history and SLA are based on consistent data.
**E4 · Must · 3 pts · S2 · Sources:** BF-09, BF-33, RG-11, RG-13, RG-14, RG-17

1. **Given** a call that becomes Assigned, **when** the assignment is processed, **then** the call becomes InProgress in the same transaction with that instant as the answer time (RG-13), and becomes Completed when its simulated duration has elapsed (RG-14).
2. *(error)* **Given** a Completed or Abandoned call, **when** any transition is requested (for example Completed → InProgress), **then** it is refused (RG-11).
3. **Given** a call that reaches a final state, **when** it is saved, **then** the history holds its date, queue, agent (empty if abandoned), wait time, duration and outcome (RG-17).

**Tasks:** Call aggregate with a state machine · unit tests per transition · completion timer.

#### US-20 — Skill-based assignment

As the **System**, I want to assign each call to an eligible agent so that every call reaches someone who can handle it.
**E4 · Must · 5 pts · S3 · Sources:** BF-09, BF-17, BF-18, RG-04, RG-06, RG-18, RG-19, RG-25

1. **Given** queue Q (skill S, team T) and agents A1 (Available, S, T), A2 (Available, no S) and A3 (On break, S, T), **when** a call arrives in Q, **then** it is assigned to A1, A1 becomes On call with the actor System (RG-04), and A1 becomes Available again when the call is Completed (RG-06).
2. *(edge)* **Given** no eligible agent, **when** a call arrives, **then** it stays Waiting, and **when** A3 becomes Available, **then** the call is assigned to A3 (BF-18).
3. *(edge)* **Given** two Waiting calls C1 (older) and C2 in Q and one eligible agent, **when** the agent becomes Available, **then** they receive C1 (FIFO, RG-19) and never C2 while they are On call (RG-25).

**Tasks:** eligibility query · dispatcher service · domain events for status changes · test on a sample of 100 calls (100 % with the required skill).

#### US-21 — Longest-idle strategy (Strategy + Factory)

As a **Supervisor**, I want calls to go to the agent who has been idle the longest so that work is shared fairly.
**E4 · Must · 3 pts · S3 · Sources:** BF-19, RG-20, RG-21, RG-23

1. **Given** eligible agents A (Available since 10:00) and B (Available since 10:05), **when** a call arrives, **then** it is assigned to A (RG-21).
2. *(edge)* **Given** two eligible agents who became Available at the same instant, **when** a call arrives, **then** it is assigned to the agent with the smaller ID (RG-23).
3. *(edge)* **Given** a queue created without a strategy, **when** its strategy is built, **then** the Factory returns the longest-idle strategy, and an unknown STRAT value is refused at save time.

**Tasks:** `IRoutingStrategy` interface · `RoutingStrategyFactory` · LongestIdle implementation · isolated unit tests.

#### US-22 — Round-robin strategy

As an **Administrator**, I want to choose round robin for a queue so that calls rotate between agents in a fixed order.
**E4 · Should · 2 pts · S5 · Sources:** BF-48, RG-22 — *second strategy: demonstrates the Strategy pattern, cut last*

1. **Given** eligible agents with IDs 3, 5 and 9, and 5 as the last agent served by the queue, **when** a call arrives, **then** it is assigned to 9.
2. *(edge)* **Given** 9 as the last agent served, **when** a call arrives, **then** it is assigned to 3 (wrap-around).
3. *(edge)* **Given** a queue that has never served anyone, **when** a call arrives, **then** it goes to 3, and two queues with different strategies each distribute calls according to their own strategy (automated test).

**Tasks:** RoundRobin implementation · "last served agent" per queue · strategy selection on the queue screen.

#### US-23 — Event-driven dispatch under 500 ms, no double assignment

As the **System**, I want to dispatch calls as soon as an event happens, with a safety cycle, so that calls are assigned quickly and never twice.
**E4 · Must · 5 pts · S3 · Sources:** BNF-03, RG-24, RG-37

1. **Given** an eligible agent already Available, **when** a call is created, **then** it becomes Assigned in less than 500 ms at the 95th percentile, as measured by the assignment-delay metric under nominal load.
2. *(edge)* **Given** a Waiting call whose trigger event was lost (simulated in a test), **when** the safety cycle runs, **then** the call is assigned within R = 1 s.
3. *(edge)* **Given** a concurrency test that starts parallel dispatches on the same calls and agents, **when** they finish, **then** each call is assigned at most once and each agent holds at most one call (RG-37).

**Tasks:** in-process event channel (Observer) · safety-cycle hosted service · optimistic concurrency or row locking in PostgreSQL · assignment-delay histogram · concurrency integration test.

#### US-24 — Abandon after queue patience

As the **System**, I want a waiting call to be abandoned when it reaches the queue patience P so that the simulation shows realistic hang-ups.
**E4 · Should · 3 pts · S5 · Sources:** BF-20, RG-15, RG-31

1. **Given** P = 120 s and a Waiting call, **when** its wait reaches 120 s, **then** it becomes Abandoned, leaves the queue, and is recorded as outside threshold (RG-31).
2. *(edge)* **Given** a call that reaches P in the same dispatcher cycle in which an agent becomes Available, **when** the cycle runs, **then** the abandon is processed first and the call is not assigned (RG-15).
3. *(error)* **Given** an administrator who sets P to 0 or a negative value, **when** the queue is saved, **then** the API answers 400, and a valid new P applies only to later calls.

**Tasks:** patience field per queue · abandon step in the dispatcher cycle · unit tests with an injectable clock.

#### US-25 — Most-skilled strategy with skill levels

As an **Administrator**, I want agents to have a level per skill and a "most skilled" strategy so that hard calls go to experts.
**E4 · Could · 3 pts · — · Sources:** BF-40

1. **Given** two eligible agents with levels 2 and 4, **when** a call arrives, **then** it goes to the level 4 agent.
2. *(edge)* **Given** two agents with the same level, **when** a call arrives, **then** it goes to the smaller ID (RG-23).
3. *(error)* **Given** a level outside 1 to 5 *(proposed scale)*, **when** it is saved, **then** the API answers 400.

**Tasks:** level on Agent–Skill · new strategy registered in the Factory (shows the Open/Closed benefit).

#### US-26 — VIP call marker

As a **Supervisor**, I want VIP calls to pass in front of other calls in their queue so that key customers wait less.
**E4 · Could (out of MVP) · 2 pts · — · Sources:** BF-47

1. **Given** two normal Waiting calls, **when** a VIP call arrives in the same queue, **then** it is assigned first.
2. *(edge)* **Given** two VIP calls, **when** an agent is free, **then** they are served in arrival order.
3. *(edge)* **Given** a VIP call in a priority 2 queue and a normal call in a priority 1 queue, **when** an agent eligible for both is free, **then** queue priority still wins *(proposed)*.

**Tasks:** not planned.

### E5 — Real-time supervision

#### US-27 — Authenticated real-time hub

As a **Supervisor**, I want a secure real-time connection so that I receive live updates and nobody else does.
**E5 · Must · 3 pts · S3 · Sources:** BF-25, BNF-05, BNF-07

1. **Given** a Supervisor JWT, **when** the client connects to the supervision hub, **then** the connection is accepted and receives status and queue events.
2. *(error)* **Given** no token or an expired token, **when** the client connects, **then** the connection is refused with 401.
3. *(error)* **Given** an Agent token, **when** the client joins the supervision group, **then** it is refused, and the agent receives only events about themselves.

**Tasks:** SignalR hub with JWT from the query string · role-based groups · React hub client service.

#### US-28 — Agent counters and agent list

As a **Supervisor**, I want live counters per status and the list of agents with time in status so that I see my team's availability at a glance.
**E5 · Must · 5 pts · S3 · Sources:** BF-22, BF-23, BF-25, RG-01, RG-10

1. **Given** 3 Available, 2 On call, 1 On break and 4 Offline agents, **when** the dashboard opens, **then** the counters show 3 / 2 / 1 / 4 and their sum equals the number of agents (RG-01).
2. **Given** an open dashboard, **when** an agent changes status, **then** the counters and the list update without a page refresh.
3. *(edge)* **Given** an agent Available since 10:00:00, **when** the list is viewed at 10:02:30, **then** it shows 2 min 30 s and keeps counting, and a `STATUT_IDENTIQUE` refusal does not reset it.

**Tasks:** snapshot endpoint · status-changed broadcast · counters and list components · client-side timer from the server timestamp.

#### US-29 — Waiting calls per queue with timer

As a **Supervisor**, I want to see, for each queue, the number of waiting calls and the longest wait so that I spot saturated queues at once.
**E5 · Must · 3 pts · S4 · Sources:** BF-14, BF-24, RG-16

1. **Given** 3 queues with 2, 0 and 5 Waiting calls, **when** the dashboard opens, **then** each queue is shown separately with its own count.
2. **Given** an oldest Waiting call that arrived 45 s ago, **when** the panel is viewed, **then** the longest wait shows 45 s and increases every second.
3. *(edge)* **Given** a queue whose last Waiting call is assigned or abandoned, **when** the event arrives, **then** the count shows 0 and the longest wait shows "—".

**Tasks:** queue state broadcast · queue panel component · tests.

#### US-30 — See my current call

As an **Agent**, I want to see the queue and wait time of the call I am handling so that I know the context of the customer.
**E5 · Should · 2 pts · S6 · Sources:** BF-10

1. **Given** a call assigned to the agent, **when** the agent screen updates, **then** it shows the queue name and the wait time of the call, fixed at the answer time.
2. **Given** a Completed call, **when** the event arrives, **then** the call panel disappears and the status shows Available.
3. *(edge)* **Given** an agent with no call, **when** the screen opens, **then** it shows "Aucun appel en cours".

**Tasks:** per-agent hub event · call panel on the agent screen.

#### US-31 — Automatic real-time reconnection

As a **Supervisor**, I want the dashboard to reconnect by itself after a network cut so that I never look at stale data.
**E5 · Must · 3 pts · S4 · Sources:** BNF-13

1. **Given** a 5 s network cut, **when** the network comes back, **then** the client reconnects in less than 10 s without a page reload, and a "reconnecting" banner is shown during the cut.
2. *(edge)* **Given** status changes that happened during the cut, **when** the client reconnects, **then** it reloads the snapshot and shows the current state, with no stale counter.
3. *(error)* **Given** a token that expired during the cut, **when** the client reconnects, **then** the user is sent to the login screen.

**Tasks:** `withAutomaticReconnect` · snapshot reload on `onreconnected` · banner component.

#### US-32 — Filter the dashboard by team and queue

As a **Supervisor**, I want to filter the dashboard by team and queue so that I can focus on the group I manage.
**E5 · Should · 2 pts · Overflow · Sources:** BF-26

1. **Given** a filter on team T, **when** it is applied, **then** only the agents of T and the queues linked to T are shown, and the counters are computed on that subset.
2. **Given** a filter on queue Q, **when** it is applied, **then** only Q and the agents of Q's team who have Q's skill are shown.
3. *(edge)* **Given** a filter that matches nothing, **when** it is applied, **then** an empty-state message is shown instead of an empty table.

**Tasks:** filter bar · client-side filtering of the snapshot and of events.

#### US-33 — Read-only dashboard for the administrator

As an **Administrator**, I want read-only access to the dashboard and statistics so that I can check the effect of my configuration.
**E5 · Could · 2 pts · — · Sources:** BF-44 (Could since Day 4; the rights matrix gives the administrator 403 until it is delivered)

1. **Given** an Administrator token, **when** they open the dashboard, **then** it is displayed with live updates.
2. *(error)* **Given** an Administrator token, **when** a status-forcing request is sent, **then** the API answers 403, and the UI does not show the force button.
3. **Given** an Administrator token, **when** they open the statistics, **then** they are displayed, while the same request with an Agent token answers 403.

**Tasks:** extend the read policies to the Administrator role · hide write actions in the UI.

### E6 — SLA and alerts

#### US-34 — Configure SLA per queue

As an **Administrator**, I want to set the SLA target of each queue (T, O, N, F) so that each queue is measured against its own commitment.
**E6 · Must · 2 pts · S4 · Sources:** BF-28, RG-40

1. **Given** a new queue, **when** it is created, **then** its SLA settings are T = 20 s, O = 80 %, N = 10 points, F = 30 min.
2. **Given** an administrator who sets O = 90 % and T = 15 s, **when** the change is saved, **then** O applies at once to the level, and T applies only to calls counted afterwards (RG-40).
3. *(error)* **Given** O > 100, T ≤ 0, N < 0 or F ≤ 0, **when** the change is saved, **then** the API answers 400 and nothing changes.

**Tasks:** SLA fields on Queue · validation · SLA section of the queue screen.

#### US-35 — Compute the daily SLA rate

As a **Supervisor**, I want the SLA rate of each queue for the current day so that I know whether we keep our commitment.
**E6 · Must · 5 pts · S4 · Sources:** BF-29, RG-29, RG-30, RG-31, RG-32, RG-38, RG-39, BNF-28

1. **Given** the worked example of section 7.6 (45 answered, of which 38 under 20 s; 5 abandoned; 3 still Waiting), **when** the rate is computed, **then** it is 38 / 50 = 76.0 %.
2. *(edge)* **Given** a call answered at exactly 20.0 s, **when** it is counted, **then** it is outside threshold, and this stored result does not change if T is later set to 25 s (RG-29, RG-39).
3. *(edge)* **Given** Z = Europe/Paris, **when** a call is answered at 2026-10-11 23:30 UTC (01:30 in Paris), **then** it counts for the day of 2026-10-12, not 2026-10-11 (RG-38).

**Tasks:** "within threshold" result and T stored on the call · SQL query on the day range converted to UTC · unit tests on the worked example and the boundary cases.

#### US-36 — Show the SLA level (green, orange, red, N/A)

As a **Supervisor**, I want a colored badge per queue so that I see at a glance which queues are in trouble.
**E6 · Must · 3 pts · S4 · Sources:** BF-30, RG-34, RG-35

1. **Given** O = 80 % and N = 10, **when** the rates are 82 %, 75 % and 69 %, **then** the badges are green, orange and red.
2. *(edge)* **Given** the boundaries 40/50 = 80 %, 35/50 = 70 %, 34/50 = 68 % and 1749/2500 = 69.96 %, **when** levels are computed, **then** they are green, orange, red, and red (the comparison uses the raw value, although the display shows 70.0 %).
3. *(edge)* **Given** a queue with no counted call today, **when** the dashboard shows it, **then** the rate is "N/A" with a grey badge and no notification (RG-35).

**Tasks:** `SlaLevel` pure function in Domain · badge component · broadcast on every counted call.

#### US-37 — Sliding-window SLA rate

As a **Supervisor**, I want the SLA rate of the last F minutes as well so that I see recent trends that the daily rate hides.
**E6 · Should · 3 pts · S6 · Sources:** BF-42, RG-33, RG-36, RG-40

1. **Given** F = 30 min and the time 10:00, **when** the window rate is computed, **then** a call counted at 09:31 is included and a call counted at 09:29 is not.
2. **Given** an administrator who changes F from 30 to 60 min, **when** the change is saved, **then** the displayed window rate changes immediately (RG-40).
3. *(edge)* **Given** a red window level and a green daily level, **when** the dashboard updates, **then** the window badge is red, and no notification or alert is sent (RG-36).

**Tasks:** window query · second badge · periodic refresh because the window moves.

#### US-38 — Notify the supervisor on red

As a **Supervisor**, I want a visible notification when a queue turns red so that I react at once.
**E6 · Should · 2 pts · S5 · Sources:** BF-31, RG-36

1. **Given** a queue whose daily level goes from orange to red, **when** the event is broadcast, **then** a notification appears on the dashboard in less than 1 s.
2. *(edge)* **Given** a queue whose daily level goes from green to orange, **when** the event is broadcast, **then** only the badge changes and no notification appears.
3. *(edge)* **Given** a queue with no counted call (N/A), **when** the dashboard updates, **then** no notification appears (RG-35).

**Tasks:** level-change detection on the server · toast component.

#### US-39 — Audit SLA parameter changes

As an **Administrator**, I want every SLA parameter change to be logged so that I can explain later why a rate or level changed.
**E6 · Should · 2 pts · S6 · Sources:** BF-43, RG-41

1. **Given** an administrator who changes O from 80 to 90 on a queue, **when** the change is saved, **then** an audit entry holds the author, the UTC timestamp, the old value 80 and the new value 90.
2. *(edge)* **Given** a save with unchanged values, **when** it is processed, **then** no audit entry is written *(interpretation: not a modification)*.
3. *(error)* **Given** an invalid change refused with 400, **when** the audit log is read, **then** it contains no entry for it.

**Tasks:** SlaAuditEntry table · write in the same transaction · read endpoint for administrators.

#### US-40 — Daily SLA history

As a **Supervisor**, I want the SLA rate per day and per queue for past days so that I can compare days.
**E6 · Could · 2 pts · — · Sources:** BF-32

1. **Given** a past day, **when** the history is displayed, **then** each rate matches the calls of that day.
2. *(edge)* **Given** a day with no calls, **when** it is displayed, **then** it shows "N/A".
3. *(error)* **Given** a period longer than 31 days, **when** it is requested, **then** the API answers 400 (OBJ-05).

**Tasks:** aggregation query · table view.

### E7 — Statistics and history

#### US-41 — Paginated call history

As a **Supervisor**, I want the list of finished calls, page by page, so that I can check any call.
**E7 · Must · 3 pts · S4 · Sources:** BF-33, RG-16, RG-17

1. **Given** finished calls, **when** the history is opened, **then** each row shows date, queue, agent, wait time, duration and outcome.
2. *(edge)* **Given** 1,234 calls and a page size of 50, **when** pages are read, **then** there are 25 pages sorted by date, newest first, and a page beyond the last returns an empty list, not an error.
3. *(edge)* **Given** an abandoned call, **when** it is shown, **then** the agent is "—", the outcome is "Abandonné", and the wait time runs until the abandon (RG-16).

**Tasks:** paged endpoint with an index on date · history table component.

#### US-42 — Filter the call history

As a **Supervisor**, I want to filter the history by period, queue, agent and outcome so that I find the calls I am looking for.
**E7 · Should · 2 pts · Overflow · Sources:** BF-34

1. **Given** a filter on a period and a queue, **when** it is applied, **then** only the calls of that queue in that period are returned.
2. **Given** a combined filter on an agent and the outcome "Traité", **when** it is applied, **then** only that agent's handled calls are returned.
3. *(error)* **Given** an end date before the start date, or a period longer than 31 days, **when** it is requested, **then** the API answers 400.

**Tasks:** query parameters and validation · filter bar.

#### US-43 — Agent statistics

As a **Supervisor**, I want calls handled, average handling time and occupancy per agent so that I can coach my team.
**E7 · Must · 3 pts · S4 · Sources:** BF-35

1. **Given** an agent who handled 4 calls of 120, 180, 240 and 60 s in the period, **when** statistics are computed, **then** the count is 4 and the average handling time is 150 s.
2. **Given** an agent with 2 h of Available + On call time, of which 1.5 h On call, **when** occupancy is computed, **then** it is 75 % *(proposed definition: On call / (Available + On call); the specification does not define occupancy)*.
3. *(edge)* **Given** an agent with no call in the period, **when** statistics are computed, **then** the count is 0, and the average and occupancy show "—" instead of a division by zero.

**Tasks:** queries on call history and status history · statistics page · tests on a known data set.

#### US-44 — Team and period statistics

As a **Supervisor**, I want statistics per team and per queue by day or week so that I can see trends.
**E7 · Should · 3 pts · Overflow · Sources:** BF-36, BF-37

1. **Given** agent A (4 calls, average 150 s) and agent B (6 calls, average 100 s) in team T, **when** team statistics are computed, **then** T has 10 calls and an average of 120 s (weighted mean).
2. **Given** a queue and a week, **when** period statistics are computed, **then** volume, average wait, abandon rate and SLA rate equal the values computed from the history of that week.
3. *(error)* **Given** a period longer than 31 days, **when** it is requested, **then** the API answers 400.

**Tasks:** aggregation queries · day and week grouping in time zone Z.

#### US-45 — Trend charts

As a **Supervisor**, I want charts of volume, wait time and SLA over a period so that trends are easy to see.
**E7 · Could · 3 pts · — · Sources:** BF-39

1. **Given** a period, **when** the chart is displayed, **then** each point equals the matching value of the statistics table.
2. **Given** the metric selector, **when** the user switches from volume to SLA, **then** the chart shows the SLA series.
3. *(edge)* **Given** a period with no data, **when** the chart is displayed, **then** an empty-state message is shown.

**Tasks:** chart library choice (ADR) · chart component.

#### US-46 — Purge history after 90 days

As an **Administrator**, I want calls older than 90 days to be purged automatically so that storage stays under control.
**E7 · Should · 2 pts · Overflow · Sources:** BNF-26 (Should since Day 4)

1. **Given** a call dated 91 days ago and one dated 89 days ago, **when** the purge job runs, **then** the first is deleted and the second is kept.
2. *(edge)* **Given** a call dated exactly 90 days ago, **when** the job runs, **then** it is kept *(interpretation: "kept 90 days")*.
3. *(error)* **Given** a database error during the purge, **when** the job fails, **then** the error is logged, no partial delete is committed, and the next run purges normally.

**Tasks:** daily hosted job · transaction · integration test with Testcontainers.

#### US-47 — Agent's own statistics

As an **Agent**, I want to see my own statistics so that I can follow my performance.
**E7 · Could (out of MVP) · 2 pts · — · Sources:** BF-45

1. **Given** an agent, **when** they open their statistics, **then** the values equal the US-43 values for that agent.
2. *(error)* **Given** an agent, **when** they request another agent's statistics, **then** the API answers 403.
3. *(edge)* **Given** an agent with no calls, **when** they open the page, **then** they see zeros and "—".

**Tasks:** not planned.

### E8 — DevOps platform

#### US-48 — Layered backend skeleton with architecture tests

As a **Developer**, I want a layered solution with health probes and architecture tests so that the structure stays clean from the first commit.
**E8 · Must · 3 pts · S1 · Sources:** BNF-12, BNF-14, BNF-23, OBJ-T05

1. **Given** the Domain, Application, Infrastructure and Api projects plus test projects, **when** `dotnet build -warnaserror` runs, **then** it succeeds with 0 warnings.
2. *(error)* **Given** a Domain class that references Infrastructure, **when** the NetArchTest tests run, **then** they fail.
3. **Given** a running API, **when** `/health/live` and `/health/ready` are called, **then** they answer 200 in less than 100 ms, and `/health/ready` answers 503 if the database cannot be reached.

**Tasks:** solution and projects · `Directory.Build.props` (warnings as errors, nullable) · health checks · architecture test project.

#### US-49 — Frontend skeleton (Vite, ESLint, French labels)

As a **Developer**, I want a React + TypeScript skeleton with lint, tests and French labels so that the frontend starts clean.
**E8 · Must · 2 pts · S1 · Sources:** BNF-23, BNF-25

1. **Given** the skeleton, **when** `npm run lint`, `npm run build` and `npm test` (Vitest) run, **then** all three succeed with 0 errors.
2. *(error)* **Given** a lint error added on purpose, **when** `npm run lint` runs, **then** it exits with a non-zero code.
3. **Given** the login page, **when** it is displayed, **then** every visible label comes from a single French resource file.

**Tasks:** Vite project · ESLint and Prettier · Vitest · French label file · router and layout.

#### US-50 — Docker Compose environment

As a **Developer**, I want `docker compose up` to start the whole application so that anyone can run it from a fresh clone.
**E8 · Must · 5 pts · S1 · Sources:** BNF-11, BNF-17

1. **Given** a fresh clone, **when** `docker compose up` runs, **then** API, frontend, database and generator are all "healthy" in less than 3 minutes, with no manual step (migrations applied automatically, `.env.example` defaults).
2. *(edge)* **Given** a running stack, **when** `docker kill` stops the API, **then** it is healthy again in less than 30 s (`restart: unless-stopped`).
3. *(edge)* **Given** a database that is slow to start, **when** the stack starts, **then** the API waits for it (`depends_on: condition: service_healthy`) instead of crash-looping.

**Tasks:** multi-stage Dockerfiles (non-root) · `docker-compose.yml` with health checks · `.env.example` · README section.

#### US-51 — Jenkins CI v1 (build, tests, lint, gitleaks)

As a **Developer**, I want each push to `main` to be built and tested by Jenkins so that broken code is caught at once.
**E8 · Must · 5 pts · S1 · Sources:** BNF-08, BNF-23, BNF-29 (build and tests part), OBJ-T01

1. **Given** a push to `main` or a pull request, **when** Jenkins runs the `Jenkinsfile`, **then** it builds backend and frontend, runs unit tests and lint, publishes the test reports, and a pull-request run finishes in less than 10 minutes (BNF-29).
2. *(error)* **Given** a failing unit test, **when** the pipeline runs, **then** the stage is red and the pipeline fails.
3. *(error)* **Given** a fake secret committed on a test branch, **when** the gitleaks stage runs, **then** the pipeline fails.

**Tasks:** Jenkins in Docker (configuration as code) · declarative multibranch `Jenkinsfile` · gitleaks stage · stage timings · repository polling (GitHub webhook on Day 5 or later).

#### US-52 — SonarQube quality gate and coverage

As a **Developer**, I want a SonarQube quality gate in the pipeline so that quality is checked automatically, since I have no reviewer (CT-04).
**E8 · Must · 3 pts · S4 · Sources:** BNF-15, BNF-22

1. **Given** a build of `main`, **when** the analysis runs, **then** SonarQube receives the Coverlet coverage report and the gate result is shown in Jenkins.
2. *(error)* **Given** Domain line coverage below 70 %, **when** the pipeline runs, **then** it fails.
3. *(error)* **Given** a new bug, a new vulnerability or duplication of 3 % or more, **when** the gate is evaluated, **then** the pipeline fails.

**Tasks:** SonarQube container · scanner stage · `waitForQualityGate` · coverage threshold.

#### US-53 — Trivy image scan

As an **Ops engineer**, I want Docker images scanned for vulnerabilities so that no critical vulnerability is shipped.
**E8 · Must · 2 pts · S4 · Sources:** BNF-09

1. **Given** a build, **when** the images are built, **then** Trivy scans each one and the report is archived.
2. *(error)* **Given** an image with a CRITICAL vulnerability, **when** Trivy runs with `--severity CRITICAL --exit-code 1`, **then** the pipeline fails.
3. *(edge)* **Given** an image with only HIGH vulnerabilities, **when** Trivy runs, **then** the pipeline passes and the report lists them.

**Tasks:** Trivy stage · report archiving.

#### US-54 — Integration tests with Testcontainers

As a **Developer**, I want integration tests on a real PostgreSQL so that database behaviour (UTC, constraints, concurrency) is tested for real.
**E8 · Must · 2 pts · S1 · Sources:** BNF-28, OBJ-T04

1. **Given** the integration test project, **when** it runs locally or in Jenkins, **then** it starts a PostgreSQL container, runs the tests and removes the container.
2. **Given** a timestamp written in UTC, **when** it is read back from a session whose time zone is Asia/Tokyo, **then** it is the same instant, and a schema test finds no `timestamp without time zone` column.
3. *(error)* **Given** Docker is not available, **when** the tests run, **then** they fail with a clear message instead of being skipped.

**Tasks:** Testcontainers fixture · `WebApplicationFactory` · first UTC tests.

#### US-55 — k6 load tests in the pipeline

As an **Ops engineer**, I want automated nightly load tests so that performance targets are checked without slowing down pushes.
**E8 · Must · 3 pts · S5 · Sources:** BNF-02, BNF-03, BNF-04

1. *(error)* **Given** the nominal scenario (100 agents, 5 supervisors, 2 calls/s) in the nightly pipeline, **when** `http_req_duration p(95)<300` is not met, **then** the nightly job fails and reports it, and pushes to `main` are not blocked.
2. **Given** the headroom scenario (500 virtual users for 10 minutes), **when** k6 runs, **then** `http_req_failed rate<0.01` and `p(95)<500` pass.
3. **Given** a load run, **when** the assignment-delay metric is read from Prometheus, **then** its p95 is under 500 ms (BNF-03).

**Tasks:** k6 scripts · nightly Jenkins job (cron trigger) on the test environment · results archived.

#### US-56 — Playwright end-to-end tests

As a **Developer**, I want browser tests of the key flows so that real-time behaviour and browser support are proven.
**E8 · Could · 5 pts · — · Sources:** BNF-01, BNF-13, BNF-24, BNF-25 (Playwright verification, Could since Day 4)

1. **Given** a supervisor dashboard and an agent screen, **when** the agent changes status, **then** the change appears on the dashboard in less than 1 s (timestamps compared).
2. *(edge)* **Given** a simulated network cut, **when** the network comes back, **then** the dashboard reconnects in less than 10 s.
3. **Given** the suite, **when** it runs on Chromium and Firefox at 1366 × 768 with selectors based on French labels, **then** it passes on both, and any failure fails the pipeline.

**Tasks:** Playwright project · test data seeding · pipeline stage.

#### US-57 — Kubernetes deployment with Helm

As an **Ops engineer**, I want a Helm chart so that the application is deployed on kind or k3s with one command.
**E8 · Must · 5 pts · S5 · Sources:** BNF-11, BNF-12, BNF-18, OBJ-T02

1. **Given** a kind cluster, **when** `helm install` runs, **then** `kubectl wait --for=condition=Ready pods --all --timeout=300s` succeeds.
2. *(edge)* **Given** a running API pod, **when** it is deleted with `kubectl delete pod`, **then** a new pod is Ready in less than 30 s (liveness and readiness probes).
3. *(error)* **Given** values without the database secret, **when** `helm install` runs, **then** it fails with an explicit message (`values.schema.json`).

**Tasks:** chart (Deployments, Services, ConfigMap, Secret, PostgreSQL StatefulSet or sub-chart) · probes · values schema.

#### US-58 — Prometheus metrics and Grafana dashboard

As an **Ops engineer**, I want business and technical metrics in Grafana so that I see how the application behaves.
**E8 · Must · 3 pts · S5 · Sources:** BNF-19, BNF-01, BNF-03, OBJ-T03

1. **Given** a running API, **when** `/metrics` is scraped, **then** it exposes queue length, longest wait, SLA rate per queue, agents per status and HTTP request duration.
2. **Given** the repository, **when** the stack starts, **then** the Grafana dashboard is provisioned from a versioned JSON file.
3. *(edge)* **Given** a request to `/metrics` through the public entry point, **when** it is sent, **then** it is not served; scraping works only on the internal port *(proposed answer to the BNF-05 gap, see section 5.4)*.

**Tasks:** prometheus-net · custom gauges and histograms (SignalR broadcast delay, assignment delay) · Prometheus and Grafana in Compose and Helm.

#### US-59 — Alertmanager rules (SLA, API down)

As an **Ops engineer**, I want alerts on SLA degradation and API outage so that problems are reported without watching the screens.
**E8 · Must · 3 pts · S5 · Sources:** BNF-21, BNF-27, OBJ-T03

1. **Given** a queue whose daily level stays orange for W = 5 min, **when** the rule is evaluated, **then** a `warning` alert fires, and when it turns red a `critical` alert fires in less than 2 minutes.
2. *(edge)* **Given** a queue at green or N/A, **when** rules are evaluated, **then** no alert fires.
3. *(edge)* **Given** an API stopped for 2 minutes, **when** the rule `up{job="api"} == 0 for: 1m` is evaluated, **then** an alert fires, and an API stopped for 30 s fires none.

**Tasks:** versioned alert rules · Alertmanager configuration · forced-degradation scenario with the generator.

#### US-60 — Structured logs with correlation ID

As an **Ops engineer**, I want JSON logs with a correlation ID so that I can follow one request across all its logs.
**E8 · Must · 2 pts · S1 · Sources:** BNF-20 (structured logs and correlation ID part)

1. **Given** any request, **when** the API logs, **then** each entry is JSON with timestamp, level, message and correlation ID.
2. **Given** a request with an `X-Correlation-ID` header, **when** it is handled, **then** that ID is used, and without the header an ID is generated and returned in the response.
3. *(error)* **Given** a login request, **when** it is logged, **then** no password and no JWT appears in the logs.

**Tasks:** Serilog with a JSON formatter · correlation middleware · log redaction test.

#### US-61 — Log collection with Loki

As an **Ops engineer**, I want logs collected in Loki and searchable in Grafana so that I do not have to read container output by hand.
**E8 · Could · 2 pts · — · Sources:** BNF-20 (Loki part, Could since Day 4)

1. **Given** a request's correlation ID, **when** a LogQL query searches for it, **then** all logs of that request are returned.
2. *(edge)* **Given** Loki is down, **when** the API runs, **then** it keeps working and logs to stdout.
3. **Given** the stack, **when** Grafana starts, **then** the Loki data source is provisioned automatically.

**Tasks:** Loki and Promtail (or Grafana Alloy) in Compose and Helm · data source provisioning.

#### US-62 — Security hardening and OWASP ZAP scan

As an **Ops engineer**, I want the deployed application hardened and scanned so that no high-risk weakness is shipped.
**E8 · Should · 3 pts · Overflow · Sources:** BNF-10 (Should since Day 4)

1. *(error)* **Given** the deployed application, **when** the ZAP baseline scan runs in the pipeline, **then** any "High" alert fails the pipeline.
2. **Given** the Helm chart, **when** pods start, **then** containers run as non-root, and secrets come from Kubernetes Secrets, never from committed values.
3. **Given** any HTTP response, **when** its headers are checked by a test, **then** it includes `X-Content-Type-Options`, `Content-Security-Policy` and `Referrer-Policy`.

**Tasks:** ZAP stage · security headers middleware · `securityContext` in the chart.

#### US-63 — Provision the environment with Ansible

As an **Ops engineer**, I want an Ansible playbook that prepares the environment so that it can be rebuilt reliably.
**E8 · Should · 3 pts · Overflow · Sources:** OBJ-T06, LIV-08 — *no BF or BNF source (see section 5.4)*

1. **Given** a clean Linux target (WSL or VM), **when** the playbook runs, **then** Docker, kind, kubectl and Helm are installed and the cluster is created.
2. *(edge)* **Given** a second run on the same target, **when** the playbook finishes, **then** it reports 0 changed tasks (idempotent).
3. *(error)* **Given** an unsupported operating system, **when** the playbook starts, **then** it stops at once with a clear message.

**Tasks:** inventory · roles · idempotence check.

#### US-64 — Production deployment with rollback

As an **Ops engineer**, I want a production deployment with a safe rollback so that the final demo is close to a real release.
**E8 · Must · 3 pts · S6 · Sources:** OBJ-T02, LIV-12 — *no BF or BNF source (see section 5.4); HTTPS split into US-67 on Day 4*

1. **Given** the production values, **when** the chart is installed in the production namespace, **then** all pods are Ready and the application answers through the Ingress.
2. *(error)* **Given** a release whose pods never become Ready, **when** `helm upgrade --atomic` runs, **then** it rolls back automatically and the previous version keeps serving.
3. **Given** a bad release that is already live, **when** `helm rollback` runs, **then** the previous version is restored and healthy in less than 5 minutes.

**Tasks:** Ingress controller · production values file · rollback runbook in the README.

#### US-65 — GitOps deployment with ArgoCD

As an **Ops engineer**, I want ArgoCD to deploy what is in Git so that a merge to `main` reaches the cluster automatically.
**E8 · Could · 3 pts · — · Sources:** BNF-29, OBJ-T06 (ArgoCD part, Could since Day 4; US-68 meets BNF-29 without it)

1. **Given** a merge to `main`, **when** Jenkins pushes the new image tag to the deployment repository, **then** ArgoCD syncs it and the application is Synced and Healthy less than 15 minutes after the push (BNF-29).
2. *(edge)* **Given** a manual `kubectl` change, **when** ArgoCD compares the state, **then** it detects the drift and reverts it (self-heal).
3. *(error)* **Given** an invalid manifest, **when** ArgoCD syncs, **then** the application is Degraded, the previous version keeps running, and the pipeline reports the failure.

**Tasks:** ArgoCD install · Application manifest · tag update stage in Jenkins.

#### US-66 — GitHub Actions comparison pipeline

As a **Developer**, I want a GitHub Actions workflow equal to the Jenkins CI so that I can compare both tools.
**E8 · Could · 2 pts · — · Sources:** CT-01, LIV-06

1. **Given** a push, **when** the workflow runs, **then** it builds and tests backend and frontend.
2. *(error)* **Given** a failing test, **when** the workflow runs, **then** it fails.
3. **Given** both pipelines, **when** the comparison is written, **then** it is recorded in an ADR.

**Tasks:** workflow file · ADR.

#### US-67 — HTTPS with cert-manager

As an **Ops engineer**, I want the production deployment served over HTTPS so that credentials and tokens never travel in clear text.
**E8 · Should · 2 pts · Overflow · Sources:** OBJ-T02, LIV-12 — *split from US-64 on Day 4; no BF or BNF source*

1. **Given** cert-manager with a local CA issuer, **when** the production chart is installed, **then** a certificate is issued and the application is served over HTTPS.
2. **Given** an HTTP request, **when** it reaches the Ingress, **then** it is redirected to HTTPS.
3. *(error)* **Given** a misconfigured issuer, **when** the certificate is requested, **then** its status is not Ready with a readable reason, and the post-deploy smoke test fails.

**Tasks:** cert-manager install · ClusterIssuer · TLS section of the Ingress · smoke test.

#### US-68 — Deploy automatically to the test environment

As an **Ops engineer**, I want every successful build of `main` deployed to the test environment by Jenkins so that a push reaches a running system in less than 15 minutes.
**E8 · Must · 3 pts · S5 · Sources:** BNF-29, OBJ-T01, OBJ-T02 — *added on Day 4 because ArgoCD (US-65) is now Could*

1. **Given** a push to `main`, **when** all pipeline stages pass, **then** Jenkins pushes the images to the registry, runs `helm upgrade --install` on the test namespace, and the release is healthy less than 15 minutes after the push.
2. *(error)* **Given** a stage that fails before the deploy stage, **when** the pipeline stops, **then** nothing is deployed and the test environment keeps the previous version.
3. *(error)* **Given** a deployment whose pods never become Ready, **when** `helm upgrade --atomic --timeout 5m` runs, **then** the release is rolled back and the pipeline fails.

**Tasks:** local registry for kind · cluster credentials in Jenkins · deploy stage · push-to-healthy timing recorded per build.

## 5. Traceability

### 5.1 Functional requirements → stories

Priorities are those of specification version 0.3, which was aligned with this backlog on Day 4.

| BF | Spec priority | Stories | Note |
|----|---------------|---------|------|
| BF-01 | Must | US-01 | |
| BF-02 | Must | US-02 | |
| BF-03 | Must | US-04 | |
| BF-04 | Must | US-03 | |
| BF-05 | Should | US-05 | Overflow |
| BF-06 | Could | US-06 | |
| BF-07 | Must | US-11 | |
| BF-08 | Must | US-11, US-12 | |
| BF-09 | Must | US-19, US-20 | |
| BF-10 | Should | US-30 | |
| BF-11 | Could | US-15 | |
| BF-12 | Must | US-07, US-08 | |
| BF-13 | Must | US-09 | |
| BF-14 | Must | US-09, US-29 | |
| BF-15 | Must | US-17 | |
| BF-16 | Should | US-18 | Overflow |
| BF-17 | Must | US-20 | |
| BF-18 | Must | US-20 | |
| BF-19 | Must | US-21 | Default strategy only (split on Day 4) |
| BF-20 | Should | US-24 | |
| BF-21 | Won't | — | Excluded on purpose |
| BF-22 | Must | US-28 | |
| BF-23 | Must | US-13, US-28 | |
| BF-24 | Must | US-29 | |
| BF-25 | Must | US-27, US-28 | |
| BF-26 | Should | US-32 | Overflow |
| BF-27 | Should | US-12, US-14 | |
| BF-28 | Must | US-34 | |
| BF-29 | Must | US-35 | |
| BF-30 | Must | US-36 | |
| BF-31 | Should | US-38 | |
| BF-32 | Could | US-40 | |
| BF-33 | Must | US-19, US-41 | |
| BF-34 | Should | US-42 | Overflow |
| BF-35 | Must | US-43 | ⚠ Occupancy not defined in the spec |
| BF-36 | Should | US-44 | Overflow |
| BF-37 | Should | US-44 | Overflow |
| BF-38 | Won't | — | Excluded on purpose |
| BF-39 | Could | US-45 | |
| BF-40 | Could | US-25 | |
| BF-41 | Should | US-10 | |
| BF-42 | Should | US-37 | |
| BF-43 | Should | US-39 | |
| BF-44 | Could | US-33 | Should → Could on Day 4 |
| BF-45 | Could (out of MVP) | US-47 | Not planned |
| BF-46 | Could (out of MVP) | US-16 | Not planned |
| BF-47 | Could (out of MVP) | US-26 | Not planned |
| BF-48 | Should | US-22 | Round robin, new on Day 4, cut last |

### 5.2 Non-functional requirements → stories

| BNF | Topic | Spec priority | Stories | Note |
|-----|-------|---------------|---------|------|
| BNF-01 | Dashboard latency < 1 s | Must | US-58, US-56 (Could) | Verified by the Prometheus histogram; Playwright only if time remains |
| BNF-02 | API p95 < 300 ms | Must | US-55 | Nightly, does not block pushes |
| BNF-03 | Assignment < 500 ms | Must | US-23, US-55, US-58 | |
| BNF-04 | 500-user headroom test | Must | US-55 | Nightly |
| BNF-05 | JWT on every route, ≤ 60 min | Must | US-01, US-03, US-27 | ⚠ `/metrics` is not in the exceptions (5.4) |
| BNF-06 | Hashed passwords | Must | US-01 | |
| BNF-07 | RBAC, 403 | Must | US-03, US-27 | |
| BNF-08 | No secret in Git | Must | US-51 | |
| BNF-09 | No critical image vulnerability | Must | US-53 | |
| BNF-10 | 0 ZAP "High" | Should | US-62 | Overflow |
| BNF-11 | Restart < 30 s | Must | US-50, US-57 | |
| BNF-12 | Health probes < 100 ms | Must | US-48, US-57 | |
| BNF-13 | Reconnection < 10 s | Must | US-31, US-56 (Could) | Manual test if Playwright is not delivered |
| BNF-14 | Layer dependencies | Must | US-48 | |
| BNF-15 | Domain coverage > 70 % | Must | US-52 | |
| BNF-16 | Every choice in an ADR | Must | — | ⚠ No story: Definition of Done (Day 5) |
| BNF-17 | `docker compose up` < 3 min | Must | US-50 | |
| BNF-18 | `helm install` < 5 min | Must | US-57 | |
| BNF-19 | `/metrics` content | Must | US-58 | |
| BNF-20 | JSON logs, correlation ID, Loki | Must (Loki part Could) | US-60, US-61 (Could) | |
| BNF-21 | SLA alerts | Must | US-59 | |
| BNF-22 | SonarQube gate | Must | US-52 | |
| BNF-23 | No lint error or warning | Must | US-48, US-49, US-51 | |
| BNF-24 | Chrome, Edge, Firefox | Must | US-56 (Could) | ⚠ Only a Could story; manual test otherwise |
| BNF-25 | UI in French | Must | US-49, US-56 (Could) | |
| BNF-26 | 90-day retention | Should | US-46 | Overflow |
| BNF-27 | API-down alert | Must | US-59 | |
| BNF-28 | UTC timestamps | Must | US-13, US-35, US-54 | |
| BNF-29 | 15 min push to deploy, 10 min PR | Must | US-51, US-68, US-65 (Could) | Met by Jenkins + Helm without ArgoCD |

### 5.3 Business rules → stories

| RG | Stories | RG | Stories | RG | Stories |
|----|---------|----|---------|----|---------|
| RG-01 | US-11, US-28 | RG-16 | US-29, US-41 | RG-31 | US-24, US-35 |
| RG-02 | US-04, US-11 | RG-17 | US-19, US-41 | RG-32 | US-35 |
| RG-03 | US-12 | RG-18 | US-08, US-20 | RG-33 | US-37 |
| RG-04 | US-20 | RG-19 | US-20 | RG-34 | US-36 |
| RG-05 | US-12 | RG-20 | US-21, US-22 | RG-35 | US-36, US-38 |
| RG-06 | US-20 | RG-21 | US-21 | RG-36 | US-37, US-38 |
| RG-07 | US-02, US-04 | RG-22 | US-22 | RG-37 | US-23 |
| RG-08 | US-12, US-14 | RG-23 | US-21 | RG-38 | US-35 |
| RG-09 | US-13 | RG-24 | US-08, US-23 | RG-39 | US-35 |
| RG-10 | US-13, US-28 | RG-25 | US-20 | RG-40 | US-34, US-37 |
| RG-11 | US-19 | RG-26 | US-10 | RG-41 | US-39 |
| RG-12 | US-17 | RG-27 | US-10 | RG-42 | US-09 |
| RG-13 | US-19 | RG-28 | US-10 | RG-43 | US-09 |
| RG-14 | US-19 | RG-29 | US-35 | RG-44 | US-09, US-17 |
| RG-15 | US-24 | RG-30 | US-35 | | |

All 44 RG are covered.

### 5.4 Gaps

| # | Gap | Status |
|---|-----|--------|
| 1 | BF-21 and BF-38 have no story. | Intentional (Won't). |
| 2 | BNF-16 (ADR for each structuring choice) has no story. | To add to the Definition of Done on Day 5. |
| 3 | BNF-24 (browser support) is covered only by a Could story (US-56). | Open: a manual check on Chrome, Edge and Firefox goes in the release checklist (Day 5 Definition of Done). |
| 4 | BNF-29 depended on ArgoCD and X was undefined. | **Closed:** X = 15 min (10 min for pull requests), met by US-51 and US-68. |
| 5 | US-63 (Ansible) and US-66 (GitHub Actions) come only from objectives and deliverables (OBJ-T06, LIV-08, CT-01, LIV-06). | Accepted: both are outside the Must set. |
| 6 | US-64 (production and rollback, Must) and US-67 (HTTPS, Should) have no BF or BNF source. They come from the planning (S6), OBJ-T02 and LIV-12. | Open: add BNF entries to the specification, or accept that objectives are their source. |
| 7 | BNF-05 requires a JWT on every route except login and health, but Prometheus scrapes `/metrics` without a token. | Open: add `/metrics` (internal port only) to the BNF-05 exceptions before S5. |
| 8 | BF-35 "occupancy" has no formula in the specification. | Open: adopt On call / (Available + On call) in section 7 before S4. |
| 9 | BF-06 does not give the failure count or lockout length. | Could: 5 failures and 15 min (Identity defaults) if it is ever planned. |
| 10 | The Day 4 outline says "agents with skill levels", but levels exist only in BF-40 (Could). | Levels moved to US-25. MVP agents have skills without levels. |
| 11 | US-24 (abandon, S5) comes after the SLA rate (US-35, S4). Until S5, SLA rates contain no abandoned calls (RG-31). | Accepted: the SLA tests use data sets with abandoned calls inserted directly. |
| 12 | Section 11, point 10 of the spec (agent closes the browser without logging out) has no story. | Out of MVP. Supervisor forcing (US-14) is the workaround. |
| 13 | ArgoCD (OBJ-T06) and Playwright (OBJ-T04) are now Could, so those objectives are only partly guaranteed. | Accepted on Day 4 (spec section 11, point 23). |

## 6. Points and capacity

### 6.1 Totals

| Category | Stories | Points |
|----------|--------:|-------:|
| Must | 38 | 129 |
| Should in a sprint | 8 | 20 |
| Should in Overflow | 9 | 21 |
| **Must + Should** | **55** | **170** |
| Could (no sprint) | 10 | 26 |
| Could (out of MVP) | 3 | 7 |
| **Whole backlog** | **68** | **203** |

| Epic | Points (whole backlog) |
|------|-------:|
| E1 Access and security | 19 |
| E2 Reference data | 14 |
| E3 Agent statuses | 16 |
| E4 Calls and routing | 33 |
| E5 Real-time supervision | 20 |
| E6 SLA and alerts | 19 |
| E7 Statistics and history | 18 |
| E8 DevOps platform | 64 |

### 6.2 Points per sprint

Stories are ordered by dependency. Authentication starts in S1. The routing core and the hub are in S3. The dashboard, SLA and statistics are in S4. Should stories fill the space left in S5 and S6.

| Sprint | Weeks | Capacity | Must | Should | Total | Free |
|--------|-------|---------:|-----:|-------:|------:|-----:|
| S1 | 2-3 | 28 | 27 | 0 | 27 | 1 |
| S2 | 4-5 | 28 | 27 | 0 | 27 | 1 |
| S3 | 6-7 | 28 | 28 | 0 | 28 | 0 |
| S4 | 8-9 | 28 | 27 | 0 | 27 | 1 |
| S5 | 10-11 | 28 | 17 | 10 | 27 | 1 |
| S6 | 12 | 14 | 3 | 10 | 13 | 1 |
| **Total** | | **154** | **129** | **20** | **149** | **5** |
| Overflow | — | — | 0 | 21 | 21 | — |

**Overflow, in the order it is pulled into a sprint if velocity allows:** US-18 generator control, US-05 password change, US-42 history filters, US-32 dashboard filters, US-44 team and period statistics, US-63 Ansible, US-67 HTTPS, US-46 purge, US-62 ZAP. The last three follow the decided cut order, so they are pulled in last. US-22 (round robin) is planned in S5 and is cut only after all of them.

### 6.3 Balance check (after the Day 4 decisions)

**Decisions applied:**

- US-62 ZAP and US-46 purge Must → Should (BNF-10 and BNF-26 Should in the spec).
- US-64 split: production deployment and rollback stay Must (3 pts), HTTPS with cert-manager becomes US-67 (Should, 2 pts).
- Cut-first items: US-65 ArgoCD, US-61 Loki and US-56 Playwright Should → Could.
- US-22 round robin stays Should and is cut last. BF-19 is split in the spec: the default strategy (Must) and BF-48 for round robin (Should).
- US-33 (BF-44) Should → Could, and the rights matrix of the spec is updated.
- New US-68 (Must, 3 pts): Jenkins deploys to the test environment, so BNF-29 (15 min) is met without ArgoCD.
- US-55 k6 runs nightly and does not block pushes. Pull-request builds must finish in 10 min (US-51).
- Reference story: US-07 instead of US-11. Calibration stays 1 point ≈ 1 h and 28 points per sprint, to be reviewed after S1.

| # | Check | Limit | Actual | Result |
|---|-------|------:|-------:|--------|
| 1 | Must + Should points | about 165 | 170 | ⚠ 5 over (3 %) |
| 2 | Must as a share of capacity | 70 % of 154 ≈ 108 | 129 (84 %) | ⚠ 21 over |
| 3 | Sprint capacity | 28 (S6: 14) | max 28, S6 = 13 | OK |
| 4 | Cut-first items not Must | — | ArgoCD, Loki, Playwright Could; round robin Should | OK |

**Remaining risks (accepted on Day 4, to review after S1):**

- **Check 1.** Under the decided cut order, the next step would move US-62 ZAP and US-46 purge from Should to Could, which gives exactly 165. Both are already in Overflow, so the sprint plan does not change.
- **Check 2.** The Must set is 84 % of capacity, which leaves only 25 points (16 %) of margin for underestimation. Going down to 70 % would mean cutting core MVP functions. If S1 velocity is below 28, the first Must candidates to discuss are US-31 automatic reconnection, US-02 deferred logout and US-43 occupancy, which are not in the protected list. Docker, Jenkins, basic Kubernetes and Prometheus/Grafana are never cut.
- **S1 has no slack for design.** Design of the domain model and the API contract is counted inside US-48 and the first stories. If it takes longer, the S1 velocity will show it.
