# Canary Watch — Post-Deploy Monitoring

Monitor a deployed URL after a release. Check HTTP endpoints, SSE streams, static assets, console errors, and performance regressions.

## When to use

- After deploying to production or staging
- After merging a risky PR
- When you want to verify a fix actually fixed it
- Continuous monitoring during a launch window
- After dependency upgrades

## How It Works

Monitors a deployed URL for regressions. Runs in a loop until stopped or until the watch window expires.

### What It Watches

```
1. HTTP Status — is the page returning 200?
2. Console Errors — new errors that weren't there before?
3. Network Failures — failed API calls, 5xx responses?
4. Performance — LCP/CLS/INP regression vs baseline?
5. Content — did key elements disappear? (h1, nav, footer, CTA)
6. API Health — are critical endpoints responding within SLA?
7. Static Assets — are JS, CSS, image, and font requests returning 2xx/3xx with expected content types?
8. SSE Streams — do event-stream endpoints connect and receive an initial event or heartbeat?
```

### Watch Modes

| Mode | What to do |
|------|------------|
| Quick check (default) | Do one pass on the URL and report the results. |
| Sustained watch | Do the check every N minutes for M hours (for example, every 5 min for 2 h during a launch). |
| Diff mode | Do the same checks on staging and production, and compare the results. |

A minimal HTTP and asset pass with `curl`:
```bash
URL=https://myapp.com
curl -s -o /dev/null -w '%{http_code} %{time_total}s\n' "$URL"
curl -s -o /dev/null -w '%{http_code} %{content_type}\n' "$URL/health"
curl -sN --max-time 10 -H 'Accept: text/event-stream' "$URL/events" | head -n 3
```
For console errors, Core Web Vitals, and content checks, use a browser tool (see [performance.md](performance.md) and [browser-qa](../../unit-testing-patterns/references/browser-qa.md)).

### Alert Thresholds

```yaml
critical:  # immediate alert
  - HTTP status != 200
  - Console error count > 5 (new errors only)
  - LCP > 4s
  - API endpoint returns 5xx
  - Static asset returns 4xx/5xx
  - SSE endpoint cannot connect or drops before first heartbeat

warning:   # flag in report
  - LCP increased > 500ms from baseline
  - CLS > 0.1
  - New console warnings
  - Response time > 2x baseline
  - Static asset content type changed unexpectedly
  - SSE heartbeat latency > 2x baseline

info:      # log only
  - Minor performance variance
  - New network requests (third-party scripts added?)
```

### Notifications

When a critical threshold is crossed:
- Desktop notification (macOS/Linux)
- Optional: Slack/Discord webhook
- A log file in the project or in the CI artifacts

## Output

```markdown
## Canary Report — myapp.com — 2026-03-23 03:15 PST

### Status: HEALTHY ✓

| Check | Result | Baseline | Delta |
|-------|--------|----------|-------|
| HTTP | 200 ✓ | 200 | — |
| Console errors | 0 ✓ | 0 | — |
| LCP | 1.8s ✓ | 1.6s | +200ms |
| CLS | 0.01 ✓ | 0.01 | — |
| API /health | 145ms ✓ | 120ms | +25ms |
| Static assets | 42/42 ✓ | 42/42 | — |
| SSE /events | connected ✓ | connected | +80ms heartbeat |

### No regressions detected. Deploy is clean.
```

## Integration

Pair with:
- [browser-qa](../../unit-testing-patterns/references/browser-qa.md) for pre-deploy verification
- [benchmark.md](benchmark.md) for the baseline values
- CI: run the checks in GitHub Actions after the deploy step (see [github-actions](../../devops-iac/references/github-actions.md))
