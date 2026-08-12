# Migration Plan For Other Repositories

Use this sequence after the customer agrees to pilot GitHub-native quality controls.

## Phase 1: Baseline

- Inventory languages, build systems, current SonarQube gates, and required metrics.
- Enable dependency graph, Dependabot alerts, code scanning, and secret scanning.
- Add CodeQL for supported languages.
- Add existing test commands to GitHub Actions.

## Phase 2: Enforce pull request quality

- Add branch protection or organization rulesets.
- Require build, test, CodeQL, and Dependency Review checks.
- Add CODEOWNERS for critical areas.
- Add PR templates that make quality exceptions visible.

## Phase 3: Fill SonarQube gaps only where needed

- Add coverage threshold checks.
- Add duplication analysis if the business uses duplication as a required metric.
- Add language-specific linters that publish SARIF into code scanning.
- Add custom CodeQL queries for organization patterns.

## Phase 4: Scale centrally

- Convert common workflows into reusable workflows.
- Apply organization rulesets.
- Track adoption through GitHub security overview, workflow history, and repository scorecards.
- Retire SonarQube project by project when required GitHub evidence is accepted.