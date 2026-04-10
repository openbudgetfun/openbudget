# OpenBudget Infrastructure

Pulumi TypeScript infrastructure for deploying the Serverpod backend to **AWS** (ECS Fargate)
or **GCP** (Cloud Run). Secrets are managed centrally via
[Pulumi ESC](https://www.pulumi.com/docs/esc/) — see [ESC_SECRETS_GUIDE.md](./ESC_SECRETS_GUIDE.md)
for detailed setup instructions.

## Quick Start

### Prerequisites

```bash
devenv up          # Start local postgres + redis
install:all        # Install eget binaries, Pulumi, pnpm, Dart deps, infra deps
```

### Add Secrets to ESC

Before deploying, you must populate the ESC environments with real secrets.
Follow the step-by-step instructions in **[ESC_SECRETS_GUIDE.md](./ESC_SECRETS_GUIDE.md)**.

Short version:

```bash
# Staging
pulumi env set ifiokjr/openbudget-infra/staging dbPassword <password> --secret
pulumi env set ifiokjr/openbudget-infra/staging serviceSecret <secret> --secret

# Production (also needs Redis password)
pulumi env set ifiokjr/openbudget-infra/production dbPassword <password> --secret
pulumi env set ifiokjr/openbudget-infra/production serviceSecret <secret> --secret
pulumi env set ifiokjr/openbudget-infra/production redisPassword <password> --secret
```

### Deploy

```bash
infra:preview                      # Preview changes (staging by default)
infra:up                           # Deploy
infra:stack select production      # Switch to production
infra:preview                      # Preview production changes
infra:up                           # Deploy production
```

## Devenv Commands

All infrastructure commands are available as devenv scripts. Run them from the
repository root — they automatically `cd` into `infra/`.

| Command              | Description                                                    |
| -------------------- | -------------------------------------------------------------- |
| `install:all`        | Install everything (eget, Pulumi, pnpm, Dart deps, infra deps) |
| `install:pulumi`     | Install Pulumi CLI from official releases                      |
| `install:pnpm`       | Install pnpm standalone binary                                 |
| `install:infra`      | Run `pnpm install` in `infra/`                                 |
| `pulumi <args>`      | Run Pulumi CLI (auto-loads `PULUMI_ACCESS_TOKEN`)              |
| `esc <args>`         | Run Pulumi ESC CLI (auto-loads `PULUMI_ACCESS_TOKEN`)          |
| `pnpm <args>`        | Run pnpm package manager                                       |
| `infra:preview`      | Preview infrastructure changes (`pulumi preview`)              |
| `infra:up`           | Deploy infrastructure changes (`pulumi up`)                    |
| `infra:destroy`      | Tear down all infrastructure resources                         |
| `infra:build`        | Type-check the infrastructure code (`tsc`)                     |
| `infra:stack <args>` | Manage Pulumi stacks (select, ls, output, etc.)                |

### Examples

```bash
# Switch stacks
infra:stack select staging
infra:stack select production

# Preview and deploy
infra:preview
infra:up

# View stack outputs (URLs, hosts)
infra:stack output

# Type-check without deploying
infra:build

# List ESC environments
esc env ls
```

## Local Development

The infrastructure code does not need to run locally for day-to-day app development.
Local Serverpod development uses `devenv up` which starts PostgreSQL on port 8090 and
Redis on port 8091 — no cloud resources needed.

### When to work with infra locally

- **Changing infrastructure** — edit TypeScript in `infra/src/`, then run `infra:build`
  to type-check and `infra:preview` to verify changes before deploying.
- **Adding secrets** — use `pulumi env set` commands as documented in
  [ESC_SECRETS_GUIDE.md](./ESC_SECRETS_GUIDE.md).
- **Rotating secrets** — update the secret in ESC, then redeploy. See the "Rotating
  Secrets" section of the ESC guide.

### Secrets management (how it works)

Secrets flow from **Pulumi ESC** into **Pulumi stacks** automatically:

```
ESC environments (Pulumi Cloud)
  ifiokjr/openbudget-infra/base         → domain, cloudProvider
  ifiokjr/openbudget-infra/staging      → imports base + staging secrets
  ifiokjr/openbudget-infra/production   → imports base + production secrets
        │
        ▼
Pulumi stack config (Pulumi.staging.yaml / Pulumi.production.yaml)
  environment:
    - openbudget-infra/staging          ← references ESC environment
        │
        ▼
TypeScript config reader (src/config.ts)
  config.requireSecret("dbPassword")    ← reads from ESC via pulumiConfig
        │
        ▼
Cloud resources (AWS Secrets Manager / GCP Secret Manager)
  Database password, service secret, Redis password
```

No secrets are stored in local files or git. The stack YAML files only contain an
ESC environment reference. All actual secret values live in Pulumi Cloud (encrypted).

### Authentication

The `pulumi` and `esc` devenv commands automatically load your token:

1. They source `~/.env.dotfiles`
2. Map `PULUMI_TOKEN` to `PULUMI_ACCESS_TOKEN`

Ensure `~/.env.dotfiles` contains:

```bash
export PULUMI_TOKEN="pul-xxxxxxxxxxxx"
```

## Cloud Provider Selection

Switch between AWS and GCP by updating the base ESC environment:

```bash
# AWS (default)
pulumi env set ifiokjr/openbudget-infra/base cloudProvider aws

# GCP (also set project and region)
pulumi env set ifiokjr/openbudget-infra/base cloudProvider gcp
pulumi config set gcp:project <your-gcp-project-id>
pulumi config set gcp:region us-central1
```

## Architecture

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

## Domain Setup

The default domain is `openbudget.app`. To change it:

```bash
pulumi env set ifiokjr/openbudget-infra/base domain yourdomain.com
```

After deploying, update your domain registrar's nameservers to point to the Route53
hosted zone (AWS) or Cloud DNS managed zone (GCP) nameservers shown in the stack outputs.

## CI/CD Deployment Pipeline

The infrastructure creates the compute platform and container registry. You need a CI/CD
pipeline to build and deploy the Serverpod Docker image.

### Docker Build & Push (AWS)

```bash
# Authenticate with ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ecr-url>

# Build and push
docker build -t <ecr-url>:latest -f openbudget_server/Dockerfile .
docker push <ecr-url>:latest

# Force new deployment
aws ecs update-service --cluster <cluster-name> --service <service-name> --force-new-deployment
```

### Docker Build & Push (GCP)

```bash
# Authenticate with Artifact Registry
gcloud auth configure-docker <region>-docker.pkg.dev

# Build and push
docker build -t <registry-url>/serverpod:latest -f openbudget_server/Dockerfile .
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

## Scaling Recommendations

### Phase 1: Launch (Current Setup)

The default configuration is designed for initial launch and low traffic:

| Resource         | Staging                       | Production                     |
| ---------------- | ----------------------------- | ------------------------------ |
| **Compute**      | 1 container (256 CPU / 512MB) | 2 containers (512 CPU / 1GB)   |
| **Database**     | db.t3.micro / db-f1-micro     | db.t3.small / db-custom-1-3840 |
| **Redis**        | Disabled                      | Optional                       |
| **Auto-scaling** | 1-3 instances                 | 2-10 instances                 |

**Estimated monthly cost**: ~$50-100 (staging), ~$150-300 (production)

### Phase 2: Growth (100-1,000 daily active users)

**Actions to take:**

1. **Enable Redis** for session caching and future call coordination:
   ```bash
   pulumi env set ifiokjr/openbudget-infra/staging redisEnabled true
   pulumi env set ifiokjr/openbudget-infra/staging redisPassword <password> --secret
   ```

2. **Upgrade database tier**:
   ```bash
   # AWS
   pulumi env set ifiokjr/openbudget-infra/production dbInstanceClass db.t3.medium
   # GCP
   pulumi env set ifiokjr/openbudget-infra/production dbTier db-custom-2-7680
   ```

3. **Increase container resources**:
   ```bash
   pulumi env set ifiokjr/openbudget-infra/production containerCpu 512
   pulumi env set ifiokjr/openbudget-infra/production containerMemory 1024
   ```

4. **Add CloudFront/CDN** for the Flutter web app. Create a CloudFront distribution
   pointing to the `app.*` subdomain for global caching of static assets.

### Phase 3: Scale (1,000-10,000 DAU)

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

## File Structure

```
infra/
├── .gitignore
├── README.md                  # This file
├── ESC_SECRETS_GUIDE.md       # Step-by-step secrets setup guide
├── package.json               # pnpm dependencies
├── tsconfig.json              # TypeScript configuration
├── Pulumi.yaml                # Project definition (pnpm runtime)
├── Pulumi.staging.yaml        # Staging stack config (ESC reference)
├── Pulumi.production.yaml     # Production stack config (ESC reference)
├── index.ts                   # Entry point — selects AWS or GCP
└── src/
    ├── config.ts              # Reads Pulumi config into typed interface
    ├── aws/
    │   ├── index.ts           # ServerpodAwsStack (top-level component)
    │   ├── networking.ts      # VPC, subnets, security groups
    │   ├── database.ts        # RDS PostgreSQL 16
    │   ├── cache.ts           # ElastiCache Redis
    │   ├── compute.ts         # ECS Fargate + ALB + ECR
    │   ├── storage.ts         # S3 (encrypted, versioned)
    │   └── dns.ts             # Route53 + ACM certificate
    └── gcp/
        ├── index.ts           # ServerpodGcpStack (top-level component)
        ├── networking.ts      # VPC, subnet, VPC connector, firewall
        ├── database.ts        # Cloud SQL PostgreSQL 16
        ├── cache.ts           # Memorystore Redis
        ├── compute.ts         # Cloud Run + Artifact Registry + HTTPS LB
        ├── storage.ts         # Cloud Storage
        └── dns.ts             # Cloud DNS
```
