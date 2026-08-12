# Quality Profiles and Gates

This document explains SonarQube quality profiles and quality gates, and how to customize them for your project.

## Quality profiles

A **quality profile** is a set of coding rules that SonarQube applies to your code during analysis. Profiles determine which issues are detected and how they are classified (bug, code smell, security vulnerability, etc.).

### Default profiles

SonarQube comes with built-in profiles:

- **Sonar way** – Recommended profile balancing coverage and maintainability.
- **Sonar way Security** – Focus on security vulnerabilities and hotspots.
- **Sonar way Reliability** – Focus on bugs and reliability issues.

### Creating a custom profile

1. In SonarQube, go to **Quality Profiles**.
2. Click **Create** and select the language (e.g., C#).
3. Name the profile (e.g., "Company Standard").
4. Select a parent profile or start from scratch.
5. Add/modify rules:
   - Click **Change** (parent profile name) to customize.
   - Enable or disable rules based on your requirements.
   - Set rule severity (Blocker, Critical, Major, Minor, Info).
   - Set rule parameters (e.g., max method length).
6. Save the profile.

### Assigning a profile to the project

In the project settings:

1. Go to **Quality Profiles**.
2. Select the profile for each language.
3. Save.

Future scans will use the selected profile.

### Example: Banking sector profile

A stricter profile for financial services might:

- **Disable** rules for minor code style issues.
- **Enable** all security rules as Blockers.
- **Enable** all reliability rules (bugs) as Critical or higher.
- **Increase** method complexity threshold to catch overly complex logic.
- **Enable** OWASP Top 10 and CWE rules.

## Quality gates

A **quality gate** is a set of conditions that determine whether a project is "release-ready." Quality gates are enforced at project level and block merge/release if conditions are not met.

### Default quality gate

The default "Sonar way" quality gate includes:

- Bugs: `< 1`
- Code Smell Rating: `A` (excellent)
- Coverage: `> 80%` (on new code)
- Duplicated Lines: `< 3%` (on new code)
- Maintainability Rating: `A` (excellent)
- Security Issues: `< 1`
- Security Hotspots: `>= 100% reviewed`

### Creating a custom quality gate

1. In SonarQube, go to **Quality Gates**.
2. Click **Create** and name it (e.g., "Strict").
3. Add conditions by clicking **Add Condition**:
   - Select metric (e.g., "Bugs").
   - Select comparison (e.g., "is greater than").
   - Set threshold (e.g., `0`).
   - Select scope (Overall code or New code).
4. Save the gate.

### Assigning the quality gate to projects

1. In the project dashboard, click the settings icon.
2. Go to **Quality Gate**.
3. Select the gate to enforce.
4. Save.

### Example: Lenient gate (startup)

For rapid iteration, a lenient gate might allow:

- Bugs: `> 10` (known technical debt)
- Coverage: `> 50%` (early-stage testing)
- Code Smells: `Rating >= B` (acceptable debt)
- Security: `< 1` (no compromise on security)

### Example: Strict gate (regulated)

For production systems:

- Bugs: `== 0` (zero defects)
- Coverage: `> 90%` (comprehensive testing)
- Code Smells: `Rating >= A` (excellent)
- Security: `== 0` (no vulnerabilities)
- Security Hotspots: `100% reviewed` (all security-sensitive code reviewed)
- Duplicated Lines: `< 1%` (high code reuse)

## Applying quality gates in CI/CD

### GitHub Actions integration

The workflow in this repository checks the quality gate:

```yaml
- name: SonarQube Quality Gate Status
  run: |
    echo "SonarQube analysis completed. Check the SonarQube dashboard for detailed results."
    echo "Dashboard: http://localhost:9000"
```

To make the build fail if the quality gate fails:

```yaml
- name: Fail if quality gate fails
  run: |
    STATUS=$(curl -s -H "Authorization: Bearer ${{ secrets.SONAR_LOGIN }}" \
      http://localhost:9000/api/qualitygates/project_status?projectKey=pwc-github-code-quality \
      | jq -r '.projectStatus.status')
    if [ "$STATUS" != "OK" ]; then
      echo "Quality gate failed: $STATUS"
      exit 1
    fi
```

### Branch protection

To enforce quality gates at merge time:

1. In GitHub repository settings, go to **Branches**.
2. Edit the protection rule for `main`.
3. Require the **Build and analyze with SonarQube** check.
4. Optionally, require dismissal of code review before merge.

## Monitoring and tuning

### Reviewing gate failures

When a quality gate fails:

1. Check the SonarQube project dashboard.
2. See which conditions failed.
3. Review the **Issues** tab for details.
4. Decide: fix the code or adjust the gate threshold.

### Gradual tightening

A recommended approach is to tighten gates gradually:

1. **Week 1:** Gate focused on security and critical bugs.
2. **Week 2:** Add coverage threshold (e.g., > 60%).
3. **Week 3:** Increase coverage (e.g., > 70%).
4. **Week 4:** Add maintainability and duplication rules.

This allows the team to adjust practices incrementally.

### Historical trends

SonarQube tracks metrics over time:

1. In the project dashboard, click **Activity**.
2. See how metrics (coverage, duplicated lines, technical debt) trend.
3. Use trends to identify improvements or regressions.

## Best practices

1. **Start with recommended profiles and gates** – Don't customize prematurely.
2. **Make gates visible** – Share gate status in PR comments and dashboards.
3. **Educate the team** – Explain what each metric means and why it matters.
4. **Tune by data** – Adjust thresholds based on your team's baseline, not arbitrary values.
5. **Security first** – Never compromise on security rules or hotspot review.
6. **Coverage, not perfection** – Aim for 80%+ coverage; 100% is usually not cost-effective.
7. **Communicate exceptions** – Document why certain rules or gates are disabled.
8. **Review regularly** – Check quality metrics monthly and adjust as the codebase evolves.

## Common customizations by language

### C# specific

- **Naming conventions** – Enforce PascalCase for classes, methods, etc.
- **Cyclomatic complexity** – Warn if methods exceed 10-15 paths.
- **LINQ usage** – Recommend LINQ over loops.
- **Async/await** – Warn on blocking calls in async code.

### JavaScript specific

- **Semicolon usage** – Enforce or disable based on preference.
- **ES6 features** – Require or allow ES6 syntax.
- **Type checking** – Integrate TypeScript or JSDoc.

## Next steps

- [sonarqube-setup-guide.md](sonarqube-setup-guide.md) – Setup and installation.
- [sonarqube-workflow-guide.md](sonarqube-workflow-guide.md) – CI/CD integration.
- [self-hosted-vs-saas.md](self-hosted-vs-saas.md) – Deployment models.
