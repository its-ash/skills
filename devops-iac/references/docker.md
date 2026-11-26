@REF:docker
§SCOPE{Dockerfile_opt,multistage,size,hardening,Compose,perf,debug(build|runtime|net)}
§FLOW{1:`docker --version && docker info|grep -E "Server Version|Storage Driver|Runtime"`;2:`find . -name "Dockerfile*" -type f; find . -name "*compose*.yml" -o -name "*compose*.yaml" -type f; ls -1 .dockerignore 2>/dev/null`;3:inspect(base,layers,stages,`.dockerignore`);4:apply(§PAT);5:`docker build --no-cache -t test-build . && docker run --rm -d --name tmp test-build && docker exec tmp ps aux|head -3 && docker stop tmp && docker-compose config`;6:`docker scout quickview test-build`}
§R{cache:COPY_deps→install→COPY_src;ms:build≠runtime,artifacts_only;base:Alpine|Distroless|scratch,pin(¬`:latest`);user:non_root(UID/GID+`USER`);secrets:¬`ENV`∧¬layers⇒Docker_secrets∨`--mount=type=secret`;clean:rm_tools+caches_same_RUN;health:`HEALTHCHECK`∀runtime;res:`deploy.resources`(CPU+mem);net:split(fe,be),¬def_bridge;arch:`docker buildx`}
§PAT{
  node_ms:```dockerfile
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build && npm prune --production
FROM node:18-alpine AS runtime
RUN addgroup -g 1001 -S appgroup && adduser -S appuser -u 1001 -G appgroup
WORKDIR /app
COPY --from=deps --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=build --chown=appuser:appgroup /app/dist ./dist
COPY --from=build --chown=appuser:appgroup /app/package*.json ./
USER appuser
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD curl -f http://localhost:3000/health || exit 1
CMD ["node","dist/index.js"]
```;
  harden:non_root(1001)+`--chown`+docker_run(drop_all_caps,read_only_root_fs);
  distroless:`FROM gcr.io/distroless/nodejs18-debian11`→COPY `dist`,`node_modules`→`WORKDIR /app`→`EXPOSE 3000`→`CMD ["index.js"]`;
  bk_cache:`RUN --mount=type=cache,target=/root/.npm npm ci --only=production`;
  bk_secret:`RUN --mount=type=secret,id=api_key API_KEY=$(cat /run/secrets/api_key) && ...`;
  compose_prod(v"3.8"):{app:{build:{context:.,target:runtime},depends_on:{db:{condition:service_healthy}},networks:[frontend,backend],healthcheck:{test:["CMD","curl","-f","http://localhost:3000/health"],interval:30s,timeout:10s,retries:3},deploy.resources:{limits:{cpus:"0.5",memory:512M},reservations:{cpus:"0.25",memory:256M}}};db:{image:`postgres:15-alpine`,env:{POSTGRES_DB_FILE:`/run/secrets/db_name`,POSTGRES_USER_FILE:`/run/secrets/db_user`,POSTGRES_PASSWORD_FILE:`/run/secrets/db_password`},secrets:[db_name,db_user,db_password],volumes:[`postgres_data:/var/lib/postgresql/data`],networks:[backend],healthcheck:{test:["CMD-SHELL","pg_isready -U ${POSTGRES_USER}"],interval:10s,timeout:5s,retries:5}};nets:{frontend:bridge,backend:{bridge,internal:true}};vols:[postgres_data];secrets:{db_name,db_user,db_password:{external:true}}};
  compose_dev:{app:{build:{context:.,target:development},volumes:[".:/app","/app/node_modules"],env:[NODE_ENV=development,"DEBUG=app:*"],ports:["9229:9229"],command:"npm run dev"}};
  buildx:`docker buildx create --name multiarch --use && docker buildx build --platform linux/amd64,linux/arm64 -t myorg/app:latest --push .`;
  net_dns:svc_name(`postgres://db:5432/app`,`redis://redis:6379/0`)|frontend∈`[frontend-net]`,api∈`[frontend-net,backend-net]`,db∈`[backend-net]`(dev_only:`127.0.0.1:5432:5432`,omit_prod);
  vols:{named:`pgdata:/var/lib/postgresql/data`;bind:`.:/app`(hot_reload);anon:`/app/node_modules`,`/app/.next`(preserve_under_bind);init:`./scripts/init.sql:/docker-entrypoint-initdb.d/init.sql`(1st_start)};
  dockerignore:`node_modules .git .env .env.* dist coverage *.log .next .cache docker-compose*.yml Dockerfile* tests/`
}
§DBG{`docker compose logs -f app`;`logs --tail=50 db`;`exec app sh`;`exec db psql -U postgres`;`ps && docker compose top`;`docker stats`;`build --no-cache app`;`down -v`(DESTRUCTIVE);net:`exec app nslookup db`;`exec app wget -qO- http://api:3000/health`;`docker network inspect <project>_default`}
§ANTI{src_before_deps;no_dockerignore;root;secrets_in_ENV|Dockerfile;leftover_caches;oversized_base;no_HEALTHCHECK;extra_ports|def_bridge_prod;no_res_limits;ignore_ARM;`:latest`;multi_proc_container(1/container);stateful_no_vol;plain_compose_prod_multicontainer(K8s|ECS|Swarm)}
§CHK{§R;compose:{depends_on_healthy,split_nets,isolated_env_overrides,named|bind_vols,res_limits+restart,secrets_ref};run:{no_cache_ok,<200MB_Node,healthy,0_vuln_warns,multiarch_if_req}}
§REL{[devops-iac](../SKILL.md);[backend-development](../../backend-development/SKILL.md);[observability](observability.md);[golang](../../golang/SKILL.md)}
