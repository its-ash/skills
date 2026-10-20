---
name: secrets-management
description: "Manage secrets across CI/CD and runtime using HashiCorp Vault, AWS Secrets Manager, GitHub Actions secrets, GitLab CI variables, Kubernetes External Secrets Operator, Azure Key Vault, GCP Secret Manager, Doppler, Infisical, and sealed secrets via SOPS or age. Use when storing database passwords, API keys, access tokens, SSH keys, TLS certificates, connection strings, encryption keys, service account credentials, OAuth secrets, webhook signing keys, JWT secrets, or sensitive values in .env files, docker secrets, helm values, terraform variables, circleci contexts, or kubernetes secrets; implement rotation policies, dynamic database credentials, lease renewal, automated TLS cert renewal, and scan with trufflehog, gitguardian, detect-secrets, gitleaks, or pre-commit hooks to prevent hardcoding, meet SOC2, HIPAA, PCI-DSS, GDPR compliance, and audit access."
---

# Secrets Management

Manage secrets for CI/CD and runtime systems without hardcoding them. Store, retrieve, rotate, and audit credentials, API keys, database passwords, and certificates with least privilege.

## When to use

- Store API keys, credentials, database passwords, or TLS certificates.
- Manage secrets across CI/CD pipelines, cloud platforms, or Kubernetes.
- Rotate secrets automatically or on a schedule.
- Enforce least-privilege access and audit secret use.

## When not to use

- You plan to hardcode secrets in source control.
- You cannot secure access to the secrets backend.
- You only need local development values that are not shared.

## Workflow

1. Identify each secret, its owner, environment, and rotation requirement.
2. Choose a secrets backend and access model.
3. Store secrets in the backend, not in code or config files.
4. Grant the smallest access needed to each pipeline, service, or user.
5. Retrieve secrets at runtime or during deployment.
6. Mask secrets in logs and error output.
7. Rotate secrets on a schedule or after exposure.
8. Review audit logs for access and changes.

## Safety

- Never commit secrets to source control.
- Limit access to each secret by environment and role.
- Log secret access and changes for auditing.
- Revoke exposed or unused secrets immediately.

## Tool choices

- HashiCorp Vault: centralized storage, dynamic secrets, rotation, audit logs, fine-grained policies.
- AWS Secrets Manager: AWS-native storage, automatic rotation, RDS integration, CloudFormation support.
- Azure Key Vault: Azure-native storage, HSM-backed keys, certificates, RBAC.
- Google Secret Manager: GCP-native storage, versioning, IAM integration.
- GitHub Secrets and GitLab CI/CD variables: platform-native CI/CD secret storage.

## HashiCorp Vault

Start a development server only for local testing:

```bash
vault server -dev
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='root'
vault secrets enable -path=secret kv-v2
vault kv put secret/database/config username=admin password=secret
```

Read a value:

```bash
vault kv get -field=password secret/database/config
```

GitHub Actions example:

```yaml
- uses: hashicorp/vault-action@v2
  with:
    url: https://vault.example.com:8200
    token: ${{ secrets.VAULT_TOKEN }}
    secrets: |
      secret/data/database username | DB_USERNAME ;
      secret/data/database password | DB_PASSWORD
```

GitLab CI example:

```yaml
deploy:
  image: vault:latest
  before_script:
    - export VAULT_ADDR=https://vault.example.com:8200
    - export VAULT_TOKEN=$VAULT_TOKEN
    - apk add curl jq
  script:
    - DB_PASSWORD=$(vault kv get -field=password secret/database/config)
    - ./deploy.sh
```

Vault setup notes:

- Use a production cluster with TLS, storage backend, and unseal process.
- Use policies and roles instead of root tokens.
- Enable audit devices.
- Use short-lived tokens and dynamic secrets where possible.

## AWS Secrets Manager

Create a secret:

```bash
aws secretsmanager create-secret \
  --name production/database/password \
  --secret-string "super-secret-password"
```

Retrieve it in GitHub Actions:

```yaml
- uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: us-west-2

- run: |
    SECRET=$(aws secretsmanager get-secret-value \
      --secret-id production/database/password \
      --query SecretString --output text)
    echo "::add-mask::$SECRET"
    echo "DB_PASSWORD=$SECRET" >> $GITHUB_ENV
```

