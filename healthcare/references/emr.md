@REF:emr
§REL{cdss:cdss.md}
§R{
  invariant:"Could this harm a patient?";
  interactions⇒MUST_alert(¬silent_pass);
  abnormal_labs⇒MUST_visually_flag;
  critical_vitals⇒MUST_trigger_escalation;
  clinical_mutation⇒MUST_write_audit_trail
}
§FLOW{
  layout:single_page_vertical_scroll∧¬tab_switching;
  header(sticky_always_visible):{demographics,allergies,active_meds};
  steps:[
    1_ChiefComplaint(templates+free_text),
    2_HPI,
    3_PhysicalExam(system_wise),
    4_Vitals(auto_score→NEWS2|qSOFA),
    5_Diagnosis(ICD-10|SNOMED_search),
    6_Medications(drug_DB+CDSS),
    7_Investigations(lab|radiology_orders),
    8_Plan_FollowUp,
    9_Sign_Lock_Print
  ]
}
§SIG{
```typescript
interface ClinicalTemplate {
  id: string; name: string; chips: string[];
  requiredFields: string[]; redFlags: string[]; icdSuggestions: string[];
}
```
}
§PAT{
  templates:redFlags⇒non_dismissable_visible_alert∧¬toast;
  med_safety:select_drug→check(current_meds,encounter_meds,allergies,dose[weight,age,renal])→(
    CRITICAL⇒BLOCK_prescribing∧require_documented_override_reason→audit_trail∧¬silent_allow |
    MAJOR⇒display_warning∧require_ack
  )→log(all_alerts,overrides)→audit_trail;
  locked_encounter:signed⇒immutable(0_edits)∧addendum_only(linked_record_e.g._E-2024-0891-A1)∧timeline_shows(original+addendum+timestamps)∧audit_captures(signer,time,addenda)
}
§UI{
  vitals:{normal_range_highlight(green|yellow|red),trend_arrows_vs_prev,auto_score(NEWS2,qSOFA),inline_escalation};
  labs:{normal_range_highlight,prev_comparison,critical→non_dismissable_alert,collection+analysis_timestamps,pending_turnaround};
  rx_pdf:1_click_gen({demographics,allergies,dx,drug(generic+brand,dose,route,freq,duration),clinician_signature_block})
}
§A11Y{
  contrast≥4.5:1(WCAG_AA);touch_target≥44x44px;full_keyboard_nav;
  ¬color_only_indicators(pair_text|icon);sr_labels∀form_fields;
  ¬auto_dismiss_toast(clinical_alerts)
}
§ANTI{
  ¬clinical_data∈localStorage;¬silent_cdss_fail;¬dismissable_toast(critical);
  ¬tab_encounter_UI;¬edit_locked_encounter;¬clinical_view_without_audit_trail;¬any_type
}
