# Pulumi ESC Secrets Guide

This guide explains how to manage secrets for OpenBudget infrastructure using
[Pulumi ESC](https://www.pulumi.com/docs/esc/) (Environments, Secrets, and Configuration).

## Overview

Secrets are managed centrally in Pulumi ESC rather than per-stack config files. Three
ESC environments form a layered hierarchy:

```
ifiokjr/openbudget-infra/base          ← shared config (domain, cloud provider)
  ├── ifiokjr/openbudget-infra/staging    ← imports base, adds staging secrets
  └── ifiokjr/openbudget-infra/production ← imports base, adds production secrets
```

Each Pulumi stack (`staging`, `production`) references its ESC environment in the stack
config file. When you run `pulumi up`, secrets are automatically injected from ESC into
`pulumi.Config()` — no manual `pulumi config set` needed.

## Prerequisites

1. **Pulumi CLI** and **ESC** installed (run `install:all` from devenv)
2. **Authenticated** with Pulumi Cloud:
   ```bash
   pulumi login
   ```
3. **PULUMI_TOKEN** set in `~/.env.dotfiles` (the devenv scripts map this to
   `PULUMI_ACCESS_TOKEN` automatically)

## Required Secrets

### Staging Environment

| Secret          | Description                         | Required                       |
| --------------- | ----------------------------------- | ------------------------------ |
| `dbPassword`    | PostgreSQL database password        | Yes                            |
| `serviceSecret` | Serverpod service-to-service secret | Yes                            |
| `redisPassword` | Redis authentication password       | No (Redis disabled in staging) |

### Production Environment

| Secret          | Description                         | Required                          |
| --------------- | ----------------------------------- | --------------------------------- |
| `dbPassword`    | PostgreSQL database password        | Yes                               |
| `serviceSecret` | Serverpod service-to-service secret | Yes                               |
| `redisPassword` | Redis authentication password       | Yes (Redis enabled in production) |

## Step-by-Step: Adding Secrets

### 1. View Current Environment

Check what's already configured:

```bash
# View staging environment (secrets shown as [secret])
pulumi env get ifiokjr/openbudget-infra/staging

# View production environment
pulumi env get ifiokjr/openbudget-infra/production
```

### 2. Set Staging Secrets

```bash
# Set the database password
pulumi env set ifiokjr/openbudget-infra/staging dbPassword <your-staging-db-password> --secret

# Set the Serverpod service secret
pulumi env set ifiokjr/openbudget-infra/staging serviceSecret <your-staging-service-secret> --secret
```

### 3. Set Production Secrets

```bash
# Set the database password
pulumi env set ifiokjr/openbudget-infra/production dbPassword <your-production-db-password> --secret

# Set the Serverpod service secret
pulumi env set ifiokjr/openbudget-infra/production serviceSecret <your-production-service-secret> --secret

# Set the Redis password (required for production)
pulumi env set ifiokjr/openbudget-infra/production redisPassword <your-production-redis-password> --secret
```

### 4. Verify Secrets Are Set

```bash
# Check that secrets appear (values hidden)
pulumi env get ifiokjr/openbudget-infra/staging
pulumi env get ifiokjr/openbudget-infra/production

# To see actual resolved values (use cautiously):
pulumi env open ifiokjr/openbudget-infra/staging
pulumi env open ifiokjr/openbudget-infra/production
```

### 5. Verify Stack Integration

```bash
# Switch to staging and check config flows through
pulumi stack select staging
pulumi config

# You should see values like:
#   openbudget-infra:cloudProvider   aws
#   openbudget-infra:dbPassword      [secret]
#   openbudget-infra:domain          openbudget.app
#   openbudget-infra:environment     staging
#   openbudget-infra:serviceSecret   [secret]
```

## Generating Strong Secrets

Use `openssl` to generate cryptographically secure passwords:

```bash
# Generate a 32-character random password
openssl rand -base64 32

# Generate a 48-character hex string
openssl rand -hex 24
```

## Changing Shared Configuration

### Switch Cloud Provider

The base environment sets `cloudProvider: aws` by default. To change it:

```bash
pulumi env set ifiokjr/openbudget-infra/base cloudProvider gcp
```

This propagates to both staging and production since they import base.

### Change Domain

```bash
pulumi env set ifiokjr/openbudget-infra/base domain yourdomain.com
```

### Override Per-Environment

If staging needs different settings from base, set them directly on the staging
environment — they override imported values:

```bash
pulumi env set ifiokjr/openbudget-infra/staging domain staging.yourdomain.com
```

## Editing Environments Directly

For bulk changes, edit the full YAML definition:

```bash
# Open in your editor
pulumi env edit ifiokjr/openbudget-infra/staging
```

The environment YAML structure:

```yaml
imports:
  - openbudget-infra/base

values:
  # Plain values
  environment: staging

  # Encrypted secrets
  dbPassword:
    fn::secret: your-password-here
  serviceSecret:
    fn::secret: your-secret-here

  # Map to Pulumi stack config
  pulumiConfig:
    openbudget-infra:environment: ${environment}
    openbudget-infra:dbPassword: ${dbPassword}
    openbudget-infra:serviceSecret: ${serviceSecret}
```

## Rotating Secrets

To rotate a secret:

1. **Update the secret in ESC**:
   ```bash
   pulumi env set ifiokjr/openbudget-infra/production dbPassword <new-password> --secret
   ```

2. **Redeploy** to propagate the change to cloud resources:
   ```bash
   pulumi stack select production
   pulumi preview   # Verify what changes
   pulumi up        # Apply
   ```

3. **Update the database** password (if rotating the DB password, update the database
   user password first, then update ESC and redeploy).

## Future: OIDC Integration

Once deployed, you can eliminate long-lived AWS/GCP credentials by adding OIDC
configuration to the base or per-environment ESC files:

```yaml
# Example: AWS OIDC in base environment
values:
  aws:
    login:
      fn::open::aws-login:
        oidc:
          roleArn: arn:aws:iam::123456789:role/pulumi-deploy
          sessionName: pulumi-esc

  environmentVariables:
    AWS_ACCESS_KEY_ID: ${aws.login.accessKeyId}
    AWS_SECRET_ACCESS_KEY: ${aws.login.secretAccessKey}
    AWS_SESSION_TOKEN: ${aws.login.sessionToken}
```

See the [Pulumi ESC AWS OIDC docs](https://www.pulumi.com/docs/esc/integrations/dynamic-login-credentials/aws-login/)
for setup instructions.

## Troubleshooting

| Problem                         | Solution                                                                         |
| ------------------------------- | -------------------------------------------------------------------------------- |
| `pulumi config` shows no values | Run `pulumi env get` to verify ESC environment exists and has `pulumiConfig` key |
| "Environment not found"         | Check org/project/name: `pulumi env ls -o ifiokjr`                               |
| Secret not resolving            | Ensure the secret is referenced in `pulumiConfig` mapping                        |
| Wrong values in stack           | Check import order — later values override earlier ones                          |
| Auth failure                    | Verify `PULUMI_TOKEN` is set in `~/.env.dotfiles`                                |
