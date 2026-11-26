---
description: "FastAPI review: arch,async,DI,Pydantic,sec,perf,tests"
---
@CMD:fastapi-review
§FLOW{1:invoke(fastapi-reviewer,[file-or-directory]?)→2:audit{app_factory,routers,mw,exc_handlers;pydantic_req_resp_sep;DI(db_session,auth,pagination,settings);async_db_http;CORS,auth,rate_limit,log,secrets;openapi_meta_resp_models;test_client,dep_overrides}→3:emit(§OUT)}
§OUT{[SEVERITY] <title> | File:<path>:<line> | Issue:<what∧why> | Fix:<Δ>}
§REL{cmd:/python-review,skill:{backend-development/references/fastapi.md,secure-coding/SKILL.md}}
