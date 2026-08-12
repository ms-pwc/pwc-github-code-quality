# Quality Gate Design

The demo quality gate is intentionally simple and readable. It maps GitHub signals to a merge decision that business and engineering stakeholders can discuss.

## Inputs

`PullRequestSignal` represents the signals normally collected from GitHub checks and code scanning:

- Changed lines.
- Critical and high code scanning alerts.
- Coverage percentage.
- Duplicated lines percentage.
- CODEOWNERS review state.
- Required build status.

## Thresholds

`QualityGateOptions.Recommended` starts with conservative thresholds:

- Minimum coverage: 80%.
- Maximum duplicated lines: 3%.
- Maximum high severity alerts: 0.

Production repositories should tune these thresholds by language, application criticality, and current baseline.

## Why this exists

GitHub does not force every team into a single quality gate model. That is useful during migration because each repository can start with transparent, versioned policy and then move shared rules into organization rulesets and reusable workflows.

## How to extend

- Add a real test coverage collector for the target language.
- Add a duplication scanner that emits SARIF or a failing check.
- Add custom CodeQL queries for organization-specific risks.
- Publish workflow summaries so reviewers see the score without opening logs.
- Move common policy into a reusable workflow when rolling out to many repositories.