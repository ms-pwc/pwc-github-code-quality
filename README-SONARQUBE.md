# SonarQube Code Quality Branch (Latest)

This branch (`sonarqube-latest`) demonstrates comprehensive code quality analysis using **SonarQube 10.7 LTS** (latest long-term support version).

## Quick Start

### Prerequisites
- SonarQube 10.7+ running locally (see [RUNBOOK.md](../RUNBOOK.md#installing-latest-sonarqube-locally))
- SonarQube `SONAR_HOST_URL` and `SONAR_TOKEN` secrets configured in GitHub
- .NET 10.0+ SDK

### Run Analysis Locally

```powershell
# Install SonarScanner tool
dotnet tool install --global dotnet-sonarscanner

# Start analysis
dotnet sonarscanner begin `
  /k:"pwc-github-code-quality" `
  /n:"PWC GitHub Code Quality" `
  /d:sonar.host.url="http://localhost:9000" `
  /d:sonar.login="your_sonar_token" `
  /d:sonar.cs.opencover.reportsPaths="coverage/coverage.opencover.xml"

# Build and test with coverage
dotnet build Pwc.GitHubCodeQuality.slnx --configuration Release
dotnet test tests/QualityDemo.Tests/QualityDemo.Tests.csproj `
  --collect:"XPlat Code Coverage" `
  --results-directory coverage

# End analysis
dotnet sonarscanner end /d:sonar.login="your_sonar_token"

# View results
Start-Process "http://localhost:9000/dashboard?id=pwc-github-code-quality"
```

---

## All 6 Quality Components in SonarQube

### Component 1: Security ✅

**What SonarQube tracks:**
- Vulnerabilities (CVSS-based ratings)
- Security hotspots (code requiring manual review)
- CWE/OWASP tracking

**Findings in this project:**
- Weak cryptography (MD5, SHA1 hashing)
- Insecure RNG (Random generation)
- XXE/XML injection risks
- Insecure TLS configurations

**Where to find it:**
```
SonarQube Dashboard
  → Measures
    → Security
      → Rating: Shows A/B/C/D/E grade
      → Vulnerabilities: Count of issues
      → Security Hotspots: Requires review
```

**SonarQube vs GitHub:**
| Metric | SonarQube | GitHub Code Quality |
|--------|-----------|---------------------|
| Finding source | Syntactic + data-flow | CodeQL + Roslyn |
| Hotspots | Native concept | Via CODEOWNERS |
| Review workflow | Built-in UI | PR approval process |

---

### Component 2: Maintainability ✅

**What SonarQube tracks:**
- Code smells (violation of best practices)
- Technical debt (time to fix issues)
- Complexity metrics
- Duplicate code

**Findings in this project:**
- Nested ternary operators (complexity)
- Unused variables
- Long parameter lists
- Duplicated code blocks

**Where to find it:**
```
SonarQube Dashboard
  → Measures
    → Maintainability
      → Rating: Shows A/B/C/D/E grade
      → Code Smells: Count of issues
      → Technical Debt: Estimated time to fix
```

**Calculation:**
- Rating based on density of code smells
- A = 0-5% of code volume is problematic
- E = >50% problematic

---

### Component 3: Reliability ✅

**What SonarQube tracks:**
- Bugs (logic errors, resource leaks)
- Improper error handling
- Null pointer exceptions
- Resource disposal issues

**Findings in this project:**
- Resource not disposed (IDisposable)
- Potential null references
- Logic errors in conditionals

**Where to find it:**
```
SonarQube Dashboard
  → Measures
    → Reliability
      → Rating: Shows A/B/C/D/E grade
      → Bugs: Count of issues
```

**Equivalent metrics:**
- SonarQube "Bug": Issue requiring fix to prevent runtime error
- GitHub "Reliability alert": CA2000 (IDisposable), logic analysis

---

### Component 4: Code Coverage ✅

**What SonarQube tracks:**
- Line coverage (% of lines executed in tests)
- Branch coverage (% of conditional paths tested)
- Historical trends

**How it works:**
1. Generate coverage report: `dotnet test --collect:"XPlat Code Coverage"`
2. SonarScanner reads `coverage/coverage.opencover.xml`
3. Results aggregated and displayed in dashboard

**Where to find it:**
```
SonarQube Dashboard
  → Measures
    → Coverage
      → Overall: X.X%
      → Line Coverage: X.X%
      → Branch Coverage: X.X%
      → Uncovered Lines: Highlighted in code view
```

**Current project coverage:**
- Expected: ~85% (from unit tests)
- Tracked: Line and branch coverage
- Trending: Available in history view

---

### Component 5: Security Hotspots Review ✅

**What SonarQube tracks:**
- Security-sensitive code (cryptography, auth, file ops)
- Manual review requirement
- Reviewed vs. unreviewed count

**Process:**
1. SonarQube identifies potentially dangerous operations
2. Security team reviews each hotspot
3. Mark as "Reviewed" after assessment
4. Metrics track % of hotspots reviewed

**Where to find it:**
```
SonarQube Dashboard
  → Measures
    → Security Hotspots
      → To Review: Count of unreviewed hotspots
      → Reviewed: Count of reviewed hotspots
      → Review %: X% reviewed
```

**In this project:**
- TrainingOnlyThreatWorkbench.cs: Cryptography hotspots
- TrainingOnlyInsecureExamples.cs: Multiple hotspots
- Each requires manual review and classification

**Hotspot Review Workflow:**
1. Go to **Security → Security Hotspots** tab
2. Click each hotspot
3. Review the code
4. Mark as:
   - ✓ **Reviewed** - Assessed and decision made
   - 🔒 **Fixed** - Vulnerability was resolved
   - 🤷 **Safe** - False positive or intended

---

### Component 6: Duplication ✅

**What SonarQube tracks:**
- Duplicated blocks (minimum 10 lines)
- Duplication density (% of duplicated lines)
- File-level and project-level metrics

**Analysis method:**
- Syntactic clone detection
- Configurable minimum block size
- Cross-file detection

**Where to find it:**
```
SonarQube Dashboard
  → Measures
    → Duplication
      → Duplication: X.X% (percent of duplicated lines)
      → Duplicated Blocks: N blocks
      → Duplicated Lines: N lines
```

**In this project:**
- **TrainingOnlyThreatWorkbench.cs**: 30-line duplicated block
  - `BuildGatewayRiskDigestA()` and `BuildGatewayRiskDigestB()` are nearly identical
  - Creates 60 lines of duplication
  - File density: ~19.5%
  - Project density: ~7.6%

**Duplication reduction strategies:**
1. Extract common method
2. Use base class or interface
3. Apply strategy or factory pattern
4. Template method pattern

---

## SonarQube Dashboard Navigation

### Main Metrics View
```
Dashboard → Measures (Left sidebar)
```

All 6 components visible in one place:
- **Security**: Rating + Vulnerabilities
- **Reliability**: Rating + Bugs  
- **Maintainability**: Rating + Code Smells + Technical Debt
- **Coverage**: % + Trend
- **Security Hotspots**: To Review / Reviewed
- **Duplication**: % + Blocks

### Detailed Issue Analysis
```
Dashboard → Issues (Left sidebar)
```

Filter by:
- Type: Bug, Vulnerability, Code Smell
- Severity: Critical, Major, Minor, Info
- Status: Open, Confirmed, False Positive, Won't Fix

### Security Hotspot Review
```
Dashboard → Security → Security Hotspots
```

Interactive review workflow for each hotspot

### Coverage Details
```
Dashboard → Code (Left sidebar) → Choose file
```

Line-by-line coverage visualization

---

## GitHub Actions Workflow

The workflow (`.github/workflows/build-and-sonarqube-scan.yml`) automatically:

1. ✅ Checks out code (full history for analysis)
2. ✅ Builds solution in Release mode
3. ✅ Runs tests with XPlat coverage collection
4. ✅ Installs SonarScanner CLI tool
5. ✅ Runs SonarQube analysis with coverage data
6. ✅ Waits for quality gate result
7. ✅ Provides dashboard link

**Secrets required in GitHub:**
- `SONAR_HOST_URL`: Your SonarQube instance URL
- `SONAR_TOKEN`: SonarQube authentication token

**Add secrets:**
1. Go to Repository → Settings → Secrets and variables → Actions
2. Create `SONAR_HOST_URL` = `http://localhost:9000`
3. Create `SONAR_TOKEN` = Your SonarQube token (from SonarQube UI)

---

## Component Mapping: SonarQube ↔ GitHub Code Quality

See [COMPONENT_MAPPING.md](../COMPONENT_MAPPING.md) for complete equivalence matrix.

### Quick Comparison

| Component | SonarQube | GitHub Code Quality | Parity |
|-----------|-----------|---------------------|--------|
| **Security** | Native rating + hotspots | CodeQL + Roslyn | HIGH |
| **Reliability** | Native rating + bugs | Roslyn CA rules | HIGH |
| **Maintainability** | Native rating + smells | Roslyn CA rules | MEDIUM |
| **Coverage** | Native tracking | upload-code-coverage | HIGH |
| **Hotspots** | Native review workflow | CODEOWNERS | MEDIUM |
| **Duplication** | Native metrics | CPD (external tool) | MEDIUM |

---

## Setup Instructions

### Local SonarQube Installation

1. **Download SonarQube 10.7 LTS**
   ```powershell
   # See RUNBOOK.md section "Installing Latest SonarQube Locally"
   ```

2. **Start SonarQube**
   ```powershell
   C:\SonarQube\sonarqube-10.7.0.96680\bin\windows-x86-64\StartSonar.bat
   ```

3. **Access dashboard**
   - Open http://localhost:9000
   - Login: admin / admin
   - Create token in User Profile → My Account → Security

4. **Configure GitHub secrets**
   - Add SONAR_HOST_URL and SONAR_TOKEN

5. **Run analysis**
   - Push to sonarqube-latest branch
   - GitHub Actions workflow runs automatically
   - View results in SonarQube dashboard

---

## Troubleshooting

### Analysis fails with "SonarQube server is not accessible"
```powershell
# Check SonarQube is running
curl http://localhost:9000/api/system/status

# If not running, start it
C:\SonarQube\sonarqube-10.7.0.96680\bin\windows-x86-64\StartSonar.bat
```

### Quality Gate times out
- Increase `MaxRetries` in `Wait-SonarQualityGate.ps1`
- Increase workflow timeout

### Coverage not showing
- Verify coverage.opencover.xml is generated
- Check file path in workflow

### Invalid token error
- Regenerate token in SonarQube UI
- Update GitHub secret

---

## Files

| File | Purpose |
|------|---------|
| `.github/workflows/build-and-sonarqube-scan.yml` | Main workflow for SonarQube analysis |
| `scripts/Wait-SonarQualityGate.ps1` | Quality gate wait script |
| `RUNBOOK.md` | Complete setup and troubleshooting guide |
| `COMPONENT_MAPPING.md` | SonarQube vs GitHub equivalence |

---

## See Also

- **Main branch** (`github-code-quality`): GitHub Code Quality setup with CodeQL + Roslyn
- **RUNBOOK.md**: Step-by-step setup for both branches
- **COMPONENT_MAPPING.md**: Detailed component equivalence analysis
- [SonarQube Documentation](https://docs.sonarqube.org/)
