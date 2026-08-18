# GitHub Code Quality vs SonarQube - Component Mapping

This document provides an exact mapping between GitHub Code Quality and SonarQube components, showing how each of the 6 key quality metrics are handled in both platforms.

## Overview of 6 Quality Components

1. **Security** - Vulnerability detection and secure coding practices
2. **Maintainability** - Code smell detection and technical debt
3. **Reliability** - Bug detection and code correctness
4. **Coverage** - Code coverage metrics from tests
5. **Hotspot Review** - Security-sensitive code requiring manual review
6. **Duplication** - Duplicate code detection

---

## Component 1: Security

### SonarQube Approach
- **Metric**: Security Rating (A-E)
- **Method**: Static analysis of security vulnerabilities
- **Issues Detected**: 
  - Weak cryptography (MD5, SHA1)
  - Insecure deserialization
  - XXE/XML injection
  - TLS/SSL misconfigurations
- **Dashboard Location**: Measures → Security
- **Result Format**: Rating + Issue count + CWE tracking

### GitHub Code Quality Approach
- **Tools**: CodeQL (security-and-quality) + Roslyn Analyzers
- **Method**: 
  - CodeQL: Data-flow based security analysis (CA rules)
  - Roslyn: Syntactic analysis (MD5, SHA1, weak RNG, etc.)
- **Issues Detected**: 
  - Same vulnerabilities as SonarQube (via Roslyn)
  - Data-flow security issues (via CodeQL)
- **Dashboard Location**: Security → Code scanning alerts
- **Result Format**: Alert severity (Critical/High/Medium/Low/Note) + URL to source

### Equivalence
| SonarQube | GitHub | Notes |
|-----------|--------|-------|
| Vulnerability count | Code scanning alert count | Both find same issues for syntactic vulnerabilities |
| CWE tracking | Alert rule ID (e.g., CA5350) | GitHub shows rule origin (Microsoft.CodeAnalysis) |
| Security Hotspots | Code scanning alerts | GitHub doesn't distinguish hotspots; treats all as alerts |
| Severity levels | Alert severity | Sonar: Critical/Major/Minor; GitHub: Critical/High/Medium/Low/Note |

---

## Component 2: Maintainability

### SonarQube Approach
- **Metric**: Maintainability Rating (A-E)
- **Method**: Code smell detection
- **Issues Detected**:
  - Complex methods
  - Nested ternary operators
  - Unused variables
  - Code duplication
- **Dashboard Location**: Measures → Maintainability
- **Result Format**: Rating + Technical debt + Issue count

### GitHub Code Quality Approach
- **Tools**: Roslyn Analyzers (CA1822, CA1818, etc.)
- **Method**: Syntactic analysis for best practices
- **Issues Detected**:
  - Unused methods/parameters (CA1822)
  - Complex conditions
  - Code duplication (requires external tool)
- **Dashboard Location**: Security → Code scanning alerts (Maintainability category)
- **Result Format**: Alert severity + Rule recommendation

### Equivalence
| SonarQube | GitHub | Notes |
|-----------|--------|-------|
| Code smell count | Maintainability alerts | Both find similar issues via analyzers |
| Technical debt | Sum of estimated fix times | GitHub doesn't expose in dashboard; can be calculated |
| Rating | No direct rating | GitHub doesn't show overall rating |
| Duplication | Separate duplication metric | GitHub has no native duplication; see Component 6 |

---

## Component 3: Reliability

### SonarQube Approach
- **Metric**: Reliability Rating (A-E)
- **Method**: Bug detection via static analysis
- **Issues Detected**:
  - Potential null pointer exceptions
  - Resource leaks
  - Logic errors
  - Improper exception handling
- **Dashboard Location**: Measures → Reliability
- **Result Format**: Rating + Bug count + Issue details

### GitHub Code Quality Approach
- **Tools**: CodeQL (reliability queries) + Roslyn (CA2000 - Dispose)
- **Method**: 
  - CodeQL: Data-flow analysis for reliability issues
  - Roslyn: Syntactic checks for resource management
- **Issues Detected**:
  - Resource not disposed (CA2000)
  - Logic errors (via CodeQL path analysis)
- **Dashboard Location**: Security → Code scanning alerts (Reliability category)
- **Result Format**: Alert severity + Problem description

### Equivalence
| SonarQube | GitHub | Notes |
|-----------|--------|-------|
| Bug count | Reliability alerts | Both find disposal and logic issues |
| Rating | No direct rating | GitHub doesn't show overall Reliability rating |
| Issue tracking | Alert tracking | Both support dismissal/triage |

---

## Component 4: Coverage

### SonarQube Approach
- **Metric**: Code Coverage %
- **Source**: External coverage tools (OpenCover, Cobertura, etc.)
- **Method**: Parse coverage reports (XML/JSON)
- **Tracked**: Lines, branches, conditions
- **Dashboard Location**: Measures → Coverage
- **Integration**: Via `sonar.scm.provider=git` + coverage report upload

### GitHub Code Quality Approach
- **Tool**: GitHub Code Coverage (native support)
- **Source**: Cobertura XML format
- **Method**: 
  1. Generate coverage with `dotnet test --collect:"XPlat Code Coverage"`
  2. Convert to Cobertura XML
  3. Upload with `actions/upload-code-coverage@v1`
- **Dashboard Location**: Security → Code coverage
- **Integration**: Via workflow artifact upload