Use it in Terraform:

```hcl
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "production/database/password"
}

resource "aws_db_instance" "main" {
  allocated_storage = 100
  engine           = "postgres"
  instance_class   = "db.t3.large"
  username         = "admin"
  password         = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["password"]
}
```

## Platform CI/CD secrets

GitHub Actions:

```yaml
- run: |
    echo "API key is available as ${{ secrets.API_KEY }}"
```

Use environment secrets for deployment targets:

```yaml
deploy:
  runs-on: ubuntu-latest
  environment: production
  steps:
    - run: ./deploy.sh
```

GitLab CI/CD variables:

- Mark variables as protected for protected branches.
- Mark variables as masked to hide them in logs.
- Use file-type variables when an application expects a file.

## Kubernetes with External Secrets Operator

Sync a Vault secret into a Kubernetes Secret:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
  namespace: production
spec:
  provider:
    vault:
      server: "https://vault.example.com:8200"
      path: "secret"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "production"
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: database-credentials
  namespace: production
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: database-credentials
    creationPolicy: Owner
  data:
    - secretKey: username
      remoteRef:
        key: database/config
        property: username
    - secretKey: password
      remoteRef:
        key: database/config
        property: password
```

## Rotation

AWS Lambda rotation outline:

```python
import boto3
import json

def lambda_handler(event, context):
    client = boto3.client("secretsmanager")
    response = client.get_secret_value(SecretId="my-secret")
    current = json.loads(response["SecretString"])
    new_password = generate_strong_password()
    update_database_password(new_password)
    client.put_secret_value(
        SecretId="my-secret",
        SecretString=json.dumps({
            "username": current["username"],
            "password": new_password,
        }),
    )
    return {"statusCode": 200}
```

Manual rotation:

1. Generate a new secret.
2. Store the new secret in the backend.
3. Update applications and pipelines.
4. Verify the application works.
5. Revoke the old secret.

## Secret scanning

Pre-commit hook:

```bash
#!/bin/bash
docker run --rm -v "$(pwd):/repo" \
  trufflesecurity/trufflehog:latest \
  filesystem --directory=/repo
```

CI/CD scan:

```yaml
secret-scan:
  stage: security
  image: trufflesecurity/trufflehog:latest
  script:
    - trufflehog filesystem .
  allow_failure: false
```

Also use platform secret scanning and tools such as GitGuardian or TruffleHog.

## Best practices

- Use a different secret for each environment.
- Rotate secrets regularly and after any suspected exposure.
- Grant least privilege to users, pipelines, and services.
- Enable audit logging on the secrets backend.
- Mask secrets in CI/CD logs.
- Encrypt secrets at rest and in transit.
- Prefer short-lived tokens and dynamic secrets.
- Document which secrets each application needs.
- Run secret scanning in local hooks and CI/CD.

## Checklist

- [ ] No secrets are committed to source control.
- [ ] Each secret has an owner and rotation schedule.
- [ ] Access follows least privilege.
- [ ] Secrets are masked in logs.
- [ ] Rotation is tested.
- [ ] Audit logging is enabled.
- [ ] Secret scanning runs in hooks and CI/CD.

## Related skills

Load these when the task spans more than this skill.

- [`devops-iac`](../devops-iac/SKILL.md) — DevOps IaC skill provides a step-by-step workflow for designing, implementing, and operating cloud infrastruct…
- [`deployment-procedures`](../deployment-procedures/SKILL.md) — Provides a concise, platform‑agnostic procedure for safely deploying production services, covering pre‑checks,…
- [`docker`](../docker/SKILL.md) — Provides expert guidance for Dockerfile optimization, multi‑stage builds, image size reduction, container secu…
- [`secure-coding`](../secure-coding/SKILL.md) — Secure coding guidance and review checklists for secrets, authentication, authorization, input validation, SQL…
- [`security-compliance`](../security-compliance/SKILL.md) — Guides security and compliance work: risk assessment, control selection, framework mapping, ISMS implementatio…
- [`stripe`](../stripe/SKILL.md) — Implements Stripe payments, subscriptions, billing portal, checkout sessions, and webhooks with idempotency, s…
- [`api-integration`](../api-integration/SKILL.md) — Guides developers to integrate third‑party REST or GraphQL APIs securely and reliably. Includes authentication…
