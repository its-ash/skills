---
name: dependency-updates
description: "Automates dependency detection, safe updating, and security auditing for Node.js npm yarn pnpm, Python pip poetry, Go modules, Rust cargo, Java Maven Gradle, .NET NuGet; auto-applies minor patch upgrades, prompts for major migrations, diagnoses conflicts, runs vulnerability scans via npm audit pip-audit cargo audit Snyk. Use when updating packages, upgrading dependencies, fixing CVEs, resolving conflicts, auditing supply chain, running npm audit pip-audit cargo audit, managing package-lock.json requirements.txt go.mod Cargo.toml pom.xml build.gradle, or automating Dependabot Renovate PRs in CI/CD."
---

# Dependency Updates

Automate dependency management for any language. The skill detects the project type, applies safe minor and patch updates automatically, prompts for each major version change, and runs a security audit.

---

## When to use
- You need to bring a project's dependencies up‑to‑date.
- You want automatic minor/patch upgrades but manual control over breaking major upgrades.
- You require a quick security audit after updates.
- The project uses a common package manager (npm, pip, go, cargo, bundler, Maven, Gradle, dotnet, etc.).

---

## Workflow
1. **Detect project type** – Scan the repository for known manifest files (e.g., `package.json`, `requirements.txt`, `go.mod`).
2. **Verify tools** – Ensure the language‑specific update and audit tools are installed; suggest installation commands if missing.
3. **Check for outdated packages** – Run the appropriate "list outdated" command.
4. **Classify updates** – Separate into **PATCH**, **MINOR**, **MAJOR**, and **FIXED** (pinned) groups.
5. **Auto‑apply PATCH and MINOR** – Update these versions without user interaction.
6. **Prompt for each MAJOR** – Show current → new version and ask for approval.
7. **Apply approved MAJOR updates** – Update only the packages the user approved.
8. **Run install/build** – Execute the language’s install command to lock the new versions.
9. **Run security audit** – Scan for known vulnerabilities and report severity.
10. **Verify** – Run the checklist to confirm a clean state.

---

## Supported Languages & Tools
| Language | Manifest | Update Tool | Audit Tool |
|---------|----------|-------------|------------|
| Node.js | `package.json` | `taze` (or `npm-check-updates`) | `npm audit` |
| Python | `requirements.txt`, `pyproject.toml` | `pip-review` | `pip-audit`, `safety` |
| Go | `go.mod` | `go get -u` | `govulncheck` |
| Rust | `Cargo.toml` | `cargo update` | `cargo audit` |
| Ruby | `Gemfile` | `bundle update` | `bundle audit` |
| Java (Maven) | `pom.xml` | `mvn versions:use-latest-releases` | `mvn dependency:tree` (or OWASP Dependency‑Check) |
| Java (Gradle) | `build.gradle` | `./gradlew dependencyUpdates` | `./gradlew dependencyCheckAnalyze` |
| .NET | `*.csproj` | `dotnet list package --outdated` | `dotnet list package --vulnerable` |

---

## Commands by Language
### Node.js (npm/yarn/pnpm)
```bash
# List outdated packages
taze

# Apply only minor & patch updates
taze minor --write

# Apply selected major updates (replace pkg1,pkg2 with approved names)
 taze major --write --include pkg1,pkg2

# Install after updates
npm install   # or pnpm install / yarn install

# Security audit
npm audit
npm audit fix   # if safe fixes are available
```

### Python
```bash
# List outdated packages
pip list --outdated

# Auto‑apply safe updates (minor & patch)
pip-review --auto

# Update a specific package
pip install --upgrade package-name

# Security audit
pip-audit
safety check
```

### Go
```bash
# List outdated modules
go list -m -u all

# Update all modules (minor & patch)
go get -u ./...

go mod tidy   # clean up go.mod and go.sum

# Security audit
govulncheck ./...
```

### Rust
```bash
# List outdated crates
cargo outdated

# Apply safe updates
cargo update

# Security audit
cargo audit
```

### Ruby
```bash
# List outdated gems
bundle outdated

# Apply safe updates
bundle update

# Security audit
bundle audit
```

### Java (Maven)
```bash
# List outdated dependencies
mvn versions:display-dependency-updates

# Apply latest releases (minor & patch)
#mvn versions:use-latest-releases   # use with caution for majors

# Security audit (requires OWASP Dependency‑Check plugin)
mvn dependency-check:check
```

