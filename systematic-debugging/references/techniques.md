# Debugging techniques and commands

## Error classes

| Category | Indicators | Typical causes |
|---|---|---|
| Syntax | Parse error, unexpected token | Typo, missing bracket |
| Type | `TypeError`, type mismatch | Wrong type, null access |
| Reference | `NameError`, undefined variable | Scope |
| Runtime | Uncaught exception | Logic error, invalid op |
| Network | Timeout, `ECONNREFUSED`, 4xx/5xx | Wrong URL, server down |
| Permission | `EACCES`, `PermissionError` | File rights, missing sudo |
| Dependency | `ModuleNotFound`, version conflict | Missing or wrong package |
| Configuration | Missing env var, bad config | Wrong settings |
| Database | Connection refused, query error | Bad credentials, bad SQL |
| Memory | OOM, heap exhausted | Leak, huge data set |

## Boundary instrumentation (multi-layer example: CI code-signing)

Log at each layer; the first layer with bad data is the fault.

```bash
echo "=== Workflow secrets ==="; echo "IDENTITY: ${IDENTITY:+SET}${IDENTITY:-UNSET}"
echo "=== Build env ===";        env | grep IDENTITY || echo "IDENTITY missing"
echo "=== Keychain ===";         security list-keychains; security find-identity -v
echo "=== Sign ===";             codesign --sign "$IDENTITY" --verbose=4 "$APP"
```

Never echo secret values; print SET/UNSET only.

## Isolation techniques

- **Binary search**: disable half the code path, rerun, repeat.
- **Minimal repro**: start empty; add code until the error appears.
- **Rubber duck**: explain each step aloud; the wrong assumption shows.
- **Git bisect**:
  ```bash
  git bisect start; git bisect bad; git bisect good <last-good>
  # test each checkout, mark good/bad; or: git bisect run <test-cmd>
  git bisect reset
  ```

## Commands

```bash
# Node
NODE_DEBUG=* node app.js        # verbose core-module logs
node --inspect app.js           # DevTools debugger / heap
npm ls [pkg]; npm ls --depth=0  # installed versions, conflicts
# Python
python -m pdb script.py
pip list; pip show [pkg]
# System
ls -la [file]                   # permissions
lsof -i :[port]; netstat -an | grep [port]
env | grep VAR; printenv VAR
df -h                           # disk
free -m                         # memory (Linux)
vm_stat                         # memory (macOS)
```

## Checklist

- [ ] Full error and stack trace captured.
- [ ] Repro steps written.
- [ ] Recent code, config, dependency changes reviewed.
- [ ] Boundaries instrumented (multi-component).
- [ ] Bad value traced to origin.
- [ ] Working reference found; all differences listed.
- [ ] One hypothesis, tested with the smallest change.
- [ ] Failing test written.
- [ ] One root-cause fix applied.
- [ ] New test and full suite pass.
- [ ] Three failed fixes → stop, review architecture.
- [ ] Solution recorded (optional).
