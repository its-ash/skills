@REF:firebase-backend
§SVC{
  Auth:identity,OAuth,passkeys(Identity_Platform);
  Firestore:NoSQL_docs,vector_search,pipelines;
  Data_Connect:relational(Cloud_SQL_PostgreSQL)+generated_typed_SDKs;
  Cloud_Functions_v2:`firebase-functions` v7(`7.4+`),Node 22|24(¬EOL_Node_20);
  Storage&App_Hosting:files,SSR(Next.js|Angular);
  Security_Rules_v2&App_Check:access_control,client_attestation
}
§D{
  data_model:read-heavy∧denormalized∧query-first(UI_queries⇒collection_structure);
  firestore_rules:{
    denormalize_across_docs⇒¬multi-read/client_joins;
    sub-collections¬deep_nesting(doc_limit<1MB);
    query-first(exact_filters+sorts_before_schema);
    composite_indexes⇔multi-field+inequality_filters;
    joins|constraints|cross-entity_tx⇒Data_Connect(PostgreSQL)
  };
  security_rules:{
    prod:NEVER `allow read, write: if true;`;
    owner:```javascript
match /users/{userId} { allow read, write: if request.auth != null && request.auth.uid == userId; }
```
    RBAC:custom_claims∨`roles`_coll;
    write_val:`request.resource.data`;
    storage:MIME_whitelist(e.g.`image/jpeg`)∧max_file_size
  };
  cloud_functions_v2:{
    import:`firebase-functions/v2`(`onRequest`,`onCall`,`onDocumentWritten`);set(`region`,`memory`,`concurrency`);
    admin:`firebase-admin`(trusted_server_ops⇒bypass_rules);
    idempotent:mandatory(at-least-once_exec);
    cold_start:minimal_deps;
    loop_guard:onUpdate_writing_same_doc⇒termination_condition
  };
  perf_and_cost:{
    ¬`onSnapshot`_on_large_colls;
    paginate:`startAfter`∨`limit`;
    aggregate:`count()`,`sum()`,`avg()`(¬fetch_all);
    modular_SDK13(`firebase` v13.4+):```javascript
import { getFirestore, collection, getDocs } from 'firebase/firestore';
```
  }
}
§ANTI{
  SQL_thinking(normalize+client_joins)⇒high_read_cost∧slow;
  client_admin_logic(e.g.subscription_status)⇒insecure;
  UI_hiding_as_security(missing_rules);
  RTDB_for_complex_queries(use Firestore=structured_data,RTDB=simple_high-freq_sync);
  legacy_compat_SDK_v8_namespaces(use_modular_v13)
}
§CHK{
  rules∀collection∧storage_path;
  query-optimized_data_model;
  modular_SDK_v13_imports;
  functions_v2(`firebase-functions` v7,Node_22/24)∧idempotent∧`firebase-admin`∧App_Check_enforced;
  pagination∀large_lists;
  Firebase_Emulators(local_dev/test)
}
§REL{../SKILL.md,../../database-design/SKILL.md,../../devops-iac/references/cloud-architecture.md,../../flutter/SKILL.md}
