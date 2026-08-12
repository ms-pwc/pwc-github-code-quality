# SonarQube Branch Quick Start

Welcome to the **sonarqube** branch! This branch demonstrates how to use SonarQube as your centralized code quality and security analysis platform instead of GitHub-native quality controls.

## What you'll need

- **Docker Desktop** (Windows, macOS) or **Docker + Docker Compose** (Linux)
  - Download: https://www.docker.com/products/docker-desktop/
  - On Linux: `sudo apt-get install docker-compose` (Ubuntu/Debian)
- **.NET 10 SDK** (or later) for building and scanning
  - Download: https://dotnet.microsoft.com/download
- **GitHub** account (optional, for pushing and running workflows)

## 5-minute setup

### Step 1: Start local SonarQube

Navigate to the repository and run:

**Windows (PowerShell):**
```powershell
.\scripts\setup-local-sonarqube.ps1
```

**macOS / Linux (Bash):**
```bash
chmod +x scripts/setup-local-sonarqube.sh
./scripts/setup-local-sonarqube.sh
```

The script will start PostgreSQL and SonarQube containers. SonarQube will be ready at `http://localhost:9000` in about 60 seconds.

### Step 2: Login and generate a token

1. Open http://localhost:9000 in your browser
2. Login: `admin` / `admin`
3. Go to **Administration** > **Security** > **Users** > click the **admin** user > **Tokens**
4. Create a token named "Local Dev" and copy it

### Step 3: Run a scan

**Windows (PowerShell):**
```powershell
$env:SONAR_LOGIN = "your-token-here"
.\scripts\run-sonarqube-scan.ps1
```

**macOS / Linux (Bash):**
```bash
export SONAR_LOGIN="your-token-here"
./scripts/run-sonarqube-scan.sh
```

### Step 4: View results

Open http://localhost:9000 and find the "pwc-github-code-quality" project to see:
- **Code Smells** – Maintainability issues
- **Bugs** – Reliability issues
- **Vulnerabilities** – Security issues
- **Duplications** – Duplicated code
- **Coverage** – Test coverage (if available)
- **Quality Gate** – Pass/fail status

## What's different from the main branch

| Aspect | Main branch | SonarQube branch |
| --- | --- | --- |
| **Quality platform** | GitHub-native (CodeQL, Dependabot) | SonarQube (centralized server) |
| **Scans** | Per-repository GitHub Actions | Centralized SonarQube analysis |
| **Dashboards** | Distributed (GitHub security view) | Unified SonarQube project dashboard |
| **Quality gates** | GitHub branch protection | SonarQube server-side gates |
| **Data location** | GitHub infrastructure | Your infrastructure (self-hosted) or SonarSource (SaaS) |
| **Workflow** | `.github/workflows/quality-gate.yml` | `.github/workflows/build-and-sonarqube-scan.yml` |

## Key files

- **docker-compose.yml** – Starts PostgreSQL + SonarQube containers
- **sonar-project.properties** – SonarQube project configuration
- **.github/workflows/build-and-sonarqube-scan.yml** – GitHub Actions workflow for CI/CD
- **scripts/setup-local-sonarqube.ps1** – PowerShell setup script
- **scripts/run-sonarqube-scan.ps1** – PowerShell scan script
- **docs/sonarqube-setup-guide.md** – Complete setup instructions
- **docs/sonarqube-workflow-guide.md** – Workflow integration guide
- **docs/self-hosted-vs-saas.md** – Self-hosted vs. SaaS comparison
- **docs/quality-profiles-and-gates.md** – Quality configuration guide

## Documentation

Read these in order for a complete understanding:

1. **[sonarqube-setup-guide.md](docs/sonarqube-setup-guide.md)** – Detailed installation and configuration
2. **[sonarqube-workflow-guide.md](docs/sonarqube-workflow-guide.md)** – How SonarQube integrates with GitHub Actions
3. **[quality-profiles-and-gates.md](docs/quality-profiles-and-gates.md)** – Customizing quality rules and gates
4. **[self-hosted-vs-saas.md](docs/self-hosted-vs-saas.md)** – Choosing between self-hosted and SaaS

## Common tasks

### Stop SonarQube

```bash
docker-compose stop
```

### Remove SonarQube (keep data)

```bash
docker-compose down
```

### Reset SonarQube (delete all data)

```bash
docker-compose down -v
```

### Run tests without SonarQube

```powershell
dotnet restore Pwc.GitHubCodeQuality.slnx
dotnet build Pwc.GitHubCodeQuality.slnx --configuration Release
dotnet run --project tests/QualityDemo.Tests/QualityDemo.Tests.csproj --configuration Release --no-build
```

### Troubleshooting

**SonarQube not starting?**
- Ensure Docker is running: `docker ps`
- Check logs: `docker-compose logs sonarqube`
- Port 9000 in use? Change port in `docker-compose.yml` and try again

**Authentication failed?**
- Verify token copied correctly (no spaces)
- Regenerate token in SonarQube if needed

**"Quality Gate failed"?**
- Review SonarQube dashboard to see which condition failed
- Either fix the code or adjust the quality gate in SonarQube

## Using in GitHub Actions

After pushing to GitHub, add these secrets to your repository:

- `SONAR_LOGIN` – Your SonarQube authentication token
- `SONAR_HOST_URL` – SonarQube URL (optional; defaults to `http://localhost:9000`)

For a SaaS SonarQube Cloud instance:
- `SONAR_LOGIN` – Your SonarCloud token
- `SONAR_HOST_URL` – Set to `https://sonarcloud.io`

The workflow will automatically run on every push to `main` and pull request.

## Moving to production

When ready to deploy SonarQube to production:

1. **Choose your deployment model** – See [self-hosted-vs-saas.md](docs/self-hosted-vs-saas.md)
2. **Self-hosted?** – Set up on your infrastructure (cloud VM, K8s, on-premises)
3. **SaaS?** – Sign up at https://sonarcloud.io and connect your GitHub org
4. **Update workflow** – Change `SONAR_HOST_URL` secret to your production instance
5. **Customize quality profiles** – See [quality-profiles-and-gates.md](docs/quality-profiles-and-gates.md)
6. **Enable branch protection** – Require quality gate to pass before merge

## Comparing with main branch

To see the differences between GitHub-native quality (main) and SonarQube quality (sonarqube branch):

```bash
git diff main..sonarqube -- .github/workflows/
```

This shows the workflow changes. The application code is identical.

## Support and feedback

For questions or issues:

1. Check the docs folder for detailed guides
2. Review SonarQube logs: `docker-compose logs -f sonarqube`
3. Check the workflow run logs in GitHub Actions
4. See [sonarqube-setup-guide.md](docs/sonarqube-setup-guide.md) troubleshooting section

## Next steps

- ✅ Start SonarQube locally
- ✅ Generate an auth token
- ✅ Run your first scan
- ✅ Customize quality profiles and gates
- ✅ Integrate with GitHub Actions
- ✅ Push to GitHub and enable secrets
- ✅ Decide: self-hosted or SaaS for production?

Happy scanning! 🚀
