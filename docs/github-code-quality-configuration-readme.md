# GitHub Code Quality Configuration Readme (main branch)

This file explains what was configured on the `main` branch to replace SonarQube
with **GitHub-native code quality and security tooling**, how to run it, what
results to expect, and — importantly — where GitHub-native tooling does **not**
fully match what SonarQube provides (so the demo is honest about trade-offs).

It mirrors the structure of [docs/sonarqube-configuration-readme.md](../docs/sonarqube-configuration-readme.md)
(on the `sonarqube` branch) so the two can be compared side by side.

---

## 1. What was configured

### CI workflows

| File | Purpose |
| --- | --- |
| `.github/workflows/codeql.yml` | Runs CodeQL static analysis (security + quality queries) for C#. Equivalent to the SonarQube scanner step. |
| `.github/workflows/quality-gate.yml` | Restores, builds, checks formatting (`dotnet format`), and runs tests. Equivalent to the build/test half of `build-and-sonarqube-scan.yml`. |

Both workflows trigger on `push`/`pull_request` to `main` and `workflow_dispatch`.
`codeql.yml` also runs on a weekly schedule so alerts refresh even without new commits.

### CodeQL configuration
- File: `.github/codeql/codeql-config.yml`
- Restricts analysis to `src/` and `tests/`, ignoring `bin/`, `obj/`, generated files, and `docs/` —
  the same effective scope as the `sonar.exclusions` setting used for SonarQube.
- Uses the `security-and-quality` query suite (broader than the CodeQL default
  `security-extended` suite) so results include maintainability-style findings,
  not just vulnerabilities, for closer parity with SonarQube's combined report.

### Supply-chain / dependency configuration
- File: `.github/dependabot.yml`
- Weekly checks for the `nuget` and `github-actions` ecosystems, opening pull
  requests automatically. This is the GitHub-native equivalent of SonarQube's
  dependency vulnerability detection.

### Governance files
- `.github/CODEOWNERS` – required reviewers for merge gating.
- `.github/pull_request_template.md` – GitHub Code Quality checklist for PR authors/reviewers.
- `SECURITY.md` – updated to describe the GitHub-native security controls and merge policy.

### Shared application code (identical to `sonarqube` branch)
The training fixtures that produce findings are unchanged between branches, so
the two approaches are analyzing the same code:
- `src/QualityDemo/TrainingOnlyInsecureExamples.cs`
- `src/QualityDemo/TrainingOnlyThreatWorkbench.cs`
- `src/QualityDemo/PortfolioQualityStory.cs`
- `tests/QualityDemo.Tests/Program.cs`

---

## 2. What you need (no external server)

Unlike SonarQube, there is **no server to install, no Docker container, and no
localhost dashboard**. Everything runs as part of GitHub Actions and results
are stored/rendered by GitHub itself:

- A GitHub repository with **GitHub Advanced Security** features available
  (code scanning and secret scanning are free for public repos; on private
  repos they require GitHub Advanced Security licensing on GitHub Enterprise,
  or are included for free on GitHub.com public/organization repos as of the
  current GitHub feature set — verify current entitlements for your org).
- `.NET 10 SDK` locally only if you want to build/test/format-check before pushing.
- No secrets/tokens are required for CodeQL or Dependabot (unlike
  `SONAR_HOST_URL` / `SONAR_LOGIN` for SonarQube).

---

## 3. Steps to reproduce / demonstrate

### Step 1 — Validate locally (optional, mirrors CI)

```powershell
dotnet restore Pwc.GitHubCodeQuality.slnx
dotnet build Pwc.GitHubCodeQuality.slnx --configuration Release
dotnet format Pwc.GitHubCodeQuality.slnx --verify-no-changes --verbosity minimal
dotnet run --project tests/QualityDemo.Tests/QualityDemo.Tests.csproj --configuration Release --no-build
```

Local results captured for this demo (main branch, 2026-08-13):

```
Build succeeded in 7.8s
dotnet format: no violations (command produced no output)
PASS passes when all GitHub quality signals are clean
PASS fails when security, coverage, duplication, or review gates fail
PASS classifies large risky pull requests as high risk
PASS classifies small clean pull requests as low risk
PASS computes a positive threat exposure score
PASS builds unsafe SQL and shell command fixtures
PASS builds duplicated gateway digest fixtures
PASS processes XML and legacy signature fixtures
PASS creates insecure network and dtd parsing fixtures
PASS calculates portfolio quality trend values
All 10 quality demo tests passed.
```

