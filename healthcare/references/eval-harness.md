@REF:eval-harness
§R{
  framework_agnostic(Vitest4|Jest30=JS/TS_ref,adapt→pytest|JUnit|PHPUnit);
  single_CRITICAL_fail⇒BLOCK_deploy;
  run_order:[1_CDSS_Accuracy,2_PHI_Exposure,3_Data_Integrity,4_Clinical_Workflow,5_Integration_Conformance,6_Clinical_AI_Safety_if_AI]
}
§GATES{
  CDSS_Accuracy:{tier:CRITICAL,req:100%,fail:BLOCK,path:'tests/cdss',cov:'≥80%_global∧100%_critical_branches',scope:{bidirectional_RxCUI_pairs,UCUM_dose_rules,unit_mismatch_block,RCP_NEWS2[ACVPU_confusion,Scale1|2,single_param_3],qSOFA,0_FN,0_silent_fail}};
  PHI_Exposure:{tier:CRITICAL,req:100%,fail:BLOCK,path:'tests/security/phi',scope:{api_errs,console_OTel,url_params,browser_storage,FORCE_RLS_cross_facility,42_CFR_Part_2_consent_gate,Safe_Harbor_18_ID_deID,0_3p_trackers_auth_portal,unauth_access,no_service_role_key,LLM_prompt_boundary}};
  Data_Integrity:{tier:CRITICAL,req:100%,fail:BLOCK,path:'tests/data-integrity',scope:{locked_encounters_immutable,audit_log_UPDATE_DELETE_denied+hash_chain,entered_in_error_no_hard_delete,If-Match_optimistic_lock_conflict,0_orphans}};
  Clinical_Workflow:{tier:HIGH,req:≥95%,fail:WARN_allow_with_review,path:'tests/clinical',scope:{encounter_lifecycle,2_ID_banner,templates,med_sets,coded_drug_dx_search,rx_pdf,red_flags,WCAG_2.2_AA}};
  Integration_Conformance:{tier:HIGH_or_CRITICAL_if_certified,req:≥95%,fail:WARN_or_BLOCK,path:'tests/integration',scope:{FHIR_R4_US_Core_v9_validate(HL7_Validator|ONC_Inferno),SMART_App_Launch_v2.2_PKCE,CDS_Hooks_v2_cards,HL7_v2x_parse_and_malformed_msg,LOINC_UCUM_map}};
  Clinical_AI_Safety:{tier:CRITICAL_if_AI_present,req:100%_safety_invariants,fail:BLOCK,path:'tests/clinical-ai',scope:{0_hallucinated_meds_allergies_dx,0_dropped_red_flags,AI_DRAFT_attestation_gate,HTI-1_DSI_source_attributes,BAA_ZDR_routing,PHI_redaction_eval}}
}
§CMD{
  critical_vitest4:npx vitest run tests/cdss --bail=1 --coverage && npx vitest run tests/security/phi --bail=1 && npx vitest run tests/data-integrity --bail=1;
  critical_jest30:npx jest --testPathPatterns='tests/cdss' --bail --ci --coverage --coverageThreshold='{"global":{"branches":80,"functions":80,"lines":80}}' && npx jest --testPathPatterns='tests/security/phi' --bail --ci && npx jest --testPathPatterns='tests/data-integrity' --bail --ci;
  critical_pytest:pytest tests/cdss -x --cov=cdss --cov-fail-under=80 && pytest tests/security/phi tests/data-integrity -x;
  fhir_validate:java -jar validator_cli.jar test-fixtures/fhir/*.json -version 4.0.1 -ig hl7.fhir.us.core#9.0.0;
  high_rate_check_jest30:`
tmp_json=$(mktemp)
npx jest --testPathPatterns='tests/clinical' --ci --json --outputFile="$tmp_json" || true
total=$(jq '.numTotalTests // 0' "$tmp_json"); passed=$(jq '.numPassedTests // 0' "$tmp_json")
[ "$total" -eq 0 ] && { echo "::error::No clinical tests found" >&2; exit 1; }
rate=$(awk -v p="$passed" -v t="$total" 'BEGIN{printf "%.2f", (p*100)/t}')
awk -v r="$rate" 'BEGIN{exit !(r < 95)}' && echo "::warning::Pass rate ${rate}% < 95%"
`
}
§CFG{
  ci_gha:actions/checkout@v7→actions/setup-node@v7(node-version:'24',cache:'npm')→npm ci→sequential(CDSS[cov≥80%],PHI,DataIntegrity,ClinicalAI_if_present)→HIGH_gates(tests/clinical,tests/integration[FHIR_Validator/Inferno];total≡0⇒exit 1;rate<95⇒::warning::)
}
§RPT{format:date+commit→per_cat(tests,pass,fail,status)→coverage(global≥80%,critical_branches=100%)→conformance(US_Core_v9/SMART_v2.2)→verdict(SAFE_TO_DEPLOY⇔ALL_CRITICAL=100%∧HIGH≥95%)}
§ANTI{
  ¬skip_CDSS_or_PHI_tests;¬CRITICAL_threshold<100%;¬--no-bail(CRITICAL);
  ¬legacy_jest_--testPathPattern_singular(Jest30_requires_--testPathPatterns);
  ¬mock_CDSS_in_integration(test_real_logic);¬deploy_on_red_gate;¬omit_--coverage(CDSS);
  ¬ship_clinical_AI_without_red_flag_omission_and_hallucination_eval
}
