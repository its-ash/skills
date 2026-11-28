@REF:api-connector-builder
§GOAL{repo_native_integration(¬generic_HTTP)⇒match{layout,cfg_schema,auth,err,tests,reg/discovery}}
§ANTI{¬new_arch_if_exists;¬vendor_docs_alone(in_repo_1st);¬stop_at_transport(reg+tests+docs);¬cargo_cult_legacy_over_newer}
§FLOW{1_style:inspect≥2→map{layout,bounds,cfg,retry/pag,reg_hooks,tests/naming};2_scope:min{auth,entities,R/W_ops,pag+RL,webhook|poll};3_layers:cfg/schema→client→map→entrypoint→reg→tests;4_val:native_fit}
§PAT{provider:providers/existing_provider/{__init__.py,provider.py,config.py};connector:integrations/existing/{client.py,models.py,connector.py};ts_plugin:src/integrations/existing/{index.ts,client.ts,types.ts,test.ts}}
§CHK{repo_pat;cfg_val;explicit_auth+err;repo_pag/retry;reg_wired;repo_tests;docs_if_expected}
§REL{../SKILL.md,contract-first.md,error-handling.md}
