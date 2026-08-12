# SonarQube Workflow Guide

This document explains how SonarQube is integrated into your GitHub Actions workflow and how to use it effectively.

## GitHub Actions workflow integration

The workflow in `.github/workflows/build-and-sonarqube-scan.yml` runs on every push to `main` and pull request.

### Workflow steps

1. **Checkout** – Fetch the repository with full history (for branch analysis).
2. **Setup .NET** – Install the .NET 10 SDK.
3. **Install SonarQube Scanner** – Download the `dotnet-sonarscanner` tool globally.
4. **Restore dependencies** – Restore NuGet packages.
5. **Begin SonarQube analysis** – Start the scanning session.
6. **Build** – Compile the project in Release mode.
7. **Verify formatting** – Check code style compliance.
8. **Run tests** – Execute the quality gate tests.
9. **End SonarQube analysis** – Upload results to SonarQube.
10. **Report status** – Display link to SonarQube dashboard.

### Environment variables and secrets

The workflow requires two secrets to be configured in your GitHub repository:

| Secret | Purpose | Default |
| --- | --- | --- |
| `SONAR_HOST_URL` | URL of SonarQube instance | `http://localhost:9000` |
| `SONAR_LOGIN` | Authentication token from SonarQube | (required) |

For local testing, you can omit `SONAR_HOST_URL` and it will default to `http://localhost:9000`. For production, add it as a repository or organization secret.

### Setting up secrets in GitHub

1. Go to your GitHub repository settings.
2. Navigate to **Secrets and variables** > **Actions**.
3. Click **New repository secret**.
4. Add `SONAR_LOGIN` with your SonarQube token.
5. (Optional) Add `SONAR_HOST_URL` if using a non-local instance.

## Pull request workflow

### What happens on PR

1. The workflow triggers on each push to a pull request branch.
2. SonarQube analyzes the code against the `main` branch.
3. Quality gate is evaluated:
   - **Passed** – PR can be merged (assuming other checks pass).
   - **Failed** – SonarQube reports which conditions failed. The workflow logs display the SonarQube dashboard link.

### Reviewing SonarQube PR results

After a workflow run completes:

1. In the GitHub PR, find the workflow run in the **Checks** tab.
2. Click on **Build and analyze with SonarQube** to see the run details.
3. Check the **SonarQube Quality Gate Status** step for the dashboard link.
4. Click the link to see detailed analysis:
   - New issues in this PR.
   - Quality gate failures.
   - Security hotspots.
   - Code smell and duplicate code changes.

### Integrating results into PR comments (optional)

You can enhance the workflow to post SonarQube results as a PR comment using the SonarQube API or a marketplace action. Example:

```yaml
- name: Comment PR with SonarQube results
  if: github.event_name == 'pull_request'
  run: |
    # Fetch SonarQube project metrics via API
    curl -s -H "Authorization: Bearer ${{ secrets.SONAR_LOGIN }}" \
      http://localhost:9000/api/qualitygates/project_status?projectKey=pwc-github-code-quality | jq .
```

## Branch analysis

SonarQube can track quality metrics across branches, comparing the main branch to feature branches.

### Enable branch analysis

Branch analysis is automatically enabled if:

1. Repository has full history (`fetch-depth: 0` in checkout step).
2. SonarQube project has a quality gate assigned.

### Viewing branch comparison

1. In SonarQube, go to your project dashboard.
2. Click **Branches** to see all analyzed branches.
3. Compare metrics between main and feature branches.

## Troubleshooting workflow issues

### Quality gate fails but build passes

This is intentional. The workflow continues even if the quality gate fails so you can see the detailed results. To block the build on failure, add a step:

```yaml
- name: Fail if quality gate fails
  run: |
    # Check quality gate status via SonarQube API
    STATUS=$(curl -s -H "Authorization: Bearer ${{ secrets.SONAR_LOGIN }}" \
      http://localhost:9000/api/qualitygates/project_status?projectKey=pwc-github-code-quality | jq -r '.projectStatus.status')
    if [ "$STATUS" != "OK" ]; then
      echo "Quality gate failed: $STATUS"
      exit 1
    fi
```

### Scanner connection timeout

- Verify `SONAR_HOST_URL` is correct and reachable.
- For local SonarQube in Docker, ensure the container is running: `docker-compose ps`.
- Check firewall rules if using a remote instance.

### Token expired or invalid

- Regenerate the token in SonarQube: **Administration** > **Security** > **Users** > **Tokens**.
- Update the GitHub secret.

## Developer workflow (local)

For local development without committing to main:

1. Start the local SonarQube server: `./scripts/setup-local-sonarqube.ps1`
2. Generate a token in SonarQube UI.
3. Run a local scan: `$env:SONAR_LOGIN = "token"; .\scripts\run-sonarqube-scan.ps1`
4. Review results in SonarQube dashboard.
5. Fix issues and re-scan.

This lets you validate code quality before opening a PR.

## Scaling to multiple repositories

Once established, this workflow can be:

1. **Copied** to other repositories as-is (update project key and name).
2. **Centralized** as a reusable workflow (GitHub recommends this for many repos).
3. **Templated** with organization-wide settings and quality profiles.

See [self-hosted-vs-saas.md](self-hosted-vs-saas.md) for enterprise scaling patterns.

## Next steps

- [sonarqube-setup-guide.md](sonarqube-setup-guide.md) – Complete setup instructions.
- [quality-profiles-and-gates.md](quality-profiles-and-gates.md) – Advanced quality configuration.
- [self-hosted-vs-saas.md](self-hosted-vs-saas.md) – Deployment models for production.
