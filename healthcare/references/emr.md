@REF:emr
§REL{cdss:cdss.md;phi:phi-compliance.md}
§R{
  invariant:"Could this harm a patient?";
  patient_banner⇒always_display≥2_identifiers(full_name+DOB/MRN)+allergies+active_meds+weight_if_pediatric;
  interactions⇒MUST_alert(¬silent_pass);
  abnormal_labs⇒MUST_visually_flag(range+delta+critical_non_dismissable);
  critical_vitals⇒MUST_trigger_escalation(NEWS2_ACVPU+Scale1|2,qSOFA);
  clinical_mutation∧chart_view⇒MUST_write_audit_trail;
  coded_first⇒store_standard_codes(ICD-10-CM/ICD-11,SNOMED_CT,RxNorm/RxCUI,LOINC,UCUM)∧preserve_free_text_only_as_supplement;
  signed_encounter⇒immutable(0_edits)∧addendum_only∧¬hard_delete(use_status='entered-in-error');
  concurrency⇒optimistic_locking(ETag/If-Match/FHIR_meta.versionId)∧¬silent_last_write_wins
}
§FLOW{
  layout:single_page_vertical_scroll∧¬tab_switching_that_hides_allergies_or_meds;
  header(sticky_always_visible):{2_patient_IDs,demographics,allergies,active_meds,part2_sensitivity_badge?};
  steps:[
    1_ChiefComplaint(templates+free_text),
    2_HPI(manual|AI_scribe_AI_DRAFT),
    3_PhysicalExam(system_wise),
    4_Vitals(LOINC+UCUM+auto_score→NEWS2[ACVPU,Scale1|2]|qSOFA),
    5_Diagnosis(ICD-10-CM|ICD-11+SNOMED_CT_search),
    6_Medications(RxNorm_DB+CDS_Hooks[order-select|order-sign]+CDSS),
    7_Investigations(LOINC_lab|radiology_orders),
    8_Plan_FollowUp(care_plan+patient_instructions),
    9_Review_Attest_Sign_Lock_Export
  ]
}
§INTEROP{
  fhir_baseline:HL7_FHIR_R4(4.0.1)+US_Core_v9.0.0(USCDI_v6;v8.x=USCDI_v5;FHIR_R6=long_term_roadmap);
  smart_launch:SMART_App_Launch_v2.2.0(OAuth2+OIDC+mandatory_PKCE_S256+.well-known/smart-configuration+granular_scopes_e.g._patient/Observation.rs?category=vital-signs);
  cds_hooks:CDS_Hooks_v2.0(patient-view,order-select,order-sign;prefetch_FHIR_R4+typed_cards+feedback_endpoint);
  bulk_and_cures:Bulk_FHIR_$export+21st_Century_Cures_info_blocking_compliance(timely_patient_access,respect_Part2_and_harm_exceptions);
  india_abdm:ABDM_FHIR_R4_NRCeS_profiles+ABHA_ID+Consent_Manager_HIP/HIU_flows
}
§SIG{
```ts
interface ClinicalTemplate {
  id: string; name: string; chips: string[];
  requiredFields: string[]; redFlags: string[];
  icdSuggestions: Array<{ system: 'ICD-10-CM'|'ICD-11'|'SNOMED-CT'; code: string; display: string }>;
}
interface AIDraftNote {
  status: 'AI_DRAFT'|'ATTESTED'; modelId: string; generatedAt: string;
  sourceTranscriptId: string; attestedBy?: string; attestedAt?: string; sections: Record<string, string>;
}
```
}
§PAT{
  templates:redFlags⇒non_dismissable_visible_alert∧¬toast;
  med_safety:select_drug(RxCUI)→check(current_meds,encounter_meds,allergies,UCUM_dose[weight,age,eGFR/CrCl])→(
    CRITICAL⇒BLOCK_prescribing∧require_documented_override_reason→audit_trail∧¬silent_allow |
    MAJOR⇒display_warning∧require_ack
  )→log(all_alerts,overrides)→audit_trail;
  locked_encounter:signed⇒immutable(0_edits)∧addendum_only(linked_record_e.g._E-2026-0891-A1)∧timeline_shows(original+addendum+timestamps+signers)∧correction_of_wrong_chart⇒status='entered-in-error'+reason(¬DELETE);
  ai_scribe:ambient_or_LLM_summary⇒BAA+ZDR_endpoint∧render_AI_DRAFT_banner∧highlight_uncertain_spans∧require_explicit_clinician_attestation_before_sign∧¬auto_commit_meds_allergies_orders
}
§UI{
  vitals:{LOINC_coded,UCUM_units,normal_range_highlight(green|yellow|red+icon_label),trend_arrows_vs_prev,auto_score(NEWS2[ACVPU,Scale1|2],qSOFA),inline_escalation};
  labs:{LOINC_coded,UCUM_units,ref_range_highlight,prev_delta,critical→non_dismissable_alert+read_back_ack,collected+resulted_timestamps,pending_TAT};
  rx_pdf_and_erx:1_click_gen({2_patient_IDs,dob,weight_if_pediatric,allergies,dx_codes,drug(generic+brand+RxCUI,UCUM_dose,route,freq,duration,qty,refills),clinician_signature+license/NPI})∨EPCS/NCPDP_SCRIPT
}
§A11Y{
  WCAG_2.2_AA(contrast≥4.5:1_text,≥3:1_UI);touch_target≥44x44px;full_keyboard_nav+visible_focus;
  ¬color_only_indicators(pair_text+icon+aria-live='assertive'_for_critical);sr_labels∀form_fields;
  ¬auto_dismiss_toast(clinical_alerts)
}
§ANTI{
  ¬clinical_data∈localStorage|sessionStorage;¬silent_cdss_fail;¬dismissable_toast(critical);
  ¬tab_hiding_allergies_or_meds;¬edit_locked_encounter;¬hard_delete_clinical_record;
  ¬silent_last_write_wins(omit_If-Match);¬auto_sign_AI_scribe_without_clinician_attestation;
  ¬free_text_only_for_meds_dx_labs;¬single_identifier_patient_header;¬any_type
}
