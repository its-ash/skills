# GitHub Actions Workflow Builder

Generate production‑ready `.github/workflows/*.yml` files. The skill analyses the repository, asks minimal clarifications, and outputs a complete workflow with best‑practice settings.

## When to use
- Set up CI pipelines (test, lint, type‑check) for any language.
- Add automated deployments to cloud providers, Docker registries, or static hosts.
- Create release or publish workflows (npm, PyPI, Docker, GitHub Release).
- Define scheduled jobs (cron, maintenance, security scans).
- Automate PR reviews, issue triage, or other GitHub automation.
- Need caching, matrix testing, or concurrency controls.

---

## 1. Workflow Creation Process
### 1.1 Analyze the project
| Indicator | Detected language / framework |
|---|---|
| `package.json` | Node.js (React, Next.js, Vue, Angular, Svelte, etc.) |
| `requirements.txt`, `pyproject.toml`, `setup.py` | Python |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pom.xml`, `build.gradle` | Java / Kotlin |
| `Gemfile` | Ruby |
| `composer.json` | PHP |
| `pubspec.yaml` | Dart / Flutter |
| `Package.swift` | Swift |
| `*.csproj`, `*.sln` | .NET |
| `.github/workflows/` | Existing workflows – avoid name conflicts |
| `Dockerfile` | Container build available |
| `docker-compose.yml` | Multi‑service setup |
| `vercel.json`, `netlify.toml` | Deployment target |
| `terraform/`, `pulumi/` | IaC |
| `.eslintrc*`, `eslint.config.*` | ESLint |
| `prettier*` | Prettier |
| `jest.config*`, `vitest.config*`, `pytest.ini` | Test framework |
| `.env.example` | Environment variables needed |
| `Makefile` | Custom build commands |

### 1.2 Clarify if needed
Ask ONE focused question when the request is ambiguous, e.g.:
- "Should the CI run only tests, or also lint and type‑check?"
- "Where should the deployment go (AWS, GCP, Docker Hub, Vercel, etc.)?"
- "Run tests on PR only or also on push to main?"
If the intent is clear, skip this step.

### 1.3 Generate the workflow file
**File naming** – kebab‑case, descriptive:
- `ci.yml` – basic CI
- `deploy.yml` or `deploy‑<target>.yml` – deployment
- `release.yml` – publishing
- `scheduled‑<task>.yml` – cron jobs

**Base YAML template**
```yaml
name: <Human readable name>

on:
  push:
    branches: [main]
    paths-ignore: ['**.md', 'docs/**']
  pull_request:
    branches: [main]
  # add schedule or workflow_dispatch as needed

permissions:
  contents: read
  # add other minimal permissions here

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  <job-id>:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v4
      # add setup, cache, test, build, deploy steps