### Equivalence
| SonarQube | GitHub | Notes |
|-----------|--------|-------|
| Coverage % | Coverage % | Both use same Cobertura XML format |
| Tracked metrics | Line/branch coverage | Same coverage types |
| Trend tracking | Yes (historical) | Both track coverage over time |
| Pull request checks | Yes (on new code) | Both can enforce minimum coverage |

**Setup in GitHub workflow:**
```yaml
- name: Generate coverage report
  run: |
    dotnet test --configuration Release \
      --collect:"XPlat Code Coverage" \
      --settings:.github/coverlet.settings.json \
      --logger trx --results-directory coverage

- name: Upload coverage to GitHub
  uses: actions/upload-code-coverage@v1
  with:
    files: ./coverage/coverage.cobertura.xml
```

---

## Component 5: Hotspot Review

### SonarQube Approach
- **Metric**: Security Hotspots Reviewed %
- **Definition**: Security-sensitive code marked for manual review
- **Method**: Flag potentially dangerous operations:
  - Cryptography APIs
  - Database access
  - File operations
  - Authentication/authorization
- **Dashboard Location**: Measures → Security Hotspots
- **Workflow**: Developers review each hotspot and mark as reviewed/risky
- **Tracking**: Hotspot count + review status

### GitHub Code Quality Approach
- **No native hotspot concept**: All findings are alerts
- **Alternative approach**:
  - Use pull request comments for security-sensitive code
  - Use GitHub code reviews with custom checklists
  - Use branch protection rules requiring approval
- **Location**: Pull Requests → Reviews
- **Workflow**: Require security team review before merge
- **Tracking**: Via review comments + approval status

### Equivalence
| SonarQube | GitHub | Notes |
|-----------|--------|-------|
| Hotspots count | Manual review checklist | GitHub relies on code review process |
| Hotspots reviewed % | PR approval status | Different mechanism; same intent |
| Security-sensitive flag | Requires manual review comment | GitHub doesn't auto-flag hotspots |

**Workaround in GitHub workflow:**
```yaml
# Add security review requirement in branch protection rules
- Require pull request reviews before merging
- Add CODEOWNERS file for security-sensitive paths:
  /src/QualityDemo/TrainingOnlyInsecureExamples.cs @security-team
  /src/QualityDemo/TrainingOnlyThreatWorkbench.cs @security-team
```

---

## Component 6: Duplication

### SonarQube Approach
- **Metric**: Duplication Density %
- **Definition**: Percentage of duplicated lines vs. total lines
- **Method**: Clone detection algorithm
- **Tracked**: 
  - Duplicate blocks (default 10 lines)
  - File duplication
  - Cross-project duplication
- **Dashboard Location**: Measures → Duplication
- **Thresholds**: Can set warnings/errors at % levels
- **Result**: Shows which files have duplicates + percentage

### GitHub Code Quality Approach
- **No native duplication detection**
- **Alternative approaches**:
  1. **Manual review**: Code review best practices
  2. **Third-party integration**: 
     - CPD (Copy Paste Detector) via workflow
     - RADON for Python-like analysis
  3. **Roslyn approach**: Use code analyzers for known duplicate patterns
- **Location**: Not in standard GitHub Code Quality dashboard
- **Workflow**: Manual process or external tool integration

### Equivalence
| SonarQube | GitHub | Notes |
|-----------|--------|-------|
| Duplication % | Not available natively | GitHub requires external tools |
| Duplicate block detection | Not available | Use CPD or manual review |
| Tracking over time | Yes (SonarQube) | Not automatic in GitHub |

**GitHub workaround - Add CPD to workflow:**
```yaml
- name: Check for code duplication
  run: |
    # Download Copy Paste Detector
    dotnet tool install --global pmd --version 6.x
    
    # Run duplication check
    pmd cpd --files src/QualityDemo \
            --minimum-tokens 10 \
            --format csv > duplication-report.csv
            
    # Upload report
    echo "Duplication Report Generated"
    cat duplication-report.csv
```

---

## Summary Table: All 6 Components

| Component | SonarQube | GitHub Code Quality | Equivalence | Setup Effort |
|-----------|-----------|---------------------|-------------|--------------|
| Security | Native metric | CodeQL + Roslyn | High - same findings | Low |
| Maintainability | Native metric | Roslyn analyzers | Medium - fewer rules | Medium |
| Reliability | Native metric | CodeQL + Roslyn | High - similar detection | Low |
| Coverage | Via upload | Via actions/upload-code-coverage | High - same format | Low |
| Hotspot Review | Native workflow | Manual code review | Medium - different process | High |
| Duplication | Native metric | Via external tool (CPD) | Low - requires extra setup | High |

---

## Recommended GitHub Code Quality Setup

To achieve maximum parity with SonarQube:

1. ✅ **Security**: Use CodeQL + Roslyn (native)
2. ✅ **Maintainability**: Use Roslyn analyzers (native)
3. ✅ **Reliability**: Use CodeQL + Roslyn (native)
4. ✅ **Coverage**: Add Cobertura XML upload (simple)
5. ⚠️ **Hotspot Review**: Implement via CODEOWNERS + PR reviews (manual)
6. ⚠️ **Duplication**: Add CPD to workflow (external tool)

See [RUNBOOK.md](RUNBOOK.md) for detailed implementation steps.