### Step 2 — Enable GitHub security features (one-time, per repository)

In the GitHub repository (**Settings > Code security**):
1. Enable **Dependency graph**.
2. Enable **Dependabot alerts** and **Dependabot security updates**.
3. Enable **Code scanning** (it activates automatically once `codeql.yml` runs,
   but confirm "Default setup" is not also enabled to avoid a duplicate/conflicting config).
4. Enable **Secret scanning** (and push protection, if available for your plan).

### Step 3 — Push and trigger the workflows

```powershell
git push origin main
```

This triggers both `Quality Gate (Build, Format, Test)` and `CodeQL Analysis`
under the **Actions** tab.

### Step 4 — View results

- **Actions tab** – pass/fail status for both workflows (equivalent to the CI
  portion of the SonarQube workflow).
- **Security > Code scanning alerts** – CodeQL findings, each with severity,
  rule description, and the exact file/line (equivalent to SonarQube's
  Bugs/Vulnerabilities/Code Smells list, minus the aggregate dashboard view).
- **Security > Dependabot alerts** – vulnerable dependency findings, and
  **Pull requests** tab shows auto-generated update PRs.
- **Security overview** (organization or repo level) – a rollup across
  alert types; the closest GitHub-native equivalent to a single dashboard,
  though it is alert-centric rather than metric-centric (no maintainability
  rating, duplication %, or technical debt figures).

### Step 5 — Enforce as a merge gate

In **Settings > Branches > Branch protection rules** for `main`:
- Require status checks to pass: `Build, format check, and test`, `Analyze (csharp)`.
- Require a pull request before merging, with CODEOWNERS review required.
- (Optional) Require signed commits / linear history per your org policy.

This reproduces the same "quality gate before merge" experience as
SonarQube's quality gate + branch protection combination.

---

## 4. Expected findings on this codebase

Because the training fixtures are shared with the `sonarqube` branch, CodeQL
is expected to flag the same categories of issues SonarQube reports, using
its own rule IDs:

| Fixture | Pattern | Expected CodeQL finding |
| --- | --- | --- |
| `TrainingOnlyInsecureExamples.CreateWeakDemoFingerprint` | `MD5.HashData` | Use of a broken/weak cryptographic hash function |
| `TrainingOnlyInsecureExamples.CreateUnsafeHttpClient` | `ServerCertificateCustomValidationCallback = (...) => true` | Disabled certificate validation |
| `TrainingOnlyInsecureExamples.DemonstrateUntrustedInputSinks` | `File.ReadAllText(userSuppliedPath)`, `Process.Start("cmd.exe", ...)` | Path injection / OS command injection |
| `TrainingOnlyThreatWorkbench.BuildUnsafeSql` / `BuildUnsafeAuditSql` | string-concatenated SQL | SQL injection (data flow from untrusted input) |
| `TrainingOnlyThreatWorkbench.BuildUnsafeShellCommand` | interpolated shell command | Command injection |
| `TrainingOnlyThreatWorkbench.ComputeLegacySignature` | `SHA1.HashData` | Use of a broken/weak cryptographic hash function |
| `TrainingOnlyThreatWorkbench.BuildPredictableToken` | `System.Random` for a token | Insecure randomness |
| `TrainingOnlyThreatWorkbench.LoadXmlAndReadNode` / `ParseXmlWithDtd` | `XmlUrlResolver` + DTD processing enabled | XML External Entity (XXE) injection |
| `TrainingOnlyThreatWorkbench.CreateInsecurePartnerClient` | disabled TLS validation | Disabled certificate validation |
| `LegacyApiKey` / `LegacyDbPassword` / `DemoPassword` constants | hard-coded literals | Hard-coded credentials (flagged by secret scanning if the pattern matches a known provider format; generic literals may not be caught — see Section 5) |

> Exact rule names/IDs depend on the CodeQL query pack version used at scan time; view the live alert text in **Security > Code scanning alerts** after the workflow runs.

---

## 5. Where GitHub-native tooling does **not** fully match SonarQube (be upfront about this)

