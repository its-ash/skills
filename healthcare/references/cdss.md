@REF:cdss
§SCOPE{
  patient_safety_critical∧FN≡0;
  use∈{drug_interactions,UCUM_dose_validation,clinical_scoring(NEWS2_ACVPU,qSOFA,APACHE,GCS),abnormal_lab_alerts,med_order_safety,CDS_Hooks_v2,predictive_DSI}
}
§ARCH{
  pure_fn_lib∧side_effects=0∧deterministic_core;
  EMR_UI|CDS_Hooks_v2(patient-view,order-select,order-sign)→CDSS(DrugInteractionChecker[RxCUI],DoseValidator[UCUM],ClinicalScoring[RCP_NEWS2],AlertClassifier)→EMR_UI|CDS_Card(inline,block_critical,override_audit)
}
§REG{
  FDA_non_device_CDS(Sec_520o1E):exempt_ONLY_if_ALL_4_hold:[1_no_image_or_signal_acquisition/analysis,2_display_analyze_print_medical_info,3_support_HCP_judgment_not_replace,4_clinician_can_independently_review_basis];else⇒FDA_SaMD(premarket+PCCP_for_ML_updates);
  ASTP_ONC_HTI-1_DSI:certified_EHR_predictive_CDS⇒expose_source_attributes(evidence,training_data,intended_use,intervention_risk_mgmt)+clinician_feedback_loop;
  EU_AI_Act:clinical_AI_CDSS⇒Annex_III_High_Risk(2027-12-02)∨Annex_I_MDR_IVDR(2028-08-02)∧Art50_transparency(2026-08)
}
§SIG{
```ts
interface CodedDrug { rxcui: string; genericName: string; brandName?: string }
interface DrugInteractionPair { rxcuiA: string; rxcuiB: string; severity: 'critical'|'major'|'minor'; mechanism: string; clinicalEffect: string; recommendation: string; evidenceSource: string }
interface DoseInput { drug: CodedDrug; amount: number; unit: 'mg'|'mcg'|'g'|'mL'|'units'; route: 'oral'|'iv'|'im'|'sc'|'topical'; weightKg?: number; ageYears?: number; eGFR?: number; crCl?: number }
interface DoseValidationResult { valid: boolean; normalizedAmountMg?: number; message: string; suggestedRange: { min: number; max: number; unit: string } | null; factors: string[]; basis: string }
interface NEWS2Input { respiratoryRate: number; oxygenSaturation: number; spo2Scale: 1|2; supplementalOxygen: boolean; temperatureC: number; systolicBP: number; heartRate: number; consciousness: 'alert'|'confusion'|'voice'|'pain'|'unresponsive' }
interface NEWS2Result { total: number; maxSingleParam: number; risk: 'low'|'low-medium'|'medium'|'high'; components: Record<string, number>; escalation: string } // adult≥16y; total:0-20
```
}
§PAT{
  checkInteractions(newDrug,currentMeds[],allergies[]):¬newDrug?.rxcui⇒[];resolve_RxCUI_and_class_hierarchy(¬brand_string_only);∀m∈currentMeds:findInteraction(newDrug.rxcui,m.rxcui)[bidirectional]⇒{severity,pair:[newDrug,m],message:clinicalEffect,recommendation,evidenceSource};∀a∈allergies:isCrossReactive(newDrug,a)⇒{severity:'critical',pair:[newDrug,a],message:`Cross-reactivity:${a}`,recommendation:'Do not prescribe without allergy consultation',evidenceSource};return sort_asc(severityOrder);
  validateDose(input:DoseInput):rules=getDoseRules(input.drug.rxcui,input.route);¬rules⇒{valid:true,suggestedRange:null,factors:['no_rule_found'],basis:'unconfigured'};reject_if(unit_incompatible_with_UCUM_rule)⇒BLOCK{valid:false,factors:['unit_mismatch']};norm=convertUCUM(input.amount,input.unit,rules.baseUnit);rules.weightBased∧(¬input.weightKg∨input.weightKg≤0)⇒BLOCK{valid:false,suggestedRange:null,factors:['weight_missing']};check_weight(norm>maxPerKg*weightKg)∧check_age(ageYears)∧check_renal(eGFR|crCl)∧check_absoluteMax(norm>rules.absoluteMax)⇒return{valid,suggestedRange,factors,basis:rules.source};
  calculateNEWS2(v:NEWS2Input):RCP_NEWS2_exact(adults≥16y,¬pediatric,¬pregnancy);ACVPU(alert=0,confusion|voice|pain|unresponsive=3);SpO2_Scale1(default:≥96=0,94-95=1,92-93=2,≤91=3)|SpO2_Scale2(confirmed_hypercapnic_COPD:88-92_or_≥93_on_air=0,86-87_or_93-94_on_O2=1,84-85_or_95-96_on_O2=2,≤83_or_≥97_on_O2=3);O2_supp(true=2,false=0);risk:total≥7⇒'high'|total∈[5,6]⇒'medium'|maxSingleParam≡3⇒'low-medium'|else⇒'low';
  cds_hooks_card:return{summary,indicator:'info'|'warning'|'critical',detail,source:{label,url},suggestions?,overrideReasons?}+require_feedback_logging(accepted|overridden+reason)
}
§UI{
  critical⇒block+non_dismissable_modal(red+icon+aria-live='assertive')+override_reason→audit_trail+¬auto_dismiss+¬toast;
  major⇒inline_warn(orange+icon)+explicit_ack_required+basis_link;
  minor⇒inline_info(yellow+icon)+awareness_only(¬modal_to_prevent_alert_fatigue);
  ai_or_predictive_card⇒display_HTI-1_source_attributes+independent_clinical_basis
}
§TST{
  req=100%;
  ∀{rxcuiA,rxcuiB,severity}∈INTERACTION_PAIRS:test(A,[B])∧test(B,[A])∧alerts[0].severity≡severity;
  brand_alias_matches_generic_via_RxCUI(e.g._Tylenol≡acetaminophen);
  mg_vs_mcg_unit_mismatch⇒valid≡false∧'unit_mismatch'∈factors;
  weightBased∧¬weightKg⇒valid≡false∧'weight_missing'∈factors;
  NEWS2_single_param_3(consciousness:'confusion',others_normal)⇒total≡3∧risk≡'low-medium';
  NEWS2_Scale2(spo2:97,o2:true)⇒spo2_score≡3(hyperoxia_warn);
  NEWS2_Scale2(spo2:90,o2:false)⇒spo2_score≡0;
  empty_input⇒¬throw
}
§EX{
  checkInteractions(warfarin,[aspirin,metformin],[penicillin])⇒[{severity:'critical',pair:['warfarin','aspirin']}];
  validateDose(paracetamol,1000|5000,'mg','oral',70,45)⇒true([500,4000,'mg'])|false('Exceeds absolute max 4000mg');
  validateDose(gentamicin,300,'mg','iv')⇒false(['weight_missing']);
  calculateNEWS2({rr:24,spo2:93,spo2Scale:1,o2:true,tempC:38.5,sbp:100,hr:110,consciousness:'voice'})⇒{total:13,maxSingleParam:3,risk:'high'};
  calculateNEWS2({rr:16,spo2:97,spo2Scale:1,o2:false,tempC:37.0,sbp:120,hr:75,consciousness:'confusion'})⇒{total:3,maxSingleParam:3,risk:'low-medium'}
}
§ANTI{
  ¬skippable_cdss_without_reason;¬toast_interactions;¬AVPU_missing_C_new_confusion;¬Scale1_only_NEWS2;
  ¬string_only_drug_match_without_RxCUI;¬unitless_dose_numbers;¬hardcoded_unreferenced_pairs;
  ¬silent_catch;¬pass_weight_drug_without_weight;¬black_box_AI_rec_without_basis;¬any
}
