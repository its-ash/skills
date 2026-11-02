# Deployment

## Dockerfile (Next.js, multi-stage)
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json .
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/public ./public
EXPOSE 3000
CMD ["npm", "start"]
```

## Docker Compose (app + Postgres)
```yaml
services:
  web:
    build: .
    ports: ["3000:3000"]
    env_file: .env
    depends_on: [db]
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: appdb
    volumes: [pgdata:/var/lib/postgresql/data]
volumes:
  pgdata:
```

## Kubernetes Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata: { name: fullstack-app }
spec:
  replicas: 2
  selector: { matchLabels: { app: fullstack } }
  template:
    metadata: { labels: { app: fullstack } }
    spec:
      containers:
        - name: web
          image: myregistry/fullstack-app:<tag>
          ports: [{ containerPort: 3000 }]
          envFrom: [{ secretRef: { name: app-secrets } }]
```
`kubectl apply -f k8s/` then `kubectl rollout status deployment/fullstack-app`.

## Release checklist
- [ ] Env vars set; secrets in a secret store, not in git.
- [ ] Lint and type-check pass with zero errors.
- [ ] Unit, integration, and e2e coverage ≥ 80%.
- [ ] Performance meets target SLAs.
- [ ] `npm audit` and OWASP ZAP show no critical findings.
- [ ] Docker image built and scanned.
- [ ] CI runs lint, test, and image build.
- [ ] Compose/Helm manifests in version control.
- [ ] Docs include API spec, architecture diagram, runbook.
