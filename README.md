# pwc-github-code-quality

This is the **main** branch: the GitHub-native code-quality upgrade of the
SonarQube-controlled application on the `sonarqube` branch. It replaces the
separate scanning platform in the pull-request path with one GitHub workflow,
CodeQL, Roslyn SARIF, Dependabot, secret scanning, and target branch governance.

## Start here

1. [docs/01-SonarQube-to-GitHub-Native-Upgrade-Demonstration.docx](docs/01-SonarQube-to-GitHub-Native-Upgrade-Demonstration.docx) —
	concise client demonstration: SonarQube baseline first, then the GitHub-native upgrade, results, advantages, and drawbacks.
2. [docs/02-GitHub-Native-Code-Quality-Setup-and-Migration-Runbook.docx](docs/02-GitHub-Native-Code-Quality-Setup-and-Migration-Runbook.docx) —
	from-scratch manual setup, repository settings, validation, migration, rollback, troubleshooting, and exact workflows.

## What's configured on this branch

| File | Purpose |
| --- | --- |
| [.github/workflows/code-quality.yml](.github/workflows/code-quality.yml) | One workflow with build/format/test, CodeQL, and Roslyn SARIF jobs |
| [.github/codeql/codeql-config.yml](.github/codeql/codeql-config.yml) | CodeQL path scope (matches SonarQube's exclusions) |
| [.github/dependabot.yml](.github/dependabot.yml) | Weekly NuGet + GitHub Actions dependency updates |
| [Directory.Build.props](Directory.Build.props) | Per-project SARIF output for analyzer results |
| [.github/CODEOWNERS](.github/CODEOWNERS) | Required reviewers for merge gating |
| [.github/pull_request_template.md](.github/pull_request_template.md) | GitHub Code Quality PR checklist |
| [SECURITY.md](SECURITY.md) | Security controls and merge policy |

## Shared code fixture files (functionally equivalent to `sonarqube` branch)

The branches exercise the same scenario, but `main` removes selected Roslyn
suppressions so those diagnostics can be published to GitHub code scanning.

- [src/QualityDemo/TrainingOnlyInsecureExamples.cs](src/QualityDemo/TrainingOnlyInsecureExamples.cs)
- [src/QualityDemo/TrainingOnlyThreatWorkbench.cs](src/QualityDemo/TrainingOnlyThreatWorkbench.cs)
- [src/QualityDemo/PortfolioQualityStory.cs](src/QualityDemo/PortfolioQualityStory.cs)
- [tests/QualityDemo.Tests/Program.cs](tests/QualityDemo.Tests/Program.cs)

## Results (verified on GitHub, 2026-08-13)

The results below are from the equivalent verified jobs before consolidation;
the next push runs those same commands as three jobs in `code-quality.yml`.

| Check | Result |
| --- | --- |
| `Build, format, and test` job | verified success — build ok, formatting clean, 10/10 tests passed |
| `CodeQL (C#)` job | verified success — 171 C# queries loaded, **1 alert** (`cs/path-combine`) |
| `Roslyn analyzers to code scanning` job | verified success — **8 alerts** (MD5, SHA1, insecure RNG x2, CA2000 x2, CA1822 x2) |
| Code scanning total | **9 open alerts** from both tools in one Security tab |
| `Dependabot` | opened update PRs automatically (checkout v4→v7, setup-dotnet v4→v6, codeql-action v3→v4) |

**Key insight:** CodeQL alone found almost nothing on these deliberately
insecure fixtures because it is a data-flow engine and this repository is a
library with no entry points — there is no untrusted input source for its taint
queries to follow. Roslyn analyzers (syntactic, like SonarQube's rule engine)
close most of that gap. Use the demonstration and migration runbook linked above
for the complete evidence and implementation steps.