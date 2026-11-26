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
FROM golang:1.22-alpine AS b
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /server ./cmd/server
FROM alpine:3.19
RUN apk --no-cache add ca-certificates && adduser -D -u 1001 appuser
USER appuser
COPY --from=b /server /server
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:8080/health || exit 1
CMD ["/server"]
```;
  py:```dockerfile
FROM python:3.12-slim AS b
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir uv && uv pip install --system --no-cache -r requirements.txt
FROM python:3.12-slim
WORKDIR /app
RUN useradd -r -u 1001 appuser
USER appuser
COPY --from=b /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=b /usr/local/bin /usr/local/bin
COPY . .
ENV PYTHONUNBUFFERED=1
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health/')" || exit 1
CMD ["gunicorn","config.wsgi:application","--bind","0.0.0.0:8000","--workers","4"]
```;
  R:{pin(`node:22-alpine`),ms,non_root,deps_before_src,`.dockerignore`(`node_modules,.git,tests`),HEALTHCHECK,res_limits(compose|k8s)};
  ANTI:{root,`:latest`,single_COPY_repo,dev_deps_prod,secrets_in_img}
}
§CICD{
  ref:[github-actions.md](github-actions.md);
  flow:{PR:lint→typecheck→unit→int→preview;main:lint→typecheck→unit→int→build_img→staging→smoke→prod};
  gha(on:push|PR@[main],ubuntu-latest):{
    test:[`actions/checkout@v4`,`actions/setup-node@v4`(node:22,cache:npm),`npm ci`,`npm run lint`,`npm run typecheck`,`npm test -- --coverage`,`actions/upload-artifact@v4`(if:always(),coverage→`coverage/`)];
    build(needs:test,if:main):[`actions/checkout@v4`,`docker/setup-buildx-action@v3`,`docker/login-action@v3`(ghcr.io,`${{github.actor}}`,`${{secrets.GITHUB_TOKEN}}`),`docker/build-push-action@v5`(push:true,tags:`ghcr.io/${{github.repository}}:${{github.sha}}`,cache-from:type=gha,cache-to:`type=gha,mode=max`)];
    deploy(needs:build,if:main,env:production):`railway up`|`vercel --prod`|`kubectl set image deployment/app app=ghcr.io/${{github.repository}}:${{github.sha}}`
  }
}
§HLTH{`/health`:200 `{status:"ok"}`;`/health/detailed`:check(db:`SELECT 1`→`{status:"ok",latency_ms}`|`{status:"error",message}`,redis,externalApi)→all_ok?200("ok"):503("degraded")+`{timestamp,version:APP_VERSION||"unknown",uptime,checks}`;k8s:startup+liveness(`/health`)+readiness(`/ready`→deps)⇒[kubernetes.md](kubernetes.md#probes--liveness-readiness-startup)}
§ENV{12f:{DATABASE_URL,REDIS_URL,API_KEY(secrets_mgr),LOG_LEVEL=info,PORT=3000,NODE_ENV=production|staging|development,APP_ENV=production};zod(startup):`z.object({NODE_ENV:z.enum(["development","staging","production"]),PORT:z.coerce.number().default(3000),DATABASE_URL:z.string().url(),REDIS_URL:z.string().url(),JWT_SECRET:z.string().min(32),LOG_LEVEL:z.enum(["debug","info","warn","error"]).default("info")}).parse(process.env)`}
§RBK{cmd:{k8s:`kubectl rollout undo deployment/app`;vercel:`vercel rollback`;railway:`railway up --commit <prev-sha>`;prisma:`npx prisma migrate resolve --rolled-back <migration-name>`};chk:{prev_img_tagged,backward_compat_migs(¬destructive),feature_flags,err_alerts,staging_tested}}
§CHK_PROD{app:{tests(unit,int,E2E),¬secrets,edge_errs,JSON_logs(¬PII),health};infra:{pinned_docker,env_doc+val,cpu_mem_limits,hpa(min/max),tls_all};mon:{metrics(rate,lat,err),err_alerts,log_agg,uptime_health};sec:{cve_scan,cors_allowlist,rate_limit_pub,authn_authz,hdrs(CSP,HSTS,X-Frame-Options)};ops:{rbk_tested,mig_prod_scale,runbook,oncall_esc}}
§REL{[docker.md](docker.md);[kubernetes.md](kubernetes.md);[github-actions.md](github-actions.md);[observability.md](observability.md);[production-audit](../../web-quality-audit/references/production-audit.md);[canary-watch](../../web-quality-audit/references/canary-watch.md)}
