# OpenBudget Infrastructure — Setup & Scaling Guide

## Quick Start

### Prerequisites

Ensure devenv is running and tools are installed:

```bash
devenv up          # Start local services
install:all        # Install eget binaries, Dart deps, infra deps
```

### Configure Secrets

Before deploying, set required secrets for each stack:

```bash
# Select a stack
pulumi stack select staging

# Set required secrets (encrypted in state)
pulumi config set --secret openbudget-infra:dbPassword <your-db-password>
pulumi config set --secret openbudget-infra:serviceSecret <your-service-secret>

# Optional: Redis password (only needed if redisEnabled is true)
pulumi config set --secret openbudget-infra:redisPassword <your-redis-password>
```

Repeat for production:

```bash
pulumi stack select production
pulumi config set --secret openbudget-infra:dbPassword <your-db-password>
pulumi config set --secret openbudget-infra:serviceSecret <your-service-secret>
pulumi config set --secret openbudget-infra:redisPassword <your-redis-password>
```

### Switch Cloud Providers

The `cloudProvider` config controls which infrastructure is provisioned. Change it in the
stack YAML file or via CLI:

```bash
# AWS (default)
pulumi config set openbudget-infra:cloudProvider aws

# GCP
pulumi config set openbudget-infra:cloudProvider gcp
pulumi config set gcp:project <your-gcp-project-id>
pulumi config set gcp:region us-central1
```

### Deploy

```bash
pulumi stack select staging
pulumi preview    # Always preview first
pulumi up         # Deploy

pulumi stack select production
pulumi preview
pulumi up
```

### Update Domain

The default domain is `openbudget.app`. Update it per stack:

```bash
pulumi config set openbudget-infra:domain yourdomain.com
```

After deploying, update your domain registrar's nameservers to point to the Route53
hosted zone (AWS) or Cloud DNS managed zone (GCP) nameservers shown in the stack outputs.

---

## Architecture Overview

### AWS Stack

```
Internet → ALB (HTTPS/443)
             ├── api.domain     → ECS Fargate (port 8080)
             ├── app.domain     → ECS Fargate (port 8082)
             └── insights.domain → ECS Fargate (port 8081)

ECS Fargate → RDS PostgreSQL 16 (private subnet)
            → ElastiCache Redis (private subnet, optional)

S3 Bucket → File storage (private, encrypted)

Route53 → DNS management
ACM     → SSL certificate (wildcard)
ECR     → Docker image registry
```

### GCP Stack

```
Internet → HTTPS Load Balancer (port 443)
              ├── api.domain     → Cloud Run (port 8080)
              ├── app.domain     → Cloud Run (port 8082)
              └── insights.domain → Cloud Run (port 8081)

Cloud Run → Cloud SQL PostgreSQL 16 (private IP via VPC connector)
          → Memorystore Redis (optional)

Cloud Storage → File storage

Cloud DNS         → DNS management
Managed SSL Cert  → Auto-provisioned certificate
Artifact Registry → Docker image registry
```

---

## CI/CD Deployment Pipeline

The infrastructure creates the compute platform and container registry. You need a CI/CD
pipeline to build and deploy the Serverpod Docker image.

### Docker Build & Push (AWS)

```bash
# Authenticate with ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ecr-url>

# Build and push
docker build -t <ecr-url>:latest -f openbudget_server/Dockerfile openbudget_server/
docker push <ecr-url>:latest

# Force new deployment
aws ecs update-service --cluster <cluster-name> --service <service-name> --force-new-deployment
```

### Docker Build & Push (GCP)

```bash
# Authenticate with Artifact Registry
gcloud auth configure-docker <region>-docker.pkg.dev

# Build and push
docker build -t <registry-url>/serverpod:latest -f openbudget_server/Dockerfile openbudget_server/
docker push <registry-url>/serverpod:latest

# Cloud Run auto-deploys on new image (if configured)
```

### Serverpod Passwords Injection

The Serverpod container needs `config/passwords.yaml` at runtime. Options:

1. **Build-time injection** (simplest): Generate `passwords.yaml` in CI from secrets and
   copy it into the Docker image before building.
2. **Runtime injection** (more secure): Store the full YAML in Secrets Manager, modify the
   Docker entrypoint to fetch and write it before starting the server.
3. **Environment variables**: Check if your Serverpod version supports env var overrides
   for password configuration.

---

## Scaling Recommendations

### Phase 1: Launch (Current Setup)

The default configuration is designed for initial launch and low traffic:

| Resource         | Staging                       | Production                     |
| ---------------- | ----------------------------- | ------------------------------ |
| **Compute**      | 1 container (256 CPU / 512MB) | 2 containers (512 CPU / 1GB)   |
| **Database**     | db.t3.micro / db-f1-micro     | db.t3.small / db-custom-1-3840 |
| **Redis**        | Disabled                      | Optional                       |
| **Auto-scaling** | 1–3 instances                 | 2–10 instances                 |

**Estimated monthly cost**: ~$50–100 (staging), ~$150–300 (production)

### Phase 2: Growth (100–1,000 daily active users)

**Actions to take:**

1. **Enable Redis** for session caching and future call coordination:
   ```bash
   pulumi config set openbudget-infra:redisEnabled true
   pulumi config set --secret openbudget-infra:redisPassword <password>
   ```

