@REF:security-bounty-hunter
§GOAL{remote_reachable_exploitable_vulns(Huntr|HackerOne|disclosure);bias:user_controlled_paths;¬broad_audit}
§SCOPE{SSRF(user_URL)→CWE-918:int_net|cloud_meta;AuthBypass(middleware|guard)→CWE-287:unauth_acct_data;RemoteDeser|UploadRCE→CWE-502:RCE;SQLi(endpoint)→CWE-89:exfil|auth|destruct;CmdInj(handler)→CWE-78:RCE;PathTrav(file_srv)→CWE-22:arb_RW;AutoXSS→CWE-79:sess_theft|admin}
§ANTI{unless_in_scope:local(pickle.loads|torch.load);eval|exec(CLI);shell=True(hardcoded);missing_headers_only;rate_limit(¬impact);self_XSS;out_of_scope_CICD;demo|example|test}
§FLOW{1:scope(rules,SECURITY.md,channel,excl)→2:entrypoints(HTTP,upload,jobs,webhook,parser,integ)→3:static_triage([web-vulnerability-testing.md](web-vulnerability-testing.md))→4:read_path_e2e→5:prove(user_ctrl→sink)→6:minimal_safe_PoC→7:dedup}
§CMD{`semgrep --config=auto --severity=ERROR --severity=WARNING --json`→drop{test,demo,fixture,vendor,local}∧keep{net|user_route}}
§RPT{Description(what+why);Vulnerable_Code(file,lines,snippet);Proof_of_Concept(min_req|script);Impact;Affected_Version(ver|commit|target)}
§CHK{reachable_user_net_boundary;user_controlled;exploitable_sink;PoC_works;¬dup(advisory|CVE|ticket);in_scope}
