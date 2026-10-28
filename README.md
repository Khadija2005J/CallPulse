# CallPulse

> Real-time call center supervision and optimization platform — 12-week DevOps training project.

**Status:** Sprint 0 (pre-project) — specification, backlog and engineering rules are in place; implementation starts in Sprint 1.

## The problem

Call center supervisors often work blind: agent statuses, queue lengths and waiting times are scattered across tools or only visible in end-of-day reports. Overloaded queues are noticed too late, calls are assigned without considering agent skills, and SLA compliance is measured after the fact.

## What CallPulse does

- Live view of agent states: available, on a call, on break, offline
- Live view of waiting calls in each queue
- Automatic skill-based call routing, with interchangeable routing strategies per queue
- Waiting-time and SLA tracking (e.g. 80 % of calls answered in under 20 seconds)
- Dashboards per agent, team, period and call, plus full call history
- Three roles: **Agent**, **Supervisor**, **Administrator**

Calls are simulated by a configurable traffic generator — there is no real telephony integration.

## Tech stack

| Area | Choice |
|------|--------|
| Architecture | Layered modular monolith (Domain, Application, Infrastructure, Api) |
| Backend | ASP.NET Core 8, EF Core |
| Database | PostgreSQL |
| Frontend | React, TypeScript, Vite |
| Real time | SignalR |
| CI/CD | Jenkins (main), GitHub Actions (comparison) |
| Containers | Docker, Docker Compose, Kubernetes (kind/k3s), Helm |
| Quality & security | SonarQube, Trivy, OWASP ZAP, gitleaks |
| Monitoring | Prometheus, Grafana, Loki, Alertmanager |
| IaC & GitOps | Ansible, ArgoCD |
| Tests | xUnit, Testcontainers, Vitest, Playwright, k6 |

The reasons behind each choice are in [ADR-001](docs/adr/001-choix-techniques.md).

## Engineering practices

- **GitHub Flow** – `main` is always deployable; every change goes through a pull request and a squash merge
- **Conventional Commits** enforced by commitlint and husky
- **Definition of Done** checked on every pull request
- **Architecture Decision Records** for every structuring choice

## Documentation

| Document | Content |
|----------|---------|
| [VISION.md](VISION.md) | Problem, solution, personas, MVP scope |
| [Requirements specification](docs/cahier-des-charges.md) | Functional and non-functional requirements (French) |
| [Product backlog](docs/backlog.md) | User stories and priorities |
| [Sprint plan](docs/sprint-plan.md) | 12-week roadmap |
| [Definition of Done](docs/definition-of-done.md) | Quality checklist |
| [Architecture decisions](docs/adr/) | ADRs |
| [UML diagrams](docs/uml/) | Use cases and class diagrams |
| [Project journal](docs/journal.md) | Day-by-day log |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Branching, commits and pull requests |

## Author

Khadija Alaoui Mrani – [GitHub](https://github.com/Khadija2005J)
