<!-- Title: a Conventional Commits header, e.g. "feat(auth): log in with email and password". It becomes the commit message on main after the squash. -->

## What

<!-- What changed, in a few lines. -->

Closes #

## How it was tested

<!-- Automated tests added or run, manual checks. -->

-

## Definition of Done

<!-- Tick what applies; write "n/a" next to an item that does not apply yet (see DoD section 1). Full list: docs/definition-of-done.md -->

**Code and design**
- [ ] Layer rules respected: architecture tests pass (BNF-14)
- [ ] No lint error, no compiler warning (BNF-23)
- [ ] No secret in the code or history: gitleaks passes (BNF-08)
- [ ] New structuring choice recorded in an ADR (BNF-16)
- [ ] New API routes declare their roles and are in the role × route test (BNF-07)

**Tests**
- [ ] Each of the 3 acceptance criteria has a passing automated test named after it
- [ ] Business rules touched have Domain unit tests
- [ ] Domain coverage > 70 %, new code coverage ≥ 70 % (BNF-15, BNF-22)
- [ ] No test disabled or skipped

**Pipeline**
- [ ] Jenkins pipeline green in < 10 min (BNF-29), from S1
- [ ] SonarQube quality gate and Trivy pass, from S4

**User interface** (only if a screen changed)
- [ ] Labels in French, from the label file (BNF-25)
- [ ] Checked on Chrome, Edge and Firefox at 1366 × 768 (BNF-24): result:

**Documentation**
- [ ] `README.md` updated if installing, running or deploying changed
- [ ] Specification and change log updated if a requirement changed
- [ ] Changes re-read once in the **Files changed** tab

## Notes

<!-- Optional: decisions, open points, screenshots. -->
