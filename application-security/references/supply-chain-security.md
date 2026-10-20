# Supply Chain Security

This skill helps detect and remediate software supply chain attacks across npm, PyPI, crates.io, GitHub Actions, and CI/CD pipelines. It combines dependency review, IOC checks, CI/CD hardening, remediation, and prevention. Threat intelligence in this skill is current as of 2026-03-31.

## When to use

- Audit a project's dependencies before production deployment.
- Investigate a suspected supply chain compromise.
- Check exposure after a newly reported attack.
- Harden CI/CD pipelines and dependency workflows.
- Perform regular security checks during development.

## Workflow

1. Identify the ecosystems in use.
2. Inventory dependencies and lockfiles.
3. Compare manifests and lockfiles against trusted advisories.
4. Inspect installed artifacts and source for IOCs.
5. Audit CI/CD configuration.
6. Classify findings as critical or warning.
7. Remediate using the steps below.
8. Reinstall from clean lockfiles and verify.
9. Apply hardening measures.

## Ecosystem files

- Node.js/npm: `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- Python/PyPI: `requirements.txt`, `Pipfile`, `pyproject.toml`, `poetry.lock`
- Rust/crates.io: `Cargo.toml`, `Cargo.lock`
- CI/CD: `.github/workflows/`, `Dockerfile`, `docker-compose.yml`

## Dependency checks

- Confirm lockfiles are committed and match manifests.
- Review new, changed, or unexpected dependencies.
- Compare package names and versions against advisories from Socket, Aikido, Endor Labs, Snyk, and JFrog.
- Inspect package scripts, especially npm `postinstall` and Python setup hooks.
- Review maintainer and ownership changes for critical dependencies.

Useful commands:

```bash
npm ci
pip check
python -m pip install --require-hashes -r requirements.txt
cargo tree
```

## IOC and filesystem checks

- Treat any known malicious package or active IOC as a compromise.
- Search for persistence mechanisms:
  - Python `.pth` files in site-packages
  - systemd user or system units
  - cron jobs
  - shell profile modifications
- Search source and configuration for network indicators from trusted advisories.
- Inspect recently changed dependencies and build artifacts.
- Check for unexpected outbound network behavior during builds or tests.

## CI/CD audit

- Pin every GitHub Action to a full commit SHA, not a version tag.
- Add `--ignore-scripts` to npm install and npm ci commands.
- Add `--require-hashes` to pip install commands.
- Remove or tightly secure `pull_request_target` triggers.
- Apply least-privilege permissions to workflow tokens.
- Audit pipeline execution logs for relevant attack windows.
- Avoid exposing npm tokens, PyPI credentials, or `.env` files in logs or artifacts.

## Remediation

### If a compromised package is found

1. Remove the package or downgrade to a known safe version.
2. Clear package caches: `npm cache clean --force` or `pip cache purge`.
3. Delete `node_modules` or `.venv`.
4. Reinstall from the committed lockfile.
5. Rotate all credentials accessible from the environment.

### If filesystem IOCs are found

1. Treat the system as fully compromised.
2. Identify and remove persistence mechanisms.
3. Rotate every credential on the system.
4. Audit cloud provider logs.
5. Check for lateral movement in Kubernetes clusters.
6. Consider reimaging the machine.

### If CI/CD issues are found

1. Pin all GitHub Actions to full commit SHAs.
2. Add `--ignore-scripts` to npm install and ci commands.
3. Add `--require-hashes` to pip install commands.
4. Remove or secure `pull_request_target` triggers.
5. Apply least-privilege permissions to workflow tokens.
6. Audit pipeline execution logs for attack window periods.

## Hardening

1. Commit lockfiles and use exact version pins.
2. Use `npm ci` instead of `npm install`.
3. Use `pip install --require-hashes`.
4. Disable scripts by default and enable them only for trusted packages.
5. Pin GitHub Actions to full SHAs.
6. Scope CI/CD tokens to minimal permissions.
7. Monitor dependencies, but verify scanner integrity before trusting it.
8. Block known C2 domains and IPs at the firewall.
9. Audit dependencies before every deployment.
10. Review new dependencies and maintainer changes regularly.

## Threat landscape as of 2026-03-31

- TeamPCP: A cascading credential-chain campaign. It compromised Trivy to steal CI/CD secrets, deployed CanisterWorm across 141+ npm packages, backdoored LiteLLM and Telnyx on PyPI, uses blockchain-based C2, uses WAV steganography, targets Kubernetes for lateral movement, and has a destructive variant.
- axios npm hijack on 2026-03-31: `axios@1.14.1` and `axios@0.30.4` contained a RAT dropper through a fake `plain-crypto-js` dependency. The package has 300M+ weekly downloads. The RAT is cross-platform. The maintainer account `jasonsaayman` was compromised.
- Malicious Rust crates in February and March 2026: Five crates impersonated time utilities and stole `.env` files, AWS credentials, and SSH keys.
- Shai-Hulud worm: A self-replicating npm worm that compromised about 1000 packages, targets npm tokens, and has a destructive fallback that wipes the home directory if exfiltration fails.

## Checklist

- [ ] Ecosystems and lockfiles identified.
- [ ] Dependencies compared against trusted advisories.
- [ ] No known malicious packages or versions present.
- [ ] No filesystem or network IOCs found.
- [ ] GitHub Actions pinned to full commit SHAs.
- [ ] npm uses `--ignore-scripts` where appropriate.
- [ ] pip uses `--require-hashes` where appropriate.
- [ ] Workflow permissions follow least privilege.
- [ ] Credentials rotated if compromise is suspected.
- [ ] Hardening measures applied.