### .NET
```bash
# List outdated packages
dotnet list package --outdated

# Update a specific package
dotnet add package PackageName

# Security audit
dotnet list package --vulnerable
```

---

## Version Strategy
- **Semantic Versioning**: `MAJOR.MINOR.PATCH`
  - **MAJOR** – breaking changes, requires code changes.
  - **MINOR** – new features, backward compatible.
  - **PATCH** – bug fixes, backward compatible.
- **Range Specifiers**
  - `^1.2.3` → `>=1.2.3 <2.0.0` (allows minor & patch).
  - `~1.2.3` → `>=1.2.3 <1.3.0` (patch only).
  - Exact `1.2.3` pins the version (treated as **FIXED**).
- **Recommended `package.json` example**
  ```json
  {
    "dependencies": {
      "critical-lib": "1.2.3",   // exact, never auto‑updated
      "stable-lib": "~1.2.3",     // patch only
      "modern-lib": "^1.2.3"      // minor & patch allowed
    }
  }
  ```

---

## Diagnosis Mode
| Issue | Symptom | Fix |
|-------|---------|-----|
| Version conflict | Dependency resolution fails | Delete lock file, reinstall, or add `overrides`/`resolutions` (Node) or use constraints file (Python). |
| Peer dependency missing | Warning during install | Install the required peer version explicitly. |
| Security vulnerability | Audit reports high severity | Apply the suggested update or run `npm audit fix` / `pip-audit` fix. |
| Unused dependency | Large bundle size | Run `depcheck` (Node) or `pipdeptree` to identify and remove. |
| Duplicate versions | Multiple versions of same lib installed | Use `npm dedupe` (Node) or consolidate in `go.mod` (Go). |

**Emergency reset examples**
```bash
# Node.js
rm -rf node_modules package-lock.json
npm cache clean --force
npm install

# Python (virtualenv)
rm -rf venv
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Go
rm go.sum
go mod tidy
```

---

## Security Audit
Run the appropriate audit command for the project language (see Commands section). After the scan, handle findings by severity:
| Severity | Action |
|----------|--------|
| Critical | Fix immediately before any release. |
| High | Fix within 24 hours. |
| Moderate | Fix before next scheduled release. |
| Low | Document and fix in a future update. |

---

## Anti‑Patterns
| What to avoid | Why | Preferred practice |
|---------------|-----|--------------------|
| Auto‑apply MAJOR updates | May introduce breaking changes. | Prompt user for each major version. |
| Update pinned (fixed) versions automatically | Intentional version lock. | Skip packages with exact version specifiers. |
| Batch MAJOR prompts together | Loses context for each change. | Prompt individually and explain impact. |
| Ignore lock files | Reproducibility suffers. | Keep `package-lock.json`, `Pipfile.lock`, `go.sum`, etc., in version control. |
| Disregard audit warnings | Leaves known vulnerabilities. | Treat audit findings according to severity table. |

---

## Verification Checklist
- [ ] Project type detected correctly.
- [ ] All required tools are installed.
- [ ] Outdated packages listed without errors.
- [ ] PATCH and MINOR updates applied automatically.
- [ ] MAJOR updates prompted individually and applied only if approved.
- [ ] Fixed (pinned) versions left unchanged.
- [ ] Lock file updated and committed.
- [ ] Install/build command executed successfully.
- [ ] Security audit completed; critical/high issues resolved or documented.
- [ ] No residual dependency conflicts (`npm ls`, `pip check`, `go mod tidy` clean).

## Related skills

Load these when the task spans more than this skill.

- [`node`](../node/SKILL.md) — Node.js project conventions and setup rules. Load when creating, configuring, or working on any Node.js projec…
- [`python`](../python/SKILL.md) — Guidance for modern Python 3.12+ development. Includes framework selection, async vs sync decisions, project l…
- [`golang`](../golang/SKILL.md) — Provides expert guidance for Go 1.21+ development, covering concurrency patterns, performance tuning, microser…
- [`java`](../java/SKILL.md) — Guidance, best practices, and checklists for modern Java 21+ development, covering language features, virtual…
- [`security-compliance`](../security-compliance/SKILL.md) — Guides security and compliance work: risk assessment, control selection, framework mapping, ISMS implementatio…
- [`secure-coding`](../secure-coding/SKILL.md) — Secure coding guidance and review checklists for secrets, authentication, authorization, input validation, SQL…
- [`context7-docs`](../context7-docs/SKILL.md) — Fetch up‑to‑date library or framework documentation using the Context7 API within Claude Code sessions. Use wh…
