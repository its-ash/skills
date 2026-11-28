@REF:security-bounty-hunter
§GOAL{remote_reachable_exploitable_vulns(Huntr|HackerOne|Bugcrowd|VDP);bias:user_controlled_network_paths;¬broad_audit}
§SCOPE{
  SSRF(user_URL)→CWE-918:int_net|cloud_meta(IMDSv1_vs_v2);
  AuthBypass(middleware|guard)→CWE-287:unauth_acct_data;
  BOLA/IDOR(obj_ref)→CWE-639:cross_tenant/user_read_write;
  RemoteDeser|UploadRCE→CWE-502|CWE-434:RCE;
  SQLi(endpoint)→CWE-89:exfil|auth|destruct;
  CmdInj(handler)→CWE-78:RCE;
  SSTI(tpl_render)→CWE-1336:RCE;
  PathTrav(file_srv)→CWE-22:arb_RW;
  OAuth_ATO(redirect/state)→CWE-601|CWE-352:tok_theft;
  Stored/DOM_XSS→CWE-79:sess_theft|admin_action
}
§ANTI{unless_in_scope:local(pickle.loads|torch.load);eval|exec(CLI);shell=True(hardcoded);missing_headers_only;rate_limit(¬concrete_impact);self_XSS;clickjacking_non_sensitive;out_of_scope_CICD;demo|example|test}
§FLOW{1:scope(rules,SECURITY.md,safe_harbor,excl)→2:entrypoints(HTTP,API,GraphQL,upload,jobs,webhook,parser,OAuth)→3:static_triage(web-vulnerability-testing.md)→4:trace_source_to_sink_e2e→5:prove(user_ctrl→exploitable_sink)→6:minimal_safe_PoC(¬real_user_data)→7:dedup}
§CMD{
  sast:`semgrep --config=auto --severity=ERROR --severity=WARNING --json`∨`opengrep --config=auto --json`→drop{test,demo,fixture,vendor,local}∧keep{net|user_route};
  secrets:`gitleaks detect --no-banner`∨`trufflehog git file://. --only-verified`;
  dast:`nuclei -u https://target -severity medium,high,critical`
}
§RPT{Title(vuln+component);Description(root_cause+CWE);Vulnerable_Code(file,lines,snippet);Proof_of_Concept(min_repro_req|script);Impact(concrete_exploit_scenario);Affected_Version(ver|commit|target);Remediation}
§CHK{reachable_net_boundary;user_controlled_src;exploitable_sink;minimal_PoC_verified;¬dup(advisory|CVE|GHSA|ticket);in_scope}
§REF{web_pentest→web-vulnerability-testing.md;secure_fixes→secure-patterns.md}
