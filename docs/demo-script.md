# Customer Demo Script

Use this script to present the repository as a GitHub-native code quality reference implementation.

## 1. Explain the goal

This repository shows how GitHub can replace much of the day-to-day SonarQube pull request experience by moving quality signals into the developer workflow: checks, code scanning, dependency risk, ownership review, and branch protection.

## 2. Show the code quality model

Open `src/QualityDemo/QualityGateEvaluator.cs` and explain that the sample code models the same decision points a real repository would enforce:

- Critical code scanning alerts must be fixed.
- High severity alerts are not allowed by default.
- Coverage must meet the configured threshold.
- Duplicated lines must remain below the configured threshold.
- CODEOWNERS review is required.
- Required GitHub Actions checks must pass.

## 3. Show the pull request checks

Open `.github/workflows/quality-gate.yml` and explain the required status check:

- Restore dependencies.
- Build with analyzer warnings as errors.
- Verify formatting.
- Run the quality gate tests.

## 4. Show security and quality scanning

Open `.github/workflows/codeql.yml` and `.github/codeql/codeql-config.yml`.

Explain that CodeQL findings appear under GitHub code scanning alerts and can be required before merge through branch protection and rulesets.

## 5. Show dependency and supply-chain controls

Open `.github/dependabot.yml`, `.github/workflows/dependency-review.yml`, and `.github/workflows/scorecard.yml`.

Explain that GitHub can both prevent new risky dependency changes and continuously raise update pull requests.

## 6. Show governance settings

Open `docs/repository-settings.md` and explain which controls are files and which controls must be enabled in GitHub settings.

## 7. Be transparent about SonarQube differences

Open `docs/sonarqube-to-github-map.md` and highlight the partial or non-native areas:

- Universal duplicate-code metrics.
- SonarQube-style maintainability ratings.
- Technical debt ratio dashboards.
- Server-side quality profiles.

The recommendation is not to hide these gaps. The stronger message is that GitHub can enforce the merge decision directly, and exact SonarQube-style metrics can be added only where the business still needs them.