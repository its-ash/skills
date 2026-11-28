@REF:deployment-patterns
§SCOPE{CI/CD,Docker,strategies(rolling|blue-green|canary),health/readiness,env_cfg,rollback,prod_readiness}
§STRAT{
  rolling(def):inst(v1→v2)|pro:0_downtime,gradual|con:v1∧v2_concurrent⇒req_backward_compat|use:std,backward_compat;
  blue_green:2x(Blue=v1←traffic,Green=v2_idle→verify→Green←traffic,Blue=standby)|pro:instant_rb(→Blue),clean_cutover|con:2x_infra|use:critical,0_tol;
  canary:split(95%v1/5%v2→ok→50/50→100%v2)|pro:real_traffic_val|con:req_split+mon|use:high_traffic,risky_Δ,flags
}
§DKR{
  node⇒[docker.md](docker.md);
  go:```dockerfile
FROM golang:1.27-alpine AS b
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /server ./cmd/server
FROM alpine:3.24
RUN apk --no-cache add ca-certificates && adduser -D -u 1001 appuser
USER appuser
COPY --from=b /server /server
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1:8080/health || exit 1
CMD ["/server"]
```;
  py:```dockerfile
FROM python:3.15-slim AS b
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/ # pin semver tag in prod
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv uv sync --frozen --no-dev --no-install-project
COPY . .
RUN --mount=type=cache,target=/root/.cache/uv uv sync --frozen --no-dev
FROM python:3.15-slim
WORKDIR /app
RUN useradd -r -u 1001 appuser
COPY --from=b --chown=appuser:appuser /app /app
ENV PATH="/app/.venv/bin:$PATH" PYTHONUNBUFFERED=1
USER appuser
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health/')" || exit 1
CMD ["gunicorn","config.wsgi:application","--bind","0.0.0.0:8000","--workers","4"]
```;
  R:{pin(`node:26-alpine`,`golang:1.27-alpine`,`python:3.15-slim`),ms,non_root,deps_before_src,`.dockerignore`(`node_modules,.git,tests`),HEALTHCHECK,res_limits(compose|k8s)};
  ANTI:{root,`:latest`,single_COPY_repo,dev_deps_prod,secrets_in_img}
}
§CICD{
  ref:[github-actions.md](github-actions.md);
  flow:{PR:lint→typecheck→unit→int→sec_scan→preview;main:lint→typecheck→unit→int→build_img(SBOM)→staging→smoke→prod};
  gha(on:push|PR@[main],ubuntu-latest,permissions:{contents:read},pin_40char_SHA_in_prod):{
    test:[`actions/checkout@v7`(persist-credentials:false),`actions/setup-node@v7`(node:26,cache:npm),`npm ci`,`npm run lint`,`npm run typecheck`,`npm test -- --coverage`,`actions/upload-artifact@v7`(if:always(),coverage→`coverage/`)];
    build(needs:test,if:main,permissions:{contents:read,packages:write,id-token:write}):[`actions/checkout@v7`,`docker/setup-buildx-action@v4`,`docker/login-action@v4`(ghcr.io,`${{github.actor}}`,`${{secrets.GITHUB_TOKEN}}`),`docker/build-push-action@v7`(push:true,provenance:mode=max,sbom:true,tags:`ghcr.io/${{github.repository}}:${{github.sha}}`,cache-from:type=gha,cache-to:`type=gha,mode=max`)];
    deploy(needs:build,if:main,env:production):GitOps_PR_bump(ArgoCD|Flux)⊕`wrangler deploy`⊕`railway up`⊕`vercel --prod`(¬raw_imperative`kubectl set image`in_GitOps_clusters)
  }
}
§HLTH{`/health`:200 `{status:"ok"}`;`/health/detailed`:check(db:`SELECT 1`→`{status:"ok",latency_ms}`|`{status:"error",message}`,redis,externalApi)→all_ok?200("ok"):503("degraded")+`{timestamp,version:APP_VERSION||"unknown",uptime,checks}`;k8s:startup+liveness(`/health`)+readiness(`/ready`→deps)⇒[kubernetes.md](kubernetes.md)(§PROBE)}
§ENV{12f:{DATABASE_URL,REDIS_URL,API_KEY(secrets_mgr),LOG_LEVEL=info,PORT=3000,NODE_ENV=production|staging|development,APP_ENV=production};zod(startup):`z.object({NODE_ENV:z.enum(["development","staging","production"]),PORT:z.coerce.number().default(3000),DATABASE_URL:z.string().url(),REDIS_URL:z.string().url(),JWT_SECRET:z.string().min(32),LOG_LEVEL:z.enum(["debug","info","warn","error"]).default("info")}).parse(process.env)`}
§RBK{cmd:{gitops:revert_image_tag_commit(ArgoCD|Flux);k8s:`kubectl rollout undo deployment/app`;vercel:`vercel rollback`;railway:`railway up --commit <prev-sha>`;prisma:`npx prisma migrate resolve --rolled-back <migration-name>`};chk:{prev_img_tagged,backward_compat_migs(¬destructive),feature_flags,err_alerts,staging_tested}}
§CHK_PROD{app:{tests(unit,int,E2E),¬secrets,edge_errs,JSON_logs(¬PII),health};infra:{pinned_docker+SBOM,env_doc+val,cpu_mem_limits,hpa(min/max),tls_all};mon:{OTel_metrics(rate,lat,err),SLO_burn_alerts,log_agg,uptime_health};sec:{Trivy_CVE_scan,OIDC_CI,cors_allowlist,rate_limit_pub,authn_authz,hdrs(CSP,HSTS,X-Frame-Options)};ops:{rbk_tested,mig_prod_scale,runbook,oncall_esc}}
§REL{[docker.md](docker.md);[kubernetes.md](kubernetes.md);[github-actions.md](github-actions.md);[observability.md](observability.md);[production-audit](../../web-quality-audit/references/production-audit.md);[canary-watch](../../web-quality-audit/references/canary-watch.md)}
