@REF:deployment
§R{
  base_img⇒`node:26-alpine`(Active_LTS)∨`node:24-alpine`(Maint_LTS);pin_tag(e.g.`node:26-alpine3.23`,¬`:latest`,¬`node:20`_EOL);
  Next16_docker⇒`output:'standalone'`+3-stage_build(`deps`→`builder`→`runner`)+non-root_`USER`(UID/GID_1001)+`HEALTHCHECK`+`.dockerignore`;
  compose⇒`compose.yaml`∧OMIT_obsolete_top-level_`version:`∧use_`healthcheck`+`depends_on.condition:service_healthy`;
  pg18+_vol⇒`pgdata:/var/lib/postgresql`(PG18/19_changed_`PGDATA`→`/var/lib/postgresql/<ver>/docker`;¬`/var/lib/postgresql/data`);
  k8s_harden⇒`runAsNonRoot:true`∧`allowPrivilegeEscalation:false`∧`readOnlyRootFilesystem:true`∧`capabilities.drop:[ALL]`∧`emptyDir`(`/tmp`,`.next/cache`)∧`requests/limits`∧probes;
  migrations⇒run_via_CI/pre-deploy_Job(`prisma migrate deploy`∨`drizzle-kit migrate`)BEFORE_app_rollout(¬inside_app_startup_race);
  secrets⇒secret_manager/K8s_Secret/Docker_secret(¬`ENV`/image_layers/git);build_secrets⇒`--mount=type=secret`;
  supply_chain⇒scan_built_images(`trivy image`∨`docker scout quickview`)+`audit`+immutable_digest/semver_tags;
}
§D{
  Next16_on_Cloudflare⇒`@opennextjs/cloudflare`+`wrangler.jsonc`(`nodejs_compat`)¬legacy_next-on-pages;
  Next16_managed_zero_ops⇒Vercel¬custom_K8s_for_small_team;
  API+DB_managed_PaaS⇒Railway⊕Render⊕Fly.io⊕CloudRun/ECS¬bare_VMs;
  small_self-hosted_Compose⇒Docker_Compose⊕Uncloud(`uc`)¬full_Kubernetes;
  single_VPS_non_container_Node⇒PM2(`ecosystem.config.cjs`,cluster/fork)¬bare_`npm start`;
  multi_svc_high_scale⇒Kubernetes(EKS/GKE/AKS)+GitOps(ArgoCD/Flux)+HPA+PDB¬manual_`kubectl apply`;
  monorepo_Docker⇒`turbo prune <app> --docker`in_prune_stage¬copy_entire_monorepo_context;
  cache_service⇒Valkey9(`valkey:9-alpine`,OSS)⊕Redis8(`redis:8-alpine`)¬unpinned_legacy_Redis;
}
§PAT{
  dockerfile_next16_standalone:```dockerfile
# syntax=docker/dockerfile:1
FROM node:26-alpine AS base
WORKDIR /app
ENV NEXT_TELEMETRY_DISABLED=1

FROM base AS deps
RUN apk add --no-cache libc6-compat && npm i -g pnpm@11
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

FROM base AS builder
RUN npm i -g pnpm@11
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# If Prisma 7: RUN pnpm exec prisma generate
RUN pnpm run build

FROM base AS runner
ENV NODE_ENV=production PORT=3000 HOSTNAME="0.0.0.0"
RUN addgroup --system --gid 1001 nodejs && adduser --system --uid 1001 nextjs
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
USER nextjs
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 CMD wget -qO- http://127.0.0.1:3000/api/health/live || exit 1
CMD ["node","server.js"]
```;
  monorepo_prune_stage:`FROM node:26-alpine AS pruner → RUN npm i -g turbo@^2 && turbo prune web --docker`→deps_copies_`/app/out/json/`+lockfile→builder_copies_`/app/out/full/`;
  compose_yaml(no_`version:`_key;PG18/19_volume+Valkey9+watch):```yaml
services:
  web:
    build: .
    ports: ["3000:3000"]
    env_file: .env
    depends_on:
      db: { condition: service_healthy }
      cache: { condition: service_healthy }
    develop:
      watch:
        - { action: sync, path: ./src, target: /app/src, ignore: [node_modules/] }
        - { action: rebuild, path: package.json }
  db:
    image: postgres:18-alpine
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-postgres}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?set POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB:-appdb}
    volumes: ["pgdata:/var/lib/postgresql"]
    healthcheck:
      test: ["CMD-SHELL","pg_isready -U ${POSTGRES_USER:-postgres} -d ${POSTGRES_DB:-appdb}"]
      interval: 5s
      timeout: 5s
      retries: 5
  cache:
    image: valkey/valkey:9-alpine
    healthcheck:
      test: ["CMD","valkey-cli","ping"]
      interval: 5s
      timeout: 3s
      retries: 5
volumes:
  pgdata:
```;
  k8s_deployment:{
    `apiVersion:apps/v1,kind:Deployment,spec.replicas:2,strategy.rollingUpdate:{maxUnavailable:0,maxSurge:1}`;
    `pod.spec.securityContext:{runAsNonRoot:true,runAsUser:1001,runAsGroup:1001,fsGroup:1001}`;
    `container:{image:registry/app:<git-sha>,ports:[{containerPort:3000}],envFrom:[{secretRef:{name:app-secrets}}]}`;
    `container.securityContext:{allowPrivilegeEscalation:false,readOnlyRootFilesystem:true,capabilities:{drop:[ALL]}}`;
    `resources:{requests:{cpu:100m,memory:256Mi},limits:{cpu:500m,memory:512Mi}}`;
    `probes:{startupProbe:/api/health/live,readinessProbe:/api/health/ready(period:10s),livenessProbe:/api/health/live(period:15s)}`;
    `volumes+mounts:[{name:tmp,emptyDir:{},mountPath:/tmp},{name:next-cache,emptyDir:{},mountPath:/app/.next/cache}]`;
    `PDB`:`minAvailable:1`∧`HPA`:CPU/mem_or_RPS_target;
  };
  k8s_migrate_job:`kind:Job(backoffLimit:1,activeDeadlineSeconds:300)→cmd:["npx","prisma","migrate","deploy"]∨["npx","drizzle-kit","migrate"]`run_before_rollout;
  opennext_cloudflare:{
    pkg:`@opennextjs/cloudflare`+`wrangler`;
    `wrangler.jsonc`:`{"main":".open-next/worker.js","name":"app","compatibility_date":"2026-01-01","compatibility_flags":["nodejs_compat"],"assets":{"directory":".open-next/assets","binding":"ASSETS"}}`;
  };
  dockerignore:`.git .gitignore node_modules .next .env .env.* coverage tests/ Dockerfile* compose*.yaml docker-compose*.yml *.log`;
}
§CMD{
  docker:`docker build -t app:$(git rev-parse --short HEAD) .` | `docker buildx build --platform linux/amd64,linux/arm64 -t reg/app:<tag> --push .`;
  scan:`trivy image --severity HIGH,CRITICAL --exit-code 1 app:<tag>` | `docker scout quickview app:<tag>`;
  compose:`docker compose up -d` | `docker compose watch` | `docker compose config`;
  k8s:`kubectl apply -f k8s/migrate-job.yaml && kubectl wait --for=condition=complete job/db-migrate --timeout=180s && kubectl apply -f k8s/deployment.yaml && kubectl rollout status deployment/fullstack-app` | rollback:`kubectl rollout undo deployment/fullstack-app`;
  cf_opennext:`npx opennextjs-cloudflare build && npx wrangler deploy`;
  pm2:`pm2 startOrReload ecosystem.config.cjs --env production && pm2 save`;
}
§ANTI{
  `node:20-alpine`⇒EOL_2026-04;use_`node:26-alpine`_or_`node:24-alpine`;
  `corepack enable`_on_Node25+⇒Corepack_unbundled;run_`npm i -g pnpm@11`_or_`npm i -g corepack`;
  PG18/19_mount_`/var/lib/postgresql/data`⇒startup_crash;mount_`/var/lib/postgresql`;
  Compose_`version:'3.8'`⇒obsolete_attr;omit_top-level_`version`;
  Next_full_`node_modules`+`npm start`_in_Docker⇒bloated_img;use_`output:'standalone'`+`node server.js`;
  container_as_`root`⇒security_risk;add_non-root_`USER`_1001;
  `:latest`_tag_in_K8s⇒non-reproducible_rollback;pin_immutable_SHA/semver;
  `readOnlyRootFilesystem:true`_wo_`/tmp`_mount⇒runtime_crash;mount_`emptyDir`;
  migrations_in_app_entrypoint⇒multi-replica_race;run_pre-deploy_Job;
  secrets_in_`ARG`/`ENV`/layers⇒leaked_in_`docker history`;use_runtime_secret_store_or_BuildKit_`--mount=type=secret`;
}
§CHK{secrets∈secret_store(¬git,¬layers);env_validated@boot;biome+tsc=0_err;unit+int+E2E+sec_header_tests_green;audit+Trivy/Scout=0_crit/high;non-root_standalone_img+HEALTHCHECK;PG18+_vol=/var/lib/postgresql;K8s_securityContext+probes+limits+PDB;expand-contract_migration_tested+rollback_plan;OTel_traces+Pino_JSON+alerts_live;docs:[OpenAPI/schema,arch,runbook]}
