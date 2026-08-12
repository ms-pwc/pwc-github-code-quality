# SonarQube Branch Setup Complete

You now have **two branches** demonstrating different code quality approaches:

## Branch Comparison

### `main` branch (GitHub-native quality)
- Uses **GitHub Actions** with **CodeQL** for security scanning
- Uses **Dependabot** for dependency updates
- Uses **OpenSSF Scorecard** for supply-chain security
- Quality gates managed via GitHub branch protection
- Data stays within GitHub infrastructure

### `sonarqube` branch (SonarQube-based quality)
- Uses **SonarQube** as the centralized quality platform
- **Self-hosted** via Docker Compose (PostgreSQL + SonarQube)
- Supports both **self-hosted** and **SaaS (SonarQube Cloud)** deployments
- Server-side quality gates and profiles
- Comprehensive metrics: duplicates, technical debt, coverage, etc.

---

## SonarQube Branch: Quick Start

### Prerequisites
- Docker Desktop (or Docker + Docker Compose)
- .NET 10 SDK
- ~2GB RAM + 3GB disk space

### 1. Start SonarQube locally

**Windows (PowerShell):**
```powershell
cd c:\Users\v-naveshetty\OneDrive - Microsoft\Desktop\GithubRepo\pwc-github-code-quality
git checkout sonarqube
.\scripts\setup-local-sonarqube.ps1
```

**macOS/Linux (Bash):**
```bash
cd <path-to-repo>
git checkout sonarqube
chmod +x scripts/setup-local-sonarqube.sh
./scripts/setup-local-sonarqube.sh
```

The script will:
- Start PostgreSQL container
- Start SonarQube container
- Wait for both to be healthy (~60 seconds)
- Display access info

### 2. Login to SonarQube

Open http://localhost:9000 in your browser
- Username: `admin`
- Password: `admin`

### 3. Generate authentication token

1. Click avatar (top-right) → **My Account**
2. Go to **Security** tab
3. Click **Generate** under Tokens
4. Name it "Local Dev" and copy the token

### 4. Run a local scan

**Windows (PowerShell):**
```powershell
$env:SONAR_LOGIN = "your-token-from-step-3"
.\scripts\run-sonarqube-scan.ps1
```

**macOS/Linux (Bash):**
```bash
export SONAR_LOGIN="your-token-from-step-3"
./scripts/run-sonarqube-scan.sh
```

### 5. View results

After scan completes, refresh http://localhost:9000
- Project "pwc-github-code-quality" will appear
- View metrics: bugs, code smells, vulnerabilities, duplicates, coverage

---

## Key Files in SonarQube Branch

### Docker & Local Setup
- **docker-compose.yml** – Starts PostgreSQL + SonarQube containers
- **scripts/run-portable-sonarqube-scan.ps1** – SonarQube configuration for the local .NET scan

### CI/CD Workflow
- **.github/workflows/build-and-sonarqube-scan.yml** – GitHub Actions workflow that builds, tests, and scans with SonarQube

### Setup & Scanning Scripts
- **scripts/setup-local-sonarqube.ps1** – PowerShell: Start SonarQube server
- **scripts/setup-local-sonarqube.sh** – Bash: Start SonarQube server
- **scripts/run-sonarqube-scan.ps1** – PowerShell: Run SonarQube scan
- **scripts/run-sonarqube-scan.sh** – Bash: Run SonarQube scan

### Documentation
| File | Purpose |
| --- | --- |
| **QUICK_START.md** | 5-minute setup guide (start here!) |
| **docs/sonarqube-setup-guide.md** | Complete installation and configuration |
| **docs/sonarqube-workflow-guide.md** | GitHub Actions integration guide |
| **docs/quality-profiles-and-gates.md** | How to customize quality rules and gates |
| **docs/self-hosted-vs-saas.md** | Self-hosted vs. SaaS comparison for production |

