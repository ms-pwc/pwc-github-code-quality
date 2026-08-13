# Security Policy

## Reporting a vulnerability

Report suspected vulnerabilities through GitHub private vulnerability reporting (Security > Advisories > Report a vulnerability) when it is enabled for this repository. If private reporting is not enabled yet, contact the repository owners through the approved internal security channel.

## Security controls used by this repository

This repository (`main` branch) uses **GitHub-native code quality and security tooling** instead of a third-party server such as SonarQube. See [docs/github-code-quality-configuration-readme.md](docs/github-code-quality-configuration-readme.md) for full configuration details and a feature-by-feature comparison with the `sonarqube` branch.

### GitHub-native security features

- **CodeQL code scanning** (`.github/workflows/codeql.yml`) – Analyzes C# code for security vulnerabilities and quality issues (SQL/command injection, weak cryptography, insecure deserialization, etc.) using the `security-and-quality` query pack. Results appear under **Security > Code scanning alerts**.
- **Dependabot alerts + updates** (`.github/dependabot.yml`) – Detects vulnerable/outdated NuGet and GitHub Actions dependencies and opens pull requests to update them. Alerts appear under **Security > Dependabot alerts**.
- **Secret scanning** – Detects committed secrets/credentials (enable from **Settings > Code security > Secret scanning**). Alerts appear under **Security > Secret scanning alerts**.
- **Severity levels** – CodeQL alerts are rated Critical, High, Medium, Low, or Warning/Note; Dependabot alerts use CVSS-derived severities.
- **Branch protection quality gate** – Required status checks (`quality-gate.yml`, `codeql.yml`) and required CODEOWNERS review enforce the merge policy below (**Settings > Branches > Branch protection rules**).

### Merge policy

Pull requests must:

1. Pass the `Quality Gate (Build, Format, Test)` workflow.
2. Pass the `CodeQL Analysis` workflow with no new Critical/High severity alerts.
3. Have zero open Dependabot alerts introduced by the change.
4. Receive CODEOWNERS approval for affected areas.

### Code scanning alert review

CodeQL alerts are identified but may need triage, similar to SonarQube's Security Hotspots. The security team must:

1. Review the alert under **Security > Code scanning alerts**.
2. Classify it as:
   - **Open** – Fix the issue before merge.
   - **Dismissed** (false positive / won't fix / used in tests) – Justification is recorded in the dismissal reason.

### Dependency management

Dependencies are tracked in `*.csproj` files and monitored automatically:

1. Dependabot opens a pull request when an update or fix is available.
2. Review the PR diff and the linked advisory (if any), then merge.
3. Review **Security > Dependabot alerts** for anything not yet covered by an automatic PR.

### Incident response

If a security issue is found:

1. Open a private security advisory in GitHub (if enabled).
2. Create a fix branch: `git checkout -b security/CVE-XXXX-XXXXX`.
3. Address the vulnerability and test the fix.
4. Submit a pull request with `[SECURITY]` in the title.
5. Request expedited review from the security team.
6. Merge and deploy quickly.

## GitHub configuration for security

This repository is configured through:

- `.github/workflows/codeql.yml` – CodeQL initialization, build, and analysis for `csharp` using the `security-and-quality` query suite.
- `.github/codeql/codeql-config.yml` – Path filters so only `src` and `tests` are analyzed.
- `.github/dependabot.yml` – Weekly NuGet and GitHub Actions dependency checks.

For details and a comparison against the SonarQube-based approach, see [docs/github-code-quality-configuration-readme.md](docs/github-code-quality-configuration-readme.md).
