@REF:cdss
§SCOPE{patient_safety_critical∧FN≡0;use∈{drug_interactions,dose_validation,scoring(NEWS2,qSOFA,APACHE,GCS),abnormal_alerts,med_order_safety,lab_interp}}
§ARCH{pure_fn_lib∧side_effects=0;EMR_UI→CDSS(DrugInteractionChecker,DoseValidator,ClinicalScoring,AlertClassifier)→EMR_UI(inline,block_critical)}
§SIG{
```ts
interface DrugInteractionPair{drugA:string;drugB:string;severity:'critical'|'major'|'minor';mechanism:string;clinicalEffect:string;recommendation:string}
interface DoseValidationResult{valid:boolean;message:string;suggestedRange:{min:number;max:number;unit:string}|null;factors:string[]}
interface NEWS2Input{respiratoryRate:number;oxygenSaturation:number;supplementalOxygen:boolean;temperature:number;systolicBP:number;heartRate:number;consciousness:'alert'|'voice'|'pain'|'unresponsive'}
interface NEWS2Result{total:number;risk:'low'|'low-medium'|'medium'|'high';components:Record<string,number>;escalation:string} // total:0-20
```
}
§PAT{
  checkInteractions(newDrug,currentMeds[],allergies[]):¬newDrug⇒[];∀m∈currentMeds:findInteraction(newDrug,m)[bidirectional]⇒{severity,pair:[newDrug,m],message:clinicalEffect,recommendation};∀a∈allergies:isCrossReactive(newDrug,a)⇒{severity:'critical',pair:[newDrug,a],message:`Cross-reactivity:${a}`,recommendation:'Do not prescribe without allergy consultation'};return sort_asc(severityOrder);
  validateDose(drug,dose,route:'oral'|'iv'|'im'|'sc'|'topical',weight?,age?,renalFn?):rules=getDoseRules(drug,route);¬rules⇒{valid:true,suggestedRange:null,factors:[]};rules.weightBased∧(¬weight∨weight≤0)⇒BLOCK{valid:false,suggestedRange:null,factors:['weight_missing']};rules.weightBased⇒factors+='weight'∧(dose>maxPerKg*weight⇒invalid([minPerKg*weight,maxPerKg*weight]));rules.ageAdjusted∧age!==undefined⇒factors+='age'∧(dose>getAgeAdjustedMax(age)⇒invalid([typicalMin,ageMax]));rules.renalAdjusted∧renalFn!==undefined⇒factors+='renal'∧(dose>getRenalAdjustedMax(renalFn)⇒invalid([typicalMin,renalMax]));dose>absoluteMax⇒invalid([typicalMin,absoluteMax],factors+='absolute_max');else⇒{valid:true,suggestedRange:[typicalMin,typicalMax],factors};
  calculateNEWS2(vitals):Royal_College_of_Physicians_spec_exact
}
§UI{critical⇒block+non_dismissable_modal(red)+override_reason→audit_trail+¬auto_dismiss+¬toast;major⇒inline_warn(orange)+ack_required;minor⇒inline_info(yellow)+awareness_only}
§TST{req=100%;∀{drugA,drugB,severity}∈INTERACTION_PAIRS:test(A,[B])∧test(B,[A])∧alerts[0].severity≡severity;mg/kg∧¬weight⇒valid≡false∧'weight_missing'∈factors;checkInteractions('',[],[])⇒¬throw}
§EX{checkInteractions('warfarin',['aspirin','metformin'],['penicillin'])⇒[{severity:'critical',pair:['warfarin','aspirin']}];validateDose('paracetamol',1000|5000,'oral',70,45)⇒true([500,4000,'mg'])|false('Exceeds absolute max 4000mg');validateDose('gentamicin',300,'iv')⇒false(['weight_missing']);calculateNEWS2({rr:24,spo2:93,o2:true,temp:38.5,sbp:100,hr:110,consciousness:'voice'})⇒{total:13,risk:'high'}}
§ANTI{¬skippable_cdss_without_reason;¬toast_interactions;¬any;¬hardcoded_pairs;¬silent_catch;¬pass_weight_drug_without_weight}
