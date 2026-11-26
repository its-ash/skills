@REF:mailtrap-email-integration
§R{Core
- env_sep:non-prod⇒Sandbox(`sandbox.api.mailtrap.io`,captures_no_delivery); prod⇒verified(`send.api.mailtrap.io`); ¬dev→prod
- auth:`Authorization: Bearer ${MAILTRAP_API_TOKEN}`; scoped/project; sandbox≠prod tokens in separate env_vars
- dns:prod requires `SPF`,`DKIM`,`DMARC` verified; skip⇒silent_fail∨spam
- sdk:use `mailtrap` Node SDK∨Nodemailer 7 transport if in repo; raw `fetch`=0 deps
- err:wrap `try/catch`,check `r.ok`/status,log `{recipient,template,timestamp,status}`,surface_err
}
§PAT{Send_API
```ts
const URL=process.env.NODE_ENV==="production"?"https://send.api.mailtrap.io/api/send":`https://sandbox.api.mailtrap.io/api/send/${process.env.MAILTRAP_INBOX_ID}`;
const r=await fetch(URL,{method:"POST",headers:{Authorization:`Bearer ${process.env.MAILTRAP_API_TOKEN}`,"Content-Type":"application/json"},body:JSON.stringify({from:{email:"no-reply@yourverifieddomain.com",name:"Your App"},to:[{email:to}],subject,html})});
if(!r.ok)throw new Error(`Email send failed: ${r.status}`);
```
}
§ANTI{
- prod_endpoint in dev/test⇒inbox_spam∧test_data_leak→Sandbox
- hardcoded_token⇒VCS_leak→env_vars/secrets_manager
- pre-DNS(`SPF`/`DKIM`/`DMARC`)⇒silent_fail∨spam
- ¬error_handle/retry⇒silent_loss(password_reset)→check_status,log,surface_err
}
§REL{`backend-development/references/api-design.md`, `secure-coding/SKILL.md`, `devops-iac/SKILL.md`}
