# SonarQube Configuration Readme (Hosted Server)

This file explains what was configured to get the current SonarQube results and how to reproduce it manually.

## 1. What was configured

### CI workflow
- File: `.github/workflows/build-and-sonarqube-scan.yml`
- Purpose: Run restore, build, tests, and SonarQube scan in GitHub Actions.
- Trigger: push, pull_request, workflow_dispatch (currently configured for `main`).

### Local/Manual scan scripts
- File: `scripts/run-portable-sonarqube-scan.ps1`
- File: `scripts/run-sonarqube-scan.ps1`
- Purpose: Run scanner from local machine and publish coverage.

### Shared code changes (on both `main` and `sonarqube`)
- Added scanner training fixtures and issue patterns in:
  - `src/QualityDemo/TrainingOnlyInsecureExamples.cs`
  - `src/QualityDemo/TrainingOnlyThreatWorkbench.cs`
  - `src/QualityDemo/PortfolioQualityStory.cs`
- Added/updated tests that execute fixtures and produce real coverage:
  - `tests/QualityDemo.Tests/Program.cs`

## 2. Connection details required for hosted SonarQube

For hosted SonarQube, you need:
- SonarQube URL (example: `https://sonarqube.yourcompany.com`)
- Project key (configured as `pwc-github-code-quality`)
- User token with permission to analyze project

### GitHub secrets required
Set these in repository secrets:
- `SONAR_HOST_URL` = your hosted SonarQube URL
- `SONAR_LOGIN` = generated SonarQube token

## 3. Scanner options that matter

These are the key scanner settings used:
- `sonar.host.url`
- `sonar.login`
- `sonar.cs.vscoveragexml.reportsPaths=TestResults/coverage.xml`
- `sonar.sourceEncoding=UTF-8`
- `sonar.scanner.scanAll=false`
- `sonar.scm.disabled=true`
- `sonar.exclusions=**/.tools/**,**/.sonarqube/**,**/bin/**,**/obj/**,docs/**,scripts/**,.github/**`
- `sonar.qualitygate.wait=true` (portable script)

## 4. Why coverage is not zero now

Coverage is generated using `dotnet-coverage` and imported into SonarQube:
1. Build solution
2. Run tests through coverage collector
3. Save report to `TestResults/coverage.xml`
4. Pass that report path to Sonar scanner

## 5. Manual SonarQube UI steps (simple)

1. Login to SonarQube.
2. Create project (or use existing project key: `pwc-github-code-quality`).
3. Generate token (My Account -> Security -> Generate Token).
4. Set quality gate (use default Sonar way or your custom gate).
5. Set new code definition (recommended: previous version).
6. (Optional) Assign quality profile for C#.
7. Run scanner from CI or local script using host URL and token.
8. Open project dashboard and verify:
   - Lines of Code
   - Coverage
   - Vulnerabilities
   - Bugs
   - Code Smells
   - Duplications
   - Security Hotspots

## 6. If you want workflow-only setup

Yes, this is achievable mostly by workflow + scanner config:
- Keep the workflow file with scanner begin/build/end steps.
- Keep secrets configured.
- Ensure coverage file is generated in workflow before `sonarscanner end`.

Code fixtures are only needed if you intentionally want demo findings (vulnerabilities, duplication, hotspots, etc.).

## 7. Minimal command examples

### PowerShell local run (hosted server)
```powershell
$env:SONAR_HOST_URL = "https://sonarqube.yourcompany.com"
$env:SONAR_LOGIN = "<token>"
.\scripts\run-sonarqube-scan.ps1 -SonarHostUrl $env:SONAR_HOST_URL -SonarLogin $env:SONAR_LOGIN
```

### Portable run
```powershell
$env:SONAR_LOGIN = "<token>"
.\scripts\run-portable-sonarqube-scan.ps1 -SonarHostUrl "https://sonarqube.yourcompany.com" -SonarLogin $env:SONAR_LOGIN
```

## 8. Notes

- If scanner lock issues occur in `.sonarqube`, run scan from a clean folder/worktree copy.
- If dashboard and docs are Sonar-only branch artifacts, keep them in `sonarqube` branch.
- Shared code fixtures were mirrored to both branches as requested.
