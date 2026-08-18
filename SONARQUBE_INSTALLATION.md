# SonarQube 10.7 LTS Installation Guide (Windows - No Docker)

## Step-by-Step Installation

### Step 1: Install Java 17 LTS

**Option A: Using PowerShell (Direct Download)**

```powershell
# Create directory for Java
$javaPath = "C:\Java"
New-Item -ItemType Directory -Path $javaPath -Force

# Download OpenJDK 17 LTS from Adoptium
$url = "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13%2B11/OpenJDK17U-jdk_x64_windows_hotspot_17.0.13_11.zip"
$zipFile = "$javaPath\openjdk17.zip"

Write-Host "Downloading OpenJDK 17 LTS..."
Invoke-WebRequest -Uri $url -OutFile $zipFile

# Extract
Write-Host "Extracting..."
Expand-Archive -Path $zipFile -DestinationPath $javaPath -Force
Remove-Item $zipFile

# Find JDK directory
$jdkDir = Get-ChildItem $javaPath -Directory | Where-Object { $_.Name -match 'jdk' } | Select-Object -First 1
$JAVA_HOME = $jdkDir.FullName

# Set environment variable
[Environment]::SetEnvironmentVariable('JAVA_HOME', $JAVA_HOME, 'User')
$env:JAVA_HOME = $JAVA_HOME
$env:PATH = "$JAVA_HOME\bin;$env:PATH"

# Verify
java -version
```

**Option B: Manual Download**
1. Go to https://adoptium.net/temurin/releases/
2. Download OpenJDK 17 LTS for Windows x64
3. Extract to `C:\Java\jdk-17.x.x`
4. Set `JAVA_HOME` environment variable to the JDK directory
5. Add `%JAVA_HOME%\bin` to PATH

**Verify Installation:**
```powershell
java -version
# Should show: openjdk version "17.x.x"
```

---

### Step 2: Download SonarQube 10.7 LTS

**Download from official source:**

```powershell
# Create SonarQube directory
$sonarPath = "C:\SonarQube"
New-Item -ItemType Directory -Path $sonarPath -Force

# Download SonarQube 10.7 LTS
$url = "https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.7.0.96680.zip"
$zipFile = "$sonarPath\sonarqube-10.7.0.zip"

Write-Host "Downloading SonarQube 10.7 LTS..."
Invoke-WebRequest -Uri $url -OutFile $zipFile

# Extract
Write-Host "Extracting..."
Expand-Archive -Path $zipFile -DestinationPath $sonarPath -Force
Remove-Item $zipFile

# Navigate to extracted directory
$sonarDir = "$sonarPath\sonarqube-10.7.0.96680"
Write-Host "SonarQube installed at: $sonarDir"
```

**Or download manually:**
1. Go to https://www.sonarqube.org/downloads/
2. Download Community Edition 10.7 LTS
3. Extract to `C:\SonarQube\sonarqube-10.7.0.96680`

---

### Step 3: Configure SonarQube

**Edit configuration file:**

```powershell
# Open properties file in notepad
$propsFile = "C:\SonarQube\sonarqube-10.7.0.96680\conf\sonar.properties"
notepad $propsFile
```

**Find and modify these settings:**

```properties
# ===================================================
# DATABASE
# ===================================================
# For development, the embedded H2 database is fine
# For production, use PostgreSQL or MySQL

# Embedded H2 database (default, good for testing)
sonar.jdbc.username=sonar
sonar.jdbc.password=sonar

# ===================================================
# WEB SERVER
# ===================================================
sonar.web.host=127.0.0.1
sonar.web.port=9000
sonar.web.context=/

# ===================================================
# SECURITY  
# ===================================================
# For development, disable forced auth
sonar.forceAuthentication=false

# ===================================================
# SYSTEM
# ===================================================
sonar.path.data=data
sonar.path.temp=temp
sonar.path.logs=logs
```

**Save the file.**

---

### Step 4: Start SonarQube

#### Option A: Run as Console Application

```powershell
# Set Java path
$env:JAVA_HOME = "C:\Java\jdk-17.x.x"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

# Navigate to SonarQube bin directory
cd "C:\SonarQube\sonarqube-10.7.0.96680\bin\windows-x86-64"

# Run StartSonar.bat
.\StartSonar.bat

# Wait for output:
# 2024-XX-XX XX:XX:XX.XXX  INFO  web   o.s.s.a.EmbeddedTomcatStarter |  SonarQube is up
```

Then open browser: http://localhost:9000

#### Option B: Install as Windows Service

```powershell
cd "C:\SonarQube\sonarqube-10.7.0.96680\bin\windows-x86-64"

# Install service (must run as Administrator)
.\InstallSonarService.bat

# Start service
.\StartSonarService.bat

# Check status
.\StatusSonarService.bat

# View logs
Get-Content "C:\SonarQube\sonarqube-10.7.0.96680\logs\sonar.log" -Tail 20
```

**Access SonarQube:**
- Open http://localhost:9000 in browser
- Default login: `admin` / `admin`
- You'll be prompted to change password on first login

---

### Step 5: Create SonarQube Project and Token

**In SonarQube Web UI:**

