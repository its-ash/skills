@REF:phi-compliance
§SCOPE{HIPAA(US),DISHA(IN),GDPR(EU);layers:[classification,access_control,audit]}
§CLS{PHI(identifying∧health):{name,dob,address,phone,email,national_ID(SSN,Aadhaar,NHS),MRN,diagnoses,meds,labs,imaging,insurance_policy_claims,appointments_admissions,any_combo};PII(non_patient):{staff_personal,doctor_fees_payouts,employee_salary_bank,vendor_payment}}
§SQL{
```sql
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
CREATE POLICY "staff_read_own_facility" ON patients FOR SELECT TO authenticated USING (facility_id IN (SELECT facility_id FROM staff_assignments WHERE user_id=auth.uid() AND role IN ('doctor','nurse','lab_tech','admin')));
CREATE POLICY "audit_insert_only" ON audit_log FOR INSERT TO authenticated WITH CHECK (user_id=auth.uid());
CREATE POLICY "audit_no_modify" ON audit_log FOR UPDATE USING (false);
CREATE POLICY "audit_no_delete" ON audit_log FOR DELETE USING (false);
COMMENT ON COLUMN patients.name IS 'PHI: patient_name';
COMMENT ON COLUMN patients.dob IS 'PHI: date_of_birth';
COMMENT ON COLUMN patients.aadhaar IS 'PHI: national_id';
COMMENT ON COLUMN doctor_payouts.amount IS 'PII: financial';
```
}
§SIG{`interface AuditEntry{timestamp:string;user_id:string;patient_id:string;action:'create'|'read'|'update'|'delete'|'print'|'export';resource_type:string;resource_id:string;changes?:{before:object;after:object};ip_address:string;session_id:string}`}
§LEAK{errors:generic_client('Record not found')∧server_log(opaque_ID);console_logs:¬patient_obj∧¬MRN∧¬national_ID∧¬name⇒opaque_UUID_only∧sanitize_stacks;url_params:¬PHI∈query|path⇒opaque_UUID_only;browser_storage:¬PHI∈localStorage|sessionStorage⇒mem_only+fetch_on_demand;keys:¬service_role∈client⇒anon_key+RLS}
§CHK{¬PHI∈{errors,stacks,console,URLs,browser_storage};¬service_role∈client;RLS∀PHI_PII_tables;audit∀PHI_access_mutations;session_timeout;auth∀PHI_endpoints;cross_facility_isolation(facility_A_doc→query_facility_B⇒0_rows)}
