# Terraform and IaC Pipeline

Parent: [`devops-iac`](../SKILL.md). Module layout and backend block: [cloud-architecture.md](cloud-architecture.md). General workflow syntax: [github-actions.md](github-actions.md).

## Rules

- Remote state backend with locking (e.g. S3 + DynamoDB lock). Encrypt state at rest and in transit.
- Reusable modules in `modules/`; inputs in `variables.tf`, exports in `outputs.tf`; consistent naming.
- `terraform fmt` and `terraform validate` on every commit.
- `terraform plan` in CI; apply only the saved plan, after approval.
- Detect drift with `terraform plan -refresh-only`.
- Scan IaC in CI: Checkov, tfsec, or Terrascan.
- CI runners use least-privilege IAM roles.

```bash
terraform init -backend-config="bucket=my-tf-state" -backend-config="key=prod/terraform.tfstate"
terraform validate
terraform plan -out=plan.out        # CI step
terraform apply "plan.out"          # after manual approval
```

## CI pipeline (lint -> test -> scan -> plan -> gated apply)

Gate `apply` in production with GitHub environment protection rules (required reviewers).

```yaml
name: IaC
on:
  push: { branches: [main] }
  pull_request: { branches: [main] }
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: terraform fmt -check
  test:
    needs: lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: ./run_tests.sh
  security:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: bridgecrewio/checkov-action@v12
        with: { directory: . }
  plan:
    needs: security
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: terraform init && terraform plan -out=tfplan
      - uses: actions/upload-artifact@v4
        with: { name: tfplan, path: tfplan }
  apply:
    needs: plan
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    environment: production
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/download-artifact@v4
        with: { name: tfplan }
      - run: terraform init && terraform apply tfplan
```
