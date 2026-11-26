@REF:cloud-infrastructure-security

§WHEN{deploy(AWS|Vercel|Railway|Cloudflare)|IAM|CI/CD|IaC(Terraform|CloudFormation)|logging|secrets|CDN/edge|DR/backups}

§IAM{
  least_priv:specific_actions(s3:GetObject,s3:ListBucket)∧resource(arn:aws:s3:::my-bucket/*)¬(s3:*|"*");
  mfa:aws iam enable-mfa-device --user-name admin --serial-number arn:aws:iam::123456789:mfa/admin --authentication-code1 123456 --authentication-code2 789012
  chk:{¬root_in_prod,MFA_∀privileged,roles_for_svc_accts¬long_lived_creds,least_priv_policies,regular_access_reviews,rotate_or_rm_unused_creds}
}

§SEC{
  mgr:use(@aws-sdk/client-secrets-manager SecretsManager.getSecretValue({SecretId:'prod/api-key'}) | Vercel Secrets)¬(hardcoded|env_only_unrotated_unaudited);
  rot:aws secretsmanager rotate-secret --secret-id prod/db-password --rotation-lambda-arn arn:aws:lambda:region:account:function:rotate --rotation-rules AutomaticallyAfterDays=30
  chk:{cloud_secrets_mgr,auto_rot_DB(30d),API_keys_rot≥quarterly,¬secrets∈code|logs|errors,audit_log_secret_access}
}

§NET{
  sg(aws_security_group):ingress(443/tcp,10.0.0.0/16_VPC)∧egress(443/tcp,0.0.0.0/0); ¬ingress(0..65535,0.0.0.0/0);
  chk:{¬public_DB,SSH/RDP→VPN|bastion_only,least_priv_SGs,Network_ACLs,VPC_flow_logs}
}

§LOG{
  cw:@aws-sdk/client-cloudwatch-logs putLogEvents(logGroupName:'/aws/security/events',logStreamName:'authentication',fields:{type,userId,ip,result})∧¬sensitive_data;
  chk:{logging_∀services,failed_auth_logged,admin_actions_audited,retention≥90d,anomaly_alerts,centralized_tamper_proof}
}

§CICD{
  gha:permissions:{contents:read},actions/checkout@v4,trufflesecurity/trufflehog@main,npm audit --audit-level=high,aws-actions/configure-aws-credentials@v4(OIDC role-to-assume¬long_lived_tokens);
  pkg:npm ci(reproducible),npm audit --audit-level=moderate,npm outdated;
  chk:{OIDC¬long_lived_creds,secret_scan,dep_vuln_scan,container_scan,branch_protection,code_review_pre_merge,signed_commits}
}

§CDN{
  headers:{X-Frame-Options:DENY,X-Content-Type-Options:nosniff,Referrer-Policy:strict-origin-when-cross-origin,Permissions-Policy:"geolocation=(), microphone=()"};
  waf:{OWASP_Core_Ruleset,Cloudflare_Managed_Ruleset,rate_limiting,bot_protection};
  chk:{WAF+OWASP,rate_limit,bot_prot,DDoS_prot,sec_headers,SSL/TLS_strict}
}

§DR{
  rds(aws_db_instance):backup_retention_period=30,backup_window="03:00-04:00",maintenance_window="mon:04:00-mon:05:00",enabled_cloudwatch_logs_exports=["postgresql"],deletion_protection=true;
  chk:{auto_daily_backups,retention_compliant,PITR,quarterly_backup_test,DR_plan_doc,RPO_RTO_defined∧tested}
}

§PRE_DEPLOY{
  [ ] IAM(¬root,MFA,least_priv); [ ] Secrets(mgr+rot); [ ] Net(restricted_SG,¬public_DB);
  [ ] Log(CloudWatch+retention≥90d); [ ] Monitor(anomaly_alerts); [ ] CI/CD(OIDC,secret_scan,dep_audit);
  [ ] CDN/WAF(Cloudflare_WAF+OWASP); [ ] Crypto(enc_at_rest∧in_transit); [ ] Backups(auto+tested_recovery);
  [ ] Compliance(GDPR|HIPAA_if_app); [ ] Docs(infra+runbooks); [ ] Incident_Response_plan
}

§ANTI{
  s3_pub:¬"aws s3api put-bucket-acl --bucket my-bucket --acl public-read" ⇒ "--acl private" + "put-bucket-policy --bucket my-bucket --policy file://policy.json";
  rds_pub:¬(publicly_accessible=true) ⇒ publicly_accessible=false ∧ vpc_security_group_ids=[aws_security_group.db.id]
}

§URL{
  https://aws.amazon.com/security/best-practices/
  https://www.cisecurity.org/benchmark/amazon_web_services
  https://developers.cloudflare.com/security/
  https://owasp.org/www-project-cloud-security/
  https://www.terraform.io/docs/cloud/guides/recommended-practices/
}
