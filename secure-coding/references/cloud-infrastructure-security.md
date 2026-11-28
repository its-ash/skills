@REF:cloud-infrastructure-security
§WHEN{deploy(AWS|GCP|Vercel|Railway|Cloudflare)|IAM|CI/CD|IaC(Terraform|OpenTofu|CloudFormation)|logging|secrets|CDN/edge|DR/backups}
§IAM{
  least_priv:specific_actions(s3:GetObject,s3:ListBucket)∧resource(arn:aws:s3:::my-bucket/*)¬(s3:*|"*");
  human_auth:IAM_Identity_Center(SSO)+phishing_resistant_MFA(WebAuthn/FIDO2)¬IAM_users_long_lived_keys;
  svc_auth:IAM_Roles/Workload_Identity_Federation(OIDC)¬static_access_keys;
  chk:{¬root_in_prod,WebAuthn_MFA_∀privileged,short_lived_OIDC_creds,least_priv_policies,quarterly_access_reviews,rm_unused_roles_keys}
}
§SEC{
  mgr:@aws-sdk/client-secrets-manager(`getSecretValue`)|GCP_Secret_Manager|Vercel_Secrets¬(hardcoded|unrotated_env_only);
  rot:`aws secretsmanager rotate-secret --secret-id prod/db-password --rotation-lambda-arn <arn> --rotation-rules AutomaticallyAfterDays=30`;
  chk:{cloud_secrets_mgr,auto_rot_DB(30d),API_keys_rot≥quarterly,¬secrets∈code|logs|errors,audit_log_secret_access}
}
§NET{
  sg(aws_security_group):ingress(443/tcp,10.0.0.0/16_VPC)∧egress(restricted_ports/CIDRs);¬ingress(0..65535,0.0.0.0/0);
  imds_v2(aws_instance):`metadata_options{http_endpoint="enabled";http_tokens="required";http_put_response_hop_limit=1}`(blocks_SSRF_IMDSv1);
  access:AWS_SSM_Session_Manager|Tailscale|VPN¬public_SSH/RDP(22/3389);
  chk:{¬public_DB,IMDSv2_enforced,¬public_SSH_RDP,least_priv_SGs,VPC_flow_logs,egress_filtering}
}
§LOG{
  cw:@aws-sdk/client-cloudwatch-logs(`putLogEvents`,group:`/aws/security/events`,fields:{type,userId,ip,result})∧¬secrets/PII;
  chk:{logging_∀services,CloudTrail_multi_region_org,failed_auth_logged,admin_actions_audited,retention≥90d,anomaly_alerts(GuardDuty|SIEM),tamper_proof_WORM}
}
§CICD{
  pin:full_40char_commit_SHA+ver_comment(e.g.`actions/checkout@<40-char-sha> # v6`∨`v7`)¬floating_tags(@v4,@main)(post_CVE-2025-30066);
  checkout:`persist-credentials: false`;v6⇒`$RUNNER_TEMP`_tok_isolation;v7+⇒blocks_pwn_requests(untrusted_fork_on_pull_request_target/workflow_run);
  oidc:`permissions:{contents:read,id-token:write}`+`aws-actions/configure-aws-credentials@<40-char-sha>`+strict_IAM_trust_policy(`sub`_scoped_to_org/repo/env);
  scan:{workflow_SAST:`zizmor`(SARIF→GHAS),secrets:`gitleaks`(CI_gate)+`trufflehog`(live_verify_forensics),deps/IaC/img:`osv-scanner`+`trivy`,pkg:`npm ci`+`npm audit --audit-level=high`};
  provenance:SBOM(CycloneDX/SPDX)+artifact_attestation(SLSA/Sigstore);
  chk:{default_read_only_GITHUB_TOKEN,SHA_pinned_actions,Dependabot_SHA_updates,OIDC_¬static_keys,zizmor,gitleaks+trufflehog,OSV+Trivy,branch_protection,signed_commits}
}
§CDN{
  headers:{Strict-Transport-Security:"max-age=31536000; includeSubDomains; preload",Content-Security-Policy:"default-src 'self'; object-src 'none'; base-uri 'self'; frame-ancestors 'none'",X-Frame-Options:DENY,X-Content-Type-Options:nosniff,Referrer-Policy:strict-origin-when-cross-origin,Permissions-Policy:"geolocation=(), microphone=()"};
  waf:{OWASP_Core_Ruleset,Cloudflare_Managed_Ruleset,rate_limiting,bot_protection};
  chk:{WAF+OWASP,rate_limit,bot_prot,DDoS_prot,sec_headers,TLS1.3/1.2_strict_origin_cert}
}
§DR{
  rds(aws_db_instance):`backup_retention_period=30,backup_window="03:00-04:00",maintenance_window="mon:04:00-mon:05:00",enabled_cloudwatch_logs_exports=["postgresql"],storage_encrypted=true,deletion_protection=true`;
  chk:{auto_daily_backups,encrypted_backups,retention_compliant,PITR,quarterly_restore_test,DR_runbook,RPO_RTO_tested}
}
§CHK{
  IAM(¬root,WebAuthn_MFA,OIDC,least_priv);Secrets(mgr+rot);Net(restricted_SG,IMDSv2,¬public_DB,¬SSH_0.0.0.0/0);
  Log(CloudTrail+CloudWatch≥90d+alerts);CICD(SHA_pin,persist-credentials:false,OIDC,zizmor,gitleaks,OSV,Trivy);
  CDN/WAF(OWASP_CRS+TLS_strict+hdrs);Crypto(enc_at_rest∧in_transit);Backups(auto+tested_restore);IR_plan+Compliance
}
§ANTI{
  s3_acl:¬(`--acl public-read`∨`--acl private`)⇒`aws_s3_bucket_ownership_controls{object_ownership="BucketOwnerEnforced"}`+`aws_s3_bucket_public_access_block`(all_4_true);
  rds_pub:¬(`publicly_accessible=true`)⇒`publicly_accessible=false`∧`vpc_security_group_ids=[aws_security_group.db.id]`;
  imds_v1:¬(`http_tokens="optional"`)⇒`http_tokens="required"`∧`http_put_response_hop_limit=1`;
  ci_tags:¬(`uses: org/action@v4`|`@main`)⇒40char_SHA_pin
}
§URL{
  https://aws.amazon.com/security/best-practices/
  https://www.cisecurity.org/benchmark/amazon_web_services
  https://developers.cloudflare.com/security/
  https://owasp.org/www-project-cloud-security/
  https://zizmor.sh/
}
§REL{../SKILL.md:secure-coding;../../devops-iac/SKILL.md:devops-iac}
