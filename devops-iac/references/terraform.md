@REF:terraform
§REL{parent:../SKILL.md,layout:cloud-architecture.md,gha:github-actions.md}
§R{
  engine:Terraform(1.17.x,min`>= 1.11`)⊕OpenTofu(1.13.x,drop-in+native_state_encryption);
  state:remote_backend+encrypt(at_rest∧in_transit)+native_lock(S3:`use_lockfile=true`[GA_TF_1.11+],¬deprecated`dynamodb_table`;Azure:blob_lease;GCS:object_versioning);
  secrets:`ephemeral "..."`+write_only(`*_wo`,TF_1.11+∨OpenTofu)⇒never_written_to_state_or_plan;
  modules:`modules/`(`variables.tf`,`outputs.tf`,`versions.tf`,consistent_naming,pinned_providers`~>`);
  commit:`terraform fmt -check -recursive`∧`terraform validate`;
  test:native`terraform test`|`tofu test`(`*.tftest.hcl`,`command=plan|apply`)_before_apply;
  scan:`trivy config .`(replaces_deprecated`tfsec`,preserves`AVD-*`_IDs)⊕Checkov;¬`tfsec`;
  ci:OIDC(keyless,`id-token:write`,scoped`sub`)→`plan -out=tfplan`→approval(env_prot)→`apply tfplan`(saved_plan_only);
  drift:scheduled`terraform plan -refresh-only -detailed-exitcode`;
  iam:CI_runners=least_priv_scoped_role(read_only_plan,apply_on_main_only)
}
§CFG[s3_native_lock]{
```hcl
terraform {
  required_version = ">= 1.11.0"
  backend "s3" {
    bucket       = "my-tf-state"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # native S3 lock (.tflock); dynamodb_table is deprecated
  }
}
```
}
§CFG[ephemeral_wo]{
```hcl
ephemeral "aws_secretsmanager_secret_version" "db" { secret_id = "prod/db-pass" }
resource "aws_db_instance" "main" {
  password_wo         = ephemeral.aws_secretsmanager_secret_version.db.secret_string
  password_wo_version = 1 # bump to rotate; value never persisted in .tfstate
}
```
}
§CMD{
  `terraform init -backend-config="bucket=my-tf-state" -backend-config="key=prod/terraform.tfstate"`;
  `terraform fmt -check -recursive && terraform validate && terraform test`;
  `trivy config --severity HIGH,CRITICAL --exit-code 1 .`;
  `terraform plan -out=tfplan && terraform apply "tfplan"`;
  `terraform plan -refresh-only -detailed-exitcode`
}
§PAT[ci_pipeline]{
  on:{push:[main],pull_request:[main],schedule:[daily_drift]};
  permissions:{contents:read,id-token:write,pull-requests:write,security-events:write};
  runs_on:ubuntu-latest;pin_all_actions:40char_SHA`# vX.Y.Z`;
  lint→`actions/checkout@v7`→`terraform fmt -check -recursive && terraform validate`;
  test(needs:lint)→`terraform test`;
  security(needs:test)→`aquasecurity/trivy-action@v0.36.0+`{scan-type:config,format:sarif,severity:"CRITICAL,HIGH"}→upload_SARIF;
  plan(needs:security)→`aws-actions/configure-aws-credentials@v6`(OIDC:`role-to-assume`)→`terraform init && terraform plan -out=tfplan`→`actions/upload-artifact@v7`{name:tfplan,path:tfplan,retention-days:1};
  apply(needs:plan,if:`github.ref == 'refs/heads/main' && github.event_name == 'push'`,env:production[req_reviewers])→`aws-actions/configure-aws-credentials@v6`(OIDC)→`actions/download-artifact@v8`{name:tfplan}→`terraform init && terraform apply tfplan`
}
§ANTI{`dynamodb_table`_lock(deprecated);`tfsec`(deprecated⇒Trivy);plain_secrets_in_state(¬`ephemeral`/`_wo`);static_AWS_keys_in_GHA(⇒OIDC);`terraform apply -auto-approve`_without_saved_plan;unpinned_provider_versions;manual_console_edits(drift)}
§CHK{remote_encrypted_state+`use_lockfile=true`;`ephemeral`+`*_wo`_for_secrets;modules+pinned_providers;`fmt`+`validate`+`test`;`trivy config`_in_CI;OIDC+SHA_pinned_actions;saved_plan+env_protection;scheduled_drift_check}
