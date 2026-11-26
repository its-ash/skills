@REF:terraform
§REL{parent:../SKILL.md,layout:cloud-architecture.md,gha:github-actions.md}
§R{state:remote_backend+lock(S3+DynamoDB)∧encrypt(at_rest∧in_transit);modules:`modules/`(`variables.tf`,`outputs.tf`,consistent_naming);∀commit:`terraform fmt`∧`terraform validate`;ci:`terraform plan`→approval→apply(saved_plan_only);drift:`terraform plan -refresh-only`;scan:Checkov|tfsec|Terrascan;iam:CI_runners=least_priv}
§CMD{`terraform init -backend-config="bucket=my-tf-state" -backend-config="key=prod/terraform.tfstate"`;`terraform validate`;`terraform plan -out=plan.out`;`terraform apply "plan.out"`}
§PAT[ci_pipeline]{
  on:{push:[main],pull_request:[main]};runs_on:ubuntu-latest;∀job:`actions/checkout@v4`;
  lint→`terraform fmt -check`;
  test(needs:lint)→`./run_tests.sh`;
  security(needs:test)→`bridgecrewio/checkov-action@v12`{directory:.};
  plan(needs:security)→`terraform init && terraform plan -out=tfplan`→`actions/upload-artifact@v4`{name:tfplan,path:tfplan};
  apply(needs:plan,if:`github.ref == 'refs/heads/main' && github.event_name == 'push'`,env:production[req_reviewers])→`actions/download-artifact@v4`{name:tfplan}→`terraform init && terraform apply tfplan`
}
