---
name: fullstack-development
description: "Fullstack Development skill guides planning, scaffolding, coding, testing, and deploying modern web applications with React, Next.js, Node.js, GraphQL, REST, and PostgreSQL. Use when creating a new project, selecting a tech stack, setting up architecture, enforcing code quality, or automating deployment with npm, pnpm, yarn, Docker, CI/CD, monorepo, API routes, Prisma, Drizzle, Jest, Vitest, Playwright, Vercel, Railway, environment variables, auth, and migrations."
---

# Fullstack Development

Create, analyze, and ship complete web applications with a modern stack (React, Next.js, Node.js, GraphQL/REST, PostgreSQL). The skill covers project type detection, tech‑stack selection, directory scaffolding, architecture patterns, development workflow, quality checks, and deployment.

---

## When to Use
- Starting a new full‑stack web app (e.g., SaaS, social media, e‑commerce).
- Adding major features to an existing project.
- Auditing code quality, performance, or security.
- Setting up CI/CD pipelines for Docker/Kubernetes.
- Coordinating multiple specialist agents (frontend, backend, database, DevOps).

---

## 1. Project Type Detection
Identify the project category from the user request. Use the following keyword matrix (excerpt):
| Category | Keywords |
|----------|----------|
| **Social Media** | "feed", "post", "like", "follow", "profile" |
| **SaaS** | "subscription", "billing", "stripe", "dashboard" |
| **Landing Page** | "static", "marketing", "hero", "cta" |
| **API Service** | "REST", "GraphQL", "endpoint", "microservice" |
| **Mobile App** | "react‑native", "expo", "flutter", "android", "ios" |

Select the first matching category. If none match, default to **Full‑Stack Web App**.

---

## 2. Tech‑Stack Selection
The default 2025 stack for a full‑stack web app is:
- **Frontend**: React + Next.js (TypeScript)
- **Backend**: Node.js + Express (or GraphQL Apollo Server)
- **Database**: PostgreSQL accessed via Prisma ORM
- **Auth**: Clerk or Auth0
- **File Storage**: Cloudinary or Supabase Storage
- **Hosting**: Vercel (frontend) + Railway / Render (backend) or Docker/K8s for self‑hosted.

**Alternatives** (choose based on project type):
- **SaaS** – add Stripe for payments.
- **Mobile** – replace Next.js with React‑Native or Flutter.
- **Static Site** – use Next.js static export or Nuxt 3.
- **API‑only** – use FastAPI (Python) or Express API template.

---

## 3. Scaffolding Templates
Pick a template that matches the detected type and chosen stack. Only read the matching template.
| Template | Stack | Use When |
|----------|-------|----------|
| `nextjs-fullstack` | Next.js + Prisma + PostgreSQL | General full‑stack web app |
| `nextjs-saas` | Next.js + Prisma + Stripe | SaaS product |
| `nextjs-static` | Next.js (static) | Landing page |
| `nuxt-app` | Nuxt 3 + Pinia + PostgreSQL | Vue full‑stack |
| `express-api` | Express + JWT + PostgreSQL | REST API |
| `python-fastapi` | FastAPI + PostgreSQL | Python API |
| `react-native-app` | Expo + Zustand | Mobile app |
| `flutter-app` | Flutter + Riverpod | Cross‑platform mobile |
| `electron-desktop` | Electron + React | Desktop app |
| `cli-tool` | Node.js + Commander | CLI utility |
| `monorepo-turborepo` | Turborepo + pnpm | Multi‑package repo |

### Scaffolding Steps (manual)
1. **Create directory**
   ```bash
   mkdir my-project && cd my-project
   ```
2. **Initialize Git**
   ```bash
   git init
   ```
3. **Copy template files** – copy the selected template folder into the project root.
4. **Install dependencies**
   ```bash
   npm install   # or pnpm install / yarn install
   ```
5. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with DB URL, API keys, etc.
   ```
6. **Run database migrations** (Prisma example)
   ```bash
   npx prisma migrate dev --name init
   ```

---

## 4. Architecture Patterns
### 4.1 Folder Layout (Next.js example)
```
src/
  pages/          # Route files (API routes under pages/api)
  components/     # Reusable UI components
  lib/            # Helpers, API clients, auth utilities
  styles/         # CSS/SCSS modules or Tailwind config
  prisma/         # Prisma schema and migrations
