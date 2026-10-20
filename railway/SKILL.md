---
name: railway
description: "Deploy applications and manage infrastructure on Railway using the CLI and GraphQL API. Use when the user says deploy, push, or ship code with `railway up`, `railway link`, `railway service`, or `railway template add`; needs to check deployment logs, list recent builds, rename or re-icon a service, link an existing project, provision Postgres, Redis, Ghost, or other marketplace add-ons, configure environment variables, or troubleshoot failed builds and service health."
---

# Railway
Deploy code, manage services, and add templates on Railway. The skill works with the Railway CLI (`railway …`) and the Railway GraphQL API.

## When to Use
- User says *deploy*, *ship*, *push*, or runs `railway up`.
- User wants to watch build logs or debug a deployment.
- User asks about service health, status, name, or icon.
- User needs to link a different service or create a new one.
- User wants to add a pre‑configured service from the Railway template marketplace (e.g., Postgres, Ghost, n8n).

---

## Deploy Code
### Modes
- **Detach (default)** – Starts the deployment and returns immediately.
  ```bash
  railway up --detach
  ```
- **CI** – Streams build logs until the deployment finishes. Use for debugging.
  ```bash
  railway up --ci
  ```

### Target a Specific Service
```bash
railway up --service <service-name> --detach
```

### Deploy to an Unlinked Project
```bash
railway up --project <project-id> --environment production --detach
```
Both `--project` and `--environment` are required.

### Common Flags
| Flag | Meaning |
|------|---------|
| `-d, --detach` | Do not attach to logs (default). |
| `-c, --ci` | Stream logs and exit when finished. |
| `-s, --service <NAME>` | Deploy to a named service (defaults to linked). |
| `-e, --environment <NAME>` | Deploy to a named environment (defaults to linked). |
| `-p, --project <ID>` | Deploy to a project without linking first. |
| `[PATH]` | Path to the code to deploy (default: current directory). |

### After Deploy
- **Detach mode** – Use `railway-deployment` skill (or `railway logs --build --lines <n>`) to view recent build output.
- **CI mode** – Logs are already streamed. Do not run `railway logs` again; use `--lines` if more context is needed.

---

## Service Management
### Check Service Status
```bash
railway service status --json
```
The JSON contains `status` (SUCCESS, FAILED, DEPLOYING, etc.), `deployedAt`, and recent deployments.

### List Recent Deployments
```bash
railway deployment list --json --limit 5
```

### Rename a Service
```bash
curl -X POST https://backboard.railway.app/graphql/v2 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $RAILWAY_TOKEN" \
  -d '{"query":"mutation($id:String!,$name:String!){serviceUpdate(id:$id,input:{name:$name}){id name}}","variables":{"id":"SERVICE_ID","name":"new-name"}}'
```

### Change Service Icon
Use an image URL, animated GIF, or a Railway Devicon.
```bash
curl -X POST https://backboard.railway.app/graphql/v2 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $RAILWAY_TOKEN" \
  -d '{"query":"mutation($id:String!,$icon:String!){serviceUpdate(id:$id,input:{icon:$icon}){id icon}}","variables":{"id":"SERVICE_ID","icon":"https://devicons.railway.app/postgres"}}'
```
Available Devicons: `github`, `postgres`, `redis`, `nodejs`, etc. Browse at https://devicons.railway.app.

### Link a Different Service
```bash
railway service link            # interactive selection
railway service link <name>    # link by name
```

### Create a Service (Advanced)
> Use the `railway-new` skill for typical local‑code projects. The steps below are for GraphQL‑only creation (e.g., Docker image services).
1. **Create Service**
   ```bash
   curl -X POST https://backboard.railway.app/graphql/v2 \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $RAILWAY_TOKEN" \
     -d '{"query":"mutation($input:ServiceCreateInput!){serviceCreate(input:$input){id name}}","variables":{"input":{"projectId":"PROJECT_ID","name":"my-service","source":{"image":"nginx:latest"}}}}'
   ```
2. **Configure Instance** – add variables, ports, etc., with the `railway-environment` skill.

