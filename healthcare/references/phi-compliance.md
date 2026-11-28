@REF:phi-compliance
§SCOPE{
  US:HIPAA(Privacy+Security+Breach)+Security_Rule_NPRM_blueprint(target_Jul2027:eliminate_addressable_vs_required,mandatory_MFA,universal_encryption_rest+transit,ePHI_asset_inventory+net_map,6mo_vuln_scan,annual_pentest)+42_CFR_Part_2(SUD_records,enforced_2026-02-16:single_TPO_consent,updated_NPP,strict_redisclosure,OCR_HIPAA_penalties);
  IN:DPDP_Act_2023+DPDP_Rules(Data_Fiduciary,explicit_itemized_consent,access_logs,72h_DPB_breach_notice,penalty≤250Cr)+ABDM(NHA_Health_Data_Mgmt_Policy+Consent_Manager);DISHA_2018=shelved_subsumed_into_DPDP;
  EU:GDPR_Art9(special_category_health)+EHDS(Reg_EU_2025/327,in_force_2025-03-26,primary+secondary_use_phased_2027-2035)+EU_AI_Act(Reg_EU_2026/1744_Omnibus:Art50_transparency_2026-08,Annex_III_high_risk_CDSS_2027-12-02,Annex_I_MDR_IVDR_2028-08-02);
  layers:[classification,de_identification,access_control,consent_segregation,tamper_evident_audit,leak_prevention]
}
§CLS{
  PHI(identifying∧health):{name,dob,address,phone,email,national_ID(SSN,Aadhaar,ABHA,NHS),MRN,diagnoses,meds,labs,imaging,insurance_claims,appointments,clinical_notes,any_reidentifying_combo};
  PII(non_patient):{staff_personal,clinician_payouts,NPI_bank,vendor_payment};
  Part2_SUD:{substance_use_disorder_dx,treatment_notes,program_enrollment}⇒segregated_consent_tag∧redisclosure_notice;
  Safe_Harbor_18_IDs(all_must_strip+no_actual_reID_knowledge):[1_names,2_geo<state_incl_ZIP,3_dates_except_year∧ages>89,4_phone,5_fax,6_email,7_SSN,8_MRN,9_plan_beneficiary#,10_account#,11_cert_license#,12_vehicle_VIN,13_device_serial#,14_URLs,15_IP_addr,16_biometrics,17_full_face_photos,18_other_unique_ID];
  de_id_alt:Expert_Determination(documented_statistical_very_small_reID_risk)
}
§SQL{
```sql
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE patients FORCE ROW LEVEL SECURITY;
CREATE POLICY "staff_read_own_facility" ON patients FOR SELECT TO authenticated
  USING (
    facility_id IN (
      SELECT facility_id FROM staff_assignments
      WHERE user_id = auth.uid() AND active = true AND role IN ('doctor','nurse','lab_tech','admin')
    )
    AND (NOT is_part2_sud OR EXISTS (
      SELECT 1 FROM patient_consents c
      WHERE c.patient_id = patients.id AND c.scope = 'part2_tpo' AND c.revoked_at IS NULL AND c.expires_at > now()
    ))
  );
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log FORCE ROW LEVEL SECURITY;
CREATE POLICY "audit_insert_only" ON audit_log FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "audit_no_modify" ON audit_log FOR UPDATE USING (false);
CREATE POLICY "audit_no_delete" ON audit_log FOR DELETE USING (false);
REVOKE UPDATE, DELETE, TRUNCATE ON audit_log FROM PUBLIC, authenticated;
COMMENT ON COLUMN patients.name IS 'PHI: patient_name';
COMMENT ON COLUMN patients.dob IS 'PHI: date_of_birth';
COMMENT ON COLUMN patients.national_id IS 'PHI: national_id';
COMMENT ON COLUMN patients.is_part2_sud IS 'REG: 42_CFR_Part_2_SUD_flag';
COMMENT ON COLUMN clinician_payouts.amount IS 'PII: financial';
```
}
§SIG{
```ts
interface AuditEntry {
  timestamp: string;
  user_id: string;
  patient_id: string; // opaque internal UUID only
  action: 'create'|'read'|'update'|'delete'|'print'|'export'|'override'|'break_glass';
  purpose: 'treatment'|'payment'|'operations'|'break_glass'|'patient_access'|'audit';
  resource_type: string;
  resource_id: string;
  reason?: string; // mandatory when action∈{'break_glass','override'}
  changes?: { before: object; after: object }; // store encrypted/access-controlled, never echo to app logs
  ip_address: string;
  session_id: string;
  prev_hash?: string; // SHA-256 hash chain or WORM/immutable sink for tamper evidence
  entry_hash?: string;
}
```
}
§PAT{
  break_glass:emergency_override⇒require(explicit_reason+time_boxed_grant)→write(AuditEntry{action:'break_glass',purpose:'break_glass'})→auto_alert(privacy_officer);
  audit_immutability:append_only_table(FORCE_RLS+REVOKE_UPDATE_DELETE_TRUNCATE)+hash_chain∨WORM_object_lock(S3_Object_Lock/Cloud_Audit)∧retention≥6y(HIPAA);
  tech_safeguards:MFA_all_ePHI_principals∧TLS1.3_in_transit∧AES256_KMS_envelope_at_rest_and_backups∧idle_session_timeout(15m_clinical)∧rapid_access_revocation(target≤24h);
  consent_ledger:versioned_itemized_consent(HIPAA_NPP,42_CFR_Part_2_TPO,DPDP_purpose,ABDM_artifact)∧instant_revocation_enforcement
}
§LEAK{
  errors:generic_client('Record not found')∧server_log(opaque_UUID_only);
  console_and_traces:¬patient_obj∧¬MRN∧¬national_ID∧¬name∧¬DOB⇒opaque_UUID_only∧scrub_OTel_spans∧sanitize_stacks;
  url_params:¬PHI∈query|path|referrer⇒opaque_UUID_only;
  browser_storage:¬PHI∈localStorage|sessionStorage|IndexedDB_unencrypted|caches⇒mem_only+fetch_on_demand+clear_on_logout;
  keys:¬service_role_key∈client⇒scoped_anon/user_JWT+FORCE_RLS;
  tracking_tech:post_AHA_v_Becerra⇒0_3p_pixels(Meta,GA,session_replay,CDPs_no_BAA)_on_authenticated_portals_and_patient_apps(OCR_active_enforcement)∧scrub_health_intent_params_on_public_pages;
  LLM_and_AI:¬PHI→non_BAA_LLM∧enable_ZDR(zero_data_retention,no_training)∧tokenize_or_Safe_Harbor_before_non_BAA_evals
}
§ANTI{
  ¬RLS_without_FORCE_RLS;¬target_shelved_DISHA_for_India;¬mix_42_CFR_Part_2_SUD_without_consent_gate;
  ¬3p_tracking_pixels_on_authenticated_portal;¬partial_redaction_called_deidentified(must_meet_Safe_Harbor_18_or_Expert);
  ¬PHI_in_LLM_prompts_without_BAA+ZDR;¬mutable_or_deletable_audit_log;¬service_role_in_browser
}
§CHK{
  ¬PHI∈{errors,stacks,console,OTel_traces,URLs,browser_storage,3p_trackers,non_BAA_LLM};
  FORCE_RLS∀PHI_PII_tables∧cross_facility_isolation(facility_A→facility_B⇒0_rows);
  42_CFR_Part_2_consent_gate_verified(no_consent⇒0_SUD_rows);
  audit_log_append_only(UPDATE/DELETE⇒denied)∧captures(read,write,export,break_glass,override);
  MFA+TLS1.3+AES256+idle_logoff+BAA_inventory_current;
  de_id_exports_pass_Safe_Harbor_18_ID_scanner
}
