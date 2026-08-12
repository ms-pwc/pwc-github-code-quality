# Security Policy

## Reporting a vulnerability

Report suspected vulnerabilities through GitHub private vulnerability reporting when it is enabled for this repository. If private reporting is not enabled yet, contact the repository owners through the approved internal security channel.

## Security controls used by this repository

This repository uses **SonarQube** to detect and manage security vulnerabilities and code quality issues.

### SonarQube security features

- **Security rules** – Analyzes code for OWASP Top 10, CWE, and banking security vulnerabilities.
- **Security Hotspots** – Identifies security-sensitive code (authentication, cryptography, injection risks).
- **Severity levels** – Issues are rated as Blocker (must fix), Critical, Major, Minor, or Info.
- **Quality gates** – Enforces zero vulnerabilities and 100% security hotspot review before merge.
- **Dependency scanning** – Identifies vulnerable third-party packages in dependency tree.

### Merge policy

Pull requests must:

1. Pass SonarQube security gate (zero vulnerabilities).
2. Resolve or document all security hotspots (100% reviewed).
3. Pass build and tests.
4. Receive CODEOWNERS approval for affected areas.

### Security hotspot review

Security hotspots are identified but may not be vulnerabilities. The security team must:

1. Review the hotspot in SonarQube.
2. Classify it as:
   - **Vulnerability** – Fix the issue before merge.
   - **Not a Vulnerability** – Justification is documented.

### Dependency management

Dependencies are tracked in `*.csproj` files. Keep them updated:

1. Run `dotnet outdated` to check for updates.
2. Run `dotnet add package <name> --version <version>` to update.
3. Review SonarQube security reports for known vulnerabilities.

### Incident response

If a security issue is found:

1. Open a private security issue in GitHub (if enabled).
2. Create a fix branch: `git checkout -b security/CVE-XXXX-XXXXX`.
3. Address the vulnerability and test the fix.
4. Submit a pull request with `[SECURITY]` in the title.
5. Request expedited review from the security team.
6. Merge and deploy quickly.

## SonarQube configuration for security

This repository is configured in `sonar-project.properties` with:

- `sonar.language=cs` – Analyzes C# code.
- Security rules for OWASP, CWE, and banking standards.
- Quality gate enforces zero vulnerabilities.

For details, see [docs/quality-profiles-and-gates.md](docs/quality-profiles-and-gates.md).
