# Security Policy

## Reporting a vulnerability

Report suspected vulnerabilities through GitHub private vulnerability reporting (Security > Advisories > Report a vulnerability) when it is enabled for this repository. If private reporting is not enabled yet, contact the repository owners through the approved internal security channel.

## Security controls used by this repository

This repository (`main` branch) demonstrates **GitHub-native code quality and security tooling** as the upgrade path from the SonarQube baseline. See the [client demonstration](docs/01-SonarQube-to-GitHub-Native-Upgrade-Demonstration.docx) for evidence and the [setup and migration runbook](docs/02-GitHub-Native-Code-Quality-Setup-and-Migration-Runbook.docx) for exact configuration and governance steps.

### GitHub-native security features

- **CodeQL code scanning** (`.github/workflows/code-quality.yml`) – The consolidated workflow analyzes C# code with the `security-and-quality` query pack and uploads Roslyn SARIF findings. Results appear under **Security > Code scanning alerts**.
- **Dependabot alerts + updates** (`.github/dependabot.yml`) – Detects vulnerable/outdated NuGet and GitHub Actions dependencies and opens pull requests to update them. Alerts appear under **Security > Dependabot alerts**.
- **Secret scanning** – Detects committed secrets/credentials (enable from **Settings > Code security > Secret scanning**). Alerts appear under **Security > Secret scanning alerts**.
- **Severity levels** – CodeQL alerts are rated Critical, High, Medium, Low, or Warning/Note; Dependabot alerts use CVSS-derived severities.
- **Target branch quality gate** – Configure an active GitHub ruleset to require the quality, CodeQL, analyzer, and CODEOWNERS checks. The demonstration document distinguishes this target control from the repository's currently verified settings.

### Target merge policy

Pull requests must:

1. Pass the `Build, format, and test` job in the `GitHub Native Code Quality` workflow.
2. Pass the `CodeQL (C#)` and `Roslyn analyzers to code scanning` jobs with no unacceptable new alerts.
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

- `.github/workflows/code-quality.yml` – One workflow containing the quality gate, CodeQL, and Roslyn SARIF jobs.
- `.github/codeql/codeql-config.yml` – Path filters so only `src` and `tests` are analyzed.
- `.github/dependabot.yml` – Weekly NuGet and GitHub Actions dependency checks.

For details, see the [client demonstration](docs/01-SonarQube-to-GitHub-Native-Upgrade-Demonstration.docx) and [setup and migration runbook](docs/02-GitHub-Native-Code-Quality-Setup-and-Migration-Runbook.docx).