```
Use the sections below to fill in specific steps.

---

## 2. Core Patterns by Use Case
### 2.1 CI (test + lint)
- **Triggers**: `push` to main and `pull_request`.
- **Jobs**: `lint`, `test` (run in parallel when possible).
- **Key features**: dependency caching, matrix testing for multiple runtimes.

### 2.2 Deployment
- **Trigger**: `push` to main (or tag).
- **Jobs**: `test → build → deploy` (use `needs` to enforce order).
- **Key features**: environment protection, secrets for credentials, status checks.

### 2.3 Release / Publish
- **Trigger**: tag matching `v*` or `workflow_dispatch`.
- **Jobs**: `test → build → publish → create‑release`.
- **Key features**: changelog generation, artifact upload, npm/PyPI/Docker publishing.

### 2.4 Scheduled Tasks
- **Trigger**: `schedule` with cron expression.
- **Job**: single job performing the task.
- **Key features**: also expose `workflow_dispatch` for manual runs, failure notifications.

### 2.5 Security Scanning
- **Triggers**: `pull_request` + weekly `schedule`.
- **Jobs**: dependency audit, SAST, secret scanning.
- **Key features**: upload SARIF to GitHub Security tab, fail on critical findings.

### 2.6 Docker Build & Push
- **Trigger**: `push` to main and tags.
- **Jobs**: `docker build → docker push`.
- **Key features**: multi‑platform builds, layer caching, consistent tagging.

---

## 3. Essential Actions (pin to major version)
### 3.1 Setup actions
| Action | Purpose |
|---|---|
| `actions/checkout@v4` | Clone repository |
| `actions/setup-node@v4` | Node.js + cache |
| `actions/setup-python@v5` | Python + cache |
| `actions/setup-go@v5` | Go |
| `actions/setup-java@v4` | Java/Kotlin |
| `dtolnay/rust-toolchain@stable` | Rust toolchain |
| `ruby/setup-ruby@v1` | Ruby + bundler cache |
| `actions/setup-dotnet@v4` | .NET SDK |

### 3.2 Build & Deploy actions
| Action | Purpose |
|---|---|
| `docker/build-push-action@v6` | Multi‑platform Docker builds |
| `docker/login-action@v3` | Docker registry authentication |
| `aws-actions/configure-aws-credentials@v4` | AWS auth |
| `google-github-actions/auth@v2` | GCP auth |
| `azure/login@v2` | Azure auth |
| `cloudflare/wrangler-action@v3` | Cloudflare Workers |
| `amondnet/vercel-action@v25` | Vercel deployment |

### 3.3 Quality & Security actions
| Action | Purpose |
|---|---|
| `github/codeql-action/analyze@v3` | CodeQL SAST |
| `aquasecurity/trivy-action@master` | Container vulnerability scan |
| `codecov/codecov-action@v4` | Coverage upload |
| `actions/dependency-review-action@v4` | Dependency audit on PRs |

### 3.4 Utility actions
| Action | Purpose |
|---|---|
| `actions/cache@v4` | Generic caching |
| `actions/upload-artifact@v4` | Store build artifacts |
| `actions/download-artifact@v4` | Retrieve artifacts |
| `softprops/action-gh-release@v2` | Create GitHub Release |
| `slackapi/slack-github-action@v2` | Slack notifications |
| `peter-evans/create-pull-request@v7` | Automated PR creation |

---

## 4. Security Best Practices
- Declare the minimal `permissions` needed at workflow or job level.
- Pin actions to a major version (`@v4`, `@v5`).
- Never `echo` secrets; avoid `${{ secrets.X }}` in command strings.
- Use GitHub Environments for production deployments and enable protection rules.
- Validate all `workflow_dispatch` inputs.
- Prevent script injection: pass event data via environment variables, not directly in `run:`.
- Prefer the default `${{ secrets.GITHUB_TOKEN }}` over personal access tokens.
- Use `concurrency` to avoid duplicate runs on the same PR or branch.

**Example of safe variable handling**
```yaml
- run: echo "$ISSUE_TITLE"
  env:
    ISSUE_TITLE: ${{ github.event.issue.title }}
```
---

## 5. Caching Strategies
### Node.js
```yaml
- uses: actions/setup-node@v4
  with:
    node-version: 20
    cache: npm   # or yarn / pnpm
```
### Python
```yaml
- uses: actions/setup-python@v5
  with:
    python-version: '3.12'
    cache: pip   # or poetry / pipenv
```
### Go
```yaml
- uses: actions/setup-go@v5
  with:
    go-version: '1.22'
    cache: true
```
### Rust
```yaml
- uses: actions/cache@v4
  with:
    path: |
      ~/.cargo/bin/
      ~/.cargo/registry/**
      target/
    key: ${{ runner.os }}-cargo-${{ hashFiles('**/Cargo.lock') }}
```
### Docker
```yaml
- uses: docker/build-push-action@v6
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max
```
---

## 6. Matrix Testing Patterns
### Multiple Node.js versions
```yaml
strategy:
  matrix:
    node-version: [18, 20, 22]
  fail-fast: false
```
### Multiple operating systems
```yaml
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest, windows-latest]
runs-on: ${{ matrix.os }}
```
### Complex matrix with exclusions
```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest]
    node-version: [18, 20]
    exclude:
      - os: windows-latest
        node-version: 18
```
---

## 7. Cron Syntax Quick Reference
| Schedule | Cron |
|---|---|
| Every hour | `0 * * * *` |
| Daily at midnight UTC | `0 0 * * *` |
| Weekdays at 09:00 UTC | `0 9 * * 1-5` |
| Weekly on Sunday | `0 0 * * 0` |
| First day of each month | `0 0 1 * *` |
---

## 8. Checklist for a New Workflow
- [ ] Choose a clear, kebab‑case file name.
- [ ] Set specific `on:` triggers (push, pull_request, schedule, workflow_dispatch).
- [ ] Declare minimal `permissions`.
- [ ] Add `concurrency` block.
- [ ] Use `actions/checkout@v4` as first step.
- [ ] Add appropriate setup action for the language.
- [ ] Enable caching for dependencies.
- [ ] Define jobs (lint, test, build, deploy) with `needs` to enforce order.
- [ ] Pin all third‑party actions to a major version.
- [ ] Include timeout (`timeout-minutes`).
- [ ] Add secret handling (never echo secrets).
- [ ] Provide a short summary of what the workflow does, required secrets, and how to trigger it.
- [ ] Test the workflow with a manual `workflow_dispatch` run before relying on automation.
