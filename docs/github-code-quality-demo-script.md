# GitHub Code Quality — Demonstration Script

A step-by-step walkthrough for presenting the GitHub-native code quality setup
on the `main` branch as a replacement for the SonarQube setup on the
`sonarqube` branch.

**Repository:** https://github.com/ms-pwc/pwc-github-code-quality
**All results below were captured from real workflow runs on 2026-08-13.**

For full configuration details and the honest gap analysis, see
[github-code-quality-configuration-readme.md](github-code-quality-configuration-readme.md).

---

## Setup before the demo

Nothing to start. Unlike SonarQube — which needed a server on `localhost:9000`,
a database, an auth token, and a scanner install — there is no infrastructure.
Just open the repository in a browser.

Optionally have two tabs ready:
- **Actions** tab
- **Security > Code scanning** tab

---

## Part 1 — Frame the problem (2 min)

> "We previously proved out code quality with SonarQube. It works, but it needs
> a server we host, patch, back up, and license. The question was: can GitHub's
> native tooling give us the same protection with no server at all?
>
> Both branches contain **identical application code** — the same deliberately
> insecure training fixtures. The only difference is the scanning approach.
> That makes this a fair comparison."

Show the two branches:
- `sonarqube` — SonarQube scanner + `docker-compose.yml` + tokens
- `main` — GitHub-native workflows only

---

## Part 2 — Show what replaced SonarQube (3 min)

Open the **Actions** tab. Three workflows replaced the single SonarQube scan:

| Workflow | Replaces | Result |
| --- | --- | --- |
| `Quality Gate (Build, Format, Test)` | The build/test half of the Sonar workflow | **success** (30s) |
| `CodeQL Analysis` | SonarQube's security scanner | **success** (1m23s, 164 rules) |
| `.NET Analyzers (SARIF to Code Scanning)` | SonarQube's syntactic rule engine | **success** (8 findings) |

Talking point:

> "No `SONAR_HOST_URL`. No `SONAR_LOGIN` secret. No scanner CLI to install.
> The configuration is four small files committed to the repository."

---

## Part 3 — The honest moment: CodeQL alone found almost nothing (5 min)

**This is the most valuable part of the demo. Do not skip it.**

Open **Security > Code scanning** and filter to the CodeQL tool. Show that
CodeQL ran **164 rules** and produced exactly **1 alert**:

```
note   cs/path-combine   src/QualityDemo/TrainingOnlyThreatWorkbench.cs:292
```

Then ask the room: *"The code has hard-coded passwords, MD5, SHA1, string-
concatenated SQL, shell command injection, and disabled TLS validation. Why did
CodeQL stay quiet?"*

The answer:

> **CodeQL is a data-flow (taint-tracking) engine.** It raises a security alert
> only when it can prove untrusted input reaches a dangerous sink. This
> repository is a **class library with no entry points** — no HTTP controller,
> no `Main` that reads arguments. There is no *source* of untrusted data, so the
> injection queries find no complete path and correctly stay silent.
>
> **SonarQube reports these because it also applies syntactic rules** that flag
> insecure API usage on sight, regardless of whether it is reachable.
>
> Neither tool is "wrong" — they answer different questions. CodeQL answers
> *"can an attacker actually exploit this?"*. SonarQube answers *"is this code
> using a dangerous API?"*.

**Key takeaway to state explicitly:**

> A clean CodeQL result on a library is **not** a clean bill of health. If we
> had swapped SonarQube for CodeQL alone, we would have silently lost coverage.

---

## Part 4 — Closing the gap natively (4 min)

> "The fix is not to bring SonarQube back. It is to add the syntactic layer that
> was missing — and .NET already ships one: the Roslyn analyzers."

Show [src/QualityDemo/QualityDemo.csproj](../src/QualityDemo/QualityDemo.csproj):
- `EnableNETAnalyzers` + `AnalysisMode=All` — the full rule set, the GitHub-native
  equivalent of a SonarQube quality profile.
- `WarningsNotAsErrors` — the fixtures are *reported* as alerts without breaking
  the build.

Show [.github/workflows/dotnet-analyzers.yml](../.github/workflows/dotnet-analyzers.yml):
the compiler writes SARIF, and the SARIF is uploaded to code scanning — so
Roslyn findings land in the **same Security tab** as CodeQL.

Now show the **8 additional alerts**:

| Rule | Meaning | Location |
| --- | --- | --- |
| `CA5351` | Broken cryptographic algorithm (MD5) | `TrainingOnlyInsecureExamples.cs:28` |
| `CA5350` | Weak cryptographic algorithm (SHA1) | `TrainingOnlyThreatWorkbench.cs:120` |
| `CA5394` | Insecure random number generator | `TrainingOnlyInsecureExamples.cs:28` |
| `CA5394` | Insecure random number generator | `TrainingOnlyThreatWorkbench.cs:128` |
| `CA2000` | Disposable object not disposed | `TrainingOnlyInsecureExamples.cs:38` |
| `CA2000` | Disposable object not disposed | `TrainingOnlyThreatWorkbench.cs:146` |
| `CA1822` | Member can be marked static (maintainability) | `QualityGateEvaluator.cs:5` |
| `CA1822` | Member can be marked static (maintainability) | `RepositoryRiskClassifier.cs:12` |

**Total: 9 alerts in one unified view (1 CodeQL + 8 Roslyn).**

### Bonus talking point: suppressions hide findings

The MD5, SHA1, and XXE rules were originally hidden behind
`#pragma warning disable` in the fixture files. Those suppressions were removed
so the rules actually fire.

