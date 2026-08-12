# Repository Settings To Enable In GitHub

These settings cannot be fully represented as files. Enable them after pushing this repository to GitHub.

## Branch protection or rulesets

Protect `main` and require:

- Pull request before merge.
- At least one approval.
- CODEOWNERS approval.
- Conversation resolution before merge.
- Linear history if that is the organization standard.
- Required status checks:
  - `Build, test, and style checks`
  - `Analyze C# with CodeQL`
  - `Block vulnerable or disallowed dependencies`
  - `Supply-chain posture scan`

## Code security and analysis

Enable these repository or organization features:

- Code scanning default setup or advanced setup. This repo uses advanced setup through `.github/workflows/codeql.yml`.
- Dependabot alerts.
- Dependabot security updates.
- Dependency graph.
- Secret scanning.
- Secret scanning push protection.
- Private vulnerability reporting.

## Merge policy

Recommended merge policy for governed repositories:

- Disable direct pushes to `main` except for repository administrators or release automation.
- Require all conversations to be resolved.
- Require signed commits if the organization uses commit signing.
- Block force pushes.
- Block branch deletion for protected branches.

## Organization rollout pattern

For multiple repositories, create an organization ruleset and reusable workflows instead of copying every setting manually. Keep repository-specific thresholds in small config files so each team can tune risk without bypassing central policy.