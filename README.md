# pwc-github-code-quality

This is the **main** branch: a demonstration of code quality and security
scanning using **GitHub-native tooling** (CodeQL, Dependabot, Secret scanning,
branch protection) instead of a self-hosted third-party server.

The `sonarqube` branch runs the same application code through SonarQube
instead, so the two branches can be compared directly.

## Start here

Full configuration, step-by-step demo instructions, expected findings, and an
honest comparison (including gaps) against the SonarQube approach:

- [docs/github-code-quality-configuration-readme.md](docs/github-code-quality-configuration-readme.md)

## What's configured on this branch

| File | Purpose |
| --- | --- |
| [.github/workflows/codeql.yml](.github/workflows/codeql.yml) | CodeQL security + quality analysis for C# |
| [.github/workflows/quality-gate.yml](.github/workflows/quality-gate.yml) | Build, format check, and test |
| [.github/codeql/codeql-config.yml](.github/codeql/codeql-config.yml) | CodeQL path scope (matches SonarQube's exclusions) |
| [.github/dependabot.yml](.github/dependabot.yml) | Weekly NuGet + GitHub Actions dependency updates |
| [.github/CODEOWNERS](.github/CODEOWNERS) | Required reviewers for merge gating |
| [.github/pull_request_template.md](.github/pull_request_template.md) | GitHub Code Quality PR checklist |
| [SECURITY.md](SECURITY.md) | Security controls and merge policy |

## Shared code fixture files (identical to `sonarqube` branch)

- [src/QualityDemo/TrainingOnlyInsecureExamples.cs](src/QualityDemo/TrainingOnlyInsecureExamples.cs)
- [src/QualityDemo/TrainingOnlyThreatWorkbench.cs](src/QualityDemo/TrainingOnlyThreatWorkbench.cs)
- [src/QualityDemo/PortfolioQualityStory.cs](src/QualityDemo/PortfolioQualityStory.cs)
- [tests/QualityDemo.Tests/Program.cs](tests/QualityDemo.Tests/Program.cs)

## Results (last local validation)

```
dotnet build   -> succeeded
dotnet format  -> no violations
dotnet test    -> 10/10 passed
```

CodeQL and Dependabot results are only visible after pushing to GitHub and
letting Actions run (see the docs above) — there is no local dashboard
equivalent to SonarQube's `http://localhost:9000`.