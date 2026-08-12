# Self-Hosted vs. SaaS SonarQube

This document compares self-hosted SonarQube and SonarQube Cloud (SaaS) to help you choose the right deployment model.

## Overview

| Aspect | Self-Hosted | SaaS (SonarQube Cloud) |
| --- | --- | --- |
| **Hosting** | Your infrastructure (Docker, VM, K8s) | SonarSource cloud infrastructure |
| **Cost** | Initial setup + maintenance | Pay-as-you-go or fixed plans |
| **Control** | Complete | Limited to configuration |
| **Security** | Full control, air-gapped possible | Shared infrastructure, encrypted |
| **Privacy** | Code stays on your network | Code sent to SonarSource |
| **Scalability** | Limited by your infrastructure | Automatically scalable |
| **Maintenance** | Your responsibility | SonarSource responsibility |
| **Features** | Depends on license (Community, Developer, Enterprise) | All features included |
| **Deployment time** | Hours to days | Minutes (sign up and connect) |

## Self-Hosted SonarQube

### Strengths

- **No data leaves your network** – Code and analysis results stay on-premises.
- **Complete control** – Customize plugins, analyzers, and quality profiles.
- **Cost-effective at scale** – Fixed license cost doesn't increase with project volume.
- **Air-gapped deployments** – Works in isolated networks without internet access.
- **Custom integrations** – Build webhooks and API extensions.
- **Compliance** – Meet strict data residency and privacy requirements (SOC2, GDPR, etc.).

### Weaknesses

- **Operational overhead** – You manage installation, upgrades, backups, and disaster recovery.
- **Infrastructure costs** – Server, database, storage, and network expenses.
- **Uptime responsibility** – You handle monitoring and incident response.
- **License costs** – Developer edition (100 projects) or Enterprise (unlimited).
- **Initial complexity** – Setup and configuration require expertise.

### When to choose self-hosted

- Your organization requires code to remain on-premises (banking, healthcare, government).
- You have hundreds or thousands of projects (break-even analysis favors self-hosted).
- You need air-gapped deployments.
- You require custom analyzers or deep integration with internal systems.
- You already have infrastructure and operations teams.

### Setup and deployment

This repository includes Docker Compose setup for self-hosted SonarQube:

```bash
docker-compose up -d
```

This is suitable for development and small production deployments. For enterprise scale, consider:

- **Kubernetes** – Use Helm charts for HA and auto-scaling.
- **Cloud VMs** – AWS EC2, Azure VMs, or GCP Compute Engine.
- **High availability** – Multiple SonarQube instances with shared database and load balancer.

### Upgrades and maintenance

- **Community edition** – Free, single-project focus, no commercial support.
- **Developer edition** – ~$1,000/year, up to 100 projects.
- **Enterprise edition** – Custom pricing, unlimited projects, priority support.

Upgrades are manual; plan for testing and downtime.

## SaaS SonarQube Cloud

### Strengths

- **Zero infrastructure** – No setup, no maintenance, instant access.
- **Always up-to-date** – Features and analyzers updated automatically.
- **Scalable by default** – Handles growth without capacity planning.
- **Security provided** – SOC2 Type 2, ISO 27001, encrypted data in transit and at rest.
- **Support included** – Priority customer support available.
- **Developer-friendly** – Easy to integrate with GitHub, GitLab, Bitbucket.

### Weaknesses

- **Code leaves your network** – Analysis happens on SonarSource infrastructure.
- **Cost at scale** – Per-project or per-contributor pricing can increase with growth.
- **Less customization** – Limited control over analyzers and profiles.
- **Compliance restrictions** – Not suitable for air-gapped deployments.
- **No custom plugins** – Community plugins must be approved by SonarSource.

### When to choose SaaS

- You want zero infrastructure overhead.
- Your organization can allow code to be analyzed on SonarSource infrastructure.
- You have fewer than 100 projects.
- You prioritize simplicity and time-to-value over cost optimization.
- You want automatic updates and guaranteed uptime SLAs.

