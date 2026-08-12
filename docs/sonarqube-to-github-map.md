# SonarQube To GitHub Code Quality Map

This document is the decision matrix for replacing or reducing SonarQube usage with GitHub-native controls. It is written for customer discussions where teams need to understand both the strengths and the gaps honestly.

## Executive view

GitHub can cover a large part of the SonarQube operating model when GitHub Actions, CodeQL, Dependabot, Dependency Review, branch protection, rulesets, code scanning, secret scanning, and repository ownership are configured together. The strongest fit is pull request governance, security scanning, dependency risk, and developer workflow integration.

GitHub is not a perfect one-to-one replacement for every SonarQube feature. SonarQube has mature built-in dashboards for maintainability ratings, duplicated lines, technical debt ratios, quality profiles, and quality gates across many languages. GitHub can enforce similar outcomes, but some metrics require language tooling, CodeQL custom queries, SARIF-producing scanners, or third-party marketplace actions.

## Capability comparison

| SonarQube capability | GitHub equivalent | Included here | Notes |
| --- | --- | --- | --- |
| Pull request quality gate | Required GitHub Actions checks, branch protection, rulesets | Yes | `GitHub Quality Gate` should be required before merge. |
| Static code analysis | CodeQL code scanning plus language analyzers | Yes | CodeQL `security-and-quality` query suite is enabled for C#. |
| Security vulnerabilities in code | CodeQL, code scanning alerts, security overview | Yes | Best with GitHub Advanced Security for private repositories. |
| Security hotspots | Code scanning alert review workflow | Partial | GitHub alerts can be dismissed with reason. SonarQube's hotspot-specific review UX is more specialized. |
| Dependency vulnerabilities | Dependabot alerts and Dependency Review | Yes | Dependency Review blocks risky dependency changes in PRs. |
| Secret detection | GitHub secret scanning and push protection | Settings only | Must be enabled in repository or organization settings. Not represented by a workflow file. |
| Code coverage | Test workflow plus coverage tool or SARIF/check summary | Partial | This demo models coverage as a gate. A production repo should add the language-specific coverage collector. |
| Duplicated code | Language analyzers, custom CodeQL, or SARIF scanner | Partial | GitHub does not provide a universal duplicate-code metric like SonarQube out of the box. |
| Code smells | CodeQL quality queries, compiler analyzers, linters | Yes | C# analyzers run as warnings-as-errors; CodeQL adds security and quality findings. |
| Maintainability rating | Custom score from checks, rulesets, and reports | Partial | GitHub does not provide the same A-E maintainability rating model by default. |
| Technical debt ratio | Custom reporting or third-party SARIF/check action | Not native | Use a dedicated analyzer if the customer requires the exact metric. |
| Quality profiles | Reusable workflow templates, analyzer config, CodeQL packs | Partial | GitHub uses config-as-code instead of SonarQube server-side profiles. |
| Quality gate history | Checks, workflow history, code scanning trends | Partial | GitHub has auditability, but not the same single SonarQube project history dashboard. |
| Multi-language support | CodeQL, Actions linters, Dependabot ecosystems | Yes | CodeQL supports major languages; other languages can add linters that upload SARIF. |
| Central portfolio dashboard | GitHub security overview, organization insights, projects | Partial | Strong for security. Broader quality portfolio reporting may need dashboards or exports. |
| Issue assignment workflow | GitHub issues, PR review, code owners, security campaigns | Yes | Native to GitHub collaboration model. |
| Compliance evidence | Checks, audit log, branch protection, signed commits, rulesets | Yes | Evidence is distributed across GitHub features rather than a SonarQube project page. |

## Recommended customer position

Use GitHub as the primary developer-facing quality gate where the goal is to reduce tool switching and enforce checks directly in pull requests. Keep or augment SonarQube only if the customer requires SonarQube-specific maintainability ratings, duplication dashboards, technical debt ratios, or server-managed quality profiles that must be identical across all repositories.

## What needs GitHub Advanced Security

- Code scanning with CodeQL for private repositories.
- Secret scanning and push protection for private repositories.
- Dependency Review on private repositories, depending on plan and organization licensing.
- Organization-level security overview and campaign-style remediation.

## What should be added for production repositories

- A real test framework and coverage collector for the selected language.
- Coverage threshold enforcement in CI.
- Optional SARIF upload from extra linters if the language has gaps in CodeQL coverage.
- Organization rulesets so the same controls apply consistently across many repositories.
- A reusable workflow template repository for central governance.