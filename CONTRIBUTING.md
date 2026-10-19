# Contributing to CallPulse

- **Version:** 0.1
- **Date:** 2026-10-19 (Day 5, Sprint 0)
- **Author:** Khadija
- **See also:** [Definition of Done](docs/definition-of-done.md), [sprint plan](docs/sprint-plan.md)

> CallPulse is developed by one person, but every change follows the same rules as a team project: one branch, one pull request, one squashed commit on `main`.

---

## 1. Workflow: GitHub Flow

`main` is always working and deployable. Nobody commits directly to it.

1. **Start from an up-to-date `main`.**
   ```
   git switch main
   git pull
   ```
2. **Create a branch** for one story or one change (section 2).
   ```
   git switch -c feature/us-48-backend-skeleton
   ```
3. **Commit small steps** with Conventional Commits messages (section 3).
4. **Push** the branch and **open a pull request** to `main` (section 4).
5. **Check** that the pipeline is green and the Definition of Done is met.
6. **Squash and merge**, then delete the branch (section 5).
7. **Clean up locally.**
   ```
   git switch main
   git pull
   git branch -D feature/us-48-backend-skeleton
   ```
   `-D` is needed because a squash merge creates a new commit, so Git does not see the branch as merged.

## 2. Branch names

Format: `<type>/<short-name>`, in lowercase with hyphens. A story branch includes the story ID.

| Type | Use | Example |
|------|-----|---------|
| `feature/` | A user story | `feature/us-01-login` |
| `fix/` | A bug fix | `fix/sla-rate-rounding` |
| `docs/` | Documentation only | `docs/contributing` |
| `chore/` | Tooling, configuration, dependencies | `chore/commitlint-husky` |
| `ci/` | Pipeline changes outside a story | `ci/jenkins-cache` |

One branch contains one story. A branch should live a few days at most.

## 3. Commit messages: Conventional Commits

Format ([conventionalcommits.org](https://www.conventionalcommits.org/)):

```
<type>(<optional scope>): <description>

<optional body: why the change was made>

<optional footer: Closes #n, BREAKING CHANGE: ...>
```

| Type | Use |
|------|-----|
| `feat` | A new feature for the user |
| `fix` | A bug fix |
| `docs` | Documentation only |
| `test` | Adding or fixing tests |
| `refactor` | Code change that neither adds a feature nor fixes a bug |
| `perf` | Performance improvement |
| `style` | Formatting only, no code change |
| `build` | Build system, Docker, dependencies |
| `ci` | Jenkins or other pipeline configuration |
| `chore` | Other maintenance |

**Rules**

- The description is in English, in the imperative ("add", not "added" or "adds"), starts with a lowercase letter and has no final period.
- The header (first line) is 100 characters or less.
- Optional scopes: `api`, `web`, `db`, `auth`, `routing`, `sla`, `realtime`, `docker`, `jenkins`, `k8s`, `monitoring`.
- A breaking change adds `!` after the type (`feat(api)!: ...`) and a `BREAKING CHANGE:` footer.

**Examples**

```
feat(auth): add login endpoint issuing a JWT
test(db): check UTC timestamps with an Asia/Tokyo session
ci(jenkins): add gitleaks stage
docs: add contributing guide
```

From Sprint 0 (Day 5), these rules are checked on every commit by **commitlint** with a **husky** `commit-msg` hook. A commit with an invalid message is refused. An unknown scope only gives a warning.

After cloning the repository, run `npm install` once at its root to activate the hook (Node.js 20 or later). The rules are in `commitlint.config.mjs`.

## 4. Pull requests

- **One pull request per story**, opened from its branch to `main`.
- **Title:** a valid Conventional Commits header, because it becomes the commit message on `main` after the squash. Example: `feat(auth): log in with email and password`.
- **Description:** what changed and how it was tested, following the pull request template, with `Closes #n` to link the story's issue. The issue then moves to **Done** on the board when the pull request is merged.
- **Before merging:**
  - the pipeline is green (from Sprint 1, when Jenkins is delivered);
  - every applicable item of the [Definition of Done](docs/definition-of-done.md) is checked;
  - the changes were re-read once in the **Files changed** tab.
- **Review:** as a solo developer, no approval is required. The self-review above replaces it.

## 5. Merging

- **Method:** **Squash and merge** only. Each pull request becomes one commit on `main`, with a Conventional Commits title and the pull request number, for example `feat(auth): log in with email and password (#11)`.
- **After merging:** delete the branch on GitHub (button **Delete branch**) and locally (section 1, step 7).
- **Protection of `main`:** direct pushes are blocked, and a pull request is required (0 approvals, solo developer). Force-push and deletion of `main` are blocked.

## 6. Tags

| Tag | When |
|-----|------|
| `spec-v1.0` | Specification frozen (done) |
| `sprint-n` | End of sprint n, after the review (Definition of Done section 3) |
| `v1.0.0` | Final release at the end of S6 |

```
git switch main
git pull
git tag -a sprint-1 -m "End of Sprint 1"
git push origin sprint-1
```