2. **Upgrade database tier**:
   ```bash
   # AWS
   pulumi config set openbudget-infra:dbInstanceClass db.t3.medium

   # GCP
   pulumi config set openbudget-infra:dbTier db-custom-2-7680
   ```

3. **Increase container resources**:
   ```bash
   pulumi config set openbudget-infra:containerCpu 512
   pulumi config set openbudget-infra:containerMemory 1024
   ```

4. **Add CloudFront/CDN** for the Flutter web app. Create a CloudFront distribution
   pointing to the `app.*` subdomain for global caching of static assets.

### Phase 3: Scale (1,000–10,000 DAU)

**Infrastructure improvements needed:**

1. **Database read replicas**:
   - Add `AwsDatabaseReadReplica` component for read-heavy queries
   - GCP: Enable Cloud SQL read replicas with `replicaConfiguration`
   - Update Serverpod to route reads to replica endpoints

2. **Multi-AZ / Multi-region**:
   - AWS: Switch VPC to 3 AZs with NAT Gateway per AZ
   - GCP: Deploy Cloud Run in multiple regions
   - Add `NatGatewayStrategy.OnePerAz` for higher availability

3. **Connection pooling**:
   - Add PgBouncer as a sidecar container
   - Reduces database connection overhead from auto-scaling containers

4. **Dedicated Redis cluster**:
   - AWS: Switch from single-node to Redis Replication Group
   - GCP: Switch to `STANDARD_HA` tier Memorystore

5. **Monitoring & alerting**:
   - Add CloudWatch/Cloud Monitoring dashboards via Pulumi
   - Set up alerts for CPU > 80%, memory > 80%, 5xx error rate
   - Enable RDS Performance Insights / Cloud SQL Query Insights

### Phase 4: Enterprise (10,000+ DAU)

**Architecture evolution:**

1. **Role-based deployment**: Split the Serverpod monolith into separate services
   per role (api, web, insights) with independent scaling policies. The GCP stack
   already deploys 3 Cloud Run services. For AWS, create separate ECS services per role.

2. **Database sharding or vertical scaling**:
   - AWS: Move to db.r6g.large+ or Aurora PostgreSQL for auto-scaling storage
   - GCP: Move to db-custom-8-30720+ or AlloyDB for PostgreSQL

3. **Global distribution**:
   - Deploy to multiple AWS regions / GCP regions
   - Use Route53 latency-based routing or GCP global load balancer
   - Consider Aurora Global Database or Cloud SQL cross-region replicas

4. **Queue-based architecture**:
   - Add SQS/Cloud Tasks for async operations
   - Decouple heavy processing (AI features, transaction imports)

5. **WAF and DDoS protection**:
   - AWS: Add AWS WAF to the ALB
   - GCP: Enable Cloud Armor on the HTTPS load balancer

6. **Cost optimization**:
   - AWS: Use Fargate Spot for staging
   - GCP: Use Cloud Run min-instances=0 for staging
   - Add S3/GCS lifecycle policies for old file storage

---

## Pulumi ESC (Environments, Secrets, Configuration)

For centralized secret management across stacks, consider using Pulumi ESC:

```bash
# Create an ESC environment
esc env init ifiokjr/openbudget-production

# Set secrets
esc env set ifiokjr/openbudget-production db.password --secret <value>
esc env set ifiokjr/openbudget-production service.secret --secret <value>

# Reference from Pulumi.yaml
# environment:
#   - openbudget-production
```

ESC enables:

- Centralized secrets shared across stacks
- OIDC integration with AWS/GCP (no long-lived credentials)
- Secret rotation without stack updates
- Audit logs for secret access

---

## File Structure

```
infra/
├── .gitignore
├── package.json           # pnpm dependencies
├── tsconfig.json          # TypeScript configuration
├── Pulumi.yaml            # Project definition (pnpm runtime)
├── Pulumi.staging.yaml    # Staging stack config
├── Pulumi.production.yaml # Production stack config
├── index.ts               # Entry point — selects AWS or GCP
└── src/
    ├── config.ts           # Reads Pulumi config into typed interface
    ├── aws/
    │   ├── index.ts        # ServerpodAwsStack (top-level component)
    │   ├── networking.ts   # VPC, subnets, security groups
    │   ├── database.ts     # RDS PostgreSQL 16
    │   ├── cache.ts        # ElastiCache Redis
    │   ├── compute.ts      # ECS Fargate + ALB + ECR
    │   ├── storage.ts      # S3 (encrypted, versioned)
    │   └── dns.ts          # Route53 + ACM certificate
    └── gcp/
        ├── index.ts        # ServerpodGcpStack (top-level component)
        ├── networking.ts   # VPC, subnet, VPC connector, firewall
        ├── database.ts     # Cloud SQL PostgreSQL 16
        ├── cache.ts        # Memorystore Redis
        ├── compute.ts      # Cloud Run + Artifact Registry + HTTPS LB
        ├── storage.ts      # Cloud Storage
        └── dns.ts          # Cloud DNS
```

## Useful Commands

```bash
pulumi stack select staging     # Switch to staging
pulumi stack select production  # Switch to production
pulumi preview                  # Preview changes
pulumi up                       # Deploy changes
pulumi stack output             # View stack outputs (URLs, hosts)
pulumi destroy                  # Tear down all resources
pulumi stack ls                 # List all stacks
esc env ls                      # List ESC environments
```
