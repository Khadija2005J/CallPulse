# ADR-001 — Initial technical choices

- **Status:** Accepted
- **Date:** 2026-10-08
- **Deciders:** Khadija (sole developer)

## Context

CallPulse is a real-time call center supervision platform built as a 12-week DevOps training project by a single developer. The system must:

- push agent and queue state changes to supervisors in real time;
- route simulated calls to agents according to their skills;
- compute waiting times and SLA compliance;
- run locally with Docker Compose and on a local Kubernetes cluster;
- go through a full DevOps chain: commit → CI (build, tests, quality, security) → image → Helm → Kubernetes → metrics → alert.

Constraints: one developer, limited time, Windows workstation, no cloud budget, and the goal of learning industry-standard tools.

## Decision

| Topic | Choice | Rejected alternatives | Why |
|-------|--------|-----------------------|-----|
| Architecture | Layered modular monolith (Domain, Application, Infrastructure, Api) | Microservices | One developer, 12 weeks and ~100 agents do not justify the network calls, distributed data and multiple pipelines of microservices; strict layers keep modules separable so one can be extracted later if needed. |
| Backend | ASP.NET Core 8 + EF Core | Node.js (NestJS), Java (Spring Boot) | Native SignalR support for the real-time dashboard, strong typing, high performance, and EF Core migrations; it also matches my existing C#/.NET skills, so I can spend the time on DevOps rather than on a new language. |
| Database | PostgreSQL | SQL Server, MySQL, MongoDB | Calls, agents, queues and statistics are relational data that need joins, aggregates and transactions, which rules out MongoDB; PostgreSQL is free, runs well in Docker/Kubernetes and has first-class Testcontainers and EF Core support, unlike SQL Server's heavier licensing and images. |
| Frontend | React + TypeScript + Vite | Angular, Vue | Largest ecosystem and fastest learning curve for a single developer; TypeScript catches errors at compile time and can share API contracts; Vite gives near-instant dev builds and is lighter than Angular's full framework. |
| Real time | SignalR | Raw WebSocket, Server-Sent Events, polling | Built into ASP.NET Core with automatic reconnection, user/group targeting (e.g. per team or queue) and transport fallback, which raw WebSocket would require me to code by hand; polling cannot meet the < 1 s dashboard target (BNF-01) without heavy load. |
| Design patterns | Strategy (call routing), Factory, Observer (domain events) | Hard-coded `if/else` routing, direct service calls | Routing must support several interchangeable strategies per queue (BF-19), which is exactly the Strategy pattern; Observer decouples status/call events from SignalR, statistics and metrics; Factory centralizes creation of strategies and simulated calls. Each pattern answers a real variation point. |
| CI/CD | Jenkins (main) + GitHub Actions (comparison) | GitLab CI, Azure DevOps | Jenkins is still the most widespread CI server in enterprises and teaches pipelines as code, agents and plugin administration; GitHub Actions is added as a lightweight comparison. GitLab CI and Azure DevOps would tie the project to another platform without extra learning value. |
| Containers and orchestration | Docker, Docker Compose, Kubernetes (kind/k3s) + Helm | Docker Swarm, Nomad, plain Kubernetes manifests / Kustomize | Docker Compose gives a one-command local stack; Kubernetes is the industry standard and the learning target, and kind/k3s run it locally at no cost; Helm adds templating, per-environment values and versioned releases that plain manifests lack and that ArgoCD can deploy. |
| Quality and security | SonarQube, Trivy, OWASP ZAP | Snyk, Grype, Burp Suite | All three are free, self-hostable and integrate into Jenkins: SonarQube for code quality gates, Trivy for image and dependency CVEs, ZAP for dynamic web scanning. Snyk is SaaS with limited free usage, Burp Suite Pro is paid. |
| Monitoring | Prometheus, Grafana, Loki, Alertmanager | ELK stack, Datadog | Prometheus + Grafana is the de facto standard for Kubernetes and is much lighter than ELK, which matters on one laptop; Loki reuses Grafana for logs; Alertmanager closes the metrics -> alert loop. Datadog is a paid SaaS. |
| IaC and GitOps | Ansible, ArgoCD | Terraform, Flux | Ansible configures existing machines (Jenkins host, tools) without agents, which fits a local setup with no cloud resources to create; Terraform mainly provisions cloud infrastructure we do not have. ArgoCD has a UI that makes GitOps sync and drift visible, which helps learning compared to Flux. |
| Tests | xUnit, Testcontainers, Vitest, Playwright, k6 | NUnit, in-memory database, Jest, Cypress, JMeter | xUnit is the default in modern .NET; Testcontainers tests against a real PostgreSQL, avoiding the false confidence of an in-memory database; Vitest is native to Vite; Playwright tests Chromium and Firefox (BNF-24) and handles WebSockets; k6 scripts in JavaScript with thresholds usable directly in CI, unlike JMeter's XML. |

## Trade-offs per decision

### Architecture: modular monolith

- **Most serious alternative:** Microservices.
- **What I lose:** Independent deployment and scaling of each module. Modules cannot use different technologies.
- **Risk:** Module boundaries erode over time and the monolith becomes a "big ball of mud".
- **Mitigation:** Strict layer dependencies (Domain depends on nothing). Architecture tests (e.g. NetArchTest) in CI to enforce boundaries. Communication between modules through interfaces and domain events.

### Backend: ASP.NET Core 8 + EF Core

- **Most serious alternative:** Java with Spring Boot.
- **What I lose:** The largest enterprise Java ecosystem and its tooling.
- **Risk:** EF Core hides SQL. This can produce N+1 queries or slow queries on dashboards.
- **Mitigation:** Enable EF Core query logging in development. Use projections (`Select`) for read models. Add load tests with k6.

