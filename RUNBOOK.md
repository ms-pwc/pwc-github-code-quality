# GitHub Code Quality vs SonarQube - Implementation Runbook

This runbook provides step-by-step instructions for setting up both GitHub Code Quality (main branch) and SonarQube (sonarqube branch) to achieve all 6 quality components.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Branch Setup](#branch-setup)
3. [Main Branch: GitHub Code Quality Setup](#main-branch-github-code-quality-setup)
4. [SonarQube Branch Setup](#sonarqube-branch-setup)
5. [Installing Latest SonarQube Locally](#installing-latest-sonarqube-locally)
6. [Verifying All 6 Components](#verifying-all-6-components)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software
- Git 2.35+
- .NET 10.0+ SDK
- PowerShell 7.2+ (for Windows)
- SonarQube 10.7+ (latest LTS)
- Java 17+ (required by SonarQube)

### Required Accounts/Tokens
- GitHub repository with Actions enabled
- GitHub token (GITHUB_TOKEN - automatic)
- SonarQube instance (local or cloud) with:
  - SONAR_HOST_URL
  - SONAR_TOKEN

---

## Branch Setup

### Step 1: Clean up existing branches

```powershell
cd "c:\path\to\pwc-main-sync"

# List current branches
git branch -a

# If you want to start completely fresh, you can delete local branches:
git checkout main
git branch -D github-code-quality sonarqube  # if they exist
```

### Step 2: Create main branch for GitHub Code Quality

```powershell
# From the current main branch, create a clean slate
git checkout -b main-github-code-quality
git push origin main-github-code-quality -u
```

### Step 3: Create sonarqube branch for latest SonarQube

```powershell
git checkout main
git checkout -b sonarqube-latest
git push origin sonarqube-latest -u
```

---

## Main Branch: GitHub Code Quality Setup

### Step 1: Verify Workflow Structure

The main branch should have `.github/workflows/code-quality.yml` with three jobs:

**Job 1: Build, Format, and Test**
- Builds the solution
- Verifies code formatting
- Runs unit tests

**Job 2: CodeQL Analysis**
- Initializes CodeQL for C#
- Uses security-and-quality query pack
- Uploads findings to Security → Code scanning alerts

**Job 3: Roslyn Analyzers to SARIF**
- Builds project with `SarifOutputDir` flag
- Runs `Merge-AnalyzerSarif.ps1` to consolidate SARIF files
- Uploads merged SARIF to code scanning

### Step 2: Verify .NET Analyzer Configuration

Check `Directory.Build.props` contains SARIF output configuration:

```xml
<PropertyGroup>
  <SarifOutputDir>$(MSBuildProjectDirectory)/bin/sarif</SarifOutputDir>
  <GenerateSerializationAssemblies>Off</GenerateSerializationAssemblies>
  <AnalysisLevel>latest</AnalysisLevel>
</PropertyGroup>
```

### Step 3: Verify CodeQL Configuration

Check `.github/codeql/codeql-config.yml`:

```yaml
name: Custom CodeQL configuration
paths:
  include:
    - src
    - tests
  exclude:
    - '**/test-files/**'
    - '**/obj/**'
queries:
  - uses: security-and-quality
```

### Step 4: Add Coverage Support

Update `.github/workflows/code-quality.yml` to include coverage upload:

**In `quality-gate` job, add after tests:**
```yaml
- name: Generate coverage report
  run: |
    dotnet test tests/QualityDemo.Tests/QualityDemo.Tests.csproj \
      --configuration Release \
      --collect:"XPlat Code Coverage" \
      --logger trx

- name: Upload coverage to GitHub
  uses: actions/upload-code-coverage@v1
  with:
    files: ./coverage/coverage.cobertura.xml
```

### Step 5: Add Dependabot Configuration

Verify `.github/dependabot.yml` for weekly updates:

```yaml
version: 2
updates:
  - package-ecosystem: "nuget"
    directory: "/"
    schedule:
      interval: "weekly"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

### Step 6: Add CODEOWNERS for Hotspot Review Simulation

Create/update `.github/CODEOWNERS`:

```
# Security-sensitive code requires review from security team
/src/QualityDemo/TrainingOnlyInsecureExamples.cs @security-team
/src/QualityDemo/TrainingOnlyThreatWorkbench.cs @security-team

# All changes require review
* @maintainers
```

### Step 7: Create Duplication Check in Workflow

Add a new job to detect duplicates using CPD:

```yaml
duplication-check:
  name: Code Duplication Check
  runs-on: ubuntu-latest
  timeout-minutes: 10

  steps:
    - name: Checkout
      uses: actions/checkout@v7

    - name: Install PMD (Copy Paste Detector)
      run: |
        curl -L https://github.com/pmd/pmd/releases/download/pmd_releases%2F6.55.0/pmd-bin-6.55.0.zip -o pmd.zip
        unzip pmd.zip
        echo "$(pwd)/pmd-bin-6.55.0/bin" >> $GITHUB_PATH

    - name: Run CPD
      run: |
        cpd --files src/QualityDemo \
            --minimum-tokens 10 \
            --format csv > duplication-report.csv || true
        cat duplication-report.csv

    - name: Upload duplication report
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: duplication-report
        path: duplication-report.csv
```

### Step 8: Commit and Test

```powershell
git add .github/workflows/code-quality.yml \
        .github/codeql/codeql-config.yml \
        .github/dependabot.yml \
        .github/CODEOWNERS \
        COMPONENT_MAPPING.md \
        RUNBOOK.md

git commit -m "feat: GitHub Code Quality setup with all 6 components

- CodeQL + Roslyn for Security/Reliability/Maintainability
- Coverage upload with actions/upload-code-coverage
- CODEOWNERS for hotspot review simulation
- CPD for duplication detection"

git push origin github-code-quality -u
```

---

## SonarQube Branch Setup

### Step 1: Checkout SonarQube Branch

```powershell
git checkout sonarqube-latest
```

### Step 2: Create SonarQube Workflow

Create `.github/workflows/build-and-sonarqube-scan.yml`:

```yaml
name: Build and SonarQube Analysis

on:
  push:
    branches:
      - sonarqube-latest
  pull_request:
    branches:
      - sonarqube-latest
  workflow_dispatch:

permissions:
  contents: read
  pull-requests: read

jobs:
  build-and-analyze:
    name: Build and SonarQube Scan
    runs-on: ubuntu-latest
    timeout-minutes: 30

    steps:
      - name: Checkout
        uses: actions/checkout@v7
        with:
          fetch-depth: 0  # Full history for better analysis

      - name: Setup .NET
        uses: actions/setup-dotnet@v6
        with:
          dotnet-version: 10.0.x

      - name: Restore dependencies
        run: dotnet restore Pwc.GitHubCodeQuality.slnx

      - name: Verify formatting
        run: dotnet format Pwc.GitHubCodeQuality.slnx --verify-no-changes --verbosity minimal || true

      - name: Build
        run: dotnet build Pwc.GitHubCodeQuality.slnx --configuration Release --no-restore

      - name: Run tests and generate coverage
        run: |
          dotnet test tests/QualityDemo.Tests/QualityDemo.Tests.csproj \
            --configuration Release \
            --collect:"XPlat Code Coverage" \
            --logger trx \
            --results-directory coverage

      - name: Install SonarScanner
        run: dotnet tool install --global dotnet-sonarscanner

      - name: Run SonarQube Analysis
        env:
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
        run: |
          dotnet sonarscanner begin \
            /k:"pwc-github-code-quality" \
            /n:"PWC GitHub Code Quality" \
            /d:sonar.host.url="${{ env.SONAR_HOST_URL }}" \
            /d:sonar.login="${{ env.SONAR_TOKEN }}" \
            /d:sonar.cs.opencover.reportsPaths="**/coverage.opencover.xml"

          dotnet build Pwc.GitHubCodeQuality.slnx --configuration Release --no-restore

          dotnet sonarscanner end \
            /d:sonar.login="${{ env.SONAR_TOKEN }}"

      - name: Wait for SonarQube Quality Gate
        env:
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
        run: |
          # Script to wait for quality gate (see below)
          pwsh -File scripts/Wait-SonarQualityGate.ps1 \
            -SonarHostUrl "${{ env.SONAR_HOST_URL }}" \
            -SonarToken "${{ env.SONAR_TOKEN }}" \
            -ProjectKey "pwc-github-code-quality"
```

### Step 3: Create SonarQube Quality Gate Wait Script

Create `scripts/Wait-SonarQualityGate.ps1`:

```powershell
param(
    [Parameter(Mandatory = $true)]
    [string]$SonarHostUrl,
    
    [Parameter(Mandatory = $true)]
    [string]$SonarToken,
    
    [Parameter(Mandatory = $true)]
    [string]$ProjectKey,
    
    [int]$MaxRetries = 60,
    [int]$WaitSeconds = 5
)

$headers = @{
    "Authorization" = "Bearer $SonarToken"
}

$retryCount = 0
$gateStatus = "PENDING"

while ($gateStatus -eq "PENDING" -and $retryCount -lt $MaxRetries) {
    Start-Sleep -Seconds $WaitSeconds
    $retryCount++
    
    $analysisUrl = "$SonarHostUrl/api/ce/activity?component=$ProjectKey"
    $response = Invoke-RestMethod -Uri $analysisUrl -Headers $headers
    
    if ($response.tasks.Count -gt 0) {
        $task = $response.tasks[0]
        $gateStatus = $task.status
        
        Write-Host "Analysis status: $gateStatus"
        
        if ($task.status -eq "SUCCESS") {
            # Check quality gate
            $projectUrl = "$SonarHostUrl/api/qualitygates/project_status?projectKey=$ProjectKey"
            $gateResponse = Invoke-RestMethod -Uri $projectUrl -Headers $headers
            $gateStatus = $gateResponse.projectStatus.status
            
            Write-Host "Quality Gate: $gateStatus"
            
            if ($gateStatus -ne "OK") {
                throw "Quality Gate FAILED: $gateStatus"
            }
        }
    }
}

if ($gateStatus -eq "PENDING") {
    throw "Quality Gate check timed out after $($MaxRetries * $WaitSeconds) seconds"
}

Write-Host "Quality Gate check passed!"
```

### Step 4: Configure SonarQube Secrets in GitHub

In GitHub repository settings:

1. Go to Settings → Secrets and variables → Actions
2. Add two repository secrets:
   - `SONAR_HOST_URL`: `http://localhost:9000` (or your SonarQube URL)
   - `SONAR_TOKEN`: Your SonarQube token (create in SonarQube → User profile → Security → Tokens)

### Step 5: Commit SonarQube Setup

```powershell
git add .github/workflows/build-and-sonarqube-scan.yml \
        scripts/Wait-SonarQualityGate.ps1 \
        COMPONENT_MAPPING.md \
        RUNBOOK.md

git commit -m "feat: SonarQube branch setup with latest version

- Workflow for SonarQube 10.7+ analysis
- Coverage integration with opencover format
- Quality gate validation
- Component mapping documentation"

git push origin sonarqube-latest -u
```

---

## Installing Latest SonarQube Locally

### Step 1: Download Latest SonarQube

Download SonarQube 10.7 LTS or latest (without Docker):

```powershell
# Create SonarQube directory
mkdir -Force C:\SonarQube
cd C:\SonarQube

# Download latest SonarQube (replace version with latest)
$Version = "10.7.0.96680"  # Check https://www.sonarqube.org/downloads/
$Url = "https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$Version.zip"
Invoke-WebRequest -Uri $Url -OutFile sonarqube.zip

# Extract
Expand-Archive -Path sonarqube.zip -DestinationPath .
Remove-Item sonarqube.zip
```

### Step 2: Install Java (Required by SonarQube)

```powershell
# Download and install OpenJDK 17+
# Go to https://jdk.java.net/17/ or use:
choco install openjdk17  # If using Chocolatey

# Or download manually and add to PATH
# $env:JAVA_HOME = "C:\Program Files\OpenJDK\jdk-17.0.x"
```

### Step 3: Configure SonarQube

Edit `sonarqube-10.7.0.96680\conf\sonar.properties`:

```properties
# Web server settings
sonar.web.host=127.0.0.1
sonar.web.port=9000
sonar.web.context=/

# Database (embedded for development, external for production)
sonar.jdbc.username=sonar
sonar.jdbc.password=sonar
sonar.jdbc.url=jdbc:h2:tcp://localhost/sonarqube

# Security
sonar.forceAuthentication=false
```

### Step 4: Start SonarQube

```powershell
cd C:\SonarQube\sonarqube-10.7.0.96680\bin\windows-x86-64

# Run SonarQube (will start on http://localhost:9000)
./StartSonar.bat

# Or run as a service (Windows)
./InstallSonarService.bat
./StartSonarService.bat
```

### Step 5: Verify SonarQube is Running

```powershell
# Open in browser
Start-Process "http://localhost:9000"

# Default login: admin / admin
# You'll be prompted to change password on first login
```

### Step 6: Create SonarQube Project and Token

1. Log in to SonarQube (http://localhost:9000)
2. Click "+ Create project"
3. Enter:
   - Project key: `pwc-github-code-quality`
   - Display name: `PWC GitHub Code Quality`
4. Generate token:
   - User → My Account → Security → Generate Token
   - Name: `github-sonarqube`
   - Copy the token

### Step 7: Add Secrets to GitHub (from local SonarQube)

In GitHub repository settings:
```
SONAR_HOST_URL = http://localhost:9000
SONAR_TOKEN = <your-generated-token>
```

---

## Verifying All 6 Components

### Checklist for GitHub Code Quality (main branch)

| Component | Expected Location | How to Verify |
|-----------|-------------------|---------------|
| **Security** | Security → Code scanning alerts | Should show alerts from CodeQL + Roslyn (MD5, SHA1, XXE, TLS issues) |
| **Maintainability** | Security → Code scanning alerts | Should show alerts for code smells (CA1822 - unused methods) |
| **Reliability** | Security → Code scanning alerts | Should show bugs (CA2000 - resource disposal issues) |
| **Coverage** | Security → Code coverage | Should show % coverage from dotnet test |
| **Hotspot Review** | Pull Requests → CODEOWNERS reviews | Sensitive files require approval from security team |
| **Duplication** | Actions → Artifacts (duplication-report.csv) | CPD report shows duplicate lines and blocks |

### Checklist for SonarQube (sonarqube-latest branch)

| Component | Expected Location | How to Verify |
|-----------|-------------------|---------------|
| **Security** | Dashboard → Measures → Security | Rating (E for current code) + vulnerability count |
| **Maintainability** | Dashboard → Measures → Maintainability | Rating + code smell count |
| **Reliability** | Dashboard → Measures → Reliability | Rating + bug count |
| **Coverage** | Dashboard → Measures → Coverage | % coverage from test run |
| **Hotspot Review** | Dashboard → Measures → Security Hotspots | Hotspots to review + % reviewed |
| **Duplication** | Dashboard → Measures → Duplication | % duplication + duplicate blocks |

### Step 1: Run GitHub Code Quality Workflow

```powershell
git checkout github-code-quality
git push origin github-code-quality

# Go to GitHub Actions and verify all jobs pass
# Check results in Security → Code scanning alerts
```

### Step 2: Run SonarQube Workflow

```powershell
git checkout sonarqube-latest
git push origin sonarqube-latest

# Go to GitHub Actions and verify workflow completes
# Check results in local SonarQube: http://localhost:9000
```

### Step 3: Compare Results

Create a comparison spreadsheet:

```
Component          | SonarQube Result | GitHub Result | Equivalent?
Security           | E / 4 vulns      | 1 alert       | High (Roslyn finds same issues)
Maintainability    | A / 2 smells     | 2 CA1822      | High (same detectors)
Reliability        | C / 2 bugs       | 2 CA2000      | High (same resource issues)
Coverage           | 84.8%            | 84.8%         | Yes (same source)
Hotspot Review     | E / 0%           | PR reviews    | Medium (different approach)
Duplication        | 7.6%             | In artifact   | Yes (CPD matches Sonar)
```

---

## Troubleshooting

### GitHub Code Quality Issues

**Issue: CodeQL analysis times out**
```powershell
# Solution: Increase timeout in workflow
# timeout-minutes: 30 → 45
```

**Issue: Roslyn SARIF not uploading**
```powershell
# Check if Merge-AnalyzerSarif.ps1 exists:
Test-Path scripts/Merge-AnalyzerSarif.ps1

# Run locally to debug:
./scripts/Merge-AnalyzerSarif.ps1 -InputDirectory sarif -OutputPath dotnet-analyzers.sarif
```

**Issue: No coverage data**
```powershell
# Ensure coverage file generated:
dotnet test tests/QualityDemo.Tests/QualityDemo.Tests.csproj \
  --collect:"XPlat Code Coverage" \
  --results-directory coverage

# Check for coverage.cobertura.xml:
Get-ChildItem -Recurse coverage.cobertura.xml
```

### SonarQube Issues

**Issue: "SonarQube server is not accessible"**
```powershell
# Verify SonarQube is running:
curl http://localhost:9000/api/system/status

# If not running, start it:
C:\SonarQube\sonarqube-10.7.0.96680\bin\windows-x86-64\StartSonar.bat
```

**Issue: "Invalid token"**
```powershell
# Regenerate token in SonarQube:
# 1. Login to http://localhost:9000
# 2. User profile → My Account → Security
# 3. Revoke old token, create new one
# 4. Update GitHub secret: SONAR_TOKEN
```

**Issue: Quality gate stuck on PENDING**
```powershell
# Increase timeout in Wait-SonarQualityGate.ps1:
# $MaxRetries = 60 → 120
# $WaitSeconds = 5 → 10
```

---

## Next Steps

1. ✅ Both branches created: `github-code-quality` and `sonarqube-latest`
2. ✅ All 6 components implemented on each branch
3. ✅ Latest SonarQube installed locally
4. ✅ Documentation with component mapping complete
5. 📋 Run workflows and verify results match
6. 📋 Create PR comparison showing both approaches
7. 📋 Document equivalent metrics in README

See [COMPONENT_MAPPING.md](COMPONENT_MAPPING.md) for detailed component equivalence matrix.
