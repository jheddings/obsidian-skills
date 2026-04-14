# CI Workflows Design

## Summary

Add two GitHub Actions workflows to the obsidian-skills repo:

1. **preflight** — runs Prettier style checks on all changes
2. **validate-skill** — validates only the skill folders that changed

## Workflow 1: preflight

- **File:** `.github/workflows/preflight.yml`
- **Triggers:** `push` to `main`, `pull_request` to `main`
- **Steps:**
    1. `actions/checkout@v4`
    2. `actions/setup-node@v4` with `node-version: lts/*`
    3. `npx prettier --check .`

## Workflow 2: validate-skill

- **File:** `.github/workflows/validate-skill.yml`
- **Triggers:** `push` to `main`, `pull_request` to `main`, filtered to
  `paths: skills/**`
- **Job 1: detect**
    - Checkout with `fetch-depth: 0` (need history for diffing)
    - Detect changed skill folders using git diff:
        - PR: `git diff --name-only origin/${{ github.base_ref }}...HEAD`
        - Push: `git diff --name-only HEAD~1...HEAD`
    - Extract unique `skills/<name>/` prefixes from changed paths
    - Output as JSON array for matrix consumption
    - If no skill folders changed (e.g. only root-level files in `skills/`), output
      empty array
- **Job 2: validate**
    - `needs: detect`, with `if` guard on non-empty matrix
    - `strategy.matrix.skill` from detect output
    - Steps:
        1. `actions/checkout@v4`
        2. `actions/setup-node@v4` with `node-version: lts/*`
        3. `npx skills-ref validate ${{ matrix.skill }}`

## Dependencies

Only first-party GitHub Actions (`actions/checkout`, `actions/setup-node`). Changed file
detection uses plain `git diff`.

## Branch Strategy

Implement on a `chore/ci-workflows` branch and verify via PR.
