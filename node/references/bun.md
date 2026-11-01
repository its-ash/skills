# Bun Runtime

Bun as runtime, package manager, bundler, and test runner: when to choose it over Node, migration, commands, built-in APIs, and Vercel.

## When to use

- The project already uses Bun (`bun.lock`, `bunfig.toml`), or the user asks for Bun.
- You migrate a Node project to Bun, or write or debug Bun scripts and tests.
- You configure Bun on Vercel or another platform.

The parent [`node`](../SKILL.md) default stays npm. Use Bun only when one of the conditions above is true.

| Prefer Bun | Prefer Node |
| --- | --- |
| New JS/TS projects where install and run speed matter | Maximum ecosystem compatibility |
| One toolchain for run + install + test + build | Legacy tooling that expects Node |
| Vercel deployments with the Bun runtime | A dependency with known Bun issues |

## How it works

- **Version baseline:** this guidance targets Bun 1.4.x. Run `bun --version` before you rely on flag names, because CLI flags can change between releases.
- **Runtime:** Node-compatible runtime on JavaScriptCore. From Bun 1.4 the runtime is in Rust (it was Zig). It is not 100% Node-compatible: some native addons, less-common `node:` internals, and packages that depend on Node internals can fail. Verify before production use.
- **Package manager:** the lockfile is `bun.lock` (text). Older versions used `bun.lockb` (binary); Bun still reads it for migration, but new projects use `bun.lock`.
- **Bundler:** built-in bundler and transpiler for apps and libraries.
- **Test runner:** built-in `bun test` with a Jest-like API.

## Migration from Node

| Node | Bun |
| --- | --- |
| `node script.js` | `bun script.js` or `bun run script.js` |
| `npm install` | `bun install` |
| `npm run <script>` | `bun run <script>` |
| `npx <pkg>` | `bun x <pkg>` |

Node built-ins are supported. Use Bun APIs where they exist for better performance.

## Package and workspace commands

| Command | Effect |
| --- | --- |
| `bun add <pkg>` / `bun remove <pkg>` / `bun update [pkg]` | Manage dependencies |
| `bun outdated` | List stale dependencies |
| `bun pm ls [--all]` | List dependencies and resolved versions from the lockfile (`--all` adds transitive). Not an integrity check of installed files. |
| `bun audit` | Query registry advisories with names and versions from `bun.lock`. Does not change `package.json`, `bun.lock`, or `node_modules`. |
| `bun audit fix` | Upgrades and installs dependencies. It changes the lockfile, installed packages, and sometimes direct pins, and can run lifecycle scripts. Review it as a modifying install. |
| `bun dedupe` | Collapse duplicate installs |
| `bun prune` | Remove packages that are no longer referenced |
| `bun run --filter <pkg-name> <script>` | Run a script in one workspace |

- `bun audit` sends package metadata to the registry advisory endpoint. Make sure the destinations are approved before you audit private packages. Packages whose scoped registry has no advisory endpoint are skipped and do not change the exit code.
- Monorepos use a root `workspaces` array in `package.json` (same as npm/yarn).

## Built-in APIs

Use these before you add a dependency:

| Need | API |
| --- | --- |
| File I/O | `Bun.file`, `Bun.write` |
| Embedded SQLite | `bun:sqlite` |
| HTTP / WebSocket server | `Bun.serve` |
| SQL databases | [`Bun.sql`](https://bun.com/docs/runtime/sql) |
| Redis | [`Bun.redis`](https://bun.com/docs/runtime/redis) |
| S3-compatible storage | [`Bun.S3Client`](https://bun.com/docs/runtime/s3) |

```typescript
const pkg = await Bun.file("package.json").json();

Bun.serve({
  port: Number(process.env.PORT ?? 3000),
  fetch(req) {
    const { pathname } = new URL(req.url);
    return pathname === "/health" ? new Response("ok") : new Response("Not found", { status: 404 });
  },
});
```

## Run, env, and test

```bash
bun install                      # creates or updates bun.lock
bun run dev
bun src/index.ts                 # runs .ts directly
bun run --env-file=.env dev
FOO=bar bun run script.ts
bun test
bun test --watch
```

```typescript
// test/example.test.ts
import { expect, test } from "bun:test";

test("add", () => {
  expect(1 + 2).toBe(3);
});
```

CI options in Bun 1.4:

| Flag | Effect |
| --- | --- |
| `--changed[=<ref>]` | Run only affected tests |
| `--isolate` | Fresh JS global per file in the same process. Not a process or security sandbox. |
| `--parallel[=<n>]` | Worker processes (enables `--isolate`) |
| `--shard=<n>/<count>` | Split tests across CI jobs |
| `--timings=<file>` / `--update-timings` | Read / record durations for scheduling |

```bash
bun test --parallel --timings=./test-timings.json --update-timings
```

Check `bun test --help` for the installed version before you choose timing-file paths for multi-shard CI.

## Makefile (Bun variant)

Same targets as the parent [`node`](../SKILL.md) Makefile, with Bun commands:

```makefile
run:
	bun run dev

build:
	bun run build

deploy: build
	git checkout main
	git add -A
	git commit -m "$$(copilot -sp 'Analyze the staged git changes and generate a concise commit message. Output ONLY the commit message. Do not execute any commands. Do not include quotes, markdown, explanation, or bullet points.')"
	git push origin main
```

## Vercel

- Set `"bunVersion": "1.4.x"` in `vercel.json` to use Bun 1.4. See [Vercel Bun runtime docs](https://vercel.com/docs/functions/runtimes/bun).
- Build: `bun run build` or `bun build ./src/index.ts --outdir=dist`.
- Install: `bun install --frozen-lockfile` for reproducible deploys.

## Best practices

- Commit `bun.lock` for reproducible installs.
- Use `bun run` for scripts. Bun runs `.ts` natively.
- Keep `.nvmrc` if any tool or CI step still uses Node.
- Keep Bun and dependencies up to date; the ecosystem changes quickly.

## References

- [Bun 1.4 release notes](https://bun.com/blog/bun-v1.4)
- [bun audit](https://bun.com/docs/pm/cli/audit)

## Related skills

- [`node`](../SKILL.md) — project conventions, `.nvmrc`, env files, Makefile.
- [`typescript`](../../typescript/SKILL.md) — `tsconfig.json` and type checking (Bun does not type-check).
- [`unit-testing-patterns`](../../unit-testing-patterns/SKILL.md) — test structure for `bun test`.
