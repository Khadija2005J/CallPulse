# CallPulse — Project Vision

## 1. Problem

Call center supervisors often work blind. Agent statuses, queue lengths and waiting times are scattered across tools or only available in end-of-day reports. As a result:

- supervisors notice an overloaded queue only after customers have already hung up;
- calls are assigned without considering agent skills, so customers get transferred several times;
- SLA compliance (e.g. 80% of calls answered in under 20 seconds) is measured after the fact, when it is too late to act;
- agents have no simple way to signal their availability, so statuses are often wrong.

## 2. Solution

CallPulse is a web platform for **real-time call center supervision and optimization**:

- live view of agent states: available, on a call, on break, offline;
- live view of calls waiting in each queue;
- automatic assignment of incoming calls to agents based on their skills;
- tracking of customer waiting time and SLA compliance;
- dashboards with statistics per agent, per team, per period and per call;
- full call history.

Calls are **simulated** by a traffic generator. There is no real telephony integration.

Three roles are supported: **Agent**, **Supervisor** and **Administrator**.

## 3. Learning objectives

CallPulse is primarily a DevOps training project. By the end of the 12 weeks, I want to be able to:

1. Design a layered modular monolith (Domain, Application, Infrastructure, Api) and justify it in ADRs.
2. Apply design patterns where they bring value: Strategy (routing), Factory, Observer (domain events).
3. Build real-time features with SignalR.
4. Write automated tests at every level: unit (xUnit, Vitest), integration (Testcontainers), end-to-end (Playwright), load (k6).
5. Build a CI/CD pipeline with Jenkins, and compare it with GitHub Actions.
6. Containerize the application with Docker and Docker Compose.
7. Deploy to Kubernetes (kind/k3s) with Helm, then with GitOps (ArgoCD).
8. Integrate quality and security checks: SonarQube, Trivy, OWASP ZAP.
9. Monitor the application with Prometheus, Grafana, Loki and Alertmanager.
10. Automate environment setup with Ansible.

**End-to-end target:** commit → Jenkins (build, tests, Sonar, Trivy) → image → Helm → Kubernetes → metrics → alert.

## 4. Success indicators

Each indicator can be checked with a simple **yes / no**.

| # | Indicator | Yes / No |
|---|-----------|----------|
| 1 | `docker compose up` starts the whole application (API, frontend, database, simulator) with no manual step. | ☐ |
| 2 | A supervisor sees an agent status change on the dashboard in under 1 second without refreshing the page. | ☐ |
| 3 | A simulated call is automatically assigned to an available agent who has the required skill. | ☐ |
| 4 | The dashboard shows the SLA percentage (calls answered in under 20 s) for the current day. | ☐ |
| 5 | Each push to `main` triggers a Jenkins pipeline that runs build, tests, SonarQube and Trivy. | ☐ |
| 6 | The pipeline fails if a test fails or if Trivy finds a critical vulnerability. | ☐ |
| 7 | The application is deployed to a local Kubernetes cluster with a single `helm install` (or `helm upgrade`) command. | ☐ |
| 8 | Grafana shows business metrics (queue length, waiting time, SLA) collected by Prometheus. | ☐ |
| 9 | Alertmanager sends an alert when the SLA drops below a configured threshold. | ☐ |
| 10 | Application logs can be searched in Grafana through Loki. | ☐ |
| 11 | A change merged to `main` is deployed automatically by ArgoCD. | ☐ |
| 12 | A k6 load test with a defined traffic level passes with p95 API latency under a defined threshold. | ☐ |

## 5. MVP scope

| In the MVP | Out of scope |
|------------|--------------|
| Authentication with three roles: Agent, Supervisor, Administrator | Real telephony (SIP, PSTN, VoIP providers) |
| Agents view and change their own status | Call recording and transcription |
| Real-time supervisor dashboard (agents, queues, waiting calls) | AI (sentiment analysis, prediction, voice bots) |
| Simulated call generator with configurable traffic | Native mobile application |
| Automatic skill-based call routing | Multi-tenant (several companies on one instance) |
| Waiting time and SLA tracking | Billing and CRM integration |
| Statistics per agent, team, period and call | SSO (SAML, OpenID Connect with external providers) |
| Call history | Multi-region high availability |
| Administration of agents, teams, skills and queues | Workforce management (scheduling, shift planning) |
| Containerized deployment, CI/CD, monitoring | Omnichannel (chat, email, social networks) |

## 6. Assumptions

- Calls are simulated. Realistic traffic patterns from the generator are enough to validate routing, SLA and dashboards.
- A single call center organization uses the instance (no multi-tenancy).
- Scale is moderate: around 100 simultaneous agents and a few thousand calls per day.
- The whole stack runs on a single development machine (Windows with Docker Desktop) and on a local Kubernetes cluster (kind/k3s).
- One developer works on the project, about 5 days per week for 12 weeks.
- Users access the application with a recent desktop web browser.

## 7. Future evolutions

These are outside the 12-week scope but the architecture should not block them:

- integration with a real telephony provider (e.g. via a SIP gateway or a cloud contact center API);
- call recording and AI-based transcription and sentiment analysis;
- traffic forecasting and staffing recommendations;
- mobile app for supervisors;
- multi-tenant SaaS offering;
- SSO with corporate identity providers;
- extraction of modules into separate services if load or team size justifies it.

## 8. Personas

### Sara — Supervisor

- **Profile:** 34 years old, team leader of 25 agents for 6 years. Works with two screens and spends her day switching between tools.
- **Main need:** *As a supervisor, I want to see in real time the state of my agents and queues, so that I can react before the SLA is broken.*
- **Current frustration:** She discovers queue problems through end-of-day reports or customer complaints. She has to walk around the floor to know who is really available.
- **What CallPulse brings:** A live dashboard with agent statuses, waiting calls and the current SLA, so she can act within seconds (call agents back from break, rebalance teams).

### Yassine — Agent

- **Profile:** 24 years old, customer service agent for 1 year, skilled in billing and technical support, speaks French and Arabic.
- **Main need:** *As an agent, I want to change my status in one click and receive calls that match my skills, so that I can help customers without transferring them.*
- **Current frustration:** He receives calls about topics he does not handle and has to transfer them, which frustrates customers. His status is often wrong because changing it is tedious.
- **What CallPulse brings:** A simple status toggle and skill-based routing, so the calls he receives are calls he can resolve.

### Karim — Administrator

- **Profile:** 41 years old, IT administrator of the call center. Manages user accounts, teams and configuration.
- **Main need:** *As an administrator, I want to manage agents, teams, skills and queues from one place, so that the routing configuration always matches the organization.*
- **Current frustration:** Configuration is spread across spreadsheets and several tools. Every change is manual and error-prone.
- **What CallPulse brings:** A central administration area for users, roles, skills and queues, with changes applied immediately to routing.