### Pricing

- **Free plan** – Up to 3 projects, for open-source and non-commercial use.
- **Paid plans** – Start at ~$10-50/month per organization, depending on project count.
- **Enterprise plans** – Custom pricing for large organizations.

### Getting started

1. Sign up at https://sonarcloud.io.
2. Connect your GitHub organization.
3. Select repositories to analyze.
4. SonarQube Cloud will analyze on the next commit.

No workflow changes needed; SonarQube Cloud uses GitHub App integration.

## Decision matrix

| Scenario | Recommendation |
| --- | --- |
| Startup / small team (< 50 projects) | SaaS (simplicity, no overhead) |
| Enterprise with code compliance requirements | Self-hosted (data residency) |
| Financial services or healthcare | Self-hosted (strict compliance) |
| Public open-source projects | SaaS (free tier available) |
| Internal projects, cost-conscious | Self-hosted (long-term cost) |
| Regulated by GDPR, CCPA, or equivalents | Self-hosted or check SaaS regional data centers |
| Existing CI/CD integration with SonarQube | Self-hosted (minimal disruption) |
| Fast time-to-value is critical | SaaS (instant setup) |

## Hybrid approach

Many organizations use both:

- **SaaS for public/open-source projects** – Leverage the free tier.
- **Self-hosted for internal/proprietary code** – Maintain compliance and cost control.

The workflow and configuration in this repository work with both. Only change `SONAR_HOST_URL` and `SONAR_LOGIN` credentials between environments.

## Migration path

If you start with SaaS and later migrate to self-hosted (or vice versa):

1. Set up the target environment.
2. Run a fresh scan on the new instance.
3. Update GitHub Actions secrets and repository settings.
4. Archive or disable the old instance.

Historical data is not automatically migrated; plan for a clean start and forward tracking from the migration point.

## Compliance and security comparison

### Data privacy

| Aspect | Self-Hosted | SaaS |
| --- | --- | --- |
| **Code storage** | Your infrastructure | SonarSource data centers |
| **Encryption in transit** | Your responsibility | TLS 1.3 by default |
| **Encryption at rest** | Your responsibility | AES-256 (optional) |
| **Data residency** | Your choice | US, EU, or APAC data centers |
| **Audit logs** | Available | Available |
| **GDPR compliance** | Depends on implementation | EU data center available |
| **SOC2 Type 2** | Optional (third-party audit) | Certified |

### Security best practices for both

1. **Use strong authentication** – Enable MFA/SAML for user accounts.
2. **Secure tokens** – Rotate authentication tokens regularly.
3. **Network isolation** – For self-hosted, restrict access via VPN or IP whitelisting.
4. **Update frequency** – Keep SonarQube and dependencies patched.
5. **Access control** – Grant least privilege (project-level permissions).
6. **Audit logging** – Enable and monitor access logs.

## Recommendation for this demo

This repository is preconfigured for **self-hosted SonarQube with Docker Compose**. It's ideal for:

- Learning SonarQube locally without cost.
- Demonstrating self-hosted setup to stakeholders.
- Testing quality profiles and gates.
- Building CI/CD integration examples.

To switch to SaaS, simply:

1. Sign up at https://sonarcloud.io.
2. Connect your GitHub organization.
3. Update `.github/workflows/build-and-sonarqube-scan.yml` to use `SONAR_HOST_URL: "https://sonarcloud.io"`.
4. The rest of the workflow remains unchanged.

## Next steps

- [sonarqube-setup-guide.md](sonarqube-setup-guide.md) – Self-hosted setup details.
- [quality-profiles-and-gates.md](quality-profiles-and-gates.md) – Configuration and best practices.
- [sonarqube-workflow-guide.md](sonarqube-workflow-guide.md) – CI/CD integration.