> "A scanner can only report what it is allowed to see. Inline suppressions are
> invisible in the dashboard — worth auditing across any real codebase."

---

## Part 5 — Dependency security, automated (3 min)

Open the **Pull requests** tab. Dependabot opened three PRs on its own within
minutes of the config being committed:

| PR | Title |
| --- | --- |
| #1 | Bump actions/checkout from 4 to 7 |
| #2 | Bump actions/setup-dotnet from 4 to 6 |
| #3 | Bump github/codeql-action from 3 to 4 |

Talking point:

> "This is where GitHub is clearly **ahead** of SonarQube. SonarQube tells you a
> dependency is outdated or vulnerable. Dependabot opens the pull request that
> fixes it, and our quality gate workflow has already run against each one.
>
> PR #3 is a nice example: the CodeQL run warned that CodeQL Action v3 is
> deprecated in December 2026, and Dependabot had already raised the upgrade."

Note each Dependabot PR shows the `Quality Gate` and `CodeQL` checks running —
the gate applies to bot PRs exactly as it does to human ones.

---

## Part 6 — The merge gate (2 min)

Show the merge policy is enforced by GitHub itself, not an external server:

- **Settings > Branches** — required status checks: `Build, format check, and test`,
  `Analyze (csharp)`, `Run .NET analyzers and publish SARIF`.
- [.github/CODEOWNERS](../.github/CODEOWNERS) — required reviewers.
- [.github/pull_request_template.md](../.github/pull_request_template.md) — reviewer checklist.
- [SECURITY.md](../SECURITY.md) — documented merge policy and alert triage process.

> "With SonarQube, the gate result had to travel from our server back to GitHub
> as a status check. Here the gate *is* GitHub — one less integration to break."

---

## Part 7 — Where GitHub does NOT match SonarQube (3 min)

Be direct about this; it builds credibility.

| Capability | Status |
| --- | --- |
| Unified metrics dashboard (one project health screen) | **Not available.** Alerts are split across Code scanning / Dependabot / Secret scanning. |
| Code duplication percentage | **Not available natively.** Needs a separate tool. |
| Maintainability rating (A–E) / technical debt estimate | **Not available.** |
| Coverage tracking + coverage-based gate | **Not native.** Requires a third-party Action such as Codecov. |
| Per-metric historical trend graphs | **Not available** (only alert open/closed history). |
| Findings on unreachable library code | **Weaker than SonarQube** even with Roslyn added — TLS-validation and XXE fixtures were not flagged by either tool. |
| Generic hard-coded password literals | **Not flagged** by secret scanning (it targets recognizable provider token formats). |

Recommended honest conclusion:

> "For **security scanning and merge gating**, GitHub-native tooling does the job
> with no server, no licence for the engine, and better automated remediation.
>
> For **code-health metrics** — duplication, technical debt, maintainability
> ratings, coverage trends — GitHub has no equivalent today. If those metrics
> are contractual or governance requirements, keep SonarQube for reporting, or
> add a targeted tool for the specific metric. Do not assume a straight swap."

---

## Part 8 — Reproduce it live (optional, 2 min)

```powershell
dotnet build Pwc.GitHubCodeQuality.slnx --configuration Release
dotnet format Pwc.GitHubCodeQuality.slnx --verify-no-changes --verbosity minimal
dotnet run --project tests/QualityDemo.Tests/QualityDemo.Tests.csproj --configuration Release --no-build
```

Expected output: build succeeds with the 8 analyzer warnings shown inline,
formatting is clean, and `All 10 quality demo tests passed.`

To reproduce the SARIF that feeds code scanning:

```powershell
New-Item -ItemType Directory -Force -Path sarif | Out-Null
dotnet build Pwc.GitHubCodeQuality.slnx -c Release --no-incremental `
  -p:SarifOutputDir="$PWD/sarif" -p:TreatWarningsAsErrors=false
./scripts/Merge-AnalyzerSarif.ps1 -InputDirectory sarif -OutputPath dotnet-analyzers.sarif
```

---

## One-slide summary

| | SonarQube (`sonarqube` branch) | GitHub-native (`main` branch) |
| --- | --- | --- |
| Infrastructure | Server + database + token | **None** |
| Security scanning | Syntactic rule engine | CodeQL (data-flow) + Roslyn analyzers (syntactic) |
| Findings on this repo | Many | 9 alerts (1 CodeQL + 8 Roslyn) |
| Results location | `localhost:9000` dashboard | GitHub Security tab |
| Merge gate | Sonar gate → status check | Native required checks |
| Dependency fixes | Flags them | **Opens the fix PR** |
| Duplication / tech debt / coverage metrics | Yes | **No** |
| Ongoing ops burden | Patching, backups, upgrades | **None** |

---

## Questions to expect

**"Did we lose security coverage by dropping SonarQube?"**
On this library, yes — partially. Section 4 of the configuration readme lists
exactly which fixtures went unreported. On a real application with HTTP entry
points, CodeQL's data-flow analysis typically finds *more* real, exploitable
issues than SonarQube's syntactic rules, with far fewer false positives.

**"Can we run both?"**
Yes, and that is a valid strategy. They are complementary rather than mutually
exclusive: CodeQL for exploitability, SonarQube for code-health metrics.

**"What does it cost?"**
CodeQL, Dependabot, and secret scanning are free on public repositories. On
private repositories they require GitHub Advanced Security — confirm your
organization's current entitlement before committing to a migration.

**"How do we handle false positives?"**
Dismiss the alert in the Security tab with a reason (false positive / won't fix
/ used in tests). The dismissal and its justification are recorded and
auditable — equivalent to SonarQube's issue resolution workflow.