public/           # Static assets
tests/            # Jest / React Testing Library tests
```
### 4.2 Data Flow
1. **Client** → fetches via **React Query** or **Apollo Client**.
2. **API Layer** (Next.js API routes or Express) validates, authorizes, and calls **service layer**.
3. **Service Layer** contains business logic, uses **Prisma** to query PostgreSQL.
4. **Response** returns JSON; errors are standardized.
### 4.3 Error Handling
- Throw `HttpError` with status code and message.
- Central middleware catches errors and formats `{ error: message, code }`.
- Log errors with `winston` (backend) and `console.error` (frontend).
### 4.4 Security
- Validate all inputs with **zod** (TS) or **Joi** (Node).
- Use parameterized queries (Prisma does this automatically).
- Store secrets in `.env` and never commit.
- Enable CSRF protection for form posts.

---

## 5. Development Workflow
### 5.1 Setup
```bash
# Install Node dependencies
npm install
# Install Python deps if needed
pip install -r requirements.txt   # optional
# Install Prisma client
npx prisma generate
```
### 5.2 Run Locally
```bash
# Frontend + API (Next.js)
npm run dev
# Backend only (Express)
npm run dev:server
```
### 5.3 Testing
```bash
# Unit & integration tests
npm run test
# Lint & type check
npm run lint
npm run type-check
```
### 5.4 Code Quality Analyzer (manual steps)
1. Run **ESLint** with the recommended config.
2. Run **Prettier** to format code.
3. Execute **SonarQube** or **codecov** for coverage metrics.
4. Review the generated report and fix high‑severity issues.

---

## 6. Performance Guidelines
- Measure before optimizing (use **Web Vitals**, **pg_stat_statements**).
- Cache read‑heavy queries with **Redis** or **Edge caching**.
- Enable **Incremental Static Regeneration** for pages that can be pre‑rendered.
- Lazy‑load heavy components with `React.lazy` and `Suspense`.
- Keep API response payloads small; use pagination.

---

## 7. Security Checklist
- [ ] Validate all request bodies with a schema library.
- [ ] Use HTTPS everywhere (local dev with `mkcert`).
- [ ] Store passwords with **bcrypt** (or use third‑party auth).
- [ ] Apply rate limiting (`express-rate-limit`).
- [ ] Set `Content‑Security‑Policy` headers.
- [ ] Keep dependencies up‑to‑date (`npm audit fix`).

---

## 8. Maintainability Practices
- Write **type‑safe** code (TypeScript for JS, Pydantic for Python).
- Keep functions < 30 lines; extract reusable logic.
- Document public APIs with **OpenAPI** (Swagger) or **GraphQL schema comments**.
- Use **conventional commits** and generate a changelog.
- Version database schema with Prisma migrations.

---

## 9. Deployment
### 9.1 Dockerfile (Node/Next.js)
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
### 9.2 Docker Compose (app + db)
```yaml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "3000:3000"
    env_file: .env
    depends_on:
      - db
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: appdb
    volumes:
      - pgdata:/var/lib/postgresql/data
volumes:
  pgdata:
```
### 9.3 Kubernetes (quick snippet)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fullstack-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: fullstack
  template:
    metadata:
      labels:
        app: fullstack
    spec:
      containers:
        - name: web
          image: myregistry/fullstack-app:latest
          ports:
            - containerPort: 3000
          envFrom:
            - secretRef:
                name: app-secrets
```
Deploy with `kubectl apply -f deployment.yaml`.

---

## 10. Common Commands Cheat Sheet
```bash
# Install / update dependencies
npm install            # Node
pnpm install           # pnpm
pip install -r requirements.txt   # Python

# Database
npx prisma migrate dev --name <migration>
npx prisma studio    # UI for DB inspection

# Development
npm run dev          # Next.js dev server
npm run build        # Production build
npm run start        # Run built app
npm run test         # Jest / RTL tests
npm run lint         # ESLint
npm run type-check   # tsc --noEmit

# Docker
docker build -t fullstack-app .
docker compose up -d

# Kubernetes
kubectl apply -f k8s/
kubectl rollout status deployment/fullstack-app

# Code quality (manual)
npx eslint . --fix
npx prettier --write .
npm audit fix --force
```

---

## 11. Checklist Before Release
- [ ] Project type and tech stack documented.
- [ ] Directory structure follows the recommended layout.
- [ ] All environment variables set and secrets stored securely.
- [ ] Linting and type‑checking pass with zero errors.
- [ ] Unit, integration, and end‑to‑end tests have ≥80% coverage.
- [ ] Performance benchmarks meet target SLAs.
- [ ] Security audit (`npm audit`, OWASP ZAP) shows no critical findings.
- [ ] Docker image built and scanned for vulnerabilities.
- [ ] CI pipeline runs `npm run lint`, `npm test`, and builds Docker image.
- [ ] Deployment manifests (Docker Compose or Helm) are version‑controlled.
- [ ] Documentation includes API spec, architecture diagram, and runbook.

---

## 12. Agent Coordination (Optional)
If you have specialist agents, follow this order:
1. **project‑planner** – creates task list and dependency graph.
2. **frontend‑specialist** – builds UI components and pages.
3. **backend‑specialist** – implements API routes and business logic.
4. **database‑architect** – designs schema, writes migrations.
5. **devops‑engineer** – writes Dockerfiles, CI/CD pipelines, and deployment manifests.
Each agent receives the scoped files from the previous step to avoid overlap.

---

*End of Fullstack Development skill.*

## Related skills

Load these when the task spans more than this skill.

- [`frontend-development`](../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`backend-development`](../backend-development/SKILL.md) — Guidance for designing, building, and operating scalable backend services and APIs. Covers REST GraphQL gRPC A…
- [`nextjs`](../frontend-development/references/nextjs.md) — Guidelines for building Next.js 14+ applications with the App Router. Includes component type decisions, data…
- [`node`](../node/SKILL.md) — Node.js project conventions and setup rules. Load when creating, configuring, or working on any Node.js projec…
- [`database-design`](../database-design/SKILL.md) — Expert database architect for data layer design, technology selection, and schema modeling. Use for selecting…
- [`typescript`](../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