### Database: PostgreSQL

- **Most serious alternative:** SQL Server.
- **What I lose:** The tightest integration with the .NET ecosystem and SQL Server tooling.
- **Risk:** Heavy writes on call events and statistics can slow down dashboard queries.
- **Mitigation:** Proper indexes on call history. Pre-aggregated statistics tables if needed. Measure with k6 before optimizing.

### Frontend: React + TypeScript + Vite

- **Most serious alternative:** Angular.
- **What I lose:** A complete, opinionated framework (routing, forms, DI) included out of the box.
- **Risk:** Too many library choices (state management, routing, UI kit) and inconsistent code.
- **Mitigation:** Pick a small, fixed set of libraries early and document them in a later ADR. Use ESLint and Prettier in CI.

### Real time: SignalR

- **Most serious alternative:** Raw WebSocket.
- **What I lose:** Full control over the protocol, and independence from a Microsoft-specific library on the client side.
- **Risk:** With several API replicas, a client connected to one replica does not receive messages sent from another.
- **Mitigation:** Add a Redis backplane when scaling to several replicas (planned for Day 48). Until then, run a single replica or use sticky sessions.

### Design patterns: Strategy, Factory, Observer

- **Most serious alternative:** Simple procedural code (`if/else` routing, direct calls between services).
- **What I lose:** Simplicity: there are more classes and indirection for a small codebase.
- **Risk:** Over-engineering, with patterns added where they bring no value.
- **Mitigation:** Use each pattern only where a real variation point exists (several routing strategies, several event handlers). Review during code reviews and the Sprint retrospectives.

### CI/CD: Jenkins + GitHub Actions

- **Most serious alternative:** GitHub Actions only.
- **What I lose:** Simplicity: Jenkins must be hosted, configured, updated and secured by me.
- **Risk:** Time lost on Jenkins administration (plugins, agents, credentials) instead of the pipeline itself.
- **Mitigation:** Run Jenkins in Docker with configuration as code (JCasC) and a versioned `Jenkinsfile`. Keep the GitHub Actions workflow as a fallback and point of comparison.

### Containers and orchestration: Docker, Compose, Kubernetes + Helm

- **Most serious alternative:** Docker Compose only (no Kubernetes).
- **What I lose:** Simplicity and machine resources: Kubernetes is heavy on a laptop.
- **Risk:** Kubernetes complexity (networking, ingress, storage) slows the project down.
- **Mitigation:** Use lightweight local clusters (kind or k3s). Introduce Kubernetes only after the application is stable with Docker Compose.

### Quality and security: SonarQube, Trivy, OWASP ZAP

- **Most serious alternative:** Snyk (SaaS).
- **What I lose:** A managed service with a single dashboard for code, dependencies and containers.
- **Risk:** Many false positives, which slow down the pipeline or get ignored.
- **Mitigation:** Configure quality gates and severity thresholds (fail only on critical/high). Document accepted exceptions.

### Monitoring: Prometheus, Grafana, Loki, Alertmanager

- **Most serious alternative:** ELK stack (Elasticsearch, Logstash, Kibana).
- **What I lose:** Powerful full-text search over logs.
- **Risk:** Too many metrics or labels (high cardinality) overload Prometheus. Alerts are too noisy.
- **Mitigation:** Define a small set of business and technical metrics first. Avoid high-cardinality labels (e.g. call ID). Tune alert thresholds and durations.

### IaC and GitOps: Ansible, ArgoCD

- **Most serious alternative:** Terraform (IaC) and Flux (GitOps).
- **What I lose:** Declarative provisioning with state tracking (Terraform). A lighter GitOps tool (Flux).
- **Risk:** Ansible playbooks drift from the real state of the machines. Running ArgoCD adds load to the local cluster.
- **Mitigation:** Keep playbooks idempotent and run them regularly. Install ArgoCD only in the final phase.

### Tests: xUnit, Testcontainers, Vitest, Playwright, k6

- **Most serious alternative:** In-memory database for integration tests, Cypress for end-to-end tests.
- **What I lose:** Speed: Testcontainers starts a real PostgreSQL, so tests are slower.
- **Risk:** Slow or flaky test suites that block the pipeline.
- **Mitigation:** Separate fast unit tests from integration and E2E tests in the pipeline. Reuse containers between tests. Retry only for known flaky E2E cases.

## Consequences

### Positive

- One codebase and one deployable unit: simple to build, test, debug and deploy for a single developer.
- The stack covers the full DevOps chain with widely used tools, which matches the learning objectives.
- Clear layers and patterns make the routing logic testable and extensible (new strategies without changing existing code).
- Everything is open source and runs locally: no cloud costs.

### Negative

- **SignalR with several replicas needs a Redis backplane** (to handle on Day 48). Until then, the API cannot be scaled horizontally.
- A monolith cannot scale modules independently. A traffic peak on routing scales the whole application.
- Running Jenkins, SonarQube, Kubernetes and the monitoring stack together requires a lot of RAM on one machine.
- Many tools to learn in 12 weeks: risk of shallow understanding of some of them.
- Jenkins requires maintenance work (plugins, updates, security) that a SaaS CI would avoid.

## When to revisit this decision

- If one module (e.g. routing or statistics) needs to scale independently or is owned by a separate team, reconsider extracting it as a service.
- If the local machine cannot run the full stack, reconsider lighter alternatives (e.g. GitHub Actions only, fewer monitoring components).
- If SignalR becomes a bottleneck or a blocker for non-.NET clients, reconsider raw WebSocket or SSE.
- If integration with real telephony becomes a requirement, revisit the architecture and the real-time model.
- At the end of each sprint retrospective, check whether any choice has caused repeated problems.