### Application Code (Same as main branch)
- **src/QualityDemo/** – .NET library with quality gate logic
- **tests/QualityDemo.Tests/** – Dependency-free test runner

---

## What's Different from Main Branch

| Item | Main | SonarQube |
| --- | --- | --- |
| Quality platform | GitHub-native (CodeQL) | SonarQube (centralized) |
| Deployment | No setup needed | Docker Compose required |
| Data location | GitHub cloud | Your infrastructure |
| Dashboards | Distributed (GitHub UI) | Unified (SonarQube UI) |
| Quality gates | GitHub branch protection | SonarQube server-side |
| Duplicates detection | Not built-in | Yes, built-in |
| Technical debt ratio | No | Yes |
| Coverage tracking | Basic | Advanced |
| Workflow file | `quality-gate.yml` | `build-and-sonarqube-scan.yml` |

---

## Architecture Comparison

### Main Branch (GitHub-native)
```
GitHub PR
    ↓
GitHub Actions
    ├→ Build
    ├→ CodeQL Scan
    ├→ Dependabot Check
    └→ OpenSSF Scorecard
    ↓
GitHub Checks (pass/fail)
    ↓
Branch Protection (merge gate)
```

### SonarQube Branch
```
GitHub PR
    ↓
GitHub Actions
    ├→ Build
    ├→ Test
    └→ SonarQube Scanner
        ↓
        SonarQube Server (local or cloud)
            ├→ Code Analysis
            ├→ Security Scanning
            ├→ Quality Gate Evaluation
            └→ Metrics & Trends Dashboard
    ↓
GitHub Checks (SonarQube quality gate status)
    ↓
Branch Protection (merge gate)
```

---

## Self-Hosted vs. SaaS

### Self-Hosted (Current demo setup)
**Pros:**
- Code stays on your network
- No data leaves your organization
- Full control over configuration
- Cost-effective at scale (1000+ projects)

**Cons:**
- Requires Docker/infrastructure management
- Need to manage upgrades and backups
- Operational overhead

**Use when:**
- Regulatory compliance requires data residency
- You have many projects (100+)
- You have DevOps/operations team

### SaaS (SonarQube Cloud)
**Pros:**
- Zero infrastructure overhead
- Automatic updates and patches
- Instantly scalable
- SonarSource manages security/uptime

**Cons:**
- Code sent to SonarSource servers
- Per-project or per-contributor pricing
- Less customization

**Use when:**
- You want minimal overhead
- You're comfortable with cloud analysis
- Code can leave your network
- Small number of projects (< 100)

**To switch to SaaS:**
1. Sign up: https://sonarcloud.io
2. Connect your GitHub org
3. Update `.github/workflows/build-and-sonarqube-scan.yml`:
   ```yaml
   SONAR_HOST_URL: https://sonarcloud.io
   ```

---

## Troubleshooting

### SonarQube won't start
```bash
# Check if Docker is running
docker ps

# Check logs
docker-compose logs sonarqube

# Port 9000 in use? Try stopping it
docker-compose down
```

### Scanner authentication fails
- Copy token directly from SonarQube UI (no extra spaces)
- Verify environment variable is set:
  - PowerShell: `Write-Host $env:SONAR_LOGIN`
  - Bash: `echo $SONAR_LOGIN`

### "Quality Gate failed"
- Check SonarQube dashboard for which condition failed
- Either fix the code or adjust gate thresholds in SonarQube UI

### Tests pass locally but fail in GitHub Actions
- Ensure the .NET version in workflow matches your local SDK
- Check for platform-specific differences (Windows vs. Linux)

---

## Next Steps

1. **Start local SonarQube:**
   - Run `.\scripts\setup-local-sonarqube.ps1` (Windows) or `./scripts/setup-local-sonarqube.sh` (Linux/macOS)

2. **Read the docs:**
   - Start with `QUICK_START.md`
   - Then read `docs/sonarqube-setup-guide.md`

3. **Customize quality profiles:**
   - See `docs/quality-profiles-and-gates.md`

4. **Plan for production:**
   - Review `docs/self-hosted-vs-saas.md`

5. **Push to GitHub:**
   - Add `SONAR_LOGIN` and optionally `SONAR_HOST_URL` as repository secrets
   - The workflow will run automatically on push/PR

6. **Demo to stakeholders:**
   - Show both branches
   - Explain why you chose one approach
   - Highlight security and quality benefits

---

## File Locations

```
pwc-github-code-quality/
├── QUICK_START.md                              ← Start here!
├── docker-compose.yml                          ← Local SonarQube setup
├── .github/
│   └── workflows/
│       └── build-and-sonarqube-scan.yml       ← CI/CD workflow
├── scripts/
│   ├── setup-local-sonarqube.ps1              ← Start SonarQube (Windows)
│   ├── setup-local-sonarqube.sh               ← Start SonarQube (Linux/macOS)
│   ├── run-sonarqube-scan.ps1                 ← Run scan (Windows)
│   └── run-sonarqube-scan.sh                  ← Run scan (Linux/macOS)
├── docs/
│   ├── sonarqube-setup-guide.md               ← Complete setup guide
│   ├── sonarqube-workflow-guide.md            ← CI/CD integration
│   ├── quality-profiles-and-gates.md          ← Quality customization
│   └── self-hosted-vs-saas.md                 ← Deployment decision
├── src/QualityDemo/                           ← Application code
└── tests/QualityDemo.Tests/                   ← Tests
```

---

## Switching Between Branches

```bash
# View both branches
git branch -v

# Switch to main (GitHub-native quality)
git checkout main

# Switch to sonarqube (SonarQube-based quality)
git checkout sonarqube

# Compare branches
git diff main sonarqube -- .github/workflows/
```

---

**You're all set!** 🚀 

Start with the QUICK_START.md guide, and you'll have SonarQube running locally in minutes.
