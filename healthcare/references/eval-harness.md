@REF:eval-harness
§R{
  framework_agnostic(Jest=ref,adapt→Vitest|pytest|PHPUnit);
  single_CRITICAL_fail⇒BLOCK_deploy;
  run_order:[1_CDSS_Accuracy,2_PHI_Exposure,3_Data_Integrity,4_Clinical_Workflow,5_Integration]
}
§GATES{
  CDSS_Accuracy:{tier:CRITICAL,req:100%,fail:BLOCK,path:'tests/cdss',flags:'--bail --ci --coverage --coverageThreshold=\'{"global":{"branches":80,"functions":80,"lines":80}}\'',scope:{bidirectional_pairs,dose_rules,scoring_vs_specs,0_FN,0_silent_fail}};
  PHI_Exposure:{tier:CRITICAL,req:100%,fail:BLOCK,path:'tests/security/phi',flags:'--bail --ci',scope:{api_errs,console,url_params,browser_storage,cross_facility_isolation,unauth_access,no_service_role_key}};
  Data_Integrity:{tier:CRITICAL,req:100%,fail:BLOCK,path:'tests/data-integrity',flags:'--bail --ci',scope:{locked_encounters,audit_trail,cascade_delete_guard,concurrent_edits,0_orphans}};
  Clinical_Workflow:{tier:HIGH,req:≥95%,fail:WARN_allow_with_review,path:'tests/clinical',scope:{encounter_lifecycle,templates,med_sets,drug_dx_search,rx_pdf,red_flags}};
  Integration:{tier:HIGH,req:≥95%,fail:WARN_allow_with_review,path:'tests/integration',scope:{HL7_v2x_parse,FHIR_validate,lab_map,malformed_msg}}
}
§CMD{
  critical_local:npx jest --testPathPattern='tests/cdss' --bail --ci --coverage && npx jest --testPathPattern='tests/security/phi' --bail --ci && npx jest --testPathPattern='tests/data-integrity' --bail --ci;
  high_rate_check:`
tmp_json=$(mktemp)
npx jest --testPathPattern='tests/clinical' --ci --json --outputFile="$tmp_json" || true
total=$(jq '.numTotalTests // 0' "$tmp_json"); passed=$(jq '.numPassedTests // 0' "$tmp_json")
[ "$total" -eq 0 ] && { echo "::error::No clinical tests found" >&2; exit 1; }
rate=$(echo "scale=2; $passed * 100 / $total" | bc)
(( $(echo "$rate < 95" | bc -l) )) && echo "::warning::Pass rate ${rate}% < 95%"
`
}
§CFG{
  ci_gha:actions/checkout@v4→actions/setup-node@v4(node-version:'20')→npm ci→sequential(CDSS[coverage≥80%],PHI,DataIntegrity)→HIGH_gates(tests/clinical,tests/integration;total≡0⇒exit 1;rate<95⇒::warning::)
}
§RPT{format:date+commit→per_cat(tests,pass,fail,status)→coverage(target≥80%)→verdict(SAFE TO DEPLOY⇔CRITICAL=100%∧HIGH≥95%)}
§ANTI{
  ¬skip_CDSS_tests;¬CRITICAL_threshold<100%;¬--no-bail(CRITICAL);
  ¬mock_CDSS_in_integration(must_test_real_logic);¬deploy_on_red_gate;¬omit_--coverage(CDSS)
}