| Capability | SonarQube | GitHub-native (CodeQL/Dependabot) | Gap |
| --- | --- | --- | --- |
| Unified quality dashboard (bugs, smells, vulnerabilities, coverage, duplication, tech debt in one screen) | Yes | Partial — alerts are split across Code scanning / Dependabot / Secret scanning tabs; Security Overview rolls up counts but not code metrics | **Yes, real gap.** No single "project health" screen with trend graphs. |
| Code duplication detection (%) | Yes, built-in | No built-in equivalent | **Gap.** CodeQL does not compute a duplication percentage. Would need a separate tool (e.g., a duplication linter) if this metric is required. |
| Maintainability rating / Technical debt ratio (time-to-fix estimates) | Yes | No | **Gap.** GitHub does not estimate remediation time or assign A–E maintainability ratings. |
| Code coverage tracking & trend | Yes, with quality gate thresholds | No native coverage UI; requires a third-party Action (e.g., Codecov) and does not gate merges out of the box | **Gap**, workaround available via Actions + a coverage-comment/gate Action, but it is not "native." |
| Historical trend graphs per metric | Yes | Only alert open/closed history, not metric trend lines | **Partial gap.** |
| Generic hard-coded secret/password literal detection (not a recognizable provider token format) | Yes (pattern + heuristic rules) | Secret scanning focuses on recognizable provider token formats/entropy; a plain string like `"DbPassword-Training-Only"` may not be flagged | **Partial gap** — verify by checking actual alerts; do not assume 100% parity for generic secrets. |
| Custom rule authoring / quality profiles per team | Yes, quality profiles per language | Possible via custom CodeQL queries, but requires QL authoring skill; less turnkey than SonarQube's rule toggles | **Partial gap** — higher effort to customize. |
| On-prem/data-residency option | Yes (self-hosted) | No — CodeQL analysis runs in GitHub-hosted (or self-hosted) Actions runners, but alert storage/UI is GitHub.com/GHES-bound | Only a gap if you are on GitHub.com and require full data residency outside GitHub. GHES (self-hosted GitHub) closes this gap. |
| Cost at very large project counts | Can be cheaper self-hosted at 100+ projects | Included with GitHub Advanced Security entitlement / free for public repos | Depends on licensing — not a strict gap, just a different cost model. |

### What GitHub-native tooling does **better or equal**
- Zero infrastructure to run/patch/upgrade (no Docker, no Postgres, no scanner CLI install).
- Alerts are inline on the PR diff with suggested fixes for some CodeQL rules — faster reviewer feedback loop than a separate dashboard link.
- Native integration with branch protection, CODEOWNERS, and PR checks — no external status-check webhook needed.
- Dependabot auto-remediation (opens the fix PR directly) vs. SonarQube only flagging the dependency.
- No licensing/hosting cost for the analysis engine itself on qualifying repos.

**Conclusion for the demo:** GitHub-native tooling (CodeQL + Dependabot + Secret
scanning + branch protection) reproduces the *security scanning* and *merge-gate*
value of SonarQube well, and does it with less operational overhead. It does
**not** reproduce SonarQube's unified metrics dashboard, duplication %,
maintainability rating, or technical debt estimate — call this out explicitly
when presenting results so stakeholders have accurate expectations.

---

## 6. Quick comparison summary

| Aspect | `sonarqube` branch | `main` branch |
| --- | --- | --- |
| Quality platform | SonarQube (self-hosted via Docker) | GitHub-native (CodeQL, Dependabot, Secret scanning) |
| Setup effort | Docker Compose + token generation + scanner config | Add workflow/config files only |
| Where results live | `http://localhost:9000` project dashboard | GitHub **Security** tab + **Actions** tab |
| Dashboard/metrics | Bugs, vulnerabilities, code smells, duplications, coverage, tech debt, quality gate | Code scanning alerts, Dependabot alerts, Secret scanning alerts, Security Overview counts |
| Merge gate | SonarQube quality gate + branch protection | Required status checks + CODEOWNERS + branch protection |
| Data location | Your infrastructure (or SonarCloud) | GitHub.com (or GHES if self-hosted) |
| Duplication / tech debt metrics | Yes | Not available natively |

---

## 7. Notes

- This document intentionally lists the gaps in Section 5 so the GitHub-native
  demo is not oversold as a 1:1 SonarQube replacement — it is a genuine
  alternative with different strengths, not a strict superset.
- If duplication %, maintainability rating, or coverage trend graphs are hard
  requirements, keep SonarQube (or add a supplementary Action such as
  Codecov/Codacy) alongside CodeQL rather than removing SonarQube entirely.
