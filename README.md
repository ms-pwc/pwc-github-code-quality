# pwc-github-code-quality

This is the **main** branch: a demonstration of code quality and security
scanning using **GitHub-native tooling** (CodeQL, Dependabot, Secret scanning,
branch protection) instead of a self-hosted third-party server.

The `sonarqube` branch runs the same application code through SonarQube
instead, so the two branches can be compared directly.

## Start here

- [docs/github-code-quality-demo-script.md](docs/github-code-quality-demo-script.md) —
	step-by-step walkthrough for presenting this to stakeholders
- [docs/github-code-quality-configuration-readme.md](docs/github-code-quality-configuration-readme.md) —
	full configuration, real scan results, and an honest gap analysis vs SonarQube

## What's configured on this branch

| File | Purpose |
| --- | --- |
| [.github/workflows/codeql.yml](.github/workflows/codeql.yml) | CodeQL security + quality analysis for C# |
| [.github/workflows/dotnet-analyzers.yml](.github/workflows/dotnet-analyzers.yml) | .NET (Roslyn) analyzers exported as SARIF to code scanning |
| [.github/workflows/quality-gate.yml](.github/workflows/quality-gate.yml) | Build, format check, and test |
| [.github/codeql/codeql-config.yml](.github/codeql/codeql-config.yml) | CodeQL path scope (matches SonarQube's exclusions) |
| [.github/dependabot.yml](.github/dependabot.yml) | Weekly NuGet + GitHub Actions dependency updates |
| [Directory.Build.props](Directory.Build.props) | Per-project SARIF output for analyzer results |
| [.github/CODEOWNERS](.github/CODEOWNERS) | Required reviewers for merge gating |
| [.github/pull_request_template.md](.github/pull_request_template.md) | GitHub Code Quality PR checklist |
| [SECURITY.md](SECURITY.md) | Security controls and merge policy |

## Shared code fixture files (identical to `sonarqube` branch)

- [src/QualityDemo/TrainingOnlyInsecureExamples.cs](src/QualityDemo/TrainingOnlyInsecureExamples.cs)
- [src/QualityDemo/TrainingOnlyThreatWorkbench.cs](src/QualityDemo/TrainingOnlyThreatWorkbench.cs)
- [src/QualityDemo/PortfolioQualityStory.cs](src/QualityDemo/PortfolioQualityStory.cs)
- [tests/QualityDemo.Tests/Program.cs](tests/QualityDemo.Tests/Program.cs)

## Results (verified on GitHub, 2026-08-13)

| Check | Result |
| --- | --- |
| `Quality Gate (Build, Format, Test)` | success — build ok, formatting clean, 10/10 tests passed |
| `CodeQL Analysis` | success — 164 rules, **1 alert** (`cs/path-combine`) |
| `.NET Analyzers (SARIF to Code Scanning)` | success — **8 alerts** (MD5, SHA1, insecure RNG x2, CA2000 x2, CA1822 x2) |
| Code scanning total | **9 open alerts** from both tools in one Security tab |
| `Dependabot` | opened update PRs automatically (checkout v4→v7, setup-dotnet v4→v6, codeql-action v3→v4) |

**Key insight:** CodeQL alone found almost nothing on these deliberately
insecure fixtures because it is a data-flow engine and this repository is a
library with no entry points — there is no untrusted input source for its taint
queries to follow. Roslyn analyzers (syntactic, like SonarQube's rule engine)
close most of that gap. The full explanation and the remaining gaps are in the
documentation linked above.