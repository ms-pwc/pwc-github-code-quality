# GitHub Code Quality Showcase - SonarQube Branch

This is the **SonarQube branch** of the pwc-github-code-quality repository. Instead of using GitHub-native quality controls, this branch uses **SonarQube** as the centralized code quality and security analysis platform.

The sample application is identical to the main branch; only the quality infrastructure differs. This branch demonstrates:

- Local SonarQube setup without Docker using portable files under `.tools`.
- Optional Docker Compose setup for teams that prefer containers.
- SonarQube Scanner integration in CI/CD (GitHub Actions workflow).
- Local scanning scripts for developer workstations.
- Configuration for both self-hosted and SaaS SonarQube instances.
- Project quality gates and dashboards.

## What is configured

| Area | SonarQube implementation | Outcome |
| --- | --- | --- |
| Build quality gate | `.github/workflows/build-and-sonarqube-scan.yml` | Builds, tests, and submits analysis to SonarQube before merge. |
| Static code analysis | SonarQube scanner for C# | Analyzes security, maintainability, reliability, and duplicated code. |
| Quality gate enforcement | SonarQube server-side quality gates | Blocks merge if project fails configured SonarQube quality criteria. |
| Duplicate detection | Built-in SonarQube analyzer | Detects duplicated code across the project. |
| Security scanning | SonarQube security rules | Identifies OWASP, CWE, and banking security vulnerabilities. |
| Technical debt | SonarQube metrics dashboard | Displays technical debt ratio and maintainability index. |
| Multi-branch analysis | SonarQube branch comparison | Compares quality metrics across branches. |
| Coverage integration | Coverage reports → SonarQube | Optional: upload coverage reports from test runs. |
| Centralized dashboard | SonarQube project page | Single dashboard for all quality and security metrics. |
| Historical tracking | SonarQube timeline | View trends in quality, coverage, and technical debt over time. |

## Repository layout

```text
.github/
  workflows/
    build-and-sonarqube-scan.yml    GitHub Actions: build, test, and scan with SonarQube
scripts/
  start-portable-sonarqube.ps1       PowerShell: download and start SonarQube without Docker
  stop-portable-sonarqube.ps1        PowerShell: stop portable SonarQube
  run-portable-sonarqube-scan.ps1    PowerShell: run local analysis without global tools
  setup-local-sonarqube.ps1         PowerShell: start local SonarQube via Docker Compose
  setup-local-sonarqube.sh          Bash: start local SonarQube via Docker Compose
  run-sonarqube-scan.ps1            PowerShell: run SonarQube analysis locally
  run-sonarqube-scan.sh             Bash: run SonarQube analysis locally
src/QualityDemo/                    .NET library with quality gate logic
tests/QualityDemo.Tests/            Dependency-free test runner
docker-compose.yml                  Docker Compose: PostgreSQL + SonarQube container setup
docs/                               SonarQube decision and setup documentation
SECURITY.md                         Vulnerability reporting and control summary
```

## Quick start: Local SonarQube setup

### 1. Start the local SonarQube server without Docker

This is the preferred lightweight local demo path. It downloads portable Java and SonarQube under `.tools` and does not install system services.

```powershell
.\scripts\start-portable-sonarqube.ps1
```

The server will be available at `http://localhost:9000` after 1-2 minutes. Login with `admin` / `admin`, change the password, and generate a token.

### 2. Run a local scan without global tools

```powershell
$env:SONAR_LOGIN = "your-copied-token"
.\scripts\run-portable-sonarqube-scan.ps1
```

After the scan completes, view results at `http://localhost:9000`.

### Optional: Docker-based local setup

**Windows (PowerShell):**
```powershell
.\scripts\setup-local-sonarqube.ps1
```

**Linux/macOS (Bash):**
```bash
chmod +x scripts/setup-local-sonarqube.sh
./scripts/setup-local-sonarqube.sh
```

This starts a Docker Compose stack with SonarQube and PostgreSQL. Use this only if Docker is already approved for your machine.

### Login and generate a token

1. Open http://localhost:9000 in your browser.
2. Login with default credentials: `admin` / `admin`.
3. Go to **Administration** > **Security** > **Users** > click the **admin** user > **Tokens**.
4. Generate a new token (e.g., "Local Dev") and copy it.

### Run a Docker-based local scan

Set the token as an environment variable and run the scan:

**Windows (PowerShell):**
```powershell
$env:SONAR_LOGIN = "your-copied-token"
.\scripts\run-sonarqube-scan.ps1
```

**Linux/macOS (Bash):**
```bash
export SONAR_LOGIN="your-copied-token"
./scripts/run-sonarqube-scan.sh
```

After the scan completes, view results at http://localhost:9000/dashboard (the project will appear in the projects list).

## Run locally (build only, without SonarQube)

```powershell
dotnet restore Pwc.GitHubCodeQuality.slnx
dotnet build Pwc.GitHubCodeQuality.slnx --configuration Release
dotnet format Pwc.GitHubCodeQuality.slnx --verify-no-changes --verbosity minimal
dotnet run --project tests/QualityDemo.Tests/QualityDemo.Tests.csproj --configuration Release --no-build
```

## Documentation

- [sonarqube-setup-guide.md](docs/sonarqube-setup-guide.md) – Complete setup and configuration instructions.
- [sonarqube-workflow-guide.md](docs/sonarqube-workflow-guide.md) – Workflow integration and developer experience.
- [self-hosted-vs-saas.md](docs/self-hosted-vs-saas.md) – Comparison of self-hosted and SaaS SonarQube.
- [quality-profiles-and-gates.md](docs/quality-profiles-and-gates.md) – Quality profiles, gates, and metrics.

## SonarQube server lifecycle

Stop the SonarQube server:
```bash
docker-compose down
```

Remove volumes (resets the database; only do this for testing):
```bash
docker-compose down -v
```

## GitHub Actions integration

The workflow in `.github/workflows/build-and-sonarqube-scan.yml` requires:

- `SONAR_HOST_URL` – URL of your SonarQube instance (defaults to `http://localhost:9000` for local testing).
- `SONAR_LOGIN` – Authentication token generated in SonarQube.

For a self-hosted GitHub environment, set these as repository or organization secrets before running the workflow.

## Next steps

1. Choose your SonarQube deployment model: see [self-hosted-vs-saas.md](docs/self-hosted-vs-saas.md).
2. Customize quality profiles and gates in the SonarQube UI or in scanner arguments used by the workflow/scripts.
3. Integrate into your CI/CD pipeline with proper credentials.
4. Roll out to other repositories using the same pattern.
