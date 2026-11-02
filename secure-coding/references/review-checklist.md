# Security review checklist

## Full review report

Write `security_best_practices_report.md` (or user path). Include:
- Executive summary.
- Findings by severity, each with numeric ID, file path, and line numbers.
- One-sentence impact for each critical finding.
- Closing summary with report location.

Fix one finding at a time. Add a short comment that cites the practice and why. Run tests. Keep one finding per commit.

## Pre-deployment

- [ ] No hardcoded secrets; all in env or secret manager.
- [ ] All input validated; all queries parameterized.
- [ ] User content sanitized; CSP set.
- [ ] CSRF protection on state-changing requests.
- [ ] Tokens in httpOnly cookies; authorization checks on every object/function.
- [ ] Rate limits on all endpoints.
- [ ] HTTPS in production; security headers set.
- [ ] Generic error messages; no sensitive data in logs.
- [ ] Dependencies audited, no known vulnerabilities.
- [ ] Row-level security where multi-tenant.
- [ ] CORS limited to trusted origins.
- [ ] File uploads validated.
- [ ] Wallet signatures verified (blockchain only).

## OWASP API Security Top 10

1. Broken object-level authorization.
2. Broken authentication.
3. Broken object property-level authorization.
4. Unrestricted resource consumption.
5. Broken function-level authorization.
6. Unrestricted access to sensitive business flows.
7. Server-side request forgery.
8. Security misconfiguration.
9. Improper inventory management.
10. Unsafe consumption of APIs.

## Sources

- OWASP API Top 10: https://owasp.org/www-project-api-security/
- OWASP Top 10: https://owasp.org/www-project-top-ten/
- JWT BCP (RFC 8725): https://tools.ietf.org/html/rfc8725
- Next.js security: https://nextjs.org/docs/security
- Supabase auth: https://supabase.com/docs/guides/auth
- PortSwigger Academy: https://portswigger.net/web-security