### Error Handling
- **No project linked** – `railway link` first.
- **No service linked** – `railway service link`.
- **Service not found** – run `railway status` to list available services.
- **Permission denied** – user must have at least *DEVELOPER* role.
- **Invalid Docker image** – ensure the image is public or credentials are set.

---

## Template Marketplace
### Common Template Codes
| Category | Template | Code |
|----------|----------|------|
| Databases | PostgreSQL | `postgres` |
|          | Redis | `redis` |
|          | MySQL | `mysql` |
|          | MongoDB | `mongodb` |
| CMS | Ghost | `ghost` |
|     | Strapi | `strapi` |
| Storage | Minio | `minio` |
| Automation | n8n | `n8n` |
| Monitoring | Uptime Kuma | `uptime-kuma` |

### Search Templates
```bash
curl -X POST https://backboard.railway.app/graphql/v2 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $RAILWAY_TOKEN" \
  -d '{"query":"query($first:Int,$verified:Boolean){templates(first:$first,verified:$verified){edges{node{name code description category}}}}","variables":{"first":20,"verified":true}}'
```
- `first` – number of results (max ~100).
- `verified` – true to return only verified templates.
- Rate limit: 10 requests per minute.

### Get Template Details
```bash
curl -X POST https://backboard.railway.app/graphql/v2 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $RAILWAY_TOKEN" \
  -d '{"query":"query($code:String!){template(code:$code){id name description serializedConfig}}","variables":{"code":"postgres"}}'
```
The response includes `id` and `serializedConfig` (exact JSON needed for deployment).

### Deploy a Template
1. **Fetch template** (as above) to obtain `templateId` and `serializedConfig`.
2. **Deploy**
   ```bash
   curl -X POST https://backboard.railway.app/graphql/v2 \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $RAILWAY_TOKEN" \
     -d '{"query":"mutation($input:TemplateDeployV2Input!){templateDeployV2(input:$input){projectId workflowId}}","variables":{"input":{"templateId":"TEMPLATE_ID","serializedConfig":SERIALIZED_CONFIG,"projectId":"PROJECT_ID","environmentId":"ENV_ID","workspaceId":"WORKSPACE_ID"}}}'
   ```
**Important:** `serializedConfig` must be the raw JSON object, not a quoted string.

### After Deployment
- Use `railway-service` skill to view the new service.
- Add environment variables or connect other services with `railway-environment`.

---

## Checklist
- [ ] Identify the user intent (deploy, service status, rename, template add).
- [ ] Choose mode: `--detach` for fire‑and‑forget, `--ci` for log streaming.
- [ ] If deploying a specific service, add `--service <name>`.
- [ ] For unlinked projects, provide both `--project` and `--environment`.
- [ ] After a CI deployment, read the streamed logs; do not run `railway logs` again.
- [ ] When creating or updating a service via API, include the `Authorization: Bearer $RAILWAY_TOKEN` header.
- [ ] Verify template `code` exists before deploying; fetch its `serializedConfig` first.
- [ ] After any change, run `railway up` or apply the environment to trigger a new deployment.
- [ ] Handle common errors: no linked project/service, permission issues, invalid Docker image.

## Related skills

Load these when the task spans more than this skill.

- [`docker`](../docker/SKILL.md) — Provides expert guidance for Dockerfile optimization, multi‑stage builds, image size reduction, container secu…
- [`deployment-procedures`](../deployment-procedures/SKILL.md) — Provides a concise, platform‑agnostic procedure for safely deploying production services, covering pre‑checks,…
- [`devops-iac`](../devops-iac/SKILL.md) — DevOps IaC skill provides a step-by-step workflow for designing, implementing, and operating cloud infrastruct…
- [`secrets-management`](../secrets-management/SKILL.md) — Manage secrets for CI/CD and runtime systems with Vault, AWS Secrets Manager, GitHub/GitLab variables, Kuberne…
- [`observability`](../observability/SKILL.md) — Observability skill provides practical guidance for building, querying, and visualizing production‑grade monit…