1. Click **"+"** (Create project) or go to Projects → Create project
2. Enter:
   - **Project key**: `pwc-github-code-quality`
   - **Project name**: `PWC GitHub Code Quality`
   - **Visibility**: Public
3. Click **"Create project"**

**Generate authentication token:**

1. Click your avatar (top right) → "My Account"
2. Go to "Security" tab
3. Click "Generate Tokens"
4. Name: `github-sonarqube`
5. Type: Global Analysis Token
6. Expires: Never (or set to 1 year)
7. Click "Generate"
8. **Copy the token** (you'll need it for GitHub)

**Example token:** `squ_abc123def456ghijklmnopqrstuvwxyz1234567890`

---

### Step 6: Configure GitHub Secrets

In your GitHub repository:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Click **"New repository secret"**
3. Name: `SONAR_HOST_URL`
   Value: `http://localhost:9000`
4. Click **"Add secret"**
5. Click **"New repository secret"** again
6. Name: `SONAR_TOKEN`
   Value: `squ_abc123def456...` (the token from Step 5)
7. Click **"Add secret"**

---

### Step 7: Run Analysis from GitHub Actions

**Push to sonarqube-latest branch:**

```powershell
cd c:\path\to\pwc-main-sync
git checkout sonarqube-latest
git push origin sonarqube-latest
```

**Watch GitHub Actions:**
1. Go to repository → Actions
2. Click running workflow
3. Wait for completion
4. Check SonarQube dashboard: http://localhost:9000

---

## Verification Checklist

- [ ] Java 17+ installed (`java -version` shows `17.x.x`)
- [ ] SonarQube 10.7 extracted to `C:\SonarQube\sonarqube-10.7.0.96680`
- [ ] `sonar.properties` configured correctly
- [ ] SonarQube running: http://localhost:9000 accessible
- [ ] Default login works (admin/admin → change password)
- [ ] Project created: `pwc-github-code-quality`
- [ ] Token generated and saved
- [ ] GitHub secrets configured: `SONAR_HOST_URL` and `SONAR_TOKEN`
- [ ] sonarqube-latest branch pushed to GitHub
- [ ] GitHub Actions workflow runs and completes successfully
- [ ] Dashboard shows results: http://localhost:9000/dashboard?id=pwc-github-code-quality

---

## Viewing Analysis Results

Once analysis completes, view all 6 components:

### Dashboard Overview
```
http://localhost:9000/dashboard?id=pwc-github-code-quality
```

### Individual Metrics
1. **Security**: Measures → Security
2. **Reliability**: Measures → Reliability  
3. **Maintainability**: Measures → Maintainability
4. **Coverage**: Measures → Coverage
5. **Hotspots**: Measures → Security Hotspots
6. **Duplication**: Measures → Duplication

### Issue Explorer
```
http://localhost:9000/issues?id=pwc-github-code-quality
```

Filter by:
- **Type**: Bug, Vulnerability, Code Smell
- **Severity**: Critical, Major, Minor, Info
- **Status**: Open, Confirmed, False Positive, Won't Fix

### Hotspot Review
```
http://localhost:9000/security_hotspots?id=pwc-github-code-quality
```

Click each hotspot and mark as:
- Reviewed
- Fixed
- Safe

---

## Troubleshooting

### SonarQube Won't Start

**Error: "JAVA_HOME not set"**
```powershell
$env:JAVA_HOME = "C:\Java\jdk-17.x.x"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
```

**Error: "Cannot bind to port 9000"**
```powershell
# Find process using port 9000
Get-NetTCPConnection -LocalPort 9000

# Kill process if needed
Stop-Process -Id <PID> -Force
```

### GitHub Actions Workflow Fails

**Error: "SonarQube server is not accessible"**
- Verify SonarQube is running: http://localhost:9000
- Check `SONAR_HOST_URL` secret is set correctly
- Firewall might be blocking: Check Windows Firewall

**Error: "Invalid token"**
- Regenerate token in SonarQube UI
- Update `SONAR_TOKEN` secret in GitHub

**Error: "Quality gate stuck on PENDING"**
- Increase timeout in `Wait-SonarQualityGate.ps1`
- Check SonarQube logs: `C:\SonarQube\sonarqube-10.7.0.96680\logs\sonar.log`

### Analysis Shows No Coverage

**Check coverage report generated:**
```powershell
# Look for coverage file
Get-ChildItem -Recurse -Filter "*coverage*.xml" coverage/
```

**Ensure test collection is enabled:**
```powershell
dotnet test --collect:"XPlat Code Coverage"
```

---

## Stopping SonarQube

**If running as console app:**
```powershell
# Press Ctrl+C in the terminal
```

**If running as Windows service:**
```powershell
cd "C:\SonarQube\sonarqube-10.7.0.96680\bin\windows-x86-64"
.\StopSonarService.bat
```

---

## Next Steps

1. ✅ Install Java 17 LTS
2. ✅ Download and extract SonarQube 10.7 LTS
3. ✅ Configure sonar.properties
4. ✅ Start SonarQube service
5. ✅ Create project and token
6. ✅ Add GitHub secrets
7. ✅ Push sonarqube-latest branch
8. ✅ Run GitHub Actions workflow
9. ✅ View results in SonarQube dashboard

See [RUNBOOK.md](../RUNBOOK.md) for complete setup guide.
