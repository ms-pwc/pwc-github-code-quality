# SonarQube Setup Guide

This guide covers installing, configuring, and running SonarQube locally for code quality analysis.

## Prerequisites

- Docker and Docker Compose installed on your machine.
- .NET 10 SDK for running the scanner.
- At least 2GB of available RAM and 3GB of disk space for SonarQube and PostgreSQL containers.

## Local SonarQube Setup with Docker Compose

### 1. Start the SonarQube server

The repository includes a `docker-compose.yml` that starts both PostgreSQL and SonarQube.

**Windows (PowerShell):**
```powershell
.\scripts\setup-local-sonarqube.ps1
```

**Linux/macOS (Bash):**
```bash
chmod +x scripts/setup-local-sonarqube.sh
./scripts/setup-local-sonarqube.sh
```

The script will:
- Start PostgreSQL container at `localhost:5432`.
- Start SonarQube container at `http://localhost:9000`.
- Wait for both services to be healthy.
- Display default credentials and next steps.

### 2. Access SonarQube

Open http://localhost:9000 in your browser.

- **Default username:** `admin`
- **Default password:** `admin`
- Change the password on first login.

### 3. Generate an authentication token

1. In SonarQube, click on your avatar (top-right) > **My Account**.
2. Go to the **Security** tab.
3. Scroll down to **Tokens** and enter a token name (e.g., "Local Dev").
4. Click **Generate**.
5. Copy the token immediately (you cannot see it again).

Store this token securely. You will use it to authenticate the SonarQube Scanner.

### 4. Create a project in SonarQube (optional)

Projects are created automatically on the first scan, but you can also create them manually:

1. Go to **Projects** > **Create Project**.
2. Enter project name and key (must match the `/k:` project key used by `dotnet sonarscanner begin`).
3. Click **Create Project**.

## Running SonarQube Scanner locally

### Before scanning

1. Ensure the SonarQube server is running (check http://localhost:9000).
2. Have your authentication token ready.

### Windows (PowerShell)

```powershell
# Set the token as an environment variable
$env:SONAR_LOGIN = "your-token-here"

# Run the scan
.\scripts\run-sonarqube-scan.ps1

# Or, specify the token as a parameter
.\scripts\run-sonarqube-scan.ps1 -SonarLogin "your-token-here"
```

### Linux/macOS (Bash)

```bash
# Set the token as an environment variable
export SONAR_LOGIN="your-token-here"

# Run the scan
./scripts/run-sonarqube-scan.sh

# Or, set it inline
SONAR_LOGIN="your-token-here" ./scripts/run-sonarqube-scan.sh
```

### What the scan does

1. Restores .NET dependencies.
2. Starts SonarQube Scanner analysis session.
3. Builds the solution in Release configuration.
4. Ends the analysis and uploads results to SonarQube.

The scan typically takes 30-60 seconds. Results appear in the SonarQube dashboard within a few seconds.

## View analysis results

After the scan completes:

1. Open http://localhost:9000 in your browser.
2. Find the project in the **Projects** list (key: `pwc-github-code-quality`).
3. View metrics:
   - **Overview:** Overall project health and gate status.
   - **Code Smells:** Maintainability issues.
   - **Bugs:** Reliability issues.
   - **Vulnerabilities:** Security issues.
   - **Security Hotspots:** Security-sensitive code requiring review.
   - **Duplications:** Duplicated code.
   - **Coverage:** Test coverage (if coverage data is provided).

## Configure Quality Gates

A quality gate is a set of conditions that must pass for the project to be considered "ready to merge."

### Create or edit a quality gate

1. Go to **Quality Gates** in SonarQube.
2. Create a new gate or edit the default "Sonar way" gate.
3. Add conditions (examples):
   - Bugs: `< 1`
   - Vulnerabilities: `< 1`
   - Security Hotspots Reviewed: `>= 100%`
   - Code Coverage: `>= 80%`
   - Code Duplication: `< 3%`
   - Maintainability Rating: `A` or `B`

### Associate quality gate with project

1. In the project dashboard, click the **project settings** icon.
2. Go to **Quality Gate**.
3. Select the quality gate to enforce.
4. Save.

The quality gate will be evaluated after each scan. If it fails, the workflow can fail the build (if configured).

## SonarQube scanner properties

For .NET projects, configure SonarQube through `dotnet sonarscanner begin` arguments instead of `sonar-project.properties`:

- **sonar.projectKey** – Unique project identifier.
- **sonar.projectName** – Display name in SonarQube UI.
- **sonar.projectVersion** – Project version (for historical tracking).
- **sonar.sources** – Directories containing source code.
- **sonar.tests** – Directories containing test code.
- **sonar.language** – Primary language (e.g., `cs` for C#).
- **sonar.csharp.analyzers.projectOutPaths** – Paths to compiled assemblies (used by C# analyzer).
- **sonar.exclusions** – Exclude files from analysis (e.g., `**/obj/**`).

## Stopping and removing SonarQube

### Stop containers (data persists)

```bash
docker-compose stop
```

### Remove containers (data persists)

```bash
docker-compose down
```

### Remove containers and volumes (complete reset)

```bash
docker-compose down -v
```

This deletes all SonarQube data, projects, and settings. Use only for testing.

## Troubleshooting

### SonarQube not starting

- Check Docker is running: `docker ps`
- Check logs: `docker-compose logs sonarqube`
- Ensure port 9000 is not in use: `netstat -tuln | grep 9000` (Linux/macOS) or `netstat -ano | findstr 9000` (Windows).

### Scanner authentication fails

- Verify token is correct: copy and paste directly from SonarQube.
- Check SONAR_LOGIN environment variable is set: `echo $env:SONAR_LOGIN` (PowerShell) or `echo $SONAR_LOGIN` (Bash).

### "Quality Gate failed" in workflow

- Review the SonarQube dashboard to see which condition failed.
- Update the quality gate conditions or fix the code to pass the gate.
- Re-run the scan.

## Next steps

- [sonarqube-workflow-guide.md](sonarqube-workflow-guide.md) – Integrate SonarQube into your CI/CD pipeline.
- [quality-profiles-and-gates.md](quality-profiles-and-gates.md) – Advanced quality gate and profile customization.
- [self-hosted-vs-saas.md](self-hosted-vs-saas.md) – Choosing between self-hosted and SaaS SonarQube.
